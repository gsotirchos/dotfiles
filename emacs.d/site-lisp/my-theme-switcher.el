;;; my-theme-switcher.el --- Theme switcher based on macOS appearance -*- lexical-binding: t -*-

;;; Commentary:
;; Defines a global minor mode `my-theme-switcher-mode` that polls
;; macOS system appearance every 5 seconds and runs the hook
;; `my-system-appearance-change-functions` when it changes.

;;; Code:

(defgroup my-theme-switcher nil
  "Configuration for the custom theme switcher."
  :group 'convenience)

(defcustom my/theme-poll-interval 5
  "Interval in seconds to check for system appearance changes."
  :type 'integer
  :group 'my-theme-switcher)

(defvar my-system-appearance-change-functions nil
  "Hook run when the system appearance changes.
Functions in this hook are called with one argument: the new appearance,
either 'light or 'dark.")

(defvar my/theme-poll-timer nil
  "Timer object for the theme poller.")

(defvar my/last-system-appearance nil
  "Tracks the last detected system appearance to avoid unnecessary reloads.")

(defun my/get-macos-appearance ()
  "Return 'dark if macOS is in Dark Mode, 'light otherwise."
  (if (string-equal "Dark\n"
                    (shell-command-to-string "defaults read -g AppleInterfaceStyle"))
      'dark
    'light))

(defun my/check-system-appearance ()
  "Check macOS appearance and run hooks if changed."
  (let ((current-appearance (my/get-macos-appearance)))
    (unless (eq current-appearance my/last-system-appearance)
      (setq my/last-system-appearance current-appearance)
      ;; Run the hook with the appearance argument
      (run-hook-with-args 'my-system-appearance-change-functions current-appearance)
      ;; (message "System appearance changed to %s" current-appearance)
      )))

;;;###autoload
(define-minor-mode my-theme-switcher-mode
  "Global minor mode to poll macOS system appearance and switch themes."
  :global t
  :group 'my-theme-switcher
  (if my-theme-switcher-mode
      (progn
        ;; Enable
        (when my/theme-poll-timer (cancel-timer my/theme-poll-timer))
        ;; Check immediately so correct theme applies on startup
        (my/check-system-appearance)
        ;; Start polling
        (setq my/theme-poll-timer
              (run-at-time my/theme-poll-interval my/theme-poll-interval #'my/check-system-appearance))
        ;; (message "Theme switcher enabled")
        )
    ;; Disable
    (when my/theme-poll-timer
      (cancel-timer my/theme-poll-timer)
      (setq my/theme-poll-timer nil))
    ;; (message "Theme switcher disabled")
    ))

(provide 'my-theme-switcher)

;;; my-theme-switcher.el ends here
