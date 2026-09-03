# Architecture and practices (2024–2026)

Trends that settled in real Python codebases (uv, Ruff, stdlib
`tomllib` / `zoneinfo` / `TaskGroup`, Pydantic at the edge) — not
hexagonal folder fashion.

## Stdlib-first

The stdlib closed the gaps that used to justify a starter kit of deps:

- 3.10 `X \| Y` / `list[str]` / `match` → typing and closed sets
- 3.11 `tomllib`, `TaskGroup`, `ExceptionGroup`, `asyncio.timeout`
- 3.12 `type` / `[T]` / `@override`
- 3.13 `TypeIs`
- 3.14 deferred annotations, `t""`, `uuid.uuid7`

Add a package when it does something the standard library will not (a
database driver, OpenTelemetry, Pydantic at a trust boundary, httpx for
HTTP). Do not add a second library for paths, TOML reads, time zones,
or UUID on 3.14+.

Django / FastAPI / Flask / Typer stay if the project already has them.
Do not replace them as a drive-by restyle. Do not introduce FastAPI for
a 40-line script.

## Layout

Official instinct: start as one package next to `pyproject.toml`.
`uv init` uses `src/<name>/` when the project is a package (library or
console script). `--no-package` stays flat. Honor the tree already
there.

```
src/<name>/__init__.py    # or <name>/ next to pyproject.toml
src/<name>/<noun>.py      # named for the noun
src/<name>/__main__.py    # wiring only when it is a CLI
pyproject.toml            # requires-python; [project.scripts] if any
```

- Tests live next to the code (`test_foo.py`) or under `tests/` if that
  is already the suite. How to run them: `git-repo-setup-python`.
- `__main__.py` / the console script stays small: construct deps, run,
  exit. Business logic is not in the entry once it has tests.
- Libraries declare `[project]` and a build backend. Do not invent a
  `pkg/` directory.

Do **not** create `domain/`, `usecase/`, `adapter/`, `controller/`,
`repository/`, `utils/`, `helpers/`, `common/` layers for a small
package. Flatten. Extract a module when an import cycle or a second
entry forces it.

Dual-store / cache: `source-of-truth`. Schema types: `data-modeling`.
Slice vs map: `choose-collections`. Keys: `identity`.

Do not barrel-re-export every name from `__init__.py`. Import the
module that defines the symbol.

## Dependency direction

One-way:

```
entry → http or cli → <domain>
<domain> → stdlib / vendor SDK only
```

Domain packages must compile without FastAPI, Django, or Click. Config
that is just "how we dial" belongs next to the client, not under the
CLI.

## Components

- **Protocol at the consumer.** The caller declares the two or three
  methods it calls. The producer does not export a 20-method ABC "for
  mocking".
- **Fakes over mocks.** An in-memory fake in `test_foo.py` beats
  MagicMock for most domain tests. `unittest.mock` at a stubborn I/O
  boundary, not on every class.
- **No global clients.** `httpx.Client`, engines, and pools are
  constructed in the entry and passed down. `contextlib.closing` /
  `with` for handles.
- **Options:** a dataclass of options for 2+ optional fields. No
  `**kwargs` grab-bag on an internal function with one caller.
- **Config:** typed struct (dataclass or Pydantic model), filled from
  env/flags in the entry. No module named `config` that accumulates
  unrelated fields.

## Concurrency

- Every task's lifetime is visible: `asyncio.TaskGroup` (3.11+), or a
  server shutdown. No fire-and-forget `loop.create_task` in libraries.
- Honor cancellation. `asyncio.timeout` around I/O.
- Shared state: a lock or owner task, not both on the same data.
- Threads: `concurrent.futures` when the work is blocking I/O the
  event loop must not see. Do not mix threads and asyncio on the same
  socket.

## HTTP (when you add a client)

```python
async with httpx.AsyncClient(timeout=10.0) as client:
    r = await client.get(url)
    r.raise_for_status()
```

Sync `httpx.Client` is fine when the process is sync. Honor `requests`
if that is already the client. Time out. Do not use `httpx.get` as a
process-wide singleton.

Parse the body at the boundary (Pydantic / msgspec). Never
`cast(User, r.json())`.
