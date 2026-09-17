---
name: django
description: >-
  Overlay on python-idioms: pin Django, forms vs model validation,
  save vs QuerySet bulk, signals, transactions. Use when generating,
  editing, or reviewing Django; when the user mentions Django,
  manage.py, INSTALLED_APPS, models.Model, QuerySet, or django.db.
---

# Django 2026

Follow `python-idioms`. This file fills the **Django** pin, public
validation, and ORM lifecycle. Do not flatten Django into
`src/<name>/`. Layout: `django-app-structure`.

Sources: official Django docs for the pin
(`docs.djangoproject.com/<version>/`). Not a DRF dump. Not a
skills.sh Django pack.

Kit: `git-repo-setup-python`. Schema: `data-modeling`. Keys:
`identity`. 4xx: `api-contracts`. Tenant: `authz-boundaries`.
Migrate: `evolve-safely`. Writer: `source-of-truth`.

## First step

1. Read `pyproject.toml` / `requirements` and `manage.py`. Pin is
   `django` (`Django==…` or the lock). Do not bump it.
2. Honor `DJANGO_SETTINGS_MODULE` and the settings module already
   there.
3. Layout: `django-app-structure`. Do not apply `python-idioms`
   `src/<name>/` to a `startproject` tree.

DRF / Django Ninja already in the repo: honor them. This skill still
owns `save` vs bulk and forms vs model. Do not add DRF as fashion.

## Pin

| Pin | Always use | Not yet |
| --- | --- | --- |
| 6.1+ | that series' APIs | 6.2 |
| 6.0 | 6.0 docs | 6.1-only APIs (fetch modes, DB `on_delete`) |
| 5.2 LTS | 5.2 APIs | bumping to 6.1 to unlock a line |

Write the modern form for **that** pin. Do not emit Django 3 and wait.

## After every Django edit

```bash
uv run ruff format <files>
uv run ruff check --fix <files>
uv run python manage.py check
```

Honor `pytest` / `pytest-django` if that is already the suite. Do
not add a second runner. Formatter: Ruff (`git-repo-setup-python`).

## When it breaks

| Symptom | Usually means |
| --- | --- |
| Invalid row in the DB | `save()` without `full_clean` / a form |
| Signal did not fire | `QuerySet.update` / `delete` / `bulk_*` |
| `select_for_update` ProgrammingError | not inside `atomic` |
| Unique error is a 500 | IntegrityError not mapped (`api-contracts`) |
| Another tenant's row | tenant not in the query (`authz-boundaries`) |

## What this skill owns

| Own | Leave |
| --- | --- |
| Pin, forms vs `full_clean`, `save` vs bulk, signals, `atomic` | `python-idioms` spelling |
| | `manage.py` / apps tree (`django-app-structure`) |
| | Schema types (`data-modeling`); migrate (`evolve-safely`) |
| | DRF viewsets encyclopedia if DRF is not already there |

## Hard rules

- Public input is a **form** (or the repo's DRF / Ninja serializer).
  `Model.save` does not call `full_clean`. Call `full_clean` when
  there is no form.
- `QuerySet.update`, `delete`, `bulk_create`, `bulk_update` skip
  `Model.save` and most signals. Treat them as other paths. Keep
  invariants on those paths too, or do not use them for that rule.
- Persist the instance you validated, or `refresh_from_db`. Do not
  patch selected fields from another saved object and assume they
  stuck.
- `transaction.atomic`. Catch `IntegrityError` **outside** the
  failed savepoint. Translate a proven unique conflict. Re-raise
  otherwise.
- `select_for_update` only inside `atomic`. That is a lock. A
  version / `F()` compare is stale-write detection. Name which.
- Tenant stays in the **query** (`authz-boundaries`). `get(pk=)` is
  not enough on a tenant-owned table.
- Migrations are files. Live schema change is `evolve-safely`. Do
  not `migrate --run-syncdb` as the default.

## Default shapes

Form at the boundary, then save:

```python
form = ItemForm(request.POST)
if not form.is_valid():
    return render(request, "item_form.html", {"form": form})
item = form.save()
```

No form (admin, job, shell): `full_clean` then `save`.

Bulk path: `QuerySet.update` only when the rule does not need
`save` / signals. Otherwise iterate the validated instances, or a
named job that uses the same form.

## Do not add

| Need | Use | Do not add |
| --- | --- | --- |
| HTTP | Django views / URLconf | FastAPI beside Django |
| REST | honor DRF / Ninja if present | DRF on a forms app as fashion |
| Queue | honor Celery / Django-Q if present | `transaction.on_commit` as a durable broker (`source-of-truth`) |
| Settings | the settings module already there | a second `django.conf` overlay |
| Admin | `django.contrib.admin` | a parallel CRUD SPA as the default |

## LLM traps — never generate these

- `instance.save()` as proof of validation
- `Model.objects.update(...)` and assuming `pre_save` ran
- `select_for_update()` outside `atomic`
- `get(id=pk)` on a tenant-owned table
- FastAPI / Flask added next to a working Django app
- DRF for a server-rendered form app
- `AutoMigrate`-style `syncdb` on a live database
- Hexagonal `domain/` / `usecase/` inside an app as the default
- Bumping Django to 6.1 to unlock a line

## Do not

- Restyle a working Django 5.2 LTS app onto 6.1 as a drive-by.
- Apply `python-idioms` `src/<name>/` flatten to `startproject`.
- Recopy `django-app-structure` trees here.
- Replace Django with FastAPI because a blog said so.
