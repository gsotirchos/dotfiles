---
paths:
  - "**/*.el"
---

# Emacs Lisp

Use the custom `lint-elisp` utility to run both the byte-compiler and `checkdoc` over `.el` files:

```bash
# Lint a single file
lint-elisp <path-to-file>

# Lint an entire directory (defaults to the emacs package config)
lint-elisp [path-to-directory]

# Additionally re-check through Flymake in a daemon running the real config
lint-elisp --flymake <path>
```

Batch mode resolves package symbols differently from the editor, so `--flymake` is the authoritative check when a warning is in doubt. Also note:

* **Keep `byte-compile-warnings: (not unresolved)` in init.el**: undefined-function warnings from lazily loaded packages are noise, but free-variable warnings catch stray symbols left by typos, so silence each one with `:defines`.
* **Inside a `use-package` form, use `:defines` / `:functions`** rather than a hand-written `(defvar foo)` or `declare-function`. Both keywords exist solely to silence the byte-compiler, and cost nothing at startup. Plain libraries (e.g. those in `site-lisp/`) have no `use-package` form; there the bare idiom is correct.
