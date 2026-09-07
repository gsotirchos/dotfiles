;;; my-devcontainer.el --- Develop inside devcontainers over Tramp  -*- lexical-binding: t; -*-

;;; Commentary:

;; A devcontainer image carries the project's build environment -- its
;; compiler, its ROS underlay, its headers -- but none of the editor tooling.
;; VS Code deals with that by injecting a server into the container; this does
;; the same for Emacs, and then points Tramp at the result.
;;
;; Visiting `/docker:user@id:/workspace/...' gives eglot, Flymake and Apheleia
;; a container-side clangd, ruff, mypy and friends, with the paths clangd sees
;; in `compile_commands.json' and the paths Emacs shows in a buffer being one
;; and the same -- which is what makes `M-.' into /opt/ros work.
;;
;; Three things have to line up for that:
;;
;;   * A toolchain.  `my-devcontainer-provision' populates a prefix that is
;;     bind-mounted from the host (so it survives the container being
;;     recreated) by running `devcontainer-emacs-tools' inside the container.
;;     The scripts in `my-devcontainer-payload' are copied in alongside it,
;;     since Apheleia calls some formatters that live in the dotfiles.
;;
;;   * A path map.  Nothing may assume where the workspace is mounted: it is
;;     read back from `docker inspect', because devcontainer.json is free to
;;     mount any host directory anywhere (this workspace mounts the parent of
;;     the folder it was opened from).
;;
;;   * An environment.  Tramp's direct-async processes pass their environment
;;     on the command line, which PIPE_BUF caps at 4096 bytes, and a sourced
;;     ROS environment is around 12 KB.  So the environment is *not* pushed
;;     from here; the generated wrappers source a snapshot inside the
;;     container.  What is set connection-locally is only what Tramp needs to
;;     find those wrappers.
;;
;; Entry points are `my-devcontainer-find-file' and its inverse.  Because the
;; workspace is bind-mounted, the host copy of a file is the same file: hop
;; back out with `my-devcontainer-find-file-locally' for Magit, which is far
;; happier on a local directory than on a remote one.

;;; Code:

(require 'seq)
(require 'tramp)

(defvar eglot-workspace-configuration)
(declare-function eglot-current-server "eglot")
(declare-function eglot-signal-didChangeConfiguration "eglot" (server))
(declare-function eglot-reconnect "eglot" (server &optional interactive))

(defgroup my-devcontainer nil
  "Develop inside a devcontainer over Tramp."
  :group 'tools)

(defcustom my-devcontainer-executable "devcontainer"
  "Name or path of the devcontainer CLI."
  :type 'string)

(defcustom my-devcontainer-docker-executable "docker"
  "Name or path of the docker executable."
  :type 'string)

(defcustom my-devcontainer-tools-directory
  (expand-file-name "emacs-devcontainer" (or (getenv "XDG_CACHE_HOME") "~/.cache"))
  "Host directory holding the toolchains injected into containers.
Each workspace gets a subdirectory, which is bind-mounted at
`my-devcontainer-tools-mount-point'.  Workspaces that share an image can
safely be pointed at one subdirectory; workspaces on different images
cannot, because the tools are built against the image's libc and Python."
  :type 'directory)

(defcustom my-devcontainer-tools-mount-point "/opt/emacs-tools"
  "Where the toolchain is mounted inside the container."
  :type 'string)

(defcustom my-devcontainer-provisioner
  (expand-file-name "bin/devcontainer-emacs-tools"
                    (or (getenv "MACOS_DOTFILES") "~/.dotfiles"))
  "Script that installs the toolchain, run inside the container."
  :type 'file)

(defcustom my-devcontainer-payload
  (list (expand-file-name "bin/format-cmake"
                          (or (getenv "MACOS_DOTFILES") "~/.dotfiles"))
        (expand-file-name "bin/format-json"
                          (or (getenv "MACOS_DOTFILES") "~/.dotfiles")))
  "Host scripts to install into the container's toolchain prefix.
Apheleia invokes these by name, so they have to exist on the container
side too."
  :type '(repeat file))

(defvar my-devcontainer--cache (make-hash-table :test #'equal)
  "Container info, keyed by the local workspace folder.
Each value is a plist with :id, :user, :workspace and :mounts.")

(defvar my-devcontainer--environment (make-hash-table :test #'equal)
  "Container environments, keyed by container id.")


;;;; Talking to docker

(defmacro my-devcontainer--locally (&rest body)
  "Run BODY with `default-directory' on the local machine.
docker and the devcontainer CLI live on the host, but these helpers are
also called from buffers visiting a container, where `process-file' would
otherwise look for them inside it."
  (declare (indent 0) (debug t))
  `(let ((default-directory temporary-file-directory))
     ,@body))

(defun my-devcontainer--run (program &rest args)
  "Run PROGRAM with ARGS, returning trimmed stdout, or nil if it failed."
  (my-devcontainer--locally
   (with-temp-buffer
     (when (eq 0 (apply #'process-file program nil '(t nil) nil args))
       (let ((out (string-trim (buffer-string))))
         (unless (string-empty-p out) out))))))

(defun my-devcontainer--docker (&rest args)
  "Run docker with ARGS, returning trimmed stdout, or nil if it failed."
  (apply #'my-devcontainer--run my-devcontainer-docker-executable args))

(defun my-devcontainer--run-verbose (program &rest args)
  "Run PROGRAM with ARGS, returning a cons of its exit status and its output.
Unlike `my-devcontainer--run' this keeps stderr, so that a failure can
say what went wrong rather than only that it did."
  (my-devcontainer--locally
   (with-temp-buffer
     (let ((status (apply #'process-file program nil t nil args)))
       (cons status (string-trim (buffer-string)))))))

(defun my-devcontainer--json (string)
  "Parse STRING as JSON, or return nil if it is not."
  (ignore-errors
    (json-parse-string string :object-type 'alist :array-type 'list)))

(defun my-devcontainer--mounts (id)
  "Return the bind mounts of container ID as an alist of (HOST . CONTAINER).
Sorted with the deepest host path first, so that the first match found
when translating a file name is the most specific one."
  (when-let* ((json (my-devcontainer--docker
                     "inspect" "--format" "{{json .Mounts}}" id))
              (mounts (my-devcontainer--json json)))
    (sort (mapcar (lambda (mount)
                    (cons (directory-file-name (alist-get 'Source mount ""))
                          (directory-file-name (alist-get 'Destination mount ""))))
                  mounts)
          (lambda (a b) (> (length (car a)) (length (car b)))))))


;;;; Finding and starting the container

(defun my-devcontainer--config-p (dir)
  "Return non-nil if DIR holds a devcontainer configuration."
  (or (file-exists-p (expand-file-name ".devcontainer/devcontainer.json" dir))
      (file-exists-p (expand-file-name ".devcontainer.json" dir))))

(defun my-devcontainer-folder (&optional dir)
  "Return the workspace folder of the devcontainer governing DIR, or nil."
  (let ((dir (or dir default-directory)))
    (and (not (file-remote-p dir))
         (when-let* ((root (locate-dominating-file dir #'my-devcontainer--config-p)))
           (directory-file-name (file-truename root))))))

(defun my-devcontainer-tools-directory (folder)
  "Return the host directory holding the toolchain for FOLDER."
  (expand-file-name (md5 folder) my-devcontainer-tools-directory))

(defun my-devcontainer--running (folder)
  "Return the id of the running container for FOLDER, or nil.
Both this package and VS Code label containers with the folder they were
started from, so a container either editor started is picked up."
  (my-devcontainer--docker
   "ps" "-q" "--no-trunc"
   "--filter" (format "label=devcontainer.local_folder=%s" folder)))

(defun my-devcontainer--mounted-p (id)
  "Return non-nil if container ID has the toolchain prefix mounted."
  (seq-find (lambda (mount)
              (equal (cdr mount)
                     (directory-file-name my-devcontainer-tools-mount-point)))
            (my-devcontainer--mounts id)))

(defun my-devcontainer--up (folder &optional recreate)
  "Start the devcontainer for FOLDER and return the CLI's parsed result.
With RECREATE, replace any existing container -- needed when it was
created without the toolchain mount, as one started by VS Code will be."
  (let ((tools (my-devcontainer-tools-directory folder)))
    (make-directory tools t)
    (message "my-devcontainer: bringing up %s..." (file-name-nondirectory folder))
    (my-devcontainer--locally
     (with-temp-buffer
       (let ((status (apply #'process-file my-devcontainer-executable nil '(t nil) nil
                            `("up" "--workspace-folder" ,folder
                              "--mount" ,(format "type=bind,source=%s,target=%s"
                                                 tools my-devcontainer-tools-mount-point)
                              ,@(when recreate '("--remove-existing-container"))))))
         ;; The CLI logs progress and prints one JSON object as its last line.
         (goto-char (point-max))
         (forward-line -1)
         (let ((result (my-devcontainer--json
                        (buffer-substring-no-properties (point) (point-max)))))
           (unless (and (eq status 0) result)
             (error "my-devcontainer: `devcontainer up' failed: %s"
                    (string-trim (buffer-string))))
           result))))))


;;;; The environment inside the container

(defun my-devcontainer--dump-environment (id user)
  "Return the environment of container ID as a list of \"NAME=VALUE\".
Probed with a login *interactive* shell because images conventionally
append their setup to ~/.bashrc, after the guard that returns early for
non-interactive shells; this is the same probe the devcontainer spec
performs for its default userEnvProbe."
  (when-let* ((dump (my-devcontainer--docker
                     "exec" "-u" user id "bash" "-lic" "env -0")))
    (split-string dump "\0" t)))

(defun my-devcontainer-environment (id user)
  "Return the cached environment of container ID as a list of \"NAME=VALUE\"."
  (or (gethash id my-devcontainer--environment)
      (when-let* ((vars (my-devcontainer--dump-environment id user)))
        (puthash id vars my-devcontainer--environment))))

(defvar my-devcontainer--interpreter (make-hash-table :test #'equal)
  "Container Python interpreters, keyed by container id.")

(defun my-devcontainer-python-interpreter (id user)
  "Return the Python interpreter of container ID, or nil if it has none.
This is the image's own interpreter, not the toolchain's: pyright has to
analyse against the Python that owns the container's site-packages."
  (or (gethash id my-devcontainer--interpreter)
      (when-let* ((python (my-devcontainer--docker
                           "exec" "-u" user id "bash" "-lic" "command -v python3")))
        (puthash id python my-devcontainer--interpreter))))

(defun my-devcontainer--value (vars name)
  "Return the value of NAME in VARS, a list of \"NAME=VALUE\"."
  (let ((prefix (concat name "=")))
    (when-let* ((entry (seq-find (lambda (var) (string-prefix-p prefix var)) vars)))
      (substring entry (length prefix)))))


;;;; Wiring Tramp up to the container

(defun my-devcontainer-host (info)
  "Return the Tramp host part for the container described by INFO."
  (format "%s@%s" (plist-get info :user) (plist-get info :id)))

(defun my-devcontainer-prefix (info)
  "Return the Tramp file name prefix for the container described by INFO."
  (format "/docker:%s:" (my-devcontainer-host info)))

(defun my-devcontainer--apply-connection-local (info)
  "Teach Tramp how to run processes in the container described by INFO.
Only the search path is set here.  The environment is deliberately left
alone: direct-async processes carry it on the command line, where a ROS
environment does not fit, so the generated wrappers restore it inside the
container instead."
  (let ((profile (intern (format "my-devcontainer-%s"
                                 (substring (plist-get info :id) 0 12))))
        (bin (concat (directory-file-name my-devcontainer-tools-mount-point) "/bin")))
    (connection-local-set-profile-variables
     profile
     `((tramp-direct-async-process . t)
       (tramp-remote-path . ,(cons bin (default-value 'tramp-remote-path)))))
    (connection-local-set-profiles
     `(:application tramp
                    :protocol "docker"
                    :user ,(plist-get info :user)
                    :machine ,(plist-get info :id))
     profile)))


;;;; Provisioning

(defun my-devcontainer-provision (info &optional force)
  "Install the editing toolchain into the container described by INFO.
With FORCE, reinstall even when the prefix is already current.  The
prefix is bind-mounted, so the scripts are copied into it on the host
side and only the install itself runs in the container."
  (let* ((tools (my-devcontainer-tools-directory (plist-get info :folder)))
         (payload (expand-file-name "payload" tools))
         (script (expand-file-name (file-name-nondirectory my-devcontainer-provisioner)
                                   tools)))
    (make-directory payload t)
    (copy-file my-devcontainer-provisioner script t)
    (set-file-modes script #o755)
    (dolist (file my-devcontainer-payload)
      (if (not (file-exists-p file))
          (message "my-devcontainer: payload script %s is missing" file)
        (let ((target (expand-file-name (file-name-nondirectory file) payload)))
          (copy-file file target t)
          (set-file-modes target #o755))))
    (message "my-devcontainer: provisioning the toolchain...")
    (let ((result (apply #'my-devcontainer--run-verbose
                         my-devcontainer-docker-executable
                         `("exec" "-u" ,(plist-get info :user) ,(plist-get info :id)
                           ,(format "%s/%s"
                                    (directory-file-name my-devcontainer-tools-mount-point)
                                    (file-name-nondirectory my-devcontainer-provisioner))
                           ,@(when force '("--force"))))))
      (unless (eq 0 (car result))
        (error "my-devcontainer: provisioning failed: %s"
               (car (last (split-string (cdr result) "\n" t))))))))


;;;; Connecting

(defun my-devcontainer-connect (&optional dir recreate)
  "Return the container serving DIR, starting and provisioning it as needed.
The result is a plist with :id, :user, :workspace, :folder and :mounts.
With RECREATE, replace an existing container first."
  (let* ((folder (or (my-devcontainer-folder dir)
                     (user-error "my-devcontainer: no .devcontainer above %s"
                                 (abbreviate-file-name (or dir default-directory)))))
         (cached (and (not recreate) (gethash folder my-devcontainer--cache))))
    (if (and cached (equal (plist-get cached :id)
                           (my-devcontainer--running folder)))
        cached
      (let* ((running (and (not recreate) (my-devcontainer--running folder)))
             (info
              (if (and running (my-devcontainer--mounted-p running))
                  (list :id running
                        :user (or (my-devcontainer--docker
                                   "inspect" "--format" "{{.Config.User}}" running)
                                  "root")
                        :workspace nil)
                (let ((result (my-devcontainer--up folder recreate)))
                  (list :id (alist-get 'containerId result)
                        :user (alist-get 'remoteUser result)
                        :workspace (alist-get 'remoteWorkspaceFolder result))))))
        (setq info (plist-put info :folder folder))
        (unless (my-devcontainer--mounted-p (plist-get info :id))
          (user-error (concat "my-devcontainer: this container has no toolchain mount"
                              " (it predates Emacs, or was started by VS Code);"
                              " re-run with a prefix argument to recreate it")))
        (setq info (plist-put info :mounts (my-devcontainer--mounts (plist-get info :id))))
        (my-devcontainer-provision info)
        (my-devcontainer--apply-connection-local info)
        (puthash folder info my-devcontainer--cache)
        info))))


;;;; Translating file names

(defun my-devcontainer-remote-file-name (file &optional info)
  "Return the container-side Tramp file name for local FILE.
INFO defaults to the container serving FILE."
  (let* ((info (or info (my-devcontainer-connect (file-name-directory file))))
         (file (expand-file-name file))
         (mount (seq-find (lambda (mount)
                            (or (equal file (car mount))
                                (string-prefix-p (file-name-as-directory (car mount)) file)))
                          (plist-get info :mounts))))
    (unless mount
      (user-error "my-devcontainer: %s is not mounted into the container"
                  (abbreviate-file-name file)))
    (concat (my-devcontainer-prefix info)
            (cdr mount)
            (substring file (length (car mount))))))

(defun my-devcontainer-local-file-name (file)
  "Return the host file name for container-side FILE, or nil if there is none."
  (when-let* ((id (file-remote-p file 'host))
              (path (file-remote-p file 'localname))
              (mount (seq-find
                      (lambda (mount)
                        (or (equal path (cdr mount))
                            (string-prefix-p (file-name-as-directory (cdr mount)) path)))
                      ;; `my-devcontainer--mounts' orders by host path; going
                      ;; this way the most specific container path wins.
                      (sort (my-devcontainer--mounts id)
                            (lambda (a b) (> (length (cdr a)) (length (cdr b))))))))
    (concat (car mount) (substring path (length (cdr mount))))))

;;;###autoload
(defun my-devcontainer-find-file (&optional recreate)
  "Visit the container's copy of the current file or directory.
With a prefix argument RECREATE, replace the existing container first --
use this when it was started by VS Code and so lacks the toolchain mount."
  (interactive "P")
  (let* ((file (or (buffer-file-name) default-directory))
         (info (my-devcontainer-connect (file-name-directory file) recreate))
         (remote (my-devcontainer-remote-file-name file info)))
    (find-file remote)
    (when (buffer-file-name)
      (message "my-devcontainer: %s" (abbreviate-file-name remote)))))

;;;###autoload
(defun my-devcontainer-find-file-locally ()
  "Visit the host's copy of the current container-side file or directory.
The workspace is bind-mounted, so this is the same file -- useful for
Magit and project-wide search, which are much faster on a local tree."
  (interactive)
  (let ((local (my-devcontainer-local-file-name
                (or (buffer-file-name) default-directory))))
    (unless local
      (user-error "my-devcontainer: this file is not bind-mounted from the host"))
    (find-file local)))


;;;; Python

;;;###autoload
(defun my-devcontainer-python-setup ()
  "Point the Python tooling of a container buffer at the container.
Meant for `python-base-mode-hook', where it has to run before
`eglot-ensure' so that the language server is told about the environment
on connection.  Pyright resolves imports through the interpreter and its
own extraPaths only; it never reads PYTHONPATH."
  (when-let* (((file-remote-p default-directory))
              (id (file-remote-p default-directory 'host))
              (user (or (file-remote-p default-directory 'user) "root"))
              (vars (my-devcontainer-environment id user))
              (prefix (file-remote-p default-directory))
              (python (my-devcontainer-python-interpreter id user)))
    (setq-local python-shell-interpreter python)
    (setq-local eglot-workspace-configuration
                `(:python
                  (:pythonPath
                   ,python
                   :analysis
                   (:extraPaths
                    ,(vconcat
                      (seq-filter
                       (lambda (path)
                         (file-directory-p (concat prefix path)))
                       (split-string (or (my-devcontainer--value vars "PYTHONPATH") "")
                                     path-separator t)))))))
    (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
      (eglot-signal-didChangeConfiguration server))))


;;;; Refreshing

;;;###autoload
(defun my-devcontainer-refresh ()
  "Re-read the container's environment and reconnect its language server.
Use this after a build has extended AMENT_PREFIX_PATH or PYTHONPATH: the
snapshot the container's tool wrappers source is a snapshot, and does not
follow along on its own."
  (interactive)
  ;; Take the container from the buffer rather than resolving the workspace
  ;; folder again: a repository whose .devcontainer is also linked from an
  ;; enclosing workspace resolves to two different folders depending on where
  ;; the search starts, and the second one would start a second container.
  (let ((info (if (file-remote-p default-directory)
                  (list :id (file-remote-p default-directory 'host)
                        :user (or (file-remote-p default-directory 'user) "root"))
                (my-devcontainer-connect))))
    (remhash (plist-get info :id) my-devcontainer--environment)
    (remhash (plist-get info :id) my-devcontainer--interpreter)
    (my-devcontainer--docker
     "exec" "-u" (plist-get info :user) (plist-get info :id)
     (format "%s/%s" (directory-file-name my-devcontainer-tools-mount-point)
             (file-name-nondirectory my-devcontainer-provisioner))
     "env")
    (when (derived-mode-p 'python-base-mode)
      (my-devcontainer-python-setup))
    (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
      (eglot-reconnect server))
    (message "my-devcontainer: refreshed %s" (plist-get info :id))))

(provide 'my-devcontainer)
;;; my-devcontainer.el ends here
