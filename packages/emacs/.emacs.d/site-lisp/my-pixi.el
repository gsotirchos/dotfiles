;;; my-pixi.el --- Buffer-local environments from pixi workspaces  -*- lexical-binding: t; -*-

;;; Commentary:

;; Emacs started outside a `pixi shell' knows nothing about a workspace's
;; environment, so language servers, formatters and inferior processes
;; resolve against the system interpreter instead of `.pixi/envs/...'.
;;
;; This package asks pixi itself for the activated environment of the
;; workspace a buffer lives in (`pixi run env -0', which also runs the
;; workspace's [activation] scripts -- for a colcon/ROS workspace that is
;; what puts `install/*/lib/python3.X/site-packages' on PYTHONPATH) and
;; installs it as buffer-local `process-environment' and `exec-path'.
;;
;; Pyright ignores PYTHONPATH, so `my-pixi-python-setup' additionally hands
;; it the interpreter and the PYTHONPATH entries through
;; `eglot-workspace-configuration'.
;;
;; The dump is cached per manifest and invalidated when pixi.toml or
;; pixi.lock changes.  Anything else that alters the activated environment
;; -- a colcon build adding packages to the install space, say -- needs
;; `my-pixi-refresh'.

;;; Code:

(require 'seq)

(defvar eglot-workspace-configuration)
(declare-function eglot-current-server "eglot")
(declare-function eglot-signal-didChangeConfiguration "eglot" (server))
(declare-function eglot-reconnect "eglot" (server &optional interactive))

(defgroup my-pixi nil
  "Use the environment of the surrounding pixi workspace."
  :group 'tools)

(defcustom my-pixi-executable "pixi"
  "Name or path of the pixi executable."
  :type 'string)

(defcustom my-pixi-environment nil
  "Name of the pixi environment to activate, or nil for the default one."
  :type '(choice (const :tag "Default" nil) string)
  :safe #'stringp)

(defvar my-pixi--cache (make-hash-table :test #'equal)
  "Cache of environment dumps, keyed by (MANIFEST . ENVIRONMENT).
Each value is a cons of the manifest stamp and a list of \"NAME=VALUE\".")

(defun my-pixi--manifest-in (dir)
  "Return the pixi manifest directly in DIR, or nil."
  (let ((pixi (expand-file-name "pixi.toml" dir))
        (pyproject (expand-file-name "pyproject.toml" dir)))
    (cond ((file-exists-p pixi) pixi)
          ((and (file-exists-p pyproject)
                (with-temp-buffer
                  (insert-file-contents pyproject)
                  (re-search-forward "^\\[tool\\.pixi" nil t)))
           pyproject))))

(defun my-pixi-manifest (&optional dir)
  "Return the pixi manifest governing DIR, or nil if there is none."
  (let ((dir (or dir default-directory)))
    (and (not (file-remote-p dir))
         (when-let* ((root (locate-dominating-file dir #'my-pixi--manifest-in)))
           (my-pixi--manifest-in root)))))

(defun my-pixi--stamp (manifest)
  "Return a value that changes when the environment of MANIFEST is respecified."
  (let ((dir (file-name-directory manifest)))
    (mapcar (lambda (file)
              (file-attribute-modification-time (file-attributes file)))
            (list manifest (expand-file-name "pixi.lock" dir)))))

(defun my-pixi--dump (manifest environment)
  "Return the activated environment of MANIFEST as a list of \"NAME=VALUE\".
ENVIRONMENT is a pixi environment name, or nil for the default one."
  (let ((default-directory (file-name-directory manifest))
        ;; Ask pixi from a pristine environment, so that activating a
        ;; workspace from a buffer that already has one does not stack.
        (process-environment (default-value 'process-environment))
        (exec-path (default-value 'exec-path)))
    (with-temp-buffer
      (if (eq 0 (apply #'call-process my-pixi-executable nil '(t nil) nil
                       `("run" "--frozen" "--manifest-path" ,manifest
                         ,@(when environment (list "--environment" environment))
                         "env" "-0")))
          (split-string (buffer-string) "\0" t)
        (message "my-pixi: could not read the environment of %s" manifest)
        nil))))

(defun my-pixi-environment-variables (manifest &optional environment)
  "Return the activated environment of MANIFEST as a list of \"NAME=VALUE\".
ENVIRONMENT is a pixi environment name, or nil for the default one.
The result is cached until MANIFEST or its lock file changes."
  (let ((key (cons manifest environment))
        (stamp (my-pixi--stamp manifest)))
    (if-let* ((cached (gethash key my-pixi--cache))
              ((equal (car cached) stamp)))
        (cdr cached)
      (when-let* ((vars (my-pixi--dump manifest environment)))
        (puthash key (cons stamp vars) my-pixi--cache)
        vars))))

(defun my-pixi--value (vars name)
  "Return the value of NAME in VARS, a list of \"NAME=VALUE\"."
  (let ((prefix (concat name "=")))
    (when-let* ((entry (seq-find (lambda (var) (string-prefix-p prefix var)) vars)))
      (substring entry (length prefix)))))

;;;###autoload
(define-minor-mode my-pixi-mode
  "Run subprocesses of this buffer inside its pixi workspace environment.
Turning the mode on sets `process-environment' and `exec-path' buffer
locally; it turns itself off again when the buffer is not in a pixi
workspace, or when pixi cannot report the environment."
  :lighter " pixi"
  (if (not my-pixi-mode)
      (progn (kill-local-variable 'process-environment)
             (kill-local-variable 'exec-path))
    (let* ((manifest (my-pixi-manifest))
           (vars (and manifest
                      ;; Never let opening a file provision an environment:
                      ;; that can take minutes.  Bail out and let the user
                      ;; run `pixi install' instead.
                      (or (file-directory-p
                           (expand-file-name ".pixi/envs" (file-name-directory manifest)))
                          (ignore (message "my-pixi: %s has no installed environment"
                                           manifest)))
                      (my-pixi-environment-variables manifest my-pixi-environment))))
      (if (null vars)
          (setq my-pixi-mode nil)
        (setq-local process-environment (copy-sequence vars))
        (setq-local exec-path
                    (append (split-string (or (my-pixi--value vars "PATH") "")
                                          path-separator t)
                            (list exec-directory)))))))

(defun my-pixi-python-executable ()
  "Return the Python interpreter of the current buffer's pixi environment."
  (when-let* ((prefix (getenv "CONDA_PREFIX"))
              (python (expand-file-name "bin/python" prefix))
              ((file-executable-p python)))
    python))

;;;###autoload
(defun my-pixi-python-setup ()
  "Point the Python tooling of this buffer at its pixi environment.
Meant for `python-base-mode-hook', where it has to run before
`eglot-ensure' so that the language server is told about the
environment on connection."
  (my-pixi-mode 1)
  (when-let* ((my-pixi-mode)
              (python (my-pixi-python-executable)))
    (setq-local python-shell-interpreter python)
    ;; Pyright resolves imports through the interpreter and its own
    ;; extraPaths only; it never reads PYTHONPATH.
    (setq-local eglot-workspace-configuration
                `(:python
                  (:pythonPath
                   ,python
                   :analysis
                   (:extraPaths
                    ,(vconcat (seq-filter #'file-directory-p
                                          (split-string (or (getenv "PYTHONPATH") "")
                                                        path-separator t)))))))
    (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
      (eglot-signal-didChangeConfiguration server))))

;;;###autoload
(defun my-pixi-refresh ()
  "Forget every cached pixi environment and re-activate this buffer's.
Use this after something outside the manifest changed the environment,
such as a colcon build adding packages to the install space."
  (interactive)
  (clrhash my-pixi--cache)
  (when (derived-mode-p 'python-base-mode)
    (my-pixi-python-setup))
  (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
    (eglot-reconnect server)))

(provide 'my-pixi)
;;; my-pixi.el ends here
