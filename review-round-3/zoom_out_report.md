# Stage 5: Initial Zoom Out (Round 3)

**Target:** `docs/designs/rez-maya-2026-ayon.md`, lines 1-249. Reviewer: `egm-zoom-out`. Nothing was run; rez/Ayon/Maya behavior is unverified. No reuse search (repo has no code).

Counts: Blocker 0, Major 4, Nit 6. Context sufficiency passes.

## Major
1. **Wrapper extras are speculative (L125-129, L194).** Log file, `--output/--input` two-step and exit codes are gated on spike need, which is good, but they sit in the architecture section. Replace with one line: "no extras until the spike records a need".
2. **Two-variable repo root is more than slice 1 needs (L135-137, L162, L91, L173).** L162 already shows local-first testing works by pointing `STUDIO_REZ_NAS_ROOT` at a local folder. `STUDIO_REZ_LOCAL_ROOT`, CUJ 4 and the stale-shadow risk exist only for TD shadowing. Defer, or say why rez's native `--paths`/`REZ_PACKAGES_PATH` (unverified) is not enough. The stderr warning also sits awkwardly with "wrapper passes no repository flags".
3. **Alternative A has no way to find the config (L129, L206).** Without the wrapper nothing exports `REZ_CONFIG_FILE`. Say how rez finds the config under A, or the "A wins" claim is overstated.
4. **Package-level detail for P1-P3 before the gate (L138-146, L194).** Conventions and carry-overs contradict "only Phase 0 is specified". Keep architecture-relevant conventions only; move carry-overs to a backlog pointer.

## Nit
1. L198 acceptance checks A-H restate goals and P3-P5 exit checks.
2. L105/L61 leak candidates written into the diagram as step 2; mark as unverified.
3. L131-133 preset parsing is code-level detail; one sentence is enough.
4. L238-242 Alternative G status ("not a post-failure fallback") conflicts with its own con ("needs a second mechanism").
5. L168/L66 speculative follow-up designs and first-plugin question.
6. L3 status still says "round 2".

Strengths: small scope, explicit fail-closed, official-plugin disabling treated as measured, gate keeps build-out behind evidence.
