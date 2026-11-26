# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`lines 1-387`; FeatureRange 1-242, DetailedRange 243-387)

**Reviewer:** `egm-comprehension` (single instance)

**Severity breakdown:** Blocker 0, Major 7, Nit 6

## Prioritized Findings (Blockers -> Major -> Nits)

No Blockers.

## Major

### Wrapper behavior differs between the architecture and the detail spec - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 99-105 vs 304-312`; also lines 36, 83
* **Discrepancy Description**: The architecture diagram says "exit 1" and checks the preset. The detail spec uses exit codes 64-67. The diagram passes `--input` with a saved context. The detail spec adds `--no-local` and a fallback. The diagram unsets variables before it logs. The detail spec opens the log, runs the checks, and unsets variables last. Line 36 and CUJ 3 say only "non-zero". No preset parsing rule is given: `set -f` is noted, but nothing says whether the wrapper trims whitespace or handles multiple lines. Line 258 says "one line, no comments", but item 4 checks only "missing or empty".
* **Rationale & Recommendation**: Make the diagram match the detail spec, or state that 64-67 override "exit 1". Add the preset parsing rule.

### Undefined constants and defaults in the wrapper and rezconfig - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 295, 255, 305-307, 313`
* **Discrepancy Description**: `STUDIO_REZ_NAS_ROOT` is "required" in rezconfig, but the wrapper defaults it to `/nas/rez/packages`. `REZ_CONFIG_FILE` has no stated value. The repo root is "derived from the script's own location" with no method, so symlink handling is unclear. The context file goes "next to the log", but the log can fall back to `/tmp`.
* **Rationale & Recommendation**: State that the wrapper supplies the default, so the rezconfig error fires only when the wrapper is bypassed. Give `REZ_CONFIG_FILE` as `<repo>/config/rezconfig.py`. Specify the repo root method (for example `readlink -f`). Say where the context file goes when the log falls back to `/tmp`.

### Error and exit-code behavior is incomplete - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 311-313, 349-351`
* **Discrepancy Description**: Nothing says what happens if the second `rez-env` fails to start. Codes 64-67 are only "reserved", so they can collide with Maya's own exit codes. T5 uses an empty NAS folder, which is a package-not-found failure, and a malformed preset is not covered. T4 depends on an already-set `STUDIO_REZ_NAS_ROOT` being honored, and says nothing about the local root.
* **Rationale & Recommendation**: Define the exit code for a failed second step. State the collision rule. Add a malformed-preset case. State how the local root behaves in T4.

### The package.py contract is left to the implementer - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 136-138, 320-333`
* **Discrepancy Description**: Package files are described in prose, with no fields or code shown. "Build command disabled", "copies `python/` into the install location (placeholder names confirmed in P2)" and the `commands` syntax are all left open. Item 7 requires `maya-2026` without explaining the range semantics. Nothing says whether `pix_hello` and `td_scripts` set `XBMLANGPATH` (apparently they do not). Nothing says what `say()` does if `REZ_PIX_HELLO_VERSION` is missing.
* **Rationale & Recommendation**: Show a skeleton `package.py` for each package. State the `XBMLANGPATH` decision. Define the fallback behavior of `say()`.

### install_rez.sh has unnamed or unspecified parts - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 252, 281-289`
* **Discrepancy Description**: The `rez-bind` install-location option is unnamed, and its name is deferred to P0. The clone URL, temporary folder cleanup, and the method for "finds the installed rez-env" are unspecified. Exit 3 gives no upgrade or re-run path. `python3` has no minimum version.
* **Rationale & Recommendation**: Name the option after P0, or mark the script as P1-blocked on that result. Specify the clone source, cleanup, the lookup method, and the minimum Python.

### env_dump.sh invocation and label semantics are unclear - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 265, 338`
* **Discrepancy Description**: The labels are defined, but how each runs is not. The script does not say how it chooses `env | sort` or the `mayapy` form per label. It also does not say who calls it inside Ayon's launch for `before`. P0 step 1 saves `maya` from the pre-rez launch, which conflicts with line 338, where `maya` means "inside Maya through `mayapy`". The pass criteria compare against `MAYA_PATH`, and the doc does not say how the script reads that spike value.
* **Rationale & Recommendation**: Define each label's invocation and caller. Fix the P0 step 1 label conflict. State how `MAYA_PATH` is read at test time.

### Acceptance checks do not map cleanly to tests - Severity: Major
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 172-191, 349, 382`
* **Discrepancy Description**: T3 covers check D through a direct `rez-env`, not the wrapper, so the preset path is untested for D. Check E does not say which variables count (item 9 uses `AYON_*`). Check G depends on A, which is a manual GUI test.
* **Rationale & Recommendation**: Run T3 through the wrapper, or state the gap. Put the `AYON_*` definition in check E. Say that G needs manual A.

## Nit

### Terms are undefined or used before definition - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 11-23, 27, 122, 56, 63, 166, 374`
* **Discrepancy Description**: NAS, TD, DCC, CUJ, `.rxt`, Rocky Linux, Ayon bundle and prelaunch hook are not defined. TD and DCC appear before any definition, and "Phase 0" appears at line 11 before its definition. "Ayon applications addon", "variant" and "project override" are undefined, and the document links to no rez or Ayon documentation.
* **Rationale & Recommendation**: Add a short glossary and doc links.

### Preset trailing newline is unspecified - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 258, 318`
* **Discrepancy Description**: "One line, no comments" is stated twice, but a trailing newline is not mentioned.
* **Rationale & Recommendation**: Say whether a trailing newline is allowed.

### Smoke test commands are described, not shown - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 346-352`
* **Discrepancy Description**: Cases such as "Maya prints `REZ_RESOLVE`" are in words. T7 runs "after T1" with no log isolation or cleanup.
* **Rationale & Recommendation**: Show the exact `-command` strings. Isolate the log directory for T7.

### Git configuration details - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 303, 370`
* **Discrepancy Description**: `.gitignore` lists `logs/`, but logs go to `$HOME/rez/logs`, outside the repo. `git update-index --chmod=+x` needs the files staged first, and the instruction is repeated.
* **Rationale & Recommendation**: Drop or justify `logs/`. State the staging requirement once.

### Release command is not chosen - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Lines 89, 365, 61`
* **Discrepancy Description**: The runbook says "`rez-cp` or `cp`" without picking one. Line 89 says the TD releases to the NAS without naming the permission model, although the open question at line 61 mentions "who publishes".
* **Rationale & Recommendation**: Pick one command or state the rule for choosing. Note the permission model.

### Unverified upstream behavior - Severity: Nit
* **Reviewer Lens:** `comprehension`
* **Affected Scope:** `Line 245`
* **Discrepancy Description**: The reviewer did not check claims about rez, Ayon or Maya behavior against upstream documentation. The document marks them unverified until P0.
* **Rationale & Recommendation**: No action needed. P0 settles these.
