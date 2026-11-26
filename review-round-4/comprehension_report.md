# Stage 6: Comprehension (round 4)

**Target:** `docs/designs/rez-maya-2026-ayon.md`, whole file (462 lines). Nothing was run; all rez/Ayon/Maya claims unverified.

**Verdict:** 0 Blocker, 12 Major, 12 Nit. Feature story is followable; all five standard elements present; Phase 0 tokens are defined at L413-433. Majors are mostly execution-reading gaps.

## Major
1. L9 vs L39/L274/L278: rez "installed" vs "install it" vs "no rez installed". State rez is absent until Step 5.
2. L57 and feature-range tokens (L59-62, 140, 171-176, 211): pointer to definitions not a link; anchor "Spike fields and allowed values" and "Go/no-go gate".
3. No external links or glossary for rez-env/-bind/-build/-config, `.rxt`, `parent_variables`, `REZ_RESOLVE`, `--input/--output`, Ayon bundle/variant/prelaunch hook; Step 5 "clone it" has no URL.
4. "Dev variant" undefined (L43, 176, 183, 312); rollout depends on it.
5. Distribution of wrapper/config/preset to artist machines unaddressed (L21, 179); absolute path needed by Ayon. Carry-over from round 3.
6. Source of `STUDIO_REZ_NAS_ROOT` value in the final wrapper unstated (L103-106, 140, 165; only probe has a default L380).
7. L132 "each tested in the spike" but no step/field exercises the safety rules.
8. L199 carry-overs opaque ("from review", "installer", `sudo`).
9. Alt A understated (L130, 211): loses stderr message, timeout, scrub, config; Step 9 (L407) runs it without `REZ_CONFIG_FILE`.
10. Step 7 (L392-398) assumes unstated setup: PATH to rez, `REZ_CONFIG_FILE`, `STUDIO_REZ_NAS_ROOT`.
11. Gate logic: `rejected` makes P0b fields unmeasured so row 1 beats row 3; row 1 lists 7 fields vs L274; `ENV_LEAKS` has no row; no value for "no official plugin installed" (L405).
12. Stranded state: P0a `rejected` leaves variant on stub; revert is in P0b Step 10; L456 still requires `REVERT_CHECK`=pass.

## Nit
Status line stale; P0/Phase 0 and "first slice/milestone", "baseline" (two meanings) shorthand; "resolve step" vs "resolve check"; `parent_variables`/`rez-bind`/`--input` explained late or never; `REZ_RESOLVE` set by rez not stated; L66 ambiguity (Maya vs mtoa availability); `MAYA_PLUG_IN_PATH` unexplained; `timeout 30` vs "budget from measurement" and probe exit codes vs "distinct exit codes optional"; `printf '%s\n' "$@"` writes a blank line with zero args so "non-empty" is vacuous (L297, 317); Step 8 dummy `PYTHONPATH` tests inherited env not the hook's; Step 6 `maya` has no build system, `rez-config packages_path` may not reveal added local path, `ARGS_QUOTING` measured twice, `MAYA_PATH` recorded after stub hard-codes it, empty `ENV_LEAKS` indistinguishable from unmeasured (all unverified); unverified claims: Python 3.11, `REZ_DISABLE_HOME_CONFIG`, rez path, `maya.bin`.

## Not checked
Nothing run; no external docs.
