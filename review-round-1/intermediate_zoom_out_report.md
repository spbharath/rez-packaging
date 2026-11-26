# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`1-323`)

**Stage:** intermediate zoom-out. **Verdict:** pass with changes, 0 Blockers, 8 Major, 4 Nit.
The target is unchanged since the earlier reports (`zoom_out_report.md`, `comprehension_report.md`, `critic_report.md`), so their zoom-out findings still stand. Carried-over items are listed briefly. New items are in full.

## Prioritized Findings (Blockers -> Major -> Nits)

### Blockers

None.

### Major

### Plugin-selection mechanism duplicates what Ayon and rez already offer - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `120-122, 186-190, 236, 307-310`
* **Discrepancy Description**: Alternative C rejects a "full plugin list in Ayon settings". The plan then puts the same list in an Ayon environment variable (`STUDIO_REZ_REQUEST`), which is a hidden second plugin list. Ayon app variants already carry per-variant environment settings, and rez has its own `REZ_*` overrides. The preset file, the variable and the fallback logic are three moving parts for one choice. This is distinct from the earlier "switch undecided" finding, which was about the decision. This one is about duplicated mechanism.
* **Rationale & Recommendation**: The smallest first slice is a wrapper that reads one preset file and runs `rez-env`. Cut the variable override from the first slice, or justify it against Ayon's native environment settings.

### Rez configuration has no single owner - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `244-249, 252-259, 302-305`
* **Discrepancy Description**: Repository roots are spread across the wrapper, `rezconfig.py`, environment variables, `REZ_CONFIG_FILE` and `install_rez.sh` (which only prints a `packages_path` value). `rezconfig.py` reads paths "from environment variables", but nothing says who sets them. Config discovery depends on the wrapper setting `REZ_CONFIG_FILE`, so it depends on the wrapper's own location.
* **Rationale & Recommendation**: Choose one owner for repository paths (the wrapper exports them, or one config file defines them) and remove the other route.

### Central claim (plugin off = package left out) is untested and has no go/no-go gate - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `55-63, 93-122, 222-310`
* **Discrepancy Description**: Line 57 admits Maya also scans its default Autodesk module folders. If that holds, leaving mtoa or Bifrost out of the request does not turn them off, and the design's value shrinks to in-house tools. The document treats this as one of nine open questions and a later spike item. It does not say what the design becomes if the test fails.
* **Rationale & Recommendation**: Make it a stated go/no-go gate before any Detailed Plan work. State the fallback scope, for example "in-house packages only". This is different from the earlier "too many unknowns" finding, which asked for the spike to be the deliverable. That finding stays Major and is the root cause here.

### `exec` in the wrapper defeats logging and the "not half-configured" guarantee - Severity: Major (raised from earlier report)
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `79-83, 99-105, 147, 168, 259`
* **Discrepancy Description**: After `exec`, the wrapper cannot log failures from `rez-env` itself (resolve error, package conflict, missing package). Those errors go to `rez-env`'s own stderr, which Ayon detaches. Only a missing path can be caught before `exec`. CUJ 3 and check F cannot be fully met, and the exit code cannot be logged as line 147 promises.
* **Rationale & Recommendation**: Run `rez-env` as a child with stderr redirected to the log, then return its exit code. This also yields the resolve time the log should hold. It is a structural fix, not a detail.

### `maya` package pins the OS and is awkward to resolve - Severity: Major
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `125-130, 267-270`
* **Discrepancy Description**: The package is `maya 2026.0` and the request is `maya-2026`, with a `requires` on `platform-linux` and the Rocky OS string. The package then fails to resolve on any other host, including the Windows machine where the repo is edited. Only one Rocky machine exists today.
* **Rationale & Recommendation**: Leave OS pinning out of the first slice, or put it in a variant. It is speculative.

### Carried over from the earlier zoom-out report, still standing

* **Two layers specify scrubbing** (`101, 237, 249`), Major, now more serious. The wrapper and `rezconfig.py` own the same job, and the wrapper loads `rezconfig.py` itself. Pick one.
* **Rez location contradiction** (`11, 32, 60`), Major. Rez is said to live on the NAS and at a fixed local path `/opt/rez`. State one.
* **Altitude drop in the Detailed Plan** (`239-310`), Major. It reads as a file-by-file build list while the design decisions are still open.
* **Switch undecided but used as the default** (`56, 122, 236`), Major. Decide it, or label the default as provisional everywhere it is used.

### Nit

### Rez primer and Maya plugin detail belong in a knowledge base - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `15-22, 124-130`
* **Discrepancy Description**: The conventions section carries a rez versions and names primer, plus `XBMLANGPATH` `/%B`, `.mod` path checks and compiled dependency notes. The earlier report covered the vendor-plugin detail. The new point is the rez primer.
* **Rationale & Recommendation**: Link to rez documentation and move Maya plugin detail to the runbook.

### Publish step to the NAS has no owner or test - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `159, 169, 300, 312-318`
* **Discrepancy Description**: Check G needs a `rez-cp` or equivalent publish step. The runbook mentions it only as a manual step, and the smoke test does not cover it.
* **Rationale & Recommendation**: Add it to the smoke test or state that it is manual.

### Overclaim: "no decision is left to the implementer" - Severity: Nit
* **Reviewer Lens:** `zoom-out`
* **Affected Scope:** `7, 224`
* **Discrepancy Description**: The defaults table has several **(confirm)** items and open questions, so the claim is stronger than the table delivers.
* **Rationale & Recommendation**: Reword to "defaults to confirm in the spike".

### Carried over, still standing (Nit)

* `pix_hello` overlaps `td_scripts` (`34, 267-280`). "Decided by you" wording (`195-196`). Speculative `package_cache`, saved-context and resolve-budget items (`61, 145, 147, 249, 259`).

## Not checked

Ayon 1.6.3 and rez behavior (executable field, `rezconfig` semantics, `rez-env` flags), and whether `concepts_brief.md` or `design_draft.md` contradict the design. The repo has no code, so no reuse search was possible. The Maya OS-pin and Autodesk module-scan findings depend on behavior that was not verified.
