* **Always adhere to clean code principles** (i.e. KISS, DRY, single responsibility, least surprise, descriptive naming, SLAP, etc).

* **Do not duplicate code:** Omit comments that simply restate what the syntax already conveys. 
* **Do not excuse unclear code:** Refactor confusing logic and use descriptive variable/function names instead of writing comments to explain it.
* **Provide External Context:** Use comments exclusively to capture information that syntax cannot natively convey, such as URLs to adapted sources/standards, issue tracker references for bug fixes, and `TODO` tags for known limitations.

* **Git operations:** Never commit or push code without explicit authorization.
* **Suggest commit messages:** Any time you implement anything we worked on together, at the very end of your answer for that you will provide me with a *concise yet informative commit message (summary: max. 50 chars line length; body: max. 73 chars line length, if any)* describing all *uncommitted changes* as reported at the moment of its composition by `git status` and `git diff` (and inspect untracked files). Base the message solely on that output and never solely on your memory of what was changed during the conversation.
* **Check before reporting issues:** when identifying an issue in a repo, do not jump into the conclusion it has to be reported before checking that repo's open issues first. Human maintainers and reviewers are very limited.

* **Do not bump versions:** Never bump versions in CHANGELOGs, only append entries in Forthcoming.
* **Check the toolbox before building anything substantial:** Before implementing a feature that involves several fundamental pieces (ROS nodes, device drivers, behavior-tree or SMACC clients, RViz plugins, planners, calibration, registration, ...), look for existing implementations in the organization's `toolbox` GitLab group. Always prefer reusing or extending those packages, and report what exists and how it maps onto the task before writing new code.
  - The organization name is the `<organization>` prefix of the local mirror directory `~/Projects/reference-src/<organization>_toolbox`; substitute it wherever `<organization>` appears below.
  - Grep code in that local mirror (same layout as the GitLab namespace), refreshing it first with `gitlab-mirror <organization>/toolbox ~/Projects/reference-src/<organization>_toolbox`. If the mirror is empty, browse `<organization>/toolbox` on `gitlab.tudelft.nl` instead.
  - Discover projects via the API: `glab api "groups/<organization>%2Ftoolbox/projects?include_subgroups=true&per_page=100&search=<term>"`. Group-wide code search via the API is unavailable on this instance, so grep the mirror for code.
