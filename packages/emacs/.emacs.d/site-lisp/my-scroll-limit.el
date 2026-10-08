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

(defgroup my/scroll-limit nil
  "Keep the end of the buffer at the bottom of the window."
  :group 'convenience)

(defvar my/scroll-limit-triggers '(post-command-hook)
  "Hooks after which every window's scroll position is reconsidered.")

(defvar my/scroll-limit-deferred-triggers '(window-state-change-hook)
  "Hooks after whose bursts every window's scroll position is reconsidered.
Each run postpones the check by `my/scroll-limit-settle-delay'.  A
frame resize runs `window-state-change-hook' on every step, and
walking the windows from inside each redisplay makes the NS port
flicker throughout the resize.")

(defvar my/scroll-limit-settle-delay 0.05
  "Seconds without a deferred trigger after which the check runs.")

(defvar my/scroll-limit--settle-timer nil
  "Timer running the check once the deferred triggers settle.")

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

(defun my/scroll-limit-scroll-forward (window pixels)
  "Scroll WINDOW forward by PIXELS, within its first screen line."
  (set-window-vscroll window (+ (window-vscroll window t) pixels) t t))

(defun my/scroll-limit-cursor-cut-off-p (window)
  "Return non-nil when the cursor's line is cut off at the bottom of WINDOW."
  (let ((below-window (nth 3 (pos-visible-in-window-p (point) window t))))
    (and below-window (> below-window 0))))

(defun my/scroll-limit-cursor-line-fits-p (window)
  "Return non-nil when the cursor's line is no taller than WINDOW's body.
A taller line, such as a PDF page displayed as a single image, is paged
through by vscroll, which bringing its bottom into view would undo."
  (<= (line-pixel-height) (window-body-height window t)))

(defun my/scroll-limit-update (&rest _)
  "Keep the end of every window's buffer at the bottom of the window."
  ;; Redisplay waits for pending input to be consumed, so this can too:
  ;; a burst of scroll events is then checked once, before its frame.
  (unless (input-pending-p)
    (walk-windows
     (lambda (window)
       (unless (window-minibuffer-p window)
         (with-selected-window window
           (let ((empty-space (my/scroll-limit-empty-space window)))
             (cond
              ;; Scrolling counts as a window state change, which runs
              ;; this again; that second pass finds no empty space and
              ;; ends it.  A vscroll is worth undoing even at the
              ;; beginning of the buffer, where there is no line left to
              ;; scroll back over.
              ((and empty-space
                    (> empty-space 0)
                    (or (> (window-start) (point-min))
                        (> (window-vscroll window t) 0)))
               (my/scroll-limit-scroll-back window empty-space))
              ;; `line-move' clears the vscroll that holds the last line
              ;; flush with the bottom, cutting off the cursor on it.
              ;; Redisplay would uncover it by scrolling a whole line
              ;; past the end of the buffer, which the branch above
              ;; scrolls back on the next command: a jitter per keypress.
              ((and empty-space
                    (< empty-space 0)
                    (my/scroll-limit-cursor-cut-off-p window)
                    (my/scroll-limit-cursor-line-fits-p window))
               (my/scroll-limit-scroll-forward window (- empty-space))))))))
     nil 'visible)))

(defun my/scroll-limit-update-when-settled (&rest _)
  "Run `my/scroll-limit-update' once no call to this has come for a while.
The while is `my/scroll-limit-settle-delay'."
  (when (timerp my/scroll-limit--settle-timer)
    (cancel-timer my/scroll-limit--settle-timer))
  (setq my/scroll-limit--settle-timer
        (run-with-timer my/scroll-limit-settle-delay nil #'my/scroll-limit-update)))

;;;###autoload
(define-minor-mode my-scroll-limit-mode
  "Toggle scrolling limited to the last line of the buffer.
When enabled, no window shows empty space past the end of its
buffer, and the last line is held flush with the bottom while the
cursor is on it, rechecked after each of the
`my/scroll-limit-triggers' and after each burst of the
`my/scroll-limit-deferred-triggers'."
  :global t
  :group 'my/scroll-limit
  (if my-scroll-limit-mode
      (progn
        (dolist (hook my/scroll-limit-triggers)
          (add-hook hook #'my/scroll-limit-update))
        (dolist (hook my/scroll-limit-deferred-triggers)
          (add-hook hook #'my/scroll-limit-update-when-settled))
        (my/scroll-limit-update))
    (dolist (hook my/scroll-limit-triggers)
      (remove-hook hook #'my/scroll-limit-update))
    (dolist (hook my/scroll-limit-deferred-triggers)
      (remove-hook hook #'my/scroll-limit-update-when-settled))
    (when (timerp my/scroll-limit--settle-timer)
      (cancel-timer my/scroll-limit--settle-timer))))

(provide 'my-scroll-limit)
;;; my-scroll-limit.el ends here
