---
name: branch-stack-rewrite
description: Fold fixes/renames into the originating commits of a stacked branch series, add review follow-ups to the right branch of a stack, or measure branch size.
---

- Measure size: `git diff --numstat <base> <branch> -- . ':!*/LICENSE' ':!<new-pkg>/CMakeLists.txt' ':!<new-pkg>/README.md'`.
- Before any rewrite (filter-branch, rebase, amend/fixup), back up each affected branch: `git branch backup/<branch> <branch>`; if one exists, ask, never `-f` it. Leave no refs outside `refs/heads`. Rebase with `--no-update-refs` (`rebase.updateRefs` moves the backups too).
- Fold fixes/renames (also in commit messages); drop follow-up fix commits. For stack-wide text renames use a snapshot rewrite: `git filter-branch --tree-filter … --msg-filter … --prune-empty` over all stack branches `^main`.
  - Dry-run on archived snapshots; verify per-commit diffs are rename-only; run tests at each tip.
  - Pass `--original refs/filter-branch-scratch`, then delete it: `git for-each-ref --format='%(refname)' refs/filter-branch-scratch | xargs -rn1 git update-ref -d`. Leave pre-existing `refs/original*` alone.
  - Package renames: `git grep` every branch of every affected repo, not just the working tree.
- Review follow-ups: one commit per part, even past the size limit; never a lumped commit/new branch.
- Ask before rewriting pushed branches; never push (force-push is the user's call).
