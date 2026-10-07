---
name: merge-request-description
description: >-
  Write a merge request (or pull request) description as a Markdown file for
  merging a source branch into a target branch of a git repo, following the
  repo's MR/PR template or a given one. Use when the user asks for an MR/PR
  message, description or body for a branch.
argument-hint: <repo-path> <source-branch> <target-branch> [template-path]
allowed-tools: Bash(git *), Read, Grep, Glob, Write
---

Arguments: $ARGUMENTS

## Gather

1. `git -C <repo> fetch` and confirm both branches exist and match their
   remotes; note any unpushed commits.
2. Read `git log <target>..<source>` (full messages) and
   `git diff <target>...<source>` (stat, then the substantive files in full).
   Separate hand-written changes from generated ones (models, schemas,
   lockfiles) and summarise the latter in one item.
3. Template: the given path, else the first of
   `.gitlab/merge_request_templates/default.md`,
   `.gitlab/merge_request_templates/*.md`, `.github/pull_request_template.md`,
   `docs/pull_request_template.md`. With none, use: summary, Motivation and
   Context, Changes, Testing.
4. Context the diff lacks: the issue key from the branch name; where new code
   is used, by grepping sibling repos in the workspace and noting their branch
   and `origin` path for cross-repo references; how the repo runs its tests
   (CI config, existing test files).

## Write

- Fill every template section; delete optional sections that do not apply and
  the template's placeholder text, but keep its `[comment]: #` lines.
- Motivation must make sense to someone outside the project: the problem
  first, then why this solution.
- Changes: one bullet per behavioural change, not per file.
- Testing: exact commands and the expected outcome taken from the tests.
- Tick checklist boxes only for what the diff shows; mention borderline ones
  to the user instead of guessing.
- Fenced code blocks for code and commands; GitLab/GitHub references
  (`group/repo#123`, `!45`) for anything that already exists.

Save it as `mr_<source-branch-slug>.md` in the root of the outermost git repo
enclosing the repo (e.g. a workspace containing it under `src/`), else in the
repo root. Run `git check-ignore` on the path and tell the user if the file
would show up as untracked. Never commit, push or open the MR. Report the path,
plus anything in the description that does not match the commits (for example
a commit message describing changes made in another repo).
