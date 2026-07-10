;;; my-margin.el --- Arbitrate the left margin between packages  -*- lexical-binding: t; -*-
;;; Commentary:

;; Emacs has a single `left-margin-width' per buffer, so packages that
;; draw indicators in the margin (diff-hl, flymake, ...) fight over it
;; if each manages the width itself.  This package appoints a single
;; owner: each "contributor" reports how many columns it currently
;; needs in the current buffer, and the margin width is the sum.  When
;; nobody has anything to show, the margin collapses to zero.
;;
;; Enable `my-margin-mode' and make sure the contributing packages'
;; own width management is disabled (e.g. `flymake-autoresize-margins'
;; nil, and don't set `diff-hl-autohide-margin').

;;; Code:

(require 'seq)

(declare-function flymake-diagnostics "flymake")

(defgroup my-margin nil
  "Single owner of the left margin."
  :group 'convenience)

(defcustom my/margin-contributors
  '(my/margin-diff-hl-width my/margin-flymake-width)
  "Functions reporting how many left-margin columns they need.
Each is called with no arguments in the buffer being updated and
should return an integer (usually 0 or 1)."
  :type '(repeat function))

(defvar my/margin-triggers
  '(diff-hl-update diff-hl-remove-overlays flymake--handle-report)
  "Functions after which the margin width is recomputed.")

(defun my/margin-diff-hl-width ()
  "Return 1 if diff-hl currently shows any indicators here, else 0."
  (if (and (bound-and-true-p diff-hl-mode)
           (save-restriction
             (widen)
             (seq-some (lambda (o) (overlay-get o 'diff-hl-hunk))
                       (overlays-in (point-min) (point-max)))))
      1 0))

(defun my/margin-flymake-width ()
  "Return 1 if flymake currently has diagnostics here, else 0."
  (if (and (bound-and-true-p flymake-mode)
           (flymake-diagnostics))
      1 0))

(defun my/margin-update (&rest _)
  "Recompute and apply the left margin width for the current buffer."
  (let ((width (apply #'+ (mapcar #'funcall my/margin-contributors))))
    (unless (eql left-margin-width width)
      (setq left-margin-width width)
      (dolist (win (get-buffer-window-list (current-buffer) nil t))
        ;; Preserve the right margin -- it is not ours to manage.
        (set-window-margins win width (cdr (window-margins win)))))))

;;;###autoload
(define-minor-mode my-margin-mode
  "Toggle centralized management of the left margin.
When enabled, the margin width in each buffer is the sum of what
the `my/margin-contributors' report, recomputed after each of the
`my/margin-triggers'."
  :global t
  :group 'my-margin
  (if my-margin-mode
      ;; Advising not-yet-defined functions is fine: the advice takes
      ;; effect when the function is defined, so this does not force
      ;; diff-hl or flymake to load.
      (dolist (fn my/margin-triggers)
        (advice-add fn :after #'my/margin-update))
    (dolist (fn my/margin-triggers)
      (advice-remove fn #'my/margin-update))))

(provide 'my-margin)
;;; my-margin.el ends here
