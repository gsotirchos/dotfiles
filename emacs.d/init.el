;;; package --- init -*- lexical-binding: t -*-
;;; Commentary:
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

  (defun my/find-file (file)
    "Open buffer with FILE in new frame or tab."
    (interactive)
    (let ((file-name (file-truename file)))
      (unless (string-equal buffer-file-name file-name)
        (if (cdr (assoc 'fullscreen (frame-parameters)))
            (find-file-other-tab file-name)
          (find-file-other-frame file-name)))))

  (defun my/edit-emacs-init ()
    "Edit `~/.emacs.d/init.el'."
    (interactive)
    (my/find-file  "~/.emacs.d/init.el"))

  (defun my/edit-emacs-early-init ()
    "Edit `~/.emacs.d/early-init.el'."
    (interactive)
    (my/find-file  "~/.emacs.d/early-init.el"))

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
    "Adjust the size of latex preview fragments when changing the buffer's text scale."
    (let ((scale (expt text-scale-mode-step text-scale-mode-amount)))
      (my/text-scale-overlays 'category 'preview-overlay scale)
      (my/text-scale-overlays 'org-overlay-type 'org-latex-overlay scale)))

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
  (defun my/set-line-spacing-advice (&rest _)
    "Set `line-spacing' after the advised function is executed."
    (if (and (bound-and-true-p buffer-face-mode)
             (equal buffer-face-mode-face 'variable-pitch))
        (when (boundp 'variable-pitch-line-spacing)
          (setq-local line-spacing variable-pitch-line-spacing))
      (setq line-spacing fixed-pitch-line-spacing)))

  (advice-add 'variable-pitch-mode :after #'my/set-line-spacing-advice)

  (defun my/fixed-pitch-mode ()
    (variable-pitch-mode -1))

  (add-hook 'Custom-mode-hook #'variable-pitch-mode)
  (add-hook 'Info-mode-hook #'variable-pitch-mode)
  (add-hook 'org-mode-hook #'variable-pitch-mode)
  ;; (add-hook 'text-mode-hook #'variable-pitch-mode)
  ;; (add-hook 'LaTeX-mode-hook #'my/fixed-pitch-mode)

  ;; Modeline
  (defvar mode-line-major-modes
    (let ((recursive-edit-help-echo
           "Recursive edit, type C-M-c to get out"))
      (list (propertize "%[" 'help-echo recursive-edit-help-echo)
	          `(:propertize ("" mode-name)
			                    help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
			                    mouse-face mode-line-highlight
			                    local-map ,mode-line-major-mode-keymap)
	          '("" mode-line-process)
	          (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
		                    'mouse-face 'mode-line-highlight
		                    'local-map (make-mode-line-mouse-map
				                            'mouse-2 #'mode-line-widen))
	          (propertize "%]" 'help-echo recursive-edit-help-echo)
	          " ")))
  (put 'mode-line-major-modes 'risky-local-variable t)

  (defvar mode-line-minor-modes
    (let ((recursive-edit-help-echo
           "Recursive edit, type C-M-c to get out"))
      (list (propertize "%[" 'help-echo recursive-edit-help-echo)
            "("
            `(:propertize ("" minor-mode-alist)
            			        mouse-face mode-line-highlight
            			        help-echo "Minor mode\n\
mouse-1: Display minor mode menu\n\
mouse-2: Show help for minor mode\n\
mouse-3: Toggle minor modes"
            			        local-map ,mode-line-minor-mode-keymap)
            ")"
	          (propertize "%]" 'help-echo recursive-edit-help-echo)
	          " ")))
  (put 'mode-line-minor-modes 'risky-local-variable t)

  (defvar my/mode-line-format
    '("%e"
      mode-line-front-space
      (:propertize evil-mode-line-tag
                   display (min-width (5.5)))
      (:propertize (""
                    mode-line-mule-info
                    mode-line-client
                    mode-line-modified
                    mode-line-remote
                    mode-line-window-dedicated)
                   display (min-width (5.0)))
      mode-line-frame-identification
      mode-line-buffer-identification
      (:propertize (" ") display (min-width (2.0)))
      mode-line-position
      ;; (:propertize (" ") display (min-width (2.0)))
      ;; (project-mode-line project-mode-line-format)
      (vc-mode vc-mode)
      (:propertize (" ") display (min-width (2.0)))
      mode-line-major-modes
      (:propertize (" ") display (min-width (2.0)))
      ;; mode-line-minor-modes
      (:eval (when (bound-and-true-p flymake-mode) flymake-mode-line-counters))
      (:propertize (" ") display (min-width (2.0)))
      mode-line-misc-info
      mode-line-end-spaces))

  (add-hook 'after-load-theme-hook (lambda () (setq-default mode-line-format my/mode-line-format)))

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
    "m" 'memory-report
    "C-d" 'help-follow-symbol)

  (keymap-set global-map "C-c" my/personal-map)
  ;; :bind-keymap ("C-c" . my/personal-map)

  :bind
  (("C-z" . nil)
   ("<wheel-left>" . ignore)
   ("<wheel-right>" . ignore)
   ("C-<wheel-left>" . ignore)
   ("S-<wheel-left>" . ignore)
   ("M-<wheel-left>" . ignore)
   ("A-<wheel-left>" . ignore)
   ("C-<wheel-right>" . ignore)
   ("S-<wheel-right>" . ignore)
   ("M-<wheel-right>" . ignore)
   ("A-<wheel-right>" . ignore)
   ("C-<wheel-up>" . ignore)
   ("S-<wheel-up>" . ignore)
   ("M-<wheel-up>" . ignore)
   ("A-<wheel-up>" . ignore)
   ("C-<wheel-down>" . ignore)
   ("S-<wheel-down>" . ignore)
   ("M-<wheel-down>" . ignore)
   ("A-<wheel-down>" . ignore)
   ("C-<delete>" . ignore)
   ("C-<right>" . ignore)
   ("C-<left>" . ignore)
   ("C-<up>" . ignore)
   ("C-<down>" . ignore)
   ("M-<escape>" . ignore)
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
   ("C-M-e" . ns-do-show-character-palette)
   ("M-u" . universal-argument)
   ("M-c" . kill-ring-save)
   ("M-n" . make-frame)
   ("M-t" . tab-new)
   ("M-w" . my/quit-dwim)
   ("M-m" . iconify-frame)
   ("M-h" . ns-do-hide-emacs)
   ("M-," . my/edit-emacs-init)
   ("C-M-," . my/edit-emacs-early-init)
   :map help-map
   ("=" . describe-char)
   :map minibuffer-mode-map
   ("<escape>" . abort-recursive-edit)
   ("C-u" . scroll-down-command)
   ("C-d" . scroll-up-command)
   ("<prior>" . scroll-down-command)
   ("<next>" . scroll-up-command))

  :custom
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
  (line-spacing fixed-pitch-line-spacing)
  (truncate-lines nil)
  (wrap-prefix "…")
  (cursor-in-non-selected-windows nil)
  (left-margin-width 0)
  (right-margin-width 0)
  (indent-tabs-mode nil)
  (treemacs-no-png-images t)
  (major-mode-remap-alist
   '((python-mode . python-ts-mode)
     (sh-mode . bash-ts-mode)
     (yaml-mode . yaml-ts-mode)))

  :init
  ;; Display table for wrap prefix
  (set-display-table-slot standard-display-table 'wrap (string-to-char wrap-prefix))
  (set-display-table-slot standard-display-table 0 (string-to-char wrap-prefix)))


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

(use-package modus-themes
  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-variable-pitch-ui t)
  (modus-themes-common-palette-overrides
   '((fringe unspecified)
     (bg-mode-line-active bg-inactive)
     (bg-mode-line-inactive bg-dim)
     (border-mode-line-active bg-mode-line-active)
     (border-mode-line-inactive bg-mode-line-inactive)
     (header-line bg-dim)
     (bg-tab-bar bg-main)
     (bg-tab-current bg-inactive)
     (bg-tab-other bg-dim)
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
    (let ((box-released '(:line-width 2 :style released-button))
          ;; (box-pressed '(:line-width 2 :style pressed-button))
          (box-thinner '(:line-width (1 . 2) :style released-button)))
      (dolist (face
               '(modus-themes-button
                 tab-bar-tab
                 tab-bar-tab-inactive
                 header-line
                 mode-line
                 mode-line-inactive))
        (set-face-attribute face nil :box box-released))
      ;; (add-hook 'Custom-mode-hook  ;; TODO
      ;;           (lambda ()
      ;;             (set-face-attribute 'custom-button nil :box box-released)
      ;;             (set-face-attribute 'custom-button-mouse nil :box box-released)
      ;;             (set-face-attribute 'custom-button-pressed nil :box box-pressed)))
      (dolist (face
               '(mode-line-highlight
                 header-line-highlight))
        (set-face-attribute face nil :box box-thinner))))
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
  (tab-bar-auto-width nil)
  (tab-bar-tab-name-truncated-max 35)
  (tab-bar-format
   '(tab-bar-format-tabs
     tab-bar-separator
     tab-bar-format-align-right
     tab-bar-format-global))
  :preface
  (defun my/prepend-whitespace (string _ _)
    "Just append and prepend spaces to a STRING."
    (concat " " string " "))
  (add-hook 'desktop-after-read-hook #'tab-bar-mode)
  :init
  (when (boundp 'tab-bar-tab-name-format-functions)
    (add-to-list 'tab-bar-tab-name-format-functions #'my/prepend-whitespace)
    (add-to-list 'tab-bar-tab-name-format-functions #'tab-bar-tab-name-format-truncated)))

(use-package dired
  :ensure nil
  :bind (:map dired-mode-map ("M-<up>" . dired-up-directory))
  :custom
  (dired-listing-switches "-alv --group-directories-first")
  (dired-omit-files "^\\.[^.].*")
  (dired-mouse-drag-files t)
  (dired-omit-verbose nil)
  (dired-dwim-target 'dired-dwim-target-next)
  (dired-hide-details-hide-symlink-targets nil)
  (dired-kill-when-opening-new-dired-buffer t)
  (delete-by-moving-to-trash t)
  :preface
  (defun my/dired-mode-hook ()
    (dired-omit-mode 1)
    (dired-hide-details-mode 1)
    (hl-line-mode 1))
  (add-hook 'dired-mode-hook #'my/dired-mode-hook))

(use-package evil
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
        ("<tab>" . corfu-next)
        ("S-<tab>" . corfu-previous)
        ("<escape>" . corfu-reset)
        ("C-d" . corfu-scroll-up)
        ("C-u" . corfu-scroll-down)
        ("<next>" . corfu-scroll-up)
        ("<prior>" . corfu-scroll-down)
        ("S-SPC" . corfu-insert-separator)
        ;; ("<return>" . my/corfu-send-in-shell)
        ;; ("RET" . nil)
        )
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
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preselect 'prompt)  ;; don't pre-select first candidate
  (corfu-preview-current 'insert)  ;; insert previewed candidate
  (corfu-on-exact-match nil)  ;; Don't auto expand tempel snippets
  (corfu-cycle t)
  ;; (global-corfu-minibuffer t)
  (global-corfu-minibuffer 'my/corfu-minibuffer-filter)
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
                        :italic t :family nil :inherit 'variable-pitch))
  (add-hook 'after-load-theme-hook #'my/marginalia-mode-hook)
  :init
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
  :config
  ;; The configuration values are evaluated at runtime, just before the
  ;; completion session is started. Therefore you can use for example
  ;; `thing-at-point' to adjust the initial input or the future history.
  (consult-customize consult-line
                     :add-history (seq-some 'thing-at-point '(region symbol)))
  (defalias 'consult-line-thing-at-point 'consult-line)
  (consult-customize consult-line-thing-at-point
                     :initial (thing-at-point 'symbol))
  (add-to-list 'consult-preview-allowed-hooks #'variable-pitch-mode)
  ;; (add-to-list 'consult-preview-allowed-hooks #'my/fixed-pitch-mode)
  (add-to-list 'consult-preview-allowed-hooks #'my/pdf-view-mode-hook)
  (add-to-list 'consult-preview-allowed-hooks #'my/org-mode-hook))

(use-package embark
  :bind
  (("C-h B" . embark-bindings)  ;; alternative for `describe-bindings'
   :map minibuffer-local-map
   ("C-c" . embark-act)  ;; begin the embark process
   ("C-<return>" . embark-dwim))  ;; run the default action
  :custom (embark-quit-after-action nil))

(use-package embark-consult
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
  :custom (which-key-idle-delay 1)
  :init (which-key-mode))

(use-package eldoc-box
  :hook (prog-mode . eldoc-box-hover-at-point-mode))

(use-package diff-hl
  :custom (diff-hl-draw-borders nil)
  :preface
  (defun my/diff-hl-mode-if-vc ()
    (when (and (buffer-file-name) (vc-registered (buffer-file-name)))
      (diff-hl-mode 1)))
  (dolist (hook
           '(find-file-hook
             ;; auto-save-hook
             after-save-hook))
    (add-hook hook #'my/diff-hl-mode-if-vc))
  (defun my/customize-diff-hl ()
    (setf (alist-get 'change diff-hl-margin-symbols-alist nil nil #'equal) "~")
    (seq-mapn
     (lambda (diff-hl-face diff-face)
       (face-remap-add-relative diff-hl-face diff-face)
       (set-face-attribute diff-hl-face nil
                           :italic nil :bold nil
                           :height (round (* 0.92 (face-attribute 'default :height)))))
     '(diff-hl-change
       diff-hl-insert
       diff-hl-delete)
     '(diff-changed
       diff-added
       diff-removed)))
  (defun my/diff-hl-hook ()
    (my/customize-diff-hl)
    (add-hook 'auto-save-hook 'diff-hl-update nil t)
    (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh nil t)
    (add-hook 'after-load-theme-hook #'my/customize-diff-hl))
  (add-hook 'diff-hl-mode-hook #'my/diff-hl-hook)
  :init (diff-hl-margin-mode 1))

(use-package magit
  :bind
  (:map magit-mode-map
        ("M-n" . nil)
        ("M-w" . nil)
        :map magit-section-mode-map
        ("<tab>" . magit-section-toggle)
        ("C-<tab>" . nil))
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  :config
  (when (bound-and-true-p evil-mode)
    (evil-define-key 'normal magit-section-mode-map (kbd "C-<tab>") nil)))

(use-package pdf-tools
  :commands (pdf-loader-install)
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :bind (:map special-mode-map ([remap quit-window] . nil))
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

;; Programming

(use-package eglot
  :ensure nil
  :no-require t
  :hook ((python-base-mode sh-base-mode LaTeX-mode) . eglot-ensure)
  :bind (:map eglot-mode-map ("C-c rn" . eglot-rename))
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
  ;; (defun my/eglot-mode-hook ()
  ;;   (add-hook 'flymake-diagnostic-functions #'eglot-flymake-backend nil t)
  ;;   (flymake-mode 1))
  :init
  (advice-add 'eglot--connect :around #'my/prevent-in-home-dir-advice)
  ;; (setq eglot-stay-out-of '(flymake))
  ;; (add-hook 'eglot-managed-mode-hook #'my/eglot-mode-hook)
  :config (add-to-list 'eglot-server-programs
                       `(python-base-mode . ("pyright-langserver" "--stdio"))))

(use-package prog-mode
  :ensure nil
  :preface
  (defun my/prog-mode-hook ()
    (hs-minor-mode 1)
    (setq show-trailing-whitespace t)
    ;; (modify-syntax-entry ?- "w")
    (modify-syntax-entry ?_ "w"))
  (add-hook 'prog-mode-hook #'my/prog-mode-hook))

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
  :hook (prog-mode minibuffer-setup)
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
  (indent-bars-no-stipple-char ?·)
  (indent-bars-color '(highlight :face default :blend 0.2))
  (indent-bars-zigzag nil)
  (indent-bars-color-by-depth nil)
  (indent-bars-highlight-current-depth nil)
  (indent-bars-display-on-blank-lines nil))

(use-package ediff
  :ensure nil
  :custom (ediff-window-setup-function 'ediff-setup-windows-plain))

(use-package flymake
  :ensure nil
  :hook prog-mode
  :bind (:map flymake-mode-map ("C-c M-f" . flymake-show-buffer-diagnostics))
  :custom
  (flymake-no-changes-timeout 1)
  (flymake-show-diagnostics-at-end-of-line t)
  (flymake-indicator-type 'margins)
  ;; (flymake-autoresize-margins nil)
  (flymake-margin-indicators-string
   '((note "•" flymake-note-echo)  ;; ●
     (warning "▲" flymake-warning-echo)
     (error "◼" flymake-error-echo)))
  :preface
  (defun my/customize-flymake ()
    (set-face-attribute 'flymake-end-of-line-diagnostics-face nil
                        :foreground (modus-themes-get-color-value 'fg-dim)
                        :box '(:line-width (5 . -1) :style flat-button)
                        :height (round (* 0.92 (face-attribute 'default :height)))
                        :italic t
                        :inherit 'variable-pitch)
    (let ((faces
            '(flymake-eol-information-face
              flymake-note-echo-at-eol
              flymake-warning-echo-at-eol
              flymake-error-echo-at-eol))
           (fg-colors
            '(blue-faint
              cyan-faint
              yellow-faint
              red-faint))
           (bg-colors
            '(bg-blue-nuanced
              bg-cyan-nuanced
              bg-yellow-nuanced
              bg-red-nuanced)))
      (seq-mapn
       (lambda (face fg-color bg-color)
         (set-face-attribute face nil
                             :extend t :inherit 'flymake-end-of-line-diagnostics-face
                             :foreground (modus-themes-get-color-value fg-color)
                             :background (modus-themes-get-color-value bg-color)))
       faces fg-colors bg-colors)))
  (defun my/flymake-hook ()
    (when (fboundp 'modus-themes-get-color-value)
      (my/customize-flymake)
      (add-hook 'after-load-theme-hook #'my/customize-flymake nil t)))
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
  :init
  (add-hook 'python-base-mode-hook (lambda () (hs-minor-mode -1)))
  (add-hook 'inferior-python-mode-hook
            (lambda () (add-to-list 'comint-output-filter-functions #'comint-truncate-buffer))))

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
  (defun my/conda-eglot-hook ()
    (defun my/eglot-conda-reconnect ()
      (eglot-reconnect (eglot--current-server-or-lose)))
    (add-hook 'conda-postactivate-hook #'my/eglot-conda-reconnect nil t)
    (add-hook 'conda-postdeactivate-hook #'my/eglot-conda-reconnect nil t))
  (add-hook 'eglot-managed-mode-hook #'my/conda-eglot-hook)
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
  :mode ("/\\.?\\(bashrc\\|bash_[^.]*\\)\\'" . sh-mode)
  :init
  ;; (add-hook 'sh-base-mode-hook #'flymake-mode-off)
  (add-hook 'sh-base-mode-hook (lambda () (hs-minor-mode -1))))


;; LaTeX

(use-package auctex
  :ensure nil
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
  (preview-scale-function (/ 1 1.75))
  :preface
  (defun my/LaTeX-mode-hook ()
    (outline-minor-mode 1)
    (LaTeX-math-mode 1)
    (turn-on-reftex)
    (add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews nil t)
    (add-hook 'after-load-theme-hook #'delete-all-overlays)
    (advice-add 'preview-document :before (lambda (&rest _) (TeX-PDF-mode -1)))
    (advice-add 'preview-region :before (lambda (&rest _) (TeX-PDF-mode -1)))
    (advice-add 'TeX-command :before (lambda (&rest _) (TeX-PDF-mode 1))))
  (add-hook 'LaTeX-mode-hook #'my/LaTeX-mode-hook)
  (add-hook 'TeX-after-compilation-finished-functions-hook #'TeX-revert-document-buffer))

(use-package preview-dvisvgm
  :after preview
  :custom
  (preview-image-type 'dvisvgm)
  (preview-scale-function 1.75))


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
  (org-startup-with-latex-preview t)
  (org-startup-with-inline-images t)
  (org-startup-truncated nil)
  (org-startup-folded 'content)
  (org-startup-indented t)
  (org-blank-before-new-entry '((heading . nil) (plain-list-item . nil)))
  (org-cycle-separator-lines 1)
  (org-preview-latex-image-directory (no-littering-expand-var-file-name "ltximg/"))
  (org-image-max-width (/ 2 (+ 1 (sqrt 5))))
  (org-directory "~/Documents/org")
  (org-agenda-files (list org-directory "~/Desktop"))
  (org-todo-keywords '((sequence "TODO" "WIP" "|" "DONE" "SKIP" "FAIL")))
  (org-log-done 'time)
  (org-tags-column 0)
  (org-hide-emphasis-markers t)
  (org-fontify-todo-headline nil)
  (org-fontify-done-headline t)
  (org-export-with-toc nil)
  (org-latex-create-formula-image-program 'dvisvgm)
  (org-special-ctrl-a/e t)
  (org-special-ctrl-k t)
  (org-special-ctrl-o t)
  :preface
  (defun my/unlimited-fill-column-advice (fn &rest args)
    "Execute FN with ARGS with `fill-column' set to the maximum possible value."
    (let ((fill-column most-positive-fixnum))
      (apply fn args)))
  (advice-add 'org-fill-paragraph :around #'my/unlimited-fill-column-advice)
  (defun my/org-emphasize-dwim (&optional char)
    "DWIM (Do What I Mean) wrapper for `org-emphasize'.
If there's an active region, apply emphasis to it.
Otherwise, apply emphasis to the word at point."
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
  (defun my/md-to-org-region (start end)
    "Convert contents between START and END from markdown to org."
    (interactive "r")
    (shell-command-on-region start end "pandoc -f markdown -t org" t t))
  (defun my/org-remove-drawers-in-region (start end)
    "Remove all Org-mode drawers between START and END."
    (interactive "r")
    (save-excursion
      (goto-char start)
      (let ((drawer-regexp "^\s*:\\w*:\n\\(\s*:.*\n\\)*\s*:END:\s*\n"))
        (while (re-search-forward drawer-regexp end t)
          ;; Delete the match, including the newline
          (replace-match "" nil nil)))))
  (defun my/adjust-preview-latex-scale ()
    (let* ((text-scaling (if (boundp 'text-scale-mode-step)
                             (expt text-scale-mode-step text-scale-mode-amount)
                           1.0))
           (monitor-scaling (cdr (assoc 'scale-factor (car (display-monitor-attributes-list)))))
           (scaling-fn (lambda (_) (/ text-scaling monitor-scaling))))
      (my/update-plist-property org-format-latex-options :scale scaling-fn)))
  (defun my/customize-org-mode ()
    "Apply my tweaks to theme-controlled settings."
    (set-face-attribute 'org-headline-done nil :strike-through t :family nil :inherit 'variable-pitch)
    (set-face-bold 'org-checkbox t)
    (let ((bg-color (face-background 'org-agenda-clocking)))
      (setf (alist-get "_" org-emphasis-alist nil nil #'equal) `((:background ,bg-color))))
    (dolist (face
             '(org-hide
               org-table
               org-todo
               org-done
               org-checkbox))
      (set-face-attribute face nil :family nil :inherit 'fixed-pitch))
    (font-lock-update))
  (defun my/org-mode-hook ()
    ;; (setq fill-column most-positive-fixnum)
    (visual-line-mode 1)
    (my/customize-org-mode)
    (add-hook 'after-load-theme-hook #'my/customize-org-mode nil t)
    (add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews nil t)
    (advice-add 'org-latex-preview :after #'my/text-scale-adjust-latex-previews)
    (add-hook 'after-load-theme-hook #'delete-all-overlays)
    (dolist (hook
             '(after-load-theme-hook
               ;; text-scale-mode-hook
               auto-save-hook
               after-save-hook))
      (add-hook hook #'my/org-latex-preview-buffer nil t)))
  (add-hook 'org-mode-hook #'my/org-mode-hook)
  (advice-add 'my/org-latex-preview-buffer :around #'my/silence-advice)
  :config
  (my/adjust-preview-latex-scale)
  (plist-put org-format-latex-options :background "Transparent"))

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
