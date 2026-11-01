;;; my-theme-color.el --- Look up colors in the active theme's palette  -*- lexical-binding: t; -*-

;;; Commentary:
;; `my/theme-color' resolves a palette name such as `fg-dim' to a color string.

;;; Code:

(declare-function modus-themes-get-color-value "modus-themes")

(defun my/theme-color (name)
  "Return the color NAME resolves to in the active theme's palette, or nil.
Returns nil rather than `unspecified', so callers can guard with `when-let*'."
  (and (fboundp 'modus-themes-get-color-value)
       ;; Non-nil OVERRIDES, so `modus-themes-common-palette-overrides' and
       ;; `modus-vivendi-palette-overrides' are honoured everywhere.
       (let ((value (modus-themes-get-color-value name t)))
         (and (stringp value) value))))

(provide 'my-theme-color)
;;; my-theme-color.el ends here
