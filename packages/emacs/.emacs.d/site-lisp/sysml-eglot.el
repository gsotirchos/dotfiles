;;; sysml-eglot.el --- OpenSysML language server extensions for Eglot -*- lexical-binding: t -*-

;; Copyright The OpenSysML Authors
;; SPDX-License-Identifier: Apache-2.0

;; Author: George Sotirchos
;; Version: 0.1.0
;; Package-Requires: ((emacs "31.1"))

;;; Commentary:

;; This module ports to Eglot the parts of OpenSysML's lsp-mode client,
;; editors/emacs/sysml-lsp.el, that `sysml-diagram' relies on: the
;; `opensysml/renderChanged' notification and the text of the bundled
;; library documents the server locates under `sysml-stdlib:' URIs.
;; See https://github.com/Open-MBEE/OpenSysML/blob/af30460/editors/emacs/sysml-lsp.el
;; and docs/reference/lsp.md there for the methods.

;; Usage:
;;   (add-to-list 'eglot-server-programs '((sysml-mode kerml-mode) "sysml-lsp"))
;;   (require 'sysml-eglot)

;;; Code:

(require 'eglot)
(require 'sysml-mode)
(require 'url-parse)
(require 'url-util)

(defvar sysml-eglot-render-changed-functions nil
  "Functions called when the server reports a document's rendering changed.
Each is called with the document's file name and the version the server
analysed.  The server sends `opensysml/renderChanged' after every analysis
of an open document, whether or not anything shows a view of it.")

(cl-defmethod eglot-handle-notification
  (_server (_method (eql opensysml/renderChanged)) &key textDocument version)
  "Run `sysml-eglot-render-changed-functions' for the TEXTDOCUMENT at VERSION."
  (run-hook-with-args 'sysml-eglot-render-changed-functions
                      (eglot-uri-to-path (plist-get textDocument :uri))
                      version))

(defconst sysml-eglot--stdlib-content-method "opensysml/stdlibContent"
  "The request serving the text of a bundled library document.")

(defvar-local sysml-eglot-stdlib-uri nil
  "The `sysml-stdlib:' URI of the bundled library document this buffer shows.")

(defvar-local sysml-eglot--stdlib-server nil
  "The server whose bundled library this buffer's text is from.")

(defun sysml-eglot-stdlib-uri-p (uri)
  "Return non-nil when URI names a document of the bundled library."
  (string-prefix-p "sysml-stdlib:" uri))

(defun sysml-eglot-stdlib-buffer (uri)
  "Return a read-only buffer showing the bundled library document URI.
Its text is asked of the current buffer's server, once per document and
server: another build may bundle a different library."
  (let ((server (eglot-current-server)))
    (or (seq-find (lambda (buffer)
                    (and (equal (buffer-local-value 'sysml-eglot-stdlib-uri buffer) uri)
                         (eq (buffer-local-value 'sysml-eglot--stdlib-server buffer) server)))
                  (buffer-list))
        (let* ((text (plist-get (jsonrpc-request server sysml-eglot--stdlib-content-method
                                                 (list :uri uri))
                                :text))
               (path (url-unhex-string (url-filename (url-generic-parse-url uri))))
               (buffer (generate-new-buffer
                        (format "%s <library>" (file-name-nondirectory path)))))
          (with-current-buffer buffer
            (insert text)
            (if (string-suffix-p ".kerml" path) (kerml-mode) (sysml-mode))
            (setq sysml-eglot-stdlib-uri uri
                  sysml-eglot--stdlib-server server)
            (set-buffer-modified-p nil)
            (setq buffer-read-only t)
            (goto-char (point-min)))
          buffer))))

;;;; Formatting

(defun sysml-eglot--format-with-mode-offset (format &rest args)
  "Call FORMAT with ARGS, sending `sysml-indent-offset' as the indent width.
Eglot sends `tab-width' as a formatting request's tabSize, the width the
server indents by, while `sysml-mode' indents by `sysml-indent-offset'."
  (let ((tab-width (if (derived-mode-p 'sysml-base-mode) sysml-indent-offset tab-width)))
    (apply format args)))

(advice-add 'eglot-format :around #'sysml-eglot--format-with-mode-offset)

(provide 'sysml-eglot)

;;; sysml-eglot.el ends here
