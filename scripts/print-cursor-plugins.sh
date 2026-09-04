#!/usr/bin/env bash
# Reminder: Cursor marketplace plugins have no non-interactive CLI install yet.
# Usage: print-cursor-plugins.sh [install|uninstall]

set -euo pipefail

install_msg() {
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
}

uninstall_msg() {
	cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Cursor plugins (manual — make clean does not remove them)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  make clean already dropped lore copies and vendor packs.
  Plugins stay until you uninstall them in Cursor:

    Customize sidebar → the plugin (encore, temporal, svelte) → Uninstall.

  Optional: same for react-doctor if you added it.

  Restart agent chat after uninstall if MCP tools still appear.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
}

cmd="${1:-install}"
case "$cmd" in
install) install_msg ;;
uninstall) uninstall_msg ;;
*)
	printf 'usage: %s install|uninstall\n' "$(basename "$0")" >&2
	exit 2
	;;
esac
