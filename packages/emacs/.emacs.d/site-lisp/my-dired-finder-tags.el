;;; my-dired-finder-tags.el --- Show macOS Finder tag colors in Dired -*- lexical-binding: t; -*-

;;; Commentary:
;; After each Dired listing is read, append a colored dot to every file line
;; per colored Finder tag of that file, like Finder's list view.
;;
;; Finder stores tags as "name\ncolor" strings in a binary plist in the
;; com.apple.metadata:_kMDItemUserTags extended attribute.  A tag without a
;; color has no "\ncolor" part, or has "\n0" when another tool wrote it;
;; Finder then still colors its built-in tags by name.  The attribute is read
;; with xattr(1), which works outside Spotlight-indexed volumes, unlike mdls(1).

;;; Code:

(require 'bindat)
(require 'cl-lib)
(require 'dired)
(require 'hex-util)

(defconst my/dired-finder-tags-builtin
  '(("Gray" . "#8e8e93") ("Green" . "#34c759") ("Purple" . "#af52de")
    ("Blue" . "#007aff") ("Yellow" . "#ffcc00") ("Red" . "#ff3b30")
    ("Orange" . "#ff9500"))
  "Finder's built-in tags and their colors, in color number order 1-7.")

(defun my/dired-finder-tags--int (data pos size)
  "Return the SIZE-byte big-endian unsigned integer at POS in DATA."
  (bindat-unpack (bindat-type uint (* 8 size)) data pos))

(defun my/dired-finder-tags--extent (data pos)
  "Return (START . LENGTH) of the contents of the object at POS in DATA."
  (let ((length (logand (aref data pos) #x0f)))
    (if (< length #x0f)
        (cons (1+ pos) length)
      (let ((size (ash 1 (logand (aref data (1+ pos)) #x0f))))
        (cons (+ pos 2 size) (my/dired-finder-tags--int data (+ pos 2) size))))))

(defun my/dired-finder-tags--plist-strings (data)
  "Return the strings of DATA, a binary plist holding an array of strings."
  ;; Format: https://opensource.apple.com/source/CF/CF-1153.18/CFBinaryPList.c
  (let-alist (bindat-unpack
              (bindat-type (_ fill 6) (offset-size u8) (ref-size u8)
                           (_ fill 8) (top uint 64) (table uint 64))
              data (- (length data) 32))
    (let* ((object (lambda (ref)
                     (my/dired-finder-tags--int
                      data (+ .table (* ref .offset-size)) .offset-size)))
           (array (my/dired-finder-tags--extent data (funcall object .top))))
      (cl-loop
       for i below (cdr array)
       collect (let* ((pos (funcall object (my/dired-finder-tags--int
                                            data (+ (car array) (* i .ref-size))
                                            .ref-size)))
                      (utf-16 (= (ash (aref data pos) -4) 6))
                      (string (my/dired-finder-tags--extent data pos)))
                 (decode-coding-string
                  (substring data (car string)
                             (+ (car string) (* (if utf-16 2 1) (cdr string))))
                  (if utf-16 'utf-16be 'utf-8)))))))

(defun my/dired-finder-tags--read (files)
  "Return the Finder tags of each of FILES, in order."
  (with-temp-buffer
    (let ((coding-system-for-read 'utf-8))
      (apply #'call-process "xattr" nil '(t nil) nil
             "-pvx" "com.apple.metadata:_kMDItemUserTags" files))
    (goto-char (point-min))
    (mapcar (lambda (file)
              (when (looking-at (concat (regexp-quote file) ": \n"
                                        "\\(\\(?:\\(?:[0-9A-F]\\{2\\} \\)+\n\\)+\\)"))
                (goto-char (match-end 0))
                (my/dired-finder-tags--plist-strings
                 (decode-hex-string
                  (replace-regexp-in-string "[ \n]" "" (match-string 1))))))
            files)))

(defun my/dired-finder-tags--dots (tags)
  "Return a dot per colored tag of the Finder TAGS, in its color."
  (mapconcat
   (lambda (tag)
     (pcase-let* ((`(,name ,number) (split-string tag "\n"))
                  (color (if (member number '(nil "0"))
                             (alist-get name my/dired-finder-tags-builtin
                                        nil nil #'equal)
                           (cdr (nth (1- (string-to-number number))
                                     my/dired-finder-tags-builtin)))))
       (if color (propertize "●" 'face (list :foreground color)) "")))
   tags))

(defun my/dired-finder-tags-show ()
  "Append each listed file's Finder tag colors to its line as dots.
The dots are a `display' string over the line's last character, so they
take the background of that character, e.g. from `stripes' or `hl-line'."
  (remove-overlays (point-min) (point-max) 'my/dired-finder-tags t)
  (unless (file-remote-p default-directory)
    (let (entries)
      (save-excursion
        (goto-char (point-min))
        (while (not (eobp))
          (when-let* ((file (dired-get-filename nil t)))
            (push (cons (line-end-position) file) entries))
          (forward-line)))
      (when entries
        (setq entries (nreverse entries))
        (cl-loop for (end . _) in entries
                 for tags in (my/dired-finder-tags--read (mapcar #'cdr entries))
                 for dots = (my/dired-finder-tags--dots tags)
                 unless (string-empty-p dots)
                 do (let ((overlay (make-overlay (1- end) end)))
                      (overlay-put overlay 'my/dired-finder-tags t)
                      (overlay-put overlay 'evaporate t)
                      (overlay-put overlay 'display
                                   (concat (string (char-before end)) " "
                                           dots))))))))

(provide 'my-dired-finder-tags)

;;; my-dired-finder-tags.el ends here
