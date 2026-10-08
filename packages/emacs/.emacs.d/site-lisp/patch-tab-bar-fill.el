;;; patch-tab-bar-fill.el --- Tabs that split the full frame width evenly  -*- lexical-binding: t; -*-
;;; Commentary:

;; `tab-bar-auto-width' is meant to split the tab bar evenly among the
;; tabs, but misses the frame width in several ways:
;;
;; - it measures tab names without the `tab-bar' face they are drawn
;;   with, so a tab bar in another font gets tabs sized for the wrong one;
;; - its cache is keyed by width and name only, so after a font or theme
;;   change it keeps serving names sized for the old metrics;
;; - it pads with whole spaces, so each tab falls short of its share;
;; - it ignores the borders that adjacent tabs sharing a :box face merge.
;;
;; This package corrects all of these and centers each name in its tab.
;; An underlined last tab ends on a pixel-wide unboxed sliver, as Emacs
;; does not underline the box border that ends the tab bar.
;;
;; Pair it with `tab-bar-truncate': a tab bar filled to the frame's edge
;; otherwise wraps onto an empty second line.
;;
;; TODO: Report the `tab-bar-auto-width' issues above to bug-gnu-emacs;
;; none reported as of 2026-10-03.

;;; Code:

(require 'seq)
(require 'tab-bar)

(defgroup patch/tab-bar-fill nil
  "Split the full frame width evenly among the tabs."
  :group 'tab-bar)

(defvar patch/tab-bar-fill-tab-metrics nil
  "Tab face metrics under which the auto-width cache was filled.")

(defun patch/tab-bar-fill-invalidate-cache (&rest _)
  "Drop the auto-width cache once the tab face metrics change."
  (let ((metrics (string-pixel-width
                  (propertize "x" 'face '(tab-bar-tab tab-bar)))))
    (unless (eql metrics patch/tab-bar-fill-tab-metrics)
      ;; NOTE: `tab-bar--auto-width-hash' is private; revisit on updates.
      (setq patch/tab-bar-fill-tab-metrics metrics
            tab-bar--auto-width-hash nil))))

(defun patch/tab-bar-fill-labeled-p (item)
  "Return non-nil if tab-bar ITEM is a menu item with a string label."
  (and (eq (nth 1 item) 'menu-item)
       (stringp (nth 2 item))))

(defun patch/tab-bar-fill-measure-with-base-face (args)
  "Give the labels in the items of ARGS the `tab-bar' face they are drawn with."
  (list (mapcar (lambda (item)
                  (if (patch/tab-bar-fill-labeled-p item)
                      (let ((label (copy-sequence (nth 2 item))))
                        (add-face-text-property 0 (length label) 'tab-bar t label)
                        `(,(car item) menu-item ,label ,@(nthcdr 3 item)))
                    item))
                (car args))))

(defun patch/tab-bar-fill-underlined-p (label)
  "Return non-nil if the end of LABEL is drawn underlined."
  (seq-some (lambda (face)
              (and (facep face)
                   (not (memq (face-attribute face :underline nil t)
                              '(nil unspecified)))))
            (ensure-list (get-text-property (1- (length label)) 'face label))))

(defun patch/tab-bar-fill-sliver (label)
  "Return a pixel-wide, unboxed piece of LABEL's last face."
  (let ((sliver (propertize " " 'display '(space :width (1))
                            'face (get-text-property (1- (length label)) 'face label))))
    (add-face-text-property 0 1 '(:box nil) nil sliver)
    sliver))

(defun patch/tab-bar-fill-fit-name (name edge share)
  "Shorten NAME until it fits SHARE pixels between two EDGEs.
Function `tab-bar-auto-width' truncates a name together with its
trailing edge, so putting that edge back can overflow the tab and
the tab bar.  A further shortened name has its last two characters
faded with `shadow', as that function does."
  (let ((fitted name))
    (while (and (> (string-pixel-width (concat edge fitted edge)) share)
                (length> fitted 0))
      (setq fitted (substring fitted 0 -1)))
    (when (length< fitted (length name))
      (add-face-text-property (max 0 (- (length fitted) 2)) (length fitted)
                              'shadow nil fitted))
    fitted))

(defun patch/tab-bar-fill-stretch-tabs (items)
  "Stretch the auto-width tabs in ITEMS to fill the frame exactly.
Each name is centered in its tab."
  (let* ((labeled (seq-filter #'patch/tab-bar-fill-labeled-p items))
         (tabs (seq-filter (lambda (item)
                             (run-hook-with-args-until-success
                              'tab-bar-auto-width-functions item))
                           labeled))
         (others (seq-remove (lambda (item)
                               (or (memq item tabs)
                                   (eq (car item) 'align-right)))
                             labeled))
         (labels-width (lambda (items)
                         (apply #'+ (mapcar (lambda (item)
                                              (string-pixel-width (nth 2 item)))
                                            items))))
         (merged-borders (- (funcall labels-width tabs)
                            (string-pixel-width
                             (mapconcat (lambda (tab) (nth 2 tab)) tabs))))
         (last-tab (car (last tabs)))
         (sliver (and last-tab
                      (patch/tab-bar-fill-underlined-p (nth 2 last-tab))
                      (patch/tab-bar-fill-sliver (nth 2 last-tab))))
         (room (- (+ (- (frame-inner-width) (funcall labels-width others))
                     merged-borders)
                  (if sliver 1 0))))
    (seq-do-indexed
     (lambda (tab index)
       (let* ((label (nth 2 tab))
              (edge (apply #'propertize " " (text-properties-at 0 label)))
              (share (+ (/ room (length tabs))
                        (if (< index (% room (length tabs))) 1 0)))
              (name (patch/tab-bar-fill-fit-name (string-trim label) edge share))
              (slack (max 0 (- share (string-pixel-width (concat edge name edge)))))
              (stretch (lambda (width)
                         (apply #'propertize " " 'display `(space :width (,width))
                                (text-properties-at 0 edge)))))
         ;; Keep the stretches off the tab's edges, where a :box face
         ;; draws its border inside a stretch instead of beside it.
         (setf (nth 2 tab)
               (concat edge (funcall stretch (/ slack 2))
                       name (funcall stretch (- slack (/ slack 2)))
                       edge))))
     tabs)
    (when sliver
      (setf (nth 2 last-tab) (concat (nth 2 last-tab) sliver)))
    items))

(defconst patch/tab-bar-fill-advice
  '((:before . patch/tab-bar-fill-invalidate-cache)
    (:filter-args . patch/tab-bar-fill-measure-with-base-face)
    (:filter-return . patch/tab-bar-fill-stretch-tabs))
  "How each function of this package advises function `tab-bar-auto-width'.")

;;;###autoload
(define-minor-mode patch-tab-bar-fill-mode
  "Toggle tabs that split the full frame width evenly.
Takes effect while the option `tab-bar-auto-width' is non-nil."
  :global t
  :group 'patch/tab-bar-fill
  (pcase-dolist (`(,how . ,function) patch/tab-bar-fill-advice)
    (if patch-tab-bar-fill-mode
        (advice-add 'tab-bar-auto-width how function)
      (advice-remove 'tab-bar-auto-width function)))
  (setq patch/tab-bar-fill-tab-metrics nil
        tab-bar--auto-width-hash nil)
  (force-mode-line-update t))

(provide 'patch-tab-bar-fill)
;;; patch-tab-bar-fill.el ends here
