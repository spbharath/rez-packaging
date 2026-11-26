# Consolidated Review Report, Round 3

**Target:** `docs/designs/rez-maya-2026-ayon.md` (381 lines; FeatureRange 1-249, DetailedRange 250-381)
**Date:** 2026-11-26. Full flow, one instance per reviewer. No findings applied; design not edited. Nothing was run: all statements about rez, Ayon and Maya are reviewer knowledge and unverified until the spike.

## Verdict
Round 2's three Phase 0 Blockers are resolved in form (files are created in Step 0, fields have allowed values, a gate table exists, rez facts have steps). Round 3 finds six Blockers, but they are a different kind: two say Phase 0 is mis-scoped (it builds P1-P3 artifacts, and Ayon questions need no rez), and four say the spike measures the wrong thing or leaves its own artifacts unspecified. The feature range has no Blockers.

| Stage | Report | Blocker | Major | Nit |
| :--- | :--- | :--- | :--- | :--- |
| 5 Initial Zoom Out | `zoom_out_report.md` | 0 | 4 | 6 |
| 6 Comprehension | `comprehension_report.md` | 0 | 5 | 13 |
| 7 Critic (design 0/8/9, structural 0/2/10, style 0/5/16) | `critic_report.md` | 0 | 15 | 35 |
| 8 Intermediate Zoom Out | `intermediate_zoom_out_report.md` | 2 | 6 | 4 |
| 9 Implementation Readiness | `implementation_readiness_report.md` | 4 | 7 | 6 |
| **Round 3 total** | | **6** | **37** | **64** |
| Round 2 | `review-round-2/` | 3 | 37 | 43 |
| Round 1 | `review-round-1/` | 9 | 45 | 44 |

Raw counts are flat or up because reviewers now go deeper on Phase 0. Per-stage reviewers overlap; deduplicated, about 4 Blockers, 25 Majors.

## Round 2 items: resolved vs open
| Round 2 item | Status |
| :--- | :--- |
| B1 P0 runnable (env_dump circularity, stub) | Resolved: Step 0 creates `env_dump.sh`, `stub_maya`, `probe_maya`; new gaps B-I1..B-I4 below |
| B2 gate is a function of fields | Mostly resolved: fields, domains, table exist; table has gaps (M2), PLUGIN_OFF_OFFICIAL mapping undefined |
| B3 "confirm in P0" items | Resolved: fields and fallbacks for `PARENT_VARIABLES_KEY`, `NO_LOCAL_BEHAVIOR`, `REZ_BIND_OPTION`, `REZ_INPUT_FORM`; mapping from output to value still missing |
| M1 reduce P1-P5 to table | Resolved, except L194 carry-overs and L138-146 conventions |
| M2 wrapper minimum contract | Resolved; extras list still in architecture |
| M3 Alt A/G dispositions | Resolved formally; Alt A logic and Alt G scope now questioned (Stage 8) |
| M4 plugin-off wording | Partly: Goal 2 says "guaranteed" (style overclaim); gate row 5 contradicts "as written" |
| M5 risks and trust model | Resolved; gaps: hung NAS timeout, distribution, publish enforcement |
| M6 local shadows NAS | Resolved (opt-in); now argued as unnecessary |
| M7 Ayon scope/rollback | Partly: scope field exists; test-variant isolation missing |
| M8 wrapper vs diagram | Partly: diagram steps still duplicate wrapper section |
| M9 reduce acceptance machinery | Partly: A-H remain, duplicate goals |
| M10 config/tooling faults | Deferred to P1 by design; still listed as dense carry-over |
| M11 publish procedure, variant procedure | Open (publish deferred to P5; variant procedure underspecified) |
| M12/M13 terms, shorthand | Partly open (preset/request, P0 vs Phase 0) |

## Consolidated actions

### Blockers
1. **Re-scope Phase 0 (S8-B1, S8-B2).** Split into P0a (stub only, no rez: exec field, args, env leaks, `AYON_*`, `PYTHONPATH`, project scope) and P0b (minimal rez toggle and plugin-off). State that P0 artifacts are throwaway or promoted; stop P1-P3 repeating them.
2. **Measure arguments at Maya (S9-B1).** Capture `maya.bin` cmdline; add a spaces/quotes/`$` case.
3. **Measure `PYTHONPATH_SURVIVES` where a package sets it (S9-B2),** with `parent_variables` applied.
4. **Print the spike artifacts (S9-B3):** rezconfig, scratch config, `maya` and `td_scripts` `package.py`, `--output/--input` commands.
5. **Step 6 (S9-B4):** specify the hook route or declare it a separate plan; move `REVERT_CHECK` to the end.

### Majors (grouped)
- **Gate:** add default no-go row and boolean predicates; cover `ok-args-lost`+`yes`, `not measured`; fix Alt A rule (A drops the switch; contradicts L129/L206); define `PLUGIN_OFF_OFFICIAL` mapping and "no candidate installed"; `ENV_LEAKS` decision rule; add Alt A config path (`REZ_CONFIG_FILE`).
- **Wrapper safety:** preset read into array, no glob, reject `-` words; clear `REZ_PACKAGES_PATH`/home config; arg quoting test; Ayon `PYTHONPATH` vs rez's Python; bounded NAS check and provisional resolve-time ceiling.
- **Operations:** distribution of wrapper/preset/config; release command and overwrite guard; official-plugin prefs autoload; isolate the Ayon test variant; absolute paths, variant name.
- **Scope trim:** drop `STUDIO_REZ_LOCAL_ROOT`/CUJ 4 or justify; move wrapper extras, carry-overs, A-H, speculative plugin items out; drop go-path Alt G comparison; cut non-gate fields.
- **Clarity:** link Phase 0 anchors from feature range; define field tokens on first use; Assumptions table; one term each for request/preset; soften "guaranteed" and "installed"; fix rez install source/command; fill blank "How measured" cells; add fields for Ayon versions and NAS facts.

### Nits
Stale round in status line; heading levels and casing; glossary; bullets for dense sentences; style wording (see `critic_report.md`); script quoting details (see `implementation_readiness_report.md`).

## Traceability matrix
| Action | S5 | S6 | S7 | S8 | S9 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Re-scope P0 | M4 | | | B1, B2, M5 | |
| Args at Maya | | M2 | D-M3 | | B1 |
| PYTHONPATH measure | | | D-M2 | | B2 |
| Spike artifacts | | | | | B3 |
| Step 6 / Alt G | N4 | | D-N | M4 | B4 |
| Gate gaps / Alt A | M3 | | | M3 | M2, M4 |
| Plugin-off | | M2 | D-M8 | | M3 |
| Wrapper safety | M1 | M3 | D-M1, D-M4, D-M5 | | M1 |
| Ops (distribution, publish) | | | D-M6, D-M7 | M6 | M5 |
| Scope trim | M1, M2, M4 | | S-M3 | M8 | |
| Clarity/terms | | M1, M2, M4 | St-M1, St-M2, Sy-M1..5 | M7 | M6, M7 |

## Not checked
- No Ayon 1.6.3, ayon-core 1.9.12, rez or Maya 2026 behavior verified (arg quoting, `parent_variables`, `REZ_PACKAGES_PATH`, `--output` semantics, Maya launcher env rewriting, mtoa availability all unverified).
- Stage 7 and the zoom-out/comprehension reviewers saw lines 1-249 (Phase 0 definitions were out of their range, which inflates the "undefined token" findings); Stage 9 saw 250-381; Stage 8 saw the whole file.
- No second independent instance of any reviewer was run.
- No code in the repo, so no reuse search. No external docs were consulted.
