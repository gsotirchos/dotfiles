;;; my-devcontainer.el --- Container-side tools for host buffers  -*- lexical-binding: t; -*-

;;; Commentary:

;; Buffers stay on the host while the tools needing the image's filesystem
;; (clangd, pyright, mypy, colcon) run in the container via `devcontainer-exec'.
;; clangd gets the bind mounts as --path-mappings; paths only the container
;; has are visited over Tramp.

;;; Code:

(require 'seq)
(require 'format-spec)
(require 'subr-x)

(declare-function eglot-current-server "eglot")
(declare-function eglot-reconnect "eglot" (server &optional interactive))
(declare-function ghostel-exec "ghostel" (buffer program &optional args identity))
(defvar eglot-withhold-process-id)

(defgroup my-devcontainer nil
  "Run language servers inside a devcontainer for buffers on the host."
  :group 'tools)

(defcustom my-devcontainer-executable "devcontainer-exec"
  "Name or path of the script that runs a command in a devcontainer."
  :type 'string)

(defvar my-devcontainer--cache (make-hash-table :test #'equal)
  "Answers of `devcontainer-exec', keyed by (ACTION . DIRECTORY).
A nil value records that DIRECTORY belongs to no container.")

(defun my-devcontainer--run (&rest args)
  "Run `devcontainer-exec' with ARGS, returning trimmed stdout, or nil on failure."
  (with-temp-buffer
    (when (eq 0 (apply #'call-process my-devcontainer-executable nil '(t nil) nil args))
      (string-trim (buffer-string)))))

(defun my-devcontainer--query (action &optional dir)
  "Return the cached answer of `devcontainer-exec ACTION' for DIR, or nil."
  (let* ((dir (directory-file-name (expand-file-name (or dir default-directory))))
         (key (cons action dir)))
    (unless (file-remote-p dir)
      (let ((cached (gethash key my-devcontainer--cache 'unknown)))
        (if (eq cached 'unknown)
            (puthash key (my-devcontainer--run action dir) my-devcontainer--cache)
          cached)))))

(defun my-devcontainer-mappings (&optional dir)
  "Return the bind mounts of the container serving DIR as an alist, or nil.
Each entry is (HOST . CONTAINER), deepest host path first."
  (when-let* ((mappings (my-devcontainer--query "--mappings" dir)))
    (mapcar (lambda (mapping)
              (let ((sides (split-string mapping "=")))
                (cons (car sides) (cadr sides))))
            (split-string mappings ","))))

(defun my-devcontainer--mount (dir mappings)
  "Return the entry of MAPPINGS whose host side holds DIR, or nil."
  (seq-find (lambda (mapping)
              (string-prefix-p (file-name-as-directory (car mapping)) dir))
            mappings))

(defun my-devcontainer-workspace (&optional dir)
  "Return the host side of the bind mount holding DIR, or nil."
  (when-let* ((dir (expand-file-name (or dir default-directory)))
              (mappings (my-devcontainer-mappings dir))
              (mount (my-devcontainer--mount dir mappings)))
    (car mount)))

(defun my-devcontainer-temporary-directory (&optional dir)
  "Return a temporary directory both the host and DIR's container can see.
Nil if no container serves DIR."
  (when-let* ((workspace (my-devcontainer-workspace dir))
              (tmp (expand-file-name ".cache/emacs/" workspace)))
    (make-directory tmp t)
    tmp))

(defun my-devcontainer-command (program &rest args)
  "Return the command running PROGRAM with ARGS in the current container."
  `(,my-devcontainer-executable ,program ,@args))

(defun my-devcontainer--clangd-args (mappings)
  "Return clangd's arguments for the container's MAPPINGS.
It is pointed at the workspace's merged compile database, the only one
covering generated headers."
  (cons (concat "--path-mappings="
                (mapconcat (lambda (mapping) (concat (car mapping) "=" (cdr mapping)))
                           mappings ","))
        (when-let* ((workspace (my-devcontainer-workspace))
                    (build (my-devcontainer--container-path
                            (expand-file-name "build" workspace) mappings)))
          (list (concat "--compile-commands-dir=" build)))))

(defun my-devcontainer-eglot-server (program &rest args)
  "Return an `eglot-server-programs' contact running PROGRAM with ARGS.
Inside a devcontainer project the server is run in the container."
  (lambda (&optional _interactive _project)
    (if-let* ((mappings (my-devcontainer-mappings)))
        (apply #'my-devcontainer-command program
               (append args (when (equal program "clangd")
                              (my-devcontainer--clangd-args mappings))))
      (cons program args))))


;;;; Locations inside the container

(defun my-devcontainer--translate (path from to mappings)
  "Return PATH moved from the FROM side of MAPPINGS to the TO side.
FROM and TO are `car' and `cdr' in either order; nil if no mount covers PATH."
  (when-let* ((mapping (seq-find (lambda (mapping)
                                   (or (equal path (funcall from mapping))
                                       (string-prefix-p (file-name-as-directory
                                                         (funcall from mapping))
                                                        path)))
                                 mappings)))
    (concat (funcall to mapping) (substring path (length (funcall from mapping))))))

(defun my-devcontainer--host-path (path mappings)
  "Return the host side of container PATH according to MAPPINGS, or nil."
  (my-devcontainer--translate path #'cdr #'car mappings))

(defun my-devcontainer--container-path (path mappings)
  "Return the container side of host PATH according to MAPPINGS, or nil."
  (my-devcontainer--translate path #'car #'cdr mappings))

(defun my-devcontainer--symlink-target (path mappings)
  "Return the host side of what symlink PATH points to, or nil.
Links made in the container (colcon --symlink-install) carry its paths,
which MAPPINGS translate."
  (when-let* ((target (file-symlink-p path))
              (host (my-devcontainer--host-path
                     (expand-file-name target (file-name-directory path)) mappings)))
    (and (file-exists-p host) host)))

(defun my-devcontainer--localize-path (path)
  "Return container PATH as something the host can visit.
Filter for `eglot-uri-to-path'."
  (if (or (file-exists-p path) (file-remote-p path))
      path
    (if-let* ((mappings (my-devcontainer-mappings)))
        (or (my-devcontainer--host-path path mappings)
            (my-devcontainer--symlink-target path mappings)
            (concat "/docker:" (my-devcontainer--query "--container") ":" path))
      path)))

(defun my-devcontainer--withhold-process-id (fn &rest args)
  "Call FN with ARGS, sending no client PID to a container-side server."
  (let ((eglot-withhold-process-id (or eglot-withhold-process-id
                                       (my-devcontainer-mappings))))
    (apply fn args)))

(with-eval-after-load 'eglot
  (advice-add 'eglot-uri-to-path :filter-return #'my-devcontainer--localize-path)
  (advice-add 'eglot--connect :around #'my-devcontainer--withhold-process-id))


;;;; Building

(defun my-devcontainer--colcon-package (file)
  "Return the name of the colcon package holding FILE, or nil."
  (when-let* ((dir (locate-dominating-file file "package.xml")))
    (with-temp-buffer
      (insert-file-contents (expand-file-name "package.xml" dir))
      (when (re-search-forward "<name>\\s-*\\([^<[:space:]]+\\)\\s-*</name>" nil t)
        (match-string 1)))))

(defun my-devcontainer-compile-command ()
  "Return the command building the current colcon package in its container.
Outside any package the whole workspace is built; outside any container,
return nil.  --cmake-args replaces colcon_defaults.yaml's list, hence the
explicit generator."
  (when-let* ((workspace (my-devcontainer-workspace)))
    (let ((package (my-devcontainer--colcon-package
                    (or (buffer-file-name) default-directory))))
      (format-spec (concat "%e -C %w colcon build --symlink-install%p"
                           " --cmake-args -GNinja -DCMAKE_BUILD_TYPE=Release"
                           " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
                           " && merge-compile-commands %w")
                   `((?e . ,my-devcontainer-executable)
                     (?w . ,(shell-quote-argument (directory-file-name workspace)))
                     (?p . ,(if package (concat " --packages-up-to " package) "")))))))

(defun my-devcontainer--propose-compile-command (&rest _)
  "Make \\[compile] propose `my-devcontainer-compile-command'.
Proposed once per buffer, so an edit made at the prompt is kept."
  (interactive
   (lambda (spec)
     (unless (local-variable-p 'compile-command)
       (when-let* ((command (my-devcontainer-compile-command)))
         (setq-local compile-command command)))
     (advice-eval-interactive-spec spec))))

(advice-add 'compile :before #'my-devcontainer--propose-compile-command)

;;;###autoload
(defun my-devcontainer-setup-compilation-buffer ()
  "Translate the container's paths in compiler messages to the host's.
For `compilation-mode-hook'."
  (when-let* ((mappings (my-devcontainer-mappings)))
    (setq-local compilation-parse-errors-filename-function
                (lambda (file) (or (my-devcontainer--host-path file mappings) file)))))


;;;; Terminal

(defun my-devcontainer--container ()
  "Return the current container as (USER . ID)."
  (let ((container (split-string (my-devcontainer--query "--container") "@")))
    (cons (car container) (cadr container))))

(defun my-devcontainer--container-name (id)
  "Return the name docker knows container ID by."
  (with-temp-buffer
    (call-process "docker" nil '(t nil) nil "inspect" "--format" "{{.Name}}" id)
    (string-remove-prefix "/" (string-trim (buffer-string)))))

(defun my-devcontainer--shell-command (container workdir)
  "Return the docker command opening a login shell in WORKDIR of CONTAINER.
CONTAINER is a (USER . ID) pair."
  `("docker" "exec" "-it" "-u" ,(car container) "-w" ,workdir
    "-e" "TERM=xterm-256color" ,(cdr container) "bash" "-l"))

;;;###autoload
(defun my-devcontainer-terminal (&optional new)
  "Pop to a ghostel login shell at the top of the container's workspace.
An existing terminal is reused, as in `project-shell'; with prefix
argument NEW, another one is started."
  (interactive "P")
  (require 'ghostel)
  (let* ((mappings (or (my-devcontainer-mappings)
                       (user-error "No devcontainer serves %s"
                                   (abbreviate-file-name default-directory))))
         (mount (my-devcontainer--mount (expand-file-name default-directory) mappings))
         (container (my-devcontainer--container))
         (name (format "*%s-ghostel*" (my-devcontainer--container-name (cdr container))))
         (buffer (if new (generate-new-buffer name) (get-buffer-create name))))
    (pop-to-buffer-same-window buffer)
    (unless (process-live-p (get-buffer-process buffer))
      (let ((command (my-devcontainer--shell-command container (cdr mount))))
        (ghostel-exec buffer (car command) (cdr command))))))


;;;; Refreshing

;;;###autoload
(defun my-devcontainer-refresh ()
  "Re-read the container's environment and reconnect the language server.
Needed after a build or after the container was recreated."
  (interactive)
  (unless (my-devcontainer--run "--refresh" default-directory)
    (user-error "No devcontainer serves %s"
                (abbreviate-file-name default-directory)))
  (clrhash my-devcontainer--cache)
  (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
    (eglot-reconnect server))
  (message "my-devcontainer: refreshed"))

(provide 'my-devcontainer)
;;; my-devcontainer.el ends here
