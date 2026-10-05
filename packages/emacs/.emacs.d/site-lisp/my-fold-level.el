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
;; Neither do those front ends act on the folds containing a line, as Vim's `zA',
;; `zC' and `zv' do, so the module provides those too.  With `hs-allow-nesting'
;; every hideshow block keeps an overlay of its own, one per Vim fold; an outline
;; subtree is hidden as one region instead, so closing its outermost heading is
;; all that closing the folds along a line amounts to there.
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
(defvar hs-allow-nesting)
(defvar hs-block-start-regexp)
(defvar hs-block-start-mdata-select)
(declare-function hs-hide-block-at-point "hideshow" (&optional end comment-reg))
(declare-function hs-hide-block "hideshow" ())
(declare-function hs-show-all "hideshow" ())
(declare-function hs-discard-overlays "hideshow" (beg end))
(declare-function kirigami-open-folds "kirigami" ())
(declare-function kirigami-close-folds "kirigami" ())
(declare-function kirigami-open-fold "kirigami" ())
(declare-function kirigami-close-fold "kirigami" ())
(declare-function kirigami-toggle-fold "kirigami" ())

(defvar-local my/fold-level nil
  "Number of nesting levels left visible, the analogue of Vim's `foldlevel'.
1 leaves only the outermost constructs visible.  nil means the level has not
been set yet, in which case it is taken to be `my/fold-level--max-level', i.e.
nothing folded.")

(defvar-local my/fold-level--max nil
  "Cached result of `my/fold-level--max-level'.")

(defvar-local my/fold-level--tick nil
  "Value of `buffer-chars-modified-tick' when `my/fold-level--max' was computed.")

;;;; Backends

(defun my/fold-level--backend ()
  "Return the folding backend of the current buffer.
Either the symbol `outline' or `hideshow', or nil if neither is in use.
Outline wins when both are active: it is the more faithful of the two."
  (cond ((or (bound-and-true-p outline-minor-mode)
             (derived-mode-p 'outline-mode))
         'outline)
        ((bound-and-true-p hs-minor-mode)
         'hideshow)))

(defun my/fold-level--outline-max ()
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

(defun my/fold-level--hideshow-blocks ()
  "Return a (DEPTH . START) pair for each hideshow block outside comments.
DEPTH is the syntactic paren depth at the block's opening delimiter START,
which is what `hs-hide-level-recursive' descends through."
  (when (stringp hs-block-start-regexp)
    (save-excursion
      (goto-char (point-min))
      (let (blocks)
        (while (re-search-forward hs-block-start-regexp nil t)
          ;; `syntax-ppss' leaves point at the position it parsed up to, which
          ;; would send the search back over the delimiter it just matched.
          (let* ((start (match-beginning hs-block-start-mdata-select))
                 (state (save-excursion (syntax-ppss start))))
            ;; Same guard `hs-hide-level-recursive' applies.
            (unless (nth 8 state)
              (push (cons (1+ (car state)) start) blocks))))
        blocks))))

(defun my/fold-level--hideshow-max ()
  "Return the level at which no hideshow block is left folded.
Only blocks that `hs-hide-block-at-point' would really hide count, that is
those whose body spans more than one line, so that deep single-line nesting
adds no levels that fold nothing."
  (let ((deepest 0))
    (unless (bound-and-true-p hs-indentation-mode)
      (pcase-dolist (`(,level . ,start) (my/fold-level--hideshow-blocks))
        ;; Blocks that cannot raise the maximum are dismissed before the
        ;; costly `scan-lists'.
        (when (> level deepest)
          (let ((p (save-excursion (goto-char start) (line-end-position)))
                (q (ignore-errors (scan-lists start 1 0))))
            (when (and q (< p q) (> (count-lines p q) 1))
              (setq deepest level))))))
    (1+ deepest)))

(defun my/fold-level--hideshow-hide-blocks (blocks)
  "Fold each of BLOCKS, a list of (DEPTH . START) pairs, an overlay apiece.
Relies on `hs-allow-nesting', without which hideshow discards the overlays
of the blocks nested inside a folded one."
  (save-excursion
    ;; Deepest first: `hs-hide-block-at-point' deletes whichever overlay
    ;; covers the header of the block it folds, which for an outer block
    ;; would be the overlay of a child folded earlier.
    (dolist (block (sort blocks (lambda (a b) (> (car a) (car b)))))
      (goto-char (cdr block))
      (hs-hide-block-at-point))))

(defun my/fold-level--hideshow-hide (level)
  "Fold every hideshow block nested LEVEL levels deep or deeper.
`hs-hide-level' gives an overlay of its own only to the blocks at the depth
it is asked for, so opening one of them uncovers its whole subtree.  Folding
every level instead leaves each nested block an overlay of its own, which is
what makes opening a block uncover just the next level, as in Vim."
  (my/fold-level--hideshow-hide-blocks
   (seq-filter (lambda (block) (>= (car block) level))
               (my/fold-level--hideshow-blocks))))

(defun my/fold-level--max-level ()
  "Return the lowest level at which the buffer is fully unfolded.
The result is cached until the buffer text changes."
  (let ((tick (buffer-chars-modified-tick)))
    (unless (and my/fold-level--max (eql my/fold-level--tick tick))
      (setq my/fold-level--tick tick
            my/fold-level--max
            (pcase (my/fold-level--backend)
              ('outline (my/fold-level--outline-max))
              ('hideshow (my/fold-level--hideshow-max))
              (_ 1))))
    my/fold-level--max))

(defun my/fold-level--apply (level)
  "Leave LEVEL nesting levels visible and fold everything deeper."
  (pcase (my/fold-level--backend)
    ('outline
     (if (>= level (my/fold-level--max-level))
         (outline-show-all)
       (outline-hide-sublevels level)))
    ('hideshow
     ;; Hideshow leaves its overlays alone while `hs-allow-nesting' is on, so
     ;; the state left by the previous level has to be cleared before laying
     ;; down the new one.
     (hs-show-all)
     (unless (>= level (my/fold-level--max-level))
       (my/fold-level--hideshow-hide level)))))

;;;; Level stepping

(defun my/fold-level--reveal-point ()
  "Move point to the first visible line of the fold hiding it, as Vim does."
  (when (invisible-p (point))
    (goto-char (previous-single-char-property-change (point) 'invisible))
    (forward-line 0)))

(defun my/fold-level--fallback (command)
  "Call the `kirigami' COMMAND in a buffer that has no backend of ours."
  (unless (require 'kirigami nil t)
    (user-error "No folding backend is active in this buffer"))
  (funcall command))

(defun my/fold-level--set (level)
  "Set the fold level to LEVEL, clamped to the buffer's range, and report it."
  (let* ((max (my/fold-level--max-level))
         (level (max 1 (min level max))))
    (setq my/fold-level level)
    (my/fold-level--apply level)
    (my/fold-level--reveal-point)
    ;; Reported the way Vim counts it, where 0 means every fold is closed.
    (message "foldlevel=%d/%d" (1- level) (1- max))))

(defun my/fold-level--current ()
  "Return the current fold level, defaulting to a fully unfolded buffer."
  (or my/fold-level (my/fold-level--max-level)))

(defun my/fold-level--steppable-p ()
  "Return non-nil if the buffer has more than one fold level to step through.
A backend that cannot measure nesting reports a single level, which leaves
nothing for `zm' and `zr' to do; such buffers are folded whole instead."
  (and (my/fold-level--backend)
       (> (my/fold-level--max-level) 1)))

;;;###autoload
(defun my/fold-level-decrease (&optional count)
  "Fold one nesting level more, like Vim's `zm'.
With a numeric prefix COUNT, fold COUNT levels more."
  (interactive "p")
  (if (my/fold-level--steppable-p)
      (my/fold-level--set (- (my/fold-level--current) (or count 1)))
    (my/fold-level--fallback #'kirigami-close-folds)))

;;;###autoload
(defun my/fold-level-increase (&optional count)
  "Unfold one nesting level more, like Vim's `zr'.
With a numeric prefix COUNT, unfold COUNT levels more."
  (interactive "p")
  (if (my/fold-level--steppable-p)
      (my/fold-level--set (+ (my/fold-level--current) (or count 1)))
    (my/fold-level--fallback #'kirigami-open-folds)))

;;;###autoload
(defun my/fold-level-close-all ()
  "Close every fold in the buffer, like Vim's `zM'."
  (interactive)
  (if (my/fold-level--steppable-p)
      (my/fold-level--set 1)
    (my/fold-level--fallback #'kirigami-close-folds)))

;;;###autoload
(defun my/fold-level-open-all ()
  "Open every fold in the buffer, like Vim's `zR'."
  (interactive)
  (if (my/fold-level--steppable-p)
      (my/fold-level--set (my/fold-level--max-level))
    (my/fold-level--fallback #'kirigami-open-folds)))

;;;; Folds at point

(defun my/fold-level--hideshow-close (beg end)
  "Fold every hideshow block containing a line between BEG and END."
  (if (stringp hs-block-start-regexp)
      (my/fold-level--hideshow-hide-blocks
       (seq-filter (pcase-lambda (`(,_ . ,start))
                     (and (<= start end)
                          (when-let* ((block-end
                                       (ignore-errors (scan-lists start 1 0))))
                            (>= block-end beg))))
                   (my/fold-level--hideshow-blocks)))
    ;; Without the regexp `my/fold-level--hideshow-blocks' finds no block.
    (save-excursion (goto-char beg) (hs-hide-block))))

(defun my/fold-level--hideshow-line-overlays ()
  "Return the hideshow overlays hiding the current line or its end."
  (seq-filter (lambda (overlay) (overlay-get overlay 'hs))
              (seq-union (overlays-at (point)) (overlays-at (pos-eol)))))

(defun my/fold-level--hideshow-open-recursive ()
  "Unfold the outermost hideshow block hiding the line and all blocks in it."
  (when-let* ((outermost (car (sort (my/fold-level--hideshow-line-overlays)
                                    :key #'overlay-start))))
    ;; Without nesting `hs-discard-overlays' discards the nested overlays too.
    (let (hs-allow-nesting)
      (hs-discard-overlays (overlay-start outermost) (overlay-end outermost)))))

(defun my/fold-level--hideshow-reveal ()
  "Unfold just the hideshow blocks hiding the current line."
  (mapc #'delete-overlay (my/fold-level--hideshow-line-overlays)))

(defun my/fold-level--outline-up-heading ()
  "Move to the parent of the heading at point, returning nil if it has none."
  (let ((from (point)))
    (ignore-errors (outline-up-heading 1 t))
    (< (point) from)))

(defun my/fold-level--outline-close (beg end)
  "Fold every top-level outline subtree containing a line between BEG and END."
  (save-excursion
    (goto-char beg)
    (condition-case nil
        (outline-back-to-heading t)
      (outline-before-first-heading (outline-next-heading)))
    (while (my/fold-level--outline-up-heading))
    (while (and (<= (point) end) (outline-on-heading-p t))
      (outline-hide-subtree)
      (outline-end-of-subtree)
      (outline-next-heading))))

(defun my/fold-level--outline-reveal ()
  "Unfold just the outline headings hiding the current line."
  (save-excursion
    (outline-back-to-heading t)
    (when (invisible-p (pos-eol))
      (outline-show-entry)
      (outline-show-children))
    (while (my/fold-level--outline-up-heading)
      (outline-show-children))))

(defun my/fold-level--open-recursive ()
  "Open the outermost fold hiding the current line and every fold in it."
  (pcase (my/fold-level--backend)
    ('outline (save-excursion (outline-back-to-heading t)
                              (outline-show-subtree)))
    ('hideshow (my/fold-level--hideshow-open-recursive))))

;;;###autoload
(defun my/fold-level-close-recursive (beg end)
  "Close every fold containing a line between BEG and END, like Vim's `zC'.
Interactively those are the lines of the active region, or else the current
line.  Folds that contain none of them are left as they are."
  (interactive (if (use-region-p)
                   (list (region-beginning) (1- (region-end)))
                 (list (point) (point))))
  (let ((beg (save-excursion (goto-char beg) (pos-bol)))
        (end (save-excursion (goto-char end) (pos-eol))))
    (pcase (my/fold-level--backend)
      ('outline (my/fold-level--outline-close beg end))
      ('hideshow (my/fold-level--hideshow-close beg end))
      (_ (my/fold-level--fallback #'kirigami-close-fold))))
  ;; Ends evil's Visual state as well.
  (deactivate-mark)
  (my/fold-level--reveal-point))

;;;###autoload
(defun my/fold-level-toggle-recursive ()
  "Open or close the folds containing the current line, like Vim's `zA'.
On a folded line open the outermost fold hiding it and every fold nested in
it, otherwise close every fold containing the line."
  (interactive)
  (cond ((not (my/fold-level--backend))
         (my/fold-level--fallback #'kirigami-toggle-fold))
        ((invisible-p (pos-eol)) (my/fold-level--open-recursive))
        (t (my/fold-level-close-recursive (point) (point)))))

;;;###autoload
(defun my/fold-level-reveal-line ()
  "Open just enough folds to show the current line, like Vim's `zv'."
  (interactive)
  (pcase (my/fold-level--backend)
    ('outline (my/fold-level--outline-reveal))
    ('hideshow (my/fold-level--hideshow-reveal))
    (_ (my/fold-level--fallback #'kirigami-open-fold))))

(provide 'my-fold-level)

;;; my-fold-level.el ends here
