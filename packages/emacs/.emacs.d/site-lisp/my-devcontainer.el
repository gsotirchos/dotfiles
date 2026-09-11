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

(defun my-devcontainer-temporary-directory (&optional dir)
  "Return a temporary directory both the host and DIR's container can see.
A checker run in the container cannot read a shadow file written to the
host's /tmp, so it goes under the bind mount holding DIR instead.  Nil if
no container serves DIR."
  (when-let* ((mappings (my-devcontainer-mappings dir))
              (dir (expand-file-name (or dir default-directory)))
              (mount (seq-find (lambda (mapping)
                                 (string-prefix-p (file-name-as-directory (car mapping)) dir))
                               mappings))
              (tmp (expand-file-name ".cache/emacs/" (car mount))))
    (make-directory tmp t)
    tmp))

(defun my-devcontainer-command (program &rest args)
  "Return the command running PROGRAM with ARGS in the current container."
  `(,my-devcontainer-executable ,program ,@args))

(defun my-devcontainer-eglot-server (program &rest args)
  "Return an `eglot-server-programs' contact running PROGRAM with ARGS.
Inside a devcontainer project the server is run in the container; clangd
is additionally told how the host's paths map to the container's."
  (lambda (&optional _interactive _project)
    (if-let* ((mappings (my-devcontainer-mappings)))
        (apply #'my-devcontainer-command program
               (append args
                       (when (equal program "clangd")
                         (list (concat "--path-mappings="
                                       (mapconcat (lambda (mapping)
                                                    (concat (car mapping) "=" (cdr mapping)))
                                                  mappings ","))))))
      (cons program args))))


;;;; Locations inside the container

(defun my-devcontainer--host-path (path mappings)
  "Return the host side of container PATH according to MAPPINGS, or nil."
  (when-let* ((mapping (seq-find (lambda (mapping)
                                   (or (equal path (cdr mapping))
                                       (string-prefix-p (file-name-as-directory (cdr mapping))
                                                        path)))
                                 mappings)))
    (concat (car mapping) (substring path (length (cdr mapping))))))

(defun my-devcontainer--localize-path (path)
  "Return PATH as something the host can visit.
Filter for `eglot-uri-to-path': a container-side server reports the
container's paths, which are either the host's own files under another
name or, for the image's headers, files only the container has."
  (if (or (file-exists-p path) (file-remote-p path))
      path
    (if-let* ((mappings (my-devcontainer-mappings)))
        (or (my-devcontainer--host-path path mappings)
            (concat "/docker:" (my-devcontainer--query "--container") ":" path))
      path)))

(with-eval-after-load 'eglot
  (advice-add 'eglot-uri-to-path :filter-return #'my-devcontainer--localize-path))


;;;; Building

(defun my-devcontainer--colcon-root (file)
  "Return the colcon workspace holding FILE, or nil.
That is the outermost ancestor whose src/ contains FILE; the nearest one
would be a package's own src/ directory."
  (let ((dir (file-name-directory file))
        root)
    (while (not (equal dir "/"))
      (when (string-prefix-p (expand-file-name "src/" dir) file)
        (setq root dir))
      (setq dir (file-name-directory (directory-file-name dir))))
    root))

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
the per-package databases are merged afterwards for clangd."
  (when-let* ((file (buffer-file-name))
              (package (my-devcontainer--colcon-package file))
              (root (my-devcontainer--colcon-root file))
              ((my-devcontainer-mappings root))
              (root (shell-quote-argument (directory-file-name root))))
    (setq-local compile-command
                (format (concat "%s -C %s colcon build --packages-up-to %s"
                                " --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
                                " && merge-compile-commands %s")
                        my-devcontainer-executable root package root))))

;;;###autoload
(defun my-devcontainer-setup-compilation-buffer ()
  "Translate the container's paths in compiler messages to the host's.
For `compilation-mode-hook': the build runs in the container, so its
messages name /workspace/..., which `next-error' could not visit."
  (when-let* ((mappings (my-devcontainer-mappings)))
    (setq-local compilation-parse-errors-filename-function
                (lambda (file) (or (my-devcontainer--host-path file mappings) file)))))


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
