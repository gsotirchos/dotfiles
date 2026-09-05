;;; package --- init -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(use-package emacs
  :ensure nil
  :preface
  (defconst fixed-pitch-line-spacing 4)
  (defconst variable-pitch-line-spacing 4)
  (defconst dotfiles-dir (or (getenv "MACOS_DOTFILES") "~/.dotfiles"))

  (defvar my/scale-factor 1.75
    "Global scale factor for images and LaTeX overlays.")

  (defun my/prevent-in-home-dir-advice (fn &rest args)
    "Prevent running the advised function in the home directory."
    (let* ((current-dir (file-truename default-directory))
           (home-dir (file-truename (expand-file-name "~/"))))
      (if (equal current-dir home-dir)
          (message "%s was prevented from running in the home directory." fn)
        (apply fn args))))

  (defun my/silence-advice (fn &rest args)
    "Silence the advised function's execution."
    (let ((message-log-max nil)
          (inhibit-message t))
      (apply fn args)))

  (defun my/read-envvar-from-file (envvar file)
    "Read the value of ENVVAR from FILE. Assumes the format: export ENVVAR=\"value\""
    (with-temp-buffer
      (insert-file-contents (expand-file-name file))
      (goto-char (point-min))
      (if (re-search-forward (format "^export %s=\"\\([^\"]+\\)\"" envvar) nil t)
          (match-string 1)
        (user-error "Variable %s not found in %s" envvar file))))

  (defvar my/1password-secret-cache (make-hash-table :test 'equal)
    "Cache for 1Password secrets to avoid multiple prompts.")

  (defun my/read-1password-secret (path)
    "Read the value of a secret from 1Password using PATH.
PATH should be in the format `op://Vault/Item/Field'."
    (let ((cached (gethash path my/1password-secret-cache)))
      (if cached
          cached
        (let ((secret (string-trim (shell-command-to-string (format "op read --account my.1password.eu \"op://Private/%s/credential\" --no-newline" path)))))
          (if (string-match-p "^\\[ERROR\\]" secret)
              (user-error "1Password error: %s" secret)
            (puthash path secret my/1password-secret-cache)
            secret)))))

  ;; Reindent by default instead of collapsing into one-line
  (defun my/reindent-or-fill-paragraph (&optional justify)
    "Fill the comment at point, otherwise reindent the enclosing defun.
Return t so `fill-paragraph' treats the paragraph as handled."
    (if (nth 4 (syntax-ppss))
        (fill-paragraph justify)
      (save-excursion
        (let* ((orig (point))
               (end (progn (goto-char orig) (end-of-defun) (point)))
               (start (progn (goto-char orig) (beginning-of-defun) (point))))
          (indent-region start end))))
    t)
  (setq-default fill-paragraph-function #'my/reindent-or-fill-paragraph)

  ;; Indentation utilities
  (defun my/set-local-indent-width (width)
    "Set the buffer-local indentation step to WIDTH."
    (setq-local standard-indent width
                tab-width width
                evil-shift-width width
                visual-wrap-extra-indent width))

  ;; List manipulation utilities
  (defun my/update-plist-property (plist property fn)
    "Update the PLIST's PROPERTY's value using FN."
    (let* ((current-value (plist-get plist property))
           (new-value (funcall fn current-value)))
      (plist-put plist property new-value)))

  (defun my/update-overlay-property-cdr (overlay property fn)
    "Update the OVERLAY's PROPERTY's value's cdr using FN."
    (let* ((current-value (overlay-get overlay property))
           (current-car (car current-value))
           (current-cdr (cdr current-value))
           (new-cdr (funcall fn current-cdr))
           (new-value (cons current-car new-cdr)))
      (overlay-put overlay property new-value)))

  ;; Overlay manipulation utilities
  (defun my/text-scale-overlays (category-type category-name scale)
    (dolist (overlay (overlays-in (point-min) (point-max)))
      (let ((overlay-category (overlay-get overlay category-type)))
        (when (and overlay-category
                   (eq overlay-category category-name))
          ;; (overlay-put overlay 'display
          ;;              (cons 'image (plist-put (cdr (overlay-get overlay 'display))
          ;;                                      :scale scale)))
          (let ((scale_fn (lambda (_) scale)))
            (my/update-overlay-property-cdr
             overlay
             'display
             (lambda (value-cdr-plist)
               (my/update-plist-property
                value-cdr-plist
                :scale
                scale_fn))))))))

  (defun my/text-scale-adjust-latex-previews (&rest _)
    "Adjust the size of latex fragments when changing the buffer's text scale."
    (let ((scale (expt text-scale-mode-step text-scale-mode-amount)))
      (my/text-scale-overlays 'category 'preview-overlay scale)
      (my/text-scale-overlays 'org-overlay-type 'org-latex-overlay scale)))

  (defun my/delete-latex-preview-overlays (&rest _)
    "Delete only LaTeX preview overlays in the current buffer."
    (dolist (overlay (overlays-in (point-min) (point-max)))
      (let ((category (overlay-get overlay 'category))
            (org-type (overlay-get overlay 'org-overlay-type)))
        (when (or (eq category 'preview-overlay)
                  (eq org-type 'org-latex-overlay))
          (delete-overlay overlay)))))

  ;; Hook management utilities
  (defun my/run-other-buffers-local-hooks (hook)
    "Run local HOOK in all buffers except the current one."
    (interactive "aHook: ")
    (dolist (buffer (buffer-list))
      (unless (eq buffer (current-buffer))
        (with-current-buffer buffer
          (my/run-local-hooks hook)))))

  (defun my/run-local-hooks (hook)
    "Run only the buffer-local functions of HOOK."
    (interactive "aHook: ")
    (when (local-variable-p hook)
      (dolist (func (symbol-value hook))
        (when (functionp func)
          (funcall func)))))

  ;; Carrier for the per-buffer face customizations; `enable-theme-functions'
  ;; is global, so buffer-local entries are dispatched from the one hook below.
  (defvar after-load-theme-hook nil
    "Hook that runs after a color theme is enabled.")

  (defun my/run-after-load-theme-hook (theme &rest _)
    "Run `after-load-theme-hook' once THEME is enabled.
Skips the `user' pseudo-theme, which `load-theme' enables alongside the
real one and which would otherwise run every hook twice."
    (unless (eq theme 'user)
      (run-hooks 'after-load-theme-hook)))

  (add-hook 'after-load-theme-hook
            (lambda () (my/run-other-buffers-local-hooks 'after-load-theme-hook)))

  (add-hook 'enable-theme-functions #'my/run-after-load-theme-hook)

  (defun my/theme-color (name)
    "Return the color NAME resolves to in the active theme's palette, or nil.
Returns nil rather than `unspecified', so callers can guard with `when-let*'."
    (and (fboundp 'modus-themes-get-color-value)
         ;; Non-nil OVERRIDES, so `modus-themes-common-palette-overrides' and
         ;; `modus-vivendi-palette-overrides' are honoured everywhere.
         (let ((value (modus-themes-get-color-value name t)))
           (and (stringp value) value))))

  ;; Variable pitch
  (defun my/set-line-spacing-advice (&rest _)
    "Set `line-spacing' after the advised function is executed."
    (if (and (bound-and-true-p buffer-face-mode)
             (equal buffer-face-mode-face 'variable-pitch))
        (when (boundp 'variable-pitch-line-spacing)
          (setq-local line-spacing variable-pitch-line-spacing))
      (when (boundp 'fixed-pitch-line-spacing)
        (setq-local line-spacing fixed-pitch-line-spacing))))

  (advice-add 'variable-pitch-mode :after #'my/set-line-spacing-advice)

  (defun my/fixed-pitch-mode ()
    (variable-pitch-mode -1))

  (add-hook 'Custom-mode-hook #'variable-pitch-mode)
  (add-hook 'Info-mode-hook #'variable-pitch-mode)
  (add-hook 'org-mode-hook #'variable-pitch-mode)
  (add-hook 'markdown-view-mode-hook #'variable-pitch-mode)
  (add-hook 'gfm-view-mode-hook #'variable-pitch-mode)
  ;; (add-hook 'text-mode-hook #'variable-pitch-mode)
  ;; (add-hook 'LaTeX-mode-hook #'my/fixed-pitch-mode)

  ;; Pad the echo area and command entry minibuffer to avoid rounded corner obstruction
  (defface my/echo-area-default-face nil
    "Remapped default face for echo area text."
    :group 'faces)
  (dolist (buf '(" *Echo Area 0*" " *Echo Area 1*"))
    (with-current-buffer (get-buffer-create buf)
      (when (eq system-type 'darwin)
        (setq-local line-prefix " "))
      (face-remap-add-relative 'default 'my/echo-area-default-face)))

  (defun my/customize-echo-area-face ()
    "Color echo area text with the theme's dimmed foreground."
    (when-let* ((fg (my/theme-color 'fg-dim)))
      (set-face-attribute 'my/echo-area-default-face nil :foreground fg)))
  (add-hook 'after-load-theme-hook #'my/customize-echo-area-face)

  (defun my/customize-special-glyphs ()
    "Dim the truncation and continuation glyphs so they read as marks, not text."
    (when-let* ((fg (my/theme-color 'fg-dim)))
      (set-face-attribute 'special-glyphs nil :foreground fg)))
  (add-hook 'after-load-theme-hook #'my/customize-special-glyphs)

  (when (eq system-type 'darwin)
    (defun my/pad-minibuffer-prompt ()
      "Add a prefix to the minibuffer prompt to prevent rounded corner obstruction."
      (let ((inhibit-read-only t))
        (put-text-property (point-min) (minibuffer-prompt-end) 'line-prefix " ")
        (put-text-property (point-min) (minibuffer-prompt-end) 'wrap-prefix " ")))
    (add-hook 'minibuffer-setup-hook #'my/pad-minibuffer-prompt))

  ;; Suppress blank tooltips
  (defun my-suppress-blank-tooltips (str &rest _)
    "Suppress tooltips with nil, empty, or all-whitespace STR."
    (or (null str) (string-blank-p (string-trim str))))

  (advice-add #'x-show-tip :before-until #'my-suppress-blank-tooltips)

  ;; Startup time
  (defun my/display-startup-stats ()
    "Display startup stats."
    (message "%d packages loaded in %.2fs (init time: %.2fs) with %d garbage collections."
             (length package-activated-list)
             (float-time (time-since before-init-time))
             (float-time (time-subtract after-init-time before-init-time))
             gcs-done))

  ;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Startup-Summary.html
  (add-hook 'window-setup-hook #'my/display-startup-stats 99)

  :custom
  (initial-scratch-message nil)
  (initial-major-mode 'fundamental-mode)
  (fill-column most-positive-fixnum)
  (column-number-mode t)
  (use-dialog-box nil)
  (auto-save-default nil)
  (auto-save-visited-interval 1)
  (auto-save-visited-mode t)
  (make-backup-files nil)
  (set-mark-command-repeat-pop t)
  (large-file-warning-threshold nil)
  (custom-safe-themes t)
  (enable-local-variables :all)
  ;; (enable-local-eval t)
  ;; (package-check-signature nil)
  (vc-follow-symlinks t)
  (browse-url-mailto-function 'browse-url-default-browser)
  (ad-redefinition-action 'accept)
  (use-short-answers t)
  (confirm-kill-emacs #'yes-or-no-p)
  (global-completion-preview-mode t)
  (sentence-end-double-space nil)
  (scroll-margin 0)
  (hscroll-margin 0)
  (scroll-step 1)
  (hscroll-step 1)
  (scroll-bar-mode (if (eq system-type 'darwin) nil 'right))
  ;; (underline-minimum-offset 2)
  (text-scale-mode-step 1.1)
  (global-text-scale-adjust-resizes-frames t)
  (line-spacing fixed-pitch-line-spacing)
  (truncate-lines nil)
  (wrap-prefix (propertize "…" 'face 'special-glyphs))
  (cursor-in-non-selected-windows nil)
  (left-margin-width 0)
  (right-margin-width 0)
  (indent-tabs-mode nil)
  (tab-always-indent 'complete)
  (treemacs-no-png-images t)
  (delete-by-moving-to-trash t)
  (treesit-enabled-modes t)

  :init
  (context-menu-mode 1)
  (pixel-scroll-precision-mode 1)
  ;; Display table for wrap prefix
  (set-display-table-slot standard-display-table 'wrap (string-to-char wrap-prefix))
  (set-display-table-slot standard-display-table 0 (string-to-char wrap-prefix))
  ;; Keeps the glyphs set above and applies `special-glyphs' to them.
  (prettify-special-glyphs-mode 1))


;; Basic packages

(use-package no-littering
  :demand t
  :config
  (setq custom-file (no-littering-expand-var-file-name "custom.el"))
  (let ((dir (no-littering-expand-var-file-name "lock-files/")))
    (make-directory dir t)
    (setq lock-file-name-transforms `((".*" ,dir t))))
  (when (file-exists-p custom-file)
    (load custom-file t)))

(use-package autorevert
  :after no-littering
  :ensure nil
  :no-require t
  :defer 1
  :custom
  (global-auto-revert-non-file-buffers t)
  (auto-revert-remote-files t)
  ;; (auto-revert-verbose nil)
  :config (global-auto-revert-mode 1))

(use-package saveplace
  :after no-littering
  :ensure nil
  :no-require t
  :defer 1
  :preface (advice-add 'find-file-noselect :before (lambda (&rest _) (save-place-mode 1)))
  :config (save-place-mode 1))

(use-package savehist
  :after no-littering
  :ensure nil
  :no-require t
  :defer 1
  :custom
  (history-length 100)
  (savehist-autosave-interval 30)
  (savehist-save-minibuffer-history t)
  (history-delete-duplicates t)
  (savehist-additional-variables
   '(kill-ring
     search-ring
     regexp-search-ring))
  :preface
  (advice-add 'completing-read :before (lambda (&rest _) (unless savehist-mode (savehist-mode 1))))
  (advice-add 'previous-history-element :before (lambda (&rest _) (unless savehist-mode (savehist-mode 1))))
  :config (savehist-mode 1))

(use-package recentf
  :after no-littering
  :ensure nil
  :no-require t
  :defer 1
  :custom (recentf-auto-cleanup 'never)
  :config
  (advice-add 'recentf-load-list :around #'my/silence-advice)
  (recentf-mode 1)
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory)))

(use-package comint
  :ensure nil
  :no-require t
  :custom (comint-buffer-maximum-size (* 1 1024))
  :config
  ;; (add-to-list 'completion-at-point-functions #'comint-dynamic-complete-filename)
  (add-to-list 'comint-output-filter-functions #'comint-truncate-buffer))

(use-package desktop
  :ensure nil
  :commands (desktop-save desktop-revert)
  :init
  ;; Frame parameters to ignore when saving/loading desktop sessions
  (dolist (filter
           '(foreground-color
             background-color
             font
             cursor-color
             background-mode
             ns-appearance))
    (add-to-list 'frameset-filter-alist (cons filter :never)))
  :config (desktop-save-mode 1))

(use-package project
  :ensure nil
  :no-require t
  :preface
  (defvar project-vc-ignores)
  (defun my/project-query-replace-ignore-binaries (orig-fun &rest args)
    "Temporarily ignore binary files during project-wide query-replace."
    (let ((project-vc-ignores
           (append '("*.png" "*.pdf" "*.jpg" "*.jpeg" "*.gif" "*.zip" "*.gz" "*.tar" "*.mp4")
                   project-vc-ignores)))
      (apply orig-fun args)))
  :config
  ;; Prevent file-loop and query-replace crashes by filtering out directories
  (advice-add 'project-files :filter-return
              (lambda (files)
                (seq-filter (lambda (f) (not (file-directory-p f))) files)))

  ;; Ignore binaries ONLY during query-replace (so they stay findable in C-x p f)
  (advice-add 'project-query-replace-regexp :around #'my/project-query-replace-ignore-binaries))

(use-package xref
  :ensure nil
  :no-require t
  :custom (xref-search-program 'ripgrep))

(use-package isearch
  :ensure nil
  :no-require t
  :preface
  (defun my/isearch-filter-opened-overlays (&rest _)
    "Remove deleted overlays from `isearch-opened-overlays'."
    (setq isearch-opened-overlays
          (seq-filter #'overlay-buffer isearch-opened-overlays)))
  (defun my/isearch-open-necessary-overlays-advice (orig-fun ov &rest args)
    "Only call ORIG-FUN if OV is a valid, live overlay."
    (when (overlay-buffer ov)
      (apply orig-fun ov args)))
  :config
  ;; Prevent query-replace and isearch clean-up errors when overlays
  ;; are deleted or buffer is killed.
  (advice-add 'isearch-clean-overlays :before #'my/isearch-filter-opened-overlays)
  (advice-add 'isearch-close-unnecessary-overlays :before #'my/isearch-filter-opened-overlays)
  (advice-add 'isearch-open-necessary-overlays :around #'my/isearch-open-necessary-overlays-advice))

(use-package uniquify
  :ensure nil
  :no-require t
  :custom
  (uniquify-buffer-name-style 'forward)
  (uniquify-separator "/")
  (uniquify-after-kill-buffer-p t)
  (uniquify-ignore-buffers-re "^\\*"))

(use-package repeat
  :ensure nil
  :hook (after-init . repeat-mode)
  :custom
  (repeat-too-dangerous '(kill-this-buffer))
  (repeat-exit-timeout 5))

(use-package two-column
  :ensure nil
  :no-require t
  :custom (2C-mode-line-format '(:eval (default-value 'mode-line-format))))

(use-package my-mode-line
  :ensure nil
  :load-path "site-lisp/"
  :hook (after-init . my-mode-line-setup)
  :custom
  (mode-line-modes-delimiters nil)
  (mode-line-collapse-minor-modes '(not flymake-mode)))

(use-package my-theme-switcher
  :ensure nil
  :load-path "site-lisp/"
  :hook after-init)

(use-package my-margin
  :ensure nil
  :load-path "site-lisp/"
  :hook after-init)

(unless (eq system-type 'darwin)
  (use-package my-auto-scroll-bar
    :ensure nil
    :load-path "site-lisp/"
    :hook after-init))

(use-package my-modifier-remap
  :ensure nil
  :load-path "site-lisp/"
  :when (eq system-type 'gnu/linux)
  :demand t
  :custom (my-modifier-remap-alist '((super . meta) (meta . alt)))
  :config (my-modifier-remap-mode 1))

(use-package my-keybindings
  :ensure nil
  :load-path "site-lisp/"
  :demand t
  :config (my-keybindings-mode 1))

(use-package modus-themes
  :demand t
  :after my-keybindings
  :bind
  (nil
   :map my/toggles-map
   ("t" . modus-themes-toggle)
   ("c" . my/modus-themes/cycle-ui-style))
  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-variable-pitch-ui t)
  (modus-themes-common-palette-overrides
   '((fringe unspecified)
     (bg-tab-bar bg-main)
     (bg-tab-current bg-mode-line-active)
     (bg-tab-other bg-mode-line-inactive)
     (fg-vertical-border bg-mode-line-inactive)
     (fg-heading-1 fg-main)
     (fg-heading-2 fg-main)
     (fg-heading-3 fg-main)
     (fg-heading-4 fg-main)
     (fg-heading-5 fg-main)
     (fg-heading-6 fg-main)
     (fg-heading-7 fg-main)
     (fg-heading-8 fg-main)
     (prose-done fg-dim)
     (prose-todo yellow-warmer)
     (comment green)
     (docstring green-faint)
     (string red-faint)
     (constant yellow)
     (keyword magenta-warmer)
     (builtin magenta-faint)
     (type magenta-cooler)
     (fnname blue-faint)
     (variable cyan)
     (bg-popup bg-main)))
  (modus-vivendi-palette-overrides
   '((bg-main "#1e1e1e")
     (bg-dim "#292929")
     (bg-inactive "#424242")
     (fg-vertical-border "#000000")))
  (modus-themes-headings
   '((1 . (1.06666))
     (2 . (1.06666))
     (3 . (1.06666))
     (4 . (1.0))
     (5 . (1.0))
     (6 . (1.0))
     (7 . (1.0))
     (8 . (1.0))))
  :preface
  (setq modus-themes-to-toggle '(modus-operandi modus-vivendi)))

(use-package my-modus-ui-styles
  :ensure nil
  :load-path "site-lisp/"
  :after modus-themes
  :demand t)

(use-package tab-bar
  :ensure nil
  :no-require t
  :custom
  (tab-bar-show (if (eq system-type 'darwin) t 1))
  (tab-bar-new-button-show nil)
  (tab-bar-close-button-show nil)
  (tab-bar-separator "")
  (tab-bar-auto-width nil)
  (tab-bar-truncate t)
  (tab-bar-format
   '(tab-bar-format-tabs
     tab-bar-separator
     tab-bar-format-align-right
     tab-bar-format-global))
  :preface
  (defun my/format-tab-spacing (string _ _)
    (concat "  " string "  "))
  :config
  (tab-bar-mode 1)
  (add-to-list 'tab-bar-tab-name-format-functions #'my/format-tab-spacing)
  (add-hook 'desktop-after-read-hook #'tab-bar-mode))

(use-package stripes
  :after (my-keybindings modus-themes)
  :demand t  ;; load at startup so the face is themed and my-stripes can build on it
  :hook dired-mode
  :bind (:map my/toggles-map ("s" . stripes-mode))
  :custom
  (stripes-unit 1)
  (stripes-overlay-priority -100)
  :preface
  (defun my/customize-stripes ()
    (when-let* ((bg (my/theme-color 'bg-dim)))
      (set-face-attribute 'stripes nil
                          :extend t  ;; fill candidate lines to the full width
                          :background bg)))
  (add-hook 'stripes-mode-hook #'my/customize-stripes)
  :config
  (my/customize-stripes)  ;; set the face now, not only on theme reload
  (add-hook 'after-load-theme-hook #'my/customize-stripes))

(use-package my-stripes
  :ensure nil
  :load-path "site-lisp/"
  :after (stripes corfu vertico)
  :demand t)

(use-package files
  :ensure nil
  :no-require t
  :preface
  (defun my/revert-buffer-quick-preserve (&optional auto-save)
    "Like `revert-buffer-quick', but preserves modes (accepts AUTO-SAVE)."
    (interactive "P")
    (revert-buffer auto-save (not (buffer-modified-p)) t))
  :bind (([remap revert-buffer-quick] . #'my/revert-buffer-quick-preserve))
  :custom (enable-remote-dir-locals t))

(use-package tramp
  :ensure nil
  :no-require t
  :custom
  (tramp-verbose 2)
  (tramp-use-connection-share nil)  ;; Let ~/.ssh/config handle it
  (vc-handled-backends '(Git))  ;; Limit VC to Git only
  :config
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (add-to-list 'tramp-remote-path "/snap/bin")
  (add-to-list 'tramp-remote-path "~/.local/bin"))

(use-package ls-lisp
  :ensure nil
  :demand t
  :custom
  (ls-lisp-use-insert-directory-program nil)
  (ls-lisp-ignore-case t)
  (ls-lisp-dirs-first t)
  (ls-lisp-use-string-collate nil))

(use-package dired
  :ensure nil
  :no-require t
  :bind
  (nil
   :map dired-mode-map
   ("M-<up>" . dired-up-directory)
   ("M-<down>" . dired-find-file)
   ([remap dired-view-file] . my/dired-find-file-other-frame))
  :custom
  (dired-listing-switches "-alF")
  (dired-omit-files "^\\.[^.].*")
  (dired-mouse-drag-files t)
  (dired-omit-verbose nil)
  (dired-dwim-target 'dired-dwim-target-next)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-kill-when-opening-new-dired-buffer t)
  :preface
  (defun my/dired-find-file-other-frame ()
    "Open the file under point in a new frame."
    (interactive)
    (find-file-other-frame (dired-get-file-for-visit)))
  (defun my/dired-mode-hook ()
    (dired-omit-mode 1)
    (dired-hide-details-mode 1)
    (hl-line-mode 1))
  (add-hook 'dired-mode-hook #'my/dired-mode-hook))

(use-package speedbar
  :ensure nil
  :no-require t
  :commands (speedbar)
  :custom
  (speedbar-prefer-window t)
  (speedbar-use-images nil)
  (speedbar-show-unknown-files t)
  (speedbar-directory-unshown-regexp "^\\'"))

(use-package eshell
  :ensure nil
  :no-require t
  :preface
  (cond
   ((executable-find "prmt")
    (defun my/eshell-custom-prompt ()
      (let* ((prmt-cmd "env TERM=xterm-256color prmt --code $? \"{path:cyan.bold} {git:magenta.bold}\n{ok:bold:>}{fail:red.bold:>} \"")
             (raw-string (shell-command-to-string prmt-cmd))
             (stripped-string (replace-regexp-in-string "[\x01\x02]" "" raw-string)))
        (ansi-color-apply stripped-string))))
   ((executable-find "starship")
    (defun my/eshell-custom-prompt ()
      (let* ((status (or (bound-and-true-p eshell-last-command-status) 0))
             (starship-cmd (format "env TERM=xterm-256color starship prompt --status %d" status)))
        (ansi-color-apply (shell-command-to-string starship-cmd))))))
  (when (fboundp 'my/eshell-custom-prompt)
    (setq eshell-prompt-function #'my/eshell-custom-prompt
          eshell-highlight-prompt nil
          eshell-prompt-regexp "^[^#$\n]* [#>❯(?:graph)] "))
  (defun my/eshell-mode-hook ()
    (setq-local pcomplete-termination-string ""))
  (add-hook 'eshell-mode-hook #'my/eshell-mode-hook))

(use-package evil
  :demand t
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-disable-insert-state-bindings t
        ;; evil-want-empty-ex-last-command nil
        evil-want-C-u-scroll t
        evil-toggle-key "C-<escape>"
        evil-cross-lines t
        evil-symbol-word-search t
        evil-undo-system 'undo-redo
        evil-mode-line-format nil)
  :config
  (evil-mode 1)
  (global-set-key [remap kill-ring-save] #'evil-yank)
  (global-set-key [remap my/quit-dwim] #'evil-quit)
  (global-set-key [remap my/delete-back-to-indentation] #'evil-delete-back-to-indentation)
  (global-set-key [remap backward-kill-word] #'evil-delete-backward-word)
  (global-set-key (kbd "M-v") #'yank)
  (evil-global-set-key 'insert (kbd "C-v") #'ignore)
  (evil-global-set-key 'normal (kbd "C-i") #'evil-jump-forward)
  (evil-global-set-key 'motion (kbd "j") #'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "k") #'evil-previous-visual-line)
  (evil-global-set-key 'motion (kbd "<down>") #'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "<up>") #'evil-previous-visual-line)
  (evil-global-set-key 'normal (kbd "<tab>") #'kirigami-toggle-fold)
  (evil-global-set-key 'normal (kbd "za") #'kirigami-toggle-fold)
  (evil-global-set-key 'normal (kbd "zo") #'kirigami-open-fold)
  (evil-global-set-key 'normal (kbd "zO") #'kirigami-open-fold-rec)
  (evil-global-set-key 'normal (kbd "zc") #'kirigami-close-fold)
  (evil-global-set-key 'normal (kbd "zm") #'my-fold-level-decrease)
  (evil-global-set-key 'normal (kbd "zr") #'my-fold-level-increase)
  (evil-global-set-key 'normal (kbd "zM") #'my-fold-level-close-all)
  (evil-global-set-key 'normal (kbd "zR") #'my-fold-level-open-all)
  (evil-global-set-key 'visual (kbd "p") #'evil-paste-before)
  (evil-global-set-key 'visual (kbd "P") #'evil-visual-paste)
  (define-key evil-command-line-map (kbd "C-a") nil)
  (define-key evil-command-line-map (kbd "C-b") nil)
  (define-key evil-command-line-map (kbd "C-d") nil)
  (define-key evil-command-line-map (kbd "C-f") nil)
  (define-key evil-command-line-map (kbd "C-l") nil))

(use-package evil-collection
  :after evil
  :demand t
  :config (evil-collection-init))

(use-package evil-surround
  :demand t
  :config (global-evil-surround-mode 1))

(use-package corfu
  :demand t
  :bind
  (nil
   :map corfu-map
   ;; ("RET" . nil)
   ("<return>" . corfu-complete)
   ("<tab>" . corfu-next)
   ("S-<tab>" . corfu-previous)
   ("<escape>" . corfu-reset)
   ("C-d" . corfu-scroll-up)
   ("C-u" . corfu-scroll-down)
   ("<next>" . corfu-scroll-up)
   ("<prior>" . corfu-scroll-down)
   ("S-SPC" . corfu-insert-separator))
  :preface
  (defun my/corfu-minibuffer-filter ()
    "Do not show Corfu in minibuffer for MCT, Vertico, or password prompts."
    (interactive)
    (not (or (bound-and-true-p mct--active)
             (bound-and-true-p vertico--input)
             (eq (current-local-map) read-passwd-map))))
  :custom
  (corfu-auto t)  ;; auto-completion
  (corfu-quit-no-match t)
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.2)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert)  ;; insert previewed candidate
  (corfu-on-exact-match nil)  ;; Don't auto expand tempel snippets
  (corfu-cycle t)
  (global-corfu-minibuffer 'my/corfu-minibuffer-filter)
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  (corfu-history-mode))

(use-package cape
  :init (add-to-list 'completion-at-point-functions #'cape-file))

(use-package tempel
  :after my-keybindings
  :bind
  (nil
   :map my/personal-map
   ("i" . tempel-insert)
   :map tempel-map
   ("<tab>" . tempel-next)
   ("S-<tab>" . tempel-previous))
  :preface
  (defun my/tempel-setup-capf ()
    "Put `tempel-expand' in front of the buffer's other completion sources.
Idempotent, since the hooks below can fire repeatedly in one buffer."
    (setq-local completion-at-point-functions
                (cons #'tempel-expand
                      (remq #'tempel-expand completion-at-point-functions))))
  ;; `eglot--managed-mode' prepends its own exclusive Capf after `prog-mode-hook'
  ;; has run, so the setup is repeated on its hook to stay ahead of it.
  :hook ((prog-mode text-mode conf-mode eglot-managed-mode) . my/tempel-setup-capf))

(use-package tempel-collection
  :after tempel)

;; Left disabled pending confirmation that it is safe: it was suspected of
;; causing the empty-prefix buffer wipe that `my/eglot-require-completion-prefix'
;; now guards against, but that reproduces without it.  Re-enable with
;; `M-x eglot-tempel-mode'.
(use-package eglot-tempel
  :after eglot
  :commands (eglot-tempel-mode))

(use-package dabbrev
  :ensure nil
  :no-require t
  :custom
  (dabbrev-check-all-buffers nil))

(use-package vertico
  :demand t
  :bind (:map vertico-map ("TAB" . minibuffer-complete))
  :custom
  (vertico-scroll-margin 1)
  (vertico-count 10)  ;; Limit to a fixed size
  (vertico-cycle t)  ;; Enable cycling for `vertico-next/previous'
  (vertico-resize 'grow-only)  ;; Grow and shrink the Vertico minibuffer
  :config
  (vertico-mode)
  (vertico-mouse-mode 1))

(use-package vertico-directory
  :after vertico
  :ensure nil  ;; comes with vertico
  :bind
  (nil
   :map
   vertico-map
   ("RET" . vertico-directory-enter)
   ("DEL" . vertico-directory-delete-char)))

(use-package marginalia
  :defer nil
  :bind (:map minibuffer-local-map ("M-a" . marginalia-cycle))
  :custom (marginalia-field-width 180)
  :preface
  (defun my/marginalia-mode-hook ()
    (when (facep 'marginalia-documentation)
      (set-face-attribute 'marginalia-documentation nil
                          :italic t :family nil :inherit 'variable-pitch)))
  (add-hook 'after-load-theme-hook #'my/marginalia-mode-hook)
  (defun my/marginalia-no-truncate (orig-fun string width)
    "Return STRING whole when WIDTH is relative, else defer to ORIG-FUN."
    (if (floatp width)
        (substring string 0 (string-search "\n" string))
      (funcall orig-fun string width)))
  :config
  (advice-add 'marginalia--truncate :around #'my/marginalia-no-truncate)
  (marginalia-mode)
  (my/marginalia-mode-hook))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles (partial-completion ((completion-pcm-leading-wildcard t)))))))
  (completion-category-defaults nil)) ;; Disable defaults, use our settings

(use-package consult
  :after (evil vertico)
  :bind
  (([remap Info-search] . consult-info)
   ([remap switch-to-buffer] . consult-buffer)
   ([remap project-switch-to-buffer] . consult-project-buffer)
   ([remap bookmark-jump] . consult-bookmark)
   ([remap recentf] . consult-recent-file)
   ([remap yank-pop] . consult-yank-pop)
   ([remap evil-paste-pop] . consult-yank-pop)
   ([remap goto-line] . consult-goto-line)
   ([remap imenu] . consult-imenu)
   ("C-x M-b" . consult-buffer-other-frame)
   ("M-g I" . consult-imenu-multi)
   ("M-g o" . consult-outline)
   ("M-g e" . consult-compile-error)
   ("M-s f" . consult-flymake)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   ("M-s g" . consult-ripgrep)
   ("M-s M-g" . consult-git-grep)
   ("M-s e" . consult-isearch-history)
   ("M-y" . consult-yank-pop)
   :map isearch-mode-map
   ([remap isearch-edit-string] . consult-isearch-history)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
   :map minibuffer-local-map
   ([remap isearch-forward] . consult-history)
   ([remap next-matching-history-element] . consult-history)
   ([remap previous-matching-history-element] . consult-history))
  :preface
  (advice-add 'consult-recent-file :before (lambda (&rest _) (recentf-mode 1)))
  (advice-add 'register-preview :override #'consult-register-window)
  :init
  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (setq register-preview-delay 0.5)
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; The configuration values are evaluated at runtime, just before the
  ;; completion session is started. Therefore you can use for example
  ;; `thing-at-point' to adjust the initial input or the future history.
  (consult-customize consult-line
                     :add-history (seq-some 'thing-at-point '(region symbol)))
  (defalias 'consult-line-thing-at-point 'consult-line)
  (consult-customize consult-line-thing-at-point
                     :initial (thing-at-point 'symbol))
  (add-to-list 'consult-preview-allowed-hooks #'visual-wrap-prefix-mode)
  (add-to-list 'consult-preview-allowed-hooks #'visual-line-mode)
  (add-to-list 'consult-preview-allowed-hooks #'variable-pitch-mode)
  ;; (add-to-list 'consult-preview-allowed-hooks #'my/fixed-pitch-mode)
  (add-to-list 'consult-preview-allowed-hooks #'my/csv-mode-hook)
  (add-to-list 'consult-preview-allowed-hooks #'my/pdf-view-mode-hook)
  (add-to-list 'consult-preview-allowed-hooks #'my/org-mode-hook))

(use-package embark
  :bind
  (nil
   :map help-map
   ("B" . embark-bindings)  ;; alternative for `describe-bindings'
   :map minibuffer-local-map
   ("C-." . embark-act)  ;; begin the embark process
   ("C-<return>" . embark-dwim))  ;; run the default action
  :custom (embark-quit-after-action nil)
  :init (setq prefix-help-command 'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult))

(use-package helpful
  :bind
  (([remap describe-function] . helpful-callable)
   ([remap describe-command] . helpful-command)
   ([remap describe-variable] . helpful-variable)
   ([remap describe-key] . helpful-key)
   ([remap describe-symbol] . helpful-symbol)
   ([remap help-follow-symbol] . helpful-at-point))
  :custom (warning-minimum-level :error))

(use-package which-key
  ;; :ensure nil
  :defer 1
  :custom (which-key-idle-delay 1)
  :config (which-key-mode))

(use-package eldoc-box
  :hook (prog-mode . eldoc-box-hover-at-point-mode))

(use-package diff-hl
  :custom
  (diff-hl-draw-borders nil)
  (diff-hl-margin-symbols-alist
   '((insert . "+") (delete . "-") (change . "~")
     (unknown . "?") (ignored . "i")))
  :hook (find-file . my/diff-hl-enable)
  :preface
  (defun my/diff-hl-enable ()
    "Enable diff-hl (margin display, live updates) in vc-tracked buffers."
    (when (and buffer-file-name (vc-registered buffer-file-name))
      (diff-hl-margin-mode 1)
      (diff-hl-flydiff-mode 1)
      (diff-hl-mode 1)))
  (defun my/diff-hl-faces (&rest _)
    "Make diff-hl faces follow the theme's diff faces."
    (pcase-dolist (`(,hl-face . ,diff-face)
                   '((diff-hl-change . diff-changed)
                     (diff-hl-insert . diff-added)
                     (diff-hl-delete . diff-removed)))
      (set-face-attribute hl-face nil
                          :inherit diff-face
                          :foreground 'unspecified
                          :background 'unspecified
                          :slant 'normal
                          :weight 'normal
                          :height 0.92)))
  :config
  (my/diff-hl-faces)
  (add-hook 'after-load-theme-hook #'my/diff-hl-faces)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(use-package ediff
  :ensure nil
  :no-require t
  :custom (ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package magit
  :bind
  (nil
   :map magit-mode-map
   ("M-n" . nil)
   ("M-w" . nil)
   :map magit-section-mode-map
   ("<tab>" . magit-section-toggle)
   ("C-<tab>" . nil))
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :preface
  (defun my/magit-mode-hook ()
    (setq-local truncate-lines nil)
    ;; Let `visual-wrap-prefix-mode' see the diff marker in the first column.
    (setq-local adaptive-fill-regexp "[-+ ]?[ \t]*"))
  (add-hook 'magit-mode-hook #'my/magit-mode-hook)
  :config
  (with-eval-after-load 'git-commit
    (remove-hook 'git-commit-setup-hook #'git-commit-setup-capf))
  (when (bound-and-true-p evil-mode)
    (evil-define-key 'normal magit-section-mode-map (kbd "C-<tab>") nil)))

(use-package git-commit
  :ensure nil
  :custom (git-commit-summary-max-length 50)
  :preface
  (defconst my/git-commit-filename-regexp "\\(MSG\\|_DESCRIPTION\\)\\'"
    "Cheap superset of `git-commit-filename-regexp'.
Matching it only decides whether pulling in `git-commit' is worthwhile;
that library's own regexp still decides whether the buffer really is a
commit message.")
  (defun my/git-commit-load-on-demand ()
    "Load `git-commit' when a commit message file is visited."
    (when (and buffer-file-name
               (not (featurep 'git-commit))
               (string-match-p my/git-commit-filename-regexp buffer-file-name))
      (remove-hook 'find-file-hook #'my/git-commit-load-on-demand)
      (require 'git-commit)
      (unless (bound-and-true-p git-commit-mode)
        (git-commit-setup-check-buffer))))
  :init (add-hook 'find-file-hook #'my/git-commit-load-on-demand))

(use-package my-git-commit
  :ensure nil
  :load-path "site-lisp/"
  :after git-commit
  :demand t)

(use-package pdf-tools
  :commands (pdf-loader-install)
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :bind (:map special-mode-map ([remap quit-window] . nil))
  :custom
  (pdf-view-use-scaling t)
  (pdf-view-use-imagemagick t)
  :preface
  (defun my/maybe-toggle-pdf-midnight-view ()
    (setq pdf-view-midnight-colors `(,(face-foreground 'default) . ,(face-background 'default)))
    (if (< (string-to-number (substring (face-background 'default) 1) 16) #x333333)
        (pdf-view-midnight-minor-mode 1)
      (pdf-view-midnight-minor-mode -1)))
  (defun my/pdf-view-mode-hook ()
    (mode-line-invisible-mode 1)
    (pdf-view-fit-width-to-window)
    (tooltip-mode -1)
    (my/maybe-toggle-pdf-midnight-view)
    (advice-add 'pdf-util-tooltip-arrow :override 'ignore)
    (add-hook 'after-load-theme-hook #'my/maybe-toggle-pdf-midnight-view nil t))
  (add-hook 'pdf-view-mode-hook #'my/pdf-view-mode-hook)
  :config
  (pdf-loader-install)
  (add-to-list 'revert-without-query ".pdf"))

(use-package saveplace-pdf-view
  :after (:any doc-view pdf-tools)
  :demand t)

(use-package csv-mode
  :custom (csv-comment-start "##")
  :preface
  (defun my/csv-mode-hook ()
    (csv-header-line)
    (csv-align-mode 1)
    (hl-line-mode 1)
    (visual-line-mode -1))
  (add-hook 'csv-mode-hook #'my/csv-mode-hook))

(use-package markdown-mode
  :after emacs
  :mode ("\\.md\\'" . gfm-mode)
  :custom
  (markdown-max-image-size `(,(round (* my/scale-factor 300)) . ,(round (* my/scale-factor 150))))
  (markdown-display-remote-images t)
  (markdown-list-item-bullets '("●" "○" "◎" "◆" "◇" "►" "•"))
  (markdown-list-indent-width 2)
  (markdown-blockquote-display-char '(">"))
  :preface
  (defun my/markdown-mode-hook ()
    (markdown-display-inline-images)
    (my/set-local-indent-width markdown-list-indent-width))
  :config
  (add-hook 'markdown-mode-hook #'my/markdown-mode-hook))

(when nil
  (use-package gptel
    :after my-keybindings
    :bind
    (nil
     :map my/personal-map
     ("g g" . gptel)
     ("g s" . gptel-send)
     ("g r" . gptel-rewrite)
     ("g m" . gptel-menu))
    :config
    (let ((_ollama-backend
           (gptel-make-ollama "Ollama"
             :host "localhost:11434"
             :stream t
             :models '("hf.co/bartowski/Nanbeige_Nanbeige4-3B-Thinking-2511-GGUF:Q4_K_M")))
          (_gemini-backend
           (gptel-make-gemini "Gemini"
             :key (lambda () (my/read-1password-secret "GOOGLE_API_KEY"))
             :stream t
             :models '("gemini-3-flash-preview"
                       "gemini-3-pro-preview")))
          (_deepseek-backend
           (gptel-make-deepseek "DeepSeek"
             :key (lambda () (my/read-1password-secret "DEEPSEEK_API_KEY"))
             :stream t
             :models '("deepseek-reasoner")))
          (_fireworks-backend
           (gptel-make-openai "FireworksAI"
             :host "api.fireworks.ai"
             :endpoint "/inference/v1/chat/completions"
             :protocol "https"
             :key (lambda () (my/read-1password-secret "FIREWORKS_API_KEY"))
             :stream t
             :models '("accounts/fireworks/models/deepseek-v3p2")))
          (_codestral-backend
           (gptel-make-openai "Codestral"
             :host "codestral.mistral.ai"
             :endpoint "/v1/chat/completions"
             :protocol "https"
             :key (lambda () (my/read-1password-secret "CODESTRAL_API_KEY"))
             :stream t
             :models '("codestral-latest")))
          (_devstral-backend
           (gptel-make-openai "Devstral"
             :host "api.mistral.ai"
             :endpoint "/v1/chat/completions"
             :protocol "https"
             :key (lambda () (my/read-1password-secret "DEVSTRAL_API_KEY"))
             :stream t
             :models '("devstral-latest")))
          (mistral-backend
           (gptel-make-openai "Mistral"
             :host "api.mistral.ai"
             :endpoint "/v1/chat/completions"
             :protocol "https"
             :key (lambda () (my/read-1password-secret "MISTRAL_API_KEY"))
             :stream t
             :models '("mistral-medium-3-5"))))
      (setq gptel-backend mistral-backend
            gptel-model 'mistral-medium-3-5)))

  (use-package gptel-agent
    :after gptel
    :config (gptel-agent-update))
  )

;; Programming

(use-package eglot
  :after my-keybindings
  :ensure nil
  :no-require t
  :hook ((python-base-mode sh-base-mode c-ts-base-mode LaTeX-mode nxml-mode) . eglot-ensure)
  :bind (:map my/personal-map ("rn" . eglot-rename))
  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref nil)
  (eglot-prefer-plaintext t)
  (eglot-send-changes-idle-time 1)
  (eglot-events-buffer-config '(:size 0 :format full))
  (eglot-ignored-server-capabilities
   '(:codeLensProvider
     ;; :codeActionProvider
     ;; :colorProvider
     :foldingRangeProvider
     :executeCommandProvider))
  :preface
  (defun my/eglot-mode-hook ()
    (add-hook 'flymake-diagnostic-functions #'eglot-flymake-backend nil t)
    (when flymake-mode (flymake-start)))
  (add-hook 'eglot-managed-mode-hook #'my/eglot-mode-hook)
  (defun my/eglot-require-completion-prefix (fn &rest args)
    "Suppress the advised Capf's result when nothing precedes point."
    (let ((res (apply fn args)))
      (unless (and (consp res)
                   (integer-or-marker-p (car res))
                   (<= (point) (car res)))
        res)))
  (defun my/eglot-tolerate-watch-limit (fn &rest args)
    "Degrade to fewer file watches instead of failing the server's request."
    (condition-case err (apply fn args)
      (jsonrpc-error (eglot--warn "Capability registration degraded: %S" err))))
  :init
  (setq eglot-stay-out-of '(flymake))
  ;; LemMinX reads its settings from the `xml' section, both from
  ;; `initializationOptions' and from `workspace/didChangeConfiguration';
  ;; Eglot sends the latter on connect with exactly this shape.
  (setq-default eglot-workspace-configuration
                '(:xml (:useCache t
                                  :downloadExternalResources (:enabled t)
                                  :validation (:noGrammar "ignore")
                                  :format (:enabled t
                                                    :maxLineWidth 100
                                                    :splitAttributes "preserve"
                                                    :preserveAttributeLineBreaks t))))
  (advice-add 'eglot--connect :around #'my/prevent-in-home-dir-advice)
  (advice-add 'eglot-completion-at-point :around #'my/eglot-require-completion-prefix)
  (advice-add 'eglot-register-capability :around #'my/eglot-tolerate-watch-limit)
  :config
  (add-to-list 'eglot-server-programs
               `(python-base-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs
               `((c++-ts-mode c-ts-mode c++-mode c-mode)
                 . ("clangd"
                    "--clang-tidy"
                    "--header-insertion=never"
                    "--background-index"
                    "--completion-style=detailed"
                    "--query-driver=**/.pixi/envs/**/bin/*")))
  (add-to-list 'eglot-server-programs
               `((nxml-mode :language-id "xml") . ("lemminx"))))

(use-package apheleia
  :defer 1
  :preface
  (add-hook 'python-base-mode-hook
            (lambda () (setq-local apheleia-formatter '(ruff-check ruff))))
  (add-hook 'sh-base-mode-hook
            (lambda () (setq-local apheleia-formatter 'shfmt)))
  (add-hook 'cmake-ts-mode-hook
            (lambda () (setq-local apheleia-formatter 'cmake-fmt)))
  (add-hook 'json-ts-mode-hook
            (lambda () (setq-local apheleia-formatter 'json-fmt)))
  (add-hook 'c-ts-base-mode-hook
            (lambda () (setq-local apheleia-formatter 'clang-format)))
  (add-hook 'LaTeX-mode-hook
            (lambda () (setq-local apheleia-formatter 'latexindent)))
  (defun my/apheleia-format-or (fallback &rest args)
    "Format the buffer with Apheleia if a formatter is configured for it.
Otherwise call FALLBACK (the command normally on \\[fill-paragraph])
interactively with ARGS.  Used to overload \\[fill-paragraph]."
    (if-let* ((formatters (and (fboundp 'apheleia--get-formatters)
                               (apheleia--get-formatters))))
        (apheleia-format-buffer formatters)
      (apply #'funcall-interactively fallback args)))
  (defun my/apheleia-format-or-fill-paragraph (&optional justify region)
    "Apheleia-format the buffer, else fall back to `fill-paragraph'."
    (interactive (progn (barf-if-buffer-read-only)
                        (list (if current-prefix-arg 'full) t)))
    (if (and region (use-region-p) (not (nth 4 (syntax-ppss))))
        (indent-region (region-beginning) (region-end))
      (my/apheleia-format-or #'fill-paragraph justify region)))
  (defun my/apheleia-format-or-prog-fill (&optional arg)
    "Apheleia-format the buffer, else fall back to `prog-fill-reindent-defun'."
    (interactive "P")
    (my/apheleia-format-or #'prog-fill-reindent-defun arg))
  :bind (([remap fill-paragraph] . my/apheleia-format-or-fill-paragraph)
         ([remap prog-fill-reindent-defun] . my/apheleia-format-or-prog-fill))
  :config
  (apheleia-global-mode 1)
  (setf (alist-get 'ruff apheleia-formatters)
        '("ruff" "format" "--silent" "--stdin-filename" filepath "-"))
  (setf (alist-get 'ruff-check apheleia-formatters)
        '("ruff" "check" "--fix" "--silent" "--stdin-filename" filepath "-"))
  (setf (alist-get 'shfmt apheleia-formatters)
        '("shfmt" "-ln" "bash"
          (apheleia-formatters-indent '("-i" "0") "-i" 'standard-indent)
          "-ci" "-bn" "-sr"))
  (setf (alist-get 'cmake-fmt apheleia-formatters)
        '("format-cmake"))
  (setf (alist-get 'json-fmt apheleia-formatters)
        '("format-json" (apheleia-formatters-indent '("--indent" "0") "--indent")))
  (setf (alist-get 'latexindent apheleia-formatters)
        '("latexindent" "--logfile=/dev/null" "-m" "-rv")))

(use-package prog-mode
  :ensure nil
  :no-require t
  :preface
  (defun my/prog-mode-hook ()
    (which-function-mode 1)
    (setq show-trailing-whitespace t)
    ;; (modify-syntax-entry ?- "w")
    (modify-syntax-entry ?_ "w"))
  (add-hook 'prog-mode-hook #'my/prog-mode-hook))

(use-package visual-wrap
  :ensure nil
  :no-require t
  :custom
  (global-visual-wrap-prefix-mode t)
  (visual-wrap-extra-indent standard-indent)
  :preface
  (defun my/visual-wrap-append-marker ()
    "Append `wrap-prefix' to the wrap-prefix property of the line at point."
    (let ((wrap-prop (get-text-property (point) 'wrap-prefix)))
      (when (stringp wrap-prop)
        (put-text-property (point) (pos-eol) 'wrap-prefix
                           (concat wrap-prop wrap-prefix)))))
  :config
  ;; NOTE: `visual-wrap--apply-to-line' is private; revisit on Emacs updates.
  (advice-add 'visual-wrap--apply-to-line :after #'my/visual-wrap-append-marker))

(use-package hideshow
  :ensure nil
  :no-require t
  :hook ((prog-mode toml-ts-mode) . hs-minor-mode)
  :init (setq hs-allow-nesting t))

(use-package outline
  :ensure nil
  :no-require t
  :custom (outline-blank-line t)
  :preface
  (defun my/outline-toggle-children-advice (_orig-fun &rest _args)
    "Fix `outline-toggle-children` for multi-line headings."
    (save-excursion
      (outline-back-to-heading)
      (let ((end (save-excursion (outline-end-of-heading) (point))))
        (if (not (outline-invisible-p end))
            (outline-hide-subtree)
          (outline-show-children)
          (outline-show-entry)))))
  :init (advice-add 'outline-toggle-children :around #'my/outline-toggle-children-advice))

(use-package outline-indent
  :hook ((conf-mode yaml-ts-mode nxml-mode python-base-mode sh-base-mode
                    c-ts-base-mode json-ts-mode)
         . outline-indent-minor-mode))

(use-package kirigami
  :custom (kirigami-preserve-visual-position t)
  :commands (kirigami-open-fold
             kirigami-open-fold-rec
             kirigami-close-fold
             kirigami-toggle-fold
             kirigami-open-folds
             kirigami-close-folds)
  :config
  ;; `kirigami' leaves `:open-rec' unimplemented for hideshow.  Since Emacs 31.1
  ;; `hs-show-block' opens the blocks nested inside the one at point, so the
  ;; plain opener already is the recursive one.
  (let ((hideshow (cdr (assoc '(hs-minor-mode) kirigami-fold-list))))
    (plist-put hideshow :open-rec (plist-get hideshow :open))))

(use-package my-fold-level
  :ensure nil
  :load-path "site-lisp/"
  :commands (my-fold-level-decrease
             my-fold-level-increase
             my-fold-level-close-all
             my-fold-level-open-all))

(use-package disp-table
  :ensure nil
  :no-require t
  :preface
  (defvar my/fold-ellipsis " ... ")

  (defface my/fold-ellipsis-face '((t :inherit default))
    "Face for the ellipsis standing in for folded text."
    :group 'faces)

  (defun my/customize-fold-ellipsis ()
    "Give the folding ellipsis a dimmed, boxed badge look."
    (when-let* ((fg (my/theme-color 'fg-dim))
                (bg (my/theme-color 'bg-dim))
                (border (my/theme-color 'border)))
      (set-face-attribute
       'my/fold-ellipsis-face nil
       :foreground fg
       :background bg
       :box `(:line-width (-1 . -1) :color ,border)))
    (unless standard-display-table
      (setq standard-display-table (make-display-table)))
    (set-display-table-slot
     standard-display-table 'selective-display
     (vconcat (mapcar (lambda (c) (make-glyph-code c 'my/fold-ellipsis-face)) my/fold-ellipsis))))
  (add-hook 'after-load-theme-hook #'my/customize-fold-ellipsis)

  (defvar my/fold-ellipsis-string (propertize my/fold-ellipsis 'face 'my/fold-ellipsis-face)
    "Marker shown in place of folded text to avoid mis-painting a `:box'.")

  (defun my/fold-ellipsis-mark-overlay (from to flag &rest _)
    "Sync the fold marker across the overlays between FROM and TO; FLAG hides."
    (dolist (o (overlays-in from to))
      (cond ((and flag (overlay-get o 'invisible) (= (overlay-start o) from))
             (overlay-put o 'display my/fold-ellipsis-string))
            ((and (eq (overlay-get o 'display) my/fold-ellipsis-string)
                  (not (overlay-get o 'invisible)))
             (overlay-put o 'display nil)))))
  ;; Neither has a hook that hands over the overlay it just created.
  (advice-add 'outline-flag-region :after #'my/fold-ellipsis-mark-overlay)
  (advice-add 'org-fold-core-region :after #'my/fold-ellipsis-mark-overlay)
  :custom (hs-set-up-overlay (lambda (ov) (overlay-put ov 'display my/fold-ellipsis-string))))

(use-package electric-pair
  :ensure nil
  :no-require t
  :hook (prog-mode text-mode)
  :preface
  (defun my/electric-pair-inhibit (char)
    "Inhibit pairing CHAR directly before a word; else use the default."
    (or (eq (char-syntax (following-char)) ?w)
        (electric-pair-default-inhibit char)))
  :custom
  (electric-pair-skip-whitespace nil)
  (electric-pair-inhibit-predicate #'my/electric-pair-inhibit))

(use-package rainbow-mode)

(use-package rainbow-delimiters
  :hook (prog-mode minibuffer-setup)
  :preface
  (defun my/customize-rainbow-delimiters ()
    (pcase-dolist (`(,face ,color)
                   '((rainbow-delimiters-depth-1-face fg-dim)
                     (rainbow-delimiters-depth-2-face magenta-faint)
                     (rainbow-delimiters-depth-3-face cyan-faint)
                     (rainbow-delimiters-depth-4-face red-faint)
                     (rainbow-delimiters-depth-5-face yellow-faint)
                     (rainbow-delimiters-depth-6-face indigo)
                     (rainbow-delimiters-depth-7-face green-faint)
                     (rainbow-delimiters-depth-8-face blue-faint)
                     (rainbow-delimiters-depth-9-face rust)))
      (when-let* ((fg (my/theme-color color)))
        (set-face-foreground face fg))))
  (defun my/rainbow-delimiters-hook ()
    (my/customize-rainbow-delimiters)
    (add-hook 'after-load-theme-hook #'my/customize-rainbow-delimiters nil t))
  (add-hook 'rainbow-delimiters-mode-hook #'my/rainbow-delimiters-hook))

(use-package indent-bars
  :preface
  (defun my/indent-bars-maybe-enable ()
    (unless (derived-mode-p 'emacs-lisp-mode 'lisp-data-mode)
      (indent-bars-mode 1)))
  :hook ((prog-mode yaml-ts-mode) . my/indent-bars-maybe-enable)
  :custom
  (indent-bars-display-on-blank-lines nil)
  ;; (indent-bars-no-descend-lists t)  ;; no extra bars in contd. func. args
  (indent-bars-treesit-support t)
  ;; (indent-bars-treesit-scope
  ;;  '((python
  ;;     function_definition class_definition
  ;;     for_statement if_statement with_statement while_statement)))
  (indent-bars-prefer-character t)
  (indent-bars-no-stipple-char ?·)
  (indent-bars-color '(highlight :face default :blend 0.2))
  (indent-bars-zigzag nil)
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-display-on-blank-lines nil))

(use-package simple
  :ensure nil
  :no-require t
  :hook ((text-mode compilation-mode) . visual-line-mode))

(use-package flymake
  :ensure nil
  :no-require t
  :after (my-keybindings modus-themes)
  :hook prog-mode
  :bind (:map my/personal-map ("M-f" . flymake-show-buffer-diagnostics))
  :custom
  (flymake-no-changes-timeout 1)
  (flymake-mode-line-format '(" " flymake-mode-line-counters))
  (flymake-show-diagnostics-at-end-of-line t)
  (flymake-indicator-type 'margins)
  (flymake-autoresize-margins nil)      ; width is my-margin's job
  (flymake-margin-indicators-string
   '((note "•" flymake-note-echo)  ;; ●
     (warning "▲" flymake-warning-echo)
     (error "◼" flymake-error-echo)))
  :preface
  (defun my/customize-flymake ()
    (when-let* (((facep 'flymake-end-of-line-diagnostics-face))
                (fg-dim (my/theme-color 'fg-dim)))
      (set-face-attribute 'flymake-end-of-line-diagnostics-face nil
                          :foreground fg-dim
                          :box '(:line-width (4 . -1) :style flat-button)
                          :height (round (* 0.92 (face-attribute 'default :height)))
                          :italic t
                          :inherit 'variable-pitch)
      (pcase-dolist (`(,face ,fg-color ,bg-color)
                     '((flymake-eol-information-face blue-faint   bg-blue-nuanced)
                       (flymake-note-echo-at-eol     cyan-faint   bg-cyan-nuanced)
                       (flymake-warning-echo-at-eol  yellow-faint bg-yellow-nuanced)
                       (flymake-error-echo-at-eol    red-faint    bg-red-nuanced)))
        (when-let* (((facep face))
                    (fg (my/theme-color fg-color))
                    (bg (my/theme-color bg-color)))
          (set-face-attribute face nil
                              :extend t
                              :underline nil
                              :inherit 'flymake-end-of-line-diagnostics-face
                              :foreground fg
                              :background bg)))))
  (defun my/flymake-hook ()
    (my/customize-flymake)
    (add-hook 'after-load-theme-hook #'my/customize-flymake nil t))
  (add-hook 'flymake-mode-hook #'my/flymake-hook))

(use-package flyspell
  :ensure nil
  :no-require t
  :custom (flyspell-delay-use-timer t)
  :init
  (add-hook 'text-mode-hook #'flyspell-mode)
  (add-hook 'prog-mode-hook #'flyspell-prog-mode)
  :config (require 'ispell))

(use-package ispell
  :ensure nil
  :no-require t
  :custom
  (ispell-silently-savep t)
  (ispell-program-name "aspell")
  (ispell-extra-args '("--ignore-case"))
  (ispell-local-dictionary-alist
   '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
  (ispell-dictionary "en_US")
  (ispell-local-dictionary "en_US"))


;; Lisp

(use-package emacs-lisp-mode
  :after my-keybindings
  :ensure nil
  :no-require t
  :bind (:map my/personal-map ("(" . 'check-parens))
  :preface (add-hook 'emacs-lisp-mode-hook (lambda () (my/set-local-indent-width lisp-body-indent))))


;; Vimscript

(use-package vimscript-ts-mode
  :ensure nil
  :no-require t
  :mode "/\\.?\\(vimrc\\|vims?\\)\\'")


;; Python

(use-package python
  :ensure nil
  :no-require t
  :after treesit
  :custom (python-check-command '("ruff" "--quiet" "--stdin-filename=stdin" "-"))
  :init
  (add-hook 'inferior-python-mode-hook
            (lambda () (add-to-list 'comint-output-filter-functions #'comint-truncate-buffer))))

(use-package flymake-ruff
  :hook (python-base-mode . flymake-ruff-load)
  :custom (python-flymake-command python-check-command))

;; Vendored from https://github.com/com4/flymake-mypy (BSD-2-Clause)
(use-package flymake-mypy
  :ensure nil
  :load-path "site-lisp/"
  :commands (flymake-mypy-enable)
  :preface
  (defun my/flymake-mypy-enable ()
    "Enable the mypy Flymake backend when mypy is available."
    (when (executable-find "mypy")
      (setq-local flymake-mypy-executable (executable-find "mypy"))
      (flymake-mypy-enable)))
  :hook (python-base-mode . my/flymake-mypy-enable))

(use-package my-pixi
  :ensure nil
  :load-path "site-lisp/"
  :commands (my-pixi-mode my-pixi-python-setup my-pixi-refresh)
  ;; Depth -90 so the environment is in place before `eglot-ensure' connects.
  :init (add-hook 'python-base-mode-hook #'my-pixi-python-setup -90))

(use-package conda
  :preface
  (defun my/conda-env-activate-for-buffer ()
    "Activate the env of the current buffer unless it is already active."
    (when (and (derived-mode-p 'python-base-mode)
               (bound-and-true-p conda-project-env-path)
               (not (equal conda-project-env-path
                           (bound-and-true-p conda-env-current-path))))
      (conda-env-activate-for-buffer)))
  (defun my/conda-reconnect-eglot ()
    "Restart the language server so that it sees the new environment."
    (when-let* ((server (and (featurep 'eglot) (eglot-current-server))))
      (eglot-reconnect server)))
  :init
  (add-hook 'find-file-hook #'my/conda-env-activate-for-buffer)
  (add-hook 'conda-postactivate-hook #'my/conda-reconnect-eglot)
  (add-hook 'conda-postdeactivate-hook #'my/conda-reconnect-eglot))


;; C/C++

(use-package c-ts-mode
  :ensure nil
  :no-require t
  :mode (("\\.\\(c\\|h\\)\\'" . c-ts-mode)
         ("\\.\\(cc\\|cpp\\|cxx\\|hh\\|hpp\\|hxx\\|ipp\\|tpp\\)\\'" . c++-ts-mode)))


;; Bash

(use-package sh-script
  :ensure nil
  :no-require t
  ;; :init (add-hook 'sh-base-mode-hook #'flymake-mode-off)
  :mode ("/\\.?\\(bashrc\\|bash_[^.]*\\)\\'" . sh-mode))

(use-package flymake-bashate
  :commands flymake-bashate-setup
  :hook (sh-base-mode . flymake-bashate-setup))

;; YAML

(use-package yaml-ts-mode
  :ensure nil
  :no-require t
  :mode ("\\.yaml\\'" "\\.yml\\'" "\\.repos\\'")
  :preface
  (defun my/yaml-mode-hook ()
    (setq-local yaml-indent-offset 2)
    (flyspell-mode -1)
    (my/set-local-indent-width yaml-indent-offset))
  (add-hook 'yaml-ts-mode-hook #'my/yaml-mode-hook))


;; JSON

(use-package json-ts-mode
  :ensure nil
  :no-require t
  :mode ("\\.json\\'" "\\.jsonc\\'")
  :custom (json-ts-mode-indent-offset 2)
  :preface
  (defun my/json-mode-hook ()
    (flyspell-mode -1)
    (my/set-local-indent-width json-ts-mode-indent-offset))
  (add-hook 'json-ts-mode-hook #'my/json-mode-hook))


;; CMake

(use-package cmake-ts-mode
  :ensure nil
  :no-require t
  :mode ("\\(?:CMakeLists\\.txt\\|\\.cmake\\)\\'")
  :init (add-hook 'cmake-ts-mode-hook #'flymake-cmake-lint-setup))

;; `flymake-quickdef' (used by the backend below) is already pulled in as a
;; dependency of `flymake-bashate'.
(use-package flymake-cmake-lint
  :ensure nil
  :load-path "site-lisp/"
  :commands (flymake-cmake-lint-setup))


;; Docker

(use-package dockerfile-ts-mode
  :ensure nil
  :no-require t
  ;; The built-in mode registers its auto-mode-alist entry and font-lock only
  ;; when the grammar is already installed, so declare the mapping ourselves.
  :mode ("\\(?:Dockerfile\\(?:\\..*\\)?\\|\\.[Dd]ockerfile\\)\\'"))


;; XML

(use-package nxml-mode
  :ensure nil
  :no-require t
  :mode ("\\.xml\\'" "\\.urdf\\'" "\\.xacro\\'" "\\.launch\\'")
  :custom
  (nxml-child-indent 2)
  ;; Let LemMinX resolve and validate <?xml-model?> schema naming.
  (rng-nxml-auto-validate-flag nil)
  :preface
  (defun my/nxml-mode-hook ()
    (flyspell-mode -1)
    (outline-minor-mode 1)
    (visual-line-mode -1)
    (my/set-local-indent-width nxml-child-indent)
    (setq-local nxml-attribute-indent nxml-child-indent))
  (defun my/nxml-close-tag-indent (orig pos)
    "Indent a lone tag-closer (`>' or `/>') to the start-tag's column.
ORIG and POS are as for `nxml-compute-indent-in-start-tag'."
    (if (save-excursion (goto-char pos) (looking-at-p "/?>[ \t]*$"))
        (save-excursion (goto-char xmltok-start) (current-indentation))
      (funcall orig pos)))
  :config
  (add-hook 'nxml-mode-hook #'my/nxml-mode-hook)
  (advice-add 'nxml-compute-indent-in-start-tag :around #'my/nxml-close-tag-indent))


;; ROS

(use-package my-ros-msg-mode
  :ensure nil
  :load-path "site-lisp/"
  :mode ("\\.msg\\'" . my-ros-msg-mode))


;; LaTeX

(use-package auctex
  :ensure nil
  :after emacs
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-command-extra-options "-shell-escape")
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  (TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view)))
  (TeX-source-correlate-start-server t)
  (preview-auto-cache-preamble t)
  (preview-default-option-list '("displaymath" "floats" "graphics" "textmath" "footnotes"))
  (preview-preserve-counters t)
  (preview-scale-function (/ 1 my/scale-factor))
  :preface
  (defun my/LaTeX-mode-hook ()
    (outline-minor-mode 1)
    (LaTeX-math-mode 1)
    (turn-on-reftex)
    (add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews nil t)
    (add-hook 'after-load-theme-hook #'my/delete-latex-preview-overlays nil t)
    (advice-add 'preview-document :before (lambda (&rest _) (TeX-PDF-mode -1)))
    (advice-add 'preview-region :before (lambda (&rest _) (TeX-PDF-mode -1)))
    (advice-add 'TeX-command :before (lambda (&rest _) (TeX-PDF-mode 1))))
  (add-hook 'LaTeX-mode-hook #'my/LaTeX-mode-hook)
  (add-hook 'TeX-after-compilation-finished-functions-hook #'TeX-revert-document-buffer))

(use-package preview-dvisvgm
  :after (emacs preview)
  :custom
  (preview-image-type 'dvisvgm)
  (preview-scale-function my/scale-factor))


;; Org

(use-package org
  :ensure nil
  :no-require t
  :bind (:map org-mode-map ("M-<return>" . org-meta-return))
  :custom
  (org-startup-with-latex-preview t)
  (org-startup-with-inline-images t)
  (org-startup-truncated nil)
  (org-startup-folded 'fold)
  (org-startup-indented t)
  (org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
  (org-cycle-separator-lines 1)
  (org-preview-latex-image-directory (no-littering-expand-var-file-name "ltximg/"))
  (org-image-max-width (/ 2 (+ 1 (sqrt 5))))
  (org-archive-location "org_archive/%s_archive::")
  (org-directory "~/Documents/org")
  (org-agenda-files (list org-directory "~/Desktop"))
  (org-todo-keywords '((sequence "TODO" "NEXT" "WIP" "WAIT" "|" "DONE" "SKIP" "FAIL")))
  (org-enforce-todo-dependencies t)
  (org-agenda-dim-blocked-tasks t)
  (org-log-done 'time)
  (org-log-into-drawer t)
  (org-tags-column 0)
  (org-catch-invisible-edits 'error)
  (org-hide-emphasis-markers t)
  (org-fontify-todo-headline nil)
  (org-fontify-done-headline t)
  (org-export-with-toc nil)
  (org-src-preserve-indentation t)
  (org-latex-create-formula-image-program 'dvisvgm)
  (org-latex-packages-alist
   (list (concat "\\input{" (expand-file-name "etc/math_commands.tex" dotfiles-dir) "}")))
  (org-special-ctrl-a/e t)
  (org-special-ctrl-k t)
  (org-special-ctrl-o t))

(use-package my-org
  :after my-keybindings
  :ensure nil
  :load-path "site-lisp/"
  :hook (org-mode . my-org-mode)
  :bind
  (nil
   :map my/personal-map
   ("l" . org-store-link)
   ("a" . org-agenda)
   ("j" . my/org-open-journal)
   :map my/toggles-map
   ("m" . my/org-toggle-emphasis-marker-display)
   ("l" . org-toggle-link-display)))

(use-package org-indent
  :ensure nil
  :no-require t
  :preface
  (defun my/org-indent-set-line-properties-advice (orig-fn level indentation &optional heading)
    "Append `wrap-prefix' to the current line's wrap-prefix property only.
Leaves the line-prefix property `org-indent' also sets untouched."
    (let ((beg (line-beginning-position))
          (end (line-beginning-position 2)))
      ;; The original function calculates and sets both line-prefix and wrap-prefix,
      ;; and then moves point to the next line via (forward-line).
      (funcall orig-fn level indentation heading)
      ;; We intercept the wrap-prefix it just set on the line, and append our marker.
      (let ((wrap-prop (get-text-property beg 'wrap-prefix)))
        (when (stringp wrap-prop)
          (put-text-property beg end 'wrap-prefix (concat wrap-prop wrap-prefix))))))
  :config
  (advice-add 'org-indent-set-line-properties :around #'my/org-indent-set-line-properties-advice))

(use-package org-fragtog
  :hook org-mode)

(use-package org-appear
  :hook org-mode
  ;; :custom (org-appear-autolinks t)
  )

(provide 'init)

;;; init.el ends here

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
