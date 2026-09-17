---
name: fastapi
description: >-
  Overlay on python-idioms: pin FastAPI / Starlette, dependencies vs
  transactions, lifespan, Pydantic at the edge. Use when generating,
  editing, or reviewing FastAPI or Starlette; when the user mentions
  FastAPI, APIRouter, Depends, lifespan, or BackgroundTasks.
---

# FastAPI 2026

Follow `python-idioms`. This file fills the **FastAPI** pin,
dependencies, and lifespan. Do not add FastAPI to a 40-line script.

Sources: official FastAPI docs (`fastapi.tiangolo.com`). Not their
full tutorial. Not a skills.sh pack. Do not pin `starlette` yourself
— FastAPI selects it.

Kit: `git-repo-setup-python`. 4xx: `api-contracts`. Schema:
`data-modeling`. Writer: `source-of-truth`. Django already in the
tree: **stop** — `django`. Do not stack FastAPI beside it.

## First step

1. Read `pyproject.toml` / the lock. Pin is `fastapi`. Do not bump
   it. Do not pin `starlette` next to it.
2. Honor the app object already there (`FastAPI()` or Starlette).
3. SQLAlchemy / SQLModel / an ORM already there: honor it. Do not
   add a second one. Persistence types: `data-modeling`.

Starlette without FastAPI: still this file for lifespan /
`BackgroundTasks`. Pydantic stays `python-idioms`.

## Pin

| Pin | Always use | Not yet |
| --- | --- | --- |
| FastAPI 0.100+ (Pydantic v2) | `lifespan=`, Pydantic v2 models | `@app.on_event` |
| Older FastAPI still on Pydantic v1 | honor that pin | bumping FastAPI to unlock v2 |

Write the modern form for **that** pin. Do not emit `@app.on_event`
on a lifespan pin.

## After every FastAPI edit

```bash
uv run ruff format <files>
uv run ruff check --fix <files>
```

Honor `pytest` + `TestClient` (as a context manager so lifespan
runs). Do not add a second test client. Formatter: Ruff.

## When it breaks

| Symptom | Usually means |
| --- | --- |
| DB work in a dependency with no commit | Depends is not a transaction |
| Task vanished after 200 | `BackgroundTasks` is not a durable queue |
| Lifespan skipped in tests | `TestClient` not used as a context manager |
| `starlette` version fight | pinned Starlette beside FastAPI |
| Django + FastAPI in one process | did not stop; `django` owns that app |

## What this skill owns

| Own | Leave |
| --- | --- |
| Pin, `Depends` vs transaction, lifespan, `BackgroundTasks` limit | `python-idioms` spelling; Pydantic parse-at-boundary |
| Starlette-only ASGI when it is the API | Django (`django`); Flask (honor, no Flask skill) |
| | Durable jobs / outbox (`source-of-truth`) |
| | Status codes (`api-contracts`) |

## Hard rules

- `Depends` lifetime is **not** a transaction. Open a session /
  `atomic` block where the write happens. Commit there.
- `BackgroundTasks` runs after the response, in-process. It is **not**
  a durable queue. Crash loses the task. Earn a worker
  (`source-of-truth`).
- App lifecycle is `lifespan=`. Do not add `@app.on_event` on a
  pin that has lifespan.
- Parse at the edge: Pydantic request models. Never `cast` on
  `request.json()`.
- Construct engines / clients in **lifespan** (or the entry) and
  yield them. No module-level `create_engine()` you connect at
  import.
- Request `ctx` / cancellation: honor disconnect. Durable work must
  not rely on the request remaining open.

## Default shapes

```python
from contextlib import asynccontextmanager

from fastapi import FastAPI


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield


app = FastAPI(lifespan=lifespan)


@app.get("/items/{item_id}")
def read_item(item_id: int) -> dict[str, int]:
    return {"item_id": item_id}
```

Routers: `APIRouter`, `include_router`. Keep path operations thin.
DB session from a dependency that **yields**, caller commits or the
context manager does. Do not hide a commit inside a generic
`get_db` that always commits.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP | FastAPI / Starlette already there | Django / Flask beside it |
| Schema | Pydantic v2 (pin) | a second schema lib |
| ORM | honor SQLAlchemy 2 / SQLModel | a second ORM; Django ORM in FastAPI |
| Queue | worker + outbox (`source-of-truth`) | `BackgroundTasks` as Celery |
| Starlette pin | let FastAPI pick it | `starlette==` next to `fastapi` |

## LLM traps — never generate these

- `@app.on_event("startup")` on a lifespan pin
- `BackgroundTasks` for mail / billing / anything that must survive
  a crash
- `Depends` as `atomic`
- Module-level `engine = create_engine(...)` used at import
- Pinning `starlette` beside `fastapi`
- FastAPI added to a 40-line script or a working Django app
- `TestClient(app)` without `with` so lifespan never runs
- Bumping FastAPI to unlock Pydantic v2 on a v1 pin

## Do not

- Restyle a working Flask / Django app into FastAPI as a drive-by.
- Recopy `python-idioms` Ruff / pathlib catalogs here.
- Teach a Celery encyclopedia.
- Invent a `fastapi-app-structure` tree. Honor the package already
  there (`python-idioms`).
