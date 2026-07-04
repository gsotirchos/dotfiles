;;; my-devcontainer.el --- Open dev containers over TRAMP  -*- lexical-binding: t; -*-

;;; Commentary:

;; Open a project's dev container (https://containers.dev) over TRAMP so that
;; eglot, flymake, formatters, compile, eshell and magit all run *inside* the
;; container, mirroring how VS Code's dev containers work.
;;
;; `my/devcontainer-up' shells out to the dev containers CLI's `up' command
;; (idempotent: it reuses an already running container), reads the container id
;; it reports, and visits the container's workspace with the built-in `docker'
;; TRAMP method.  TRAMP then handles path translation, so no per-tool wrappers
;; or `devcontainer.json' edits are needed.

;;; Code:

(require 'project)
(require 'json)

(defgroup my/devcontainer nil
  "Open dev containers over TRAMP."
  :group 'tools)

(defcustom my/devcontainer-executable "devcontainer"
  "Executable for the dev containers CLI (npm i -g @devcontainers/cli)."
  :type 'string
  :group 'my/devcontainer)

(defun my/devcontainer--last-json (buffer)
  "Return the last JSON object printed in BUFFER as a hash-table, or nil."
  (with-current-buffer buffer
    (save-excursion
      (goto-char (point-max))
      (let (result)
        (while (and (not result) (not (bobp)))
          (forward-line -1)
          (let ((line (string-trim
                       (buffer-substring-no-properties
                        (line-beginning-position) (line-end-position)))))
            (when (string-prefix-p "{" line)
              (setq result (ignore-errors (json-parse-string line))))))
        result))))

(defun my/devcontainer--open (buffer)
  "Parse the `devcontainer up' result in BUFFER and visit it via TRAMP."
  (let ((json (my/devcontainer--last-json buffer)))
    (unless json
      (pop-to-buffer buffer)
      (user-error "devcontainer up: no JSON result (see buffer)"))
    (unless (equal (gethash "outcome" json) "success")
      (pop-to-buffer buffer)
      (user-error "devcontainer up: %s — %s"
                  (gethash "outcome" json)
                  (gethash "message" json "unknown error")))
    (let* ((id (gethash "containerId" json))
           (user (gethash "remoteUser" json))
           (folder (gethash "remoteWorkspaceFolder" json))
           (path (format "/docker:%s%s:%s"
                         (if (and user (not (string-empty-p user)))
                             (concat user "@") "")
                         id folder)))
      (message "devcontainer: opening %s" path)
      (dired path))))

;;;###autoload
(defun my/devcontainer-up (&optional workspace-folder)
  "Bring up the dev container for WORKSPACE-FOLDER and open it over TRAMP.
Runs the dev containers CLI's `up' (idempotent: reuses an already
running container) and then visits the container's workspace with
Dired using the built-in `docker' TRAMP method.  Everything opened
from there — eglot, flymake, formatters, compile, eshell, magit —
runs inside the container.  WORKSPACE-FOLDER defaults to the current
project root."
  (interactive)
  (unless (executable-find my/devcontainer-executable)
    (user-error "Cannot find `%s' (npm i -g @devcontainers/cli)"
                my/devcontainer-executable))
  (let* ((folder (expand-file-name
                  (or workspace-folder
                      (if-let* ((proj (project-current)))
                          (project-root proj)
                        default-directory))))
         (buffer (generate-new-buffer " *devcontainer up*")))
    (message "devcontainer: bringing up container for %s…" folder)
    (make-process
     :name "devcontainer-up"
     :buffer buffer
     :noquery t
     :command (list my/devcontainer-executable "up" "--workspace-folder" folder)
     :sentinel
     (lambda (proc _event)
       (when (memq (process-status proc) '(exit signal))
         (unwind-protect
             (if (zerop (process-exit-status proc))
                 (my/devcontainer--open buffer)
               (pop-to-buffer buffer)
               (user-error "devcontainer up failed (exit %d)"
                           (process-exit-status proc)))
           (unless (get-buffer-window buffer)
             (kill-buffer buffer))))))))

(provide 'my-devcontainer)

;;; my-devcontainer.el ends here
