;;; my-git-commit.el --- Highlight overlong commit message body lines  -*- lexical-binding: t; -*-

;;; Commentary:
;; Magit's `git-commit' highlights the tail of an overlong *summary* line
;; with the `git-commit-overlong-summary' face, via a plain regexp entry in
;; `git-commit-font-lock-keywords-1'.  It offers no equivalent for the
;; message *body*, whose lines conventionally wrap at ~72 columns.
;;
;; This module adds a `git-commit-overlong-body' face and reuses the very
;; same mechanism: a per-line regexp font-lock keyword highlights the
;; characters of each body line past `git-commit-body-max-length'.  The
;; keyword uses OVERRIDE nil, so it never repaints text an earlier
;; git-commit keyword already faced -- which means the summary line
;; (`git-commit-summary') and comment/status lines (`font-lock-comment-face')
;; are skipped for free, with no bespoke matcher or region logic.
;;
;; The same limit also drives `fill-column' in the commit buffer, so that
;; git-commit's own `git-commit-setup-auto-fill' wraps the body exactly
;; where the overlong-body face would otherwise kick in.

;;; Code:

(require 'git-commit)

(defface git-commit-overlong-body
  '((t :inherit git-commit-overlong-summary))
  "Face for the tail of overlong lines in the commit message body."
  :group 'git-commit-faces)

(defcustom git-commit-body-max-length 72
  "Column beyond which characters in body lines are highlighted."
  :safe #'numberp
  :type 'number
  :group 'git-commit)

(with-eval-after-load 'git-commit
  ;; Append after the built-in keywords so the summary and comment faces are
  ;; already applied; OVERRIDE nil then leaves those lines untouched.  The
  ;; `eval' form re-reads `git-commit-body-max-length' on each fontification,
  ;; mirroring how the summary keyword re-reads `git-commit-summary-regexp'.
  (add-to-list 'git-commit-font-lock-keywords
               '(eval . `(,(format "^.\\{%d\\}\\(.+\\)$" git-commit-body-max-length)
                          (1 'git-commit-overlong-body)))
               t))

(defun my/git-commit-set-fill-column ()
  "Set `fill-column' to `git-commit-body-max-length' in commit buffers.
Auto filling itself is already enabled by `git-commit-setup-auto-fill',
which leaves the summary line alone."
  (setq-local fill-column git-commit-body-max-length))

(add-hook 'git-commit-setup-hook #'my/git-commit-set-fill-column)

(provide 'my-git-commit)

;;; my-git-commit.el ends here
