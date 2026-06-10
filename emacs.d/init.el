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

  ;; Custom after theme load hook
  (defvar after-load-theme-hook nil
    "Hook that runs after a color theme is loaded using `load-theme'.")

  (defun my/run-after-load-theme-hook (&rest _)
    "Run `after-load-theme-hook`."
    (run-hooks 'after-load-theme-hook))

  (add-hook 'after-load-theme-hook
            (lambda () (my/run-other-buffers-local-hooks 'after-load-theme-hook)))

  (advice-add 'load-theme :before (lambda (&rest _) (mapc #'disable-theme custom-enabled-themes)))
  (advice-add 'load-theme :after #'my/run-after-load-theme-hook)

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
  (dolist (buf '(" *Echo Area 0*" " *Echo Area 1*"))
    (with-current-buffer (get-buffer-create buf)
      (setq-local line-prefix " ")))

  (defun my/pad-minibuffer-prompt ()
    "Add a prefix to the minibuffer prompt to prevent rounded corner obstruction."
    (let ((inhibit-read-only t))
      (put-text-property (point-min) (minibuffer-prompt-end) 'line-prefix " ")
      (put-text-property (point-min) (minibuffer-prompt-end) 'wrap-prefix " ")))
  (add-hook 'minibuffer-setup-hook #'my/pad-minibuffer-prompt)

  ;; Suppress blank tooltips
  (defun my-suppress-blank-tooltips (str &rest _)
    "Suppress tooltips with nil, empty, or all-whitespace STR."
    (or (null str) (string-blank-p (string-trim str))))

  (advice-add #'x-show-tip :before-until #'my-suppress-blank-tooltips)

  ;; Startup time
  (defun my/display-startup-stats ()
    "Display startup stats."
    (message
     "%d packages loaded in %ss with %d garbage collections"
     (length package-activated-list)
     (emacs-init-time "%.3f")
     gcs-done))

  (add-hook 'emacs-startup-hook #'my/display-startup-stats)

  :custom
  (initial-scratch-message nil)
  (initial-major-mode 'fundamental-mode)
  (fill-column 79)
  (column-number-mode t)
  (use-dialog-box nil)
  (auto-save-visited-file-name t)
  (auto-save-timeout 1)
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
  ;; (underline-minimum-offset 2)
  (line-spacing fixed-pitch-line-spacing)
  (truncate-lines nil)
  (wrap-prefix "…")
  (cursor-in-non-selected-windows nil)
  (left-margin-width 0)
  (right-margin-width 0)
  (indent-tabs-mode nil)
  (treemacs-no-png-images t)
  (delete-by-moving-to-trash t)

  :init
  (xterm-mouse-mode 1)
  (context-menu-mode 1)
  (pixel-scroll-precision-mode 1)
  (global-visual-line-mode -1)
  ;; Display table for wrap prefix
  (set-display-table-slot standard-display-table 'wrap (string-to-char wrap-prefix))
  (set-display-table-slot standard-display-table 0 (string-to-char wrap-prefix)))


;; Basic packages

(use-package no-littering
  :demand t
  :config
  (setq custom-file (no-littering-expand-var-file-name "custom.el"))
  (let ((dir (no-littering-expand-var-file-name "lock-files/")))
    (make-directory dir t)
    (setq lock-file-name-transforms `((".*" ,dir t))))
  (let ((dir (no-littering-expand-var-file-name "auto-save/")))
    (make-directory dir t)
    (setq auto-save-file-name-transforms `((".*" ,dir t))))
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
  :preface (advice-add 'completing-read :before (lambda (&rest _) (unless savehist-mode (savehist-mode 1))))
  :config (savehist-mode 1))

(use-package recentf
  :after no-littering
  :ensure nil
  :no-require t
  :defer 1
  :custom (recentf-auto-cleanup 'never)
  :config
  (recentf-mode 1)
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory)))

(use-package comint
  :ensure nil
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
  :preface
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
  :custom (xref-search-program 'ripgrep))

(use-package isearch
  :ensure nil
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

(use-package my-mode-line
  :ensure nil
  :load-path "site-lisp/"
  :hook after-init
  ;; :init (add-hook 'after-load-theme-hook
  ;;                 (lambda ()
  ;;                   (setq-default mode-line-format my/mode-line-format)))
  )

(use-package my-theme-switcher
  :ensure nil
  :load-path "site-lisp/"
  :hook after-init)

(use-package my-keybindings
  :ensure nil
  :load-path "site-lisp/"
  :demand t
  :config (my-keybindings-mode 1))

(use-package modus-themes
  :defer nil
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
     (variable cyan)))
  (modus-vivendi-palette-overrides
   '((bg-main "#1e1e1e")
     (bg-dim "#292929")
     (fg-vertical-border bg-popup)))
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
  (tab-bar-show t)
  (tab-bar-new-button-show nil)
  (tab-bar-close-button-show nil)
  (tab-bar-separator "")
  (tab-bar-auto-width nil)
  (tab-bar-tab-name-truncated-max 100)
  (tab-bar-format
   '(tab-bar-format-tabs
     tab-bar-separator
     tab-bar-format-align-right
     tab-bar-format-global))
  :preface
  (defun my/format-tab-spacing (string _ _)
    "Add spacing for Emacs 30+ format-functions."
    (concat "  " string "  "))
  (defun my/tab-name-padded-and-truncated ()
    "Calculate the truncated tab name, then add padding (Emacs 29)."
    (let ((name (tab-bar-tab-name-truncated)))
      (concat "  " name "  ")))
  :config
  (if (boundp 'tab-bar-tab-name-format-functions)
      (progn
        (add-to-list 'tab-bar-tab-name-format-functions #'my/format-tab-spacing)
        (add-to-list 'tab-bar-tab-name-format-functions #'tab-bar-tab-name-format-truncated))
    (setq tab-bar-tab-name-function #'my/tab-name-padded-and-truncated))
  (add-hook 'desktop-after-read-hook #'tab-bar-mode))

(use-package stripes
  :after (my-keybindings modus-themes)
  :hook dired-mode  ;; minibuffer-mode vertico-mode corfu-popupinfo-mode
  :bind (:map my/toggles-map ("s" . stripes-mode))
  :custom
  (stripes-unit 1)
  (stripes-overlay-priority -100)
  :preface
  (defun my/customize-stripes ()
    (when (fboundp 'modus-themes-get-color-value)
      (set-face-background 'stripes (modus-themes-get-color-value 'bg-dim t))))
  (add-hook 'stripes-mode-hook #'my/customize-stripes))

(use-package files
  :ensure nil
  :preface
  (defun my/revert-buffer-quick-preserve (&optional auto-save)
    "Like `revert-buffer-quick', but preserves modes (accepts AUTO-SAVE)."
    (interactive "P")
    (revert-buffer auto-save (not (buffer-modified-p)) t))
  :bind (([remap revert-buffer-quick] . #'my/revert-buffer-quick-preserve))
  :custom (enable-remote-dir-locals t))

(use-package tramp
  :ensure nil
  :custom
  (tramp-verbose 2)
  (tramp-use-connection-share nil)  ;; Let ~/.ssh/config handle it
  (vc-handled-backends '(Git))  ;; Limit VC to Git only
  :config
  (add-to-list 'tramp-remote-path "/snap/bin")
  (add-to-list 'tramp-remote-path "~/.local/bin"))

(use-package dired
  :ensure nil
  :no-require t
  :bind (:map dired-mode-map ("M-<up>" . dired-up-directory))
  :custom
  (dired-listing-switches "-alv --group-directories-first")
  (dired-omit-files "^\\.[^.].*")
  (dired-mouse-drag-files t)
  (dired-omit-verbose nil)
  (dired-dwim-target 'dired-dwim-target-next)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-kill-when-opening-new-dired-buffer t)
  :preface
  (defun my/dired-mode-hook ()
    (dired-omit-mode 1)
    (dired-hide-details-mode 1)
    (hl-line-mode 1))
  (add-hook 'dired-mode-hook #'my/dired-mode-hook))

(use-package eshell
  :ensure nil
  :no-require t
  :preface
  (when (executable-find "starship")
    (defun my/eshell-starship-prompt ()
      (let* ((status (or (bound-and-true-p eshell-last-command-status) 0))
             (starship-cmd (format "env TERM=xterm-256color starship prompt --status %d" status)))
        (ansi-color-apply (shell-command-to-string starship-cmd))))
    (setq eshell-prompt-function #'my/eshell-starship-prompt
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
  (evil-global-set-key 'motion (kbd "j") #'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "k") #'evil-previous-visual-line)
  (evil-global-set-key 'motion (kbd "<down>") #'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "<up>") #'evil-previous-visual-line)
  (evil-global-set-key 'normal (kbd "<tab>") #'evil-toggle-fold)
  (evil-global-set-key 'normal (kbd "C-i") #'evil-jump-forward)
  (evil-global-set-key 'visual (kbd "p") #'evil-paste-before)
  (evil-global-set-key 'visual (kbd "P") #'evil-visual-paste)
  (define-key evil-command-line-map (kbd "C-a") nil)
  (define-key evil-command-line-map (kbd "C-b") nil)
  (define-key evil-command-line-map (kbd "C-d") nil)
  (define-key evil-command-line-map (kbd "C-f") nil)
  (define-key evil-command-line-map (kbd "C-l") nil))

(use-package evil-collection
  :after evil
  :defer 1
  ;; :demand t
  :config (evil-collection-init))

(use-package evil-surround
  :defer 1
  ;; :demand t
  :config (global-evil-surround-mode 1))

(use-package corfu
  :bind
  (nil
   :map corfu-map
   ;; ("<return>" . my/corfu-send-in-shell)
   ;; ("RET" . nil)
   ("<tab>" . corfu-next)
   ("S-<tab>" . corfu-previous)
   ("<escape>" . corfu-reset)
   ("C-d" . corfu-scroll-up)
   ("C-u" . corfu-scroll-down)
   ("<next>" . corfu-scroll-up)
   ("<prior>" . corfu-scroll-down)
   ("S-SPC" . corfu-insert-separator))
  :preface
  (defun my/corfu-send-in-shell ()
    "Send Corfu candidate in shell modes, else do nothing."
    (interactive)
    (if (derived-mode-p 'eshell-mode 'comint-mode)
        (corfu-send)
      (call-interactively (key-binding (kbd "RET")))))
  (defun my/corfu-minibuffer-filter ()
    "Do not show Corfu in minibuffer for MCT, Vertico, or password prompts."
    (interactive)
    (not (or (bound-and-true-p mct--active)
             (bound-and-true-p vertico--input)
             (eq (current-local-map) read-passwd-map))))
  :custom
  (corfu-auto t)  ;; auto-completion
  (corfu-quit-no-match 'separator)  ;; test
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.2)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert)  ;; insert previewed candidate
  (corfu-on-exact-match nil)  ;; Don't auto expand tempel snippets
  (corfu-cycle t)
  ;; (global-corfu-minibuffer t)
  (global-corfu-minibuffer 'my/corfu-minibuffer-filter)
  :defer 1
  :config
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  (corfu-history-mode))

(use-package vertico
  :defer nil
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
  :bind (:map vertico-map ("DEL" . vertico-directory-delete-char)))

(use-package marginalia
  :bind (:map minibuffer-local-map ("M-a" . marginalia-cycle))
  :custom (marginalia-field-width 180)
  :preface
  (defun my/marginalia-mode-hook ()
    (when (facep 'marginalia-documentation)
      (set-face-attribute 'marginalia-documentation nil
                          :italic t :family nil :inherit 'variable-pitch)))
  (add-hook 'after-load-theme-hook #'my/marginalia-mode-hook)
  :defer 1
  :config
  (marginalia-mode)
  (my/marginalia-mode-hook))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil) ;; Disable defaults, use our settings
  (completion-pcm-leading-wildcard t)) ;; Emacs 31: partial-completion behaves like substring

(use-package consult
  :after (evil vertico)
  :hook (completion-list-mode . consult-preview-at-point-mode)
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
  :init
  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add 'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  (advice-add 'consult-recent-file :before (lambda (&rest _) (recentf-mode 1)))
  :config
  ;; The configuration values are evaluated at runtime, just before the
  ;; completion session is started. Therefore you can use for example
  ;; `thing-at-point' to adjust the initial input or the future history.
  (consult-customize consult-line
                     :add-history (seq-some 'thing-at-point '(region symbol)))
  (defalias 'consult-line-thing-at-point 'consult-line)
  (consult-customize consult-line-thing-at-point
                     :initial (thing-at-point 'symbol))
  (add-to-list 'consult-preview-allowed-hooks #'adaptive-wrap-prefix-mode)
  (add-to-list 'consult-preview-allowed-hooks #'variable-pitch-mode)
  ;; (add-to-list 'consult-preview-allowed-hooks #'my/fixed-pitch-mode)
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
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

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
  :ensure nil
  :defer 1
  :custom (which-key-idle-delay 1)
  :config (which-key-mode))

(use-package eldoc-box
  :hook (prog-mode . eldoc-box-hover-at-point-mode))

(use-package diff-hl
  :custom
  (diff-hl-draw-borders nil)
  (diff-hl-autohide-margin t)
  (diff-hl-update-async t)
  :preface
  (defun my/diff-hl-mode-if-vc ()
    (when (and (buffer-file-name) (vc-registered (buffer-file-name)))
      (diff-hl-mode 1)
      (diff-hl-flydiff-mode 1)
      (diff-hl-margin-mode 1)))
  (add-hook 'find-file-hook #'my/diff-hl-mode-if-vc)
  (defun my/customize-diff-hl ()
    (when (boundp 'diff-hl-margin-symbols-alist)
      (setf (alist-get 'change diff-hl-margin-symbols-alist nil nil #'equal) "~"))
    (pcase-dolist (`(,diff-hl-face ,diff-face)
                   '((diff-hl-change diff-changed)
                     (diff-hl-insert diff-added)
                     (diff-hl-delete diff-removed)))
      (set-face-attribute diff-hl-face nil
                          :inherit diff-face
                          :foreground 'unspecified
                          :background 'unspecified
                          :italic nil :bold nil
                          :height (round (* 0.92 (face-attribute 'default :height))))))
  (defun my/diff-hl-hook ()
    (my/customize-diff-hl)
    (add-hook 'after-load-theme-hook #'my/customize-diff-hl nil t)
    ;; (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh nil t)
    (add-hook 'auto-save-hook 'diff-hl-update nil t))
  (add-hook 'diff-hl-margin-local-mode-hook #'my/diff-hl-hook))

(use-package ediff
  :ensure nil
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
  :preface (add-hook 'magit-status-mode-hook (lambda () (visual-line-mode 1)))
  :config
  (when (bound-and-true-p evil-mode)
    (evil-define-key 'normal magit-section-mode-map (kbd "C-<tab>") nil)))

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
    (setq mode-line-format nil)
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
    (let ((state (if (derived-mode-p 'csv-mode) 1 -1)))
      (hl-line-mode state)
      (csv-align-mode state)))
  (add-hook 'csv-mode-hook #'my/csv-mode-hook))

(use-package markdown-mode
  :after emacs
  :mode ("\\.md\\'" . gfm-mode)
  :custom
  (markdown-max-image-size `(,(round (* my/scale-factor 300)) . ,(round (* my/scale-factor 150))))
  (markdown-display-remote-images t)
  (markdown-list-item-bullets '("●" "○" "◎" "◆" "◇" "►" "•"))
  (markdown-list-indent-width 2)
  (standard-indent 2)
  (evil-shift-width 2)
  :preface
  (add-hook 'markdown-mode-hook (lambda ()
                                  (visual-line-mode 1)
                                  (markdown-display-inline-images))))

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


;; Programming

(use-package eglot
  :ensure nil
  :no-require t
  :hook ((python-base-mode sh-base-mode LaTeX-mode) . eglot-ensure)
  :bind (:map my/personal-map ("rn" . eglot-rename))
  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref nil)
  (eglot-prefer-plaintext t)
  (eglot-send-changes-idle-time 1)
  (eglot-events-buffer-config '(:size 0 :format full))
  (eglot-ignored-server-capabilities
   '(:codeLensProvider
     :codeActionProvider
     ;; :colorProvider
     :foldingRangeProvider
     :executeCommandProvider))
  :preface
  (defun my/eglot-mode-hook ()
    (add-hook 'flymake-diagnostic-functions #'eglot-flymake-backend nil t))
  (add-hook 'eglot-managed-mode-hook #'my/eglot-mode-hook)
  :init
  (setq eglot-stay-out-of '(flymake))
  (advice-add 'eglot--connect :around #'my/prevent-in-home-dir-advice)
  :config (add-to-list 'eglot-server-programs
                       `(python-base-mode . ("pyright-langserver" "--stdio"))))

(use-package apheleia
  :defer 1
  :preface
  (add-hook 'python-base-mode-hook
            (lambda () (setq-local apheleia-formatter '(ruff-isort ruff))))
  (add-hook 'sh-base-mode-hook
            (lambda () (setq-local apheleia-formatter 'shfmt)))
  :config
  (apheleia-global-mode 1)
  (let ((config-path (expand-file-name "pyproject.toml" dotfiles-dir)))
    (setf (alist-get 'ruff apheleia-formatters)
          `("ruff" "format" "--config" ,config-path "--silent" "--stdin-filename" filepath "-"))
    (setf (alist-get 'ruff-isort apheleia-formatters)
          `("ruff" "check" "--select" "I" "--fix" "--config" ,config-path "--silent" "--stdin-filename" filepath "-"))
    (setf (alist-get 'shfmt apheleia-formatters)
          '("shfmt" "-ln" "bash" "-i" "4" "-ci" "-bn" "-sr"))
    (setf (alist-get 'latexindent apheleia-formatters)
          '("latexindent" "--logfile=/dev/null" "-m" "-rv"))))

(use-package prog-mode
  :ensure nil
  :preface
  (defun my/prog-mode-hook ()
    (hs-minor-mode 1)
    (which-function-mode 1)
    (setq show-trailing-whitespace t)
    ;; (modify-syntax-entry ?- "w")
    (modify-syntax-entry ?_ "w"))
  (add-hook 'prog-mode-hook #'my/prog-mode-hook))

(use-package outline
  :ensure nil
  :no-require t
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
  :init
  (advice-add 'outline-toggle-children :around #'my/outline-toggle-children-advice))

(use-package outline-indent
  :hook ((conf-mode yaml-ts-mode python-base-mode sh-base-mode) . outline-indent-minor-mode)
  :custom (outline-blank-line t)
  ;; (outline-indent-ellipsis " ▼")
  )

(use-package electric-pair
  :ensure nil
  :hook (prog-mode text-mode)
  :custom (electric-pair-preserve-balance nil))

(use-package rainbow-mode)

(use-package rainbow-delimiters
  :after modus-themes
  :hook (prog-mode minibuffer-setup)
  :preface
  (defun my/customize-rainbow-delimiters ()
    (when (fboundp 'modus-themes-get-color-value)
      (pcase-dolist (`(,face . ,color)
                     '((rainbow-delimiters-depth-1-face fg-dim)
                       (rainbow-delimiters-depth-2-face magenta-faint)
                       (rainbow-delimiters-depth-3-face cyan-faint)
                       (rainbow-delimiters-depth-4-face red-faint)
                       (rainbow-delimiters-depth-5-face yellow-faint)
                       (rainbow-delimiters-depth-6-face indigo)
                       (rainbow-delimiters-depth-7-face green-faint)
                       (rainbow-delimiters-depth-8-face blue-faint)
                       (rainbow-delimiters-depth-9-face rust)))
        (set-face-foreground face (modus-themes-get-color-value color t)))))
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

(use-package adaptive-wrap
  :hook ((prog-mode compilation-mode magit-status-mode markdown-mode) . adaptive-wrap-prefix-mode)
  :bind (:map my/toggles-map ("a" . adaptive-wrap-prefix-mode))
  :custom (adaptive-wrap-extra-indent 2))

(use-package flymake
  :ensure nil
  :no-require t
  :after modus-themes
  :hook prog-mode
  :bind (:map my/personal-map ("M-f" . flymake-show-buffer-diagnostics))
  :custom
  (flymake-no-changes-timeout 1)
  (flymake-show-diagnostics-at-end-of-line t)
  (flymake-indicator-type 'margins)
  (flymake-autoresize-margins nil)
  (flymake-margin-indicators-string
   '((note "●" flymake-note-echo)  ;; •
     (warning "▲" flymake-warning-echo)
     (error "◼" flymake-error-echo)))
  :preface
  (defun my/flymake-auto-adjust-margins (&rest _)
    "Dynamically resize the left margin based on the presence of diagnostics."
    (if flymake-mode
        (let ((new-width (if (flymake-diagnostics) 2 0)))
          (setq left-margin-width new-width))
      (setq left-margin-width 0))
    (dolist (win (get-buffer-window-list (current-buffer) nil t))
      (set-window-margins win left-margin-width)))
  (advice-add 'flymake--handle-report :after #'my/flymake-auto-adjust-margins)
  (defun my/customize-flymake ()
    (when (and (fboundp 'modus-themes-get-color-value)
               (facep 'flymake-end-of-line-diagnostics-face))
      (set-face-attribute 'flymake-end-of-line-diagnostics-face nil
                          :foreground (modus-themes-get-color-value 'fg-dim t)
                          :box '(:line-width (5 . -1) :style flat-button)
                          :height (round (* 0.92 (face-attribute 'default :height)))
                          :italic t
                          :inherit 'variable-pitch)
      (pcase-dolist (`(,face ,fg-color ,bg-color)
                     '((flymake-eol-information-face blue-faint   bg-blue-nuanced)
                       (flymake-note-echo-at-eol     cyan-faint   bg-cyan-nuanced)
                       (flymake-warning-echo-at-eol  yellow-faint bg-yellow-nuanced)
                       (flymake-error-echo-at-eol    red-faint    bg-red-nuanced)))
        (when (facep face)
          (set-face-attribute face nil
                              :extend t
                              :inherit 'flymake-end-of-line-diagnostics-face
                              :foreground (modus-themes-get-color-value fg-color t)
                              :background (modus-themes-get-color-value bg-color t))))))
  (defun my/flymake-hook ()
    (my/customize-flymake)
    (add-hook 'after-load-theme-hook #'my/customize-flymake nil t))
  (add-hook 'flymake-mode-hook #'my/flymake-hook))

(use-package flyspell
  :ensure nil
  :no-require t
  :init
  (add-hook 'text-mode flyspell-mode)
  ;; (add-hook 'prog-mode flyspell-prog-mode)
  :config (require 'ispell))

(use-package ispell
  :ensure nil
  :no-require t
  :custom
  (ispell-program-name "aspell")
  (ispell-local-dictionary-alist
   '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
  (ispell-dictionary "en_US")
  (ispell-local-dictionary "en_US"))


;; Lisp

(use-package emacs-lisp-mode
  :after my-keybindings
  :ensure nil
  :bind (:map my/personal-map ("(" . 'check-parens))
  :preface (add-hook 'emacs-lisp-mode-hook (lambda () (setq-local evil-shift-width 2))))


;; Vimscript

(use-package vimscript-ts-mode
  :ensure nil
  :mode "/\\.?\\(vimrc\\|vims?\\)\\'")


;; Python

(use-package python
  :ensure nil
  :no-require t
  :after treesit
  :preface (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode))
  :custom (python-check-command '("ruff" "--quiet" "--stdin-filename=stdin" "-"))
  :init
  (add-hook 'python-base-mode-hook (lambda () (hs-minor-mode -1)))
  (add-hook 'inferior-python-mode-hook
            (lambda () (add-to-list 'comint-output-filter-functions #'comint-truncate-buffer)))
  :config
  (add-to-list 'treesit-language-source-alist
               '(python "https://github.com/tree-sitter/tree-sitter-python"))
  (unless (treesit-language-available-p 'python)
    (treesit-install-language-grammar 'python)))

(use-package flymake-ruff
  :hook (python-base-mode . flymake-ruff-load)
  :custom (python-flymake-command python-check-command))

(use-package conda
  :preface
  (defun my/conda-env-activate-for-buffer ()
    (when (and (derived-mode-p 'python-base-mode)
               (bound-and-true-p conda-project-env-path)
               (not (string-equal conda-project-env-path
                                  (bound-and-true-p conda-env-current-name)))
               (not (string-equal conda-project-env-path
                                  (bound-and-true-p conda-env-current-path))))
      ;; (conda-mode-line-setup)
      (conda-env-activate-for-buffer)))
  (add-hook 'find-file-hook #'my/conda-env-activate-for-buffer)
  (defun my/conda-eglot-hook ()
    (let ((fn (lambda () (eglot-reconnect (eglot--current-server-or-lose)))))
      (add-hook 'conda-postactivate-hook fn nil t)
      (add-hook 'conda-postdeactivate-hook fn nil t)))
  (add-hook 'eglot-managed-mode-hook #'my/conda-eglot-hook)
  ;; :config
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-eshell)
  ;; (conda-env-autoactivate-mode 1)
  )


;; Bash

(use-package sh-script
  :ensure nil
  :no-require t
  :mode ("/\\.?\\(bashrc\\|bash_[^.]*\\)\\'" . sh-mode)
  :preface (add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode))
  :init
  ;; (add-hook 'sh-base-mode-hook #'flymake-mode-off)
  (add-hook 'sh-base-mode-hook (lambda () (hs-minor-mode -1)))
  :config
  (add-to-list 'treesit-language-source-alist
               '(bash "https://github.com/tree-sitter/tree-sitter-bash"))
  (unless (treesit-language-available-p 'bash)
    (treesit-install-language-grammar 'bash)))

(use-package flymake-bashate
  :commands flymake-bashate-setup
  :hook (sh-base-mode . flymake-bashate-setup))

;; YAML

(use-package yaml-ts-mode
  :ensure nil
  :no-require t
  :mode ("\\.yaml\\'" "\\.yml\\'")
  :preface
  (defun my/yaml-mode-hook ()
    (setq-local yaml-indent-offset 2)
    (variable-pitch-mode -1)
    (flyspell-mode -1))
  (add-hook 'yaml-ts-mode-hook #'my/yaml-mode-hook)
  :config
  (add-to-list 'treesit-language-source-alist
               '(yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml"))
  (unless (treesit-language-available-p 'yaml)
    (treesit-install-language-grammar 'yaml)))


;; XML

(use-package nxml-mode
  :ensure nil
  :no-require t
  :mode ("\\.xml\\'" "\\.urdf\\'" "\\.xacro\\'")
  :preface
  (defun my/nxml-mode-hook ()
    (setq-local standard-indent nxml-child-indent)
    (setq-local evil-shift-width nxml-child-indent)
    (setq-local nxml-attribute-indent nxml-child-indent)
    (flyspell-mode -1)
    (outline-minor-mode 1)
    (setq-local outline-regexp "[ \t]*<[^!?]*")
    (setq-local outline-heading-end-regexp ">[\n\r]")
    (setq-local outline-level
                (lambda ()
                  (+ 1 (/ (current-indentation) nxml-child-indent)))))
  :config (add-hook 'nxml-mode-hook #'my/nxml-mode-hook))


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
  (org-archive-location ".archive/%s_archive::")
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
  :ensure nil
  :load-path "site-lisp/"
  :hook (org-mode . my-org-mode))

(use-package org-indent
  :ensure nil
  :no-require t
  :preface
  (defun my/org-indent-set-line-properties-advice (orig-fn level indentation &optional heading)
    "Append an ellipsis specifically to the wrap-prefix property of the current line."
    (let ((beg (line-beginning-position))
          (end (line-beginning-position 2)))
      ;; The original function calculates and sets both line-prefix and wrap-prefix,
      ;; and then moves point to the next line via (forward-line).
      (funcall orig-fn level indentation heading)
      ;; We intercept the wrap-prefix it just set on the line, and append our ellipsis.
      (let ((wrap-prop (get-text-property beg 'wrap-prefix)))
        (when (stringp wrap-prop)
          (put-text-property beg end 'wrap-prefix (concat wrap-prop "…"))))))
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
