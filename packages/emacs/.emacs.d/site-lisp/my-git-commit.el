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

(provide 'my-git-commit)

;;; my-git-commit.el ends here
