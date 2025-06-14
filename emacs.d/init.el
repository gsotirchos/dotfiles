;;; package --- my config -*- lexical-binding: t -*-
;;; commentary:

;;; Code:

(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :family "Menlo" :height 140))
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'default nil :family "Ubuntu Mono" :height 150))


(defun my/close-tab-or-frame ()
  "Close current tab or frame."
  (interactive)
  (condition-case nil
      (tab-close)
    (error (condition-case nil
               (delete-frame)
             (error nil)))))

(defun my/kill-back-to-indentation ()
  "Kill back to the first non-whitespace character."
  (interactive)
  (kill-line 0)
  (indent-for-tab-command))

(dolist (key-binding
         '(("C-z" . nil)  ;; don't suspend-frame
           ("S-<wheel-down>" . ignore)
           ("S-<wheel-up>" . ignore)
           ("C-<wheel-down>" . ignore)
           ("C-<wheel-up>" . ignore)
           ("M-<wheel-down>" . ignore)
           ("M-<wheel-up>" . ignore)
           ("C-M-f" . toggle-frame-fullscreen)
           ("M-<escape>" . next-window-any-frame)
           ("M-~" . previous-window-any-frame)
           ("M-n" . make-frame)
           ("M-t" . tab-new)
           ("M-w" . my/close-tab-or-frame)
           ("M-<backspace>" . my/kill-back-to-indentation)
           ("M-<delete>" . kill-line)
           ("M-<right>" . end-of-visual-line)
           ("M-<left>" . beginning-of-visual-line)))
  (keymap-global-set (car key-binding) (cdr key-binding)))

(dolist (key-binding
  '(("<escape>" . abort-recursive-edit)  ;; or 'abort-minibuffers
    ;; ("C-n" . next-line-or-history-element)
    ;; ("C-p" . previous-line-or-history-element)
    ))
  (keymap-set minibuffer-mode-map (car key-binding) (cdr key-binding)))


(when (eq system-type 'darwin)
  (setq-default mac-mouse-wheel-smooth-scroll t
                mouse-wheel-flip-direction t
                mouse-wheel-tilt-scroll t
                ns-command-modifier 'meta
                ns-option-modifier nil))

(defvar-keymap my-file-utils-map
  :doc "My file utilities map."
  "r" '("recent files" . recentf)
  "i" '("init.el" . (lambda ()
                      (interactive)
                      (find-file (expand-file-name "~/.emacs.d/init.el")))))

(defvar-keymap my-personal-map
  :doc "My prefix map."
  "d" 'flymake-show-buffer-diagnostics
  "m" 'magit
  "f" `("prefix files" . ,my-file-utils-map))

(defvar my/prefix "C-c")
(keymap-set global-map my/prefix my-personal-map)

(setq-default inhibit-startup-message t
              ;; auto-save-default nil
              auto-save-visited-file-name t
              auto-save-timeout 2
              make-backup-files nil
              set-mark-command-repeat-pop t
              large-file-warning-threshold nil
              vc-follow-symlinks t
              ad-redefinition-action 'accept
              use-short-answers t
              confirm-kill-emacs #'yes-or-no-p
              global-auto-revert-non-file-buffers t
              scroll-margin 0
              hscroll-margin 0
              scroll-step 1
              hscroll-step 1
              ;; global-display-line-numbers-mode t
              indent-tabs-mode nil)

(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))
(unless (and (eq system-type 'darwin)
             (display-graphic-p))
  ;; (tooltip-mode 0)
  ;; (setq visible-bell t)
  (menu-bar-mode 0))
(set-fringe-mode 16)
(tool-bar-mode 0)
(scroll-bar-mode 0)
(global-visual-line-mode 0)
(xterm-mouse-mode 1)
(column-number-mode 1)
(when (featurep 'ns)
  (pixel-scroll-precision-mode 1))


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
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-var-directory))
  (add-to-list 'recentf-exclude
               (recentf-expand-file-name no-littering-etc-directory)))


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
  (defface my-custom-curly-face
    '((t (:foreground "gray")))
    "Face for fringe curly bitmaps."
    :group 'basic-faces)
  :custom
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-common-palette-overrides
   '((fringe unspecified)
     ;; (border-mode-line-active unspecified)
     ;; (border-mode-line-inactive unspecified)
     (border-mode-line-active bg-mode-line-active)
     (border-mode-line-inactive bg-mode-line-inactive)
     (comment green)
     ))
  :init (load-theme 'modus-operandi)
  :config
  (set-fringe-bitmap-face 'left-curly-arrow 'my-custom-curly-face)
  (set-fringe-bitmap-face 'right-curly-arrow 'my-custom-curly-face))

(use-package tab-bar-mode
  :ensure nil
  :no-require t
  :preface
  (defun my/surround-in-whitespace (string _ _)
    "Just append and prepend spaces to a STRING."
    (concat " " string " "))
  (add-to-list 'tab-bar-tab-name-format-functions
               #'my/surround-in-whitespace)
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
;;   :config (doom-themes-treemacs-config))

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
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'hl-line-mode))

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
        ("<tab>" . corfu-next)
        ("S-<tab>" . corfu-previous)
        ("RET" . corfu-insert)
        ("S-SPC" . corfu-insert-separator)
        ;; ("RET" . nil)
        ;; ("C-e" . corfu-popupinfo-scroll-up)
        ;; ("C-y" . corfu-popupinfo-scroll-down)
        ;; Explicitly set for consistency in the minibuffer
        ;; ("C-n" . corfu-next)
        ;; ("C-p" . corfu-previous)
        )
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

(use-package marginalia
  :after vertico
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
  (advice-add 'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :bind
  (([remap Info-search] . consult-info)
   ([remap switch-to-buffer] . consult-buffer)
   ([remap recentf] . consult-recent-file)
   ("C-s" . consult-line)
   ("C-M-s" . consult-line-multi)
   ("M-s l" . consult-goto-line)
   ("M-s g" . consult-ripgrep)
   ("M-s M-f" . consult-flymake)
   ("M-s M-g" . consult-git-grep)
   :map isearch-mode-map
   ("C-s" . consult-isearch-history)
   :map minibuffer-local-map
   ("C-s" . consult-history))
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
  (("C-h B" . embark-bindings)  ;; alternative for `describe-bindings'
   :map minibuffer-local-map
   ("C-c" . embark-act)  ;; begin the embark process
   ("C-<return>" . embark-dwim)))  ;; run the default action

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
  (advice-add 'undo-tree-save-history :around #'my/silent-undo-tree-save-history)
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
        evil-symbol-word-search t
        evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)
  ;; (evil-set-initial-state 'messages-buffer-mode 'normal)
  ;; (evil-set-initial-state 'dashboard-mode 'normal)
  ;; (global-set-key [remap evil-quit] #'kill-buffer-and-window)
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

(use-package magit
  :bind (:map magit-status-mode-map ("<tab>" . magit-section-toggle))
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
;; (use-package forge
;;   :after magit)


;; Treesitter

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
  :hook ((python-base-mode sh-base-mode LaTeX-mode) . eglot-ensure)
  :custom
  (eglot-autoshutdown t)
  (eglot-events-buffer-size 0)
  (eglot-extend-to-xref nil)
  (eglot-prefer-plaintext t)
  (eglot-send-changes-idle-time 1)
  (eglot-ignored-server-capabilities
   '(:codeLensProvider
     :codeActionProvider
     :colorProvider
     :foldingRangeProvider
     :executeCommandProvider))
  :config
  ;; (setq eglot-stay-out-of '(flymake))
  ;; (add-hook 'eglot-managed-mode-hook
  ;;           (lambda () (add-hook 'flymake-diagnostic-functions
  ;;                                #'eglot-flymake-backend nil t)))
  ;; (add-hook 'eglot-managed-mode-hook #'flymake-mode)
  (add-to-list 'eglot-server-programs
               `((python-mode python-ts-mode) .
                 ("pyright-langserver" "--stdio"))))


;; Programming utilities

(use-package prog-mode
  :ensure nil
  :custom (show-trailing-whitespace t)
  :init
  (add-hook 'prog-mode-hook #'electric-pair-mode)
  (add-hook 'prog-mode-hook #'hs-minor-mode)
  (add-hook 'prog-mode-hook (lambda () (modify-syntax-entry ?_ "w")))
  (add-hook 'prog-mode-hook (lambda () (modify-syntax-entry ?- "w"))))

(use-package outline-indent
  :hook ((text-mode conf-mode) . outline-indent-minor-mode)
  :custom
  ;; (outline-indent-ellipsis " ▼")
  (outline-blank-line t))

(use-package rainbow-mode
  :defer t)

(use-package rainbow-delimiters
  :defer t
  :hook prog-mode)

(use-package indent-bars
  :hook (prog-mode yaml-ts-mode)
  :custom
  (indent-bars-display-on-blank-lines nil)
  ;; (indent-bars-no-descend-lists t)  ;; no extra bars in continued func arg lists
  (indent-bars-treesit-support t)
  ;; (indent-bars-treesit-scope
  ;;  '((python function_definition class_definition for_statement
  ;;            if_statement with_statement while_statement)))
  (indent-bars-prefer-character t)
  ;; (indent-bars-no-stipple-char ?│)
  (indent-bars-color '(highlight :face default :blend 0.2))
  ;; (indent-bars-pattern ".")
  (indent-bars-zigzag nil)
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-display-on-blank-lines nil)
  :config
  (add-hook 'emacs-lisp-mode-hook (lambda () (indent-bars-mode -1))))

(use-package flymake
  :ensure nil
  :hook prog-mode
  :custom
  (flymake-no-changes-timeout 1)
  ;; (add-hook 'sh-base-mode-hook #'flymake-mode-off)
  (flymake-show-diagnostics-at-end-of-line t))

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


;; Lisp

(use-package emacs-lisp-mode
  :ensure nil
  :no-require t
  :bind (:map my-personal-map ("(" . #'check-parens))
  :custom (evil-shift-width 2))


;; Python

(use-package python
  :no-require t
  :custom
  (python-check-command '("ruff" "--quiet" "--stdin-filename=stdin" "-")))

(use-package flymake-ruff
  :hook ((python-mode python-ts-mode) . flymake-ruff-load)
  :custom (python-flymake-command python-check-command)
  :config
  (add-hook 'eglot-managed-mode-hook
            (lambda () (when (derived-mode-p 'python-base-mode)
              (add-hook 'flymake-diagnostic-functions #'python-flymake nil t)
              (add-hook 'flymake-diagnostic-functions #'flymake-ruff--run-checker nil t)))))

(use-package conda
  :hook (find-file . my/conda-env-activate-for-buffer)
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
  ;; :config
  ;; (conda-env-initialize-interactive-shells)
  ;; (conda-env-initialize-eshell)
  ;; (conda-env-autoactivate-mode t)
  )


;; yaml

(use-package yaml-ts-mode
  :custom (tab-width 2)
  :init (setq yaml-indent-offset 2))


;; Bash

(add-to-list 'auto-mode-alist '("/\\.?\\(bashrc\\|bash_.*\\)\\'" . sh-mode))


;; LaTeX

(use-package auctex
  :no-require t
  :custom
  (preview-auto-cache-preamble t)
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-master nil)
  (TeX-PDF-mode t)
  :init
  (add-hook 'LaTeX-mode-hook #'outline-minor-mode)
  (add-hook 'LaTeX-mode-hook #'LaTeX-math-mode)
  (add-hook 'LaTeX-mode-hook #'turn-on-reftex)
  (add-hook 'TeX-after-compilation-finished-functions-hook #'TeX-revert-document-buffer))

(use-package preview-dvisvgm
  :after preview-latex)

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
