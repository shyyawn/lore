---
name: django-app-structure
description: >-
  Structures Django projects: official startproject tree, apps,
  INSTALLED_APPS, settings module. Use when scaffolding a Django app,
  adding an app, choosing project vs app layout, or the user mentions
  manage.py, startproject, startapp, or Django app structure. Coding
  stays in django.
---

# Django App Structure

Layout and app boundaries for Django. Coding idioms live in `django`
and `python-idioms`. Do not flatten this tree into `src/<name>/`.

Sources: official `intro/tutorial01` (`django-admin startproject`,
`startapp`), `ref/applications`. Not a DRF starter. New project:
`django-admin startproject`. Honor the tree already there.

## First step

1. Read `manage.py` and the settings module
   (`DJANGO_SETTINGS_MODULE`).
2. Find `INSTALLED_APPS`. Match that shape (flat apps vs project
   package).
3. Never invent a second `manage.py`.

No `manage.py`: this is not a Django project. Honor it. Do not add
Django as a drive-by (`python-idioms`).

Several `pyproject.toml`: `python-idioms` + the kit. This file stays
the Django project that has `manage.py`.

## Hard rules

- **One `manage.py` for the project.** A second one is a second
  project.
- **Project package holds settings / URLconf / ASGI / WSGI.** Apps
  hold models, views, migrations.
- **An app is listed in `INSTALLED_APPS`.** `startapp` then register
  it. Do not leave a new app off the list.
- **Migrations live in the owning app** (`app/migrations/`).
- **Settings is a module**, not a grab-bag `config/` of unrelated
  keys. Split settings only if the repo already does (`settings/base.py`).
- **Do not apply `python-idioms` `src/<name>/` to this tree.**

## Choose a layout

| Situation | Layout |
| --- | --- |
| New project | Official `startproject` tree |
| One domain | Project package + one app |
| Several domains | One app per domain at the project root |
| Shared helpers | a package without models, or `common` only if already there |
| Templates / static for one app | inside that app |
| Site-wide templates | project `templates/` if already that shape |

Start as the official tree. Do not invent `domain/` / `usecase/` /
`adapter/` on a greenfield Django project.

## Small app (official)

```
mysite/
  manage.py
  mysite/
    __init__.py
    settings.py
    urls.py
    asgi.py
    wsgi.py
  polls/
    __init__.py
    admin.py
    apps.py
    models.py
    views.py
    urls.py
    migrations/
      __init__.py
  pyproject.toml
```

`startproject` + `startapp polls`. URL include from the project
`urls.py`.

## Growth

1. One app next to the project package.
2. Split an app when models / URLs for a second domain appear.
3. Do not split so two apps share a table. Shared table → one app.

## After layout changes

```bash
uv run python manage.py check
uv run python manage.py makemigrations --check --dry-run
```

Honor the test runner already there. Do not commit `__pycache__/` or
`*.pyc`.

## LLM traps — never generate these

- `src/<name>/` flatten of `startproject`
- A second `manage.py` / settings module as fashion
- App not in `INSTALLED_APPS`
- Models in the project package as the default
- Hexagonal folders inside an app
- FastAPI `app/` next to `manage.py` as the Django replacement
- `python-idioms` `__main__.py` as the Django entry

## Do not

- Restyle a working `startproject` tree as a drive-by.
- Add Django to a FastAPI / Flask repo unless asked.
- Recite forms / `save` rules (those stay in `django`).
- Bump Django to unlock a layout.
