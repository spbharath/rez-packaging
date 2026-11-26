# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`Lines 243-387`, "Detailed Implementation Plan" to end of file)

**Reviewers:** `implementation-readiness`, `codebase-details`, `style`. Standard: implementation-readiness-standard.md.

**Verdict:** Not ready to implement. The repo is empty, so there was no code to reuse, and technical accuracy was judged from knowledge of rez, Maya and POSIX shell (nothing was run). The Phase 0 spike is runnable in outline but not as written. P1 to P5 still need decisions that the spike output fields do not supply.

**Totals:** 3 Blocker, 14 Major, 12 Nit.

## Prioritized Findings (Blockers -> Major -> Nits)

### P0 step 1 cannot be executed as written (env_dump circularity) - Severity: Blocker
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `265, 267, 335-338, 172-179`
* **Discrepancy Description**: Step 1 needs `tests/env_dump.sh`, but that file is only a "Create" target (item 9) and no phase says when it is written. At that point Ayon runs Maya directly, so none of our scripts runs and nothing can write the `before` dump. A stub in the executable field is only introduced in step 5. The `maya` label is taken through `mayapy`, a separate process, so it does not show the environment of the Ayon-launched Maya. The `rez` label has no invocation. Step 2 says "Install rez (item 2)", but `install_rez.sh` is listed as P1 work, and its `rez-bind` option is "confirmed in P0".
* **Rationale & Recommendation**: Add a spike-only step list with exact commands. Create `env_dump.sh` and a stub wrapper at the start of P0. Capture `before` through a stub in the executable field that dumps the environment and then runs Maya. Capture `maya` from the real Maya process, through Script Editor or batch `os.environ`, or `/proc/<pid>/environ`. Say which phase creates each file.

### Go/no-go gate is not a deterministic function of recorded fields - Severity: Blocker
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `181, 268, 270, 272`
* **Discrepancy Description**: Go requires three conditions, including "Ayon's `PYTHONPATH` survives the wrapper". No spike step or field records that result. `PLUGIN_OFF_TD`, `PLUGIN_OFF_OFFICIAL` and `EXEC_FIELD_RESULT` have no value domain. "Check whether it loads" does not say whether this means `moduleInfo`, `pluginInfo -q -loaded` or autoload. `maya -batch` does not run GUI plugin autoload, so a batch test can falsely report "off". Line 272 says only an official-plugin failure narrows scope. It does not say what happens if `td_scripts` fails, or which plan items change in the narrowed case. "Revisit Alternative G" is not an executable instruction. No one is named to decide go or no-go.
* **Rationale & Recommendation**: Define each field with an enum or exact measuring command and expected output. Run the plugin-off test as a GUI launch through Ayon with the artist's `MAYA_APP_DIR`. Add fields for PYTHONPATH survival, `AYON_*` names present, and argument pass-through (including Ayon-appended `-file`). Add an outcome table, one row per result combination, that lists the exact plan edits it triggers and who decides.

### "Confirm in P0" items have no spike step or field - Severity: Blocker
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `278, 288, 297, 299, 312, 266-270`
* **Discrepancy Description**: The `rez-bind` install-location option, the `parent_variables` key, the `--no-local` interaction with `packages_path`, and the `--input` with `--` form are all deferred to P0. Only the last has a step (`TWO_STEP_FLAG_RESULT`). Line 278 says spike-results fields are "exactly those named in Phase 0", so the other answers have nowhere to be recorded. P1 items 2 and 3 therefore cannot be written from spike output. Also, `REZ_ENV_PATH`, `MAYA_PATH` and `NAS_MOUNT` are recorded, but no rule says how they reach code. The wrapper and `rezconfig.py` hold defaults that a person copies by hand.
* **Rationale & Recommendation**: Add steps and fields such as `PARENT_VARIABLES_KEY`, `NO_LOCAL_BEHAVIOR`, `REZ_BIND_OPTION` and `REZ_INPUT_FORM`. Add a rule that the table defaults are replaced by spike values in the commit that closes P0, and name the constants edited. State how `MAYA_PATH` is stored in `package.py`. State the fallback if each confirmation fails.

### rez-build --install does not write to the local repository - Severity: Major
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `245, 255, 288, 291-299, 379`
* **Discrepancy Description**: `rez-build --install` writes to `local_packages_path` (default `~/packages`). The config never sets it, so built packages land outside `packages_path` and `rez-search` will not list them.
* **Rationale & Recommendation**: Set `local_packages_path = STUDIO_REZ_LOCAL_ROOT` in the config, or require `--prefix`. Pick one.

### P1 exit check cannot pass from a clean shell - Severity: Major
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `175, 289, 295`
* **Discrepancy Description**: The install script does not edit shell profiles, so rez is not on `PATH`. `rez-search` needs `REZ_CONFIG_FILE`, and the config hard-errors without `STUDIO_REZ_NAS_ROOT`. `~/.rezconfig` is still read unless disabled.
* **Rationale & Recommendation**: Add a sourced helper (for example `tests/rez_env.sh`) that exports `PATH`, the `STUDIO_*` variables and `REZ_CONFIG_FILE`, and disables the home config. Use it in P1, P2 and the runbook.

### install_rez.sh is under-specified and has a sudo and Python problem - Severity: Major
* **Reviewer Lens:** `codebase-details`, `implementation-readiness`
* **Affected Scope:** `281-289, 266, 60`
* **Discrepancy Description**: The script hard-codes `python3` although `REZ_PYTHON` is a spike output. Rocky 8's `python3` is 3.6, too old for current rez. The clone URL, network or PyPI access, the `venv` module, tmp-folder cleanup on failure, and how `rez-env` is found are unspecified. Under `sudo`, `HOME` is often `/root`, so `$HOME/rez/local` and `$HOME/rez/logs` land in the wrong place. "Run as the owner of `dest`" is meaningless when `/opt/rez` does not exist. `rez-bind platform arch os` is probably unneeded because those packages are built in. The `OS_STRING` command (`rez-env platform arch os -- echo`) prints nothing useful.
* **Rationale & Recommendation**: Add an optional `[python]` argument, give the clone URL and prerequisites, and state the invocation (`install.py` with destination). Move per-user directory creation to a separate per-user step. Fix the `OS_STRING` command. Drop or verify the bind step.

### Payload package build commands are left to the implementer - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `320-333`
* **Discrepancy Description**: "A build command that copies `python/`" with "placeholder names confirmed in P2" is an open decision. Missing: the literal `build_command` (or `build.py`), the `build_command = False` attribute for `maya`, the `commands()` syntax with `{root}` and `env.X.append`, whether `rez-build` runs from `packages/<name>/<version>/`, the body of the MEL procedure, and `python/td_scripts/__init__.py`.
* **Rationale & Recommendation**: Give full `package.py` content, or exact attribute values, for all three packages, plus the MEL body and the file list.

### Wrapper script leaves several decisions open - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `304-313`
* **Discrepancy Description**: Unspecified items:
  * how the preset is read (whole file, first line, trailing whitespace) and how it is split under `set -f`;
  * repo-root derivation through symlinks;
  * the command for the resolved package list (`rez-context <file>` and its path);
  * the elapsed-time method and the shell (`$SECONDS` is a bashism);
  * whether a pre-set `STUDIO_REZ_LOCAL_ROOT` is honoured;
  * the log-before-checks ordering;
  * that the context file is written only on success.
* **Rationale & Recommendation**: Provide wrapper pseudocode or exact commands. Declare `#!/bin/bash` or stay POSIX.

### Environment handling can conflict with the PYTHONPATH requirement - Severity: Major
* **Reviewer Lens:** `codebase-details`
* **Affected Scope:** `309, 312, 259, 270`
* **Discrepancy Description**: Ayon's `PYTHONPATH` is inherited by rez's own Python and could shadow its imports. The wrapper unsets `PYTHONHOME` but not `PYTHONPATH`, yet the plan also requires `PYTHONPATH` to survive. Shell startup files (`~/.bashrc`) can reintroduce leaked variables. `ENV_LEAKS` has no inclusion rule for what the wrapper unsets.
* **Rationale & Recommendation**: Specify save, clear for resolve, and restore for the Maya step. Test `--norc` or equivalent in the spike. State the inclusion rule for the unset list.

### Smoke tests T1 to T7 are not implementable as written - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `340-355`
* **Discrepancy Description**:
  * T1 and T2 give no Maya command, and the `-command` quoting (MEL calling `python(...)`) is non-trivial.
  * T3 runs `rez-env` directly, so it needs the config variables and does not exercise the preset file, which is what check D and CUJ 2 require.
  * T5 will not give exit 67 after P2: the default local repo (`$HOME/rez/local`) holds the three packages, so the request still resolves and Maya launches. P5 and the E2E NAS-only run have the same flaw.
  * Exit codes 64 and 66 are untested, and the unwritable-log case is untested.
  * T5 is labelled "bad request" but tests an empty repo.
  * T6 depends on unverified `"$@"` forwarding.
* **Rationale & Recommendation**: Give exact commands and assertion strings, or a helper. Add a `PRESET_FILE` override so a temporary preset can be edited. Set `STUDIO_REZ_LOCAL_ROOT=/nonexistent` for T5 and NAS-only runs, and document how to disable the local repo. Add tests for 64, 66 and the log fallback.

### P5 has no publish step or owner - Severity: Major
* **Reviewer Lens:** `codebase-details`, `implementation-readiness`
* **Affected Scope:** `179, 365, 61, 270`
* **Discrepancy Description**: Nothing publishes packages to the NAS. The runbook offers "`rez-cp` or `cp`" undecided. File locking, symlink support, write access and publisher are open questions that the spike does not measure (only `NAS_MOUNT` and resolve times). No threshold turns `RESOLVE_TIME_NAS` into a decision.
* **Rationale & Recommendation**: Choose `rez-cp` (it refuses to overwrite without `--overwrite`). Give the command, destination, permissions and a write check. Add spike fields for write access and symlinks, and a resolve-time budget stating whether it gates.

### Spike step 5 and the Ayon dev-variant procedure lack content - Severity: Major
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `269, 372-375, 63`
* **Discrepancy Description**: The "one-line test script" has no content or observable result that proves "accepted" versus "rejected". No steps exist to create or select a dev variant. Per-project override is unresolved, so isolation from other users is unproven. If the field rejects the path, no alternative invocation is given.
* **Rationale & Recommendation**: Give the test-script content and what to observe. Add a variant-creation procedure and visibility rule. State the fallback for `EXEC_FIELD_RESULT=rejected`.

### Spike measurements have no commands (Maya facts, value formats) - Severity: Major
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `267-270, 278`
* **Discrepancy Description**: `LICENSE_MECHANISM`, `MAYA_BUILD`, `MAYA_PYTHON`, `TWO_STEP_FLAG_RESULT` ("works or the working form") and `ENV_LEAKS` have no measuring command or value format.
* **Rationale & Recommendation**: State the command and format for each so `docs/spike-results.md` can be filled mechanically.

### Phase table does not assign every file to a phase - Severity: Major
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `172-179, 276-375`
* **Discrepancy Description**: `env_dump.sh`, `spike-results.md`, `version-matrix.md`, `runbook.md`, `.gitignore`, `.gitattributes` and `smoke_test.sh` appear only in the target list. When `$HOME/rez/local` is created is undecided.
* **Rationale & Recommendation**: Add a file-to-phase map including the P0 file list.

### Undefined shorthand and cross-references - Severity: Major
* **Reviewer Lens:** `style`
* **Affected Scope:** `265, 267, 272, 338, 347-353, 355, 365, 375, 382-383`
* **Discrepancy Description**: Checks "A-H" are not defined in this range (only at 183-191). "Item 9", "P0", "P1" and "the gate in the Technical Plan" are bare references. Check letters are used in place of names.
* **Rationale & Recommendation**: List checks A-H once at the top of this section or link to them. Replace "item 9" with the file name. Define "Phase 0 (P0)" on first use.

### Table framing and unclear or contradictory instructions - Severity: Major
* **Reviewer Lens:** `style`
* **Affected Scope:** `245, 252, 255-256, 288, 297, 299, 312`
* **Discrepancy Description**: "Defaults are listed below" is followed by rows that mix defaults with requirements. "Reported install layout" has no source. Line 299 ("adds the local packages path itself unless told otherwise") is unclear. Lines 288, 297 and 312 say "confirm" without stating the fallback.
* **Rationale & Recommendation**: Rename the table "Defaults and requirements" and cite the source for line 252. Give one-sentence behavior and fallback for each confirm item.

### Verification Plan headings do not fit the content - Severity: Major
* **Reviewer Lens:** `style`, `codebase-details`
* **Affected Scope:** `377-383`
* **Discrepancy Description**: "Compilation/Build", "Unit Tests: None" (followed by T1 covering `pix_hello.say()`), "Test Coverage Requirement" and "E2E/Integration" are template headings. Line 382 repeats the mapping from lines 347-355. `py_compile` checks syntax only, not rez-injected names. `shellcheck` on Rocky comes from EPEL and "install in P0" is not a P0 step.
* **Rationale & Recommendation**: Rename to "Build check", "Automated tests" and "Manual checks". Remove the duplicate mapping. Validate packages with `rez-build` or `rez-env`.

### Manual checks A, E, G, H have no steps or pass criteria - Severity: Nit
* **Reviewer Lens:** `implementation-readiness`
* **Affected Scope:** `355, 365`
* **Discrepancy Description**: The runbook names sections but gives no steps. G and H lack pass criteria.
* **Rationale & Recommendation**: Add steps and pass criteria. Also note that Ayon detaches the child, so stderr (CUJ 3, check F) may be invisible and only the log is seen.

### git setup details - Severity: Nit
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`, `style`
* **Affected Scope:** `303, 367-370`
* **Discrepancy Description**: The repo is not yet a git repo, and `git update-index --chmod=+x` needs files in the index (`git add` first). The chmod instruction is stated twice. `.gitignore` lists `logs/` but logs go to `$HOME/rez/logs`. The wrapper's deployment path across hosts is unstated.
* **Rationale & Recommendation**: Add `git init`/`git add`, keep the chmod instruction once, drop or justify `logs/`, and state how the wrapper reaches the same absolute path on each host.

### Smaller specification gaps - Severity: Nit
* **Reviewer Lens:** `implementation-readiness`, `codebase-details`
* **Affected Scope:** `249-259, 338, 343-344, 349`
* **Discrepancy Description**: "Rez tag: none" is not a default, so record the selection method. The `before` and `rez` dumps are used by no check. The preset's "one line, no comments" is not validated. Exit codes 64 to 67 may collide with Maya's own. The T3 command cell is run-on.
* **Rationale & Recommendation**: Fix individually, or note them in the runbook.

### Wording nits - Severity: Nit
* **Reviewer Lens:** `style`
* **Affected Scope:** `245, 259, 263, 268, 270-272, 304, 313, 318, 328, 333, 342, 365, 387`
* **Discrepancy Description**:
  * Line 245 is wordy.
  * Lines 259 and 271-272 contain vague pointers ("Final list from the spike env dump", "see the gate", "as described there").
  * Line 263 should be split into two sentences, and step 4 should read "Repeat the test with".
  * Line 304 is awkward, and line 313 restates step 4 (merge it, and move "context file next to the log" to step 7).
  * "On/off switch" (318) is figurative.
  * Line 333 ("A shelf button can be pointed at either later") is speculative and out of scope.
  * "TD" is not expanded at first use (268).
  * Line 342 is clipped.
  * Line 365 is a seven-item sentence that should be a list.
  * Line 387 is a tool-attribution footer, so confirm it is intended.
* **Rationale & Recommendation**: Apply the edits listed under Affected Scope and Discrepancy Description.
