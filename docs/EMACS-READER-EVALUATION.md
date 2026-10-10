# emacs-reader — replacement candidate for pdf-tools

> **TODO:** Re-evaluate once emacs-reader supports text (search/selection) and
> SyncTeX; until then pdf-tools stays.

[emacs-reader](https://codeberg.org/MonadicSheep/emacs-reader) renders
documents through a MuPDF dynamic module. It was evaluated on 2026-10-04 at
commit `650e294` (v0.4.x) as a replacement for the `pdf-tools` and
`saveplace-pdf-view` blocks in `packages/emacs/.emacs.d/init.el`, which the
`consult` and `auctex` blocks also use.

## Tracking

- Commits: <https://codeberg.org/MonadicSheep/emacs-reader.rss>
- `NEWS` in the repository lists user-facing changes per release.
- The blocking issues below; MELPA/ELPA availability is
  [#164](https://codeberg.org/MonadicSheep/emacs-reader/issues/164).

## Blockers

| Issue | Missing feature | Used today by |
| --- | --- | --- |
| [#62](https://codeberg.org/MonadicSheep/emacs-reader/issues/62) | AUCTeX + SyncTeX | `TeX-view-program-list` → `TeX-pdf-tools-sync-view` |
| [#29](https://codeberg.org/MonadicSheep/emacs-reader/issues/29) | Text layer: search, selection, copy | pdf-tools isearch/occur |
| [#28](https://codeberg.org/MonadicSheep/emacs-reader/issues/28) | Following links | pdf-tools links |
| [#37](https://codeberg.org/MonadicSheep/emacs-reader/issues/37) | Annotations | pdf-tools annotations |

Also worth checking before switching:

- [#34](https://codeberg.org/MonadicSheep/emacs-reader/issues/34): dark mode is
  plain inversion, so the theme's foreground and background can't be used as
  `pdf-view-midnight-colors` is now.
- [#193](https://codeberg.org/MonadicSheep/emacs-reader/issues/193): toggling
  `reader-dark-mode` crashes Emacs for some users.
- [#123](https://codeberg.org/MonadicSheep/emacs-reader/issues/123) and
  [#104](https://codeberg.org/MonadicSheep/emacs-reader/issues/104): stutter
  and high memory use, or low-quality pages, on scaled (HiDPI) displays.

## Coverage of the current config

| Current setup | emacs-reader equivalent |
| --- | --- |
| `:mode "\\.pdf\\'"` | autoloaded `auto-mode-alist` entries, which also cover epub/mobi/fb2/xps/cbz/office |
| `pdf-view-fit-width-to-window` | `reader-default-fit` set to `reader-fit-to-width` |
| `pdf-view-use-scaling` | reads `frame-scale-factor` itself |
| `pdf-view-use-imagemagick` | not needed |
| `my/maybe-toggle-pdf-midnight-view` | `reader-dark-mode`; the theme-darkness check carries over, the colors don't |
| `mode-line-invisible-mode`, `tooltip-mode -1` | unchanged; the `pdf-util-tooltip-arrow` advice goes away |
| `revert-without-query` | built in (`auto-revert-mode` plus its own `revert-buffer-function`) |
| `saveplace-pdf-view` | `reader-saveplace.el`, autoloaded into `save-place-mode` |
| bookmarks, outline | built in (`reader-bookmark.el`, `reader-outline-show`, imenu) |
| `consult-preview-allowed-hooks` entry | same, with the renamed hook |

## Migration sketch

Prerequisites (present on 2026-10-04): Homebrew `mupdf` ≥ 1.26, `gcc`,
`make`; the Makefile finds Homebrew's MuPDF on macOS by itself.

1. Replace the `pdf-tools` and `saveplace-pdf-view` blocks:

   ```elisp
   (use-package reader
     :vc (:url "https://codeberg.org/MonadicSheep/emacs-reader"
          :make "all"
          :rev :newest)
     :custom (reader-default-fit 'reader-fit-to-width)
     :preface
     (defun my/maybe-toggle-reader-dark-mode ()
       (reader-dark-mode
        (if (< (string-to-number (substring (face-background 'default) 1) 16) #x333333)
            1 -1)))
     (defun my/reader-mode-hook ()
       (mode-line-invisible-mode 1)
       (tooltip-mode -1)
       (my/maybe-toggle-reader-dark-mode)
       (add-hook 'after-load-theme-hook #'my/maybe-toggle-reader-dark-mode nil t))
     (add-hook 'reader-mode-hook #'my/reader-mode-hook))
   ```

   If it reaches MELPA/ELPA, drop `:vc` and follow the README instead.
2. Set `package-vc-allow-build-commands` to `'(reader)` in the `emacs` block.
   Otherwise package-vc skips `:make "all"` and the module is never built.
3. Replace `my/pdf-view-mode-hook` with `my/reader-mode-hook` in
   `consult-preview-allowed-hooks`.
4. Point `TeX-view-program-selection` at an emacs-reader SyncTeX viewer once
   [#62](https://codeberg.org/MonadicSheep/emacs-reader/issues/62) lands.
5. Check whether the `special-mode-map` `quit-window` unbinding is still
   needed, since `reader-mode` derives from `special-mode`.
