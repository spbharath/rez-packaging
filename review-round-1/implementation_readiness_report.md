# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`Lines 222-323`, "Detailed Implementation Plan" to end of file)

Reviewers: `implementation-readiness`, `codebase-details`, `style`. Standard: implementation-readiness-standard.md. The persona files named in the request (`egm-*.md`) do not exist. Each reviewer used the matching `agents/<name>.md` file. Lines 1-221 were not reviewed, so references to the spike, the Technical Plan and acceptance checks A-H are unverified. The rez, Maya and Ayon behavior claims come from reviewer memory and were not run, so the spike should confirm them.

**Summary:** 6 Blocker, 15 Major, 12 Nit. The plan fails the Zero-Decision Rule.

## Prioritized Findings (Blockers -> Major -> Nits)

### Values deferred to an undefined spike - Severity: Blocker
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `Lines 224-237, 267-270`
* **Discrepancy Description**: The Rocky OS string, the Maya install path, the final env-reset list, the rez-env flags, the NAS path and the switch mechanism ("Proposal") are all left to a spike. The spike has no defined output. `package.py` for `maya` cannot be written from this text.
* **Rationale & Recommendation**: Add a Phase 0 spike with explicit steps and a recorded output, for example `docs/spike-results.md` with named fields. Later phases reference those fields. Where a value is already known, state it. Move the remaining open items into one "Open input needed" list.

### No phasing or checkpoints - Severity: Blocker
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `Lines 239-310`
* **Discrepancy Description**: The 13 items are a flat list with no order and no build or test state per phase.
* **Rationale & Recommendation**: Add phases, each with an exit check. For example: P0 spike and env dump, P1 bootstrap and rezconfig, P2 packages and `rez-build`, P3 launcher and smoke test, P4 Ayon switch, P5 NAS.

### Wrong rez-env path - Severity: Blocker
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `Lines 244, 255`
* **Discrepancy Description**: rez `install.py` places the commands under `<dest>/bin/rez/`, so the path is `/opt/rez/bin/rez/rez-env`. The launcher checks `/opt/rez/bin/rez-env`, so step 1 fails on every launch.
* **Rationale & Recommendation**: Fix the path in the launcher and the install script. Have the install script print the real path.

### `--output` saves the context and does not launch Maya - Severity: Blocker
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `Line 259`
* **Discrepancy Description**: `rez-env <request> --output <file> -- maya` writes the context and exits, so `exec` never starts Maya.
* **Rationale & Recommendation**: Use two steps. First run `rez-env <request> --output ctx.rxt`, time it, log the result, and exit 1 on failure. Then run `exec rez-env --input ctx.rxt -- maya "$@"`. This also gives the resolve time, resolved packages and bad-request error that the checks need. Pin the exact flags in the plan.

### Payload folders are never installed - Severity: Blocker
* **Reviewer Lens:** `codebase-details`, `implementation-readiness`
* **Affected Scope:** `Lines 267-280, 314`
* **Discrepancy Description**: "No build step" with `rez-build --install` fails without a build system. `build_command = False` installs only `package.py`, so `pix_hello/python/` and `td_scripts/scripts/` never reach `$HOME/rez/local`. `import pix_hello` would fail.
* **Rationale & Recommendation**: Give `pix_hello` and `td_scripts` an explicit `build_command`, for example `cp -r python {install}`. Use `build_command = False` only for `maya`. Give the full `package.py` text for all three packages.

### rezconfig and launcher lack concrete content - Severity: Blocker
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `Lines 244, 249, 255-259`
* **Discrepancy Description**: The plan gives no root-path variable names (such as `STUDIO_REZ_LOCAL_ROOT` or `STUDIO_REZ_NAS_ROOT`), no config syntax, no saved-context path, no log file name pattern, and no Ayon variable prefix to log. "Verify option names" is left to the implementer. "First repository path" does not say which variable holds it.
* **Rationale & Recommendation**: State the exact variable names, config lines, paths and patterns (for example `AYON_*` for the logged variables).

### Environment reset mechanism is wrong and may break Ayon - Severity: Major
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `Lines 237, 249`
* **Discrepancy Description**: rez has no "reset these variables" setting. The real keys are `resetting_variables` and `parent_variables`, and they affect only variables a package sets. Resetting `LD_LIBRARY_PATH` does nothing unless a package touches it. Resetting `PYTHONPATH` probably drops the entry Ayon's Maya pre-launch hook sets, which would break CUJ 1 and check E. The launcher scrub from Technical Plan step 2 is missing from the launcher steps.
* **Rationale & Recommendation**: Add `PYTHONPATH` to `parent_variables` so packages append to it. Scrub `PYTHONHOME` and `LD_LIBRARY_PATH` explicitly in the launcher. Name the protected Ayon variables.

### `rez-bind` writes to the wrong place - Severity: Major
* **Reviewer Lens:** `codebase-details`, `implementation-readiness`
* **Affected Scope:** `Line 244`
* **Discrepancy Description**: `rez-bind` writes to `~/packages` unless `-i` is given, and `config/rezconfig.py` does not exist yet when the install script runs. The `platform`, `arch` and `os` packages would not be found in `$HOME/rez/local`. Bindings for `os` and `arch` were not confirmed to exist.
* **Rationale & Recommendation**: Pass `-i $HOME/rez/local`. Bind only what a package requires, and drop `python` if nothing needs it. State the exact `os` string for Rocky.

### Local repository required first on every machine - Severity: Major
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `Lines 249, 255`
* **Discrepancy Description**: The launcher exits 1 if the first path is missing, but artist machines have no `$HOME/rez/local`. `rez-env` also adds `local_packages_path` itself unless `--no-local` is given. `release_packages_path` points at the local repository while release is a copy to the NAS.
* **Rationale & Recommendation**: Add the local entry only if its directory exists, and require only the NAS path. Decide on `--no-local`. Specify the release target.

### `exec` conflicts with exit-code and end-time logging - Severity: Major
* **Reviewer Lens:** `codebase-details`, `implementation-readiness`
* **Affected Scope:** `Line 259`
* **Discrepancy Description**: After `exec`, the wrapper cannot log the exit code or end time. The Technical Plan says Ayon detaches the child, which conflicts with "so Ayon sees Maya's exit code".
* **Rationale & Recommendation**: Choose one. Either drop exit-code logging, or run Maya without `exec` and log `$?`.

### rez version unpinned - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `Lines 231, 244`
* **Discrepancy Description**: "Latest stable 3.x tag at install time" gives a different result per host, which conflicts with the same-on-every-host requirement.
* **Rationale & Recommendation**: Pin one tag now, or make the tag a required argument with no default. State which Python `install.py` uses.

### Install script details missing - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `Lines 230, 244-245`
* **Discrepancy Description**: `/opt/rez` is hardcoded in one place and an argument in another. The plan does not say whether root or sudo is needed, or how the script behaves with no network. It names no exit codes.
* **Rationale & Recommendation**: Resolve the path source. State privileges, failure behavior and exit codes.

### Package definitions incomplete - Severity: Major
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `Lines 262-280`
* **Discrepancy Description**: The plan gives no `commands()` body or `requires` text. `td_scripts` says "the Python subfolder" without a name. The placeholder script name and contents are missing. `say()` output text is undefined, and so is how it gets the version. The `maya` package does not say whether it sets `tools`.
* **Rationale & Recommendation**: Give the full text of each file. Name `python/td_scripts`. Have `say()` read `REZ_PIX_HELLO_VERSION`. State the `tools` list.

### env_dump.sh underspecified - Severity: Major
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `Lines 282-285`
* **Discrepancy Description**: The plan gives no output paths, argument convention or diff command, and no definition of the "before rez" baseline. The in-Maya command line is not written out.
* **Rationale & Recommendation**: Write the exact commands, file names and diff invocation.

### Test plan lacks assertions and will hang - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `Lines 285, 287-290, 312-318`
* **Discrepancy Description**: `maya -batch -command "python(...)"` does not exit unless `; quit -f` is added, or `mayapy` is used. Quoting a `-command` string and a path with spaces through `rez-env --` is fragile. No expected exit codes or log lines are given. The space-path scene file is not defined. Checks A-H are not restated. The bootstrap script has no failure-path checks.
* **Rationale & Recommendation**: Write a test table with ID, setup, exact command and expected result. Restate checks A-H in this section.

### Scripts lose the executable bit - Severity: Major
* **Reviewer Lens:** `codebase-details`, `implementation-readiness`
* **Affected Scope:** `Lines 253, 302-305`
* **Discrepancy Description**: Files authored on Windows reach Rocky without `+x`. `.gitattributes` fixes only line endings.
* **Rationale & Recommendation**: Add `git update-index --chmod=+x` for `bin/*` and `bootstrap/*`, or run the launcher through `sh`.

### Runbook and Ayon settings not concrete - Severity: Major
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `Lines 299-310`
* **Discrepancy Description**: The plan does not name the Ayon settings path, field, dev variant or platform key. It gives no commands for pinning a request or for blocking an overwrite on `rez-cp`. "Dev variant or project override" and "Optionally add" leave choices open. No revert test exists.
* **Rationale & Recommendation**: Pick one scope and give exact locations and commands. Add a revert check.

### Unverifiable statements and open items inside the spec - Severity: Major
* **Reviewer Lens:** `style`
* **Affected Scope:** `Lines 249, 259, 314-318`
* **Discrepancy Description**: "Misses the budget" refers to an undefined budget. "Compare to the pre-rez baseline" has no pass criterion. "Verify option names" and "flag verified in the spike" mix open items into the specification. The plan says "the three packages" without naming them.
* **Rationale & Recommendation**: State the budget value and the pass criterion. Move open items to one list or mark them **(confirm)**. Name the packages.

### Intro claim contradicts the table and addresses the reader as "you" - Severity: Major
* **Reviewer Lens:** `style`
* **Affected Scope:** `Lines 224, 233`
* **Discrepancy Description**: "No decision is left to the implementer" is contradicted by the five **(confirm)** or spike-dependent rows. "You should check" and "until you give" use second person.
* **Rationale & Recommendation**: Use "Defaults are listed below. Items marked (confirm) must be verified on the target machine." Use impersonal phrasing for the NAS placeholder.

### Subjective phrase "clear message" - Severity: Major
* **Reviewer Lens:** `style`
* **Affected Scope:** `Line 244`
* **Discrepancy Description**: The text does not say what the message contains.
* **Rationale & Recommendation**: For example "Exits 1 and prints the existing path to stderr."

### `.gitignore` and `.gitattributes` contents missing - Severity: Nit
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `Lines 302-305`
* **Discrepancy Description**: Neither file's patterns are listed.
* **Rationale & Recommendation**: Give `* text=auto eol=lf` for `.gitattributes`, and the ignore patterns such as `logs/` and `*.pyc`.

### Version matrix columns undefined - Severity: Nit
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `Lines 292-295`
* **Discrepancy Description**: "Python versions" does not say whose (rez, Maya or system).
* **Rationale & Recommendation**: Define the columns.

### Request word-splitting in the launcher - Severity: Nit
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `Lines 252, 255`
* **Discrepancy Description**: An unquoted request could glob on `*`. The preset must be one line without comments, which is not stated.
* **Rationale & Recommendation**: Add `set -f` and state the preset format.

### Verification commands not named - Severity: Nit
* **Reviewer Lens:** `style`, `codebase-details`
* **Affected Scope:** `Lines 314-318`
* **Discrepancy Description**: "Python syntax check" names no tool. `rez-search` should list the packages by name. `rez-cp` on an existing version is untested. "Unit Tests: None" ignores `say()`.
* **Rationale & Recommendation**: Use `python -m py_compile`. Name the three packages. Add an overwrite check. Say that the smoke test covers `say()`.

### Terminology and wording inconsistencies - Severity: Nit
* **Reviewer Lens:** `style`
* **Affected Scope:** `Lines 236-237, 244, 249, 264, 270, 285`
* **Discrepancy Description**: "Proposal from the Technical Plan" has no section reference. "Env reset", "Resets" and "leak" name one behavior. "Prints ... so they can be copied" has an unclear antecedent. "Restricts to Linux" duplicates "requires platform-linux". Line 264 is wordy. Line 270 says "plain string" for a **(confirm)** value.
* **Rationale & Recommendation**: Add the reference, use one term, reword the print line, drop the duplicate, shorten line 264, and say "hard-coded" while referencing the default once.

### Shelf button contradiction and duplicated test clause - Severity: Nit
* **Reviewer Lens:** `style`
* **Affected Scope:** `Lines 260, 280, 290`
* **Discrepancy Description**: "So shelf buttons can call it" assumes buttons exist, but the same item says "no shelf files". The space-in-path test is stated twice.
* **Rationale & Recommendation**: Reword to "so a shelf button can be pointed at it later" and keep one test statement.
