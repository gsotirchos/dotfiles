;;; my-org-latex-preview.el --- Sizing and placement of Org LaTeX previews  -*- lexical-binding: t; -*-

;;; Commentary:

;; Org renders each LaTeX fragment to an image whose box comes from preview.sty.
;; Three things about that box do not match how the fragment reads on screen:
;;
;; - A display environment is typeset at the full line width with the equation
;;   centred inside it, and preview.sty records that box rather than the ink, so
;;   the image arrives padded out to `:page-width'.  The fragment is rewritten to
;;   zero that width, leaving an overfull box that hugs the maths.  Inline
;;   fragments keep the full width, which is what stops them from wrapping
;;   mid-formula, so this cannot be done from the preamble.
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
  "% fragment rewriting: natural-width displays v1"
  "Preamble comment standing in for the fragment rewriting done here.
`org-latex-preview--hash' covers the preamble and the raw fragment, so
bumping the version is what expires previews cached before a change to
`my/org-latex-preview-natural-width-advice'.  It doubles as the guard
that keeps `my/org-latex-preview-setup' from extending the preamble twice.")

(defun my/org-latex-preview-display-fragment-p (string)
  "Return non-nil when STRING opens a display fragment rather than an inline one."
  (string-match-p "\\`[ \t\n]*\\(?:\\\\\\[\\|\\\\begin{\\|\\$\\$\\)" string))

(defun my/org-latex-preview-block-overlay-p (overlay)
  "Return non-nil when OVERLAY covers a display fragment."
  (my/org-latex-preview-display-fragment-p
   (buffer-substring-no-properties
    (overlay-start overlay)
    (min (overlay-end overlay) (+ (overlay-start overlay) 10)))))

(defun my/org-latex-preview-natural-width-advice (args)
  "Typeset display fragments at their natural width.
ARGS are `org-latex-preview--tex-styled''s arguments.  A display fills the
line and centres the equation in it, and preview.sty records that box rather
than the ink, so previews come out padded to `:page-width'.  Zeroing the
width inside the fragment's own preview environment leaves an overfull box
that hugs the maths."
  (pcase-let ((`(,processing-type ,value ,appearance-options) args))
    (list processing-type
          (if (my/org-latex-preview-display-fragment-p value)
              (concat "\\setlength{\\hsize}{0pt}\\setlength{\\linewidth}{0pt}%\n" value)
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
