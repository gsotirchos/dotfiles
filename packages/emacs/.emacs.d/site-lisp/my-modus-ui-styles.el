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
(defconst my/modus-themes/ui-face-parents
  '((mode-line-active                . mode-line)
    (mode-line-inactive              . mode-line)
    (header-line-inactive            . header-line)
    (header-line-highlight           . mode-line-highlight)
    (tab-bar-tab                     . tab-bar)
    (tab-bar-tab-inactive            . tab-bar-tab)
    (tab-bar-tab-group-current       . tab-bar-tab)
    (tab-bar-tab-group-inactive      . tab-bar-tab-inactive)
    (tab-bar-tab-ungrouped           . tab-bar-tab-inactive)
    (tab-line                        . tab-bar)
    (tab-line-active                 . tab-line)
    (tab-line-inactive               . tab-line)
    (tab-line-tab                    . tab-bar-tab)
    (tab-line-tab-current            . tab-bar-tab)
    (tab-line-tab-inactive           . tab-bar-tab-inactive)
    (tab-line-tab-inactive-alternate . tab-bar-tab-inactive)
    (tab-line-tab-group              . tab-bar-tab-group-inactive)
    (tab-line-highlight              . tab-bar-tab-highlight))
  "UI faces and the face each is drawn like.
Modus themes replace the inheritance that Emacs' own specs define
between these faces.")

;;;###autoload
(defun my/modus-themes/inherit-ui-faces ()
  "Draw each face in `my/modus-themes/ui-face-parents' like its parent.
Each face keeps only its own foreground.  Also let `tab-line-tab-special'
mark its tab by slant alone, so the tab stays bold."
  (pcase-dolist (`(,face . ,parent) my/modus-themes/ui-face-parents)
    (when (facep face)
      (set-face-attribute face nil
                          :inherit parent
                          :box 'unspecified
                          :background 'unspecified
                          :overline 'unspecified
                          :underline 'unspecified
                          :height 'unspecified
                          :weight 'unspecified)))
  (when (facep 'tab-line-tab-special)
    (set-face-attribute 'tab-line-tab-special nil :weight 'unspecified)))

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
    (my/modus-themes/inherit-ui-faces)
    (set-face-bold 'tab-bar t)
    (pcase-dolist
        (`(,face . ,attributes)
         (if (eq my/modus-themes/ui-style 'minimal)
             `((vertical-border       :foreground ,fg-vertical-border)
               (window-divider        :foreground ,fg-vertical-border)
               (mode-line             :box nil :foreground unspecified :background unspecified
                                      :overline ,bg-inactive :underline nil)
               (mode-line-active      :foreground ,fg-active)
               (mode-line-inactive    :foreground ,fg-inactive :overline ,bg-dim)
               (mode-line-highlight   :box nil :overline ,bg-inactive :underline nil)
               (tab-bar               :box ,box-minimal :foreground unspecified :background unspecified
                                      :overline nil :underline ,underline-minimal)
               (tab-bar-tab           :foreground ,fg-active)
               (tab-bar-tab-inactive  :foreground ,fg-inactive)
               (tab-bar-tab-highlight :box ,box-minimal-highlight :overline nil :underline ,underline-minimal)
               (header-line           :box ,box-minimal-thin :foreground unspecified :background unspecified
                                      :overline nil :underline ,underline-minimal-thin)
               (header-line-inactive  :foreground ,fg-inactive)
               (header-line-highlight :box ,box-minimal-highlight-thin :overline nil
                                      :underline ,underline-minimal-thin)
               (modus-themes-button   :overline nil :underline nil))
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
             `((tab-bar               :box nil :background ,bg-main :overline unspecified :underline unspecified)
               (mode-line             :box ,box-active :background ,bg-active
                                      :overline unspecified :underline unspecified)
               (mode-line-inactive    :box ,box-inactive :background ,bg-inactive)
               (mode-line-highlight   :box ,box-active :overline nil :underline nil)
               (tab-bar-tab           :box ,box-active :background ,bg-active)
               (tab-bar-tab-inactive  :box ,box-inactive :background ,bg-inactive)
               (tab-bar-tab-highlight :box ,box-active :overline nil :underline nil)
               (header-line           :box ,box-inactive :background ,bg-inactive
                                      :overline unspecified :underline unspecified)
               (modus-themes-button   :box ,box-active :background ,bg-active
                                      :overline unspecified :underline unspecified)))))
      (apply #'set-face-attribute face nil attributes))
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
;;;###autoload
(with-eval-after-load 'tab-line (my/modus-themes/inherit-ui-faces))

(provide 'my-modus-ui-styles)

;;; my-modus-ui-styles.el ends here
