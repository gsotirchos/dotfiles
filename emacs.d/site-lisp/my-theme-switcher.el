;;; my-theme-switcher.el --- Theme switcher based on OS appearance -*- lexical-binding: t -*-

;;; Commentary:
;; Event-driven theme switcher.
;; Supports macOS (via Emacs' built-in ns-system-appearance-change-functions)
;; and GNOME (via D-Bus Settings portal) without expensive polling.

;;; Code:

(require 'dbus nil t)

(defgroup my-theme-switcher nil
  "Configuration for the custom theme switcher."
  :group 'convenience)

(defcustom my/theme-poll-interval 10
  "Interval in seconds to check for system appearance changes.
Used only if native OS events are unavailable."
  :type 'integer
  :group 'my-theme-switcher)

(defvar my-system-appearance-change-functions nil
  "Hook run when the system appearance changes.
Functions in this hook are called with one argument: the new appearance,
either 'light or 'dark.")

(defvar my/last-system-appearance nil
  "Tracks the last detected system appearance to avoid unnecessary reloads.")

(defvar my/theme-poll-timer nil
  "Timer object for the theme poller fallback.")

(defun my/get-macos-appearance ()
  "Return 'dark if macOS is in Dark Mode, 'light otherwise."
  (let ((default-directory "/"))
    (if (string-equal "Dark\n"
                      (ignore-errors (shell-command-to-string "defaults read -g AppleInterfaceStyle 2>/dev/null")))
        'dark
      'light)))

(defun my/get-gnome-appearance ()
  "Return 'dark if GNOME is in Dark Mode, 'light otherwise."
  (let ((default-directory "/"))
    (if (string-match-p "dark"
                        (ignore-errors (shell-command-to-string "gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")))
        'dark
      'light)))

(defun my/get-current-appearance ()
  "Determine appearance based on the current operating system."
  (cond
   ((eq system-type 'darwin)
    (my/get-macos-appearance))
   ((and (eq system-type 'gnu/linux)
         (executable-find "gsettings"))
    (my/get-gnome-appearance))
   (t
    'light)))

(defun my/check-system-appearance (&optional force)
  "Check system appearance and run hooks if changed.
If FORCE is non-nil, run hooks even if the appearance hasn't changed."
  (let ((current-appearance (my/get-current-appearance)))
    (when (or force (not (eq current-appearance my/last-system-appearance)))
      (setq my/last-system-appearance current-appearance)
      (run-hook-with-args 'my-system-appearance-change-functions current-appearance))))

(defun my/mac-ns-theme-handler (appearance)
  "Handler for native macOS appearance change."
  ;; The hook gives us 'dark or 'light
  (unless (eq appearance my/last-system-appearance)
    (setq my/last-system-appearance appearance)
    (run-hook-with-args 'my-system-appearance-change-functions appearance)))

(defun my/dbus-gnome-theme-handler (namespace key value)
  "Handler for D-Bus SettingChanged signals."
  (when (and (string-equal namespace "org.freedesktop.appearance")
             (string-equal key "color-scheme"))
    ;; 0 = Default, 1 = Prefer Dark, 2 = Prefer Light
    (let ((appearance (if (equal (car value) 1) 'dark 'light)))
      (unless (eq appearance my/last-system-appearance)
        (setq my/last-system-appearance appearance)
        (run-hook-with-args 'my-system-appearance-change-functions appearance)))))

(defvar my/dbus-theme-signal nil
  "D-Bus signal object for theme changes.")

;;;###autoload
(define-minor-mode my-theme-switcher-mode
  "Global minor mode to switch themes automatically based on OS events."
  :global t
  :group 'my-theme-switcher
  (if my-theme-switcher-mode
      (progn
        ;; Check immediately so correct theme applies on startup
        (my/check-system-appearance t)

        ;; Register event listeners or fallback to polling
        (cond
         ((and (eq system-type 'gnu/linux)
               (featurep 'dbus))
          ;; Linux with D-Bus
          (setq my/dbus-theme-signal
                (dbus-register-signal
                 :session
                 "org.freedesktop.portal.Desktop"
                 "/org/freedesktop/portal/desktop"
                 "org.freedesktop.portal.Settings"
                 "SettingChanged"
                 #'my/dbus-gnome-theme-handler)))
         ((and (eq system-type 'darwin)
               (boundp 'ns-system-appearance-change-functions))
          ;; macOS Emacs NS Port
          (add-hook 'ns-system-appearance-change-functions #'my/mac-ns-theme-handler))
         (t
          ;; Fallback to polling (e.g., terminal Emacs on macOS, or unrecognized OS)
          (setq my/theme-poll-timer
                (run-at-time my/theme-poll-interval my/theme-poll-interval #'my/check-system-appearance)))))
    ;; Disable
    (when (and (eq system-type 'darwin) (boundp 'ns-system-appearance-change-functions))
      (remove-hook 'ns-system-appearance-change-functions #'my/mac-ns-theme-handler))
    (when my/dbus-theme-signal
      (dbus-unregister-object my/dbus-theme-signal)
      (setq my/dbus-theme-signal nil))
    (when my/theme-poll-timer
      (cancel-timer my/theme-poll-timer)
      (setq my/theme-poll-timer nil))))

(provide 'my-theme-switcher)

;;; my-theme-switcher.el ends here
