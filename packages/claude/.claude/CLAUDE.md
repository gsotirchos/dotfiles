* **Always adhere to clean code principles** (i.e. KISS, DRY, single responsibility, least surprise, descriptive naming, SLAP, etc).

* **Do not duplicate code:** Omit comments that simply restate what the syntax already conveys. 
* **Do not excuse unclear code:** Refactor confusing logic and use descriptive variable/function names instead of writing comments to explain it.
* **Provide External Context:** Use comments exclusively to capture information that syntax cannot natively convey, such as URLs to adapted sources/standards, issue tracker references for bug fixes, and `TODO` tags for known limitations.

* **Git operations:** Never commit or push code without explicit authorization.
* **Suggest commit messages:** Any time you implement anything we worked on together, at the very end of your answer for that you will provide me with a *concise yet informative commit message (summary: max. 50 chars line length; body: max. 73 chars line length, if any)* describing all *uncommitted changes* as reported at the moment of its composition by `git status` and `git diff` (and inspect untracked files). Base the message solely on that output and never solely on your memory of what was changed during the conversation.
