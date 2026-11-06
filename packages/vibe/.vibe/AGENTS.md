# Global Vibe Instructions

Always read CLAUDE.md files in addition to AGENTS.md files. Apply the same discovery logic: all CLAUDE.md files on the path from the task files up to the repo root are active, with closer files taking precedence on conflict.

Also read all markdown files under `~/.dotfiles/packages/claude/.claude/` and apply them as active instructions:
- `CLAUDE.md`
- `context/*.md`
- `rules/*.md`
- `skills/*/SKILL.md`
