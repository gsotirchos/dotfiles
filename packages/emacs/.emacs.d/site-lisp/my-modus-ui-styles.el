;;; my-modus-ui-styles.el --- Custom extensions and styling for modus-themes -*- lexical-binding: t; -*-

;;; Commentary:
;; Custom extensions, style cycling (flat/3d/minimal), button customization,
;; and system appearance integrations for modus-themes.

;;; Code:

(require 'modus-themes nil t)

(defvar my/system-appearance-change-functions)
(declare-function my/theme-color "init" (name))

;;;###autoload
(defvar my/modus-themes/ui-style 'minimal
  "The current style of the mode-line, tab-bar, and buttons.
Can be `flat', `3d', or `minimal'.")

;;;###autoload
(defun my/modus-themes/set-ui-style (&optional style)
  "Activate style theme (mode-line, buttons, etc.).
STYLE can be `flat', `3d', or `minimal'.
If STYLE is \\='cycle, cycle the current style."
  (interactive "P")
  (when style
    (setq my/modus-themes/ui-style
          (if (eq style 'cycle)
              (pcase my/modus-themes/ui-style
                ('flat '3d)
                ('3d 'minimal)
                (_ 'flat))
            style)))
  (let* ((is-3d (eq my/modus-themes/ui-style '3d))
         (bg-main (my/theme-color 'bg-main))
         (bg-dim (my/theme-color 'bg-dim))
         (bg-hover (my/theme-color 'bg-hover))
         (fg-vertical-border (my/theme-color 'fg-vertical-border))
         (fg-active (my/theme-color 'fg-mode-line-active))
         (fg-inactive (my/theme-color 'fg-mode-line-inactive))
         (bg-active (my/theme-color 'bg-mode-line-active))
         (bg-inactive (my/theme-color 'bg-mode-line-inactive))
         (box-minimal (list :line-width 8 :color bg-main))
         (box-minimal-thin (list :line-width 6 :color bg-main))
         (box-minimal-highlight (list :line-width 8 :color bg-hover))
         (box-minimal-highlight-thin (list :line-width 6 :color bg-hover))
         (underline-minimal (list :color bg-inactive :position 0))
         (underline-minimal-thin (list :color bg-dim :position 0)))
    ;;;;; In ordered of increasing intensity:
    ;; 1. bg-main
    ;; 2. bg-dim
    ;; 3. bg-inactive (same as macOS separator line)
    ;; 4. bg-active
    ;; 5. border-inactive
    ;; 6. border-active (very close to fg-inactive)
    ;; 7. fg-inactive
    ;; 8. fg-active
    ;;;;;
    (dolist (face '(tab-bar tab-bar-tab tab-bar-tab-inactive))
      (set-face-bold face t))
    (if (eq my/modus-themes/ui-style 'minimal)
        (progn
          (pcase-dolist
              (`(,face ,box ,fg ,ol ,ul)
               `((vertical-border      nil       ,fg-vertical-border  nil          nil)
                 (window-divider       nil       ,fg-vertical-border  nil          nil)
                 (mode-line            nil               unspecified  ,bg-inactive nil)
                 (mode-line-active     nil               ,fg-active   ,bg-inactive nil)
                 (mode-line-inactive   nil               ,fg-inactive ,bg-dim      nil)
                 (tab-bar              ,box-minimal      unspecified  nil          ,underline-minimal)
                 (tab-bar-tab          ,box-minimal      ,fg-active   nil          ,underline-minimal)
                 (tab-bar-tab-inactive ,box-minimal      ,fg-inactive nil          ,underline-minimal)
                 (header-line          ,box-minimal-thin unspecified  nil          ,underline-minimal-thin)
                 (header-line-inactive ,box-minimal-thin ,fg-inactive nil          ,underline-minimal-thin)))
            (set-face-attribute face nil
                                :box box
                                :foreground fg
                                :background 'unspecified
                                :overline ol
                                :underline ul))
          (pcase-dolist
              (`(,face ,box ,ol ,ul)
               `((mode-line-highlight   nil                         ,bg-inactive nil)
                 (tab-bar-tab-highlight ,box-minimal-highlight      nil          ,underline-minimal)
                 (header-line-highlight ,box-minimal-highlight-thin nil          ,underline-minimal-thin)))
            (set-face-attribute face nil
                                :box box
                                :overline ol
                                :underline ul))
          (set-face-attribute 'modus-themes-button nil
                              :overline nil
                              :underline nil))
      (let* ((width (if is-3d 2 1))
             (button-style (when is-3d '(:style released-button)))
             (box-active
              `(:line-width ,width
                :color ,(my/theme-color (if is-3d 'bg-mode-line-active 'border-mode-line-active))
                ,@button-style))
             (box-inactive
              `(:line-width ,width
                :color ,(my/theme-color (if is-3d 'bg-mode-line-inactive 'border-mode-line-inactive))
                ,@button-style)))
        (pcase-dolist
            (`(,face ,box ,bg)
             `((tab-bar              nil           ,bg-main)
               (mode-line            ,box-active   ,bg-active)
               (mode-line-active     ,box-active   ,bg-active)
               (tab-bar-tab          ,box-active   ,bg-active)
               (modus-themes-button  ,box-active   ,bg-active)
               (header-line          ,box-inactive ,bg-inactive)
               (mode-line-inactive   ,box-inactive ,bg-inactive)
               (tab-bar-tab-inactive ,box-inactive ,bg-inactive)))
          (set-face-attribute face nil
                              :box box
                              :overline 'unspecified
                              :underline 'unspecified
                              :background bg))
        (dolist (face '(mode-line-highlight tab-bar-tab-highlight header-line-highlight))
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
                               (my/theme-color 'bg-mode-line-inactive)
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
(add-hook 'my/system-appearance-change-functions #'my/apply-theme)
;;;###autoload
(add-hook 'after-load-theme-hook #'my/modus-themes/set-ui-style)
;;;###autoload
(add-hook 'Custom-mode-hook #'my/customize-buttons-faces)

(provide 'my-modus-ui-styles)

;;; my-modus-ui-styles.el ends here
