;;; my-wrap-marks.el --- Ellipses on wrapped code lines, pilcrows in prose -*- lexical-binding: t; -*-

;;; Commentary:
;; Two mutually exclusive buffer-local modes mark how soft-wrapped lines read:
;;
;; - `my-wrap-ellipsis-mode', for code, where wrapping is rare enough to flag:
;;   a dim "…" ends every wrapped screen line and opens every continuation,
;;   after the indentation `visual-wrap-prefix-mode' or `org-indent-mode' gives
;;   it.
;;
;; - `my-pilcrow-mode', for prose, where nearly every line wraps and the hard
;;   newline is the one worth seeing: a dim "¶" stands at each newline.
;;
;; With neither on, wrapped lines carry no marks.
;;
;; Both edit their own entries of the buffer display table in place, so they
;; compose with other users of it.  `whitespace-mode' is the exception: it
;; restores the table it found when switched off, undoing any wrap-marks toggle
;; made while it was on.

;;; Code:

(declare-function my/buffer-display-table "init" ())
(declare-function my/theme-color "init" (name))

(defvar my/wrap-ellipsis "…"
  "Mark at both ends of wrapped screen lines in `my-wrap-ellipsis-mode'.")

(defvar my/pilcrow "¶"
  "Mark at each newline in `my-pilcrow-mode'.")

(defface my/pilcrow-face '((t :inherit special-glyphs))
  "Face for the mark at each newline in `my-pilcrow-mode'."
  :group 'faces)

(defun my/customize-pilcrow ()
  "Dim the pilcrow below the wrap marks, so it recedes from prose."
  (when-let* ((fg (my/theme-color 'border)))
    (set-face-attribute 'my/pilcrow-face nil :foreground fg)))

(add-hook 'after-load-theme-hook #'my/customize-pilcrow)
(my/customize-pilcrow)

(defun my/wrap-marks-refresh ()
  "Refontify, so `visual-wrap-prefix-mode' rebuilds its prefixes."
  (when (bound-and-true-p jit-lock-mode)
    (jit-lock-refontify)))

(defun my/wrap-ellipsis-append (beg end)
  "Append the buffer's `wrap-prefix' to the `wrap-prefix' property from BEG to END."
  (let ((wrap-prop (get-text-property beg 'wrap-prefix)))
    (when (and wrap-prefix (stringp wrap-prop))
      (put-text-property beg end 'wrap-prefix (concat wrap-prop wrap-prefix)))))

(defun my/wrap-ellipsis-visual-wrap-advice ()
  "Append the ellipsis to the prefix `visual-wrap-prefix-mode' set at point."
  (my/wrap-ellipsis-append (point) (pos-eol)))

(defun my/wrap-ellipsis-org-indent-advice (orig-fn &rest args)
  "Append the ellipsis to the wrap prefix ORIG-FN sets with ARGS.
ORIG-FN leaves point on the next line, so the current one is noted first."
  (let ((beg (line-beginning-position))
        (end (line-beginning-position 2)))
    (apply orig-fn args)
    (my/wrap-ellipsis-append beg end)))

;; NOTE: `visual-wrap--apply-to-line' is private; revisit on Emacs updates.
(advice-add 'visual-wrap--apply-to-line :after #'my/wrap-ellipsis-visual-wrap-advice)
(advice-add 'org-indent-set-line-properties :around #'my/wrap-ellipsis-org-indent-advice)

;;;###autoload
(define-minor-mode my-wrap-ellipsis-mode
  "Mark both ends of wrapped screen lines with a dim ellipsis."
  :group 'display
  (if my-wrap-ellipsis-mode
      (progn
        (my-pilcrow-mode -1)
        (setq-local wrap-prefix (propertize my/wrap-ellipsis 'face 'special-glyphs))
        (set-display-table-slot (my/buffer-display-table) 'wrap
                                (make-glyph-code (string-to-char my/wrap-ellipsis)
                                                 'special-glyphs)))
    (kill-local-variable 'wrap-prefix)
    (when buffer-display-table
      (set-display-table-slot buffer-display-table 'wrap
                              (display-table-slot standard-display-table 'wrap))))
  (my/wrap-marks-refresh))

;;;###autoload
(define-minor-mode my-pilcrow-mode
  "Show a dim pilcrow at each newline."
  :group 'display
  (if my-pilcrow-mode
      (progn
        (my-wrap-ellipsis-mode -1)
        (aset (my/buffer-display-table) ?\n
              (vector (make-glyph-code (string-to-char my/pilcrow) 'my/pilcrow-face) ?\n)))
    (when buffer-display-table
      (aset buffer-display-table ?\n (aref standard-display-table ?\n)))))

(provide 'my-wrap-marks)

;;; my-wrap-marks.el ends here
