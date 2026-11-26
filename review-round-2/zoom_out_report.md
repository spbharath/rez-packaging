# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`1-387`)

**Reviewer:** `egm-zoom-out` (single instance). No Blockers found.

## Prioritized Findings (Blockers -> Major -> Nits)

### Blockers

None.

### Major

### Over-detailed implementation plan - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `243-383` (Detailed Implementation Plan)
* **Discrepancy Description**: The section specifies code-level detail: exit codes 2-4 and 64-67 with message formats, `set -f`, a `/tmp` log fallback, `git update-index --chmod=+x`, exact `.gitignore` and `.gitattributes` contents, a seven-row smoke-test matrix with `timeout 120`, the output wording of `say()` and `hello_td.run()`, and field-by-field `package.py` contents. Line 245 says all rez, Ayon and Maya behavior in this section is unverified until the spike.
* **Rationale & Recommendation**: Much of this will change once the spike results arrive. Reduce the section to component responsibilities, interfaces and acceptance checks. Move exit codes, git config and per-file field lists to the implementation phase or into the files themselves.

### Post-gate phases specified before the gate passes - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `275-356`, `377-383`, plus the gate at `181`
* **Discrepancy Description**: The design commits to 14 deliverables, but the P0 go/no-go gate can shrink the scope (in-house packages only) or send the design back to Alternative G.
* **Rationale & Recommendation**: Fully specify P0 only. Keep P1-P5 at the level of the phase table until the gate passes.

### Wrapper built on an unverified two-step flow - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `124`, `205`, `301-313`
* **Discrepancy Description**: The wrapper uses a multi-step flow (resolve, then run), logging, a temp-dir fallback and custom exit codes. It rests on `--output` then `--input`, which the doc says is unverified. The simple form `rez-env --no-local <request> -- maya "$@"` with stderr logged is already listed as the fallback (line 312). The saved context file (kept "for failed or pinned sessions", line 205) is not consumed by anything in the design.
* **Rationale & Recommendation**: Make the single-command form the baseline. Add the two-step form only if the spike shows a real need, such as exit-code logging. Drop the saved context file unless something reads it.

### Goals and CUJ 2 overstate the plugin-off guarantee - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `38`, `55-57`, `77`, `181`, `268`
* **Discrepancy Description**: The root requirement, per-launch control of what Maya loads, depends on the "plugin-off" claim. Maya also scans its default Autodesk module folders, so omitting a package may not disable it. Goal 38 and CUJ 2 read as if it will work. The gate and the open question are correct about the risk.
* **Rationale & Recommendation**: State in Goals and CUJ 2 that "off" is guaranteed only for packages delivered through rez until the spike confirms otherwise. This matches the gate's fallback.

### Dual repository, `parent_variables` and duplicate test packages - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `128`, `158`, `297-299`, `320-333`
* **Discrepancy Description**: Three pieces of extra machinery.
  * The local plus NAS repositories, with a conditional local root and `--no-local` plus an explicit root, exist only to support TD testing (CUJ 4).
  * Four variables are listed in `parent_variables`, but only `PYTHONPATH` is backed by an open question (line 58). Packages using `prepend_path` or `append_path` already compose.
  * `pix_hello` and `td_scripts` both put a payload on `PYTHONPATH` and each carries its own hello-world payload (`say()`, `hello_td.run()`, a `.mel` file).
* **Rationale & Recommendation**: Confirm in P0 whether `parent_variables` is needed, and list only the variables the spike shows are clobbered. Consider one test package for the on/off proof: keep `td_scripts` (Goal 8 needs it) and fold the toggle test into it, or keep `pix_hello` as a stub only. Reconsider whether the first slice needs the local repository.

### Nit

### Observability exceeds requirements - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `160-162`, `267-272`, `311`
* **Discrepancy Description**: The log filename scheme, the `AYON_*` variable-name list and the elapsed-time capture go beyond what check A needs. Rez's `REZ_RESOLVE` and Ayon's launcher log may cover most of it.
* **Rationale & Recommendation**: Keep the request, the resolved packages and the exit code.

### Bespoke rez installer - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `143-158`, `281-289`
* **Discrepancy Description**: `bootstrap/install_rez.sh` wraps rez's own `install.py` with clone, tag handling, exit codes and `rez-bind`.
* **Rationale & Recommendation**: It pays off only with more than one host. For a single Rocky machine, a runbook section may suffice.

### Alternatives section padded - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `193-241`
* **Discrepancy Description**: Eight alternatives, several of them strawmen (E copy Maya, H per-DCC folders). A and G are the real design choices.
* **Rationale & Recommendation**: Trim the others to one line each.

### No project alignment reference - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `11`, `25-29`
* **Discrepancy Description**: The standard asks for alignment with the project's root `README.md` or `context.md`. The doc cites neither, and the reviewer did not check whether one exists.
* **Rationale & Recommendation**: Cite the project context document if one exists.

## Notes
* Context sufficiency passes. The architecture (Ayon runs one wrapper, rez resolves, a git preset is the switch) is sound and minimal at the top level. The main issues are altitude control and scope.
* Not checked: other repo files for overlapping rez config or wrapper scripts, and any rez, Ayon or Maya behavior claim.
