;;; flymake-cmake-lint.el --- cmake-lint support for flymake -*- lexical-binding: t -*-

;; Author: George Sotirchos
;; Version: 0.1.0

;;; Commentary:

;; This module provides a Flymake backend for `cmake-lint' (from the
;; cmakelang package) in `cmake-ts-mode' buffers.

;; Usage:
;;   (require 'flymake-cmake-lint)
;;   (add-hook 'cmake-ts-mode-hook #'flymake-cmake-lint-setup)

;;; Code:

(require 'flymake)
(require 'flymake-quickdef)

(flymake-quickdef-backend flymake-cmake-lint--backend
  :pre-check (progn
               (unless (executable-find "cmake-lint")
                 (error "Executable `cmake-lint' not found on PATH"))
               (unless (buffer-file-name)
                 (error "cmake-lint: buffer is not visiting a file")))
  :write-type 'file
  :proc-form (list "cmake-lint" "--suppress-decorations" (buffer-file-name))
  :search-regexp
  "^[^:\n]*:\\([0-9]+\\)\\(?:,\\([0-9]+\\)\\)?: \\[\\([CRWE]\\)[0-9]+\\] \\(.*\\)$"
  :prep-diagnostic
  (let* ((lnum (string-to-number (match-string 1)))
         (col  (and (match-string 2) (1+ (string-to-number (match-string 2)))))
         (sev  (match-string 3))
         (msg  (match-string 4))
         (type (cond ((string= sev "E") :error)
                     ((string= sev "W") :warning)
                     (t :note)))
         (region (flymake-diag-region fmqd-source lnum col)))
    (list fmqd-source (car region) (cdr region) type
          (format "cmake-lint[%s]: %s" sev msg))))

;;;###autoload
(defun flymake-cmake-lint-setup ()
  "Enable the cmake-lint Flymake backend in the current buffer."
  (when (executable-find "cmake-lint")
    (add-hook 'flymake-diagnostic-functions #'flymake-cmake-lint--backend nil t)
    (flymake-mode 1)))

(provide 'flymake-cmake-lint)

;;; flymake-cmake-lint.el ends here
