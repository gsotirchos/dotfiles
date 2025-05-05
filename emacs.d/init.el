(set-face-attribute 'default nil :family "Menlo" :height 140)

(defun my/apply-theme (appearance)
  (mapc #'disable-theme custom-enabled-themes)
  (add-to-list 'default-frame-alist `(ns-appearance . ,appearance))
   (pcase appearance
     ('light (load-theme 'modus-operandi))
     ('dark (load-theme 'modus-vivendi-tinted))))

(use-package modus-themes
  :ensure t
  :config
  (setq modus-themes-bold-constructs t)
  (setq modus-themes-italic-constructs t)
  (setq modus-themes-common-palette-overrides
  '((fringe unspecified)
   ;; (border-mode-line-active unspecified)
   ;; (border-mode-line-inactive unspecified)
   (border-mode-line-active bg-mode-line-active)
   (border-mode-line-inactive bg-mode-line-inactive)
   ))
  (add-hook 'ns-system-appearance-change-functions #'my/apply-theme))

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(unless (eq system-type 'darwin)
  (menu-bar-mode -1)
  (tooltip-mode -1)
  (setq visible-bell t))
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq vc-follow-symlinks t)
(setq-default indent-tabs-mode nil)


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
;;     eshell-mode-hook
;;     treemacs-mode-hook))
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
  (package-refresh-content))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

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
  :init
  (ivy-rich-mode 1))

(use-package counsel
  ;; :bind (("C-M-j" . 'counsel-switch-buffer)
  ;;        :map minibuffer-local-map
  ;;        ("C-r" . 'counsel-minibuffer-history))
  ;; :custom
  ;; (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (setq ivy-initial-inputs-alist nil)  ; Don't start searches with ^
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
  ([remap describe-key] . helpful-key))


(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))


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
  :config
  (global-undo-tree-mode 1)
  (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))


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

;; (use-package doom-themes
;;   :init (load-theme 'doom-palenight t))

(use-package nerd-icons)

(use-package doom-modeline
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-window-width-limit 50)
  (setq doom-modeline-major-mode-icon nil)
  (setq doom-modeline-lsp-icon nil)
  (setq doom-modeline-buffer-encoding nil)
  ;; (setq doom-modeline-env-version nil)
  (setq doom-modeline-buffer-modification-icon nil)
  (setq doom-modeline-check-icon nil)
  (setq doom-modeline-check-simple-format t))


(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))


(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))


(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/Projects/Code")
    (setq projectile-project-search-path '("~/Projects/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

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


;; Folding

(add-hook 'prog-mode-hook 'hs-minor-mode)

(defun my/treesit-fold-mode ()
  (when (and (fboundp 'treesit-node-at)
             (treesit-node-at (point)))
    (treesit-fold-mode 1)))

(use-package treesit-fold
  :after evil
  :load-path "packages/treesit-fold"
  :config
  (add-hook 'prog-mode-hook #'my/treesit-fold-mode))


;; LSP

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . lsp-headerline-breadcrumb-mode)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-modeline-code-actions-enable nil)
  (setq lsp-modeline-diagnostics-enable nil)
  (setq lsp-headerline-breadcrumb-segments '(symbols))
  (setq lsp-headerline-breadcrumb-icons-enable nil)
  ;; (setq lsp-ui-sideline-enable t)
  ;; (setq lsp-diagnostics-disabled-modes ())
  )

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp
  :config
  (setq treemacs-no-png-images t))

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
  :config
  (require 'conda)
  (require 'conda-projectile)
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-Shell)
  (conda-env-autoactivate-mode t)
  (add-hook 'find-file-hook
            (lambda ()
              (when (bound-and-true-p conda-project-env-path)
                (conda-env-activate-for-buffer)
                ;(conda-mode-line-setup)
                ;(conda-projectile-mode-line-setup)
              )))
  )


;; Bash

(add-to-list 'auto-mode-alist '("/\\.?\\(bashrc\\|bash_.*\\)\\'" . sh-mode))


;; LaTeX

(use-package lsp-latex
  :hook
  (TeX-mode . lsp-deferred)
  (LaTeX-mode . lsp-deferred)
  :config
  (require 'lsp-latex)
  (add-hook 'bibtex-mode-hook 'lsp-deferred))

(use-package flyspell
  :ensure nil
  :config
  (require 'ispell)
  (setq ispell-program-name "/opt/homebrew/bin/aspell"
  ispell-dictionary "american")
  (add-hook 'TeX-mode-hook 'flyspell-mode)
  (add-hook 'emacs-lisp-mode-hook 'flyspell-prog-mode))

(use-package auctex
  :after flyspell-mode
  :defer t
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master nil)
  (setq TeX-PDF-mode t)
  (add-hook 'TeX-mode-hook (lambda () (TeX-fold-mode 1)))
  (add-hook 'TeX-mode-hook 'LaTeX-math-mode)
  (add-hook 'TeX-mode-hook 'turn-on-reftex)
  (add-hook 'TeX-after-compilation-finished-functions 'TeX-revert-document-buffer))

(use-package preview-dvisvgm
  :after preview-latex
  (require 'preview-dvisvgm))
