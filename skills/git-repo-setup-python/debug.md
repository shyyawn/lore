# Debug — Python

Hub: `git-repo-setup` [debug.md](../git-repo-setup/debug.md). Cursor / VS
Code / Zed consume it. Recommend `ms-python.python`. Do not pin debugpy in
mise unless the project already depends on it. Add pytest (or unittest)
next to Current File. Merge names.

## Tests

| Suite | Config |
| --- | --- |
| pytest | `Python: pytest` |
| unittest | `module: unittest` (do not ship both) |

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

Nested: `cwd` = the `pyproject.toml` directory. Honor `uv` or
`"python": "${workspaceFolder}/.venv/bin/python"`. No conda.

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

Plus the [Tests](#tests) config.

## `extensions.json`

Hub [scan](../git-repo-setup/debug.md#scan-extensions). Default
`ms-python.python` + `charliermarsh.ruff` when Ruff is the formatter.

```json
{
  "recommendations": ["ms-python.python", "charliermarsh.ruff"]
}
```
