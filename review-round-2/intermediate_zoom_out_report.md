# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`Lines 1-387`)

Intermediate zoom-out, round 2. Reviewer lens: `egm-zoom-out`. The target has not been edited since the earlier round-2 reports. Context sufficiency passes. The repo holds only design and review documents, so there is nothing to reuse. Upstream rez, Ayon and Maya behavior was not checked.

## Findings from earlier round-2 reports that still stand

* zoom_out_report, Major: the Detailed Implementation Plan (L243-383) is over-specified.
* zoom_out_report, Major: P1-P5 are specified in full before the P0 gate passes.
* zoom_out_report, Major: the wrapper depends on the unverified `--output`/`--input` flow, though a single-command fallback exists (L312).
* zoom_out_report, Major: the Goals and CUJ 2 overstate the plugin-off guarantee.
* zoom_out_report, Major: the dual repository, `parent_variables` and two hello-world packages are extra machinery.
* zoom_out_report, Nits: excessive observability, bespoke installer, padded Alternatives, no project-alignment reference.
* comprehension_report, Major: the diagram and the detail spec disagree on wrapper behavior (L99-105 vs L304-312).
* comprehension_report, Major: the `package.py` contract is only described in prose.
* critic_report, Major: the local repository silently shadows the NAS.
* critic_report, Major: the Ayon test scope and rollback are inconsistent.
* critic_report, Major: Alternatives A and G have no clear disposition.

## Prioritized Findings (Blockers -> Major -> Nits)

No Blockers.

### Wrapper justified mainly by logging; minimum contract not stated - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L36, L120-124, L160-162, L198-199, L301-313`
* **Discrepancy Description**: Alternative A (L199) justifies the wrapper by "logging, environment scrubbing and error messages". Ayon already captures launcher logs, and rez provides `REZ_RESOLVE` and context files. The design keeps a roughly 60-line shell program (preset parse, checks, exit-code table, log fallback, two-step run) to cover those gaps. The wrapper's essential jobs are two: scrub leaked variables and expand the preset into a `rez-env` call. If the spike finds no leaks, the justification shrinks.
* **Rationale & Recommendation**: State the minimum contract in the Technical Plan: preset in, env scrub, `rez-env <request> -- maya "$@"`, errors to stderr. Make the log file, exit-code table, two-step run and `/tmp` fallback conditional on what the spike shows is missing. This differs from the earlier "single-command as baseline" finding because it asks for the wrapper itself to be justified against Alternative A after the spike.

### Acceptance and test machinery larger than the first slice needs - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L183-191, L335-355, L377-383`
* **Discrepancy Description**: The design has eight acceptance checks (A-H), seven smoke tests (T1-T7) and a separate `env_dump.sh` with its own pass criteria. Four checks (A, E, G, H) are manual anyway. G repeats A-D on the NAS. `env_dump.sh` appears in the spike, the pass criteria and the E2E plan, as a test harness for a prototype.
* **Rationale & Recommendation**: For a go/no-go milestone, keep three outcomes: Maya launches from Ayon with the request visible, the toggle works, and failure gives a non-zero exit. Run `env | sort` by hand in the spike. Add automation after P0.

### Alternative G dismissed on thin evidence - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L231-235, L181, L56, L58`
* **Discrepancy Description**: The stated reason against the prelaunch hook is that rez would run inside Ayon's frozen Python. A hook can spawn `rez-env` as a subprocess, which gives the same process isolation as the wrapper. The hook is also where Ayon already merges environment variables, so `PYTHONPATH` would not need a survive-the-wrapper test. The release-coupling cost is real, but it is not weighed against the wrapper's coupling to the unknown executable-field behavior (L56). The design picks the more fragile hook point without a fair comparison.
* **Rationale & Recommendation**: Rewrite G as a hook that runs `rez-env` as a subprocess. Compare it with the wrapper on coupling and on failure visibility. Make that comparison part of the P0 gate, not a fallback after failure.

### Two layers own the same search-order setting - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L158, L295-299, L311-312`
* **Discrepancy Description**: Config builds `packages_path` conditionally, and the wrapper also passes `--no-local` (behavior "confirm in P0"). A mistake in either silently changes what resolves. This contradicts L122, "only owner of rez settings".
* **Rationale & Recommendation**: Let one layer decide. Prefer config only. The wrapper should pass neither a local flag nor a root.

### Preset file is a one-line file with its own conventions - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L128, L258, L315-318`
* **Discrepancy Description**: A git file holds one string and needs its own parse, empty check and exit code (66). A constant at the top of the wrapper is also in git and reviewed. L128 itself defers per-project presets.
* **Rationale & Recommendation**: Keep the file only if a second preset is planned this milestone. Otherwise use a constant in the wrapper.

### Three overlapping docs for one small effort - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L245, L276-279, L357-365`
* **Discrepancy Description**: `spike-results.md`, `version-matrix.md` and `runbook.md` overlap. The version record (L41) duplicates spike results. About 20 named fields (`REZ_TAG`, `MAYA_BUILD` and so on) are used like program variables. The runbook mixes procedures the spike will rewrite.
* **Rationale & Recommendation**: Use one `docs/` file, spike results first. Split out a runbook after P5.

### Exit codes and constants are interface detail, not architecture - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L259, L308, L311, L313, L349-351`
* **Discrepancy Description**: Codes 64-67 mirror `sysexits.h` values with no stated reason, and tests T4 and T5 hard-code 65 and 67. A change to the code set breaks the tests.
* **Rationale & Recommendation**: Tests should assert "non-zero and a log line", as CUJ 3 says (L83). Keep the numbers out of the design.

### Multi-host framing for a single-host milestone - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L33, L60, L281-289`
* **Discrepancy Description**: "The same path is used on every host", the `[dest]` argument, the exit-3 guard and the `rez-bind` step serve a fleet. The milestone targets one Rocky test machine.
* **Rationale & Recommendation**: Say "one host in this milestone". Record the install commands in the spike results. Write the reusable script when a second host exists. This overlaps the earlier bespoke-installer nit.

### Speculative surface in the test packages - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L35, L138, L140, L325-333`
* **Discrepancy Description**: `td_hello.mel`, `hello_td.run()` and the shelf-button remark prepare for an unrequested use. The `XBMLANGPATH` and `MAYA_PLUG_IN_PATH` conventions are specified without any package that uses them.
* **Rationale & Recommendation**: Drop the `.mel` file, the shelf remark and conventions with no current package. Add them when a real package needs them.

### Non-Goals padded with items nobody proposed - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `L43-52`
* **Discrepancy Description**: "A GUI", "CI", "migrating artist preferences" and "rewriting vendor .mod files" sit beside real scope boundaries (Nuke/3DE, ayon-core packaging, `userSetup.py`). They dilute the real exclusions.
* **Rationale & Recommendation**: Keep only the exclusions a reader might reasonably expect to be in scope.

## Summary
Blocker: 0. Major: 3 new (plus 8 still standing from earlier reports). Nit: 7 new. The architecture is sound. The highest-value changes are to make the wrapper's extras depend on the spike results, to compare Alternative G fairly inside the P0 gate, and to cut the acceptance and test machinery to three outcomes.
