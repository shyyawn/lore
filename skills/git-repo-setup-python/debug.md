# Debug — Python

Shared Cursor mechanics: `git-repo-setup` [debug.md](../git-repo-setup/debug.md).
This file is the Python `launch.json` / `extensions.json`.

Recommend `ms-python.python` (ships debugpy). Do not pin debugpy in mise
unless the project already depends on it.

**Python: Current File does not run the test suite.** Add pytest (or
unittest) next to it. Merge names.

## Tests

| Suite | Debug how |
| --- | --- |
| pytest | `Python: pytest` in `launch.json`. Breakpoints in the test and the code under test. |
| unittest | `module: unittest` instead of pytest. Do not ship both. |

```json
{
  "name": "Python: pytest",
  "type": "debugpy",
  "request": "launch",
  "module": "pytest",
  "args": ["${file}"],
  "console": "integratedTerminal"
}
```

`cwd` = the directory that has `pyproject.toml` when nested. Honor `uv`
(PATH after bootstrap) or `"python": "${workspaceFolder}/.venv/bin/python"`.
Do not invent a conda env.

## App / current file

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
    }
  ]
}
```

Plus the [Tests](#tests) pytest (or unittest) config.

## `extensions.json`

Scan: [git-repo-setup debug.md](../git-repo-setup/debug.md#scan-extensions).
Python default `ms-python.python`. Add `charliermarsh.ruff` when Ruff is
the formatter (the overlay default). Add Tombi when `*.toml` / `.mise.toml`
exists.

```json
{
  "recommendations": ["ms-python.python", "charliermarsh.ruff"]
}
```
