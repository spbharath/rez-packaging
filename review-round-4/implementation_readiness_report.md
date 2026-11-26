# Stage 9: Implementation Readiness (round 4)

**Target:** `docs/designs/rez-maya-2026-ayon.md`, DetailedRange 255-462 (lines 1-254 for context). Nothing run; all rez/Ayon/Maya/pgrep//proc behavior unverified.

**Verdict:** Not ready to execute. 3 Blocker, 11 Major, 7 Nit.

## Blocker
- **B1 Steps 5-7 run rez with no environment; order circular (L330, 367, 392-398).** No PATH to rez; `rezconfig.py` needs `STUDIO_REZ_NAS_ROOT` (KeyError otherwise, L338) but only `probe_maya` exports it; `rez-build`/`rez-config`/`rez-env` commands set no `REZ_CONFIG_FILE`; `td_scripts` requires `maya-2026` so build order matters; `$HOME/rez/repo` never created; `NO_LOCAL_BEHAVIOR` measured with home config possibly active. Add exported preamble to Step 5, reorder (bind, build maya, build td_scripts, then OS_STRING), give literal rez install command.
- **B2 Gate does not cover all combinations; one row circular (L274, 326, 441-448).** Row 1 lists 7 fields vs L274/L454; row 3 unreachable (P0a stop leaves fields unmeasured); first-match-wins drops cumulative edits (e.g. SURVIVES=no plus OFFICIAL=present); `REZ_PYTHONPATH_CLASH`=yes makes `probe_maya` exit 67 before Step 8, so row 6 is never reached; the clash fix is a left-open design choice (and unsetting PYTHONPATH defeats `parent_variables`); no rows for `ARGS_PASSTHROUGH_AYON`, `ARGS_QUOTING`, `ENV_LEAKS`; `GO_DECISION` not in field table; several fields lack `unmeasured`.
- **B3 `PLUGIN_OFF_OFFICIAL` test cannot distinguish off from not-installed/not-autoloaded (L405).** Default Autodesk module folders are not in `os.environ["MAYA_MODULE_PATH"]`; `pluginInfo` on unknown plugin may raise; no imports; launch not named; "no candidate" unspecified. Use `loadPlugin` try/except, pre-check install, add `no-candidate`.

## Major
1. `ENV_LEAKS`/`AYON_PYTHONPATH` measured at maya.bin (after Maya's own launcher may alter env); stub's `env-before.txt` unused; `env -i bash -lc env` baseline omits DISPLAY/HOME etc. so "empty" is unreachable (L319-320, 306).
2. `args-stub.txt` never empty (`printf '%s\n'` blank line); `ARGS_PASSTHROUGH` may be vacuous; quoting test lacks `$`, `*`, backtick (round 3 `$` case still open) (L297, 317, 404).
3. `pgrep -n -f maya.bin`: regex dot, newest match may be child/other user; use `-x -u` (L305).
4. Step 6 builds: `maya` has no build_command/build system; `cp -r python` relative and unquoted; install path may not exist; "copy by hand" fallback undecided (L345-367).
5. Spike config may not load (module objects/underscore names; raw KeyError instead of readable message) (L337-343).
6. Step 9 Alt A runs without config; fails for wrong reason (L407; round 3 item open).
7. P0a stop leaves variant on stub; Step 10 never runs; Step 1 project-level override not reverted (L326, 409, 312).
8. Ayon operations underspecified: no dev-variant procedure, UI path, save/refresh; Step 8 uses relative `tests/probe_maya` vs absolute in Step 2 (L312-314, 400, 408).
9. Safety rules "each tested" but no negative-case step/field (option injection, empty preset, missing rez-env, timeout, `set -f`, `REZ_PACKAGES_PATH`, unreachable NAS); CUJ 3 never exercised (L132).
10. Spike files at final P1-P3 paths despite "not promoted" (L276, 334-369, 457); use `spike/` or delete at gate close.
11. Fields without commands; no fields for Ayon/ayon-core versions (L46) or NAS facts (L64); `RESOLVE_TIME_NAS` has no "no NAS" value; Step 4 after hard-coded `/usr/autodesk/maya2026` (L324, 417, 428, 454).

## Nit
`PARENT_VARIABLES_KEY` meaningless (key is by definition `parent_variables`; use supported/unsupported); entry-wise colon-split matching for 8.3; `probe_maya` inherits `REZ_ENV`, `read` on missing file mislabels, CRLF/blank-first-line untested; name rez-bind install option; `/tmp/ctx.rxt` and single cold `time`; Alt G wording vs L247; define PLUGIN_OFF_TD pass precisely.

## Not checked
`parent_variables`, rez-build custom build semantics, `--input/--output`, `--` quoting, Maya launcher env. Feature range not reviewed here.
