;;; package --- my config -*- lexical-binding: t -*-
;;; commentary:

;;; Code:

(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :family "Menlo" :height 140))
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil :family "Ubuntu Mono" :height 150))

;; Global key mappings
(keymap-global-set "C-z" nil)

(when (eq system-type 'darwin)
  (setq ns-option-modifier 'alt)
  (setq ns-command-modifier 'meta)
  (keymap-global-set "M-<backspace>" 'evil-delete-back-to-indentation)
  (keymap-global-set "A-<backspace>" 'backward-kill-word)
  (keymap-global-set "M-<delete>" 'kill-line)
  (keymap-global-set "A-<kp-delete>" 'kill-word)
  (keymap-global-set "M-<right>" 'end-of-visual-line)
  (keymap-global-set "A-<right>" 'right-word)
  (keymap-global-set "M-<left>" 'beginning-of-visual-line)
  (keymap-global-set "A-<left>" 'left-word)
  (keymap-global-set "C-M-f" 'toggle-frame-fullscreen)
  (keymap-global-set "M-n" 'make-frame)
  (keymap-global-set "M-t" 'tab-new)
  ;; (keymap-global-set "M-q" 'save-buffers-kill-emacs)
  (keymap-global-set "M-w" 'my/close-tab-window-frame)
  (defun my/close-tab-window-frame ()
    "Close current tab or window or frame."
    (interactive)
    ;; (unless (derived-mode-p 'special-mode)
    ;;   (save-buffer)
    (condition-case nil
        (tab-close)
      (error
      (condition-case nil
          (delete-frame)
        (error nil)))))
  )

(defvar-keymap my-file-utils-map
  :doc "My file utilities map."
  "r" '("recent files" . recentf)
  "i" '("init.el" . (lambda ()
                      (interactive)
                      (find-file (expand-file-name "~/.emacs.d/init.el")))))
(defvar-keymap my-personal-map
  :doc "My prefix map."
  "m" 'magit
  "f" `("prefix files" . ,my-file-utils-map))

(defvar my/prefix "C-c")
(keymap-set global-map my/prefix my-personal-map)

(setq inhibit-startup-message t
      auto-save-default nil
      make-backup-files nil
      set-mark-command-repeat-pop t
      large-file-warning-threshold nil
      vc-follow-symlinks t
      ad-redefinition-action 'accept
      global-auto-revert-non-file-buffers t
      auto-hscroll-mode nil
      savehist-autosave-interval 30)

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(unless (eq system-type 'darwin)
  ;; (tooltip-mode 0)
  ;; (setq visible-bell t)
  (menu-bar-mode 0))
(set-fringe-mode 16)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(global-visual-line-mode 0)
(xterm-mouse-mode 1)
(savehist-mode 1)  ;; history-length = 100
(save-place-mode 1)
(recentf-mode 1)
(global-auto-revert-mode 1)
(column-number-mode 1)

(setq-default
 ;; global-display-line-numbers-mode t
 indent-tabs-mode nil)

;; Move customization settings out of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(unless (file-exists-p custom-file)
  (write-region "" nil custom-file))
(load custom-file nil t)


;; Initialize package sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
  (setq package-check-signature nil)
  (package-refresh-contents)
  (package-install 'gnu-elpa-keyring-update)
  (setq package-check-signature 'allow-unsigned)
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t)

(use-package no-littering
  :ensure nil
  :no-require t
  :custom
  ;; no-littering doesn't set this by default so we must place
  ;; auto save files in the same path as it uses for sessions
  (auto-save-file-name-transforms
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

(use-package modus-themes
  :ensure t
  :hook (ns-system-appearance-change-functions . my/apply-theme)
  :preface
  (defun my/apply-theme (appearance)
    (mapc 'disable-theme custom-enabled-themes)
    (add-to-list 'default-frame-alist `(ns-appearance . ,appearance))
    (pcase appearance
      ('light (load-theme 'modus-operandi))
      ('dark (load-theme 'modus-vivendi-tinted))))
  :custom
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-common-palette-overrides
   '((fringe unspecified)
     ;; (border-mode-line-active unspecified)
     ;; (border-mode-line-inactive unspecified)
     (border-mode-line-active bg-mode-line-active)
     (border-mode-line-inactive bg-mode-line-inactive)
     ))
  :init (load-theme 'modus-operandi))

(use-package tab-bar-mode
  :ensure nil
  :no-require t
  :hook after-init
  :preface
  (defun my/surround-in-whitespace (string _ _)
    "Just apprend and prepend spaces to a STRING."
    (concat " " string " "))
  (add-to-list 'tab-bar-tab-name-format-functions
               'my/surround-in-whitespace)
  :custom
  (tab-bar-show 1)
  (tab-bar-format '(tab-bar-format-history tab-bar-format-tabs))
  (tab-bar-auto-width-max '((2000) 20))
  (tab-bar-close-button-show nil)
  (tab-bar-separator t))

(use-package doom-modeline
  ;; needs: M-x nerd-icons-install-fonts
  :hook after-init
  :custom
  (doom-modeline-window-width-limit 50)
  (doom-modeline-workspace-name nil)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-lsp-icon nil)
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-env-version nil)
  (doom-modeline-buffer-modification-icon nil)
  (doom-modeline-check-icon nil)
  (doom-modeline-check-simple-format t))

;; (use-package doom-themes
;;   ;; :init (load-theme 'doom-palenight t))
;;   :custom
;;   (doom-themes-treemacs-enable-variable-pitch nil)
;;   (doom-themes-treemacs-theme "doom-atom")
;;   :config (doom-themes-treemacs-config)
;;   )

;; (use-package all-the-icons
;;   ;; needs: M-x all-the-icons-install-fonts
;;   :if (display-graphic-p))

(use-package treemacs
  :ensure nil
  :no-require t
  :custom
  ;; (use-package treemacs-nerd-icons
  ;;   :after treemacs
  ;;   :init (treemacs-load-theme "nerd-icons"))
  (treemacs-no-png-images t))

(use-package dired
  :ensure nil
  :custom
  (dired-listing-switches "-alv --group-directories-first")
  (dired-omit-files "^\\.[^.].*")
  (dired-omit-verbose nil)
  (dired-dwim-target 'dired-dwim-target-next)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-kill-when-opening-new-dired-buffer t)
  (delete-by-moving-to-trash t)
  ;; :bind (:map dired-mode-map ("b" . dired-up-directory))
  :init
  (add-hook 'dired-mode-hook 'dired-hide-details-mode)
  (add-hook 'dired-mode-hook 'hl-line-mode))

(use-package corfu
  :custom
  (corfu-auto t)  ;; auto-completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  ;; (corfu-preselect 'prompt)
  (corfu-preview-current 'insert)  ;; insert previewed candidate
  (corfu-on-exact-match nil)  ;; Don't auto expand tempel snippets
  (corfu-cycle t)
  ;; (global-corfu-minibuffer
  ;;  (lambda ()
  ;;    (not (or (bound-and-true-p mct--active)
  ;;             (bound-and-true-p vertico--input)
  ;;             (eq (current-local-map) read-passwd-map)))))
  :bind
  (:map corfu-map
        ;; ("TAB" . corfu-next)
        ;; ("S-TAB" . corfu-previous)
        ;; ("RET" . corfu-complete)
        ("S-SPC" . corfu-insert-separator)
        ("RET" . nil)
        ;; ("C-e" . corfu-popupinfo-scroll-up)
        ;; ("C-y" . corfu-popupinfo-scroll-down)
        ;; Explicitly set for minibuffer compatibility
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous))
  :init
  (global-corfu-mode)
  (corfu-popupinfo-mode)
  (corfu-history-mode))

(use-package vertico
  :custom
  (vertico-count 10)  ;; limit to a fixed size
  (vertico-cycle t)  ;; limit to a fixed size
  :init (vertico-mode))

(use-package vertico-directory
  :after vertico
  :ensure nil  ;; comes with vertico
  :bind (:map vertico-map ("DEL" . vertico-directory-delete-char)))

(use-package savehist
  :init (savehist-mode))

(use-package marginalia
  :after vertico
  ;; :custom
  ;; (marginalia-annotators
  ;;  '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init (marginalia-mode))

(use-package orderless
  :custom
  ;; Actvate orderless completion
  (completion-styles '(orderless substring basic))
  ;; Enable partial completion for file wildcard support
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package consult
  :after vertico
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add 'register-preview :override 'consult-register-window)
  (setq register-preview-delay 0.5)
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function 'consult-xref
        xref-show-definitions-function 'consult-xref)
  :bind
  (([remap Info-search] . consult-info)
   ("C-x b" . consult-buffer)
   ("M-G" . consult-git-grep)
   ("M-g f" . consult-flymake)
   ("M-g g" . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ;; Isearch integration
   ("C-s" . consult-line)
   ("C-M-s" . consult-line-multi)
   :map isearch-mode-map
   ("C-s" . consult-isearch-history)
   :map minibuffer-local-map
   ("C-s" . consult-history)
   ;; :map my-file-utils-map
   ;; ("r" . consult-recent-file)
   )
  :config
  ;; The configuration values are evaluated at runtime, just before the
  ;; completion session is started. Therefore you can use for example
  ;; `thing-at-point' to adjust the initial input or the future history.
  (consult-customize
   consult-line
   :add-history (seq-some 'thing-at-point '(region symbol)))
  (defalias 'consult-line-thing-at-point 'consult-line)
  (consult-customize
   consult-line-thing-at-point
   :initial (thing-at-point 'symbol)))

(use-package embark
  :bind
  (;; ("C-."   . embark-act) ;; Begin the embark process
   ;; ("C-;"   . embark-dwim)  ;; good alternative: M-.
   ("C-h B" . embark-bindings)))  ;; alternative for `describe-bindings'

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
   ("C-h F" . helpful-function)
   :map my-personal-map
   ("C-d" . helpful-at-point))
  :custom (warning-minimum-level :error))

(use-package which-key
  :init (which-key-mode)
  :custom (which-key-idle-delay 1))

(use-package undo-tree
  :hook after-init
  :preface
  (defun my/silent-undo-tree-save-history (undo-tree-save-history &rest args)
    (let ((message-log-max nil)
          (inhibit-message t))
      (apply undo-tree-save-history args)))
  :custom
  (undo-tree-auto-save-history t)
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  :init
  (advice-add 'undo-tree-save-history :around 'my/silent-undo-tree-save-history)
  (global-undo-tree-mode))

(use-package evil
  :demand t
  :init
  (setq evil-toggle-key "C-<escape>"
        evil-want-integration t
        evil-want-keybinding nil
        evil-disable-insert-state-bindings t
        evil-want-C-u-scroll t
        evil-cross-lines t
        evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)
  (keymap-global-set "M-q" 'save-buffers-kill-emacs)
  (global-set-key [remap evil-quit] 'kill-buffer-and-window)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "<tab>") 'evil-toggle-fold)
  (define-key evil-normal-state-map (kbd "C-i") 'evil-jump-forward)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (define-key minibuffer-local-map (kbd "C-n") 'next-line-or-history-element)
  (define-key minibuffer-local-map (kbd "C-p") 'previous-line-or-history-element)
  (define-key minibuffer-local-map (kbd "C-h") 'delete-backward-char)
  (define-key minibuffer-local-map (kbd "<escape>") 'keyboard-escape-quit)
  ;; (evil-set-initial-state 'messages-buffer-mode 'normal)
  ;; (evil-set-initial-state 'dashboard-mode 'normal)
  )

(use-package evil-collection
  :after evil
  :init (evil-collection-init))

(use-package magit
  :bind (:map magit-status-mode-map ("<tab>" . magit-section-toggle))
  :custom (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
;; (use-package forge
;;   :after magit)


;; Treesitter

;; (use-package treesit-auto
;;   :custom
;;   (treesit-auto-install t)
;;   :config
;;   (add-to-list 'global-treesit-auto-modes '(not org-mode))
;;   (global-treesit-auto-mode))

(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (sh-mode . bash-ts-mode)
        (yaml-mode . yaml-ts-mode)))

;; (use-package evil-textobj-tree-sitter
;;   :config
;;   ;; bind `function.outer`(entire function block) to `f` for use in things like `vaf`, `yaf`
;;   (define-key evil-outer-text-objects-map "f"
;;               (evil-textobj-tree-sitter-get-textobj "function.outer"))
;;   ;; bind `function.inner`(function block without name and args) to `f` for use in things like `vif`, `yif`
;;   (define-key evil-inner-text-objects-map "f"
;;               (evil-textobj-tree-sitter-get-textobj "function.inner"))
;;   ;; You can also bind multiple items and we will match the first one we can find
;;   (define-key evil-outer-text-objects-map "a"
;;               (evil-textobj-tree-sitter-get-textobj ("conditional.outer" "loop.outer"))))


;; LSP

(use-package eglot
  :ensure nil
  :hook
  ((python-mode
    python-ts-mode
    sh-mode
    bash-ts-mode
    LaTeX-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-extend-to-xref nil)
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :codeLensProvider
     :codeActionProvider
     :colorProvider
     :foldingRangeProvider
     :executeCommandProvider))
  ;; (eglot-stay-out-of '(yas-snippets))
  ;; :config
  ;; (add-to-list 'eglot-server-programs
  ;;              '(python-ts-mode . ("pyright-langserver")))
  )

(use-package flymake
  :ensure nil
  :hook prog-mode
  :custom (flymake-show-diagnostics-at-end-of-line t))


;; Programming utilities

(use-package prog-mode
  :ensure nil
  :custom (show-trailing-whitespace t)
  :init
  (add-hook 'prog-mode-hook 'electric-pair-mode)
  (add-hook 'prog-mode-hook 'hs-minor-mode))

(use-package rainbow-delimiters
  :hook emacs-lisp-mode)

(use-package indent-bars
  :hook (prog-mode yaml-mode yaml-ts-mode)
  :custom
  (indent-bars-no-descend-lists t) ; no extra bars in continued func arg lists
  (indent-bars-treesit-support t)
  ;; (indent-bars-treesit-scope
  ;;  '((python function_definition class_definition for_statement
  ;;            if_statement with_statement while_statement)))
  (indent-bars-prefer-character t)
  (indent-bars-color '(highlight :face default :blend 0.2))
  (indent-bars-pattern ".")
  (indent-bars-color-by-depth nil)
  ;; (indent-bars-width-frac 0.1)
  ;; (indent-bars-pad-frac 0.1)
  ;; (indent-bars-zigzag nil)
  ;; (indent-bars-highlight-current-depth nil)
  ;; (indent-bars-display-on-blank-lines t)
  ;; :init (add-hook 'emacs-lisp-mode-hook (lambda () (indent-bars-mode -1)))
  )

;; Lisp

(use-package emacs-lisp-mode
  :ensure nil
  :no-require t
  :bind (:map my-personal-map ("(" . 'check-parens))
  :custom (evil-shift-width 2))


;; Python

(use-package python-mode
  :ensure nil
  :no-require t
  ;; :custom (dap-python-debugger 'debugpy)
  ;; :config (require 'dap-python)
  )

;; (use-package pyvenv
;;   :after python-mode
;;   :config
;;   (pyvenv-mode 1))

(use-package conda
  :hook (find-file . my/conda-env-activate-for-buffer)
  :preface
  (defun my/conda-env-activate-for-buffer ()
    (when (and (derived-mode-p 'python-mode)
               (bound-and-true-p conda-project-env-path))
      ;; (conda-mode-line-setup)
      (conda-env-activate-for-buffer)))
  :config
  (require 'conda)
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-Shell)
  (conda-env-autoactivate-mode t))

;; (use-package dap-mode
;;   ;; Hide all UI panes by default
;;   ;; :custom
;;   ;; (lsp-enable-dap-auto-configure nil)
;;   :commands dap-debug
;;   :init
;;   (dap-ui-mode 1)
;;   ;; Bind `C-c l d` to `dap-hydra` for easy access
;;   ;; (general-define-key
;;   ;;  :keymaps 'lsp-mode-map
;;   ;;  :prefix lsp-keymap-prefix
;;   ;;  "d" '(dap-hydra t :wk "debugger"))):


;; yaml

(use-package yaml-mode
  :custom
  (tab-width 2)
  (yaml-indent-offset 2))

(add-hook 'yaml-ts-mode-hook (lambda () (setq yaml-indent-offset 2)))

;; Bash

(add-to-list 'auto-mode-alist '("/\\.?\\(bashrc\\|bash_.*\\)\\'" . sh-mode))


;; LaTeX

(use-package auctex
  :no-require t
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t)
  :init
  (add-hook 'LaTeX-mode-hook 'outline-minor-mode)
  (add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
  (add-hook 'TeX-after-compilation-finished-functions-hook 'TeX-revert-document-buffer))

(use-package preview-dvisvgm
  :after preview-latex)

(use-package flyspell
  :ensure nil
  :defer t
  :hook
  (text-mode . flyspell-mode)
  ;; (prog-mode . flyspell-prog-mode)
  :config (require 'ispell))

(use-package ispell
  :ensure nil
  :custom
  (ispell-program-name "aspell")
  (ispell-local-dictionary-alist
   '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))
  (ispell-dictionary "en_US")
  (ispell-local-dictionary "en_US"))

(provide 'init)
;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
;;; init.el ends here
