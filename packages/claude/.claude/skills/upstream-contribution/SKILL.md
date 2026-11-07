---
name: upstream-contribution
description: >-
  Turn a local workaround or a bug the user hit into a contribution to someone
  else's project: decide between commenting on an existing thread, an
  issue/report, a PR/patch or waiting, prepare it, and draft the text in the
  user's voice for them to send. Use when the user wants to upstream, report
  or send a fix for something.
argument-hint: "[the subject, or where it is written down]"
allowed-tools: Bash(git *), Bash(gh api *), Bash(gh search *), Bash(gh issue view *), Bash(gh pr view *), Read, Grep, Glob, Edit, Write
---

Arguments: $ARGUMENTS

Never push, open, comment or email; the user sends everything.

## Gather

1. The subject: what breaks and when, where the local workaround or fix
   lives, and which project it belongs to. Take it from the arguments, the
   conversation, and anything they point to. Restate it in two or three
   lines, and ask only for what is still missing.
2. The local side: read the workaround and its motivation
   (`git log -S'<symbol>'` commit bodies).
3. Upstream now, following any procedure the subject's written source
   documents. Otherwise read the default-branch source, issues and PRs (open
   and closed), the last activity and the latest release. Quote line numbers with the commit they
   were read at.
4. Ground rules: CONTRIBUTING, an AI policy, the PR template, CI and tests,
   copyright assignment (GNU ELPA, Emacs core and Org take about 15 changed
   lines without papers), and the channel (GitHub, debbugs, a mailing list).
5. Pacing: the user's open threads with that maintainer
   (`gh search prs --author=@me --state=open --owner=<owner>`, same for
   issues).
6. Reproduce the user-visible symptom, with its exact message, in a scratch
   setup under the session scratchpad. Never alter the user's config to do it.

## Decide

Propose one outcome with its reasons and wait for the user to confirm it. If
the source records a verdict, treat it as a guess, and say when findings
overturn it.

- Comment: an existing thread covers it. Add the diagnosis or patch there.
- Issue/report: it needs a design call (an option, a default, an API), it is
  large, the maintainer reserves that area, the project bans AI-written code,
  or a patch would need papers the user lacks.
- PR/patch: a small, clear fix, a project that merges outside contributions,
  and a policy that allows it.
- Wait: the user has an open thread with this maintainer, or the project is
  dormant. Then name the source's fallback if it has one (adopt, fork, release
  it separately).

## Prepare a PR/patch

- Clone `gsotirchos/<repo>` to `~/Projects/<repo>`, add `upstream`, and
  branch from `upstream/<default>`. Check if the fork exists and if not,
  give `gh repo fork <owner>/<repo> --clone=false` for the user to run.
- Name the branch the way the project's past PR branches are named. Match the
  file's style, and change nothing beyond the fix.
- Add a test only if contributors add them for similar fixes. Put it in the
  existing test file, in its style, and run the suite with and without the
  fix to show the test catches the bug. Report failures the fix didn't cause.
- One commit: a summary of at most 50 chars in the project's log style, plus
  at most one body sentence wrapped at 73. Mailing-list projects: a
  ChangeLog-style message and `git format-patch`.

## Draft

Write the comment, issue or PR text as a fenced Markdown block in the reply,
in the user's voice: plain sentences, no headings unless the template
requires them, no lists of benefits. State the symptom and when it occurs,
quote the exact message (shorten private paths), give the cause and the fix,
and link related threads by number. A diff in the text shows that fix alone
against the default branch, even when its commit sits on a stack, so the
context lines are the code a reader of that one thread sees upstream.
Add an AI-use line when the policy asks for one or Claude wrote the code.
When the user edits the draft, review the edit and keep their wording. End
with the exact commands to send it (`gh issue create`, `gh pr create --repo
<owner>/<repo> --head gsotirchos:<branch>`, `gh issue comment`, `M-x
report-emacs-bug`, or the list address for the patch).

## After submission

When the user reports the thread, confirm it with `gh pr view`/`gh issue
view`. If the subject came from a written source, update it by that file's own
conventions (read any section explaining them; Edit refuses symlinks, so
edit the target): the new status, the thread, commit, branch and next step.
End with the commands to check the thread's status.
