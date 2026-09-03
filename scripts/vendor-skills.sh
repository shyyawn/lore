#!/usr/bin/env bash
# Official vendor packs from the README Start here section. User-scope.
# Requires Node/npx. Usage: vendor-skills.sh install|uninstall

set -euo pipefail

AGENTS=(--agent cursor --agent claude-code --agent codex)

# Folder names `npx skills remove` deletes. Must match what `add` writes.
# Expo list: expo/skills skills.sh.json. Next: vercel/next.js skills/.
SKILLS=(
	conventional-commit-message
	vercel-react-best-practices
	next-dev-loop
	next-cache-components-adoption
	next-cache-components-optimizer
	next-partial-prefetching-adoption
	playwright-cli
	expo-overview
	expo-project-structure
	expo-router
	expo-animation
	expo-native-ui
	expo-design-system
	expo-ui
	expo-data-fetching
	expo-dom
	expo-web-to-native
	expo-module
	expo-brownfield
	expo-dev-client
	expo-examples
	expo-app-clip
	expo-upgrade
	expo-skill-feedback
	eas-app-stores
	eas-hosting
	eas-workflows
	eas-observe
	eas-update
	eas-update-insights
	eas-simulator
	expo-migrate-module
)

run() {
	printf '\n→ %s\n' "$*"
	"$@"
}

install() {
	run npx --yes skills add conventional-changelog/conventional-changelog \
		--skill conventional-commit-message -g -y "${AGENTS[@]}"

	run npx --yes skills add expo/skills -g -y "${AGENTS[@]}"

	run npx --yes skills add vercel-labs/agent-skills \
		--skill vercel-react-best-practices -g -y "${AGENTS[@]}"

	run npx --yes skills add vercel/next.js -g -y "${AGENTS[@]}"

	run npx --yes skills add microsoft/playwright-cli \
		--skill playwright-cli -g -y "${AGENTS[@]}"

	printf '\nDone. Vendor skills are user-scope for cursor, claude-code, and codex.\n'
	printf 'Plugins (encore, temporal, svelte) still use /add-plugin in agent chat.\n'
}

uninstall() {
	# Missing names are fine (pack grew, or never installed).
	for s in "${SKILLS[@]}"; do
		npx --yes skills remove -g -y "${AGENTS[@]}" "$s" || true
	done
	printf '\nDone. Named vendor packs removed from cursor, claude-code, and codex.\n'
	printf 'Lore copies are make uninstall. Plugins are not removed.\n'
}

cmd="${1:-}"
case "$cmd" in
install) install ;;
uninstall) uninstall ;;
*)
	printf 'usage: %s install|uninstall\n' "$(basename "$0")" >&2
	exit 2
	;;
esac
