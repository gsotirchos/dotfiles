;;; my-modeline.el --- Custom mode line configuration  -*- lexical-binding: t; -*-
;;; Commentary:

;;; Code:

;; Definition of Custom Variables
(defvar my/mode-line-major-modes
  (let ((recursive-edit-help-echo "Recursive edit, type C-M-c to get out"))
    (list (propertize "%[" 'help-echo recursive-edit-help-echo)
          `(:propertize ("" mode-name)
                        help-echo "Major mode\n\
mouse-1: Display major mode menu\n\
mouse-2: Show help for major mode\n\
mouse-3: Toggle minor modes"
                        mouse-face mode-line-highlight
                        local-map ,mode-line-major-mode-keymap)
          '("" mode-line-process)
          (propertize "%n" 'help-echo "mouse-2: Remove narrowing from buffer"
                      'mouse-face 'mode-line-highlight
                      'local-map (make-mode-line-mouse-map
                                  'mouse-2 #'mode-line-widen))
          (propertize "%]" 'help-echo recursive-edit-help-echo)
          " ")))
(put 'my/mode-line-major-modes 'risky-local-variable t)

(defvar my/mode-line-minor-modes
  (let ((recursive-edit-help-echo "Recursive edit, type C-M-c to get out"))
    (list (propertize "%[" 'help-echo recursive-edit-help-echo)
          "("
          `(:propertize ("" minor-mode-alist)
                        mouse-face mode-line-highlight
                        help-echo "Minor mode\n\
mouse-1: Display minor mode menu\n\
mouse-2: Show help for minor mode\n\
mouse-3: Toggle minor modes"
                        local-map ,mode-line-minor-mode-keymap)
          " )"
          (propertize "%]" 'help-echo recursive-edit-help-echo)
          " ")))
(put 'my/mode-line-minor-modes 'risky-local-variable t)

(defvar my/mode-line-spacer
  '(:propertize (" ") display (min-width (2.0))))

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
    mode-line-position
    ;; VC Mode with Conditional Spacer
    (:eval (when (and vc-mode (not (string-empty-p vc-mode)))
             (list '(vc-mode vc-mode) my/mode-line-spacer)))
    my/mode-line-major-modes
    ;; Spacer before misc info
    (:eval my/mode-line-spacer)
    (:eval (when (bound-and-true-p flymake-mode) flymake-mode-line-counters))
    mode-line-misc-info
    mode-line-end-spaces))

;; Save the original format to restore it if we disable the mode
(defvar my/original-mode-line-format nil)

;;;###autoload
(define-minor-mode my-modeline-mode
  "Toggle my custom mode line."
  :global t
  :group 'mode-line
  (if my-modeline-mode
      (progn
        ;; Enable: Save old format and set new one
        (setq my/original-mode-line-format (default-value 'mode-line-format))
        (setq-default mode-line-format my/mode-line-format))
    ;; Disable: Restore old format
    (when my/original-mode-line-format
      (setq-default mode-line-format my/original-mode-line-format))))

(provide 'my-modeline)
;;; my-modeline.el ends here
