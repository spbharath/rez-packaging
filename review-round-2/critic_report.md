# Goldfish Review Report

**Target:** `D:\Work\PixStone\rez-packaging\docs\designs\rez-maya-2026-ayon.md` (`Lines 1-242`)

Reviewers: egm-design, egm-structural, egm-style. Standard: feature-spec-standard.md (design and structural). Totals: 0 Blocker, 8 Major, 14 Nit.

## Prioritized Findings (Blockers -> Major -> Nits)

No Blockers.

## Major

### No Risks and Mitigations section - Severity: Major
* **Reviewer Lens:** `egm-design`, `egm-structural`
* **Affected Scope:** whole document; scattered in `Open Questions` (L54-63), P0 gate (L181)
* **Discrepancy Description**: The standard requires failure modes, security, scalability limits and mitigations. Risks are spread across Open Questions, CUJ 3 and the gate. Unnamed risks include NAS as a single point of failure, resolve latency, concurrent publish, and preset edit mistakes.
* **Rationale & Recommendation**: Add a "Risks and Mitigations" H2 (risk, impact, mitigation, owner). Cover official plugins loading regardless of the request, environment leakage, NAS outage or latency, publish permissions, and resolve time.

### Security and trust model absent - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** `Wrapper script` (L120-132), `Repository layout` (L158), CUJ 4 (L89)
* **Discrepancy Description**: `package.py` is executable Python run at resolve time. The spec is silent on who may write to the NAS, on local repos that shadow it, on how the wrapper parses the preset file (quoting, injection), and on log location, permissions and retention.
* **Rationale & Recommendation**: Add a trust model: NAS publish ACLs, read-only mounts on artist machines, preset parsing rules, log location and retention.

### Local repo silently shadows NAS - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** L89, L108, L141, L158
* **Discrepancy Description**: The local root is added whenever its folder exists. A stale local repo, such as one left from CUJ 4, makes a pinned request resolve different bits from the rest of the studio. Nothing in the log or the checks shows that a local package won.
* **Rationale & Recommendation**: Log or warn on any package resolved from the local repo, or make the local root opt-in through an explicit variable. Add an acceptance check.

### Official-plugin on/off assumption is core, and the fallback is thin - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** L27, L57, L136-137, L181, CUJ 2, check D
* **Discrepancy Description**: The value proposition is that leaving a package out of the request removes it. The spec itself says Maya scans default Autodesk module folders. The fallback shrinks scope to in-house packages and defers "plugin preference control" to another design, which leaves the stated problem mostly unsolved. CUJ 2 and check D test only `pix_hello`, which cannot fail the way official plugins do.
* **Rationale & Recommendation**: State that the problem is only partly solved if the gate fails. List likely mitigations now (`MAYA_MODULE_PATH` override, `MAYA_PLUG_IN_PATH` scrub). Add an official-plugin case to check D.

### Ayon test scope and rollback are inconsistent - Severity: Major
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** L63, L166, L179, L191
* **Discrepancy Description**: L63 says per-project override is unknown, yet L166 commits to "dev variant or project override". A variant change may hit everyone in scope. Rollback is only "record the original value", it ignores settings or bundle caching, and check H comes after the change is live.
* **Rationale & Recommendation**: Resolve the scope question in P0. State the blast radius and the revert steps.

### Fail-closed behavior and the resolve-time budget are not decided or tested - Severity: Major
* **Reviewer Lens:** `egm-design`, `egm-style`
* **Affected Scope:** L36, L61, L79-83, L100, L172-191
* **Discrepancy Description**: A rez or NAS failure blocks every artist, with no explicit decision against a fallback to plain Maya. Check F verifies stderr, not that an artist sees it, and Ayon detaches the child. The 10-second budget is hedged ("for example", "proposed") and no check tests it.
* **Rationale & Recommendation**: Choose between fail-closed and a visible-warning fallback. State how the artist learns of a failure. Either fix the budget number and add a check, or label it a spike output.

### Alternatives lack clear dispositions - Severity: Major
* **Reviewer Lens:** `egm-structural`, `egm-style`, `egm-design`
* **Affected Scope:** Alternative A (L195-199), Alternative G (L231-235), L181
* **Discrepancy Description**: A's "Reason for Rejection" is "kept only as something to test", and G's is "may be revisited". Neither is a rejection reason. L181 says "stop and revisit" G, while L235 says "may". G's rejection also depends on the unverified `--output`/`--input` usage (L124).
* **Rationale & Recommendation**: Add a status per alternative (Rejected, Deferred, Test-only). Mark A and G provisional pending P0. Reword the reasons. Name the fallback if the two-step flags fail. Cost and complexity are thin for B, C and F.

### Goals are not measurable and terms are inconsistent - Severity: Major
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** L11, L22-23, L35-38, L76, L128, L152, L224
* **Discrepancy Description**: "A small function" is unnamed. "Prints an error" omits stderr in the goal. "Several facts are unmeasured" is vague. "Preset" and "preset file" are mixed, and "plugin" is used for packages. "One line" in L128 and L152 conflicts with a multi-package request. There is no success metric beyond the resolve budget. Check D does not test `td_scripts` end to end.
* **Rationale & Recommendation**: Name the function. Say stderr. List the unmeasured facts or point to Open Questions. Fix the vocabulary ("preset", "package"). Say "one request, one line" or "one package per line". Add a `td_scripts` check and 2-3 outcomes.

## Nit

### No Risks-adjacent structure: acceptance checks lack a heading - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** L168-191
* **Discrepancy Description**: Phases, gate and acceptance checks sit under one H3, and the checks are a bare bullet list.
* **Rationale & Recommendation**: Add an "Acceptance checks" heading, or promote Phases and Acceptance Checks to H2.

### Alternatives referenced out of order, no anchors - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** L181, L199, L235
* **Discrepancy Description**: L181 cites Alternative G before the reader reaches it.
* **Rationale & Recommendation**: Add anchor links.

### Terms defined as an Overview bullet list; stray comma - Severity: Nit
* **Reviewer Lens:** `egm-structural`, `egm-style`
* **Affected Scope:** L9-23, L23
* **Discrepancy Description**: The glossary sits inside Overview, and L23 reads "`bin/maya2026_rez`, that Ayon runs".
* **Rationale & Recommendation**: Move the terms to their own section and fix the comma. Say the path is repo-relative.

### Header metadata and separator style - Severity: Nit
* **Reviewer Lens:** `egm-structural`, `egm-style`
* **Affected Scope:** L3-7, L91, L193
* **Discrepancy Description**: The metadata uses bullets, and the `----` rule appears only once. The author handle is informal.
* **Rationale & Recommendation**: Use a blockquote or table, apply separators consistently, and use a name or role.

### Inconsistent "unverified" markers - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** L59, L124, L132, L140, L198
* **Discrepancy Description**: Markers vary: "(unverified)", "to be confirmed", "expected".
* **Rationale & Recommendation**: Use one marker and list each in Open Questions. L124 should say "verified in the spike", not "confirmed".

### Ayon settings scope question repeated without cross-reference - Severity: Nit
* **Reviewer Lens:** `egm-structural`
* **Affected Scope:** L63-64, L128
* **Discrepancy Description**: The same question appears twice.
* **Rationale & Recommendation**: Cross-reference the Open Question.

### "Ayon is unchanged" and "only owner of rez settings" overstate - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** L93, L99, L122, L132
* **Discrepancy Description**: The Ayon executable setting changes (L37, L166). `config/rezconfig.py` also holds rez settings (L132).
* **Rationale & Recommendation**: Say "Ayon code is unchanged; only the executable setting changes". Reword to "the only place that sets environment variables for rez".

### Ambiguous "first" and other loose phrasing - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** L11, L27, L29, L35, L36, L56, L57, L58, L61, L62, L77
* **Discrepancy Description**: "Used first" could mean search order or time. Other loose spots: "build-out", "The proposed solution:", "to prove the on/off switch", chained "and"s, "plugin preference control", "frozen launcher", the passive "is proposed", awkward "official and custom status", and the verb mismatch between "call" and "imported".
* **Rationale & Recommendation**: Tighten each, using the replacements noted in the review.

### Unsupported or superlative claims in Alternatives - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** L221, L227, L233
* **Discrepancy Description**: "Closer to how Ayon builds environments", "Fully self-contained" and "Simplest possible" are unsupported.
* **Rationale & Recommendation**: Replace with factual statements.

### Package conventions wording - Severity: Nit
* **Reviewer Lens:** `egm-style`, `egm-design`
* **Affected Scope:** L132, L136-141
* **Discrepancy Description**: "key name to be confirmed" has no owner, and the rez-naming explanation is filler. "No OS pin" has no rationale. `/%B` is hedged. Nothing ties the `maya-2026` package version to the real Maya build, so a patch update changes behavior under the same version.
* **Rationale & Recommendation**: Say "confirm in P1", compress the text, give the rationale, and add a version check against the install.

### Duplicate or redundant statements - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** L158 vs L100, L217 vs L5
* **Discrepancy Description**: "NAS root is required" repeats L100, and "decision recorded 2026-11-26" duplicates the Date field.
* **Rationale & Recommendation**: Remove them or cite a decision source.

### Scale limits not addressed - Severity: Nit
* **Reviewer Lens:** `egm-design`
* **Affected Scope:** L61, L158
* **Discrepancy Description**: Start-of-day concurrent resolves over the NAS, locking and symlink behavior, and caching are not discussed as scaling risks.
* **Rationale & Recommendation**: Record the expected concurrency and the plan if resolve exceeds the budget.

### Baseline description of "today" is unsupported - Severity: Nit
* **Reviewer Lens:** `egm-style`
* **Affected Scope:** L27
* **Discrepancy Description**: "Whatever the Ayon applications addon and Maya install give it" is loose and unverified.
* **Rationale & Recommendation**: Point to the P0 baseline measurement.

## Not checked

Technical accuracy of the rez, Ayon and Maya claims. Everything from "## Detailed Implementation Plan" (L243) onward.
