;;; my-fold-ellipsis.el --- Boxed badge in place of folded text -*- lexical-binding: t; -*-

;;; Commentary:
;; Emacs stands a bare "..." in for folded text.  This module dresses it as a
;; dimmed, bordered badge, so a fold reads as a control rather than as prose that
;; happens to end in a full stop.
;;
;; Two render paths lead there, and the ellipsis has to be spelled differently
;; for each:
;;
;; - The display table's `selective-display' slot, which is what Org folds draw
;;   from -- they carry an overlay, but redisplay ignores its `display' property
;;   and paints the invisibility ellipsis instead.  Redisplay boxes every glyph
;;   of that slot as a run of its own, so a three-dot ellipsis comes out with an
;;   extra border after its first dot and with slack before its last.  A
;;   one-glyph "…" has neither, and is what proportional buffers get; Org is the
;;   one folding through this path, and `org-mode' is proportional here.
;;
;; - An overlay `display' property, handed to the fold overlays of
;;   `outline-minor-mode' and of hideshow.  One propertized string is one run,
;;   hence one box with even padding, so three dots are fine on this path.
;;
;; Neither backend offers a hook that hands over the overlay it has just made,
;; so `outline-flag-region' is advised; hideshow has `hs-set-up-overlay' for it.

;;; Code:

(declare-function my/theme-color "init" (name))
(declare-function my/variable-pitch-p "init" ())

(defvar hs-set-up-overlay)

(defvar my/fold-ellipsis-fixed-pitch "..."
  "Ellipsis standing in for folded text in fixed-pitch buffers.")

(defvar my/fold-ellipsis-proportional "…"
  "One-glyph counterpart of `my/fold-ellipsis-fixed-pitch'.
Spelled with a single character because proportional buffers are the ones
folding through the display table, which boxes each glyph separately.")

(defface my/fold-ellipsis-face '((t :inherit default))
  "Face for the ellipsis standing in for folded text."
  :group 'faces)

(defvar my/fold-ellipsis-saved-hs-set-up-overlay nil
  "Value `hs-set-up-overlay' held before `my-fold-ellipsis-mode' took it over.")

(defun my/fold-ellipsis ()
  "Return the ellipsis standing in for folded text in the current buffer."
  (if (my/variable-pitch-p)
      my/fold-ellipsis-proportional
    my/fold-ellipsis-fixed-pitch))

(defun my/fold-ellipsis-glyphs (ellipsis)
  "Return ELLIPSIS as display-table glyphs in `my/fold-ellipsis-face'."
  (vconcat (mapcar (lambda (c) (make-glyph-code c 'my/fold-ellipsis-face)) ellipsis)))

(defun my/customize-fold-ellipsis ()
  "Give the folding ellipsis a dimmed, boxed badge look."
  (when-let* ((fg (my/theme-color 'fg-dim))
              (bg (my/theme-color 'bg-dim))
              (border (my/theme-color 'border)))
    (set-face-attribute
     'my/fold-ellipsis-face nil
     :foreground fg
     :background bg
     ;; Padded at the sides only; a positive vertical width would alter the
     ;; line height, which makes redisplay measure lines instead of counting
     ;; them and lags scrolling.
     :box `(:line-width (1 . -1) :color ,border)))
  (unless standard-display-table
    (setq standard-display-table (make-display-table)))
  (set-display-table-slot
   standard-display-table 'selective-display
   (my/fold-ellipsis-glyphs my/fold-ellipsis-fixed-pitch)))

(defun my/fold-ellipsis-set-display-table (&rest _)
  "Give a proportional buffer its own ellipsis, and every other one none.
The table is a copy of `standard-display-table' because a buffer-local one
takes over from it whole, wrap and truncation glyphs included."
  (setq buffer-display-table
        (when (my/variable-pitch-p)
          (let ((table (copy-sequence standard-display-table)))
            (set-display-table-slot
             table 'selective-display
             (my/fold-ellipsis-glyphs my/fold-ellipsis-proportional))
            table))))

(defun my/fold-ellipsis-string ()
  "Return the marker standing in for folded text, avoiding a mis-painted `:box'."
  (propertize (my/fold-ellipsis) 'face 'my/fold-ellipsis-face))

(defun my/fold-ellipsis-mark-overlay (from to flag &rest _)
  "Sync the fold marker across the overlays between FROM and TO; FLAG hides."
  (let ((marker (my/fold-ellipsis-string)))
    (dolist (o (overlays-in from to))
      (cond ((and flag (overlay-get o 'invisible) (= (overlay-start o) from))
             (overlay-put o 'display marker))
            ((and (equal-including-properties (overlay-get o 'display) marker)
                  (not (overlay-get o 'invisible)))
             (overlay-put o 'display nil))))))

(defun my/fold-ellipsis-set-up-overlay (ov)
  "Show the fold marker in place of the text hideshow hides under OV."
  (overlay-put ov 'display (my/fold-ellipsis-string)))

;;;###autoload
(define-minor-mode my-fold-ellipsis-mode
  "Stand a dimmed, boxed badge in place of folded text.
Both fold render paths are covered: the display table, which Org draws its
ellipsis from, and the `display' property of the fold overlays made by
`outline-minor-mode' and by hideshow."
  :global t
  :group 'faces
  (if my-fold-ellipsis-mode
      (progn
        ;; Style the badge now, not only on the next theme load.
        (my/customize-fold-ellipsis)
        (add-hook 'after-load-theme-hook #'my/customize-fold-ellipsis)
        (advice-add 'variable-pitch-mode :after #'my/fold-ellipsis-set-display-table)
        (advice-add 'outline-flag-region :after #'my/fold-ellipsis-mark-overlay)
        ;; Set before hideshow loads: its `defcustom' leaves a value that is
        ;; already there alone, and it calls nil as no handler at all.
        (setq my/fold-ellipsis-saved-hs-set-up-overlay
              (and (boundp 'hs-set-up-overlay) hs-set-up-overlay)
              hs-set-up-overlay #'my/fold-ellipsis-set-up-overlay)
        ;; Correct any buffers that are proportional already (e.g. restored by
        ;; desktop, or visited while this mode was off).
        (dolist (buf (buffer-list))
          (with-current-buffer buf
            (my/fold-ellipsis-set-display-table))))
    (remove-hook 'after-load-theme-hook #'my/customize-fold-ellipsis)
    (advice-remove 'variable-pitch-mode #'my/fold-ellipsis-set-display-table)
    (advice-remove 'outline-flag-region #'my/fold-ellipsis-mark-overlay)
    (setq hs-set-up-overlay my/fold-ellipsis-saved-hs-set-up-overlay)
    (dolist (buf (buffer-list))
      (with-current-buffer buf
        (when (my/variable-pitch-p)
          (setq buffer-display-table nil))))))

(provide 'my-fold-ellipsis)

;;; my-fold-ellipsis.el ends here
