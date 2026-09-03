# Ruff rewrites (Python 3.10+)

Python has no `go fix`. Write these forms directly. `ruff check --fix`
is the backstop (UP / PYI / PIE). Version meaning of each rewrite:
[versions.md](versions.md).

```bash
uv run ruff check --fix <files>   # or ruff on PATH
uv run ruff format <files>
```

Do not "modernize" by bumping `requires-python`, adding Black next to
Ruff, or turning UP off.

Gate UP on the pin. A 3.10 CI must not apply 3.12-only syntax.

## Types

| Before | After |
| --- | --- |
| `Optional[T]` | `T \| None` |
| `Union[A, B]` | `A \| B` |
| `List[T]`, `Dict[K, V]`, `Set[T]`, `Tuple[…]` | `list[T]`, `dict[K, V]`, `set[T]`, `tuple[…]` |
| `Type[T]` | `type[T]` |
| `from typing import List, Optional` | drop those; keep `Protocol`, `TypedDict`, `Literal`, `ClassVar`, `Any` only when needed |
| `TypeAlias =` on 3.12+ | `type X = …` |
| `TypeVar("T")` + `Generic[T]` on 3.12+ | `[T]` on the class or def |
| `TypeGuard[T]` when the narrow *is* `T` (3.13+) | `TypeIs[T]` |

`Any` is a last resort at an untyped boundary. Narrow or parse. Do not
comment `# type: ignore` without a one-line reason.

## Syntax and stdlib

| Before | After |
| --- | --- |
| `os.path.join(a, b)` | `Path(a) / b` |
| `os.path.exists(p)` | `Path(p).exists()` |
| `open(p) as f: data = f.read()` for text | `Path(p).read_text()` when the whole file is the unit |
| `%` / `.format` for new interpolations | `f""` |
| `f"…"` built for a template processor on 3.14+ | `t"…"` |
| `asyncio.gather(*tasks)` that must cancel together (3.11+) | `async with asyncio.TaskGroup()` |
| `datetime.utcnow()` | `datetime.now(datetime.UTC)` |
| `pytz.timezone("…")` | `ZoneInfo("…")` |
| `from x import *` | explicit names |

## Packaging

| Before | After |
| --- | --- |
| `setup.py` / unpinned `requirements.txt` as the only metadata | `pyproject.toml` + lock (`uv.lock`). Kit: `git-repo-setup-python` |
| `import pkg_resources` | `importlib.metadata` |
| `python setup.py install` | `uv sync` / the installer already there |

Honor Poetry / PDM / pip-tools if that lock is already the gate. Do not
add uv beside it.
