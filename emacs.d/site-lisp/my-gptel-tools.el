;;; my-gptel-tools.el --- Context-aware coding tools for gptel -*- lexical-binding: t; -*-

;; Copyright (C) 2024
;; Author: You
;; Keywords: tools, llm, gptel, lsp, treesit

;;; Commentary:
;; This package provides context-gathering tools for gptel, split into three categories:
;;
;; 1. Project: High-level navigation and history.
;; 2. Tree-sitter: Fast, syntax-aware analysis of the CURRENT buffer.
;; 3. LSP: Deep, project-wide symbol resolution.

(require 'gptel)
(require 'project)
(require 'vc)
(require 'treesit)
(require 'eglot)
(require 'xref)

;;; Code:

;;; -------------------------------------------------------------------------
;;; 1. Project & VC Tools (Navigation & History)
;;; -------------------------------------------------------------------------

(defun my/gptel-tools--vc-log (limit)
  "Get the recent commit history up to LIMIT using Emacs VC."
  (let ((default-directory (project-root (project-current))))
    (with-temp-buffer
      (vc-call-backend (vc-responsible-backend default-directory)
                       'print-log nil (current-buffer) nil nil limit)
      (buffer-string))))

(defun my/gptel-tools--list-files ()
  "List all files in the current project."
  (if-let ((pr (project-current)))
      (mapconcat #'identity (project-files pr) "\n")
    (buffer-file-name)))

(gptel-make-tool
 :name "CommitHistory"
 :function #'my/gptel-tools--vc-log
 :description "Read the recent version control (git) commit log.

PURPOSE:
- Understand WHY code was changed recently.
- Summarize recent activity or finding when a bug might have been introduced.

ARGS:
- limit: How many commits to go back (e.g., 5 or 10)."
 :args (list '(:name "limit"
               :type integer
               :description "Number of commits to fetch."))
 :category "my-tools")

(gptel-make-tool
 :name "ProjFiles"
 :function #'my/gptel-tools--list-files
 :description "List all files in the active project/repository.

PURPOSE:
- execute this at the START of a session to understand the file structure.
- Use this to find the correct filenames before asking to read them.

LIMITATIONS:
- Returns a flat list of paths. Does not show content."
 :category "my-tools")

;;; -------------------------------------------------------------------------
;;; 2. Tree-sitter Tools (Fast, Local Structure)
;;; -------------------------------------------------------------------------

(defun my/gptel-tools--project-outline ()
  "Return an outline of the entire project (Files -> Classes/Functions)."
  (if-let ((pr (project-current)))
      (let ((files (project-files pr))
            (outline ""))
        (dolist (file files)
          ;; Filter for source files only (customise extensions as needed)
          (when (string-match-p "\\.\\(py\\|sh\\|js\\|ts\\|el\\|rs\\|go\\|c\\|cpp\\|java\\)$" file)
            (let ((short-path (file-relative-name file (project-root pr)))
                  (outline (my/gptel-tools--ts-outline file)))
              (unless (string-match-p "No definitions found" outline)
                (setq outline (concat outline
                                       "\nFile: " short-path "\n"
                                       outline
                                       "\n----------------"))))))
        (if (string-empty-p outline)
            "No definitions found in project."
          outline))
    "Not in a project."))

(defun my/gptel-tools--resolve-file (filepath)
  "Resolve FILEPATH relative to project root and ensure it is readable."
  (let* ((pr (project-current))
         (root (if pr (project-root pr) default-directory))
         (full-path (expand-file-name filepath root)))
    (unless (file-readable-p full-path)
      (error "File not found or not readable: %s" full-path))
    full-path))

(defun my/gptel-tools--ts-outline (filepath)
  "Return a structural outline (classes/methods) of FILEPATH."
  (let ((full-path (my/gptel-tools--resolve-file filepath)))
    (with-current-buffer (find-file-noselect full-path)
      (unless (treesit-available-p)
        (error "Tree-sitter is not available in this Emacs build"))

      ;; Attempt to ensure treesit is active (if mode hooks didn't fire it)
      (unless (treesit-language-at (point))
        (ignore-errors (treesit-parser-create (treesit-language-at (point)))))

      (if-let ((lang (treesit-language-at (point))))
          (let* ((query '((class_definition name: (identifier) @name)
                          (function_definition name: (identifier) @name)))
                 (captures (treesit-query-capture (treesit-buffer-root-node lang) query lang))
                 (results '()))
            (dolist (cap captures)
              (let ((type (treesit-node-type (treesit-node-parent (cdr cap))))
                    (name (treesit-node-text (cdr cap) t))
                    (line (line-number-at-pos (treesit-node-start (cdr cap)))))
                (push (format "%d: [%s] %s" line type name) results)))
            (if results
                (mapconcat #'identity (nreverse results) "\n")
              (format "No definitions found in %s (Check if tree-sitter mode is active)." filepath)))
        (format "Could not determine tree-sitter language for %s." filepath)))))

(defun my/gptel-tools--ts-read (filepath name)
  "Read the source code of a function/class by NAME in FILEPATH."
  (let ((full-path (my/gptel-tools--resolve-file filepath)))
    (with-current-buffer (find-file-noselect full-path)
      (if-let ((lang (treesit-language-at (point))))
          (let* ((query (format "((identifier) @name (:equal @name \"%s\"))" name))
                 (captures (treesit-query-capture (treesit-buffer-root-node lang) query lang)))
            (if captures
                (treesit-node-text (treesit-node-parent (cdr (car captures))) t)
              (format "Definition for '%s' not found in %s." name filepath)))
        (format "Tree-sitter not active for %s." filepath)))))

(gptel-make-tool
 :name "ProjDefs"
 :function #'my/gptel-tools--project-outline
 :description "Get a FULL structural overview of the entire project.

RETURNS:
- A list of all source files.
- Under each file, a list of Classes and Functions defined within it.

WARNING:
- This output can be very large.
- Use `ProjFiles` first to see if the repo is too huge.
- Use this ONLY for small-to-medium projects to get a 'God's Eye View' of the architecture."
 :category "my-tools")

(gptel-make-tool
 :name "FileDefs"
 :function #'my/gptel-tools--ts-outline
 :description "Get a structural outline (Classes, Functions, Methods) of a specific file.

PURPOSE:
- FAST overview of what code is in a file without reading the whole text.
- Use this BEFORE `FileDefLookup` to get the exact names of functions.

ARGS:
- filepath: The relative path to the file (e.g. 'utils/helpers.py')."
 :args (list '(:name "filepath"
               :type string
               :description "Relative path to the file."))
 :category "my-tools")

(gptel-make-tool
 :name "FileDefLookup"
 :function #'my/gptel-tools--ts-read
 :description "Read the full source code of a specific function or class in a file.

PURPOSE:
- Extract specific code blocks to analyze logic without reading the whole file.
- Extremely fast and token-efficient.

BEST PRACTICE:
- Run `ProjFiles` to find files.
- Run `FileDefs` on a file to get its symbols' names.
- Run `FileDefLookup` to get the code."
 :args (list '(:name "filepath"
               :type string
               :description "Relative path to the file.")
             '(:name "name"
               :type string
               :description "The exact name of the function or class."))
 :category "my-tools")

;;; -------------------------------------------------------------------------
;;; 3. LSP Tools (Deep, Project-Wide Intelligence)
;;; -------------------------------------------------------------------------

(defun my/gptel-tools--lsp-def (identifier)
  "Find definition of IDENTIFIER across the project using Xref/Eglot."
  (unless (eglot-current-server) (error "Eglot not active"))
  (let ((defs (xref-backend-definitions (xref-find-backend) identifier)))
    (if defs
        (with-current-buffer (marker-buffer (xref-item-location (car defs)))
          (save-excursion
            (goto-char (marker-position (xref-item-location (car defs))))
            ;; Helper: grab the paragraph or treesit node at point
            (if (and (fboundp 'treesit-node-at-point) (treesit-language-at (point)))
                (treesit-node-text (treesit-node-parent (treesit-node-at-point)) t)
              (thing-at-point 'defun t))))
      (format "No definition found for %s" identifier))))

(defun my/gptel-tools--lsp-refs (identifier)
  "Find references of IDENTIFIER across the project."
  (unless (eglot-current-server) (error "Eglot not active"))
  (let ((refs (xref-backend-references (xref-find-backend) identifier)))
    (mapconcat (lambda (x) (format "%s: %s"
                                   (xref-item-summary x)
                                   (xref-item-location x)))
               (seq-take refs 10) "\n")))

(gptel-make-tool
 :name "ProjDefLookup"
 :function #'my/gptel-tools--lsp-def
 :description "Find the definition of a symbol ANYWHERE in the project using LSP.

PURPOSE:
- Jump to definitions located in ANY file (imports, libraries).
- Understand how an imported function is implemented.

COMPARISON:
- Slower than `FileDefLookup`.
- Use `FileDefLookup` if you know in which file the symbol is defined.
- Use `ProjDefLookup` if it's unclear where the symbol is defined beforehand."
 :args (list '(:name "identifier"
               :type string
               :description "The name of the symbol to look up."))
 :category "my-tools")

(gptel-make-tool
 :name "FindRefs"
 :function #'my/gptel-tools--lsp-refs
 :description "Find usages (references) of a symbol across the entire project.

PURPOSE:
- Understand how a function or class is USED by other parts of the system.
- Determine impact before suggesting a refactor."
 :args (list '(:name "identifier"
               :type string
               :description "The name of the symbol."))
 :category "my-tools")

;;; -------------------------------------------------------------------------
;;; Interactive Commands
;;; -------------------------------------------------------------------------

;;;###autoload
(defun my/gptel-tools-add-tools ()
  "Add all Context (Project, Treesit, LSP) tools to the current gptel session."
  (interactive)
  ;; In newer gptel versions, we can just add the tool structs directly.
  ;; If using gptel-make-tool with :category, they are added to `gptel-tools`
  ;; but we might want to ensure they are available to the current buffer.
  (let ((tool-names '(CommitHistory ProjFiles ProjDefs FileDefs FileDefLookup ProjDefLookup FindRefs)))
    (dolist (tool tool-names)
      (unless (member tool gptel-tools)
        (add-to-list 'gptel-tools tool)))))

(provide 'my-gptel-tools)
;;; my-gptel-tools.el ends here
