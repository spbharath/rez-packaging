# Stage 9: Implementation Readiness (Round 3)

**Target:** lines 250-381 (Phase 0). Reviewer: `egm-implementation-readiness`. Nothing run; all rez/Ayon/Maya behavior unverified.

Counts: Blocker 4, Major 7, Nit 6. Verdict: Phase 0 cannot be executed as written.

## Blocker
- **B1. `ARGS_PASSTHROUGH` measured at the wrong point (L299, L327, L353).** `probe_maya` logs args before `rez-env` runs, proving only Ayon-to-script. Measure at `maya.bin` (e.g. `/proc/<pid>/cmdline`), add a spaces case, name the reference launch args (L312).
- **B2. `PYTHONPATH_SURVIVES` cannot fail in launch 1 (L327, L351).** Preset `maya-2026` touches no `PYTHONPATH`; survival depends on `parent_variables` (unverified). Measure in launch 2 with the config applying `PARENT_VARIABLES_KEY`.
- **B3. Spike artifacts left to the implementer (L304, L316, L325).** Content of `config/rezconfig.py`, scratch config (format, `$HOME` expansion), `maya` and `td_scripts` `package.py` (and module layout), `--output/--input` semantics, and the unnamed "candidate" `parent_variables` key. Print each in full.
- **B4. Step 6 (Alt G hook) not executable (L333).** Hook location, deployment, how Maya starts under rez, comparison contents unspecified; `REVERT_CHECK` (Step 5) can be stale after Step 6. Specify or mark out of P0 scope; move revert last.

## Major
- **M1. `ENV_LEAKS` has no decision rule (L312).** `env -i bash -lc env` makes every Ayon variable look like a leak; Maya's launcher rewrites variables. Diff stub env vs login shell against a suspect allowlist; use it in the gate.
- **M2. Gate gaps (L361-368).** `ok-args-lost` + `ARGS_PASSTHROUGH=yes` matches no row; `not measured` has no row; "any `no`" ambiguous; row 3 retest has no step; row 4 retest not an exit condition; `rejected` likely arises only for Alt A's multi-word command. Add default no-go row and boolean predicates.
- **M3. `PLUGIN_OFF_OFFICIAL` undefined mapping (L329).** Which preset; how `pluginInfo` and `MAYA_MODULE_PATH` signals map to absent/present; neither plugin installed.
- **M4. Alt A test false negative (L331).** `REZ_CONFIG_FILE` not in Ayon's env; `$REZ_ENV` depends on launching shell; "or edited into the script" is a choice left open.
- **M5. Paths and Ayon variant underspecified (L252, L306, L325).** Executable field needs an absolute path; repo location, variant name, settings field not given; `PROJECT_OVERRIDE` tried at project level before blast radius known.
- **M6. Field coverage (L46, L64, L66, L343, L316, L323).** No field for Ayon/ayon-core versions or NAS facts; "How measured" blank for several fields; no mapping for `NO_LOCAL_BEHAVIOR`; NAS timing needs packages on NAS; single timing run.
- **M7. Step 2 nondeterministic (L314).** "Newest tag" has no source, no `install.py` invocation, sudo/HOME unhandled; binding platform/arch/os not shown to be needed.

## Nit
Unquoted `$(cat preset)` and unset `REZ_ENV` guard (L301); `env | sort` multi-line mangling and blank-arg ambiguity (L279, L288); `pgrep` race and self-match (L309); `/tmp/ctx.rxt` outside log dir (L319); Step 0 omits `docs/spike-results.md`, rezconfig, preset, logs dir creation; `PLUGIN_OFF_TD` "How measured" reads as definition (L349).
