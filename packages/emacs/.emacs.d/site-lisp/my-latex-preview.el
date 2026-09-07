;;; my-latex-preview.el --- Sizing of LaTeX preview overlays  -*- lexical-binding: t; -*-

;;; Commentary:

;; Org and AUCTeX both display LaTeX fragments as images in an overlay, at a
;; size fixed when the image was generated.  This package keeps that size in
;; step with the text around it, for both `text-scale-mode' and
;; `global-text-scale-adjust', and clears the previews when the theme (and
;; with it the foreground colour baked into the images) changes.
;;
;; The functions are meant to be hooked up by whoever configures Org and
;; AUCTeX; only the `global-text-scale-adjust' advice is installed here,
;; since that command is global and offers no hook.

;;; Code:

(require 'face-remap)

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

(defun my/text-scale-overlays (category-type category-name scale)
  "Display the images of overlays matching CATEGORY-TYPE at SCALE.
An overlay matches when its CATEGORY-TYPE property is CATEGORY-NAME."
  (dolist (overlay (overlays-in (point-min) (point-max)))
    (let ((overlay-category (overlay-get overlay category-type)))
      (when (and overlay-category
                 (eq overlay-category category-name))
        (let ((scale-fn (lambda (_) scale)))
          (my/update-overlay-property-cdr
           overlay
           'display
           (lambda (value-cdr-plist)
             (my/update-plist-property
              value-cdr-plist
              :scale
              scale-fn))))))))

(defun my/latex-preview-scale ()
  "Return the scale LaTeX preview images should be displayed at.
Combines the buffer's `text-scale-mode' factor with the ratio by which
`global-text-scale-adjust' has grown the `default' face."
  (let ((base-height (bound-and-true-p global-text-scale-adjust--default-height))
        (height (face-attribute 'default :height)))
    (* (expt text-scale-mode-step text-scale-mode-amount)
       (if (and (numberp base-height) (numberp height))
           (/ (float height) base-height)
         1.0))))

;;;###autoload
(defun my/text-scale-adjust-latex-previews (&rest _)
  "Adjust the size of latex fragments when changing the buffer's text scale."
  (let ((scale (my/latex-preview-scale)))
    (my/text-scale-overlays 'category 'preview-overlay scale)
    (my/text-scale-overlays 'org-overlay-type 'org-latex-overlay scale)))

;;;###autoload
(defun my/global-text-scale-adjust-latex-previews (&rest _)
  "Adjust the size of latex fragments in every buffer."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (my/text-scale-adjust-latex-previews))))

;;;###autoload
(defun my/delete-latex-preview-overlays (&rest _)
  "Delete only LaTeX preview overlays in the current buffer."
  (dolist (overlay (overlays-in (point-min) (point-max)))
    (let ((category (overlay-get overlay 'category))
          (org-type (overlay-get overlay 'org-overlay-type)))
      (when (or (eq category 'preview-overlay)
                (eq org-type 'org-latex-overlay))
        (delete-overlay overlay)))))

;; `global-text-scale-adjust' resizes the `default' face rather than adding a
;; buffer-local remapping, so it runs no hook to attach this to.
(advice-add 'global-text-scale-adjust :after #'my/global-text-scale-adjust-latex-previews)

(provide 'my-latex-preview)

;;; my-latex-preview.el ends here
