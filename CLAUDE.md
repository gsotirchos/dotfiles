# Agent Instructions

## Core Rules & File Ownership

* **Do NOT Edit Home Directory Files:** This repository is a dotfiles manager. The files in `~/.bashrc`, `~/.vim/`, etc., are symlinked from here (via `etc/setup_dotfiles.sh`, which runs GNU Stow over `packages/`). **Always make edits to the files inside this repository** (e.g., `~/.dotfiles/packages/bash/.bashrc`), never directly in `$HOME`.

## Linting and Verification

Always run the appropriate linters after making changes.

### Bash / Shell Scripts

Use the custom `./bin/lint-bash` utility to run both `shellcheck` (using `shellcheckrc`) and `bashate` on your changes:

```bash
# Lint a single file
./bin/lint-bash <path-to-file>

# Lint an entire directory (defaults to current directory)
./bin/lint-bash [path-to-directory]
```

### Vim Configuration and Scripts

Run `vint` to check for syntax and style issues on `.vimrc` or `.vim` files. If the shell environment has loaded the custom aliases, you can use `lint-vim`:

```bash
# Lint a single file
vint <path-to-file>  # OR: lint-vim <path-to-file>
```

### Emacs Lisp

Use `lint-elisp`; see `packages/claude/.claude/rules/elisp.md` (loaded when working on `.el` files).
