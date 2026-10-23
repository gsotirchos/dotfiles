# Org LaTeX preview overhaul — cleanup once it merges

> **TODO:** Act on this file when the `Org: GNU ELPA releases` Newsticker
> feed (`M-x newsticker-treeview`) shows an entry for Version 10.0.

Org is currently installed from upstream Org's `main` branch, which carries the
asynchronous LaTeX preview system that is slated for Org 10.0. The `org` block
in `packages/emacs/.emacs.d/init.el` installs it, and
`site-lisp/my-org-latex-preview.el` works around a bug in it. This file lists
what to undo once the overhaul is part of a released Org.

## Tracking

Newsticker (`newsticker` block in `init.el`) follows Org's releases on GNU ELPA
(<https://elpa.gnu.org/packages/org.xml>). The 9.8.x point releases show up
there too.

## Milestones

1. **Merged into `main`** (done, 2026-09-20, merge commit `7f913dfae`):
   `package-vc` now tracks upstream `main` instead of karthink's `olp` branch.
2. **Released as Org 10.0**: first on GNU ELPA
   (`M-x package-install-upgrade-built-in RET org`), later bundled with Emacs.
   Most of the cleanup below applies from here.

## Prepared branch

The `org-latex-preview-merged` branch already removes everything listed under
[What goes](#what-goes), this file included. Once Org 10.0 is released:

1. `git rebase main org-latex-preview-merged`. Its first commit only brings
   this file up to date, so the rebase drops it if `main` already has that
   change. If `main` changed this file since, resolve the conflict by deleting
   the file. `init.el` conflicts in the `org` and `newsticker` blocks, which
   `main` reworked when it switched to upstream `main`; resolve them by keeping
   the branch's deletions.
2. Restore any workaround whose bug is still present, using the checks under
   [What goes](#what-goes).
3. Do the steps [outside the repository](#outside-the-repository), restart
   Emacs, and merge the branch into `main`.

## What goes

In `packages/emacs/.emacs.d/init.el`, all in the `org` block unless noted:

- `package-vc-selected-packages`, `package-vc-allow-build-commands` and
  `(package-vc-install-selected-packages)`: once switching to released Org.
- `my/org-latex-preview-color-every-fragment-advice` and its `advice-add`:
  once the `:continue-color` bug is fixed. To check, delete them, run
  `M-x org-latex-preview-clear-cache` in `~/Desktop/math.org`, and make sure no
  fragment turns black in a dark theme.
- The related `TODO` comments, and the `newsticker` block after `org-appear`:
  along with the code above.

### Outside the repository

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
