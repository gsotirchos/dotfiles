---
name: claude-plugin-setup
description: Conventions for creating, naming and registering one of the user's own Claude plugins/skills.
---

- Own public GitHub repo `gsotirchos/<name>`; one name for repo, plugin, skill dir and SKILL.md `name`: lowercase kebab-case, subject first (e.g. `emacs-query`), never `claude-`/`anthropic-` prefixed (reserved by `claude plugin validate`).
- Register: one entry in the `gsotirchos` marketplace `plugins` list in `~/.dotfiles/packages/claude/.claude/settings.json` + `"<name>@gsotirchos": true` under `enabledPlugins`. `etc/setup_claude_plugins.sh` clones it to `~/.local/src/claude-plugins/<name>` for development.
- No `version` in `plugin.json` (updates follow commits).
