;;; flymake-shfmt.el --- shfmt syntax checking for flymake -*- lexical-binding: t -*-

;; Author: George Sotirchos
;; Version: 0.1.0

;;; Commentary:

;; This module provides a Flymake backend reporting the parse errors `shfmt'
;; finds in `sh-base-mode' buffers.  Bash validates a parameter expansion only
;; when the word is expanded, so neither `bash -n' nor ShellCheck rejects
;; "${1foo}" and the mistake surfaces at run time -- or, later, as an opaque
;; Apheleia failure.  shfmt's own parser rejects it outright.
;; See https://github.com/koalaman/shellcheck/issues/1712

;; Usage:
;;   (require 'flymake-shfmt)
;;   (add-hook 'sh-base-mode-hook #'flymake-shfmt-setup)

;;; Code:

(require 'flymake)
(require 'flymake-quickdef)
(require 'sh-script)

(defvar flymake-shfmt-dialects
  '((bash . "bash") (sh . "posix") (mksh . "mksh"))
  "Alist mapping a `sh-shell' symbol to the shfmt `-ln' dialect to parse it as.
Shells absent from this alist have no shfmt parser and are left unchecked.")

(defun flymake-shfmt--dialect ()
  "Return the shfmt dialect for the current buffer, or nil if it has none."
  (cdr (assq sh-shell flymake-shfmt-dialects)))

(flymake-quickdef-backend flymake-shfmt--backend
  :pre-let ((dialect (flymake-shfmt--dialect)))
  :pre-check (progn
               (unless (executable-find "shfmt")
                 (error "Executable `shfmt' not found on PATH"))
               (unless dialect
                 (error "No shfmt dialect for shell `%s'" sh-shell)))
  ;; Piping keeps unsaved edits checkable, and is the only option when shfmt is
  ;; a snap: its `home' interface grants `owner @{HOME}/[^.]** rwkl', so opening
  ;; anything under a dotted directory is denied.
  :write-type 'pipe
  ;; `-l' reduces the formatted program on stdout to a single filename, leaving
  ;; the parse error on stderr as the only thing worth scanning.
  :proc-form (list "shfmt" "-ln" dialect "-l")
  :search-regexp "^<standard input>:\\([0-9]+\\):\\([0-9]+\\): \\(.*\\)$"
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
         (col (string-to-number (match-string 2)))
         (msg (match-string 3))
         (region (flymake-diag-region fmqd-source lnum col)))
    (list fmqd-source (car region) (cdr region) :error
          (format "shfmt: %s" msg))))

;;;###autoload
(defun flymake-shfmt-setup ()
  "Enable the shfmt Flymake backend in the current buffer."
  (when (and (executable-find "shfmt") (flymake-shfmt--dialect))
    (add-hook 'flymake-diagnostic-functions #'flymake-shfmt--backend nil t)
    (flymake-mode 1)))

(provide 'flymake-shfmt)

;;; flymake-shfmt.el ends here
