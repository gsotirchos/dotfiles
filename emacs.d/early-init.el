;;; package --- early-init -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

;; Less aggressive garbage collection on startup
(setq gc-cons-threshold (* 100 1024 1024)) ;; 100 MB
(add-hook 'emacs-startup-hook (lambda () (setq gc-cons-threshold (* 2 1024 1024))))

(when (and (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  ;; Make native compilation quieter and asynchronous
  (setq native-comp-async-report-warnings-errors nil)
  (setq native-comp-deferred-compilation-deny-list '())

  ;; Put *.eln files to the non-default directory `var/eln-cache'
  (when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
     (convert-standard-filename (expand-file-name  "var/eln-cache/" user-emacs-directory)))))

;; Configure screen properties for my MacbookAir
(when (eq system-type 'darwin)
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
  (menu-bar-mode 0))
(tool-bar-mode 0)
(scroll-bar-mode 0)
(fringe-mode 0)
(set-fill-column 79)
(global-visual-line-mode 0)
(xterm-mouse-mode 1)
(column-number-mode 1)
(pixel-scroll-precision-mode 1)

;; Set PATH
(setenv "PATH" "/Users/george/.bin:/Users/george/.dotfiles/bin:/Users/george/.macos-dotfiles/bin:/Users/george/.local/bin:/snap/bin:/opt/miniforge/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-which/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/gsed/libexec/gnubin:/opt/homebrew/opt/libtool/libexec/gnubin:/opt/homebrew/opt/make/libexec/gnubin:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pkg/sbin:/opt/pkg/bin:/opt/X11/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Applications/Ghostty.app/Contents/MacOS")
(setenv "LIBRARY_PATH" "/opt/homebrew/lib:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib:/usr/local/lib")
(setq-default exec-path (split-string (getenv "PATH") path-separator))

;;; early-init.el ends here

;; Local Variables:
;; byte-compile-warnings: (not free-vars unresolved)
;; End:
