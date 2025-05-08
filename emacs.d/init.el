;;; package --- my config -*- lexical-binding: t -*-
;;; commentary:

;;; Code:
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :family "Menlo" :height 140))
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil :family "Ubuntu Mono" :height 150))

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(unless (eq system-type 'darwin)
  ;; (tooltip-mode -1)
  ;; (setq visible-bell t)
  (menu-bar-mode -1))
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-message t)
(setq vc-follow-symlinks t)
(setq-default indent-tabs-mode nil)
(column-number-mode)
(add-hook 'prog-mode-hook
          (lambda ()
            ;; (global-display-line-numbers-mode t)
            (setq-local show-trailing-whitespace t)))
(add-hook 'prog-mode-hook 'hs-minor-mode)

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


(use-package no-littering
  :ensure nil
  :no-require t
  :custom
  ;; no-littering doesn't set this by default so we must place
  ;; auto save files in the same path as it uses for sessions
  (auto-save-file-name-transforms
   `((".*" ,(no-littering-expand-var-file-name "auto-save/") t))))

;; Offload the custom-set-variables to a separate file
(use-package custom
  :ensure nil
  :no-require t
  :custom (custom-file "~/.emacs.d/custom.el")
  :config
  (unless (file-exists-p custom-file)
    (write-region "" nil custom-file))
  ;; Load custom file. Don't hide errors. Hide success message
  (load custom-file nil t))


(use-package modus-themes
  :ensure t
  :preface
  (defun my/apply-theme (appearance)
    (mapc #'disable-theme custom-enabled-themes)
    (add-to-list 'default-frame-alist `(ns-appearance . ,appearance))
    (pcase appearance
      ('light (load-theme 'modus-operandi))
      ('dark (load-theme 'modus-vivendi-tinted))))
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
  :hook after-init
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
  )

(use-package counsel
  :hook ivy-mode
  ;; :bind (("C-M-j" . 'counsel-switch-buffer)
  ;;        :map minibuffer-local-map
  ;;        ("C-r" . 'counsel-minibuffer-history))
  :custom
  ;; (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  (ivy-initial-inputs-alist nil))  ; Don't start searches with ^

(use-package ivy-rich
  :after (ivy counsel)
  :hook counsel-mode)

(use-package ivy-prescient
  :hook counsel-mode
  :custom
  (prescient-persist-mode 1)  ;; remember sorting across sessions!
  (ivy-prescient-enable-filtering nil))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  (warning-minimum-level :error))

(use-package which-key
  :hook after-init
  :custom (which-key-idle-delay 1))

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
  ;; :config
  ;; (defhydra hydra-text-scale (:timeout 4)
  ;;   "scale text"
  ;;   ("j" text-scale-increase "in")
  ;;   ("k" text-scale-decrease "out")
  ;;   ("f" nil "finished" :exit t))
  ;; ;; (my/leader-keys
  ;;   "ts" '(hydra-text-scale/body :which-key "scale text"))
  )

(use-package undo-tree
  :hook after-init
  :custom
  (global-undo-tree-mode t)
  (undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))))

(use-package evil
  :hook after-init
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
  :config (evil-collection-init))

;; (use-package all-the-icons
;;   ;; needs: M-x all-the-icons-install-fonts
;;   :if (display-graphic-p))
;;
;; (use-package doom-themes
;;   ;; :init (load-theme 'doom-palenight t))
;;   :custom
;;   (doom-themes-treemacs-enable-variable-pitch nil)
;;   (doom-themes-treemacs-theme "doom-atom")
;;   :config (doom-themes-treemacs-config)
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


(use-package projectile
  :hook
  (after-init . projectile-mode)
  (projectile-mode . treemacs-project-follow-mode)
  :bind-keymap ("C-c p" . projectile-command-map)
  :custom
  (projectile-completion-system 'ivy)
  (projectile-project-search-path
        (when (file-directory-p "~/Projects/Code") '("~/Projects/Code") nil))
  (projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after (ivy projectile)
  :hook ivy-mode)

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


;; Treesitter

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
  :hook (((python-mode
           python-ts-mode
           sh-mode
           bash-ts-mode
           LaTeX-mode)
          . eglot-ensure)
         ;; ((cider-mode
         ;;   eglot-managed-mode)
         ;;  . eglot-disable-in-cider)
         )
  ;; :preface
  ;; (defun eglot-disable-in-cider ()
  ;;   (when (eglot-managed-p)
  ;;     (if (bound-and-true-p cider-mode)
  ;;         (progn
  ;;           (remove-hook 'completion-at-point-functions 'eglot-completion-at-point t)
  ;;           (remove-hook 'xref-backend-functions 'eglot-xref-backend t))
  ;;       (add-hook 'completion-at-point-functions 'eglot-completion-at-point nil t)
  ;;       (add-hook 'xref-backend-functions 'eglot-xref-backend nil t))))
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-extend-to-xref nil)
  (eglot-ignored-server-capabilities
   '(:documentHighlightProvider
     :codeLensProvider
     :codeActionProvider
     :colorProvider
     :foldingRangeProvider))
  (eglot-stay-out-of '(company))
  :config
  ;; (eglot-inlay-hints-mode)
  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("pyright"))))

(use-package treemacs-nerd-icons
  :after treemacs
  :config (treemacs-load-theme "nerd-icons"))

(use-package company
  :after eglot
  :hook prog-mode
  :bind
  (:map company-active-map
        ("<tab>" . company-complete-selection))
  (:map eglot-mode-map
        ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package flymake
  :ensure nil
  :unless (lisp-interaction-mode)
  :hook prog-mode
  :custom (flymake-show-diagnostics-at-end-of-line t))


;; Languages

(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (sh-mode . bash-ts-mode)))


;; Lisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (my/leader-keys "(" 'check-parens)
            (setq-local evil-shift-width 2)))

(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))


;; Python

;; (use-package dap-mode
;;   ;; Uncomment the config below if you want all UI panes to be hidden by default!
;;   ;; :custom
;;   ;; (lsp-enable-dap-auto-configure nil)
;;   :commands dap-debug
;;   :config
;;   (dap-ui-mode 1)
;;   ;; Bind `C-c l d` to `dap-hydra` for easy access
;;   ;; (general-define-key
;;   ;;  :keymaps 'lsp-mode-map
;;   ;;  :prefix lsp-keymap-prefix
;;   ;;  "d" '(dap-hydra t :wk "debugger"))):

(use-package python-mode
  :ensure nil
  :no-require t
  :custom (dap-python-debugger 'debugpy)
  :config (require 'dap-python))

;; (use-package pyvenv
;;   :after python-mode
;;   :config
;;   (pyvenv-mode 1))

(use-package conda
  :hook (find-file . my/conda-env-activate-for-buffer)
  :preface
  (defun my/conda-env-activate-for-buffer ()
    (when (bound-and-true-p conda-project-env-path)
      ;; (conda-mode-line-setup)
      ;; (conda-projectile-mode-line-setup)
      (conda-env-activate-for-buffer)))
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
  :defer t
  ;; :hook (prog-mode . flyspell-prog-mode)
  :custom
  (ispell-program-name "aspell")  ;; TODO: verify
  (ispell-dictionary "American")
  :config (require 'ispell))


(use-package auctex
  :hook
  ;; (latex-mode . my/tex-mode-hook)
  (TeX-after-compilation-finished-functions . TeX-revert-document-buffer)
  :preface
  (defun my/tex-mode-hook ()
    (eglot-ensure)
    (company-mode)
    (flyspell-mode)
    (outline-minor-mode)
    (LaTeX-math-mode)
    (turn-on-reftex))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t)
  :init (add-hook 'LaTeX-mode-hook #'my/tex-mode-hook)
  )

(use-package preview-dvisvgm
  :after preview-latex)

(provide 'init)
;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
;;; init.el ends here
