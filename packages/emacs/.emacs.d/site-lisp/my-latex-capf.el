;;; my-latex-capf.el --- Complete LaTeX macros inside math markup  -*- lexical-binding: t; -*-
;;; Commentary:

;; Org and `markdown-ts-mode' let LaTeX be written between delimiters
;; like $...$ or \[...\], but neither offers completion for the macro
;; names typed in there: Org's `pcomplete/org-mode/tex' covers only
;; `org-entities' and reports a completion region that keeps the
;; backslash its candidates lack, and Markdown registers nothing at all.
;;
;; Both modes do fontify math with a face of their own, so that face is
;; what tells a macro apart from a stray backslash in prose.  Candidates
;; come from `math-symbol-lists', annotated with the character each
;; macro stands for.

;;; Code:

(require 'cape)
(require 'math-symbol-lists)
(require 'subr-x)

(defgroup my-latex-capf nil
  "LaTeX macro completion inside math markup."
  :group 'completion)

(defcustom my-latex-capf-faces
  '(font-latex-math-face tex-math org-latex-and-related markdown-ts-latex)
  "Faces marking the text that LaTeX macros are completed in."
  :type '(repeat face)
  :group 'my-latex-capf)

(defconst my/latex-capf-macros
  (let ((macros (make-hash-table :test #'equal)))
    ;; The extended list goes first so that the basic one, which spells the
    ;; shared macros with the plainer character, wins: \alpha is a greek
    ;; letter here, not a mathematical italic one.
    (dolist (symbol (append math-symbol-list-extended math-symbol-list-basic))
      (let ((character (and (nth 2 symbol) (decode-char 'ucs (nth 2 symbol)))))
        (puthash (nth 1 symbol)
                 (and character (char-to-string character))
                 macros)))
    ;; Macros that stand for no character at all, such as \frac.
    (dolist (command math-symbol-list-latex-commands)
      (let ((macro (concat "\\" command)))
        (unless (gethash macro macros)
          (puthash macro nil macros))))
    macros)
  "Map of every known LaTeX macro to the character it stands for, if any.")

(defconst my/latex-capf-candidates
  (sort (hash-table-keys my/latex-capf-macros) #'string<)
  "The macros of `my/latex-capf-macros', as a completion table.")

(defun my/latex-capf-annotation (macro)
  "Return the character MACRO stands for, as an annotation."
  (when-let* ((character (gethash macro my/latex-capf-macros)))
    (concat " " character)))

(defun my/latex-capf-bounds ()
  "Return the bounds of the backslash-prefixed macro name before point."
  (save-excursion
    (let ((end (point)))
      (skip-chars-backward "a-zA-Z")
      (and (eq (char-before) ?\\) (cons (1- (point)) end)))))

(defun my/latex-capf-complete ()
  "Complete the LaTeX macro name before point, wherever point is."
  (when-let* ((bounds (my/latex-capf-bounds)))
    (list (car bounds) (cdr bounds) my/latex-capf-candidates
          :annotation-function #'my/latex-capf-annotation
          :company-kind (lambda (_) 'text)
          :exclusive 'no)))

;;;###autoload
(defun my-latex-capf ()
  "Complete LaTeX macro names while point is inside math markup.
Math is whatever the major mode fontifies with one of
`my-latex-capf-faces'.  Meant for `completion-at-point-functions'."
  (apply #'cape-wrap-inside-faces #'my/latex-capf-complete my-latex-capf-faces))

(provide 'my-latex-capf)
;;; my-latex-capf.el ends here
