# Rez packages for Maya 2026, launched through Ayon

* **Author:** blazentamilgaming
* **Date:** 2026-11-26

## Overview

Ayon launcher 1.6.3 (ayon-core 1.9.12) starts Maya 2026 on Rocky Linux. Rez builds the environment Maya runs in. The rez request decides which plugins, scripts and shelves load, so official and custom plugins can be turned on or off without touching the Maya install. Rez and the package repository live on the NAS. A local repo on the Rocky test machine is used first.

Milestone: Ayon launches Maya 2026 inside a rez-resolved environment, and removing a package from the request removes its effect.

Nuke, 3DEqualizer and Silhouette come later. Rez packages are per tool, so this is not a dead end.

Vocabulary used here, because "plugin" means four things:
* **Rez package**: a versioned folder with a `package.py`.
* **Maya plugin**: a `.so` or script that Maya loads.
* **Maya module**: a folder Maya finds through `MAYA_MODULE_PATH`, usually with a `.mod` file.
* **Ayon addon**: code the Ayon server delivers in a bundle (ayon-core, ayon-maya).

## Analysis

The review lenses did not check Ayon, rez or Maya docs. Every claim marked "verify" is from memory.

**Where reviewers agreed**

1. **Launch through one wrapper script.** Set the Maya executable in the Ayon applications addon to one script, called by absolute path and kept in git. The script ends with `exec rez-env <request> -- maya "$@"`. A multi-word command in the settings field may fail Ayon's path check or quoting (verify).
2. **The rez request is the on/off switch.** A context file (`.rxt`) is a frozen resolve. It suits reproducing a pinned session, not daily toggling. Ayon settings should hold only a preset name or one variable (for example `STUDIO_REZ_REQUEST`), which the wrapper reads and falls back from. That gives per-project and per-task overrides without a second plugin list.
3. **One layout, two roots.** The NAS is the source of truth and released versions never change. The local repo uses the same layout. Set the root in `rezconfig.py`. On the test machine, put the local repo first in `packages_path` and the NAS second. Rez's `package_cache` may replace a manual mirror (verify option names for the installed version).
4. **Small first scope.** A thin `maya-2026` package that points at the existing install (verify path, usually `/usr/autodesk/maya2026`) and does not copy Maya. One trivial test package (`pix_hello`) that sets an env var and prints from startup. Then mtoa, Yeti and in-house tools, one per cycle.
5. **Vendor `.mod` files stay as shipped.** Each vendor plugin package appends its module folder to `MAYA_MODULE_PATH`. In-house tools without a `.mod` set `MAYA_SCRIPT_PATH`, `MAYA_PLUG_IN_PATH`, `PYTHONPATH` and `XBMLANGPATH` directly. Check vendor `.mod` files for hard-coded absolute paths.

**Unresolved or contested**

* **ayon-maya: decided, outside rez.** Ayon delivers ayon-core and ayon-maya as server addons. Rez does not package them.
* **Who owns Maya startup (`userSetup.py`)?** With ayon-maya outside rez, Ayon's prelaunch hook owns it. A second `userSetup.py` on the path means only the first runs, so in-house rez packages must not ship their own. They expose a function that Ayon's startup or a TD calls.
* **Disabling official plugins.** Maya scans the default Autodesk module folders and user module folders. Leaving mtoa or Bifrost out of the rez request may not stop them loading. Disabling may also need plugin preference control or a clean `MAYA_APP_DIR` per launch. Test this early, because it goes to the stated goal.
* **Shelves: decided, out of scope.** Artists keep Maya's normal shelf behavior. The only shelf content wanted is TD scripts, which rez packages deliver by adding their script folders to `MAYA_SCRIPT_PATH` and `PYTHONPATH`. No shelf management, no `MAYA_APP_DIR` changes.

**Risks**

*Blockers*
* Ayon may not accept a multi-word executable. Spike this first and record the exact working value.
* Editing the executable in server settings affects everyone in that settings scope. Use a dev or staging variant or project override, and record the original value for rollback.
* Launch failures are silent because Ayon detaches the child. The wrapper must write a timestamped log, show a visible error and exit non-zero if `rez-env` or the NAS is missing.
* The plugin switch needs one named owner and location.

*Major*
* **Environment leakage.** Ayon's frozen launcher may leak `PYTHONPATH`, `PYTHONHOME` or `LD_LIBRARY_PATH` into Maya. Rez prepends to parent values unless config resets them. Compare an `env` dump before rez, after rez and inside Maya. Ayon's own project and task variables must still arrive.
* **Python ABI.** Maya 2026 ships Python 3.11. Compiled dependencies reaching Maya through Ayon's `PYTHONPATH` must match. Do not require rez's own Python in the Maya package.
* **Rez findability.** Install rez at a fixed absolute path visible to the Ayon-launched process, not only in a shell profile. Use the official `install.py`. Rez on the NAS bakes in a Python interpreter path, so every host needs the same one.
* **Drift.** Never edit a released version. Pin versions in production requests. Fix package names and one canonical NAS mount path early, because they end up in Ayon settings.
* **Vendor builds and licenses.** mtoa and Yeti are tied to exact Maya 2026 builds. Put license variables in packages and confirm Linux builds exist.
* **NAS dependence.** Every launch depends on the NAS. State an availability assumption and a launch-time budget (for example, resolve under 10 seconds). Measure before adding caching.
* **Observability.** Log the request, `REZ_RESOLVE`, repo paths, resolve time, and a saved context.
* **Version matrix.** Record Ayon launcher 1.6.3, ayon-core 1.9.12, Maya 2026 and the rez version.

*Minor*
* Test a scene path with a space.
* Check the `rez-env` flag that skips shell startup files.
* Run `rez-bind platform arch os` once and check the Rocky OS string.
* Add `.gitattributes` with `eol=lf` and keep Windows paths out of `package.py`.
* Decide how files move from this Windows folder to Linux. A git repo is the suggested route.

## Goals vs. Non-Goals

* **In-Scope Goals:**
  * Install rez on Rocky Linux at a fixed path.
  * A `maya-2026` package and a `pix_hello` test package.
  * A wrapper script that Ayon calls, with logging and visible errors.
  * One agreed plugin on/off mechanism, shown working.
  * A dev Ayon settings variant pointing at the wrapper, with a rollback.
  * Local repo first, then the same flow against the NAS.
* **Out-of-Scope Non-Goals:**
  * Nuke, 3DEqualizer and Silhouette packages (later).
  * Copying Maya or vendor installers into rez.
  * Rewriting `.mod` files or writing a `.mod` generator.
  * CI, build and release tooling, and a GUI.
  * Migrating existing artist Maya prefs.
  * Packaging ayon-core or ayon-maya in rez.
  * Managing shelves beyond making TD scripts importable.

## Key Decisions & Staging for Next Steps

**Decided so far**
* Rez and packages live on the NAS. Testing starts on a local repo on Rocky.
* Ayon launches Maya through addon settings and rez builds the environment.
* Maya 2026 Linux is already installed.

**To decide**
1. Wrapper script in the executable field (recommended by reviewers) or another mechanism.
2. Switch design: preset name in git, or `STUDIO_REZ_REQUEST` set in the Ayon app variant.
3. ~~ayon-maya~~ decided: Ayon only.
4. ~~`userSetup.py` owner~~ decided: Ayon's hook.
5. ~~Shelves~~ decided: ignored; TD scripts only.
6. First plugins after `pix_hello` (mtoa, Yeti, in-house).
7. NAS mount path, who publishes, and the release flow.

**Order of work**
1. Launch Maya through Ayon without rez and record the baseline env, Maya path, Python version and the way Ayon runs the executable.
2. Install rez at a fixed path and sanity check it.
3. Create the local repo and set `packages_path`.
4. Write `maya-2026` and hand-test `rez-env maya-2026 -- maya -batch ...`.
5. Add `pix_hello`.
6. Point a dev Ayon settings variant at the wrapper.
7. Run the acceptance checks below.
8. Repeat against the NAS repo.
9. Add a TD scripts package, then mtoa, then Yeti.

**Acceptance checks**
* A. Maya starts from Ayon and the Ayon log shows the rez command.
* B. `REZ_RESOLVE` inside Maya lists the expected packages.
* C. `MAYA_LOCATION` matches the baseline.
* D. Removing `pix_hello` from the request removes its effect. Adding it back restores it.
* E. Ayon's own env variables survive.
* F. A bad request shows a visible error.
* G. Checks A to D pass with both the local and the NAS repo.
* H. Reverting the Ayon setting restores the old behavior.

**Suggested repo layout (one git repo)**
`packages/<name>/<version>/package.py` (flat), `config/rezconfig.py`, `bin/` (wrapper), `presets/`, `bootstrap/`, `docs/`, `tests/`. Released packages stay out of git: build with `rez-build --install` to a local release dir, test, then release to the NAS.
