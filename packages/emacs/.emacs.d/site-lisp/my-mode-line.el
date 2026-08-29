;;; my-mode-line.el --- Custom mode line configuration  -*- lexical-binding: t; -*-
;;; Commentary:

;; Emacs 31.1 dropped the `min-width' specs from the standard `mode-line-format',
;; which a proportional mode-line font (`modus-themes-variable-pitch-ui') needs to
;; keep fields from resizing.  This format is the standard one with those specs
;; restored and a slot added for `evil-mode-line-tag'.

;;; Code:


(defvar my/mode-line-spacer
  '(:propertize (" ") display (min-width (1.0))))
(put 'my/mode-line-spacer 'risky-local-variable t)

(defvar my/mode-line-format
  '("%e"
    mode-line-front-space
    (:propertize evil-mode-line-tag display (min-width (5.5)))
    (:propertize (""
                  mode-line-mule-info
                  mode-line-client
                  mode-line-modified
                  mode-line-remote
                  mode-line-window-dedicated)
                 display (min-width (5.0)))
    mode-line-frame-identification
    mode-line-buffer-identification
    my/mode-line-spacer
    (:propertize ("" mode-line-position) display (min-width (10.0)))
    ;; The inner list must start with "" so that its head is not read as the
    ;; condition of a nested (SYMBOL THEN) construct.
    (vc-mode ("" vc-mode my/mode-line-spacer))
    mode-line-modes
    my/mode-line-spacer
    mode-line-misc-info
    mode-line-end-spaces))

;;;###autoload
(defun my-mode-line-setup ()
  "Install `my/mode-line-format' as the default mode line.
Buffers that predate this call carry a buffer-local `mode-line-format':
`early-init.el' hides the mode line during startup, and `evil-mode' copies
whatever the format holds into every live buffer as it turns on.  Killing
those locals lets such buffers pick up the new default, while buffers
hiding their mode line via `mode-line-invisible-mode' are left alone."
  (setq-default mode-line-format my/mode-line-format)
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (unless (bound-and-true-p mode-line-invisible-mode)
        (kill-local-variable 'mode-line-format)))))

(provide 'my-mode-line)
;;; my-mode-line.el ends here
