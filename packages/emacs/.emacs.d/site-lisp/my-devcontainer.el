;;; my-devcontainer.el --- Container-side tools for host buffers  -*- lexical-binding: t; -*-

;;; Commentary:

;; A devcontainer image carries the project's build environment -- its
;; compiler, its ROS underlay, its headers -- but none of the editor tooling.
;; VS Code deals with that by moving its whole editor server into the
;; container.  This does the opposite: buffers stay on the host (the
;; workspace is a bind mount, so the host copy of a file is the same file)
;; and only the tools that need the image's filesystem are run inside the
;; container, through the `devcontainer-exec' script.
;;
;; That is clangd, which needs the headers under /opt/ros, and pyright and
;; mypy, which need the image's site-packages.  Everything that merely
;; reads the source and its configuration -- ruff, the formatters, the
;; other Flymake backends -- keeps running on the host untouched.
;;
;; Two things bridge the path difference between the two sides:
;;
;;   * clangd is handed the container's bind mounts as `--path-mappings',
;;     since it is the one server that reads a compile database written
;;     inside the container.  The other tools see the host's paths through
;;     same-path symlinks that `devcontainer-exec --provision' creates.
;;
;;   * A location a server reports under /opt or /usr exists only in the
;;     container; `eglot-uri-to-path' is taught to point those at the
;;     container's copy over Tramp, which is enough to read a header.

;;; Code:

(require 'seq)

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
  "Return the answer of `devcontainer-exec ACTION' for DIR, or nil.
Answers are cached: docker is not free, and a container that is not yet
running is started on the first question, which takes a while."
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
A checker run in the container cannot read a shadow file written to the
host's /tmp, so it goes under the workspace holding DIR instead.  Nil if
no container serves DIR."
  (when-let* ((workspace (my-devcontainer-workspace dir))
              (tmp (expand-file-name ".cache/emacs/" workspace)))
    (make-directory tmp t)
    tmp))

(defun my-devcontainer-command (program &rest args)
  "Return the command running PROGRAM with ARGS in the current container."
  `(,my-devcontainer-executable ,program ,@args))

(defun my-devcontainer--clangd-args (mappings)
  "Return the arguments that tie clangd to the container and the workspace.
MAPPINGS tell it how the host's paths map to the container's.  It is also
pointed at the workspace's merged compile database, since the per-package
one it would find first has nothing for the generated headers that
`merge-compile-commands' provides for."
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
A link written inside the container -- every file of a colcon
--symlink-install space -- carries the container's absolute path, so on
the host it dangles until its target is translated with MAPPINGS."
  (when-let* ((target (file-symlink-p path))
              (host (my-devcontainer--host-path
                     (expand-file-name target (file-name-directory path)) mappings)))
    (and (file-exists-p host) host)))

(defun my-devcontainer--localize-path (path)
  "Return PATH as something the host can visit.
Filter for `eglot-uri-to-path': a container-side server reports the
container's paths, which are either the host's own files under another
name or, for the image's headers, files only the container has."
  (if (or (file-exists-p path) (file-remote-p path))
      path
    (if-let* ((mappings (my-devcontainer-mappings)))
        (or (my-devcontainer--host-path path mappings)
            (my-devcontainer--symlink-target path mappings)
            (concat "/docker:" (my-devcontainer--query "--container") ":" path))
      path)))

(defun my-devcontainer--withhold-process-id (fn &rest args)
  "Send no client PID to a container-side server."
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

;;;###autoload
(defun my-devcontainer-setup-compile-command ()
  "Make \\[compile] build the current colcon package in its container.
The compile database flag is passed explicitly, since the exported
variable seeds a package's CMake cache only on its first configure, and
the per-package databases are merged afterwards for clangd.  A
--cmake-args on the command line replaces, rather than extends, the
list in a workspace's colcon_defaults.yaml, so the generator is named
here too or a workspace configured for Ninja would fall back to Make."
  (when-let* ((file (buffer-file-name))
              (package (my-devcontainer--colcon-package file))
              ((my-devcontainer-workspace)))
    (setq-local compile-command
                (format (concat "%s colcon build --symlink-install --packages-up-to %s"
                                " --cmake-args -GNinja -DCMAKE_BUILD_TYPE=Release"
                                " -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
                                " && merge-compile-commands")
                        my-devcontainer-executable package))))

(defun my-devcontainer--in-workspace (fn &rest args)
  "Execute FN with ARGS the top of the container's workspace."
  (let ((default-directory (or (my-devcontainer-workspace) default-directory)))
    (apply fn args)))

(advice-add 'compile :around #'my-devcontainer--in-workspace)

;;;###autoload
(defun my-devcontainer-setup-compilation-buffer ()
  "Translate the container's paths in compiler messages to the host's.
For `compilation-mode-hook': the build runs in the container, so its
messages name /workspace/..., which `next-error' could not visit."
  (when-let* ((mappings (my-devcontainer-mappings)))
    (setq-local compilation-parse-errors-filename-function
                (lambda (file) (or (my-devcontainer--host-path file mappings) file)))))


;;;; Terminal

(defun my-devcontainer--shell-command (workdir)
  "Return the docker command opening a login shell in WORKDIR of the container."
  (let ((container (split-string (my-devcontainer--query "--container") "@")))
    `("docker" "exec" "-it" "-u" ,(car container) "-w" ,workdir
      "-e" "TERM=xterm-256color" ,(cadr container) "bash" "-l")))

;;;###autoload
(defun my-devcontainer-terminal ()
  "Pop to a new ghostel terminal running a login shell in the current container.
The shell starts at the top of the container's workspace."
  (interactive)
  (require 'ghostel)
  (let* ((mappings (or (my-devcontainer-mappings)
                       (user-error "my-devcontainer: no devcontainer serves %s"
                                   (abbreviate-file-name default-directory))))
         (mount (my-devcontainer--mount (expand-file-name default-directory) mappings))
         (command (my-devcontainer--shell-command (cdr mount)))
         (buffer (generate-new-buffer
                  (format "*devcontainer:%s*" (file-name-nondirectory (car mount))))))
    (pop-to-buffer-same-window buffer)
    (ghostel-exec buffer (car command) (cdr command))))


;;;; Refreshing

;;;###autoload
(defun my-devcontainer-refresh ()
  "Re-read the container's environment and reconnect the language server.
Needed after a build has extended what the container's tools can see, or
after the container was recreated: what `devcontainer-exec' hands them is
a snapshot."
  (interactive)
  (unless (my-devcontainer--run "--refresh" default-directory)
    (user-error "my-devcontainer: no devcontainer serves %s"
                (abbreviate-file-name default-directory)))
  (clrhash my-devcontainer--cache)
  (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
    (eglot-reconnect server))
  (message "my-devcontainer: refreshed"))

(provide 'my-devcontainer)
;;; my-devcontainer.el ends here
