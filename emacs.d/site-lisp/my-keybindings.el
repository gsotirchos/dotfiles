;;; my-keybindings.el --- My personal keybindings and interactive commands  -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;;; ----------------------------------------------------------------------------
;;; Interactive Commands (The functions bound to keys)
;;; ----------------------------------------------------------------------------

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

;; Helper for the edit-init functions below
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

;;; ----------------------------------------------------------------------------
;;; Keymaps
;;; ----------------------------------------------------------------------------

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

(defvar-keymap my-keybindings-mode-map
  :doc "Keymap for my-keybindings-mode"
  ;; Mouse/Wheel
  "<wheel-left>" #'ignore
  "<wheel-right>" #'ignore
  "C-<wheel-left>" #'ignore
  "S-<wheel-left>" #'ignore
  "M-<wheel-left>" #'ignore
  "A-<wheel-left>" #'ignore
  "C-<wheel-right>" #'ignore
  "S-<wheel-right>" #'ignore
  "M-<wheel-right>" #'ignore
  "A-<wheel-right>" #'ignore
  "C-<wheel-up>" #'ignore
  "S-<wheel-up>" #'ignore
  "M-<wheel-up>" #'ignore
  "A-<wheel-up>" #'ignore
  "C-<wheel-down>" #'ignore
  "S-<wheel-down>" #'ignore
  "M-<wheel-down>" #'ignore
  "A-<wheel-down>" #'ignore

  ;; Navigation/Edit
  "C-<delete>" #'ignore
  "C-<right>" #'ignore
  "C-<left>" #'ignore
  "C-<up>" #'ignore
  "C-<down>" #'ignore
  "M-<escape>" #'ignore
  "M-<backspace>" #'my/delete-back-to-indentation
  "M-<delete>" #'kill-line
  "M-<right>" #'end-of-visual-line
  "M-<left>" #'beginning-of-visual-line
  "A-<backspace>" #'backward-kill-word
  "A-<delete>" #'kill-word
  "A-<kp-delete>" #'kill-word
  "A-<right>" #'right-word
  "A-<left>" #'left-word

  ;; Frames/Windows
  "A-<escape>" #'ns-next-frame
  "A-~" #'ns-prev-frame
  "C-M-f" #'toggle-frame-fullscreen
  "C-M-e" #'ns-do-show-character-palette
  "M-u" #'universal-argument
  "M-c" #'kill-ring-save
  "M-n" #'make-frame
  "M-t" #'tab-new
  "M-w" #'my/quit-dwim
  "M-m" #'iconify-frame
  "M-h" #'ns-do-hide-emacs
  "M-," #'my/edit-emacs-init
  "C-M-," #'my/edit-emacs-early-init

  ;; Apply Prefix Map to C-c
  "C-c" my/personal-map)

;;; ----------------------------------------------------------------------------
;;; Mode Definition
;;; ----------------------------------------------------------------------------

;;;###autoload
(define-minor-mode my-keybindings-mode
  "A global minor mode for my personal custom keybindings."
  :global t
  :lighter " MyKeys"
  :keymap my-keybindings-mode-map
(if my-keybindings-mode
      (progn
        ;; Handle C-z unbind (hard to do in a keymap, easiest globally)
        (global-unset-key (kbd "C-z"))

        ;; Minibuffer specific maps (cannot be done in the minor mode map)
        (keymap-set minibuffer-mode-map "<escape>" #'abort-recursive-edit)
        (keymap-set minibuffer-mode-map "C-u" #'scroll-down-command)
        (keymap-set minibuffer-mode-map "C-d" #'scroll-up-command)
        (keymap-set minibuffer-mode-map "<prior>" #'scroll-down-command)
        (keymap-set minibuffer-mode-map "<next>" #'scroll-up-command)

        ;; Help map
        (keymap-set help-map "=" #'describe-char))

    ;; Note: Truly "restoring" global unsets like C-z is complex,
    ;; so just leave them or rebind to original.
    (global-set-key (kbd "C-z") #'suspend-frame)))

(provide 'my-keybindings)

;;; my-keybindings.el ends here
