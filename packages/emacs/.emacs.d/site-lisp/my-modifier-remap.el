;;; my-modifier-remap.el --- Remap whole keyboard modifiers  -*- lexical-binding: t; -*-

;;; Commentary:

;; Translate one keyboard modifier into another, e.g. make the Super
;; modifier behave as Meta (like `ns-command-modifier' on macOS or
;; `x-super-keysym' on X11).  Handy on pgtk/Wayland builds where the
;; `x-*-keysym' variables are ignored.
;;
;; It works by populating `key-translation-map', so it does NOT fight
;; window-manager grabs: GNOME/mutter claims its own `<Super>' shortcuts
;; before Emacs ever sees the event, and only the chords that fall
;; through to Emacs get remapped.
;;
;; Declare mappings via `my-modifier-remap-alist' (one TO per FROM), then
;; enable `my-modifier-remap-mode'.  Example:
;;
;;   (setq my-modifier-remap-alist '((super . meta)))   ;; Super acts as Meta
;;   (my-modifier-remap-mode 1)

;;; Code:

(defgroup my-modifier-remap nil
  "Translate one keyboard modifier into another."
  :group 'keyboard)

(defconst my-modifier-remap--prefixes
  '((alt . "A-") (control . "C-") (hyper . "H-")
    (meta . "M-") (shift . "S-") (super . "s-"))
  "Alist mapping modifier symbols to `kbd' prefixes, in canonical order.")

(defcustom my-modifier-remap-alist nil
  "Alist of (FROM . TO) modifier remappings.
Every key chord using the FROM modifier is translated to the same
chord with the TO modifier instead.  FROM and TO are symbols from
`my-modifier-remap--prefixes' (e.g. `super', `meta', `alt').  Use
at most one entry per FROM modifier."
  :type '(alist :key-type symbol :value-type symbol)
  :group 'my-modifier-remap)

(defcustom my-modifier-remap-co-modifiers '(control shift)
  "Modifiers that may accompany the remapped one.
All subsets are enumerated so that, for a `super' -> `meta' remap,
`C-s-x', `S-s-x' and `C-S-s-x' are translated as well as `s-x'."
  :type '(repeat symbol)
  :group 'my-modifier-remap)

(defcustom my-modifier-remap-keys
  (append (mapcar #'char-to-string (number-sequence ?a ?z))
          (mapcar #'char-to-string (number-sequence ?0 ?9))
          (mapcar #'char-to-string
                  '(?\[ ?\] ?\; ?\' ?\, ?. ?/ ?\\ ?- ?= ?`
                    ?! ?@ ?# ?$ ?% ?^ ?& ?* ?\( ?\)
                    ?: ?\" ?< ?> ?\? ?{ ?} ?| ?_ ?+ ?~))
          '("SPC" "RET" "TAB" "DEL" "<backspace>" "<tab>" "<return>"
            "<escape>" "<left>" "<right>" "<up>" "<down>"
            "<home>" "<end>" "<prior>" "<next>"))
  "Base keys onto which modifier remappings are applied."
  :type '(repeat string)
  :group 'my-modifier-remap)

(defun my-modifier-remap--prefix (mods)
  "Return the concatenated `kbd' prefix for MODS, a list of modifier symbols.
Prefixes are emitted in the canonical order of
`my-modifier-remap--prefixes' so `kbd' always sees a stable form."
  (mapconcat (lambda (cell) (if (memq (car cell) mods) (cdr cell) ""))
             my-modifier-remap--prefixes ""))

(defun my-modifier-remap--subsets (list)
  "Return every subset of LIST as a list of lists."
  (if (null list)
      '(())
    (let ((rest (my-modifier-remap--subsets (cdr list))))
      (append rest
              (mapcar (lambda (subset) (cons (car list) subset)) rest)))))

(defun my-modifier-remap--map (from to fn)
  "Call FN with the source and target `kbd' vectors for a FROM -> TO remap.
FN receives two arguments: the translated-from key vector and the
translated-to key vector, for each key and co-modifier subset."
  (let ((co (delq from (delq to (copy-sequence my-modifier-remap-co-modifiers)))))
    (dolist (subset (my-modifier-remap--subsets co))
      (dolist (key my-modifier-remap-keys)
        (condition-case nil
            (funcall fn
                     (kbd (concat (my-modifier-remap--prefix (cons from subset)) key))
                     (kbd (concat (my-modifier-remap--prefix (cons to subset)) key)))
          (error nil))))))

(defun my-modifier-remap-apply ()
  "Install all remappings in `my-modifier-remap-alist' into `key-translation-map'."
  (interactive)
  (dolist (pair my-modifier-remap-alist)
    (my-modifier-remap--map
     (car pair) (cdr pair)
     (lambda (source target) (define-key key-translation-map source target)))))

(defun my-modifier-remap-remove ()
  "Remove all remappings in `my-modifier-remap-alist' from `key-translation-map'."
  (interactive)
  (dolist (pair my-modifier-remap-alist)
    (my-modifier-remap--map
     (car pair) (cdr pair)
     (lambda (source _target) (define-key key-translation-map source nil)))))

;;;###autoload
(define-minor-mode my-modifier-remap-mode
  "Global minor mode remapping modifiers per `my-modifier-remap-alist'."
  :global t
  :group 'my-modifier-remap
  (if my-modifier-remap-mode
      (my-modifier-remap-apply)
    (my-modifier-remap-remove)))

(provide 'my-modifier-remap)

;;; my-modifier-remap.el ends here
