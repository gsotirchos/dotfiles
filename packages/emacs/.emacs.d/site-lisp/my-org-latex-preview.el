;;; my-org-latex-preview.el --- Sizing and placement of Org LaTeX previews  -*- lexical-binding: t; -*-

;;; Commentary:

;; Org renders each LaTeX fragment to an image whose box comes from preview.sty.
;; Three things about that box do not match how the fragment reads on screen:
;;
;; - A display fragment arrives padded out to `:page-width', because Org ends it
;;   with a blank line and because maths is centred on the line it occupies.  The
;;   fragment is rewritten to bring the box back to the ink, as described in
;;   `my/org-latex-preview-natural-width-advice'.  Inline fragments keep the full
;;   width, which is what stops them from wrapping mid-formula, so this cannot be
;;   done from the preamble.
;;
;; - That image is then placed at the left margin, where display maths belongs in
;;   the middle of the window.  A `line-prefix' aligns it to the window centre,
;;   and is dropped while the overlay shows its LaTeX source instead.
;;
;; - Fragments coloured like their predecessor are typeset without any colour of
;;   their own, which dvisvgm renders black rather than in `currentColor'.
;;
;; `my/org-latex-preview-setup' installs all of it and extends
;; `org-latex-preview-preamble'.  Note that `org-latex-preview--hash' covers the
;; preamble and the raw fragment but not the rewriting done here, so the preamble
;; carries a marker that expires previews cached before a change to it.

;;; Code:

(defvar org-latex-preview-appearance-options)
(defvar org-latex-preview-preamble)

(defconst my/org-latex-preview--preamble-marker
  "% fragment rewriting: natural-width displays v2"
  "Preamble comment standing in for the fragment rewriting done here.
`org-latex-preview--hash' covers the preamble and the raw fragment, so
bumping the version is what expires previews cached before a change to
`my/org-latex-preview-natural-width-advice'.  It doubles as the guard
that keeps `my/org-latex-preview-setup' from extending the preamble twice.")

(defconst my/org-latex-preview-natural-width-environments
  '("align" "alignat" "flalign" "xalignat" "xxalignat")
  "Environments that hug their ink once \\hsize is zeroed.
These abandon centring and left-align their box when it does not fit
`\\displaywidth', which zeroing \\hsize guarantees.  Every other display
stays centred in a box that wide, and so would collapse onto its own
centre rather than hug anything.")

(defun my/org-latex-preview-display-fragment-p (string)
  "Return non-nil when STRING opens a display fragment rather than an inline one."
  (string-match-p "\\`[ \t\n]*\\(?:\\\\\\[\\|\\\\begin{\\|\\$\\$\\)" string))

(defun my/org-latex-preview-natural-width-environment-p (string)
  "Return non-nil when STRING opens a natural-width environment.
See `my/org-latex-preview-natural-width-environments'."
  (string-match-p
   (concat "\\`[ \t\n]*\\\\begin{"
           (regexp-opt my/org-latex-preview-natural-width-environments)
           "\\*?}")
   string))

(defun my/org-latex-preview-block-overlay-p (overlay)
  "Return non-nil when OVERLAY covers a display fragment."
  (my/org-latex-preview-display-fragment-p
   (buffer-substring-no-properties
    (overlay-start overlay)
    (min (overlay-end overlay) (+ (overlay-start overlay) 10)))))

(defun my/org-latex-preview-natural-width-advice (args)
  "Typeset display fragments at their natural width.
ARGS are `org-latex-preview--tex-styled''s arguments.  Previews come out
padded to `:page-width' for two reasons, each with its own remedy.

An environment's own trailing newline plus the one Org emits before
\\end{preview} leave the fragment in vertical mode, where preview.sty keeps
the paragraph line whole, and a line is \\hsize wide.  Dropping the trailing
newlines ends the fragment in horizontal mode instead, where preview.sty
repacks that line into a box holding just its contents.

That is all a self-boxing fragment needs, a tikzpicture included, but not
maths, which TeX centres in a box of width \\hsize.  Only the environments
in `my/org-latex-preview-natural-width-environments' escape that box, and
only with \\hsize zeroed; the rest keep the width they centre in."
  (pcase-let ((`(,processing-type ,value ,appearance-options) args))
    (list processing-type
          (if (my/org-latex-preview-display-fragment-p value)
              (concat (and (my/org-latex-preview-natural-width-environment-p value)
                           "\\setlength{\\hsize}{0pt}\\setlength{\\linewidth}{0pt}%\n")
                      (string-trim-right value))
            value)
          appearance-options)))

(defun my/org-latex-preview-color-every-fragment-advice (args)
  "Make `org-latex-preview--tex-styled' set the colors of every fragment.
ARGS are its arguments.  With :continue-color, it omits them for a fragment
colored like the previous one, but each fragment is typeset in its own
preview environment, so the color does not carry over and dvisvgm emits a
black image instead of one drawn in `currentColor'."
  (pcase-let ((`(,processing-type ,value ,appearance-options) args))
    (list processing-type value
          (plist-put (copy-sequence appearance-options) :continue-color nil))))

(defun my/org-latex-preview-center-block (overlay)
  "Center OVERLAY's preview image in the window, as display math is on the page.
Dropped while the overlay shows its LaTeX source, which should stay where the
surrounding text is."
  (overlay-put
   overlay 'line-prefix
   (and (not (overlay-get overlay 'org-view-text))
        (my/org-latex-preview-block-overlay-p overlay)
        (when-let* ((image (overlay-get overlay 'org-preview-image)))
          (propertize " " 'display
                      `(space :align-to (- center (0.5 . ,image))))))))

(defun my/org-latex-preview--preamble-additions ()
  "Return the preamble text the previews here are compiled with."
  (concat
   ;; TODO: Drop this mirror of :page-width once Org's own copy survives
   ;; precompilation.  Org emits it after the %& line, by which point the
   ;; dumped format has fixed \linewidth at \begin{document}.
   (format "\n\\setlength{\\textwidth}{%s\\paperwidth}"
           (plist-get org-latex-preview-appearance-options :page-width))
   "\n" my/org-latex-preview--preamble-marker
   ;; Glyphs whose outline overshoots their TeX box metrics get clipped by the
   ;; SVG viewport dvisvgm derives from preview.sty, so the box needs padding.
   ;; \PreviewBorder pads all four sides alike, which spends on every fragment
   ;; what only a few need; measured over a spread of fragments, the ink stays
   ;; inside the box horizontally (worst case 0.03pt) and below it (0.22pt),
   ;; and only overshoots upwards, by 1.62pt for arrows.  \PreviewBbAdjust
   ;; takes the sides separately, as (left bottom right top) offsets.
   ;; https://github.com/tecosaur/org-latex-preview-todos/issues/14
   "\n\\AtBeginDocument{\\def\\PreviewBbAdjust{-0.3pt -0.5pt 0.3pt 2pt}}"))

;;;###autoload
(defun my/org-latex-preview-setup ()
  "Install the preview sizing, placement and coloring done here.
Org loads `org-latex-preview' more than once, so the preamble is only
extended when its marker is missing."
  ;; TODO: Report the :continue-color bug upstream, then drop this advice.
  (advice-add 'org-latex-preview--tex-styled :filter-args
              #'my/org-latex-preview-color-every-fragment-advice)
  (advice-add 'org-latex-preview--tex-styled :filter-args
              #'my/org-latex-preview-natural-width-advice)
  (dolist (hook '(org-latex-preview-overlay-update-functions
                  org-latex-preview-overlay-open-functions
                  org-latex-preview-overlay-close-functions))
    (add-hook hook #'my/org-latex-preview-center-block))
  (unless (string-search my/org-latex-preview--preamble-marker
                         org-latex-preview-preamble)
    (setq org-latex-preview-preamble
          (concat org-latex-preview-preamble
                  (my/org-latex-preview--preamble-additions)))))

(provide 'my-org-latex-preview)

;;; my-org-latex-preview.el ends here
