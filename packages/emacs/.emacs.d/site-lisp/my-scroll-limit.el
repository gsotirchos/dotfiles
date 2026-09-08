;;; my-scroll-limit.el --- Stop scrolling at the last line of the buffer  -*- lexical-binding: t; -*-
;;; Commentary:

;; Emacs lets the last line of a buffer be scrolled all the way up to
;; the top of the window and fills what is left of the window with
;; empty space.  This package scrolls a window back as soon as such
;; space appears, so the end of the buffer never rises above the
;; bottom of the window.
;;
;; Emacs offers no setting for this: its scroll commands only refuse to
;; go on once the last line has already reached the top.  See
;; https://lists.gnu.org/r/emacs-devel/2012-10/msg00652.html

;;; Code:

(defgroup my-scroll-limit nil
  "Keep the end of the buffer at the bottom of the window."
  :group 'convenience)

(defvar my/scroll-limit-triggers '(post-command-hook window-state-change-hook)
  "Hooks after which every window's scroll position is reconsidered.")

(defun my/scroll-limit-empty-space (window)
  "Return the pixels of empty space below the last line of WINDOW's buffer.
Return nil when the end of the buffer is off screen."
  (let ((last-line (pos-visible-in-window-p (point-max) window t)))
    (when last-line
      (- (window-body-height window t)
         (+ (nth 1 last-line)
            (save-excursion (goto-char (point-max)) (line-pixel-height)))))))

(defun my/scroll-limit-scroll-back (window pixels)
  "Scroll WINDOW back by PIXELS, stopping at the beginning of its buffer."
  (let ((vscroll (window-vscroll window t)))
    (if (>= vscroll pixels)
        (set-window-vscroll window (- vscroll pixels) t t)
      (let ((wanted (- pixels vscroll))
            (scrolled 0))
        (save-excursion
          (goto-char (window-start window))
          (while (and (< scrolled wanted)
                      (/= 0 (vertical-motion -1)))
            (setq scrolled (+ scrolled (line-pixel-height))))
          ;; Whole lines overshoot, so the excess is given back as a
          ;; vscroll below.  A forced window start would cancel it.
          (set-window-start window (point) t))
        (set-window-vscroll window (max 0 (- scrolled wanted)) t t)))))

(defun my/scroll-limit-update (&rest _)
  "Scroll back every window that shows empty space past its buffer's end."
  (walk-windows
   (lambda (window)
     (unless (window-minibuffer-p window)
       (with-selected-window window
         (let ((empty-space (my/scroll-limit-empty-space window)))
           ;; Scrolling counts as a window state change, which runs this
           ;; again; that second pass finds no empty space and ends it.
           (when (and empty-space
                      (> empty-space 0)
                      (> (window-start) (point-min)))
             (my/scroll-limit-scroll-back window empty-space))))))
   nil 'visible))

;;;###autoload
(define-minor-mode my-scroll-limit-mode
  "Toggle scrolling limited to the last line of the buffer.
When enabled, no window shows empty space past the end of its
buffer, rechecked after each of the `my/scroll-limit-triggers'."
  :global t
  :group 'my-scroll-limit
  (if my-scroll-limit-mode
      (progn
        (dolist (hook my/scroll-limit-triggers)
          (add-hook hook #'my/scroll-limit-update))
        (my/scroll-limit-update))
    (dolist (hook my/scroll-limit-triggers)
      (remove-hook hook #'my/scroll-limit-update))))

(provide 'my-scroll-limit)
;;; my-scroll-limit.el ends here
