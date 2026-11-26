# Stage 8: Intermediate Zoom Out (round 4)

**Target:** `docs/designs/rez-maya-2026-ayon.md`, whole file (462 lines). Nothing run; rez/Ayon/Maya claims unverified. No reuse search (no code).

**Verdict:** 0 Blocker, 6 Major, 7 Nit. Round 3 re-scope (P0a/P0b) done in form; Phase 0 still large for the question it answers, and feature/detailed ranges disagree in places.

## Major
1. **Phase 0 disproportionate (L272-433; also 9, 185-199).** 11 steps, ~35 fields; fields that decide nothing or only a fallback: `RESOLVE_TIME_*`, `REZ_BIND_OPTION`, `REZ_INPUT_FORM`, `PARENT_VARIABLES_KEY`, `NO_LOCAL_BEHAVIOR`, `OS_STRING`, `LICENSE_MECHANISM`, `ROCKY_VERSION`, `MAYA_BUILD`, `ALT_G_NOTE`. Keep decision fields; or promote spike files (drop "not promoted") so P1-P3 harden rather than rewrite. P0a is proportionate.
2. **Wrapper specified twice (L9, 124-132, 276, 457).** `probe_maya` already uses exit codes 64/66/67 though L199 says tests assert only non-zero+stderr. State once; remove codes.
3. **Alt A rule contradicts itself (L130, 211, 407, 450).** Step 9 has no `REZ_CONFIG_FILE`; A gives up the git preset (Goal 2's mechanism). Cut A/Step 9 or specify with config.
4. **Alt G out of proportion (L243-247, 326, 411, 443).** Feature says compared at gate; detailed says not executed. Reword as fallback; drop `ALT_G_NOTE` from required.
5. **CUJ 4 / `STUDIO_REZ_LOCAL_ROOT` speculative (L88-92, 140, 165, 177, 336-340).** Local-first already repoints NAS root; remove. Raised in round 3, kept unjustified.
6. **Script-level detail in design (L132, 136, 371-388).** Keep contract; scripts to `tests/`.

## Nit
Stale status; A-H duplicates (L203); L199 carry-overs belong to P1 plan; P0a gate is pass/fail on one field, say so; `env -i bash -lc env` noisy and unmarked unverified (L320); `$HOME/rez/repo` doubles as NAS stand-in; `/tmp/ctx.rxt` vs logs dir.

## Feature vs detailed agreement
Agree: Goals 1-3 to fields; Open Questions to fields. Disagree: wrapper spec, Alt A, Alt G, "specified in detail" claim.

## Not checked
Ayon/ayon-core executable handling, `REZ_DISABLE_HOME_CONFIG`, `parent_variables`, Maya env rewriting, `rez-bind` option; no second instance.
