# Indent bars vanish under `visual-wrap-prefix-mode`

> **TODO:** This report is to be incorporated into `docs/CONTRIBUTIONS.org` on
> the other machine; that file is a symlink to
> `/Users/george/Documents/org/emacs_upstream_contributions.org`, which does not
> exist here.

## Symptom

With `indent-bars-prefer-character` set to `t`, C/C++ buffers show the bars on
first display, but they disappear from most code lines as soon as the buffer is
refontified (an edit, an Eglot semantic-token update or `font-lock-flush`).
Comment lines and Python buffers keep their bars.

- Emacs 31.1 (snap, pgtk), indent-bars 1.0.1, `global-visual-wrap-prefix-mode`
- Observed in `c++-ts-mode`; any mode that replaces
  `adaptive-fill-first-line-regexp` is affected (cc-mode, and everything using
  `c-ts-common-comment-setup`: Rust, Go, Java, JS/TS, PHP, C#, mhtml).

## Mechanism

1. **indent-bars** puts its bar strings in an `indent-bars-display` text
   property and adds `(display indent-bars-display)` to
   `char-property-alias-alist`, so they act as `display` only where no real
   `display` property exists.
2. **visual-wrap** gives a whitespace-only line prefix a `min-width` display
   spec unless the prefix matches `adaptive-fill-first-line-regexp`
   (`visual-wrap--content-prefix` / `visual-wrap--apply-to-line`). The default
   regexp, `` \`[ \t]*\' ``, matches whitespace, but `c-ts-common` replaces it
   with `` \`\s-*[*|]\s-*\' ``, so C/C++ code lines take the `min-width` path.
3. `add-display-text-property` reads the existing value with
   `get-text-property`, which honours the alias, and writes the merged result
   as a real `display` property: `((min-width ((6 . width))) "·")`. This is
   valid and the bar still renders.
4. On refontification `visual-wrap--remove-properties` strips the `min-width`,
   leaving `("·")`, a list holding one display spec. Re-adding `min-width` then
   misclassifies `("·")` as a *single* spec, because its car is not a cons, and
   wraps it again: `((min-width ((6 . width))) ("·"))`. `("·")` is not a valid
   display spec, so nothing is drawn, and the real property keeps shadowing the
   alias from then on.

Stipple bars (`indent-bars-prefer-character` nil, graphical frames only) are
unaffected: they are drawn through `face`, not `display`. Confirmed with the
malformed property in place on the same lines.

## Reproduction

### Emacs only (the defect in step 4)

```sh
emacs -Q --batch --eval '(with-temp-buffer
  (insert "ab")
  (put-text-property 1 2 (quote display) "x")
  (add-display-text-property 1 2 (quote min-width) (quote ((2 . width))))
  (message "add:    %S" (get-text-property 1 (quote display)))
  (remove-display-text-property 1 2 (quote min-width))
  (message "remove: %S" (get-text-property 1 (quote display)))
  (add-display-text-property 1 2 (quote min-width) (quote ((2 . width))))
  (message "add:    %S" (get-text-property 1 (quote display))))'
```

```text
add:    ((min-width ((2 . width))) "x")
remove: ("x")
add:    ((min-width ((2 . width))) ("x"))
```

Adding and removing a spec should round-trip; the second `add` should yield
`((min-width ((2 . width))) "x")`.

### With indent-bars

In a graphical frame, a `c++-ts-mode` buffer with `visual-wrap-prefix-mode`
and `indent-bars-mode` (`indent-bars-prefer-character` t) and a few nested
blocks indented by whitespace: the bars show, then vanish from the code lines
after `M-: (jit-lock-refontify)`. The property at a bar column goes from
`((min-width ((6 . width))) "·")` to `((min-width ((6 . width))) ("·"))`.

## Upstream status (checked 2026-10-12)

- **Emacs:** unfixed on `master`; `add-remove--display-text-property` in
  `lisp/emacs-lisp/subr-x.el` still classifies with
  `(not (consp (car-safe disp)))`. No matching report on bug-gnu-emacs.
  Related but distinct: bug#81039 (visual-wrap `min-width` for invisible prefix
  characters) and bug#76018 (proliferating `wrap-prefix` properties).
- **indent-bars:** no matching issue; open issues are #89 and #134, both
  unrelated. Closed #38 and #73 touch `visual-wrap` for other reasons.

## Proposed upstream changes

- **Emacs (bug report, ideally with a patch):** treat `disp` as a single spec
  only when it is not a cons, its car is a symbol, or it is a `(margin ...)`
  form; a list whose car is a string, like `("x")`, is a list of specs:

  ```elisp
  ((or (not (consp disp))
       (symbolp (car disp))
       ;; If disp looks like ((margin ...) ...), that's
       ;; still a single display specification.
       (eq (car-safe (car disp)) 'margin))
   (setq type 'scalar)
   (list disp))
  ```

  Include the batch reproduction above, with a regression test in
  `test/lisp/emacs-lisp/subr-x-tests.el`.
- **indent-bars (issue, optional):** because `get-text-property` honours
  `char-property-alias-alist`, any `add-display-text-property` caller (here
  visual-wrap) freezes the aliased bar into a real `display` property, which
  indent-bars no longer controls. Worth mentioning once the Emacs bug has a
  number; not verified to cause visible problems on its own.

## Local workaround

`patch/indent-bars-fill-whitespace-prefix` in the `indent-bars` block of
`packages/emacs/.emacs.d/init.el` makes `adaptive-fill-first-line-regexp` also
accept whitespace-only prefixes wherever `indent-bars-mode` is on, so
visual-wrap uses a string prefix and adds no `min-width`. Prefixes containing
fill characters (`-`, `*`, `|`, ...) still take the `min-width` path. Remove
the workaround once the Emacs fix is released.
