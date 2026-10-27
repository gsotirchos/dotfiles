---
name: branch-stack-rewrite
description: Fold fixes/renames into the originating commits of a stacked branch series, add review follow-ups to the right branch of a stack, or measure branch size.
---

- Measure size: `git diff --numstat <base> <branch> -- . ':!*/LICENSE' ':!<new-pkg>/CMakeLists.txt' ':!<new-pkg>/README.md'`.
- Fold fixes/renames (also in commit messages); drop follow-up fix commits. For stack-wide text renames use a snapshot rewrite: `git filter-branch --tree-filter … --msg-filter … --prune-empty` over all stack branches `^main`.
  - Dry-run on archived snapshots; verify per-commit diffs are rename-only; run tests at each tip.
  - If `git for-each-ref refs/original` shows old backups, pass `--original refs/original-<topic>`; don't `-f` or delete them.
  - Package renames: `git grep` every branch of every affected repo, not just the working tree.
- Review follow-ups: one commit per part on the tip of the branch it concerns, then `git rebase --onto` the branches above, even past the size limit; never a lumped commit/new branch.
- Ask before rewriting pushed branches; never push (force-push is the user's call).
