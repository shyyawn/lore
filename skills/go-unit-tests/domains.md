# Domains

What to assert per kind of code. Shapes: [methods.md](methods.md). Encore
and Temporal keep their own runners — do not reimplement them here.

## Pure domain / validation

Table every branch the function documents. Include empty, nil, overflow,
unicode, and the error the caller is supposed to `errors.Is`. Pass `now
time.Time` into functions that care about "today" rather than calling
`time.Now()` inside.

Do not test that `len` works. Do not test unexported normalizers the
exported function already exercises.

## HTTP handlers

`httptest.NewRecorder` + `httptest.NewRequestWithContext(t.Context(), ...)`.
If the handler reads `r.PathValue`, go through `http.NewServeMux` (1.22
patterns). Bare handler funcs never fill PathValue.

Assert status, the headers you own, and the decoded body. Do not re-test
service rules already covered in the domain package — the handler test
owns mapping (401 vs 404 vs 409) and routing.

Client code: `httptest.NewServer` (or `NewTLSServer`). Close with
`t.Cleanup(srv.Close)`. Use `srv.Client()`. Do not listen a fixed port.
1.27+: `httptest.NewTestServer` for in-memory / `synctest` (no real TCP).

Do not `http.Get` in a unit test. Do not assert that ServeMux matched a
pattern you did not write.

## SQL / stores

Service tests take a fake store (in-memory map). That is the unit test.

The SQL itself is an **integration** test against a real engine
(`//go:build integration` or `testing.Short` skip): schema, constraints,
`ErrNoRows` → `ErrNotFound`, unique violation → `ErrAlreadyExists`,
rollback. Encore: `et.NewTestDatabase` (`encore-go`). Otherwise
SQLite in-process, or testcontainers when you need the production dialect.

Do not introduce `sqlmock` / a generated DB mock in new code. Do not unit
test the driver. Do not `fmt.Sprintf` SQL in production just because a
mock made it easy.

## Filesystem and I/O

Production that accepts `fs.FS` / `io.Reader` is testable. `fstest.MapFS`
for reads. `t.TempDir` for writes. `os.Root` (1.24) when the contract is
"cannot escape this directory" — assert both the happy path and `../`.

Readers you wrote: `iotest.HalfReader`, `ErrReader`, `TimeoutReader`,
`TestReader`. Partial reads are the edge case, not the full-buffer path.

Do not `os.WriteFile("/tmp/test-...")`. Do not chdir with `os.Chdir`.

## JSON / codecs / parsers

Types with custom marshalers: round-trip table + fuzz. `omitzero` on
`time.Time` (1.24). Assert `nil` vs empty slice only when the JSON
contract cares.

Do not test encoding/json itself. Fuzz the parser; commit crashers.

## Crypto

1.26+: `cryptotest.SetGlobalRandom(t, seed)` for deterministic keys /
signatures. Not parallel. Do not assert exact ciphertext without it —
algorithms may draw rand internally and the stream is not an API.

Do not test that `crypto/rand` is random. Do not seed `math/rand` for
secrets.

## slog

If you implement `slog.Handler`, `testing/slogtest.TestHandler` /
`Run`. Otherwise do not assert log text. Optional: attach
`slog.NewTextHandler(t.Output(), nil)` so failures are diagnosable.

## CLI / config

`t.Setenv` for env-backed config (no Parallel). Flag parsing: table of
argv slices. Rendered output: `testdata` golden, not a screenshot of
`--help` unless it is the contract.

`Example` functions with `// Output:` double as godoc.

## Context

Every I/O function: cancel before start (immediate error) and cancel
during (does not succeed after cancel). `t.Context()` as the live ctx.
Do not `context.Background()` in new tests on 1.24+.

## Iterators (`iter.Seq`)

Empty, one, many, and early `break` (yield returns false — producer must
stop). Error mid-stream if the iterator can fail. Do not only range to
completion.

## Generics

If behaviour depends on the type parameter, table two concrete types.
If it does not, one type is enough. Do not instantiate "to look generic".

## Caches / TTL / rate limits

`synctest` for expiry and cooldown. Assert hit, miss, eviction policy,
and that cancel does not corrupt the map (race). Do not Sleep(1s) in CI.

## net.Conn / protocols

`net/nettest` when you implement `net.Conn`. Otherwise `httptest` or a
fake conn in-process. Do not bind `:0` and hope the test runner is alone.

## What lives behind tags

| Default `go test ./...` | `//go:build integration` or `-short` skip |
| --- | --- |
| Domain tables, handler recorder, fakes, fuzz seed, synctest | Real Postgres/MySQL, real Temporal server, real S3, multi-process |
| `httptest.Server` (loopback) | Cross-service staging |

Unit tests are never tagged `integration`. Integration tests never replace
the unit table.

## Encore

`encore test`. Call APIs as functions. Real isolated DBs/topics.
`et.MockEndpoint` / `et.MockService` for **other services**, not for the
package under test. `et.NewTestDatabase`. No `time.Sleep` for Pub/Sub —
`et.Topic(T).PublishedMessages()`. Full recipe: `encore-go`.

## Temporal

`testsuite.WorkflowTestSuite`. Register activities or fake them. Time
skipping is built in — no `Sleep`. Replay + checked-in history before
changing a running workflow. Unique Task Queues in integration.
Deadlock detector may need a longer timeout **in the test env only**.
Full recipe: `temporal-go`.

## Edge cases worth a table row

These fail in production and are cheap in a table. Skip the ones that
cannot reach the function.

- `nil` vs empty slice vs missing JSON field
- empty string, whitespace-only, invalid UTF-8
- 0, -1, `math.MaxInt`, overflow on convert
- duplicate IDs, already-exists, not-found
- context canceled / deadline exceeded at start and mid-call
- wrapped errors (`Is` through `%w` / `Join`)
- partial `io.Reader` (iotest)
- `../` and absolute paths on file APIs
- method mismatch, missing path param, huge body (handler)
- second apply of an idempotent op
- concurrent `Get`/`Set` (`-race`, not a Sleep)
- iterator `break` on first yield
- timezone: store UTC, do not `==` local wall times
