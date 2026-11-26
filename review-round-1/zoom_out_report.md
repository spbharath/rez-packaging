# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`Lines 1-323`)

Reviewer: `egm-zoom-out`. Verdict: pass with changes. No Blockers. No architectural dead-ends: keeping Ayon unchanged and using one wrapper that calls `rez-env` as a separate process is the right boundary. The repo has no code, so there was nothing to reuse or duplicate.

## Prioritized Findings (Blockers -> Major -> Nits)

### On/off mechanism is both undecided and used as the default - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 55-56, 122, 236`
* **Discrepancy Description**: The Open Questions say one option must be chosen before the first plugin package. The Technical Plan and Defaults table already treat `STUDIO_REZ_REQUEST` plus a preset fallback as the answer.
* **Rationale & Recommendation**: Decide now. The simplest choice is the git preset as the default, with the env variable as an optional override. State it as decided and remove it from the open questions.

### Too many unknowns for a design that already specifies 13 files - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 53-63, 152-155, 222-310`
* **Discrepancy Description**: The executable field, disabling official plugins, env leakage, rez path, NAS and Ayon settings scope are all open. The implementation plan still gives concrete defaults and flags "verified in the spike". Two of the unknowns, the executable field and the inability to disable stock Autodesk modules (line 57), could invalidate the approach, because "removing a package turns the plugin off" may be false for official plugins.
* **Rationale & Recommendation**: Make the spike (steps 1-4) the deliverable of this design and move the rest to a follow-up design once the facts are measured. Say at the top that the riskiest assumptions are tested first.

### Environment scrubbing is specified in two layers - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 101, 237, 249`
* **Discrepancy Description**: The wrapper scrubs variables and `rezconfig.py` also resets `PYTHONPATH`, `PYTHONHOME` and `LD_LIBRARY_PATH`. A rez config reset of `PYTHONPATH` could wipe the paths packages add, unless the intent is pre-resolve parent-environment handling, which the doc does not say. The doc also does not say how the reset avoids breaking Ayon's own variables (check E).
* **Rationale & Recommendation**: Pick one place, probably the wrapper unsetting `PYTHONHOME` and `LD_LIBRARY_PATH` before `rez-env`. Drop the rezconfig reset unless the spike shows it is needed.

### `pix_hello` and `td_scripts` overlap - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 34, 112-114, 267-280`
* **Discrepancy Description**: `pix_hello` exists to prove the on/off switch. `td_scripts` also sets `PYTHONPATH` and `MAYA_SCRIPT_PATH` and could prove the same thing.
* **Rationale & Recommendation**: Use `td_scripts` with a placeholder script as the toggle test and drop `pix_hello` (one package, one function). If it stays, justify why a separate package is needed.

### Speculative features in the first slice - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 61, 122, 145, 147, 249, 259`
* **Discrepancy Description**: `package_cache` is mentioned twice though left off. The saved `rez-env --output` context is not needed by any acceptance check. The 10-second resolve budget has no basis yet. Per-project and per-task requests are described as a benefit that no goal needs.
* **Rationale & Recommendation**: Delete `package_cache` until measured resolves miss a budget. Cut the saved context from the first slice. Fold the budget into the spike as a measurement. Mark per-project requests as later.

### Package conventions describe packages that do not exist yet - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 124-130, 204-220`
* **Discrepancy Description**: The vendor `.mod` rules, the `XBMLANGPATH` `/%B` detail and the compiled-dependency Python note target mtoa and Yeti, which are out of the first slice. Alternatives G and H are longer than the decision needs.
* **Rationale & Recommendation**: Move these to a later doc or reduce them to one line.

### Implementation detail is at the wrong altitude - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 239-310`
* **Discrepancy Description**: The launcher step lists (254-260), the `install_rez.sh` arguments and `rez-bind` list (244), `.gitattributes` and `.gitignore` as numbered deliverables (302-305) and `tests/env_dump.sh` as its own deliverable (282-285) are code-level detail.
* **Rationale & Recommendation**: Compress to interface-level bullets. Fold the env dump into the smoke test or the spike runbook. Drop the numbered ignore and attributes items.

### "Decided by you" is not a rationale - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 195-196`
* **Discrepancy Description**: Alternative D is rejected as a decision, not a technical reason.
* **Rationale & Recommendation**: State the ownership and duplication rationale only, and remove the second-person wording.

### Verification gaps not stated - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 316-317`
* **Discrepancy Description**: `shellcheck` availability on the Rocky machine is assumed. Checks A, E, G and H are manual.
* **Rationale & Recommendation**: Confirm `shellcheck` is installed and record the manual checks as a known gap.

### Rez install location left open despite a known risk - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `Lines 60, 230`
* **Discrepancy Description**: The doc notes that rez on the NAS bakes in an interpreter path, but it leaves the install decision open.
* **Rationale & Recommendation**: Say plainly that a per-host `/opt/rez` install avoids the problem, and decide it.

## Not checked
Whether `concepts_brief.md` and `design_draft.md` contradict this doc. Ayon and rez behaviours (executable field handling, `rezconfig` reset semantics, `rez-env` flag names) were taken from the doc and not verified.
