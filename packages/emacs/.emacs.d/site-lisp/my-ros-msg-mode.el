;;; my-ros-msg-mode.el --- Minimal major mode for ROS interface files  -*- lexical-binding: t; -*-

;;; Commentary:
;; Provides syntax highlighting and basic formatting for ROS interface
;; definition files (*.msg, *.srv, *.action).

;;; Code:

;;;###autoload
(define-derived-mode my-ros-msg-mode prog-mode "ROS Msg"
  "Minimal major mode for ROS interface definition files."
  ;; Configure syntax table for # comments
  (modify-syntax-entry ?# "<" my-ros-msg-mode-syntax-table)
  (modify-syntax-entry ?\n ">" my-ros-msg-mode-syntax-table)
  (setq-local comment-start "# ")
  ;; Define font-lock rules
  (setq font-lock-defaults
        '((("^\\s-*\\([a-zA-Z0-9_/]+\\)\\(?:\\[[0-9]*\\]\\)?\\s-+\\([a-zA-Z0-9_]+\\)"
            (1 'font-lock-type-face)
            (2 'font-lock-variable-name-face))
           ("=\\s-*\\([^#\n]*[^# \t\n]\\)"
            (1 'font-lock-constant-face))))))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.\\(?:msg\\|srv\\|action\\)\\'" . my-ros-msg-mode))

(provide 'my-ros-msg-mode)

;;; my-ros-msg-mode.el ends here
