;;; package --- my config -*- lexical-binding: t -*-
;;; commentary:

;;; Code:


(use-package emacs
  :ensure nil
  :preface
  ;; Custom definitions
  (defun my/delete-back-to-indentation ()
    "Kill back to the first non-whitespace character."
    (interactive)
    (kill-line 0)
    (indent-for-tab-command))

  (defun my/quit-dwim ()
    "Close the current tab or frame."
    (interactive)
    (condition-case nil
        (tab-close)
      (error (condition-case nil
                 (delete-frame)
               (error nil)))))

  (defun my/edit-emacs-init ()
    "Edit `~/emacs.d/init.el'."
    (interactive)
    (let ((init-file-path "/Users/george/.dotfiles/emacs.d/init.el"))
      (unless (string-equal buffer-file-name init-file-path)
        (find-file-other-frame (expand-file-name "~/.emacs.d/init.el")))))

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

  (advice-add 'load-theme :after #'my/run-after-load-theme-hook)

  ;; Variable pitch
  (defun my/variable-pitch-line-spacing-advice (&rest _)
    "Set `line-spacing' when `variable-pitch-mode' is toggled."
    (if (and (bound-and-true-p buffer-face-mode)
             (equal buffer-face-mode-face 'variable-pitch))
        (when (boundp 'variable-pitch-line-spacing)
          (setq-local line-spacing variable-pitch-line-spacing))
      (setq line-spacing nil)))

  (advice-add 'variable-pitch-mode :after #'my/variable-pitch-line-spacing-advice)

  (add-hook 'Custom-mode-hook #'variable-pitch-mode)
  (add-hook 'Info-mode-hook #'variable-pitch-mode)
  (add-hook 'text-mode-hook #'variable-pitch-mode)
  (add-hook 'org-mode-hook #'variable-pitch-mode)

  ;; Startup time
  (defun my/display-startup-stats ()
    "Display startup stats."
    (message
     "%d packages loaded in %ss with %d garbage collections."
     (length package-activated-list)
     (emacs-init-time "%.2f")
     gcs-done))

  (add-hook 'emacs-startup-hook #'my/display-startup-stats)

  ;; Personal keymaps
  (defvar-keymap my/file-commands-map
    :doc "My file commands map."
    "r" '("recent files" . recentf))

  (defvar-keymap my/desktop-commands-map
    :doc "My desktop commands map."
    "r" '("read desktop". desktop-read)
    "s" '("save desktop". desktop-save))

  (defvar-keymap my/personal-map
    :doc "My prefix map."
    "f" `("prefix files" . ,my/file-commands-map)
    "d" `("prefix desktop" . ,my/desktop-commands-map)
    "w" 'whitespace-mode
    "C-d" 'help-follow-symbol)

  :bind-keymap ("C-c" . my/personal-map)

  :bind
  (("C-z" . nil) ;; don't suspend-frame
   ("S-<wheel-down>" . ignore)
   ("S-<wheel-up>" . ignore)
   ("C-<wheel-down>" . ignore)
   ("C-<wheel-up>" . ignore)
   ("M-<wheel-down>" . ignore)
   ("M-<wheel-up>" . ignore)
   ("C-<delete>" . ignore)
   ("C-<right>" . ignore)
   ("C-<left>" . ignore)
   ("C-<up>" . ignore)
   ("C-<down>" . ignore)
   ("M-<backspace>" . my/delete-back-to-indentation)
   ("M-<delete>" . kill-line)
   ("M-<right>" . end-of-visual-line)
   ("M-<left>" . beginning-of-visual-line)
   ("A-<backspace>" . backward-kill-word)
   ("A-<delete>" . kill-word)
   ("A-<kp-delete>" . kill-word)
   ("A-<right>" . right-word)
   ("A-<left>" . left-word)
   ("A-<escape>" . ns-next-frame)
   ("A-~" . ns-prev-frame)
   ("C-M-f" . toggle-frame-fullscreen)
   ("M-u" . universal-argument)
   ("M-c" . kill-ring-save)
   ("M-<escape>" . next-window-any-frame)
   ("M-~" . previous-window-any-frame)
   ("M-n" . make-frame)
   ("M-t" . tab-new)
   ("M-w" . my/quit-dwim)
   ("M-m" . iconify-frame)
   ("M-h" . ns-do-hide-emacs)
   ("M-," . my/edit-emacs-init)
   :map help-map
   ("=" . describe-char)
   :map minibuffer-mode-map
   ("<escape>" . abort-recursive-edit)
   ("C-u" . scroll-down-command)
   ("C-d" . scroll-up-command)
   ("<prior>" . scroll-down-command)
   ("<next>" . scroll-up-command))

  :custom
  ;; Less aggressive garbage collection on startup
  (gc-cons-threshold (* 100 1024 1024)) ;; 100 MB
  ;; Make native compilation quieter and asynchronous
  (native-comp-async-report-warnings-errors nil)
  (native-comp-deferred-compilation-deny-list '())
  (inhibit-startup-message t)
  (initial-scratch-message nil)
  (initial-major-mode 'fundamental-mode)
  (auto-save-visited-file-name t)
  (auto-save-timeout 1)
  (make-backup-files nil)
  (set-mark-command-repeat-pop t)
  (large-file-warning-threshold nil)
  (vc-follow-symlinks t)
  (ad-redefinition-action 'accept)
  (use-short-answers t)
  (confirm-kill-emacs #'yes-or-no-p)
  (global-auto-revert-non-file-buffers t)
  (scroll-margin 0)
  (hscroll-margin 0)
  (scroll-step 1)
  (hscroll-step 1)
  (line-spacing 2)
  (truncate-lines nil)
  (wrap-prefix "…")
  (left-margin-width 1)
  (right-margin-width 0)
  (indent-tabs-mode nil)
  (treemacs-no-png-images t)
  (major-mode-remap-alist
   '((python-mode . python-ts-mode)
     (sh-mode . bash-ts-mode)
     (yaml-mode . yaml-ts-mode)))


  :init ;; These settings are applied before emacs loads.
  ;; Set default values for variables
  (if (eq system-type 'darwin)
      (setq-default mac-mouse-wheel-smooth-scroll t
                    mouse-wheel-flip-direction t
                    mouse-wheel-tilt-scroll t
                    ns-command-modifier 'meta
                    ns-option-modifier 'alt
                    x-super-keysym 'alt))

  ;; UI Tweaks
  (unless (and (eq system-type 'darwin)
               (display-graphic-p))
    (menu-bar-mode 0))
  (tool-bar-mode 0)
  (scroll-bar-mode 0)
  (fringe-mode 0)
  (set-fill-column 79)
  (global-visual-line-mode 0)
  (xterm-mouse-mode 1)
  (column-number-mode 1)
  (pixel-scroll-precision-mode 1)

  ;; Display table for wrap prefix
  (set-display-table-slot standard-display-table 'wrap (string-to-char wrap-prefix))
  (set-display-table-slot standard-display-table 0 (string-to-char wrap-prefix))

  :config ;; These settings are applied after emacs loads.
  ;; Garbage collection reset
  (add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 800 1024))))

  ;; Basic fonts
  (when (eq system-type 'darwin)
    (set-face-attribute 'fixed-pitch nil :family "Menlo" :height 130)
    (set-face-attribute 'variable-pitch nil :family "Lucida Grande" :height 130))
  (when (eq system-type 'gnu/linux)
    (set-face-attribute 'fixed-pitch nil :family "Ubuntu Mono" :height 140)
    (set-face-attribute 'variable-pitch nil :family "Ubuntu" :height 130))
  (defconst variable-pitch-line-spacing 4)
  (copy-face 'fixed-pitch 'default)

  ;; Initialize package sources and set up `use-package'
  (require 'package)
  (setq package-archives '(("melpa" . "https://melpa.org/packages/")
                           ("org" . "https://orgmode.org/elpa/")
                           ("elpa" . "https://elpa.gnu.org/packages/")))

  (unless (package-installed-p 'use-package)
    (package-initialize)
    (unless package-archive-contents
      (setq package-check-signature nil)
      (package-refresh-contents)
      (package-install 'gnu-elpa-keyring-update)
      (setq package-check-signature 'allow-unsigned)
      (package-refresh-contents))
    (package-install 'use-package))

  (require 'use-package)
  (setq use-package-always-ensure t
        use-package-always-defer t))  ;; emacs


;; Basic packages

(use-package no-littering
  :demand t
  :custom
  (custom-file (no-littering-expand-var-file-name "custom.el"))
  :config
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
  :init (global-auto-revert-mode 1))

(use-package saveplace
  :after no-littering
  :ensure nil
  :init (save-place-mode 1))

(use-package savehist
  :after no-littering
  :ensure nil
  :custom
  (history-length 100)
  (savehist-autosave-interval 30)
  (savehist-save-minibuffer-history t)
  (history-delete-duplicates t)
  (savehist-additional-variables
   '(kill-ring
     search-ring
     regexp-search-ring))
  :init (savehist-mode 1))

(use-package recentf
  :after no-littering
  :ensure nil
  :init (recentf-mode 1)
  :config
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude (recentf-expand-file-name no-littering-etc-directory)))

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

(use-package modus-themes
  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-variable-pitch-ui t)
  (modus-themes-common-palette-overrides
   '((fringe unspecified)
     (bg-mode-line-active bg-dim)
     (bg-mode-line-inactive bg-main)
     (border-mode-line-active bg-mode-line-active)
     (border-mode-line-inactive bg-mode-line-inactive)
     (header-line bg-dim)
     (bg-tab-bar bg-main)
     (bg-tab-current bg-dim)
     (bg-tab-other bg-main)
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
  (modus-themes-headings
   '((1 . (1.06666))
     (2 . (1.06666))
     (3 . (1.06666))
     (4 . (1.0))
     (5 . (1.0))
     (6 . (1.0))
     (7 . (1.0))
     (8 . (1.0))))
  (org-todo-keyword-faces
   `(("WIP" . ,(modus-themes-get-color-value 'blue))
     ("FAIL" . ,(modus-themes-get-color-value 'red-intense))))
  :preface
  (setq modus-themes-to-toggle '(modus-operandi modus-vivendi-tinted))
  (defun my/apply-theme (appearance)
    (mapc 'disable-theme custom-enabled-themes)
    (pcase appearance
      ('light (modus-themes-load-theme (nth 0 modus-themes-to-toggle)))
      ('dark (modus-themes-load-theme (nth 1 modus-themes-to-toggle)))))
  (defun my/customize-modus-themes ()
    (set-face-foreground 'tab-bar-tab-inactive (modus-themes-get-color-value 'fg-dim))
    (let ((bold-p nil))
      (set-face-bold 'tab-bar bold-p)
      (set-face-bold 'tab-bar-tab bold-p)
      (set-face-bold 'tab-bar-tab-inactive bold-p))
    (let ((family (face-attribute 'variable-pitch :family)))
      (dolist (face
               '(modus-themes-button
                 tab-bar
                 tab-bar-tab
                 tab-bar-tab-inactive
                 header-line
                 header-line-highlight
                 mode-line
                 mode-line-highlight
                 mode-line-active
                 mode-line-inactive))
        (set-face-attribute face nil :family family)))
    (let ((box-released '(:line-width 2 :style released-button))
          ;; (box-pressed '(:line-width 2 :style pressed-button))
          (box-thinner '(:line-width (1 . 2) :style released-button)))
      (dolist (face
               '(modus-themes-button
                 tab-bar-tab-inactive
                 header-line
                 mode-line
                 mode-line-active
                 mode-line-inactive))
        (set-face-attribute face nil :box box-released))
      (set-face-attribute 'tab-bar-tab nil :box box-released)
      (set-face-attribute 'mode-line-highlight nil :box box-thinner)
      (set-face-attribute 'header-line-highlight nil :box box-thinner)))
  (add-hook 'after-load-theme-hook #'my/customize-modus-themes)
  :init
  (let ((theme (nth 0 modus-themes-to-toggle)))
    (if (not (fboundp 'modus-themes-load-theme))
        (load-theme theme)
      (modus-themes-load-theme theme)))
  (when (fboundp 'modus-themes-load-theme)
    (add-hook 'ns-system-appearance-change-functions #'my/apply-theme)))

(use-package ns-auto-titlebar
  :if (eq system-type 'darwin)
  :init (ns-auto-titlebar-mode))

(use-package stripes
  :hook (dired-mode)  ;; minibuffer-mode vertico-mode corfu-popupinfo-mode
  :bind (:map my/personal-map ("s" . stripes-mode))
  :custom
  (stripes-unit 1)
  (stripes-overlay-priority -100)
 :preface
  (defun my/customize-stripes ()
    (set-face-background 'stripes (modus-themes-get-color-value 'bg-dim)))
  (when (fboundp 'modus-themes-get-color-value)
    (add-hook 'stripes-mode-hook #'my/customize-stripes)))

(use-package tab-bar-mode
  :ensure nil
  :custom
  (tab-bar-show 1)
  (tab-bar-new-button-show nil)
  (tab-bar-close-button-show nil)
  (tab-bar-separator " ")
  (tab-bar-auto-width t)
  (tab-bar-auto-width-max nil)
  ;; (tab-bar-tab-name-truncated-max 200)
  (tab-bar-format
   '(tab-bar-format-tabs
     tab-bar-format-align-right
     tab-bar-format-global))
  :preface
  (defun my/prepend-whitespace (string _ _)
    "Just append and prepend spaces to a STRING."
    (concat " " string))
  ;; (add-to-list 'tab-bar-tab-name-format-functions #'tab-bar-tab-name-format-truncated)
  (add-to-list 'tab-bar-tab-name-format-functions #'my/prepend-whitespace)
  (add-hook 'desktop-after-read-hook #'tab-bar-mode))

(use-package doom-modeline
  ;; NEEDS: M-x nerd-icons-install-fonts
  :custom
  (doom-modeline-bar-width 0.1)
  (doom-modeline-height 0)
  (doom-modeline-window-width-limit 50)
  (doom-modeline-icon nil)
  (doom-modeline-modal-icon nil)
  (doom-modeline-workspace-name nil)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-buffer-modification-icon nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-env-version nil)
  (doom-modeline-lsp-icon nil)
  (doom-modeline-check-icon nil)
  (doom-modeline-check-simple-format t)
  (doom-modeline-spc-face-overrides (list :family (face-attribute 'fixed-pitch :family)))
  :preface
  (defun my/customize-doom-modeline ()
    (when (bound-and-true-p doom-modeline-mode)
      (set-face-background 'doom-modeline-bar (face-background 'mode-line))
      (set-face-background 'doom-modeline-bar-inactive (face-background 'mode-line-inactive)))
    (doom-modeline-mode t))
  (add-hook 'after-load-theme-hook #'my/customize-doom-modeline)
  :init
  (my/customize-doom-modeline))

(use-package dired
  :ensure nil
  :bind (:map dired-mode-map ("b" . dired-up-directory))
  :custom
  (dired-listing-switches "-alv --group-directories-first")
  (dired-omit-files "^\\.[^.].*")
  (dired-omit-verbose nil)
  (dired-dwim-target 'dired-dwim-target-next)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-kill-when-opening-new-dired-buffer t)
  (delete-by-moving-to-trash t)
  :preface
  (defun my/dired-mode-hook ()
    (dired-hide-details-mode 1)
    (hl-line-mode 1))
  (add-hook 'dired-mode-hook #'my/dired-mode-hook))

(use-package undo-tree
  :custom
  (undo-tree-auto-save-history t)
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  :preface
  (defun my/silent-undo-tree-save-history (undo-tree-save-history &rest args)
    (let ((message-log-max nil)
          (inhibit-message t))
      (apply undo-tree-save-history args)))
  :init
  (advice-add 'undo-tree-save-history :around #'my/silent-undo-tree-save-history)
  (global-undo-tree-mode))

(use-package evil
  :init
  (setq evil-toggle-key "C-<escape>"
        evil-want-integration t
        evil-want-keybinding nil
        evil-disable-insert-state-bindings t
        evil-want-C-u-scroll t
        evil-cross-lines t
        evil-symbol-word-search t
        evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)
  (evil-set-initial-state 'prog-mode 'normal)
  (global-set-key [remap evil-visual-block] #'scroll-up-command)
  (global-set-key [remap kill-ring-save] #'evil-yank)
  (global-set-key [remap my/quit-dwim] #'evil-quit)
  (global-set-key [remap my/delete-back-to-indentation] #'evil-delete-back-to-indentation)
  (global-set-key [remap backward-kill-word] #'evil-delete-backward-word)
  (evil-global-set-key 'motion (kbd "j") #'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "k") #'evil-previous-visual-line)
  (evil-global-set-key 'motion (kbd "<down>") #'evil-next-visual-line)
  (evil-global-set-key 'motion (kbd "<up>") #'evil-previous-visual-line)
  (evil-global-set-key 'normal (kbd "<tab>") #'evil-toggle-fold)
  (evil-global-set-key 'normal (kbd "C-i") #'evil-jump-forward)
  (evil-global-set-key 'visual (kbd "p") #'evil-paste-before)
  (evil-global-set-key 'visual (kbd "P") #'evil-visual-paste))

(use-package evil-collection
  :after evil
  :init (evil-collection-init))

(use-package evil-surround
  :init (global-evil-surround-mode 1))

(use-package corfu
  :bind
  (:map corfu-map
        ("<tab>" . 'ignore)
        ;; ("<tab>" . corfu-next)
        ;; ("S-<tab>" . corfu-previous)
        ;; ("RET" . nil)
        ;; ("C-e" . corfu-popupinfo-scroll-up)
        ;; ("C-y" . corfu-popupinfo-scroll-down)
        ("C-d" . corfu-scroll-up)
        ("C-u" . corfu-scroll-down)
        ("<next>" . corfu-scroll-up)
        ("<prior>" . corfu-scroll-down)
        ("S-SPC" . corfu-insert-separator))
  :custom
  (corfu-auto t)  ;; auto-completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  ;; (corfu-preselect 'prompt)
  (corfu-preview-current 'insert)  ;; insert previewed candidate
  (corfu-on-exact-match nil)  ;; Don't auto expand tempel snippets
  (corfu-cycle t)
  (global-corfu-minibuffer t)
  ;; Enable Corfu in all minibuffers, as long as no completion UI is active
  ;; (global-corfu-minibuffer
  ;;  (lambda () (not (or (bound-and-true-p mct--active)
  ;;                      (bound-and-true-p vertico--input)
  ;;                      (eq (current-local-map) read-passwd-map)))))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  (corfu-history-mode))

(use-package vertico
  :custom
  (vertico-scroll-margin 1)
  (vertico-mouse-mode t)
  (vertico-count 10)  ;; Limit to a fixed size
  (vertico-cycle t)  ;; Enable cycling for `vertico-next/previous'
  (vertico-resize 'grow-only)  ;; Grow and shrink the Vertico minibuffer
  :init (vertico-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil  ;; comes with vertico
  :bind (:map vertico-map ("DEL" . vertico-directory-delete-char)))

(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-a" . marginalia-cycle))
  :custom (marginalia-field-width 180)
  :preface
  (defun my/marginalia-mode-hook ()
    (set-face-attribute 'marginalia-documentation nil
                        :family (face-attribute 'variable-pitch :family)))
  (add-hook 'after-load-theme-hook #'my/marginalia-mode-hook)
  :init
  (marginalia-mode)
  (my/marginalia-mode-hook))

(use-package orderless
  :custom
  ;; Actvate orderless completion
  (completion-styles '(orderless substring basic))
  ;; Enable partial completion for file wildcard support
  (completion-category-overrides '((file (styles partial-completion)))))

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
  :config
  ;; The configuration values are evaluated at runtime, just before the
  ;; completion session is started. Therefore you can use for example
  ;; `thing-at-point' to adjust the initial input or the future history.
  (consult-customize consult-line
                     :add-history (seq-some 'thing-at-point '(region symbol)))
  (defalias 'consult-line-thing-at-point 'consult-line)
  (consult-customize consult-line-thing-at-point
                     :initial (thing-at-point 'symbol))
  (add-to-list 'consult-preview-allowed-hooks #'my/org-mode-hook))

(use-package embark
  :bind
  (("C-h B" . embark-bindings)  ;; alternative for `describe-bindings'
   :map minibuffer-local-map
   ("C-c" . embark-act)  ;; begin the embark process
   ("C-<return>" . embark-dwim))  ;; run the default action
  )

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package helpful
  :commands
  (helpful-callable
   helpful-function
   helpful-command
   helpful-variable
   helpful-key
   helpful-at-point)
  :bind
  (([remap describe-function] . helpful-function)
   ([remap describe-command] . helpful-command)
   ([remap describe-variable] . helpful-variable)
   ([remap describe-key] . helpful-key)
   ([remap help-follow-symbol] . helpful-at-point))
  :custom (warning-minimum-level :error))

(use-package which-key
  :custom (which-key-idle-delay 1)
  :init (which-key-mode))

(use-package diff-hl
  :custom
  (diff-hl-draw-borders nil)
  :preface
  (defun my/customize-diff-hl ()
    (setf (alist-get 'change diff-hl-margin-symbols-alist nil nil #'equal) "~")
    (face-remap-add-relative 'diff-hl-change 'diff-changed)
    (face-remap-add-relative 'diff-hl-insert 'diff-added)
    (face-remap-add-relative 'diff-hl-delete 'diff-removed))
  (defun my/diff-hl-hook ()
    (my/customize-diff-hl)
    (add-hook 'auto-save-hook 'diff-hl-update nil t)
    (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh nil t)
    (add-hook 'after-load-theme-hook #'my/customize-diff-hl))
  (add-hook 'diff-hl-mode-hook #'my/diff-hl-hook)
  :init
  (global-diff-hl-mode 1)
  (diff-hl-margin-mode 1))

(use-package magit
  :bind
  (:map my/personal-map
        ("m" . magit)
        :map magit-mode-map
        ("M-n" . nil)
        ("M-w" . nil)
        :map magit-section-mode-map
        ("<tab>" . magit-section-toggle)
        ("C-<tab>" . nil))
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (when (bound-and-true-p evil-mode)
    (evil-define-key 'normal magit-section-mode-map (kbd "C-<tab>") nil)))


;; Programming

(use-package eglot
  :ensure nil
  :no-require t
  :hook ((python-base-mode sh-base-mode LaTeX-mode) . eglot-ensure)
  :bind (:map eglot-mode-map ("C-c rn" . eglot-rename))
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-extend-to-xref nil)
  (eglot-prefer-plaintext t)
  (eglot-send-changes-idle-time 1)
  (eglot-ignored-server-capabilities
   '(:codeLensProvider
     :codeActionProvider
     ;; :colorProvider
     :foldingRangeProvider
     :executeCommandProvider))
  ;; :preface
  ;; (defun my/eglot-mode-hook ()
  ;;   (add-hook 'flymake-diagnostic-functions #'eglot-flymake-backend nil t)
  ;;   (flymake-mode 1))
  ;; :init
  ;; (setq eglot-stay-out-of '(flymake))
  ;; (add-hook 'eglot-managed-mode-hook #'my/eglot-mode-hook)
  :config (add-to-list 'eglot-server-programs
                       `(python-base-mode . ("pyright-langserver" "--stdio"))))

(use-package prog-mode
  :ensure nil
  :preface
  (defun my/prog-mode-hook ()
    (electric-pair-mode 1)
    (hs-minor-mode 1)
    (setq show-trailing-whitespace t)
    ;; (modify-syntax-entry ?- "w")
    (modify-syntax-entry ?_ "w"))
  (add-hook 'prog-mode-hook #'my/prog-mode-hook))

(use-package outline-indent
  :hook ((conf-mode yaml-ts-mode python-base-mode) . outline-indent-minor-mode)
  :custom (outline-blank-line t)
  ;; (outline-indent-ellipsis " ▼")
  )

(use-package rainbow-mode)

(use-package rainbow-delimiters
  :hook prog-mode
  :preface
  (defun my/customize-rainbow-delimiters ()
    (seq-mapn
     (lambda (face color)
       (set-face-foreground face (modus-themes-get-color-value color)))
     '(rainbow-delimiters-depth-1-face
       rainbow-delimiters-depth-2-face
       rainbow-delimiters-depth-3-face
       rainbow-delimiters-depth-4-face
       rainbow-delimiters-depth-5-face
       rainbow-delimiters-depth-6-face
       rainbow-delimiters-depth-7-face
       rainbow-delimiters-depth-8-face
       rainbow-delimiters-depth-9-face)
     '(fg-dim
       magenta-faint
       cyan-faint
       red-faint
       yellow-faint
       indigo
       green-faint
       blue-faint
       rust)))
  (defun my/rainbow-delimiters-hook ()
    (my/customize-rainbow-delimiters)
    (when (fboundp 'modus-themes-get-color-value)
      (add-hook 'after-load-theme-hook #'my/customize-rainbow-delimiters nil t)))
  (add-hook 'rainbow-delimiters-mode-hook #'my/rainbow-delimiters-hook))

(use-package indent-bars
  :hook (prog-mode yaml-ts-mode)
  :custom
  (indent-bars-display-on-blank-lines nil)
  ;; (indent-bars-no-descend-lists t)  ;; no extra bars in contd. func. args
  (indent-bars-treesit-support t)
  ;; (indent-bars-treesit-scope
  ;;  '((python
  ;;     function_definition class_definition
  ;;     for_statement if_statement with_statement while_statement)))
  (indent-bars-prefer-character t)
  (indent-bars-color '(highlight :face default :blend 0.2))
  (indent-bars-zigzag nil)
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-display-on-blank-lines nil))

(use-package flymake
  :ensure nil
  :hook prog-mode
  :bind (:map flymake-mode-map ("C-c M-f" . flymake-show-buffer-diagnostics))
  :custom
  (flymake-no-changes-timeout 1)
  (flymake-show-diagnostics-at-end-of-line t)
  (flymake-indicator-type 'margins)
  (flymake-margin-indicators-string
   '((note "i" flymake-note-echo)
     (warning "!" flymake-warning-echo)
     (error "!" flymake-error-echo)))
  :preface
  (defun my/customize-flymake ()
    (set-face-attribute 'flymake-end-of-line-diagnostics-face nil
                        :foreground (modus-themes-get-color-value 'fg-dim)
                        :box '(:line-width (5 . -1) :style flat-button)
                        :height 120
                        :italic t
                        :inherit 'variable-pitch)
    (dolist (face
             '(flymake-eol-information-face
               flymake-note-echo-at-eol
               flymake-warning-echo-at-eol
               flymake-error-echo-at-eol))
      (set-face-attribute face nil :inherit 'flymake-end-of-line-diagnostics-face))
    (set-face-attribute 'flymake-eol-information-face nil
                        :foreground (modus-themes-get-color-value 'blue-faint)
                        :background (modus-themes-get-color-value 'bg-blue-nuanced))
    (set-face-attribute 'flymake-note-echo-at-eol nil
                        :foreground (modus-themes-get-color-value 'cyan-faint)
                        :background (modus-themes-get-color-value 'bg-cyan-nuanced))
    (set-face-attribute 'flymake-warning-echo-at-eol nil
                        :foreground (modus-themes-get-color-value 'yellow-faint)
                        :background (modus-themes-get-color-value 'bg-yellow-nuanced))
    (set-face-attribute 'flymake-error-echo-at-eol nil
                        :foreground (modus-themes-get-color-value 'red-faint)
                        :background (modus-themes-get-color-value 'bg-red-nuanced))
    (set-face-attribute 'flymake-note-echo nil :inherit 'flymake-note-echo-at-eol)
    (set-face-attribute 'flymake-warning-echo nil :inherit 'flymake-warning-echo-at-eol)
    (set-face-attribute 'flymake-error-echo nil :inherit 'flymake-error-echo-at-eol)
    (dolist (face
             '(flymake-note-echo
               flymake-warning-echo
               flymake-error-echo))
      (set-face-attribute face nil
                          :italic nil :bold t
                          :box '(:line-width (1 . -1) :style flat-button)))
    )
  (defun my/flymake-hook ()
    (when (fboundp 'modus-themes-get-color-value)
      (my/customize-flymake)
      (add-hook 'after-load-theme-hook #'my/customize-flymake nil t)))
  ;; (add-hook 'sh-base-mode-hook #'flymake-mode-off)
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
  :custom
  (ispell-program-name "aspell")
  (ispell-local-dictionary-alist
   '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
  (ispell-dictionary "en_US")
  (ispell-local-dictionary "en_US"))


;; Lisp

(use-package emacs-lisp-mode
  :ensure nil
  :bind (:map my/personal-map ("(" . 'check-parens))
  :custom (evil-shift-width 2)
  :preface (add-hook 'emacs-lisp-mode-hook (lambda () (indent-bars-mode -1))))


;; Python

(use-package python
  :custom (python-check-command '("ruff" "--quiet" "--stdin-filename=stdin" "-"))
  :init (add-hook 'python-base-mode-hook (lambda () (hs-minor-mode -1))))

(use-package flymake-ruff
  :hook (python-base-mode . flymake-ruff-load)
  :custom (python-flymake-command python-check-command)
  :preface
  (defun my/eglot-python-flymake-hook ()
    (when (derived-mode-p 'python-base-mode)
      (add-hook 'flymake-diagnostic-functions #'python-flymake nil t)
      (add-hook 'flymake-diagnostic-functions #'flymake-ruff--run-checker nil t)))
  (add-hook 'eglot-managed-mode-hook #'my/eglot-python-flymake-hook))

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
  ;; :config
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-eshell)
  ;; (conda-env-autoactivate-mode t)
  )


;; YAML

(use-package yaml-ts-mode
  :ensure nil
  :no-require t
  :mode ("\\.yaml$" "\\.yml$")
  :custom (tab-width 2)
  :preface
  (defun my/yaml-mode-hook ()
    (setq yaml-indent-offset 2)
    (variable-pitch-mode -1)
    (flyspell-mode -1))
  (add-hook 'yaml-ts-mode-hook #'my/yaml-mode-hook))


;; Bash

(use-package sh-mode
  :ensure nil
  :mode ("/\\.?\\(bashrc\\|bash_.*\\)\\'" . sh-mode))


;; LaTeX

(use-package auctex
  :ensure nil
  :custom
  (preview-auto-cache-preamble t)
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-command-extra-options "-shell-escape")
  (preview-default-option-list '("displaymath" "floats" "graphics" "textmath" "footnotes"))
  (preview-preserve-counters t)
  (preview-scale-function 1.75)
  (preview-image-type 'dvisvgm)
  :preface
  (defun my/LaTeX-mode-hook ()
    (outline-minor-mode 1)
    (LaTeX-math-mode 1)
    (turn-on-reftex)
    (TeX-PDF-mode -1))
  (add-hook 'LaTeX-mode-hook #'my/LaTeX-mode-hook)
  (add-hook 'TeX-after-compilation-finished-functions-hook #'TeX-revert-document-buffer))

(use-package preview-dvisvgm
  :after preview-latex)


;; Org

(use-package org
  :ensure nil
  :bind
  (:map org-mode-map
        ("C-c a" . org-agenda)
        ("C-c C-x m" . #'my/org-toggle-emphasis-marker-display)
        ("C-c C-x l" . #'org-toggle-link-display)
        ([remap org-emphasize] . my/org-emphasize-dwim))
  :custom
  ;; (org-startup-with-latex-preview t)
  (org-startup-with-inline-images t)
  (org-startup-truncated nil)
  (org-startup-folded 'content)
  (org-startup-indented t)
  ;; (org-indent-mode-turns-on-hiding-stars nil)
  (org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
  (org-cycle-separator-lines 1)
  (org-preview-latex-image-directory (no-littering-expand-var-file-name "ltximg/"))
  (org-agenda-files '("~/Documents/org" "~/Desktop"))
  (org-todo-keywords '((sequence "TODO" "WIP" "|" "DONE" "SKIP" "FAIL")))
  (org-log-done t)
  (org-hide-emphasis-markers t)
  (org-fontify-todo-headline nil)
  (org-fontify-done-headline t)
  (org-latex-create-formula-image-program 'dvisvgm)
  :preface
  (defun my/org-emphasize-dwim (&optional char)
    "DWIM (Do What I Mean) wrapper for `org-emphasize'.
If there's an active region, apply emphasis to it.
Otherwise, apply emphasis to the word at point.
CHAR is the emphasis character to use."
    (interactive)
    (if (use-region-p)
        (org-emphasize char)
      (save-excursion
        (let ((bounds (bounds-of-thing-at-point 'word)))
          (when bounds
            (goto-char (car bounds))
            (set-mark (cdr bounds))
            (org-emphasize char)
            (deactivate-mark))))))
  (defun my/org-toggle-emphasis-marker-display ()
    "Toggle emphasis marker visibility."
    (interactive)
    (setq org-hide-emphasis-markers (not org-hide-emphasis-markers))
    (font-lock-update)
    (message "Emphasis markers are now %s." (if org-hide-emphasis-markers "hidden" "visible")))
  (defun my/org-latex-preview-buffer ()
    "Prevew all LaTeX fragments in buffer."
    (interactive)
    (org-latex-preview '(16)))
  (defun my/customize-org-mode ()
    "Apply my tweaks to theme-controlled settings."
    (interactive)
    (set-face-attribute 'org-headline-done nil
                        :strike-through t
                        :family (face-attribute 'variable-pitch :family))
    (set-face-bold 'org-checkbox t)
    (let ((bg-color (face-background 'org-agenda-clocking)))
      (setf (alist-get "_" org-emphasis-alist nil nil #'equal) `((:background ,bg-color))))
    (dolist (face
             '(org-table
               org-todo
               org-done
               org-checkbox))
      (set-face-attribute face nil :family (face-attribute 'fixed-pitch :family)))
    (font-lock-update))
  (defun my/org-mode-hook ()
    ;; (auto-fill-mode 1)
    (my/customize-org-mode)
    (add-hook 'after-load-theme-hook #'my/customize-org-mode nil t)
    (dolist (hook
             '(after-load-theme-hook
               find-file-hook
               auto-save-hook
               after-save-hook))
      (add-hook hook #'my/org-latex-preview-buffer nil t)))
  (add-hook 'org-mode-hook #'my/org-mode-hook)
  :config (setq org-format-latex-options (plist-put org-format-latex-options :scale 0.6)))


(provide 'init)
;;; init.el ends here

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
