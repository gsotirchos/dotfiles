(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :family "Menlo" :height 140))
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil :family "Ubuntu Mono" :height 150))

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(unless (eq system-type 'darwin)
                                        ;(tooltip-mode -1)
                                        ;(setq visible-bell t)
  (menu-bar-mode -1))
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq vc-follow-symlinks t)
(setq-default indent-tabs-mode nil)
(add-hook 'prog-mode-hook
          (lambda () (setq-local show-trailing-whitespace t)))
(add-hook 'prog-mode-hook 'hs-minor-mode)


;; Offload the custom-set-variables to a separate file
(setq custom-file "~/.emacs.d/custom.el")
(unless (file-exists-p custom-file)
  (wite-region "" nil custom-file))
;; Load custom file. Don't hide errors. Hide success message
(load custom-file nil t)


(column-number-mode)
;; (global-display-line-numbers-mode t)

;; Disable line numbers for some modes
;; (dolist (mode '(org-mode-hook
;;                 term-mode-hook
;;                 shell-mode-hook
;;                 eshell-mode-hook
;;                 treemacs-mode-hook))
;;   (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Disable Ctrl-Z
(global-set-key (kbd "C-z") nil)


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
(setq use-package-always-ensure t)


(defun my/apply-theme (appearance)
  (mapc #'disable-theme custom-enabled-themes)
  (add-to-list 'default-frame-alist `(ns-appearance . ,appearance))
  (pcase appearance
    ('light (load-theme 'modus-operandi))
    ('dark (load-theme 'modus-vivendi-tinted))))

(use-package modus-themes
  :ensure t
  :hook (ns-system-appearance-change-functions . my/apply-theme)
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
  :init
  (load-theme 'modus-operandi))


(use-package ivy
  :diminish
  ;; :bind (("C-s" . swiper)
  ;;        ("C-r" . swiper-backward)
  ;;        :map ivy-minibuffer-map
  ;;        ("TAB" . ivy-alt-done)
  ;;        ("C-l" . ivy-alt-done)
  ;;        ("C-j" . ivy-next-line)
  ;;        ("C-k" . ivy-previous-line)
  ;;        :map ivy-switch-buffer-map
  ;;        ("C-k" . ivy-previous-line)
  ;;        ("C-l" . ivy-done)
  ;;        ("C-d" . ivy-switch-buffer-kill)
  ;;        :map ivy-reverse-i-search-map
  ;;        ("C-k" . ivy-previous-line)
  ;;        ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after (ivy counsel)
  :init (ivy-rich-mode 1))

(use-package counsel
  ;; :bind (("C-M-j" . 'counsel-switch-buffer)
  ;;        :map minibuffer-local-map
  ;;        ("C-r" . 'counsel-minibuffer-history))
  :custom
  (ivy-initial-inputs-alist nil)  ; Don't start searches with ^
  ;; (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  ;; Uncomment the following line to have sorting remembered across sessions!
  ;; (prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key)
  :config
  (unless (eq system-type 'darwin)
    (setq warning-minimum-level :error)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :custom
  (which-key-idle-delay 1))
:config
(which-key-mode)


(use-package general
  :after evil
  :config
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "C-c"
    :global-prefix "C-c")
  (my/leader-keys
    "t"  '(:ignore t :which-key "toggles")
    "tt" '(counsel-load-theme :which-key "choose theme"))
  (my/leader-keys
    :infix "f"
    "i" '(lambda () (interactive) (find-file (expand-file-name "~/.emacs.d/init.el")))))

(use-package hydra
  :after general
  :defer t
  :config
  (defhydra hydra-text-scale (:timeout 4)
    "scale text"
    ("j" text-scale-increase "in")
    ("k" text-scale-decrease "out")
    ("f" nil "finished" :exit t))
  ;; (my/leader-keys
  ;;   "ts" '(hydra-text-scale/body :which-key "scale text"))
  )

(use-package undo-tree
  :ensure t
  :custom
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
  :config
  (global-undo-tree-mode 1))


(use-package evil
  :init
  (setq evil-toggle-key "C-<escape>")
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-u-delete t)
  (setq evil-disable-insert-state-bindings t)
  (setq evil-cross-lines t)
  ;; (setq evil-search-module 'evil-search)
  :config
  (evil-mode 1)
  (evil-set-undo-system 'undo-tree)
  ;; (define-key evil-normal-state-map (kbd "<escape>") 'keyboard-escape-quit)
  (define-key evil-normal-state-map (kbd "<tab>") 'evil-toggle-fold)
  ;; (define-key evil-normal-state-map (kbd "C-s") 'swiper)
  ;; (define-key evil-normal-state-map (kbd "C-r") 'swiper-backward)
  (define-key evil-insert-state-map (kbd "C-s") 'swiper)
  (define-key evil-insert-state-map (kbd "C-r") 'swiper-backward)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; (use-package all-the-icons
;;   ;; needs: M-x all-the-icons-install-fonts
;;   :if (display-graphic-p))
;;
;; (use-package doom-themes
;;   ;; :init (load-theme 'doom-palenight t))
;;   :custom
;;   (doom-themes-treemacs-enable-variable-pitch nil)
;;   (doom-themes-treemacs-theme "doom-atom")
;;   :config
;;   (doom-themes-treemacs-config)
;;   )

(use-package doom-modeline
  ;; needs: M-x nerd-icons-install-fonts
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-window-width-limit 50)
  (doom-modeline-major-mode-icon nil)
  (doom-modeline-lsp-icon nil)
  (doom-modeline-buffer-encoding nil)
  ;; (doom-modeline-env-version nil)
  (doom-modeline-buffer-modification-icon nil)
  (doom-modeline-check-icon nil)
  (doom-modeline-check-simple-format t))


(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))


(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))


(use-package projectile
  :diminish projectile-mode
  :hook (projectile-mode . treemacs-project-follow-mode)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :custom (projectile-completion-system 'ivy)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired)
  :config
  (projectile-mode))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status  ;; probably unnecessary
  ;; :custom
  ;; (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  )

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
;; (use-package forge
;;   :after magit)


;; (use-package evil-nerd-commenter
;;   :config
;;   (my/leader-keys "c" 'evilnc-comment-or-uncomment-lines))


;; Treesitter

;; (defun my/treesit-fold-mode ()
;;   (when (and (fboundp 'treesit-node-at)
;;              (treesit-node-at (point)))
;;     (treesit-fold-mode 1)))
;;
;; ;; needs: git clone https://github.com/emacs-tree-sitter/treesit-fold ~/.emacs.dir/packages/treesit-fold
;; (use-package treesit-fold
;;   :after treesit
;;   :load-path "packages/treesit-fold"
;;   :hook (prog-mode . my/treesit-fold-mode))

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

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . lsp-headerline-breadcrumb-mode)
  :custom
  (lsp-modeline-code-actions-enable nil)
  (lsp-modeline-diagnostics-enable nil)
  (lsp-headerline-breadcrumb-segments '(symbols))
  (lsp-headerline-breadcrumb-icons-enable nil)
  ;; (lsp-ui-sideline-enable t)
  ;; (lsp-diagnostics-disabled-modes ())
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package treemacs
  :config
  (use-package treemacs-nerd-icons
    :functions treemacs-load-theme
    :config
    (treemacs-load-theme "nerd-icons"))
  )

(use-package lsp-treemacs
  :after (lsp treemacs)
  :custom
  (lsp-treemacs-theme "nerd-icons-ext")
  (treemacs-no-png-images t))

(use-package lsp-treemacs-nerd-icons
  :after doom-themes
  :load-path "packages/lsp-treemacs-nerd-icons"
  ;; HACK: Load after the `lsp-treemacs' created default themes
  :init (with-eval-after-load 'lsp-treemacs
          (require 'lsp-treemacs-nerd-icons)))

(use-package lsp-ivy
  :after lsp)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind
  (:map company-active-map
        ("<tab>" . company-complete-selection))
  (:map lsp-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

;; (use-package company-box
;;   :hook (company-mode . company-box-mode))


;; Languages

(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (sh-mode . bash-ts-mode)))


;; Elisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (my/leader-keys "(" 'check-parens)
            (setq-local evil-shift-width 2)))


;; Python

(use-package lsp-pyright
  :ensure t
  :custom (lsp-pyright-langserver-command "pyright")
  :config
  (require 'lsp-pyright))

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  :commands dap-debug
  :config
  ;; (dap-ui-mode 1)
  (require 'dap-python)

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
   :keymaps 'lsp-mode-map
   :prefix lsp-keymap-prefix
   "d" '(dap-hydra t :wk "debugger"))):

(use-package python-mode
  :ensure nil
  :hook
  (python-mode . lsp-deferred)
  (python-ts-mode . lsp-deferred)
  :custom
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

;; (use-package pyvenv
;;   :after python-mode
;;   :config
;;   (pyvenv-mode 1))

(use-package conda
  :hook
  (find-file . (lambda ()
                 (when (bound-and-true-p conda-project-env-path)
                   ;; (conda-mode-line-setup)
                   ;; (conda-projectile-mode-line-setup)
                   (conda-env-activate-for-buffer))))
  :config
  (require 'conda)
  (require 'conda-projectile)
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-Shell)
  (conda-env-autoactivate-mode t))


;; Bash

(add-to-list 'auto-mode-alist '("/\\.?\\(bashrc\\|bash_.*\\)\\'" . sh-mode))


;; LaTeX

(use-package flyspell
  :ensure nil
  :hook
  (prog-mode . flyspell-prog-mode)
  (tex-mode . flyspell-mode)
  :custom
  (ispell-program-name "/opt/homebrew/bin/aspell")
  (ispell-dictionary "american")
  :config
  (require 'ispell))

(defun my/tex-mode-hook ()
  (lsp-deferred)
  (flyspell-mode)
  (outline-minor-mode)
  ;; (TeX-fold-mode 1)
  (LaTeX-math-mode)
  (turn-on-reftex))

(use-package auctex
  :defer t
  :hook
  (tex-mode . my/tex-mode-hook)
  (TeX-after-compilation-finished-functions . TeX-revert-document-buffer)
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t))

(use-package preview-dvisvgm
  :after preview-latex
  (require 'preview-dvisvgm))
