---
name: merge-request-comments
description: >-
  Write the merge request review comments agreed in the conversation into a
  Markdown file, each with its file and lines, an inquisitive comment body and
  GitLab code suggestions, ready to paste into the MR. Use after a code review
  whose findings were discussed and settled, when the user asks for the MR
  comments.
argument-hint: "[MR URL | <project-path>!<iid> | <repo-path> <branch>]"
allowed-tools: Bash(glab mr *), Bash(glab api *), Bash(git *), Read, Grep, Glob, Write
---

Arguments: $ARGUMENTS

## Gather

1. The points to raise come from the conversation, together with how each was
   settled: dropped, downgraded, reworded or merged. Keep only points with
   real impact, a concrete way things break, mislead or cost now; leave out
   hygiene with no such failure (an include that arrives transitively, a
   cosmetic default) along with the dropped points, and keep the
   discussion's numbering.
2. The MR comes from the arguments, else the conversation, else
   `glab mr list --source-branch <branch>` in the reviewed repo. Fetch it
   through GitLab, so no local clone is needed (`<enc>` is the URL-encoded
   project path or file path):
   - `glab api "projects/<enc>/merge_requests/<iid>"`: `title`, `web_url`,
     `source_branch`, `target_branch`, `diff_refs.head_sha`.
   - `glab api "projects/<enc>/repository/files/<enc file>/raw?ref=<head_sha>" | cat -n`
     for every file a comment cites. Line numbers from review tools are often
     diff positions, so take them from here.
   - `glab mr diff <iid> -R <project-path>` when the diff itself is needed.
   With only a local repo, use `git show <branch>:<path> | cat -n` instead.
3. Settle every claim before writing it: read the code and sources it rests
   on, and compile or run a minimal check when reading cannot decide (what a
   header pulls in, what a library does with an input). The reviewers own
   this research; the reviewee only gets results. Drop a claim that stays
   unconfirmed, and tell the user, rather than asking the reviewee to check it.
4. Pin every source a comment relies on to the exact version that was read:
   a file in the MR's project at `head_sha`; another repo at the commit of
   the checkout read (`git -C <checkout> rev-parse HEAD` and its `origin`);
   an installed library or header at the release tag of its installed
   version. When the code was read from a local copy, fetch the upstream file
   at that ref and make sure the cited lines are the same.

## Write

- File header: MR title as a link, `source → target`, and the `head_sha` the
  line numbers refer to.
- One section per point, `### N. Short title`. A point that needs comments at
  several places gets sub-items (`5a`, `5b`), one location each.
- Location line: ``[**`<repo-relative path>`, line X**](<project web url>/-/blob/<head_sha>/<path>#LX)``,
  or `lines X-Y` with `#LX-Y`. Always the full repo-relative path.
- Body, in this order: what the reviewee sees in their code; the question,
  if the comment asks one; the suggestion, if any; then, when more than two
  facts back the comment, one fact per bullet with its link, introduced by a
  short lead-in written for that comment that says what the bullets explain
  ("Where `scale` matters, as far as I could find:"), never a fixed label
  (two or fewer facts stay inline). Never chain facts into a paragraph before the
  question.
- Voice: inquisitive, from a reviewer who read up on the topic during the
  review. Hedges such as "If I read X right…" or "I think…" fit
  the reviewers' judgement of the new code and readings of specific library
  lines. A question mark only goes on what the reviewee is to correct, or
  choose how to correct, or what is open for discussion in the review
  ("Could … ?", "Would it make sense to … ?"); never on whether the
  reviewers understood a library's docs or source ("Did I misread…?",
  "I guess it comes from…?"). No verdicts, severity labels or "you should".
- Every function, file, doc or other source a claim rests on is a link to the
  pinned version from Gather step 4, anchored at the lines that back the
  claim, e.g. "[`tesseract_rosutils::fromMsg`](<url>#L494-L501) ignores
  `scale` when `file_path` is empty". GitHub anchors ranges as `#LX-LY`, GitLab as `#LX-Y`.
- Code changes as [GitLab suggestions](https://docs.gitlab.com/user/project/merge_requests/reviews/suggestions/).
  A suggestion holds only the lines it changes (plus the line an insertion
  goes after), never unchanged lines repeated for context. Offsets count
  from the commented line, which is the location range's last line, so end
  the range at the last changed line; earlier lines in it are context only.
  Changed lines X-Y then take `suggestion:-<Y-X>+0`, a single one
  `suggestion:-0+0`. Changes separated by unchanged lines go in separate
  sub-items. Keep the file's indentation.
- Points whose comment ranges overlap become one comment whose heading lists
  every point it covers (`### 2a + 3.`), split into bold-led parts, each
  following the body order above with its own suggestion. When several parts
  change the same line, each later suggestion also carries the earlier
  parts' changes, so applying any one of them gives a consistent line.
- Comments get posted in any order, so a comment that refers to another
  one names it by file (in case it's in a different one) and lines
  ("Continuing from the comment on (`load_mesh.hpp`) lines 69-71…"),
  never "the previous/next/other thread". Section headings are only for
  the user and don't reach GitLab, so a comment that continues another
  still needs a body saying which one.
- Points without a concrete edit, such as structural cleanups, get no
  suggestion. Mark a non-blocking one as a cleanup suggestion.

Save it as `review_<source-branch-slug>.md` in the root of the outermost git
repo enclosing the current directory, else in the current directory. Run
`git check-ignore` on the path and tell the user if the file would show up as
untracked. Never post the comments, push or open threads.

## Report

In chat, not in the file: the path; points merged because their ranges
overlap; and any point the re-check changed or dropped, or left out for
lack of impact.
