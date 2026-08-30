;;; my-auto-scroll-bar.el --- Hide scroll bars that have nothing to scroll  -*- lexical-binding: t; -*-
;;; Commentary:

;; `scroll-bar-mode' puts a scroll bar in every window, including those
;; already showing their buffer in full.  This package hides the
;; vertical scroll bar in each such window and brings it back as soon
;; as the buffer outgrows the window.
;;
;; Hiding the bar widens the text area, so wrapped text reflows a
;; little.  That cannot oscillate: a wider window only ever shortens a
;; wrapped buffer and a narrower one only ever lengthens it, so the
;; decision still holds once applied.
;;
;; Only visibility is adjustable here.  On the NS build the bar's
;; colours are fixed: `nsfns.m' discards the `scroll-bar-foreground'
;; and `scroll-bar-background' frame parameters, and `nsterm.m' never
;; consults the `scroll-bar' face.

;;; Code:

(defgroup my-auto-scroll-bar nil
  "Hide scroll bars in windows that show their whole buffer."
  :group 'convenience)

(defvar my/auto-scroll-bar-triggers '(post-command-hook window-state-change-hook)
  "Hooks after which every window's scroll bar is reconsidered.")

(defun my/auto-scroll-bar-needed-p (window)
  "Return non-nil if WINDOW does not show the whole of its buffer."
  (with-current-buffer (window-buffer window)
    (not (and (pos-visible-in-window-p (point-min) window)
              (pos-visible-in-window-p (point-max) window)))))

(defun my/auto-scroll-bar-update (&rest _)
  "Give a vertical scroll bar only to windows that have something to scroll."
  (walk-windows
   (lambda (window)
     (let ((needed (and (my/auto-scroll-bar-needed-p window) t)))
       ;; Writing counts as a window state change, which runs this again;
       ;; comparing first makes that second pass a no-op and terminates it.
       (unless (eq needed (nth 2 (window-scroll-bars window)))
         (set-window-scroll-bars window nil needed))))
   nil 'visible))

(defun my/auto-scroll-bar-restore ()
  "Give every window back the scroll bar of its frame."
  (walk-windows (lambda (window) (set-window-scroll-bars window nil t))
                nil 'visible))

;;;###autoload
(define-minor-mode my-auto-scroll-bar-mode
  "Toggle hiding of vertical scroll bars that have nothing to scroll.
When enabled, each window keeps its frame's scroll bar only while
part of its buffer is off screen, rechecked after each of the
`my/auto-scroll-bar-triggers'."
  :global t
  :group 'my-auto-scroll-bar
  (if my-auto-scroll-bar-mode
      (progn
        (dolist (hook my/auto-scroll-bar-triggers)
          (add-hook hook #'my/auto-scroll-bar-update))
        (my/auto-scroll-bar-update))
    (dolist (hook my/auto-scroll-bar-triggers)
      (remove-hook hook #'my/auto-scroll-bar-update))
    (my/auto-scroll-bar-restore)))

(provide 'my-auto-scroll-bar)
;;; my-auto-scroll-bar.el ends here
