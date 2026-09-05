;;; my-fold-level.el --- Vim-style incremental fold levels -*- lexical-binding: t; -*-

;;; Commentary:
;; Vim steps a buffer-local `foldlevel' with `zm' and `zr', so folding closes and
;; opens one nesting level at a time.  No Emacs folding front end offers this:
;; `evil' and `kirigami' provide only "fold this node" and "fold everything".
;;
;; The primitive is there for outline: `outline-hide-sublevels' takes a number of
;; nesting levels to leave visible and acts on the whole buffer, which is exactly
;; Vim's model.  Hideshow needs a pass of its own, `hs-hide-level' folding a single
;; depth and leaving the blocks nested inside it without an overlay of their own.
;; This module supplies the missing piece: a buffer-local counter over those two
;; backends, plus the four commands that step it.
;;
;; The hideshow pass measures nesting with `hs-block-start-regexp' and the paren
;; depth at each match, which suits sexp languages such as Emacs Lisp.  Emacs 31.1
;; leaves that regexp nil in tree-sitter modes, which find their blocks through the
;; parser instead, so hideshow cannot measure depth there at all.  Those languages
;; are folded through the outline pass instead, `outline-indent-minor-mode' giving
;; them an indentation outline to count.  A tree-sitter buffer set up with neither
;; reports a single level, and the commands below then fold it as a whole.
;;
;; Levels here are 1-based -- level 1 leaves only the outermost constructs
;; visible -- while the echo area reports Vim's 0-based `foldlevel'.
;;
;; Buffers driven by neither `outline-minor-mode' nor `hs-minor-mode'
;; (`treesit-fold', vdiff...) have no level notion to step, so `zM' and `zR' fall
;; back to `kirigami', which knows how to fold them.

;;; Code:

(require 'outline)

(defvar hs-minor-mode)
(defvar hs-block-start-regexp)
(defvar hs-block-start-mdata-select)
(declare-function hs-hide-block-at-point "hideshow" (&optional end comment-reg))
(declare-function hs-show-all "hideshow" ())
(declare-function kirigami-open-folds "kirigami" ())
(declare-function kirigami-close-folds "kirigami" ())

(defvar-local my-fold-level nil
  "Number of nesting levels left visible, the analogue of Vim's `foldlevel'.
1 leaves only the outermost constructs visible.  nil means the level has not
been set yet, in which case it is taken to be `my-fold-level--max-level', i.e.
nothing folded.")

(defvar-local my-fold-level--max nil
  "Cached result of `my-fold-level--max-level'.")

(defvar-local my-fold-level--tick nil
  "Value of `buffer-chars-modified-tick' when `my-fold-level--max' was computed.")

;;;; Backends

(defun my-fold-level--backend ()
  "Return the folding backend of the current buffer.
Either the symbol `outline' or `hideshow', or nil if neither is in use.
Outline wins when both are active: it is the more faithful of the two."
  (cond ((or (bound-and-true-p outline-minor-mode)
             (derived-mode-p 'outline-mode))
         'outline)
        ((bound-and-true-p hs-minor-mode)
         'hideshow)))

(defun my-fold-level--outline-max ()
  "Return the level at which no outline heading is left folded.
That is the deepest heading level, plus one if any heading has a body:
`outline-hide-sublevels' hides every body, so where bodies exist one further
level is needed before nothing at all is hidden.  Indentation outlines have no
bodies, every non-blank line being a heading of its own, and so stop one level
earlier."
  (save-excursion
    (goto-char (point-min))
    (let ((deepest 0) (body nil))
      (while (outline-next-heading)
        (setq deepest (max deepest (funcall outline-level)))
        (unless body
          (let ((from (save-excursion (outline-end-of-heading) (point)))
                (to (save-excursion
                      (if (outline-next-heading) (point) (point-max)))))
            (setq body (and (< from to)
                            (string-match-p
                             "[^ \t\n]"
                             (buffer-substring-no-properties from to)))))))
      (max 1 (+ deepest (if body 1 0))))))

(defun my-fold-level--hideshow-max ()
  "Return the level at which no hideshow block is left folded.
A block's nesting level is the syntactic paren depth at its opening delimiter,
which is what `hs-hide-level-recursive' descends through.  Only blocks that
`hs-hide-block-at-point' would really hide count, that is those whose body spans
more than one line, so that deep single-line nesting adds no levels that fold
nothing."
  (save-excursion
    (goto-char (point-min))
    (let ((deepest 0))
      (while (and (stringp hs-block-start-regexp)
                  (not (bound-and-true-p hs-indentation-mode))
                  (re-search-forward hs-block-start-regexp nil t))
        ;; `syntax-ppss' leaves point at the position it parsed up to, which
        ;; would send the search back over the delimiter it just matched.
        (let* ((start (match-beginning hs-block-start-mdata-select))
               (state (save-excursion (syntax-ppss start)))
               (level (1+ (car state))))
          ;; Same guard `hs-hide-level-recursive' applies.  Blocks that cannot
          ;; raise the maximum are dismissed before the costly `scan-lists'.
          (unless (or (nth 8 state) (<= level deepest))
            (let ((p (line-end-position))
                  (q (ignore-errors (scan-lists start 1 0))))
              (when (and q (< p q) (> (count-lines p q) 1))
                (setq deepest level))))))
      (1+ deepest))))

(defun my-fold-level--hideshow-hide (level)
  "Fold every hideshow block nested LEVEL levels deep or deeper.
`hs-hide-level' gives an overlay of its own only to the blocks at the depth
it is asked for, so opening one of them uncovers its whole subtree.  Folding
every level instead leaves each nested block an overlay of its own, which is
what makes opening a block uncover just the next level, as in Vim.  Relies on
`hs-allow-nesting', without which hideshow discards the nested overlays."
  (save-excursion
    (goto-char (point-min))
    (let (blocks)
      ;; Same traversal as `my-fold-level--hideshow-max'.
      (while (and (stringp hs-block-start-regexp)
                  (re-search-forward hs-block-start-regexp nil t))
        (let* ((start (match-beginning hs-block-start-mdata-select))
               (state (save-excursion (syntax-ppss start)))
               (depth (1+ (car state))))
          (unless (or (nth 8 state) (< depth level))
            (push (cons depth start) blocks))))
      ;; Deepest first: `hs-hide-block-at-point' deletes whichever overlay
      ;; covers the header of the block it folds, which for an outer block
      ;; would be the overlay of a child folded earlier.
      (dolist (block (sort blocks (lambda (a b) (> (car a) (car b)))))
        (goto-char (cdr block))
        (hs-hide-block-at-point)))))


(defun my-fold-level--max-level ()
  "Return the lowest level at which the buffer is fully unfolded.
The result is cached until the buffer text changes."
  (let ((tick (buffer-chars-modified-tick)))
    (unless (and my-fold-level--max (eql my-fold-level--tick tick))
      (setq my-fold-level--tick tick
            my-fold-level--max
            (pcase (my-fold-level--backend)
              ('outline (my-fold-level--outline-max))
              ('hideshow (my-fold-level--hideshow-max))
              (_ 1))))
    my-fold-level--max))

(defun my-fold-level--apply (level)
  "Leave LEVEL nesting levels visible and fold everything deeper."
  (pcase (my-fold-level--backend)
    ('outline
     (if (>= level (my-fold-level--max-level))
         (outline-show-all)
       (outline-hide-sublevels level)))
    ('hideshow
     ;; Hideshow leaves its overlays alone while `hs-allow-nesting' is on, so
     ;; the state left by the previous level has to be cleared before laying
     ;; down the new one.
     (hs-show-all)
     (unless (>= level (my-fold-level--max-level))
       (my-fold-level--hideshow-hide level)))))

;;;; Level stepping

(defun my-fold-level--reveal-point ()
  "Move point to the first visible line of the fold hiding it, as Vim does."
  (when (invisible-p (point))
    (goto-char (previous-single-char-property-change (point) 'invisible))
    (forward-line 0)))

(defun my-fold-level--fallback (action)
  "Fold the buffer with `kirigami'.  ACTION is either `open' or `close'."
  (unless (require 'kirigami nil t)
    (user-error "No folding backend is active in this buffer"))
  (if (eq action 'open) (kirigami-open-folds) (kirigami-close-folds)))

(defun my-fold-level--set (level)
  "Set the fold level to LEVEL, clamped to the buffer's range, and report it."
  (let* ((max (my-fold-level--max-level))
         (level (max 1 (min level max))))
    (setq my-fold-level level)
    (my-fold-level--apply level)
    (my-fold-level--reveal-point)
    ;; Reported the way Vim counts it, where 0 means every fold is closed.
    (message "foldlevel=%d/%d" (1- level) (1- max))))

(defun my-fold-level--current ()
  "Return the current fold level, defaulting to a fully unfolded buffer."
  (or my-fold-level (my-fold-level--max-level)))

(defun my-fold-level--steppable-p ()
  "Return non-nil if the buffer has more than one fold level to step through.
A backend that cannot measure nesting reports a single level, which leaves
nothing for `zm' and `zr' to do; such buffers are folded whole instead."
  (and (my-fold-level--backend)
       (> (my-fold-level--max-level) 1)))

;;;###autoload
(defun my-fold-level-decrease (&optional count)
  "Fold one nesting level more, like Vim's `zm'.
With a numeric prefix COUNT, fold COUNT levels more."
  (interactive "p")
  (if (my-fold-level--steppable-p)
      (my-fold-level--set (- (my-fold-level--current) (or count 1)))
    (my-fold-level--fallback 'close)))

;;;###autoload
(defun my-fold-level-increase (&optional count)
  "Unfold one nesting level more, like Vim's `zr'.
With a numeric prefix COUNT, unfold COUNT levels more."
  (interactive "p")
  (if (my-fold-level--steppable-p)
      (my-fold-level--set (+ (my-fold-level--current) (or count 1)))
    (my-fold-level--fallback 'open)))

;;;###autoload
(defun my-fold-level-close-all ()
  "Close every fold in the buffer, like Vim's `zM'."
  (interactive)
  (if (my-fold-level--steppable-p)
      (my-fold-level--set 1)
    (my-fold-level--fallback 'close)))

;;;###autoload
(defun my-fold-level-open-all ()
  "Open every fold in the buffer, like Vim's `zR'."
  (interactive)
  (if (my-fold-level--steppable-p)
      (my-fold-level--set (my-fold-level--max-level))
    (my-fold-level--fallback 'open)))

(provide 'my-fold-level)

;;; my-fold-level.el ends here
