#!/usr/bin/env bash
# Reminder: Cursor marketplace plugins have no non-interactive CLI install yet.

cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Cursor plugins (manual — not scriptable yet)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  User-scope plugins may sync when you sign into Cursor on a new machine.
  If encore / temporal / svelte are missing, install them once:

  In Cursor agent chat:

    /add-plugin encore
    /add-plugin temporal
    /add-plugin svelte

  Or: Customize sidebar → search each plugin → Install (user scope).

  Restart agent chat if MCP tools do not appear.

  Optional: /add-plugin react-doctor

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
