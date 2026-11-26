# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (Feature: lines 1-221; Detailed: lines 222-end)

**Reviewer:** `egm-comprehension` (standard: re-implementation-standard.md)

**Summary:** The glossary (lines 15-22) is good, and the document is clear for a reader who knows Rez and Ayon. A fresh engineer would still have to guess in several places. The causes are an unresolved switch decision, package contents that are not fully specified, and an undefined error and log contract. Severity counts are 3 Blocker, 8 Major and 8 Nit.

## Prioritized Findings (Blockers -> Major -> Nits)

### On/off mechanism is both "proposed" and "open" - Severity: Blocker
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `56, 122, 236`
* **Discrepancy Description**: Line 56 says one option must be chosen before the first plugin package. Lines 122 and 236 present `STUDIO_REZ_REQUEST` as a proposal, and the Detailed Plan builds it in as the default anyway. A reader cannot tell whether it is final.
* **Rationale & Recommendation**: State it as decided. Otherwise mark every dependent item (launcher step 3, the preset file, Ayon setting 13) as contingent.

### `install_rez.sh` and `rezconfig.py` contracts are underspecified - Severity: Blocker
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `244, 249`
* **Discrepancy Description**:
  * `install_rez.sh`: the argument order, usage and exit codes are not given. "Clear message" has no text or exit code. The document does not say which python `rez-bind` binds.
  * `rezconfig.py`: paths are "read from environment variables" but the variables are never named. The launcher steps do not set them. "Resets" `PYTHONPATH`, `PYTHONHOME` and `LD_LIBRARY_PATH` does not say which rez setting is used (`parent_variables`, `all_resetting_variables`, `all_parent_variables`). Reset to empty, unset and append behave differently.
* **Rationale & Recommendation**: Name the environment variables, the exact rez config keys and the semantics.

### Launcher error and log contract is not implementable as written - Severity: Blocker
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `255-259, 147, CUJ 1/3`
* **Discrepancy Description**:
  * There is no log file name format, no exact error strings, and no definition of the saved-context path.
  * "First repository path" is ambiguous. It could be the local or the NAS one, and CUJ 3 is about the NAS being unmounted.
  * `exec` replaces the shell, so the exit code (line 147) cannot be logged after Maya exits. Resolve time is required by CUJ 1 and line 147 but is never recorded in the launcher steps.
  * "Ayon variables present" has no prefix or list that identifies them.
* **Rationale & Recommendation**: Specify the log format, the checks per path, and how exit code and resolve time are captured. This probably means not using `exec`, or logging from a wrapper.

### Package contents not fully specified - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `270, 275, 280, 125`
* **Discrepancy Description**:
  * `maya` is version `2026.0`, while line 125 says `maya-2026` matches `2026.x`. State this explicitly.
  * The "Rocky OS string" has no format, for example `os-rocky-9`.
  * `pix_hello`: the `say()` output text, how the version is obtained, the purpose of `PIX_HELLO=1`, and how Maya calls `say()` are missing.
  * `td_scripts`: "the Python subfolder" is not named, and the placeholder script name and content are missing.
  * `pix_hello` and `td_scripts` do not declare a `requires` on `maya`.
* **Rationale & Recommendation**: Give each `package.py` fields (name, version, requires, commands) in a short table or snippet.

### Defaults are placeholders, not decisions - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `59-62, 224-237, 259`
* **Discrepancy Description**: Line 224 says no decision is left to the implementer, but 5 of the 8 default rows are marked "(confirm)" or "verified in the spike". Examples are `/nas/rez/packages`, the Maya path, the Python version, the license mechanism, and the `rez-env` flags (line 259). Rez pinned to the "latest stable 3.x tag at install time" lets two hosts differ, which contradicts line 60.
* **Rationale & Recommendation**: Pin one rez tag. Or state that the spike output is required input and list the exact fields.

### Undefined or vague terms - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `125, 145, 249, 270`
* **Discrepancy Description**: "Declares the platform and OS it was tested on" is vague. `package_cache` is used without a definition. The document has no external links for rez, Ayon launcher, ayon-core, ayon-maya, `.mod` files or `MAYA_MODULE_PATH`.
* **Rationale & Recommendation**: Add a one-line gloss or a link for each.

### How the Ayon variant passes `STUDIO_REZ_REQUEST` is unclear - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `120-122, 249, 310, 63`
* **Discrepancy Description**: "Add to the Maya app environment" does not name the settings field or its format. Line 122 claims per-project and per-task requests, but the open question at line 63 says the scope may not support them. The document does not say how the launcher finds the repo root to locate `config/rezconfig.py`.
* **Rationale & Recommendation**: Say how the script locates the repo root, for example from `$0`. Resolve the contradiction on per-project scope.

### NAS resolve-time budget is not enforced - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `61, 308-317`
* **Discrepancy Description**: The "resolve under 10 seconds" budget is proposed, but no check in A to H and no smoke test enforces it. Nothing covers NAS permissions or who publishes packages.
* **Rationale & Recommendation**: Add the budget as an acceptance check, or drop it.

### Verification plan and build settings are inconsistent - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `269, 314-316`
* **Discrepancy Description**: `rez-build --install` is run "for each package", but `maya` is described as having "no build step". It is unclear how it gets installed. The `maya` `package.py` may need `build_command = False` or equivalent.
* **Rationale & Recommendation**: State the build settings and the build command per package.

### "Decided by you" has no defined referent - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `196`
* **Discrepancy Description**: "Decided by you: ayon-maya stays outside rez." The reader is not identified, and the rationale is not self-contained.
* **Rationale & Recommendation**: Restate it as a decision with an owner and a date, or use neutral wording.

### Startup-function mechanism not given - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `128, 280, CUJ 2`
* **Discrepancy Description**: "Ayon's startup path or a TD calls it" gives no mechanism. CUJ 2 says the `pix_hello` function "can no longer be imported", but the document does not show how a TD calls `say()`.
* **Rationale & Recommendation**: Add one concrete call example.

### OS version not recorded - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `11, 40`
* **Discrepancy Description**: "Rocky Linux" has no version, and line 40 requires recording one.
* **Rationale & Recommendation**: Give the current value or mark it as a spike output.

### Author and owner metadata - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `4`
* **Discrepancy Description**: The author is an identifier with no role. The date has no review owner.
* **Rationale & Recommendation**: Add a role and a review owner.

### Env scrubbing described in two places - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `99-101, 237`
* **Discrepancy Description**: The diagram puts scrubbing in the wrapper. The Detailed Plan puts the reset in `rezconfig.py` and not in the launcher.
* **Rationale & Recommendation**: Pick one place.

### Launcher naming rule unclear - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `120`
* **Discrepancy Description**: "One script per DCC version" conflicts with the single `bin/maya2026_rez` name, and the later DCCs are not named.
* **Rationale & Recommendation**: Clarify the naming rule.

### Version matrix layout not specified - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `231, 292-295`
* **Discrepancy Description**: `docs/version-matrix.md` is described as a table but its columns are not given.
* **Rationale & Recommendation**: List the columns.

### `.gitattributes` rule not given - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `305`
* **Discrepancy Description**: "Forces LF endings" does not give the rule.
* **Rationale & Recommendation**: Give the rule, for example `* text=auto eol=lf`.

### "Unit Tests: None" vs smoke test - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `312-318`
* **Discrepancy Description**: `tests/smoke_test.sh` exists, but the plan says "Unit Tests: None".
* **Rationale & Recommendation**: Clarify that the smoke tests are the only automated tests.

### Unexplained "EGM" footer - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `322`
* **Discrepancy Description**: "Drafted with EGM" is not explained to a fresh reader, and EGM is not defined.
* **Rationale & Recommendation**: Define it or remove the footer.

## Not checked
Whether the described Ayon and rez behavior is factually correct for the stated versions. This is a comprehension-only review.
