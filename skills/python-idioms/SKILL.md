---
name: python-idioms
description: >-
  Writes, restyles, and reviews Python using idioms from Python 3.10
  through 3.14 (match, X|Y unions, TaskGroup, tomllib, type params,
  TypeIs, deferred annotations, t-strings, uuid.uuid7) and 2024–2026
  architecture practices (stdlib-first, pathlib, Protocol at the
  consumer). Use when generating, editing, reviewing, or modernizing
  Python; when the user mentions idiomatic Python, 2026 Python,
  pyproject.toml, requires-python, or matching .python-version.
---

# Python 2026

Write Python as if Ruff already rewrote against the project's
`requires-python`. Do not emit tutorial Python (`Optional[List[str]]`,
`os.path`, `print` in libraries, `requests` next to `httpx`, `setup.py`
beside a working `pyproject.toml`).

Full catalogs: [versions.md](versions.md) (3.10→now),
[modernizers.md](modernizers.md) (Ruff UP), [architecture.md](architecture.md)
(2024–2026 structure). Kit: `git-repo-setup-python`. Collections:
`choose-collections`. Keys: `identity`.

## First step

Read `pyproject.toml` (`requires-python`) and `.python-version` if
present. Target that pin. Do not bump Python to unlock an idiom.

| Pin | Always use | Not yet |
| --- | --- | --- |
| 3.14+ | everything below plus deferred annotations, `t""` templates, `uuid.uuid7`, `heapq.heapify_max`, `annotationlib` | 3.15 lazy imports, `frozendict`, `sentinel`; free-threaded as the default |
| 3.13 | `TypeIs`, TypeVar defaults, `ReadOnly` | deferred annotations as the default; `uuid.uuid7`; `t""` |
| 3.12 | `type` aliases, `[T]` type params, `@override` | `TypeIs` |
| 3.11 | `ExceptionGroup` / `except*`, `asyncio.TaskGroup`, `tomllib`, `Self` | PEP 695 syntax |
| 3.10 | `match`, `X \| Y`, `list[str]`, `zip(..., strict=True)` | `TaskGroup`, `tomllib` |

Free-threaded / no-GIL builds and 3.15 RC APIs are out of scope unless
the project already enables them. Do not bump to 3.15 (final is not
this pin).

## After every Python edit

```bash
uv run ruff format <files>     # or ruff on PATH if the repo has no uv
uv run ruff check --fix <files>
```

If `ty` / `pyright` / `mypy` is already the gate, run that too. Do not
add a typechecker as a drive-by. Write the modern form the first time.
Do not write `Optional[List[T]]` and wait for Ruff. Formatter: Ruff.
Do not introduce Black next to it (`git-repo-setup-python`).

## When it breaks

| Symptom | Usually means |
| --- | --- |
| `uuid.uuid7` / `t"..."` / `heapq.heapify_max` missing | pin is below 3.14. Write to `requires-python`; do not bump |
| `TypeIs` missing | pin is below 3.13. Keep `TypeGuard` |
| `type Point = tuple[int, int]` syntax error | pin is below 3.12. `Point: TypeAlias = …` |
| `from tomllib` ImportError | pin is below 3.11. Honor `tomli` if already there |
| Ruff UP wants `X \| None` and CI is 3.9 | pin is below 3.10. Do not apply that UP rule |
| `__annotations__` is empty / a function on 3.14 | deferred annotations. `annotationlib.get_annotations` |

## Language (3.10 → now)

- Builtins in annotations: `list[str]`, `dict[str, int]`, `X \| None`.
  Never `List`, `Dict`, `Optional`, `Union` for those.
- `match` for a closed set of shapes. `if/elif` stays for predicates.
- `type` aliases and `[T]` type params (3.12+). Below 3.12,
  `TypeAlias` / `TypeVar`.
- `@override` (3.12+) on methods that must match a base. `TypeIs` (3.13+)
  when a narrow *is* the type; `TypeGuard` only when it is a subset.
- `from __future__ import annotations` on 3.13 and below for forward
  refs. Do not add it on 3.14 — deferred is the default.
- `t""` (3.14+) only to build a `string.templatelib.Template` for a
  processor. `f""` still formats. Do not log with `t""`.
- `pathlib.Path`. No `os.path` join / exists in new code.
- No mutable defaults (`def f(xs=[])`). No `from x import *`. No
  `# type: List[int]` comments.

## Architecture (2024–2026)

Stdlib-first: do not add a dependency the standard library now covers.
Same instinct as Go ([architecture.md](architecture.md)).

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP client | `httpx` (sync or async); honor `requests` | a second client; new `requests` next to `httpx` |
| HTTP server | honor Django / FastAPI / Starlette / Flask | FastAPI as fashion on a script |
| Validation at a boundary | Pydantic v2 (or the repo's msgspec) | `cast()` on `request.json`; a second schema lib |
| Dates | `datetime` + `zoneinfo` | new `pytz` / `arrow` / `pendulum` |
| IDs | `uuid.uuid4()`; 3.14+ `uuid.uuid7()` (`identity`) | a UUID package on 3.14+ |
| TOML read | `tomllib` (3.11+) | new `toml` / `tomli` on 3.11+ |
| Paths | `pathlib` | `os.path` for new code |
| CLI | `argparse`; Typer / Click if already there | a new CLI framework beside an existing one |
| Logging | `logging.getLogger(__name__)` | `print` in libraries; new `loguru` as fashion |
| Structured concurrency | `asyncio.TaskGroup` (3.11+) | `asyncio.gather` that swallows |

Layout is earned: start as a package next to `pyproject.toml`. `uv init`
`src/<name>/` for a library or CLI you install; flat when that is
already the tree. No `utils/`, `helpers/`, `common/`, `domain/` /
`usecase/` / `adapter/` unless the repo is already that shape. Kit
layout: `git-repo-setup-python`. Do not recopy it.

- Name packages for what they **are**.
- One-way imports: domain must not import FastAPI, Click, or Django
  wiring.
- `Protocol` at the **consumer**, methods that consumer needs. Do not
  export a 20-method ABC "for mocking".
- Construct clients in `__main__` / the entry and pass them down. No
  module-level `httpx.Client()` / engine.
- Timeouts on I/O. `asyncio.timeout` (3.11+) or `httpx` timeout=. Do
  not invent a Go `context` clone.

## Errors, async, I/O

- Fail at the boundary that knows the context. Messages are lowercase,
  no trailing punctuation (`open config: …`).
- Catch `Exception` only at the process edge. Bare `except:` is a bug.
  `except*` for `ExceptionGroup` (3.11+).
- Do not swallow. Do not `return None` for "not found" when the caller
  must distinguish missing from error — raise a typed error or return
  a union. Match the repo.
- `async with asyncio.TaskGroup()` instead of fire-and-forget
  `create_task` in libraries.
- Parse at HTTP, env, and file boundaries. Never `cast(User, data)`.

## Tests

How to run them: `git-repo-setup-python` (`uv run pytest`). Honor
`unittest` if that is already the suite. Tables with
`pytest.mark.parametrize`. `tmp_path` / `monkeypatch`, not home-rolled
temp dirs. Journeys: `e2e-tests` when the UI is a browser.

## LLM traps — never generate these

- `Optional[List[str]]`, `Dict[str, Any]`, `Union[A, B]` for 3.10+ pins
- `os.path.join`, `os.path.exists` in new code
- `print` / `logging.info` with `t""` as a format string
- `def f(xs=[])` / `def f(n={})`
- `from module import *`; bare `except:`
- `requests` added next to `httpx`; `pytz` next to `zoneinfo`
- `setup.py` / `requirements.txt` unpinned next to a working
  `pyproject.toml` + lock
- `asyncio.gather` without return_exceptions when one failure must cancel
- `cgi`, `asyncore`, `telnetlib` (removed 3.13)
- A new `utils.py` / `helpers.py` grab-bag
- Free-threaded / `PYTHON_GIL=0` as a drive-by

## Do not

- Restyle unrelated files, or rewrite comments that already tell the truth.
- Extract a helper until the third copy.
- Add Pydantic, FastAPI, or Typer only to look modern.
- Bump `requires-python` to unlock `uuid.uuid7` or `t""`.
- Replace Django / Flask / FastAPI / Poetry as a drive-by restyle.
- Recopy `git-repo-setup-python` recipes here.
