# Agent Instructions

This document provides compact, high-signal guidance to help AI agents working in this repository ramp up quickly and avoid common mistakes.

## Core Rules & File Ownership

* **Do NOT Edit Home Directory Files:** This repository is a dotfiles manager. The files in `~/.bashrc`, `~/.vim/`, etc., are symlinked from here (via `etc/setup_dotfiles.sh`, which runs GNU Stow over `packages/`). **Always make edits to the files inside this repository** (e.g., `/Users/george/.dotfiles/packages/bash/.bashrc`), never directly in `$HOME`.

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

### Emacs Lisp

Use the custom `./bin/lint-elisp` utility to run both the byte-compiler and `checkdoc` over `.el` files:

```bash
# Lint a single file
./bin/lint-elisp <path-to-file>

# Lint an entire directory (defaults to the emacs package config)
./bin/lint-elisp [path-to-directory]

# Additionally re-check through Flymake in a daemon running the real config
./bin/lint-elisp --flymake <path>
```

Batch mode resolves package symbols differently from the editor, so `--flymake` is the authoritative check when a warning is in doubt. Also note:

* **Do not remove the warning suppression like** `byte-compile-warnings: (not free-vars unresolved)`; local variables block is deliberate: without it, a config of lazily-loaded packages emits ~90 free-variable and undefined-function warnings. Never "fix" those individually.
* **Inside a `use-package` form, use `:defines` / `:functions`** rather than a hand-written `(defvar foo)` or `declare-function`. Both keywords exist solely to silence the byte-compiler, and cost nothing at startup. Plain libraries (e.g. those in `site-lisp/`) have no `use-package` form; there the bare idiom is correct.

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
