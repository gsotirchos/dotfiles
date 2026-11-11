;;; my-latex-preview.el --- Sizing and colour of LaTeX preview overlays  -*- lexical-binding: t; -*-

;;; Commentary:

;; AUCTeX displays LaTeX fragments as images in an overlay, at a size fixed
;; when the image was generated.  This package keeps that size in step with
;; the text around it, for both `text-scale-mode' and
;; `global-text-scale-adjust', and clears the previews when the theme (and
;; with it the foreground colour baked into the images) changes.
;;
;; The functions are meant to be hooked up by whoever configures AUCTeX;
;; only the `global-text-scale-adjust' advice is installed here, since that
;; command is global and offers no hook.  The advice also resizes
;; markdown-ts-appear's MathJax previews, which miss it for the same reason.

;;; Code:

(require 'face-remap)

(declare-function markdown-ts-appear-mathjax--appearance "markdown-ts-appear-mathjax")

(defun my/latex-preview-overlays ()
  "Return the LaTeX preview overlays in the current buffer."
  (seq-filter (lambda (overlay) (eq (overlay-get overlay 'category) 'preview-overlay))
              (overlays-in (point-min) (point-max))))

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
    (dolist (overlay (my/latex-preview-overlays))
      (when-let* ((image (overlay-get overlay 'display)))
        (setf (image-property image :scale) scale)
        (overlay-put overlay 'display image)))))

;;;###autoload
(defun my/global-text-scale-adjust-latex-previews (&rest _)
  "Adjust the size of latex fragments in every buffer."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (my/text-scale-adjust-latex-previews)))
  ;; TODO: Report upstream; the previews ignore `global-text-scale-adjust',
  ;; and `markdown-ts-appear-mathjax--appearance' is private.
  (when (fboundp 'markdown-ts-appear-mathjax--appearance)
    (markdown-ts-appear-mathjax--appearance)))

;;;###autoload
(defun my/latex-preview-foreground-advice (icon)
  "Draw ICON in the foreground colour of `preview-reference-face'.
ICON is `preview-create-icon''s return value.  dvisvgm's --currentcolor
leaves the colour to Emacs, which otherwise draws the image in the
foreground of the math face it covers."
  (setf (image-property (car icon) :foreground)
        (face-attribute 'preview-reference-face :foreground nil 'default))
  icon)

;;;###autoload
(defun my/delete-latex-preview-overlays (&rest _)
  "Delete only LaTeX preview overlays in the current buffer."
  (mapc #'delete-overlay (my/latex-preview-overlays)))

;; `global-text-scale-adjust' resizes the `default' face rather than adding a
;; buffer-local remapping, so it runs no hook to attach this to.
(advice-add 'global-text-scale-adjust :after #'my/global-text-scale-adjust-latex-previews)

(provide 'my-latex-preview)

;;; my-latex-preview.el ends here
