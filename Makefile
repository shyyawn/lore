# lore — agent knowledge as files.
#
# `make install` copies skills into the directories agents actually read.
# Copies, not symlinks: a running agent keeps a stable snapshot while you edit
# the repo. The trade-off is drift — re-run `make install` after a change, and
# `make status` will tell you what is stale.

SHELL := /bin/bash

SKILLS        := $(notdir $(wildcard skills/*))
RULES         := $(wildcard rules/*.mdc)

# ~/.cursor/skills — Cursor.
# ~/.agents/skills — Codex (Cursor also reads it).
# ~/.claude/skills — Claude Code. It does not read ~/.agents/skills.
CURSOR_SKILLS := $(HOME)/.cursor/skills
AGENTS_SKILLS := $(HOME)/.agents/skills
CLAUDE_SKILLS := $(HOME)/.claude/skills
CURSOR_RULES  := $(HOME)/.cursor/rules

SKILL_DESTS   := $(CURSOR_SKILLS) $(AGENTS_SKILLS) $(CLAUDE_SKILLS)

.DEFAULT_GOAL := help
.PHONY: help setup clean install install-vendor-skills uninstall-vendor-skills \
	print-cursor-plugins status uninstall list

## help: list targets
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/^## /  /'

## setup: lore skills + vendor skills; print Cursor plugin steps (plugins still manual)
setup:
	@bash scripts/setup.sh

## clean: undo setup (lore copies + vendor packs; print how to remove Cursor plugins)
clean:
	@$(MAKE) uninstall
	@$(MAKE) uninstall-vendor-skills
	@bash scripts/print-cursor-plugins.sh uninstall

## print-cursor-plugins: show /add-plugin steps (no install — CLI cannot install plugins yet)
print-cursor-plugins:
	@bash scripts/print-cursor-plugins.sh

## install-vendor-skills: install official vendor skills (cursor, claude-code, codex)
install-vendor-skills:
	@bash scripts/vendor-skills.sh install

## uninstall-vendor-skills: remove those vendor packs from the same agents
uninstall-vendor-skills:
	@bash scripts/vendor-skills.sh uninstall

## install: copy skills (and any Cursor rules) into agent skill dirs
install:
	@for d in $(SKILL_DESTS); do mkdir -p "$$d"; done
	@for s in $(SKILLS); do \
	  for d in $(SKILL_DESTS); do \
	    rm -rf "$$d/$$s"; \
	    cp -R "skills/$$s" "$$d/$$s"; \
	  done; \
	  printf '  %-12s %s\n' "installed" "$$s"; \
	done
ifneq ($(RULES),)
	@mkdir -p "$(CURSOR_RULES)"
	@cp $(RULES) "$(CURSOR_RULES)/"
	@printf '  %-12s %s rule(s) -> %s\n' "installed" "$(words $(RULES))" "$(CURSOR_RULES)"
endif
	@echo
	@echo "  Copies, not symlinks. Re-run after editing; 'make status' shows drift."

## status: show which installed copies differ from this repo
status:
	@for s in $(SKILLS); do \
	  for d in $(SKILL_DESTS); do \
	    if [ ! -e "$$d/$$s" ]; then printf '  %-10s %s\n' "MISSING" "$$d/$$s"; \
	    elif diff -rq "skills/$$s" "$$d/$$s" >/dev/null 2>&1; then printf '  %-10s %s\n' "ok" "$$d/$$s"; \
	    else printf '  %-10s %s\n' "DRIFTED" "$$d/$$s"; fi; \
	  done; \
	done

## uninstall: remove this repo's skills from the install locations
uninstall:
	@for s in $(SKILLS); do \
	  for d in $(SKILL_DESTS); do rm -rf "$$d/$$s"; done; \
	  printf '  %-12s %s\n' "removed" "$$s"; \
	done

## list: show the skills in this repo
list:
	@for s in $(SKILLS); do echo "  $$s"; done
