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

(defun my-devcontainer--mount (path mappings &optional side)
  "Return the entry of MAPPINGS whose SIDE holds PATH, or nil.
SIDE is `car' (the host, by default) or `cdr' (the container)."
  (let ((side (or side #'car)))
    (seq-find (lambda (mapping)
                (let ((root (funcall side mapping)))
                  (or (equal path root)
                      (string-prefix-p (file-name-as-directory root) path))))
              mappings)))

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
  (cons (concat "--path-mappings=" (my-devcontainer--query "--mappings"))
        (when-let* ((workspace (my-devcontainer-workspace))
                    (build (my-devcontainer--container-path
                            (expand-file-name "build" workspace) mappings)))
          (list (concat "--compile-commands-dir=" build)))))

(defun my-devcontainer--eglot-server (container-args program args)
  "Return an `eglot-server-programs' contact running PROGRAM with ARGS.
Inside a devcontainer project the server is run in the container, with
the arguments CONTAINER-ARGS returns for its mappings appended."
  (lambda (&optional _interactive _project)
    (if-let* ((mappings (my-devcontainer-mappings)))
        (apply #'my-devcontainer-command program
               (append args (funcall container-args mappings)))
      (cons program args))))

(defun my-devcontainer-eglot-server (program &rest args)
  "Return an `eglot-server-programs' contact running PROGRAM with ARGS.
Inside a devcontainer project the server is run in the container."
  (my-devcontainer--eglot-server #'ignore program args))

(defun my-devcontainer-clangd-server (&rest args)
  "Return an `eglot-server-programs' contact running clangd with ARGS.
Inside a devcontainer project clangd is run in the container, mapping
its paths to the host's."
  (my-devcontainer--eglot-server #'my-devcontainer--clangd-args "clangd" args))

(defun my-devcontainer-python-extra-paths (&optional dir)
  "Return the site-packages of the ament_virtualenv environments serving DIR.
Those are private to the nodes of their packages, which re-execute
themselves in them, so the container's interpreter does not report them
to pyright.  Every environment of the workspace is returned: pyright
takes one configuration per project, which may hold several packages."
  (when-let* ((workspace (my-devcontainer-workspace dir)))
    (file-expand-wildcards
     (expand-file-name "install/*/share/*/venv/lib/python*/site-packages"
                       workspace))))


;;;; Locations inside the container

(defun my-devcontainer--translate (path from to mappings)
  "Return PATH moved from the FROM side of MAPPINGS to the TO side.
FROM and TO are `car' and `cdr' in either order; nil if no mount covers PATH."
  (when-let* ((mapping (my-devcontainer--mount path mappings from)))
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

(defvar-local my-devcontainer--overlay-time-before-build nil
  "What `my-devcontainer--overlay-time' returned when the build started.")

(defun my-devcontainer--overlay-time ()
  "Return when the workspace's overlay last gained or lost a package, or nil.
colcon gives each package an entry in the install directory, whose
modification time thus changes with the set of them."
  (file-attribute-modification-time
   (file-attributes (expand-file-name "install" (my-devcontainer-workspace)))))

(defun my-devcontainer--reconnect-after-build (buffer _status)
  "Reconnect if the build in BUFFER changed the overlay's set of packages.
The servers' next start re-probes the environment, now stale.  For
`compilation-finish-functions'."
  (with-current-buffer buffer
    (unless (equal my-devcontainer--overlay-time-before-build
                   (my-devcontainer--overlay-time))
      (my-devcontainer--reconnect-servers))))

;;;###autoload
(defun my-devcontainer-setup-compilation-buffer ()
  "Fit a compilation buffer to a build running in the container.
The container's paths in compiler messages are translated to the host's,
and the language servers get to see the packages the build adds.  For
`compilation-mode-hook'."
  (when-let* ((mappings (my-devcontainer-mappings)))
    (setq-local compilation-parse-errors-filename-function
                (lambda (file) (or (my-devcontainer--host-path file mappings) file)))
    (setq my-devcontainer--overlay-time-before-build (my-devcontainer--overlay-time))
    (add-hook 'compilation-finish-functions #'my-devcontainer--reconnect-after-build
              nil t)))


;;;; Terminal

(defun my-devcontainer--container-name (id)
  "Return the name docker knows container ID by."
  (with-temp-buffer
    (call-process "docker" nil '(t nil) nil "inspect" "--format" "{{.Name}}" id)
    (string-remove-prefix "/" (string-trim (buffer-string)))))

;;;###autoload
(defun my-devcontainer-terminal (&optional new)
  "Pop to a ghostel login shell at the top of the container's workspace.
An existing terminal is reused, as in `project-shell'; with prefix
argument NEW, another one is started."
  (interactive "P")
  (require 'ghostel)
  (let* ((workspace (or (my-devcontainer-workspace)
                        (user-error "No devcontainer serves %s"
                                    (abbreviate-file-name default-directory))))
         (id (cadr (split-string (my-devcontainer--query "--container") "@")))
         (name (format "*%s-ghostel*" (my-devcontainer--container-name id)))
         (buffer (if new (generate-new-buffer name) (get-buffer-create name))))
    (pop-to-buffer-same-window buffer)
    (unless (process-live-p (get-buffer-process buffer))
      (ghostel-exec buffer my-devcontainer-executable
                    (list "-C" workspace "env" "TERM=xterm-256color" "bash" "-l")))))


;;;; Refreshing

(defun my-devcontainer--servers (workspace)
  "Return the language servers of the buffers under directory WORKSPACE."
  (when (featurep 'eglot)
    (seq-uniq
     (seq-keep (lambda (buffer)
                 (with-current-buffer buffer
                   (and (string-prefix-p (file-name-as-directory workspace)
                                         (expand-file-name default-directory))
                        (eglot-current-server))))
               (buffer-list)))))

(defun my-devcontainer--reconnect-servers ()
  "Reconnect the language servers of the current workspace."
  (mapc #'eglot-reconnect (my-devcontainer--servers (my-devcontainer-workspace))))

;;;###autoload
(defun my-devcontainer-refresh ()
  "Re-read the container's environment and reconnect its language servers.
Done automatically after a \\[compile] that added packages to the workspace;
needed by hand after such a build from a terminal, or after the container
was recreated."
  (interactive)
  (unless (my-devcontainer--run "--refresh" default-directory)
    (user-error "No devcontainer serves %s"
                (abbreviate-file-name default-directory)))
  (clrhash my-devcontainer--cache)
  (my-devcontainer--reconnect-servers)
  (message "my-devcontainer: refreshed"))

(provide 'my-devcontainer)
;;; my-devcontainer.el ends here
