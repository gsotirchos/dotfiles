(setenv "PATH" "/Users/george/.bin:/Users/george/.dotfiles/bin:/Users/george/.macos-dotfiles/bin:/Users/george/.local/bin:/snap/bin:/opt/miniforge/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/opt/findutils/libexec/gnubin:/opt/homebrew/opt/gnu-sed/libexec/gnubin:/opt/homebrew/opt/gnu-tar/libexec/gnubin:/opt/homebrew/opt/gnu-which/libexec/gnubin:/opt/homebrew/opt/grep/libexec/gnubin:/opt/homebrew/opt/gsed/libexec/gnubin:/opt/homebrew/opt/libtool/libexec/gnubin:/opt/homebrew/opt/make/libexec/gnubin:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/opt/pkg/sbin:/opt/pkg/bin:/opt/X11/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Applications/Ghostty.app/Contents/MacOS")
(setenv "LIBRARY_PATH" "/opt/homebrew/lib:/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/lib:/usr/local/lib")
(setq exec-path (split-string (getenv "PATH") path-separator))

(when (eq system-type 'darwin)
  (add-to-list 'display-mm-dimensions-alist '(t . (286 . 179)))

  (defun my/display-pixel-width () 2560)
  (defun my/display-pixel-height () 1600)
  (defun my/display-monitor-attributes-list (&optional display)
    '(((geometry . (0 0 2560 1600))
       (workarea . (0 0 2560 1600))
       (mm-size . (286 179))
       (frames . (frames-on-display-list display))
       (scale-factor . 2)
       (name . "Built-in Retina Display")
       (source . "George"))))

  ;; x-display-pixel-width
  ;; x-display-pixel-height
  ;; ns-display-monitor-attributes-list
  ;; frame-geom-value-cons

  (eval-after-load "frame"
    '(dolist (fn-override
              '((display-pixel-width . my/display-pixel-width)
                (display-pixel-height . my/display-pixel-height)
                (display-monitor-attributes-list . my/display-monitor-attributes-list) ))
       (advice-add (car fn-override) :override (cdr fn-override)))))

(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "var/eln-cache/" user-emacs-directory))))
