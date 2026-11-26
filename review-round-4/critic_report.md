# Stage 7: Critic (design + structural + style), round 4

**Target:** `docs/designs/rez-maya-2026-ayon.md`, FeatureRange 1-254 (whole file read for context; detailed range starts L255). Nothing run; rez/Ayon/Maya claims unverified.

| Lens | Blocker | Major | Nit |
| :--- | :--- | :--- | :--- |
| Design | 0 | 9 | 9 |
| Structural | 0 | 1 | 9 |
| Style | 0 | 3 | 19 |
| **Total** | **0** | **13** | **37** |

Standard-required areas (problem, goals/non-goals, architecture, alternatives, risks) all present.

## Design: Major
- **D-M1 Fail-closed has no user-visible channel (L33, 86, 128, 130, 177).** No field records whether Ayon shows stderr/non-zero exit. Add `STDERR_VISIBLE` (stub exiting 1); define what the artist sees.
- **D-M2 NAS root origin and override hole (L106, 140, 165, 179, 380).** Inherited `STUDIO_REZ_NAS_ROOT` can redirect the repo (code execution under own trust model). Hard-code or read from reviewed file in production; env override only in spike.
- **D-M3 Trust/distribution asserted, same facts open (L179, 64, 38, 153, 136).** No enforcement of read-only/TD-only publish; no statement of how wrapper/preset/rez reach workstations. Add "Deployment and trust" section and risk rows.
- **D-M4 Alt A drops required mitigations (L130, 211, 173, 450).** Goal 3, CUJ 3, REZ_PACKAGES_PATH scrub and `REZ_CONFIG_FILE` unmet. Either gate-confirm each or demote A to comparison only.
- **D-M5 Alt G disagreement (L247 vs L411)**; L245 pro unverified.
- **D-M6 Missing alternative: Ayon-native env settings or rez-less env-fragment wrapper (L205-253).** Alt F is a straw man; first-slice packages don't need dependency resolution. Add and reject on a named need.
- **D-M7 No scale/latency target; double resolve (L132, 174-175, 187).** Provisional ceiling; share check and run resolve.
- **D-M8 Motivating example (Arnold) in the likeliest-to-fail area (L25, 34, 60, 171, 447).** State value of in-house-only slice; name fallback plugin.
- **D-M9 "Guaranteed" overclaim (L34, 42, 132);** `td_scripts` `scripts/` empty so `MAYA_SCRIPT_PATH` claim untested; `rez-env --` re-quoting unverified.

## Design: Nit
Status stale; timeout check baseline vs L126; preset second line silently ignored, prefer word allow-list; no risk row for Ayon/rez/Maya upgrades or rc-file env changes; `maya` package hard-codes path, no platform/mismatch rule; field links; CUJ 4 launcher-inherits-var gap and missing wrapper warning; A-H duplicates; L52 shelf wording.

## Structural: Major
- **St-M1 Open Questions say "measured in Phase 0" but no fields for NAS publisher/locking/symlinks (L57, 64, 66, 175).** Add fields or reword.

## Structural: Nit
Risks as H3 under Architecture; stale status; tokens unlinked, no markdown links; mixed heading case; CUJ 4 has no outcome/exit check; minimum contract omits timeout check; L199 dense; glossary needs own heading; Goals subparts plain paragraphs.

## Style: Major
- **Sy-M1** stale status line (L3).
- **Sy-M2** wrapper section mixes contract, extras, Alt A rule repeated at L130/211/450 (L126-130).
- **Sy-M3** L199 carry-overs run-on, "(from review)" noise.

## Style: Nit (19)
"guaranteed" (L34); vague L25; "Proposed solution" in Problem; Overview one paragraph; request/preset drift; glossary lumped; figurative "on/off switch"; "the switch" undefined (L41); tokens undefined in feature range (L59-65, 171-176); wordy fail-closed (L86); L80 and L122 repeat; L132 long sentence; "Likely" (L171); "waits" (L174); vague isolation (L245); Alt E vs L144 copy inconsistency (L235); L212 claim; P0/Phase 0 casing.

## Not checked
Detailed range correctness (covered in Stage 9); any external behavior.
