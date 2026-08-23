#!/usr/bin/env bash
# New-machine setup: lore skills + vendor skills, then plugin reminder.
# Requires: make, Node/npx (for vendor skills). Cursor plugins are manual.

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"

printf '\n==> Lore skills (make install)\n'
make -C "$root" install

printf '\n==> Vendor skills (make install-vendor-skills)\n'
make -C "$root" install-vendor-skills

bash "$root/scripts/print-cursor-plugins.sh"
