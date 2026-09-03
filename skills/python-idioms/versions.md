# Python 3.10 → now — what to write

Gate every row on `requires-python` / `.python-version`. Do not use a
symbol newer than that pin. Write the **After** form. Ruff UP is the
backstop ([modernizers.md](modernizers.md)).

## 3.10 — match, `X | Y`, builtin generics, strict zip

| Before | After |
| --- | --- |
| `Optional[int]`, `Union[A, B]` | `int \| None`, `A \| B` |
| `List[str]`, `Dict[str, int]`, `Tuple[int, ...]` | `list[str]`, `dict[str, int]`, `tuple[int, ...]` |
| `if kind == "a": … elif kind == "b":` on a closed set | `match kind:` with `case` |
| `zip(a, b)` that must be equal length | `zip(a, b, strict=True)` |
| `from __future__ import annotations` only for `list[str]` | builtin generics work at runtime on 3.9+; keep the future import for forward refs until 3.14 |

`match` is structural. Keep `if` for boolean predicates.

## 3.11 — TaskGroup, ExceptionGroup, tomllib, Self

| Before | After |
| --- | --- |
| `asyncio.gather` of work that must all finish or cancel | `async with asyncio.TaskGroup() as tg: tg.create_task(…)` |
| `except Exception` around several concurrent failures | `except*` / `ExceptionGroup` |
| `import tomli as tomllib` on 3.11+ | `import tomllib` |
| `TypeVar("T", bound="C")` for a method returning the class | `Self` |
| `asyncio.wait_for(coro, t)` | `async with asyncio.timeout(t):` |

`tomllib` is **read**. Writing TOML still needs a writer (`tomli-w`) if
you must emit it. Do not add `toml`.

## 3.12 — type params, `type` statement, override

| Before | After |
| --- | --- |
| `T = TypeVar("T")` / `class C(Generic[T])` | `class C[T]:` / `def f[T](x: T) -> T:` |
| `Point: TypeAlias = tuple[int, int]` | `type Point = tuple[int, int]` |
| override with no marker | `@override` (`typing.override`) |
| `**kwargs: Any` | `TypedDict` for `**kwargs` (PEP 692) when the keys are known |

F-string quoting rules are relaxed. Nested quotes in an f-string are
fine. Do not go back to `'%s' % x`.

## 3.13 — TypeIs, TypeVar defaults, ReadOnly, dead batteries gone

| Before | After |
| --- | --- |
| `TypeGuard[T]` when a true result *is* `T` | `TypeIs[T]` |
| `TypeVar("T")` with a repeated default | `class C[T = int]:` |
| `TypedDict` field that must not be written | `ReadOnly[int]` |
| `import cgi` / `asyncore` / `telnetlib` | those modules are removed. Do not restore them |

Free-threaded 3.13 is experimental. Do not enable it as a drive-by.

## 3.14 — deferred annotations, t-strings, uuid7

| Before | After |
| --- | --- |
| `from __future__ import annotations` as cargo cult | omit it — deferred is the default |
| quoting forward refs `'User'` | `user: User` |
| reading `obj.__annotations__` | `annotationlib.get_annotations` |
| `uuid.uuid4()` when the key should sort by time | `uuid.uuid7()` (`identity` owns v7 vs v4) |
| `f"SELECT {id}"` passed to a sanitizer you own | `t"SELECT {id}"` → `Template`, then process. `f""` still formats |
| `heapq._heapify_max` / a negation wrapper | `heapq.heapify_max` |

Do not bump to 3.14 to unlock `uuid.uuid7`. Do not default the process
to free-threaded (supported, still optional).

## 3.15 — not yet

Lazy imports (PEP 810), `frozendict`, `sentinel`, UTF-8 as `open`
default, unpacking in comprehensions. Final is after this pin. Write
them only when `requires-python` already includes 3.15.
