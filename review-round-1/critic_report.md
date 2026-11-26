# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`Lines 1-221`)

**Reviewers:** egm-design, egm-structural, egm-style. **Summary:** 0 Blocker, 10 Major, 14 Nit.

## Prioritized Findings (Blockers -> Major -> Nits)

No Blockers.

### No Risks & Mitigations section - Severity: Major
* **Reviewer Lens:** `egm-design`, `egm-structural`
* **Affected Scope:** `Lines 53-170` (whole scope; Open Questions at 53-63)
* **Discrepancy Description**: The standard requires explicit risks, failure modes, security and scalability limits. These appear only as Open Questions (53-63), the rollback paragraph (149) and the acceptance checks (162-170). Not covered: a bad package released to the NAS breaking every artist, NAS outage beyond fail-fast (CUJ 3), who may publish, `package.py` executing arbitrary Python at resolve time, `STUDIO_REZ_REQUEST` injecting arbitrary packages, and concurrent NAS load.
* **Rationale & Recommendation**: Add an H2 "Risks & Mitigations" (risk, impact, mitigation, owner), linked to the Open Questions. Include a last-known-good pinned preset as the bad-release rollback, a NAS-down policy, and the NAS write ACL as the trust boundary.

### On/off switch undecided, yet treated as decided - Severity: Major
* **Reviewer Lens:** `egm-design`, `egm-style`
* **Affected Scope:** `Lines 56, 63, 101, 120-122, 190`
* **Discrepancy Description**: Line 56 and line 122 say the choice is open. The diagram (101) and Alternative C (190) treat `$STUDIO_REZ_REQUEST` as settled. Line 122 claims per-project and per-task requests, but line 63 says per-project override may not exist. The variable is effectively a plugin list in Ayon settings, which Alternative C rejects. CUJ 2 and check D depend on this choice. Validation of a free-form string (typos, who may edit) is not described.
* **Rationale & Recommendation**: Pick one status. Either name `STUDIO_REZ_REQUEST` the working assumption everywhere, or remove it from the diagram and Alternative C. State a decision criterion and a deadline (end of the spike). Reconcile 122 with 63. State the open status in one place only.

### Environment scrubbing may break Ayon and check E is untestable - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 58, 101, 116, 167`
* **Discrepancy Description**: Step 2 scrubs `PYTHONHOME` and `LD_LIBRARY_PATH`, and the plan later resets `PYTHONPATH` through `rezconfig.py`. Ayon's prelaunch hook and ayon-maya may rely on Ayon-injected `PYTHONPATH`. Check E does not name the variables. Precedence between rez and Ayon for `PYTHONPATH` and `MAYA_SCRIPT_PATH` is unspecified.
* **Rationale & Recommendation**: Replace "reset" with an explicit allow or deny list and name the `AYON_*` variables checked. Add a check that ayon-maya actually loads in Maya. Define append or replace order.

### Plugin loading and startup ownership undefined - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 34, 46, 57, 77, 128`
* **Discrepancy Description**: With no `userSetup.py`, nothing makes a package run at startup, so `pix_hello` proves only importability. Line 128 ("Ayon's startup path or a TD calls it") is undefined. Real plugins (mtoa, Yeti) need `loadPlugin` or autoload. Line 57 ("plugin preference control is needed") is only a test.
* **Rationale & Recommendation**: State how plugins load in Maya (`.mod` autoload, `MAYA_PLUG_IN_PATH` plus preferences, or an Ayon hook). Make it an architecture item.

### Resolve-time budget unquantified and untested - Severity: Major
* **Reviewer Lens:** `egm-design`, `egm-style`
* **Affected Scope:** `Lines 61, 145, 162-170`
* **Discrepancy Description**: "Under 10 seconds" is only an example. There is no concurrency estimate (morning peak), no cache strategy beyond a deferred `package_cache`, and no acceptance check.
* **Rationale & Recommendation**: Give expected user and launch counts and a pass/fail threshold, and add it to checks A-H, or delete the example.

### Rez location contradicts itself - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 11, 32, 60`
* **Discrepancy Description**: The Overview says rez lives on the NAS. Goal 32 says a fixed local path on Rocky. Line 60 says NAS rez bakes in an interpreter path. Per-host install (drift) and NAS-hosted (single point of failure) have different consequences, and no update policy is given.
* **Rationale & Recommendation**: State one choice and the drift and update policy across workstations.

### `exec` conflicts with logging the exit code - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 99-105, 147`
* **Discrepancy Description**: Step 5 `exec`s `rez-env`, so the wrapper cannot log Maya's exit code, yet observability promises it. Log retention, rotation and an unwritable log directory are not specified.
* **Rationale & Recommendation**: Drop `exec` and wait on the child, or log only pre-launch facts. Specify retention and the unwritable-log behavior.

### Alternative D rejected by authority, not rationale - Severity: Major
* **Reviewer Lens:** `egm-style`, `egm-structural`, `egm-design`
* **Affected Scope:** `Line 196` (and 224, just outside scope)
* **Discrepancy Description**: "Decided by you: ayon-maya stays outside rez" names no decider and addresses the reader as "you". The Cons (195) already give a technical reason.
* **Rationale & Recommendation**: Cite the technical reason (duplicate code, `userSetup.py` clash). Record the owner and date.

### No path from test machine to artist fleet - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 149-159, 168-170`
* **Discrepancy Description**: The plan covers one test machine and one dev variant. There is no staged rollout, kill switch or fleet-wide revert if the NAS or rez fails mid-flight. Check H covers only the settings revert.
* **Rationale & Recommendation**: Add a short "path to production" with gates.

### Verification gaps: batch test, baseline, td_scripts - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 39, 155, 165, 162-170`
* **Discrepancy Description**: A `-batch` hand-test does not prove the GUI environment (license, Qt, `XBMLANGPATH`). Check C compares only `MAYA_LOCATION`. Goal 39 (`td_scripts`) has no acceptance check.
* **Rationale & Recommendation**: Add a GUI-launch check, a full environment diff against baseline, and a `td_scripts` check.

### Open Questions and design depend on each other (ordering, forward references) - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `Lines 53-63, 120-122`
* **Discrepancy Description**: Open Questions precede the architecture but use terms it defines (launcher script, preset, `.rxt`). The plan relies on unresolved questions without anchors. Line 56's `.rxt` rejection duplicates Alternative B (180-184).
* **Rationale & Recommendation**: Move Open Questions after the plan, or add forward references and a "Decision status" note. Replace the duplicate with a pointer.

### Bold run-in labels used as pseudo-headings - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `Lines 120-152`
* **Discrepancy Description**: "Launcher script.", "Package conventions.", "Observability.", "Rollout and rollback." and "Order of work" cannot be linked or navigated.
* **Rationale & Recommendation**: Promote to `###`.

### Acceptance checks and CUJs not mapped; list styles mixed - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `Lines 152-170`
* **Discrepancy Description**: "Acceptance checks:" is plain text, lettered, while the work order is numbered. CUJs 1-4 do not map to checks A-H.
* **Rationale & Recommendation**: Add a heading and a CUJ-to-check mapping.

### Terminology drift: launcher script, wrapper, executable - Severity: Nit
* **Reviewer Lens:** `egm-style`, `egm-structural`
* **Affected Scope:** `Lines 11, 36, 55, 99, 120, 132, 140`
* **Discrepancy Description**: The same artifact is called "launcher script", "wrapper", "executable" and `bin/maya2026_rez`, and "Ayon launcher" is the Ayon product. "In this folder" (132) is ambiguous.
* **Rationale & Recommendation**: Define one term in the Terms list (for example "wrapper script") and name the repo root.

### Repo layout omits files the spec requires - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `Lines 40, 134-143`
* **Discrepancy Description**: No version matrix file appears although Goal 40 requires recording the version set. `presets/` has no filename.
* **Rationale & Recommendation**: Add `docs/version-matrix.md` and a preset filename.

### Unverified claims stated as fact; hedging - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `Lines 19, 55, 59, 127, 129, 177, 213-214`
* **Discrepancy Description**: "Ayon detaches the child" (177) and the frozen-launcher difference (213) are stated as fact while line 55 flags Ayon's behavior as untested. "May be revisited" (214) and "usually" (19) add nothing.
* **Rationale & Recommendation**: Mark as unverified or cite an observation. Use "Revisit if the script route fails the spike."

### Subjective or vague wording in Alternatives - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `Lines 199-202, 206, 219`
* **Discrepancy Description**: "Fully self-contained", "Simplest possible", "Large payloads", "Easy to browse" are unmeasured.
* **Rationale & Recommendation**: State concrete properties or estimates.

### Colloquial or telegraphic phrasing - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `Lines 26, 34, 61, 101`
* **Discrepancy Description**: "whatever ... gives it", "small" used twice, "proposed" without subject, "decided by env dump".
* **Rationale & Recommendation**: Rewrite precisely (for example "Proposed budget: resolve under 10 s"; "variables to be chosen after the env dump").

### Redundancy in Overview and Technical Plan - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** `Lines 11 and 28, 93 and 120`
* **Discrepancy Description**: Repeated statements about what controls plugins and what the script owns.
* **Rationale & Recommendation**: Drop one of each pair.

### "Production requests pin versions" is a requirement phrased as description - Severity: Nit
* **Reviewer Lens:** `egm-style`, `egm-design`
* **Affected Scope:** `Lines 125, 130`
* **Discrepancy Description**: Should read "must pin". Line 125's `2026` or `2026.x` range semantics should be confirmed against the pinning rule.
* **Rationale & Recommendation**: Use "must pin exact versions" and confirm the rez range behavior.

### Multi-word executable fallback is partly moot - Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 55, 120, 178`
* **Discrepancy Description**: Alternative A says the script stays regardless, so the open question implies a choice that does not exist.
* **Rationale & Recommendation**: Reword so the script is the decision and the question is only how Ayon invokes it.

### Alternative F and Ayon-native environment settings not compared - Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 204-208`
* **Discrepancy Description**: The hybrid of Ayon per-variant environment settings is not justified as rejected.
* **Rationale & Recommendation**: Add a short rejection reason.

### No success metrics - Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Lines 162-170`
* **Discrepancy Description**: The checks cover correctness only, with no reliability target such as launch success rate.
* **Rationale & Recommendation**: Add one line (optional for a spike).

### Metadata is thin - Severity: Nit
* **Reviewer Lens:** `egm-structural`, `egm-style`
* **Affected Scope:** `Lines 3-5`
* **Discrepancy Description**: The author is a handle. There is no reviewers or last-updated field, and "Draft" is undefined.
* **Rationale & Recommendation**: Add reviewers and a last-updated date (optional).

### Section heading depth: Problem section names - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** `Lines 24, 91`
* **Discrepancy Description**: Headings "The Problem" and "Technical Plan (Architecture)" differ from the standard's names (Problem Statement, Proposed Architecture). Content is present.
* **Rationale & Recommendation**: Rename for traceability (optional).

### Not checked
* Technical correctness of Ayon 1.6.3 and rez behavior claims, and anything after line 221.
