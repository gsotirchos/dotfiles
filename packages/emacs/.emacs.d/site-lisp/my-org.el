;;; my-org.el --- Org Mode interactive utilities and configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; This file groups together interactive Org-mode utilities, configurations,
;; custom advices, and visual customizations.

;;; Code:

(require 'org)

;;;###autoload
(defun my/org-emphasize-dwim (&optional char)
  "DWIM (Do What I Mean) wrapper for `org-emphasize'.
If there's an active region, apply emphasis to it.
Otherwise, apply emphasis to the word at point (CHAR)."
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

;;;###autoload
(defun my/org-toggle-emphasis-marker-display ()
  "Toggle emphasis marker visibility."
  (interactive)
  (setq org-hide-emphasis-markers (not org-hide-emphasis-markers))
  (font-lock-update)
  (message "Emphasis markers are now %s." (if org-hide-emphasis-markers "hidden" "visible")))

;;;###autoload
(defun my/org-latex-preview-buffer ()
  "Preview all LaTeX fragments in buffer."
  (interactive)
  (org-latex-preview '(16)))

;;;###autoload
(defun my/convert-md-region-to-org (start end)
  "Convert contents between START and END from markdown to org."
  (interactive "r")
  (shell-command-on-region start end "pandoc -f markdown-smart+tex_math_single_backslash -t org --wrap=none" t t))

;;;###autoload
(defun my/org-remove-drawers-in-region (start end)
  "Remove all Org-mode drawers between START and END."
  (interactive "r")
  (save-excursion
    (goto-char start)
    (let ((drawer-regexp "^\s*:\\w*:\n\\(\s*:.*\n\\)*\s*:END:\s*\n"))
      (while (re-search-forward drawer-regexp end t)
        ;; Delete the match, including the newline
        (replace-match "" nil nil)))))

;;;###autoload
(defun my/org-mac-mail-link-get-selected-message-id ()
  "Query Mail.app and get the Message-ID of currently selected message."
  (with-temp-buffer
    (call-process
     "osascript" nil t nil
     "-e" "tell application \"Mail\" to get message id of item 1 of (selection as list)")
    (browse-url-url-encode-chars
     (buffer-substring-no-properties (point-min) (- (point-max) 1))
     "[/]")))

;;;###autoload
(defun my/org-insert-mac-mail-link-string ()
  "Insert an Org link for the currently selected email in Mail.app."
  (interactive)
  (let* ((message-id (my/org-mac-mail-link-get-selected-message-id))
         (title (read-string "Link title: "))
         (link (org-link-make-string (format "message:%%3C%s%%3E" message-id) title)))
    (insert link)))


;;; ----------------------------------------------------------------------------
;;; Custom Advices & Auxiliary Functions (Migrated from init.el)
;;; ----------------------------------------------------------------------------

;;;###autoload
(defun my/org-create-archive-dir (&rest _)
  "Automatically create the .archive directory if it doesn't exist."
  (let* ((location (org-archive--compute-location
                    (or (org-entry-get nil "ARCHIVE" 'inherit) org-archive-location)))
         (afile (car location))
         (dir (when afile (file-name-directory afile))))
    (when (and dir (not (file-exists-p dir)))
      (make-directory dir t))))

;;;###autoload
(defun my/unlimited-fill-column-advice (fn &rest args)
  "Execute FN with ARGS with `fill-column' set to the maximum possible value."
  (let ((fill-column most-positive-fixnum))
    (apply fn args)))

;;;###autoload
(defun my/org-mac-mail-link-open-link (mid _)
  "Follow link (MID) function for Apple Mail messages."
  (start-process "open-link" nil "open" (format "message://%%3C%s%%3E" mid)))

;;;###autoload
(defun my/adjust-preview-latex-scale ()
  "Adjust `org-format-latex-options' scale based on text-scaling and monitor DPI."
  (let* ((step (if (boundp 'text-scale-mode-step) text-scale-mode-step 1.2))
         (amount (if (boundp 'text-scale-mode-amount)
                     (or text-scale-mode-amount 0)
                   0))
         (text-scaling (expt step amount))
         (monitor-attrs (car (display-monitor-attributes-list)))
         (monitor-scale-pair (assoc 'scale-factor monitor-attrs))
         (monitor-scaling (if monitor-scale-pair (cdr monitor-scale-pair) 1.0))
         (scaling-fn (lambda (_) (/ text-scaling monitor-scaling))))
    (my/update-plist-property org-format-latex-options :scale scaling-fn)))

;;;###autoload
(defun my/customize-org-mode ()
  "Apply my tweaks to theme-controlled settings."
  (setq org-todo-keyword-faces
        `(("NEXT" . ,(modus-themes-get-color-value 'green))
          ("WIP" . ,(modus-themes-get-color-value 'blue))
          ("WAIT" . ,(modus-themes-get-color-value 'red-faint))
          ("FAIL" . ,(modus-themes-get-color-value 'red))))
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


;;; ----------------------------------------------------------------------------
;;; Global Setup & Advices (Applied on load)
;;; ----------------------------------------------------------------------------

(advice-add 'org-archive-subtree :before #'my/org-create-archive-dir)
(advice-add 'org-fill-paragraph :around #'my/unlimited-fill-column-advice)
(advice-add 'my/org-latex-preview-buffer :around #'my/silence-advice)
(advice-add 'org-latex-preview :after #'my/text-scale-adjust-latex-previews)

(my/adjust-preview-latex-scale)
(plist-put org-format-latex-options :background "Transparent")
(org-link-set-parameters "message" :follow #'my/org-mac-mail-link-open-link)

(font-lock-add-keywords 'org-mode
                        '(;; Org headings (e.g., "* ", "** ")
                          ("^\\*+ " 0 'fixed-pitch prepend)
                          ;; Any leading whitespace (aligns descriptions)
                          ("^[ \t]+" 0 'fixed-pitch prepend)
                          ;; Unordered list items (e.g., "- ", "+ ", "* ")
                          ("^[ \t]*[-+*][ \t]+" 0 'fixed-pitch prepend)
                          ;; Ordered list items (e.g., "1. ", "a) ")
                          ("^[ \t]*[a-zA-Z0-9]+[.)][ \t]+" 0 'fixed-pitch prepend))
                        'append)


;;; Minor Mode & Keymap

(defvar-keymap my-org-mode-map
  :doc "Keymap for my-org-mode."
  "C-c a" #'org-agenda
  "C-c C-x m" #'my/org-toggle-emphasis-marker-display
  "C-c C-x l" #'org-toggle-link-display
  "<remap> <org-emphasize>" #'my/org-emphasize-dwim)

;;;###autoload
(define-minor-mode my-org-mode
  "Minor mode for personal Org Mode utilities and bindings."
  :lighter " MyOrg"
  :keymap my-org-mode-map
  ;; This mode is NOT global; it turns on per-buffer
  :global nil
  (if my-org-mode
      (progn
        (visual-line-mode 1)
        (my/customize-org-mode)
        (add-hook 'after-load-theme-hook #'my/customize-org-mode nil t)
        (add-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews nil t)
        (add-hook 'after-load-theme-hook #'my/delete-latex-preview-overlays nil t)
        (dolist (hook
                 '(after-load-theme-hook
                   auto-save-hook
                   after-save-hook))
          (add-hook hook #'my/org-latex-preview-buffer nil t)))
    ;; Cleanup if turned off
    (remove-hook 'after-load-theme-hook #'my/customize-org-mode t)
    (remove-hook 'text-scale-mode-hook #'my/text-scale-adjust-latex-previews t)
    (remove-hook 'after-load-theme-hook #'my/delete-latex-preview-overlays t)
    (dolist (hook
                 '(after-load-theme-hook
                   auto-save-hook
                   after-save-hook))
      (remove-hook hook #'my/org-latex-preview-buffer t))))

(provide 'my-org)

;;; my-org.el ends here
