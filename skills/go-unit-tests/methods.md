# Methods

Canonical shapes. Gate symbols on `go.mod` ([SKILL.md](SKILL.md)). Domain
recipes: [domains.md](domains.md).

## Files and packages

- `foo_test.go` next to `foo.go`. `testdata/` for fixtures (the tool ignores it
  as a package). Fuzz crashes: `testdata/fuzz/FuzzXxx/`.
- `package foo` when you must see unexported invariants.
- `package foo_test` to lock the public API (libraries). Prefer this once the
  API is the product.
- `export_test.go` (`package foo`) to expose a test-only name to `foo_test`.
  Do not export it from production files.
- `TestMain` only for process-level setup that cannot be `t.Cleanup` (rare).
  Do not start a shared mutable server in `TestMain`.

## Table-driven

Default for more than one input/output pair. Separate `TestXxx` functions when
setup, teardown, or assertions diverge.

```go
func TestParse(t *testing.T) {
	tests := []struct {
		name    string
		in      string
		want    Result
		wantErr error
	}{
		{name: "empty", in: "", wantErr: ErrEmpty},
		{name: "ok", in: "ok", want: Result{V: "ok"}},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			got, err := Parse(tt.in)
			if tt.wantErr != nil {
				if !errors.Is(err, tt.wantErr) {
					t.Fatalf("Parse(%q) err = %v, want %v", tt.in, err, tt.wantErr)
				}
				return
			}
			if err != nil {
				t.Fatalf("Parse(%q) unexpected err %v", tt.in, err)
			}
			if got != tt.want {
				t.Errorf("Parse(%q) = %+v, want %+v", tt.in, got, tt.want)
			}
		})
	}
}
```

- Subtest name is a stable id, not a sentence. It shows up in `-run` and CI.
- 1.22+: no `tt := tt`. Below 1.22, copy the range var before `t.Parallel`.
- `t.Fatal` when the rest of the case is meaningless; `t.Error` to collect.
- Comparable values: `==`, `slices.Equal`, `maps.Equal`. Nested structs: dump
  with `%+v`, or `cmp.Diff` **if the module already has**
  `github.com/google/go-cmp`. Stdlib `cmp` is ordering, not diffs.
- Do not table-ize unrelated cases that share no fields.

## Helpers

```go
func eq[T comparable](t *testing.T, got, want T) {
	t.Helper()
	if got != want {
		t.Errorf("got %v, want %v", got, want)
	}
}
```

`t.Helper()` on every assertion helper so failures point at the caller.
Keep helpers in the `_test.go` file that uses them. Third copy → same-package
unexported func, not a `testutil` package.

## Isolation

| Need | Use | Never with `t.Parallel` |
| --- | --- | --- |
| Context | `t.Context()` (1.24); cancelled before Cleanup | — |
| Temp files | `t.TempDir()` | — |
| Env | `t.Setenv` | yes |
| Cwd | `t.Chdir` (1.24) | yes |
| Crypto rand | `cryptotest.SetGlobalRandom(t, seed)` (1.26) | yes (process-global) |
| Cleanup | `t.Cleanup` immediately after the resource exists | — |
| Artifacts you want to keep | `t.ArtifactDir()` + `go test -artifacts` (1.26) | — |

`t.Context()` is cancelled **before** Cleanup runs — so servers that shut down
on `ctx.Done()` can drain, then Cleanup closes the rest.

`t.Parallel()` when the case shares no globals, files, env, or process-wide
crypto. Parent `Parallel` plus child `Setenv` still panics.

## Fakes, not mocks

Consumer-side interface, methods that consumer needs (`go-idioms`). In the
test file, a small concrete fake:

```go
type memStore struct{ m map[string]Item }

func (s *memStore) Get(_ context.Context, id string) (Item, error) {
	it, ok := s.m[id]
	if !ok {
		return Item{}, ErrNotFound
	}
	return it, nil
}
```

- **Fake** (working subset) for stores, clocks you still need below 1.25, queues.
- **Stub** (canned return) for a single error path.
- **Spy** (record calls) only when the side effect *is* the contract
  (you must publish exactly once).
- **Mock** (expect call order) only at a stubborn I/O protocol, and only if
  the repo already uses testify/mock or mockery.

Do not generate a mock of an interface the production package defined "for
testing". Do not assert `AssertCalled` when the output already changed.

## Errors

- `errors.Is` for sentinels. `errors.AsType[*E]` on 1.26+; else `errors.As`.
- Do not compare `err.Error()` strings. Messages are not API.
- `wantErr error` in the table, not `wantErr bool`, when more than one
  sentinel exists.
- Wrapped errors: the test uses the same `Is`/`As` the caller will.

## Concurrency and time

Push concurrency up. A synchronous `Cleanup()` plus `go cache.Cleanup()` at
the call site is easier to test than `CleanupInBackground()`.

When the API is inherently async or timed, wrap the test in a bubble
(1.25+):

```go
func TestExpires(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		c := New(time.Second)
		c.Set("k", "v")
		time.Sleep(time.Second)
		synctest.Wait()
		if _, ok := c.Get("k"); ok {
			t.Fatal("still present")
		}
	})
}
```

- Fake clock starts at midnight UTC 2000-01-01. `time.Sleep` inside the bubble
  is instant once every goroutine is durably blocked.
- `synctest.Wait()` takes **no** `*testing.T`. Inner `t` must not call
  `Run`, `Parallel`, or `Deadline`.
- Durable block: bubble channels, `time.Sleep`, `WaitGroup.Wait` (Add inside
  the bubble), `sync.Cond.Wait`. **Not** durable: `Mutex`, network I/O,
  syscalls, channels created **outside** the bubble.
- Operating on a bubbled channel/timer from outside panics.
- 1.27+: `synctest.Sleep(d)` is `time.Sleep(d)` + `Wait()` — prefer it so
  the test settles after the same instant as the code under test.
- Below 1.25: a ready `chan struct{}`, or inject `now time.Time` into pure
  functions. Do not add a Clock interface only to avoid `Sleep`.

`go test -race` on packages that start goroutines. A race is a bug.

## Fuzz

For parsers, codecs, validators, anything that takes untrusted bytes or
strings. Seed with `f.Add`. The function passed to `f.Fuzz` must be
deterministic and side-effect free (no net, no sleep, no globals).

```go
func FuzzParse(f *testing.F) {
	f.Add([]byte(`{"a":1}`))
	f.Fuzz(func(t *testing.T, in []byte) {
		v, err := Parse(in)
		if err != nil {
			return
		}
		out, err := Marshal(v)
		if err != nil {
			t.Fatal(err)
		}
		v2, err := Parse(out)
		if err != nil || v != v2 {
			t.Fatalf("round trip: %v %v", v2, err)
		}
	})
}
```

`go test` (no `-fuzz`) already runs the seed corpus and any committed crashers
in `testdata/fuzz/FuzzXxx/`. Keep those files. CI does **not** need
`-fuzz` on every PR; a scheduled `-fuzz=FuzzParse -fuzztime=30s` job is
enough. Only one `-fuzz` target per `go test` invocation. Coverage-guided
fuzzing needs amd64/arm64.

Do not fuzz through a real DB or HTTP server.

## Benchmarks

```go
func BenchmarkParse(b *testing.B) {
	in := setup(b) // not timed
	for b.Loop() { // 1.24+; do not mix with b.N
		Parse(in)
	}
}
```

Report allocs with `b.ReportAllocs()` when allocs are the point.
`testing.AllocsPerRun` panics if tests are parallel (1.25+). Do not
optimize production from a benchmark that includes setup.

## Examples

`Example`, `ExampleF`, `ExampleT_M` — compiled always; executed when they
end with `// Output:` (or `// Unordered output:`). These are docs, not a
substitute for tables. Keep them short.

## Golden / testdata

Fixtures live in `testdata/`. Read with a path relative to the package
directory (`os.ReadFile("testdata/in.json")`). Prefer `t.TempDir` for writes.

Golden files: compare bytes/string. An `-update` flag in the test file is
fine; do not add a golden library. Do not Parallel a test that rewrites
goldens.

## CI flags

| Flag | When |
| --- | --- |
| `go test ./...` | Every change (`encore test` if `encore.app`) |
| `-race` | CI, packages with goroutines. Skip only for known CGO incompatibility. |
| `-shuffle=on` | CI. Catches order dependence. |
| `-count=1` | Debugging flakes / cache lies. Not default CI (cache is useful). |
| `-short` | Default PR job when integration is slow. Integration job omits it. |
| `-tags=integration` | Files with `//go:build integration`. |
| `-coverprofile` | Local diagnosis. Do not gate merge on a percentage. |
| `-fuzz=FuzzXxx -fuzztime=30s` | Scheduled, not every PR. |
| `-artifacts` | Keep `t.ArtifactDir()` output (1.26). |
| `-json` | CI parsers. `t.Attr` (1.25) shows up as an `attr` action. |

`git-repo-setup-go` owns where these commands sit in Lefthook / just / CI.
Do not run the full suite on every commit.

## Logs in tests

`slog.New(slog.NewTextHandler(t.Output(), nil))` (1.25 `t.Output`) to see
app logs in test output. Do not assert on those strings.
`testing/slogtest` only when the code **is** a `slog.Handler`.
