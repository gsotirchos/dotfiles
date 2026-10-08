;;; my-stripes.el --- Zebra-stripe the Corfu popup and Vertico list -*- lexical-binding: t; -*-

;;; Commentary:
;; Extend the `stripes' face to the Corfu completion popup and the Vertico
;; minibuffer candidate list.  Both are re-rendered on every keystroke into a
;; transient child-frame buffer / minibuffer overlay that `stripes-mode' cannot
;; reach (its `after-change-functions' overlays never survive), so the striping
;; is installed as advice on their formatting entry points instead.  Stripes are
;; keyed by visible row (so they stay put while scrolling) and skip the current
;; selection so they don't clobber `corfu-current' / `vertico-current'.
;;
;; Reuses the `stripes' face, so its color follows whatever `stripes-mode' is
;; configured with elsewhere (see the `stripes' block in init.el).
;;
;; Also keeps `stripes-mode' from hiding the mark background of Dired file
;; names: overlay faces override text-property faces regardless of priority.

;;; Code:

(require 'cl-lib)
(require 'stripes nil t)

(defvar stripes-overlay-priority)
(defvar vertico--index)
(defvar dired-re-mark)
(declare-function corfu--popup-show "corfu")
(declare-function dired-move-to-filename "dired")
(declare-function vertico--format-candidate "vertico")

;;;; Corfu candidate popup

(defun my/stripes--line-has-face-p (face)
  "Non-nil if the face property at the start of the current line includes FACE."
  (let ((f (get-text-property (line-beginning-position) 'face)))
    (or (eq f face) (and (listp f) (memq face f)))))

;;;###autoload
(defun my/stripes-corfu-popup (&rest _)
  "Zebra-stripe the *corfu* candidate buffer, skipping the selected row."
  (when-let* ((buf (get-buffer " *corfu*")))
    (with-current-buffer buf
      (remove-overlays nil nil 'my/stripes t)
      (save-excursion
        (goto-char (point-min))
        (let ((row 0))
          (while (not (eobp))
            (when (and (cl-oddp row)
                       (not (my/stripes--line-has-face-p 'corfu-current)))
              (let ((ov (make-overlay (line-beginning-position)
                                      (min (point-max) (1+ (line-end-position))))))
                (overlay-put ov 'my/stripes t)
                (overlay-put ov 'face 'stripes)
                (overlay-put ov 'priority stripes-overlay-priority)))
            (cl-incf row)
            (forward-line 1)))))))

;;;; Vertico minibuffer completion list (e.g. M-x)

;;;###autoload
(defun my/stripes-vertico-candidate (orig cand prefix suffix index start)
  "Zebra-stripe Vertico candidates by visible row, skipping the selected row.
ORIG is the advised `vertico--format-candidate'; CAND, PREFIX, SUFFIX, INDEX
and START are its arguments."
  (let ((str (funcall orig cand prefix suffix index start)))
    (when (and (cl-oddp (- index start))  ;; row-based: stays put while scrolling
               (/= index vertico--index))
      (setq str (copy-sequence str))
      (add-face-text-property 0 (length str) 'stripes 'append str))
    str))

;;;; Dired marked files

;;;###autoload
(defun patch/stripes-dired-unstripe-marked (&rest _)
  "Cut the stripes out of marked file names in the current Dired buffer."
  (when (derived-mode-p 'dired-mode)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward dired-re-mark nil t)
        (when-let* ((beg (dired-move-to-filename)))
          (remove-overlays beg (line-end-position) 'face 'stripes))))))

;;;###autoload
(with-eval-after-load 'stripes
  (advice-add 'stripes-create :after #'patch/stripes-dired-unstripe-marked))
;;;###autoload
(with-eval-after-load 'corfu
  (advice-add 'corfu--popup-show :after #'my/stripes-corfu-popup))
;;;###autoload
(with-eval-after-load 'vertico
  (advice-add 'vertico--format-candidate :around #'my/stripes-vertico-candidate))

(provide 'my-stripes)

;;; my-stripes.el ends here
