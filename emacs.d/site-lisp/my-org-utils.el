;;; my-org-utils.el --- Org Mode interactive utilities and bindings  -*- lexical-binding: t; -*-

;;; Commentary:

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
  (shell-command-on-region start end "pandoc -f markdown+tex_math_single_backslash -t org" t t))

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
    ;; This additional encoding specifically of =/= is because Mail.app
    ;; claims to be unable to find a message if it's ID contains unencoded
    ;; slashes.
    (browse-url-url-encode-chars
     (buffer-substring-no-properties (point-min) (- (point-max) 1))
     "[/]")))

;;;###autoload
(defun my/org-insert-mac-mail-link-string ()
  "Insert an Org link for the currently selected email in Mail.app."
  (interactive)
  (let* ((message-id (org-mac-mail-link-get-selected-message-id))
         (title (read-string "Link title: "))
         (link (org-link-make-string (format "message:%%3C%s%%3E" message-id) title)))
    (insert link)))


;;; Minor Mode & Keymap

(defvar-keymap my-org-utils-mode-map
  :doc "Keymap for my-org-utils-mode."
  ;; Note: You had C-c a (Agenda) in a local map.
  ;; Usually Agenda is global, but I'm preserving your logic here.
  "C-c a" #'org-agenda
  "C-c C-x m" #'my/org-toggle-emphasis-marker-display
  "C-c C-x l" #'org-toggle-link-display
  "<remap> <org-emphasize>" #'my/org-emphasize-dwim)

;;;###autoload
(define-minor-mode my-org-utils-mode
  "Minor mode for personal Org Mode utilities and bindings."
  :lighter " OrgUtils"
  :keymap my-org-utils-mode-map
  ;; This mode is NOT global; it turns on per-buffer
  :global nil)

(provide 'my-org-utils)

;;; my-org-utils.el ends here
