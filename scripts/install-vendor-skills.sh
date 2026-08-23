#!/usr/bin/env bash
# Install vendor skills from README "Start here (Cursor)" into ~/.cursor/skills.
# User-scope (-g): every Cursor project on this machine. Requires Node/npx.

set -euo pipefail

run() {
  printf '\n→ %s\n' "$*"
  "$@"
}

run npx --yes skills add conventional-changelog/conventional-changelog \
  --skill conventional-commit-message -g --agent cursor

run npx --yes skills add expo/skills -g --agent cursor

run npx --yes skills add vercel-labs/agent-skills \
  --skill vercel-react-best-practices -g --agent cursor

run npx --yes skills add vercel/next.js -g --agent cursor

run npx --yes @playwright/cli install --skills -g

printf '\nDone. Vendor skills are in ~/.cursor/skills (user-scope).\n'
printf 'Cursor plugins (encore, temporal, svelte) still use /add-plugin in agent chat.\n'
