#!/usr/bin/env bash
# Official vendor packs from the README Start here section. User-scope.
# Requires Node/npx. Usage: vendor-skills.sh install|uninstall

set -euo pipefail

AGENTS=(--agent cursor --agent claude-code --agent codex)
# Cursor plugins already bundle these. Do not also install them there.
PLUGIN_AGENTS=(--agent claude-code --agent codex)

# Folder names `npx skills remove` deletes. Must match what `add` writes.
# Expo list: expo/skills skills.sh.json. Next: vercel/next.js skills/.
SKILLS=(
	conventional-commit-message
	frontend-design
	vercel-react-best-practices
	web-design-guidelines
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

# encoredev/skills README. sveltejs/ai-tools plugins/claude/svelte/skills.
PLUGIN_SKILLS=(
	temporal-developer
	svelte-core-bestpractices
	svelte-code-writer
	encore-getting-started
	encore-api
	encore-webhook
	encore-auth
	encore-database
	encore-pubsub
	encore-cron
	encore-bucket
	encore-cache
	encore-secret
	encore-service
	encore-testing
	encore-frontend
	encore-code-review
	encore-migrate
	encore-go-getting-started
	encore-go-api
	encore-go-webhook
	encore-go-auth
	encore-go-database
	encore-go-pubsub
	encore-go-cron
	encore-go-bucket
	encore-go-cache
	encore-go-secret
	encore-go-service
	encore-go-testing
	encore-go-code-review
)

run() {
	printf '\n→ %s\n' "$*"
	"$@"
}

remove_named() {
	local -n _agents=$1
	shift
	for s in "$@"; do
		npx --yes skills remove -g -y "${_agents[@]}" "$s" || true
	done
}

install() {
	run npx --yes skills add conventional-changelog/conventional-changelog \
		--skill conventional-commit-message -g -y "${AGENTS[@]}"

	run npx --yes skills add expo/skills -g -y "${AGENTS[@]}"

	run npx --yes skills add anthropics/skills \
		--skill frontend-design -g -y "${AGENTS[@]}"

	run npx --yes skills add vercel-labs/agent-skills \
		--skill vercel-react-best-practices --skill web-design-guidelines \
		-g -y "${AGENTS[@]}"

	run npx --yes skills add vercel/next.js -g -y "${AGENTS[@]}"

	run npx --yes skills add microsoft/playwright-cli \
		--skill playwright-cli -g -y "${AGENTS[@]}"

	run npx --yes skills add encoredev/skills -g -y "${PLUGIN_AGENTS[@]}"

	run npx --yes skills add temporalio/skill-temporal-developer \
		--skill temporal-developer -g -y "${PLUGIN_AGENTS[@]}"

	run npx --yes skills add sveltejs/ai-tools \
		--skill svelte-core-bestpractices --skill svelte-code-writer \
		-g -y "${PLUGIN_AGENTS[@]}"

	printf '\nDone. Shared vendor packs: cursor, claude-code, and codex.\n'
	printf 'Encore / Temporal / Svelte skills: claude-code and codex only.\n'
	printf 'Cursor still uses /add-plugin encore temporal svelte.\n'
	printf 'MCP is not installed here (Encore needs an app id).\n'
}

uninstall() {
	# Missing names are fine (pack grew, or never installed).
	remove_named AGENTS "${SKILLS[@]}"
	remove_named PLUGIN_AGENTS "${PLUGIN_SKILLS[@]}"
	printf '\nDone. Named vendor packs removed.\n'
	printf 'Lore copies are make uninstall. Cursor plugins are not removed.\n'
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
