;;; my-modus-ui-styles.el --- Custom extensions and styling for modus-themes -*- lexical-binding: t; -*-

;;; Commentary:
;; Custom extensions, style cycling (flat/3d/minimal), button customization,
;; and system appearance integrations for modus-themes.

;;; Code:

(require 'modus-themes)

;;;###autoload
(defvar my/modus-themes/ui-style 'minimal
  "The current style of the mode-line, tab-bar, and buttons.
Can be `flat' (or nil), `3d' (or t), or `minimal'.")

;;;###autoload
(defun my/modus-themes/set-ui-style (&optional style)
  "Activate style theme (mode-line, buttons, etc.).
STYLE can be `flat' (or nil), `3d' (or t), or `minimal'.
If STYLE is \\='cycle, cycle the current style."
  (interactive "P")
  (when style
    (setq my/modus-themes/ui-style
          (if (eq style 'cycle)
              (pcase my/modus-themes/ui-style
                ((or 'nil 'flat) '3d)
                ((or 't '3d) 'minimal)
                ('minimal 'flat)
                (_ 'minimal))
            style)))
  (let* ((is-3d (memq my/modus-themes/ui-style '(3d t)))
         (is-minimal (eq my/modus-themes/ui-style 'minimal))
         (button-style (when is-3d 'released-button))
         (width (if is-3d 2 1))
         (bold-tab-faces-p nil)
         (bg-main (modus-themes-get-color-value 'bg-main))
         (bg-dim (modus-themes-get-color-value 'bg-dim))
         (fg-active (modus-themes-get-color-value 'fg-mode-line-active))
         (fg-inactive (modus-themes-get-color-value 'fg-mode-line-inactive))
         (bg-active (modus-themes-get-color-value 'bg-mode-line-active))
         (bg-inactive (modus-themes-get-color-value 'bg-mode-line-inactive))
         (border-active (modus-themes-get-color-value 'border-mode-line-active))
         (border-inactive (modus-themes-get-color-value 'border-mode-line-inactive))
         (color-active (if is-3d bg-active border-active))
         (color-inactive (if is-3d bg-inactive border-inactive))
         (box-minimal (list :line-width 2 :color bg-main))
         (box-active (if is-minimal
                         box-minimal
                       (append (list :line-width width :color color-active)
                               (when button-style (list :style button-style)))))
         (box-inactive (if is-minimal
                           box-minimal
                         (append (list :line-width width :color color-inactive)
                                 (when button-style (list :style button-style))))))
    (set-face-bold 'tab-bar bold-tab-faces-p)
    (set-face-bold 'tab-bar-tab bold-tab-faces-p)
    (set-face-bold 'tab-bar-tab-inactive bold-tab-faces-p)
    (if is-minimal
        (progn
          (pcase-dolist
              (`(,face ,fg ,ol ,ul)
               `((mode-line            unspecified  ,bg-inactive nil)
                 (mode-line-active     unspecified  ,bg-inactive nil)
                 (mode-line-inactive   unspecified  ,bg-dim      nil)
                 (header-line          unspecified  nil          (:color ,bg-dim :position 0))
                 (tab-bar              ,fg-inactive nil          (:color ,bg-inactive :position 0))
                 (tab-bar-tab          ,fg-active   nil          (:color ,bg-inactive :position 0))
                 (tab-bar-tab-inactive ,fg-inactive nil          (:color ,bg-inactive :position 0))))
            (set-face-attribute face nil
                                :box box-active
                                :foreground fg
                                :background bg-main
                                :overline ol
                                :underline ul))
          (pcase-dolist
              (`(,face ,ol ,ul)
               `((mode-line-highlight   ,bg-inactive nil)
                 (header-line-highlight nil          ,bg-dim)))
            (set-face-attribute face nil
                                :box nil
                                :overline ol
                                :underline ul))
          (set-face-attribute 'modus-themes-button nil
                              :overline nil
                              :underline nil))
      (progn
        (set-face-attribute 'tab-bar nil
                            :box nil
                            :overline 'unspecified
                            :underline 'unspecified
                            :background bg-main)
        (dolist (face
                 '(mode-line
                   mode-line-active
                   tab-bar-tab
                   modus-themes-button))
          (set-face-attribute face nil
                              :box box-active
                              :overline 'unspecified
                              :underline 'unspecified
                              :background bg-active))
        (dolist (face
                 '(header-line
                   mode-line-inactive
                   tab-bar-tab-inactive))
          (set-face-attribute face nil
                              :box box-inactive
                              :overline 'unspecified
                              :underline 'unspecified
                              :background bg-inactive))
        (dolist (face
                 '(mode-line-highlight
                   header-line-highlight))
          (set-face-attribute face nil
                              :box box-active
                              :overline nil
                              :underline nil))))
    (my/customize-buttons-faces)))

;;;###autoload
(defun my/modus-themes/cycle-ui-style ()
  "Cycle the theme style between Flat, 3D, and Minimal."
  (interactive)
  (my/modus-themes/set-ui-style 'cycle)
  (message "Modus theme style set to: %s" my/modus-themes/ui-style))

;;;###autoload
(defun my/customize-buttons-faces ()
  "Update the \"custom\" buttons' styles as a hook."
  (dolist (face
           '(custom-button
             custom-button-mouse
             custom-button-pressed
             custom-button-unraised
             custom-button-pressed-unraised
             modus-themes-button))
    (when (facep face)
      (if (eq my/modus-themes/ui-style 'minimal)
          (let* ((bg (face-attribute face :background nil t))
                 (bg-color (if (or (eq bg 'unspecified) (null bg))
                               (modus-themes-get-color-value 'bg-mode-line-inactive)
                             bg)))
            (set-face-attribute face nil :box (list :line-width '(4 . 2) :color bg-color)))
        (set-face-attribute face nil :box (face-attribute 'modus-themes-button :box)))))
  (when (facep 'widget-inactive)
    (set-face-attribute 'widget-inactive nil :box nil)))

;;;###autoload
(defun my/apply-theme (appearance)
  "Load the appropriate light/dark theme depending on system APPEARANCE."
  (pcase appearance
    ('light (modus-themes-load-theme (nth 0 modus-themes-to-toggle)))
    ('dark (modus-themes-load-theme (nth 1 modus-themes-to-toggle)))))

;;;###autoload
(add-hook 'after-load-theme-hook #'my/modus-themes/set-ui-style)
;;;###autoload
(add-hook 'Custom-mode-hook #'my/customize-buttons-faces)

(provide 'my-modus-ui-styles)

;;; my-modus-ui-styles.el ends here