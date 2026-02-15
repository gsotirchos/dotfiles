;;; package --- early-init -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Hide modeline on startup
(setq mode-line-format nil)

;; Less aggressive garbage collection on startup
(setq gc-cons-threshold (* 1024 1024 100)) ;; 100 MB
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 1024 800))))

;; Make things a little quieter
(setq byte-compile-warnings '(not obsolete)
      warning-suppress-log-types '((comp) (bytecomp))
      native-comp-async-report-warnings-errors 'silent
      inhibit-startup-echo-area-message (user-login-name))

(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  ;; Make native compilation quieter and asynchronous
  (setq native-comp-async-report-warnings-errors nil)
  (setq native-comp-deferred-compilation-deny-list '())

  ;; Put *.eln files to the non-default directory `var/eln-cache/'
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
     (convert-standard-filename (expand-file-name "var/eln-cache/" user-emacs-directory)))))

;; Configure properties for my MacbookAir
(when (eq system-type 'darwin)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (setq-default mac-mouse-wheel-smooth-scroll t
                mouse-wheel-flip-direction t
                mouse-wheel-tilt-scroll t
                ns-command-modifier 'meta
                ns-option-modifier 'alt
                x-super-keysym 'alt)

  (let ((mm-width 286)
        (mm-height 179)
        (pixel-width 2560)
        (pixel-height 1600)
        (scale 2))
    (add-to-list 'display-mm-dimensions-alist `(t . (,mm-width . ,mm-height)))

    ;; x-display-pixel-width
    ;; x-display-pixel-height
    ;; ns-display-monitor-attributes-list
    ;; frame-geom-value-cons

    (eval-after-load "frame"
      `(dolist (fn-override
                `((display-pixel-width . (lambda () ,pixel-width))
                  (display-pixel-height . (lambda () ,pixel-height))
                  (display-monitor-attributes-list
                   . (lambda  (&optional display)
                       `(((geometry . (0 0 ,,pixel-width ,,pixel-height))
                          (workarea . (0 0 ,,pixel-width ,,pixel-height))
                          (mm-size . (,,mm-width ,,mm-height))
                          (frames . ,(frames-on-display-list display))
                          (scale-factor . ,,scale)
                          (name . "Built-in Retina Display")
                          (source . "User")))))))
         (advice-add (car fn-override) :override (cdr fn-override))))))

;; UI Tweaks
(unless (and (eq system-type 'darwin)
             (display-graphic-p))
  (menu-bar-mode -1))
(tool-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode 0)
(set-fill-column 79)
(global-visual-line-mode -1)
(xterm-mouse-mode 1)
(context-menu-mode 1)
(column-number-mode 1)
(pixel-scroll-precision-mode 1)
(setq frame-resize-pixelwise t
      ;; frame-inhibit-implied-resize t
      use-dialog-box nil)

  ;; Basic fonts
(when (eq system-type 'darwin)
  (set-face-attribute 'fixed-pitch nil :family "Menlo")  ;; :height 130
  (set-face-attribute 'variable-pitch nil :family "Lucida Grande"))  ;; :height 130
(when (eq system-type 'gnu/linux)
  (set-face-attribute 'fixed-pitch nil :family "Noto Sans Mono")  ;; :height 140
  (set-face-attribute 'variable-pitch nil :family "Sans"))  ;; :height 130
(defconst fixed-pitch-line-spacing 4)
(defconst variable-pitch-line-spacing 4)
(copy-face 'fixed-pitch 'default)

;; Initialize package sources and set up `use-package'
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                          ("org" . "https://orgmode.org/elpa/")
                          ("elpa" . "https://elpa.gnu.org/packages/")))

(unless (package-installed-p 'use-package)
  (package-initialize)
  (unless package-archive-contents
    (setq package-check-signature nil)
    (package-refresh-contents)
    (package-install 'gnu-elpa-keyring-update)
    (setq package-check-signature 'allow-unsigned)
    (package-refresh-contents))
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-always-defer t)

;; Set PATH
(setenv "PATH" "/Users/george/.dotfiles/bin/Users/george/.macos-dotfiles/bin:/Users/george/.bin::/Users/george/.local/bin:/home/george/.bin:/home/george/.local/bin:/snap/bin:/opt/miniforge/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-which/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/gsed/libexec/gnubin:/opt/homebrew/opt/libtool/libexec/gnubin:/opt/homebrew/opt/make/libexec/gnubin:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pkg/sbin:/opt/pkg/bin:/opt/X11/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Applications/Ghostty.app/Contents/MacOS")
(setenv "LIBRARY_PATH" "/opt/homebrew/lib:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib:/usr/local/lib")
(setq-default exec-path (split-string (getenv "PATH") path-separator))

;;; early-init.el ends here

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
