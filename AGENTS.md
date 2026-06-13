# Agent Instructions

This document provides compact, high-signal guidance to help AI agents working in this repository ramp up quickly and avoid common mistakes.

## Core Rules & File Ownership

* **Do NOT Edit Home Directory Files:** This repository is a dotfiles manager. The files in `~/.bashrc`, `~/.vim/`, etc., are symlinked from here (via `etc/setup_dotfiles.sh`, which runs GNU Stow over `packages/`). **Always make edits to the files inside this repository** (e.g., `/Users/george/.dotfiles/packages/bash/.bashrc`), never directly in `$HOME`.
* **Git Post-Checkout Hook:** The repository has a git post-checkout hook (`etc/hooks/post-checkout`) that automatically runs `etc/patch_modus.py`. This script reads Ghostty Modus themes from the submodule and outputs patched themes to `packages/ghostty/.config/ghostty/themes/`.
* **Suggest commit messages:** Any time you implement a (meaningful) fix after my request, for an issue we troubleshooted together, at the very end of that answer accompanying your code changes you will provide me with a *concise (max. 65 chars) yet informative commit message* in case I want to commit those changes myself later.

## Linting and Verification

Always run the appropriate linters after making changes. Custom configuration files for these tools are located in the repository root.

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

### Python Files
Ruff and Pyright are configured via `pyproject.toml`. Run `ruff check` on modified Python files:
```bash
ruff check <path-to-file>
```

### Other Configured Linters
* **Markdown:** `markdownlint` (uses `markdownlint.json`).
* **Prose:** `proselint` (uses `proselintrc`).
* **LaTeX:** `chktex` (uses `chktexrc`).
* **C / C++:** `clang-tidy` and `clang-format` (configured via root config files).
* **CMake:** `cmake-format` (uses `cmake-format.yaml`).
