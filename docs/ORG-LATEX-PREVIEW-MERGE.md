# Org LaTeX preview overhaul — cleanup once it merges

> **TODO:** Act on this file when the `Org: org-latex-preview.el on main`
> Newsticker feed (`M-x newsticker-treeview`) shows its first entry.

Org is currently installed from karthink's fork (branch `olp`), which carries
the asynchronous LaTeX preview system that is slated for Org 10.0. The `org`
block in `packages/emacs/.emacs.d/init.el` installs it and works around bugs in
it. This file lists what to undo once the overhaul is part of upstream Org.

## Tracking

Newsticker (`newsticker` block in `init.el`) follows:

- the mailing-list thread
  (<https://list.orgmode.org/orgmode/87lek2up0w.fsf@tec.tecosaur.net/>),
- the `olp` branch commits
  (<https://github.com/karthink/org-mode/commits/olp>),
- `lisp/org-latex-preview.el` on Org's `main`, which is empty until the merge.

Issue [karthink/org-mode#1](https://github.com/karthink/org-mode/issues/1) has
no feed; subscribe to it on GitHub instead.

## Milestones

1. **Merged into `main`**: the `main` feed shows a commit. Pointing `package-vc`
   at upstream Org is possible, but waiting for the release is simpler.
2. **Released as Org 10.0**: first on GNU ELPA
   (`M-x package-install-upgrade-built-in RET org`), later bundled with Emacs.
   Most of the cleanup below applies from here.

## What goes

All in the `org` block of `packages/emacs/.emacs.d/init.el`:

| Code | Remove when |
| --- | --- |
| `package-vc-selected-packages`, `package-vc-allow-build-commands`, `(package-vc-install-selected-packages)` | Switching to released Org |
| `(package-activate-1 …)` | Same time: Org 10.0 outranks the built-in 9.8.7, so normal activation picks it |
| Copied `org-latex-preview--dvisvgm3-minor-version` `defvar` | [karthink/org-mode#1](https://github.com/karthink/org-mode/issues/1) is fixed. Delete it and check `*Messages*` for "No org-loaddefs.el" |
| `my/org-latex-preview-color-every-fragment-advice` and its `advice-add` | The `:continue-color` bug is fixed. Delete them, run `M-x org-latex-preview-clear-cache` in `~/Desktop/math.org`, and check that no fragment turns black in a dark theme |
| The related `TODO` comments, and the Newsticker feeds | Along with the code above |

Outside the repository:

- `M-x package-delete RET org` removes the VC copy in `~/.emacs.d/elpa/org`
  (unnecessary if the ELPA upgrade already replaced it).
- Delete the old preview cache `~/.emacs.d/var/ltximg/`, if still there.

## What stays

- `:hook (org-mode . org-latex-preview-mode)` in the `org` block.
- The removal of the obsolete `org-preview-latex-*` options, the
  `org-format-latex-options` background tweak, and `org-fragtog`.
- The reduced `site-lisp/my-org.el` and the AUCTeX-only
  `site-lisp/my-latex-preview.el`.
- `preview` and `mylatexformat` in `etc/setup_texlive.sh`.
- The `\gt` and `\lt` definitions in `etc/math_commands.tex`.
