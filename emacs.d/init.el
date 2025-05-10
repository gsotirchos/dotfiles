;;; package --- my config -*- lexical-binding: t -*-
;;; commentary:

;;; Code:

(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :family "Menlo" :height 140))
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil :family "Ubuntu Mono" :height 150))

;; Global mappings
(keymap-global-set "C-z" nil)
(keymap-global-set "C-M-f" 'toggle-frame-fullscreen)

(setq inhibit-startup-message t
      auto-save-default nil
      make-backup-files nil
      set-mark-command-repeat-pop t
      large-file-warning-threshold nil
      vc-follow-symlinks t
      ad-redefinition-action 'accept
      global-auto-revert-non-file-buffers t
      auto-hscroll-mode nil)

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(unless (eq system-type 'darwin)
  ;; (tooltip-mode 0)
  ;; (setq visible-bell t)
  (menu-bar-mode 0))
(set-fringe-mode 17)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(global-visual-line-mode 0)
(xterm-mouse-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(global-auto-revert-mode 1)
(column-number-mode 1)
(add-hook 'prog-mode-hook 'electric-pair-mode)
(add-hook 'prog-mode-hook 'hs-minor-mode)
;; (add-hook 'prog-mode-hook (lambda () (setq-local show-trailing-whitespace t)))

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

(use-package mac-pseudo-daemon
  :when (eq system-type 'darwin)
  :init (mac-pseudo-daemon-mode))

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

;; (use-package tab-bar-mode
;;   :ensure nil
;;   :no-require t
;;   :hook after-init
;;   :preface
  (defun my/surround-in-whitespace (name _ _)
    (concat " " name " "))
  (add-to-list 'tab-bar-tab-name-format-functions
              'my/surround-in-whitespace)
  ;; :custom
(setq tab-bar-show 1
      tab-bar-format '(tab-bar-format-history tab-bar-format-tabs)
      tab-bar-auto-width-max '((2000) 20)
      tab-bar-close-button-show nil
      tab-bar-separator t)

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
  ;; :bind (:map dired-mode-map
  ;;             ("b" . dired-up-directory))
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
    (interactive)
    (dired-hide-details-mode 1)
    (hl-line-mode 1))
  :config (add-hook 'dired-mode-hook 'my/dired-mode-hook))

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
  (global-corfu-minibuffer
   (lambda ()
     (not (or (bound-and-true-p mct--active)
              (bound-and-true-p vertico--input)
              (eq (current-local-map) read-passwd-map)))))
  :bind
  (:map corfu-map
        ;; ("TAB" . corfu-next)
        ;; ("S-TAB" . corfu-previous)
        ;; ("RET" . corfu-complete)
        ("S-SPC" . corfu-insert-separator)
        ("RET" . nil)
        ("C-e" . corfu-popupinfo-scroll-up)
        ("C-y" . corfu-popupinfo-scroll-down)
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
  (("C-x b" . consult-buffer)
   ("M-G"   . consult-git-grep)
   ("M-g f" . consult-flymake)
   ("M-g g" . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ;; ;; Isearch integration
   ;; ("M-s e" . consult-isearch-history)
   ;; :map isearch-mode-map
   ;; ("M-e" . consult-isearch-history)
   ;; ("M-s e" . consult-isearch-history)
   ;; ("M-s l" . consult-line)
   ;; ("M-s L" . consult-line-multi)
   ;; :map isearch-mode-map
   ;; ("M-s l" . consult-line)
   ;; ("M-s L" . consult-line-multi)
   ;; :map minibuffer-local-map
   ;; ("M-s" . consult-history)
   ;; ("M-r" . consult-history)
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
   ("C-c C-d" . helpful-at-point))
  :custom (warning-minimum-level :error))

(use-package which-key
  :init (which-key-mode)
  :custom (which-key-idle-delay 1))

(use-package general
  :after evil
  :config
  (general-create-definer my/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "C-c"
    :global-prefix "C-c")
  (my/leader-keys
    "t"  '(:ignore t :which-key "toggles"))
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
  :hook after-init
  :custom
  (evil-toggle-key "C-<escape>")
  (evil-want-integration t)
  (evil-want-keybinding nil)
  (evil-want-C-u-scroll t)
  (evil-want-C-u-delete t)
  (evil-cross-lines t)
  :preface
  (when (eq system-type 'darwin)
    (setq ns-option-modifier 'alt)
    (setq ns-command-modifier 'meta)
    (defun my/close-tab-window-frame ()
      "Save buffer and close its tab/window/frame."
      (interactive)
      ;; (unless (derived-mode-p 'special-mode)
      ;;   (save-buffer))
      (condition-case nil
          (tab-close)
        (error
         (condition-case nil
             (delete-frame)
           (error
            (condition-case nil
                (save-buffers-kill-terminal)
              (error nil))))))))
  :config
  (setq evil-disable-insert-state-bindings nil)
  (evil-set-undo-system 'undo-tree)
  (global-set-key [remap evil-quit] 'kill-buffer-and-window)
  (define-key minibuffer-local-map (kbd "C-h") 'delete-backward-char)
  (define-key minibuffer-local-map (kbd "C-n") 'next-line-or-history-element)
  (define-key minibuffer-local-map (kbd "C-p") 'previous-line-or-history-element)
  (define-key minibuffer-local-map (kbd "ESC") 'keyboard-escape-quit)
  (define-key evil-normal-state-map (kbd "M-q") 'save-buffers-kill-emacs)
  (define-key evil-normal-state-map (kbd "M-w") 'my/close-tab-window-frame)
  (define-key evil-normal-state-map (kbd "M-t") 'tab-new)
  (define-key evil-normal-state-map (kbd "M-n") 'make-frame)
  (define-key evil-normal-state-map (kbd "SPC") 'evil-toggle-fold)
  (define-key evil-normal-state-map (kbd "TAB") 'prog-fill-reindent-defun)
  (define-key evil-insert-state-map (kbd "C-s") 'swiper)
  (define-key evil-insert-state-map (kbd "C-r") 'swiper-backward)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  ;; (evil-set-initial-state 'messages-buffer-mode 'normal)
  ;; (evil-set-initial-state 'dashboard-mode 'normal)
  )

(use-package evil-collection
  :after evil
  :init (evil-collection-init))

(use-package magit
  :commands magit-status  ;; probably unnecessary
  ;; :custom
  ;; (magit-display-buffer-function 'magit-display-buffer-same-window-except-diff-v1)
  )

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
;; (use-package forge
;;   :after magit)


;; Treesitter

(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (sh-mode . bash-ts-mode)))

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
          . eglot-ensure))
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
  ;; (eglot-stay-out-of '(yas-snippets))
  ;; :config
  ;; (add-to-list 'eglot-server-programs
  ;;              '(python-ts-mode . ("pyright-langserver")))
  )

(use-package flymake
  :ensure nil
  :unless (lisp-interaction-mode)
  :hook prog-mode
  :custom (flymake-show-diagnostics-at-end-of-line t))


;; Lisp

(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (my/leader-keys "(" 'check-parens)
            (setq-local evil-shift-width 2)))

(use-package rainbow-delimiters
  :hook (emacs-lisp-mode . rainbow-delimiters-mode))


;; Python

;; (use-package dap-mode
;;   ;; All UI panes hidden by default
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
    (when (bound-and-true-p conda-project-env-path)
      ;; (conda-mode-line-setup)
      (conda-env-activate-for-buffer)))
  :config
  (require 'conda)
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-Shell)
  (conda-env-autoactivate-mode t))


;; Bash

(add-to-list 'auto-mode-alist '("/\\.?\\(bashrc\\|bash_.*\\)\\'" . sh-mode))


;; LaTeX

(use-package auctex
  :hook
  (LaTeX-mode . my/tex-mode-hook)
  (TeX-after-compilation-finished-functions . TeX-revert-document-buffer)
  :preface
  (defun my/tex-mode-hook ()
    (flyspell-mode)
    (outline-minor-mode)
    (LaTeX-math-mode)
    (turn-on-reftex))
  :custom
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t))

(use-package preview-dvisvgm
  :after preview-latex)

(use-package flyspell
  :ensure nil
  :defer t
  ;; :hook (prog-mode . flyspell-prog-mode)
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
