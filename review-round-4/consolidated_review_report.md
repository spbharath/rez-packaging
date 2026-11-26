# Consolidated Review Report, Round 4

**Target:** `docs/designs/rez-maya-2026-ayon.md` (462 lines; heading "## Detailed Implementation Plan" at line 255; FeatureRange 1-254, DetailedRange 255-462). Note: the file is 462 lines, not 456; the extra lines are Phase 0 verification and footer.
**Date:** 2026-11-26. Full flow, one instance per reviewer. Design not edited. Nothing was run: every statement about rez, Ayon and Maya is reviewer knowledge and unverified until the spike.
**Ranges used:** Stages 5, 6, 8 read the whole file; Stage 7 reviewed 1-254 (whole file read for context); Stage 9 reviewed 255-462. This fixes round 3's split error.

## Verdict
The round 3 re-scope (P0a/P0b), args capture from /proc, launch-2 PYTHONPATH measurement, printed spike artifacts, rewritten gate table and wrapper safety rules are all present. Round 4 has 3 Blockers, all in the detailed range: the spike's shell environment is unspecified and circular, the gate table still has holes and a circular row, and the plugin-off test cannot tell "off" from "absent". Feature range: no Blockers.

| Stage | Report | Blocker | Major | Nit |
| :--- | :--- | :--- | :--- | :--- |
| 5 Initial Zoom Out | `zoom_out_report.md` | 0 | 5 | 6 |
| 6 Comprehension | `comprehension_report.md` | 0 | 12 | 12 |
| 7 Critic (design 0/9/9, structural 0/1/9, style 0/3/19) | `critic_report.md` | 0 | 13 | 37 |
| 8 Intermediate Zoom Out | `intermediate_zoom_out_report.md` | 0 | 6 | 7 |
| 9 Implementation Readiness | `implementation_readiness_report.md` | 3 | 11 | 7 |
| **Round 4 total** | | **3** | **47** | **69** |
| Round 3 | `review-round-3/` | 6 | 37 | 64 |
| Round 2 | `review-round-2/` | 3 | 37 | 43 |
| Round 1 | `review-round-1/` | 9 | 45 | 44 |

Blockers fell 6 to 3, but Majors rose 37 to 47 because Stages 5, 6 and 8 now read the whole file (round 3 range error removed) and Phase 0 is examined more deeply. Deduplicated: about 3 Blockers, 28 Majors.

## Round 3 Blockers/Majors: resolved vs open
| Round 3 item | Status |
| :--- | :--- |
| S8-B1/B2 Re-scope Phase 0 | Resolved in form (P0a stub only, P0b rez). Residual: Phase 0 still large; "not promoted" means writing twice (S8-M1, S8-M2, S5-M1) |
| S9-B1 Args at Maya | Mostly resolved: `capture_maya.sh` reads /proc cmdline. Open: `printf` blank line makes check vacuous; `$`, `*`, backtick case still missing; pgrep fragile (S9-M2, M3) |
| S9-B2 PYTHONPATH_SURVIVES with package append | Resolved in form (launch 2, td_scripts append). Open: tests inherited env not hook-set PYTHONPATH; clash fix circular (S9-B2, S6-N10) |
| S9-B3 Spike artifacts printed | Resolved in form. New: they cannot run as written (env/PATH/config, build semantics, order) (S9-B1, M4, M5) |
| S9-B4 Step 6 hook route / REVERT_CHECK last | REVERT_CHECK now last (resolved). Hook route declared separate spike but feature range still says "compared in gate" (S5-M3, S8-M4, S7 D-M5). New: P0a stop strands variant (S6-M12, S9-M7) |
| Gate gaps (default row, predicates, `ok-args-lost`, `not measured`) | Partly. Table exists with `unmeasured`, but row 1 lists 7 fields, row 3 unreachable, no ENV_LEAKS/ARGS_QUOTING rule (S9-B2) |
| Alt A rule / `REZ_CONFIG_FILE` path | Open: Step 9 still has no config (S9-M6, S8-M3, S6-M9, D-M4) |
| PLUGIN_OFF_OFFICIAL mapping, "no candidate" | Open and now Blocker (S9-B3) |
| Wrapper safety (array read, reject `-`, scrub, timeout) | Resolved in form. Open: no test step for error paths; timeout doubles resolve; `REZ_ENV` inherited (S9-M9, S5-M4) |
| Distribution, publish enforcement | Open (D-M3, S6-M5) |
| NAS root origin | New (D-M2, S6-M6) |
| Scope trim (LOCAL_ROOT/CUJ 4, A-H, carry-overs, non-gate fields) | Open (S8-M5, M1; N: A-H, L199) |
| Clarity: link Phase 0 anchors, terms, status line, "guaranteed" | Open: status still says "round 2"; tokens unlinked; "guaranteed" remains (S6-M2, Sy-M1, D-M9) |
| Fill NAS/Ayon-version fields | Open (St-M1, S9-M11) |
| Isolate Ayon test variant | Open: no dev-variant definition or procedure (S6-M4, S9-M8) |

## Consolidated actions

### Blockers
1. **Spike environment (S9-B1).** Add one exported preamble in Step 5 (PATH to rez, absolute `REZ_CONFIG_FILE`, `STUDIO_REZ_NAS_ROOT`, `REZ_DISABLE_HOME_CONFIG=1`, `mkdir -p $HOME/rez/repo`); reorder bind, build `maya`, build `td_scripts`, then `OS_STRING`; give the literal rez install command.
2. **Gate as a total function (S9-B2).** Pass 1: any `unmeasured` (all fields, including `ARGS_QUOTING`, `ENV_LEAKS`, `REZ_PYTHONPATH_CLASH`) means Stop; handle P0a `rejected` before it. Pass 2: no-go rows. Pass 3: accumulate all "go with ..." edits. Add `GO_DECISION`, rows for `ARGS_PASSTHROUGH_AYON`, `ARGS_QUOTING`, `ENV_LEAKS`. Run the clash check and fix `probe_maya` before Step 8; name one fix.
3. **Plugin-off test (S9-B3).** Pre-check candidate install; use `cmds.loadPlugin(..., quiet=True)` in try/except; name the launch and imports; add `no-candidate` value and gate row.

### Majors (grouped)
- **Gate and Alt A/G:** decide Alt A (cut it, or test with `REZ_CONFIG_FILE`, and state it revises Goal 3/CUJ 3); reword Alt G as fallback; drop `ALT_G_NOTE` from required.
- **Measurement validity:** ENV_LEAKS from stub `env-before.txt` vs desktop-session baseline by name; args file with `$#`, known args via Ayon, add `$`/`*`/backtick quoting case; `pgrep -x -u`.
- **Spike build/config:** `build_command = False` for `maya`; quote and use `$REZ_BUILD_SOURCE_PATH`; verify the config loads (`rez-config packages_path`) and fail with a message; put spike files in `spike/` or delete at gate close; give commands/fields for Step 4 values, Ayon versions, NAS facts; `RESOLVE_TIME_NAS` no-NAS value.
- **Ayon operations and revert:** define "dev variant" and its procedure; absolute path in Step 8; revert on P0a stop and revert project-level override.
- **Safety-rule tests:** add Step 8.5 negative cases (bad `REZ_ENV`, `-x foo` preset, exported `REZ_PACKAGES_PATH`, unreachable root) with expected non-zero and stderr.
- **Design gaps:** `STDERR_VISIBLE` field and artist-visible failure; NAS root source (no inherited override in production); deployment, trust enforcement, distribution; add Ayon-native/env-fragment alternative; scale/latency ceiling and single resolve; value of narrowed in-house-only slice; soften "guaranteed" and `MAYA_SCRIPT_PATH` claim.
- **Scope trim:** reduce non-decisive fields; drop or justify `STUDIO_REZ_LOCAL_ROOT`/CUJ 4; move scripts out of design; single wrapper spec; remove probe exit codes.
- **Clarity:** link Phase 0 anchors; glossary and external links; rez install state at L9; shorten L199 and wrapper section; update status line; one term each for request/preset.

### Nits
Heading levels/casing, glossary layout, Risks level, P0/Phase 0 casing, wording items in `critic_report.md`, script details in `implementation_readiness_report.md`.

## Traceability matrix
| Action | S5 | S6 | S7 | S8 | S9 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| Spike env/order | | M10 | | | B1, M4, M5 |
| Gate total function | M2 | M11 | | | B2 |
| Plugin-off test | | M11 | D-M8 | | B3 |
| Alt A / Alt G | M3 | M9 | D-M4, D-M5 | M3, M4 | M6 |
| Measurement validity | | N9, N10 | | | M1, M2, M3 |
| Revert/variant procedure | | M4, M12 | | | M7, M8 |
| Safety-rule tests | M4 | M7 | D-M9 | M6 | M9 |
| Design gaps (stderr, NAS root, trust, scale) | M5 | M5, M6 | D-M1, D-M2, D-M3, D-M6, D-M7 | | |
| Scope trim | M1, M5 | M8 | | M1, M2, M5 | M10 |
| Fields/commands missing | | | St-M1 | | M11 |
| Clarity/status/links | | M1, M2, M3 | St-M3, Sy-M1..3 | | |

## Not checked
- No behavior of Ayon 1.6.3, ayon-core 1.9.12, rez, or Maya 2026 verified (arg quoting, `parent_variables`, `REZ_DISABLE_HOME_CONFIG`, `rez-build` custom builds, `--input/--output`, `pgrep`//proc names, Maya launcher env, mtoa availability, stderr visibility in Ayon).
- No second independent instance of any reviewer; no codebase or external docs consulted; no reuse search (no code in repo).
- Round-3 resolution was judged by reviewers and this synthesis from text, not line-by-line audit.
