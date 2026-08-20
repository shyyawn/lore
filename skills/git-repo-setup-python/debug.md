# Debug — Python

Shared Cursor mechanics: `git-repo-setup` [debug.md](../git-repo-setup/debug.md).
This file is the Python `launch.json` / `extensions.json`.

Recommend `ms-python.python` (ships debugpy). Do not pin debugpy in mise
unless the project already depends on it.

## `launch.json`

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Current File",
      "type": "debugpy",
      "request": "launch",
      "program": "${file}",
      "console": "integratedTerminal"
    },
    {
      "name": "Python: pytest",
      "type": "debugpy",
      "request": "launch",
      "module": "pytest",
      "args": ["${file}"],
      "console": "integratedTerminal"
    }
  ]
}
```

Honor the project's runner: `uv run` is PATH via mise/bootstrap; if tests
only work under `uv run pytest`, set `"module": "pytest"` with
`"cwd"` = the directory that has `pyproject.toml` (nested: not the Git
root). Do not invent a conda env.

Drop the pytest config if the suite is `unittest`.

## `extensions.json`

```json
{
  "recommendations": ["ms-python.python"]
}
```
