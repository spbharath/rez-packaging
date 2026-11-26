# Stage 5: Initial Zoom Out (round 4)

**Target:** `docs/designs/rez-maya-2026-ayon.md`, whole file (462 lines; heading "## Detailed Implementation Plan" at line 255). Nothing was run; all rez/Ayon/Maya claims are unverified. No code reuse search (no code in repo).

**Verdict:** Pass with Majors. 0 Blocker, 5 Major, 6 Nit. Sound minimal fit (one wrapper, one-line preset, gated spike), but spike and wrapper are over-specified and some gate rules conflict.

## Major
1. **Altitude drop (L280-310, 334-388).** Full shell scripts and package bodies in the design; L276 says spike files are not promoted, yet `probe_maya` and `rezconfig.py` are near-final. Written twice, can drift. Move to `tests/` or drop the "not promoted" rule.
2. **Gate table (L441-448).** `ARGS_QUOTING`, `REZ_PYTHONPATH_CLASH`, `ENV_LEAKS`, `PROJECT_OVERRIDE`, `ARGS_PASSTHROUGH_AYON` absent from the unmeasured-stop row; L454 says none may be unmeasured. Use one rule "all fields measured"; reword the clash case as "go after fix retested".
3. **Alt G promise (L243-247, 326, 411).** "Compared in the P0 gate" but not executed; only a "not tested" note. Call it a documented fallback.
4. **Wrapper contract (L126-132).** Six safety rules in baseline; the `timeout` pre-resolve doubles resolve cost before `RESOLVE_TIME_NAS` is known; `timeout` cannot wrap a long-running Maya under `exec`.
5. **Repo-root source of truth (L165, 380, 177).** `STUDIO_REZ_NAS_ROOT` repointed to local, plus `STUDIO_REZ_LOCAL_ROOT`; the latter serves only CUJ 4 (YAGNI).

## Nit
Status line stale (L3); preset with multiple lines undefined behavior (L136); `pgrep -f maya.bin` may hit wrong process (L305); rez path repeated (L264, 381); acceptance A-H overlaps exit checks (L203, 454-457); Alt H is a layout decision, not an alternative (L249-253).

## Not checked
Context README (none); round-3 comparison; any external behavior.
