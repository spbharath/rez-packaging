# Rez packages for Maya 2026, launched through Ayon

> **Author:** blazentamilgaming | **Status:** Draft (round 4 review fixes applied) | **Date:** 2026-11-26

--------------------------------------------------------------------------------

## Overview

Ayon launcher 1.6.3 (ayon-core 1.9.12) starts Maya 2026 on Rocky Linux. Rez builds the environment that Maya runs in. The rez request names the packages, and those packages decide which plugins and TD scripts Maya can see. Rez is installed on the test host at a fixed path. The package repository lives on the NAS; the first tests use a repository folder on the Rocky test machine with the same layout. Several facts about Ayon, rez and Maya are unmeasured, so Phase 0 (a spike with a go/no-go gate) comes before any build-out. Only Phase 0 is specified in detail; Phases 1 to 5 are specified after the gate passes.

The first milestone covers Maya 2026 only. Nuke, 3DEqualizer and Silhouette follow the same pattern later.

Terms used in this document:

*   **TD**: technical director, the person who maintains the pipeline. **DCC**: a content-creation application such as Maya. **NAS**: the shared network storage. **CUJ**: critical user journey.
*   **Rez package**: a versioned folder with a `package.py` file.
*   **Maya plugin**: a `.so` file or script that Maya loads. **Maya module**: a folder that Maya finds through `MAYA_MODULE_PATH`, usually described by a `.mod` file.
*   **Ayon addon**: code the Ayon server delivers in a bundle, such as ayon-core and ayon-maya.
*   **Request**: the list of packages given to `rez-env`, such as `maya-2026 pix_hello`.
*   **Preset file**: the git file `presets/maya2026_default.txt`. Its single line is the **preset**, a saved request. It is the on/off switch for packages.
*   **Wrapper script**: the script `bin/maya2026_rez` (path relative to the repo root) that Ayon runs as the Maya executable.

## The Problem

Today the Maya environment is whatever the Ayon applications addon and the Maya install give it (the baseline is measured in Phase 0). There is no single place to say "this launch gets Arnold and the studio TD scripts, that launch does not". Adding or removing a plugin means editing the machine, the Ayon settings, or both. TD scripts and tools on the NAS have no versioned way to reach Maya.

Proposed solution: Ayon runs one wrapper script. The script calls `rez-env` with the request, and Maya starts inside the resolved environment. Changing the request changes what Maya can load. Packages live in a versioned repository, so a launch can be pinned and repeated.

## Goals

First-slice outcomes (these decide success of the first milestone):

1.  Launching Maya 2026 from Ayon runs the wrapper, and `REZ_RESOLVE` inside Maya lists the requested packages.
2.  Removing a package from the preset file removes its effect on the next launch, and adding it back restores it. This is guaranteed for packages delivered through rez (`pix_hello`, `td_scripts`). Whether it also holds for official Autodesk plugins is measured in Phase 0.
3.  If rez or the NAS is unavailable, the wrapper prints an error to stderr and exits non-zero, and Maya does not start.

Supporting goals:

*   Install rez on the Rocky test machine at `/opt/rez`, a fixed path the Ayon-launched process can find.
*   Create a `maya-2026` rez package that points at the existing Maya 2026 install and does not copy Maya.
*   Create a test package `pix_hello` that sets the variable `PIX_HELLO=1` and offers an importable function `pix_hello.say()`, to prove the switch without shipping a `userSetup.py`.
*   Deliver TD scripts through a package `td_scripts` that adds script folders to `MAYA_SCRIPT_PATH` and `PYTHONPATH`. It is checked end to end by importing it in Maya.
*   Point a dev variant of the Ayon applications addon settings at the wrapper script, with the original value recorded for revert.
*   Run the same flow against a local repository folder first, then the NAS, with the same layout and only the root path changed.
*   Record the tested version set (Ayon launcher, ayon-core, Maya build, rez tag, Rocky version) in the spike results.

## Non-Goals

*   Nuke, 3DEqualizer and Silhouette packages (later).
*   Packaging ayon-core or ayon-maya in rez. Ayon delivers them.
*   Shipping a `userSetup.py` from any rez package. Ayon's prelaunch hook owns Maya startup.
*   Managing shelves, shelf paths or `MAYA_APP_DIR`. Shelf content is TD scripts only.
*   Copying Maya or vendor installers into rez, or rewriting vendor `.mod` files.

## Open Questions

Each is measured in Phase 0 and recorded in `docs/spike-results.md` (field names in the Phase 0 section).

*   **Executable field**: does ayon-core 1.9.12 run the wrapper path and pass launch arguments through (`EXEC_FIELD_RESULT`)?
*   **Disabling official plugins**: Maya also scans its default Autodesk module folders, so leaving mtoa or Bifrost out of the request may not stop Maya from loading it (`PLUGIN_OFF_OFFICIAL`).
*   **Environment leakage**: Ayon's frozen launcher may pass `PYTHONHOME` or `LD_LIBRARY_PATH` into Maya (`ENV_LEAKS`). `PYTHONPATH` set by Ayon's prelaunch hook must survive (`PYTHONPATH_SURVIVES`).
*   **Rez facts**: which rez tag and Python install it, the `parent_variables` key, whether rez adds a local repository by itself, the `rez-bind` install option, and whether `--input` accepts `--`.
*   **Maya facts**: install path (usually `/usr/autodesk/maya2026`), Python (expected 3.11), license mechanism.
*   **NAS**: mount path, whether identical on every workstation, who publishes, locking and symlink support, resolve time over the NAS.
*   **Ayon settings scope**: can the executable be set per project, or only per variant (`PROJECT_OVERRIDE`)? This decides the blast radius of a test change.
*   **First plugins after `pix_hello`**: candidates mtoa, Yeti, in-house tools; Maya 2026 Linux availability unconfirmed.

## Critical User Journeys (CUJs)

### CUJ 1: Artist launches Maya from Ayon

*   **Given**: Ayon launcher 1.6.3 connects to a server whose Maya 2026 app variant points at the wrapper script, and rez and the package repository are reachable.
*   **When**: The artist launches Maya 2026 for a task.
*   **Then**: Maya opens. `REZ_RESOLVE` inside Maya lists the requested packages. Ayon's project and task variables (`AYON_*`) are present.

### CUJ 2: TD turns a package on or off

*   **Given**: Maya launches correctly with `pix_hello` in the preset.
*   **When**: The TD removes `pix_hello` from the preset file and relaunches Maya.
*   **Then**: The `PIX_HELLO` variable is gone and `import pix_hello` fails. Adding it back restores both. No machine or Maya install change was needed. (For official plugins the result depends on the Phase 0 test.)

### CUJ 3: Launch fails because rez or the NAS is missing

*   **Given**: The NAS is unmounted or `rez-env` is not at its fixed path.
*   **When**: The artist launches Maya from Ayon.
*   **Then**: The wrapper prints an error to stderr and exits non-zero. Maya does not start half-configured. (The design is fail-closed: it does not fall back to plain Maya, because that would give the artist a Maya without the studio tools and without notice.)

### CUJ 4: TD tests a new package locally before release

*   **Given**: A new or changed package is in the git repo on the Rocky machine.
*   **When**: The TD builds it into a local repository folder and exports `STUDIO_REZ_LOCAL_ROOT` in their own shell before running the wrapper or `rez-env`.
*   **Then**: That shell resolves the local version ahead of the NAS. Other machines and Ayon launches without that variable never see it. After testing, the TD releases the package to the NAS and never edits a released version.

## Technical Plan (Architecture)

Ayon code is unchanged; only the executable setting for Maya 2026 changes. Ayon's applications addon runs one executable, a wrapper script kept in git. Rez resolves a request against package repositories and starts Maya in the resulting environment.

```text
Artist -> Ayon launcher 1.6.3
            |  (applications addon: Maya 2026 executable = wrapper script)
            v
   bin/maya2026_rez  (wrapper script)
     1. read the preset and check rez-env exists; on failure: error on stderr, non-zero exit
     2. unset the leaked variables found by the spike (candidates: PYTHONHOME, LD_LIBRARY_PATH,
        REZ_PACKAGES_PATH); disable the home rez config
     3. export STUDIO_REZ_NAS_ROOT and REZ_CONFIG_FILE
     4. resolve check under timeout, then rez-env <preset> -- maya "$@"
     (safety rules and extras: see Wrapper script)
            |
            v
   rez resolves against packages_path (set only in config/rezconfig.py):
     [ local root: only when STUDIO_REZ_LOCAL_ROOT is set ] -> [ NAS root ]
            |
            v
   Maya 2026 starts with the environment from the packages
     maya-2026   : MAYA_LOCATION, PATH (existing install)
     pix_hello   : PIX_HELLO and an importable function
     td_scripts  : MAYA_SCRIPT_PATH, PYTHONPATH
     (later) mtoa, yeti, in-house tools: MAYA_MODULE_PATH or direct paths
   Ayon addons (ayon-core, ayon-maya) arrive from the Ayon bundle, outside rez.
   Ayon's prelaunch hook owns Maya startup (userSetup.py).
```

### Wrapper script

One script per DCC version, `bin/<dcc><version>_rez` (first one `bin/maya2026_rez`). **Minimum contract** (the baseline): read the preset, scrub leaked variables, run `rez-env <preset> -- maya "$@"`, send errors to stderr, and exit non-zero on failure. The baseline can use `exec`; the extras below need the wrapper to stay alive after Maya starts.

Extras are added in Phase 3 only if the spike shows a need: a log file (if Ayon's launcher log does not capture stderr), a resolve step separate from the run with `--output` and `--input` (if a log of the resolved packages is wanted before Maya starts), and distinct exit codes. Each extra needs one recorded reason in `docs/spike-results.md`. The wrapper alone unsets variables; it does not set the repository search order (see Configuration ownership).

The wrapper is justified over placing the command directly in the Ayon field (Alternative A) by the environment scrub and the readable error. If the spike finds no leaks and Ayon passes the command through, Alternative A can replace the wrapper, at the cost of the preset file: the request then sits as fixed text in Ayon settings (see Alternative C). The author decides at the gate.

Safety rules for the wrapper (each tested in the spike's `tests/probe_maya`): `set -f` and no `eval`; read only the first line of the preset; reject any request word that starts with `-` (option injection); unset `REZ_PACKAGES_PATH` and set `REZ_DISABLE_HOME_CONFIG=1` so only `config/rezconfig.py` applies; run a resolve check under `timeout` so a hung NAS fails with a message instead of hanging the launch; quote `"$@"`.

### On/off switch

The preset file in git is the switch. A TD edits its single line, reviewed through git. Parsing rule: the file has one non-empty line; the wrapper reads the first line, treats it as space-separated request words (no quoting, no shell expansion), and fails if it is empty. A trailing newline is allowed. Ayon settings carry no package list and no override variable in the first slice. Per-project presets come later, if `PROJECT_OVERRIDE` shows Ayon can vary a setting per project.

### Configuration ownership

`config/rezconfig.py` is the only place that decides the repository search order and `parent_variables` (the variables, such as `PYTHONPATH`, that packages append to instead of replacing). It reads `STUDIO_REZ_NAS_ROOT` (required) and `STUDIO_REZ_LOCAL_ROOT` (optional, opt-in). The wrapper exports the two variables and `REZ_CONFIG_FILE`, passes no repository flags, and alone unsets leaked variables. If rez adds its own local packages path regardless of config (`NO_LOCAL_BEHAVIOR`), the config neutralizes it there.

### Package conventions

*   Rez names a package and a version separately. `maya-2026` in a request means package `maya`, version `2026` or any `2026.x`. The package points at the existing install and sets `MAYA_LOCATION` and `PATH`; it does not copy Maya. The `maya` package version is checked against the real build in the spike results.
*   Vendor plugin packages append their module folder to `MAYA_MODULE_PATH` and let Maya read the vendor `.mod`, after checking the `.mod` for hard-coded absolute paths.
*   In-house packages without a `.mod` set `MAYA_SCRIPT_PATH` and `PYTHONPATH` directly. Other variables are added when a real package needs them.
*   No package ships `userSetup.py`. A package that needs startup work exposes a function that Ayon's startup path or a TD calls.
*   Compiled Python dependencies must match Maya 2026's Python (expected 3.11).
*   Released versions are immutable. Production requests pin versions. Package names are lowercase with no per-DCC folder level.

### Repository layout

One git repo, in this folder. Released packages are not stored in git.

```text
rez-packaging/
  packages/<name>/<version>/package.py   source of every package, flat
  config/rezconfig.py                    packages_path, parent_variables
  bin/maya2026_rez                       wrapper script
  presets/maya2026_default.txt           the preset file (one line)
  tests/                                 spike and smoke scripts
  docs/                                  spike results (one document for the first slice)
```

Flow: edit in git, build to a local repository folder, test, then release to the NAS. Local and NAS repositories use the same layout, and only the root path changes. For local-first testing the wrapper runs with `STUDIO_REZ_NAS_ROOT` pointing at the local repository folder; the local root variable is only for a TD shadowing a package in their own shell.

### Risks and mitigations

| Risk | Impact | Mitigation |
| :--- | :--- | :--- |
| Official plugins load regardless of the request | The on/off goal holds only for in-house packages | Measured in P0 (`PLUGIN_OFF_OFFICIAL`). If it fails: scope shrinks to in-house packages. Likely follow-up designs: override `MAYA_MODULE_PATH`, scrub `MAYA_PLUG_IN_PATH`. |
| Ayon's environment leaks into Maya or is lost | Wrong libraries, or Ayon variables missing | `ENV_LEAKS` and `PYTHONPATH_SURVIVES` measured in P0 |
| Ayon's `PYTHONPATH` reaches rez's own Python, or a user rez config or `REZ_PACKAGES_PATH` overrides ours | `rez-env` breaks or resolves from the wrong repository | `REZ_PYTHONPATH_CLASH` measured in P0; wrapper unsets `REZ_PACKAGES_PATH` and disables the home config |
| NAS down or slow | Every launch fails (fail-closed) or waits | Error on stderr, non-zero exit. Resolve time recorded in P0; a budget is set from the measured numbers, not before. |
| Concurrent resolves at start of day, locking and symlink limits | Slow launches | Recorded as NAS facts in P0; revisit after P5 with real load |
| Ayon test change affects other users | Others get a broken Maya | Dev variant only, scope checked in P0 (`PROJECT_OVERRIDE`), revert steps in `docs/spike-results.md` |
| A stale local repository shadows the NAS | A pinned request resolves different bits | Local root is opt-in through `STUDIO_REZ_LOCAL_ROOT`; the wrapper logs a warning to stderr when it is set |

Trust model: `package.py` is Python that runs at resolve time, so write access to the NAS repository equals code execution on every artist machine. Artist machines mount the NAS read-only; only TDs publish. The preset file changes only through git review. The wrapper never evaluates the preset as shell code.

### Rollout and rollback

The Ayon change is made in a dev settings variant first. The original executable value and the settings scope are recorded before the edit. Reverting restores the old value and relaunches. The blast radius is whoever uses that variant (confirmed in P0).

### Phases and go/no-go gate

Each phase has an exit check. A phase starts only when the previous exit check passes. Phases 1 to 5 get a detailed plan only after the gate passes, so that the plan reflects measured results.

| Phase | Work | Exit check |
| :--- | :--- | :--- |
| P0a Spike, Ayon only | Stub script as Ayon executable, no rez | `EXEC_FIELD_RESULT` = `ok` |
| P0b Spike, rez | Install rez, throw-away packages and probe wrapper, plugin-off test | Go/no-go gate (outcome table) |
| P1 Bootstrap | Install rez at `/opt/rez`, `config/rezconfig.py`, local repository folder | `rez-env --version` and `rez-search` work from a clean shell |
| P2 Packages | `maya`, `pix_hello`, `td_scripts` built to the local repository | `rez-search` lists all three; hand-run `rez-env` resolves them |
| P3 Wrapper | `bin/maya2026_rez`, preset file, smoke test | First-slice outcome 3 and the switch (CUJ 2) pass from the smoke test |
| P4 Ayon | Dev variant points at the wrapper | First-slice outcome 1 passes with a GUI launch; revert works |
| P5 NAS | Repeat against the NAS repository, with a documented publish procedure | Outcomes 1 to 3 pass with the NAS |

Known carry-overs for P1 to P3 (from review): `rez-build --install` writes to `local_packages_path`, which the config must set; the P1 exit check needs the rez path on `PATH` or a sourced helper; the installer must not hard-code `python3`, must handle `HOME` under `sudo`, and must use the `rez-bind` option measured in P0; tests assert "non-zero exit and a message on stderr", not specific codes; each `package.py` is shown in full in the P2 plan.

### Acceptance checks after the gate

Once the first-slice outcomes pass, these checks extend coverage: (A) Maya starts from Ayon; (B) `REZ_RESOLVE` lists the packages; (C) `MAYA_LOCATION` matches the baseline; (D) switch off and on for `pix_hello`, `td_scripts` and one official plugin; (E) `AYON_*` variables and Ayon's `PYTHONPATH` entries survive; (F) bad request or missing NAS gives stderr and non-zero exit; (G) A to D pass with both local and NAS repositories; (H) reverting the Ayon setting restores the old behavior.

## Alternatives Considered

### Alternative A: Put `rez-env ... -- maya` directly in the Ayon executable field

*   **Pros**: No script to maintain. Everything is visible in Ayon settings.
*   **Cons**: Ayon may check the path exists or split the string itself, so a multi-word command may fail (`EXEC_FIELD_RESULT`). No place for an environment scrub or a readable error.
*   **Status: Test-only, decided by P0.** Tested in the spike. An Ayon field cannot read the preset file, so Alternative A means a fixed request typed into Ayon settings. If it works and `ENV_LEAKS` is empty, the author may choose it over the wrapper at the gate, accepting that the on/off switch moves from git to Ayon settings. Otherwise the wrapper stays.

### Alternative B: A rez context file (`.rxt`) as the on/off switch

*   **Pros**: A saved context reproduces an exact resolve.
*   **Cons**: It is a frozen resolve. Turning one package off means a new context file, and per-project variation needs one file per combination.
*   **Status: Rejected** for daily toggling. It may be used later to pin a production session.

### Alternative C: Keep the package list in Ayon server settings

*   **Pros**: One place Ayon admins know.
*   **Cons**: A second source of truth with no git history or review. Changes affect everyone in that settings scope.
*   **Status: Rejected.** Ayon holds only the script path.

### Alternative D: Package ayon-core and ayon-maya in rez

*   **Pros**: One mechanism for everything Maya loads.
*   **Cons**: Ayon already delivers these in a bundle. A second copy would drift from the bundle version and clash over `userSetup.py` ownership.
*   **Status: Rejected.** Ayon owns their delivery and Maya startup.

### Alternative E: Copy Maya and vendor plugins into rez packages

*   **Pros**: Packages do not depend on the machine install.
*   **Cons**: Large payloads on the NAS, licensing and installer questions, duplicates the installer.
*   **Status: Rejected.** `maya-2026` points at the existing install. Plugin payloads are installed by rez only where a vendor ships plain folders.

### Alternative F: A fixed NAS folder of Maya modules, no rez

*   **Pros**: Set `MAYA_MODULE_PATH` once in Ayon settings. Few moving parts.
*   **Cons**: No versions, no per-launch choice, no pinning, and no way to turn a plugin off for one project.
*   **Status: Rejected.** It does not meet the per-launch control goal.

### Alternative G: Resolve rez from an Ayon prelaunch hook that runs `rez-env` as a subprocess

*   **Pros**: Ayon already merges environment variables in prelaunch hooks, so Ayon's `PYTHONPATH` does not need a survive-the-wrapper test. A subprocess `rez-env` keeps rez in its own Python, so process isolation matches the wrapper.
*   **Cons**: The hook ships in an Ayon addon, so rez setup is coupled to an addon release. Failures appear inside the launcher rather than on stderr. Ayon must still start the real Maya executable under rez, which needs a second mechanism.
*   **Status: Compared in the P0 gate, not a post-failure fallback.** P0 records the executable field result (`EXEC_FIELD_RESULT`). If the wrapper route is no-go, the same plugin-off tests are repeated with a hook-based launch and the two are compared on coupling and failure visibility.

### Alternative H: A per-DCC folder level in the repository

*   **Pros**: Easy to browse by DCC.
*   **Cons**: Rez packages are per tool and a tool can be shared across DCCs, so a per-DCC level would duplicate shared packages.
*   **Status: Rejected.** A flat layout with one folder per package name serves Nuke, 3DEqualizer and Silhouette later.

## Detailed Implementation Plan

Only Phase 0 is specified. Behavior of rez, Ayon and Maya named here is unverified until the spike measures it. All paths are relative to the repository root on the Rocky machine unless absolute.

### Defaults (replaced by measured values at the end of P0)

| Item | Default |
| :--- | :--- |
| Rez install path | `/opt/rez` |
| Rez command | `/opt/rez/bin/rez/rez-env` (recorded as `REZ_ENV_PATH`) |
| Test repository | `$HOME/rez/repo` (same layout as the NAS repository) |
| NAS repository | `/nas/rez/packages` (placeholder) |
| Maya install | `/usr/autodesk/maya2026` |
| Log and dump directory | `$HOME/rez/logs` |

**Rule for spike values:** the commit that closes P0 replaces the defaults above with measured values and links `docs/spike-results.md`. Later phases copy values from that file by hand; no code parses it.

### Phase 0: Spike

Phase 0 has two parts. **P0a** answers the Ayon questions with a stub script and no rez installed. **P0b** installs rez and tests the on/off switch. P0b starts only if the P0a gate passes. Run on the Rocky machine and record every field in `docs/spike-results.md` as a table with columns Field, Value, Command used. Allowed values for each field are in the table after the steps. A field that is not measured is recorded as `unmeasured`, and the gate treats `unmeasured` as a stop.

The spike builds throw-away artifacts only (stub, probe wrapper, scratch config, two minimal packages). Final files for P1 to P3 are written after the gate, from the measured values; the spike files are not promoted.

#### P0a: Ayon only (no rez)

**Step 0. Create the files.**

`tests/env_dump.sh` (`chmod +x`): writes the sorted environment of its own process.

```sh
#!/bin/sh
# usage: env_dump.sh <label>
mkdir -p "$HOME/rez/logs"
env | sort > "$HOME/rez/logs/env-$1.txt"
```

`tests/stub_maya` (`chmod +x`): the Ayon executable before rez exists. It dumps its environment and arguments, then starts Maya.

```sh
#!/bin/sh
D=$(dirname "$(readlink -f "$0")")
"$D/env_dump.sh" before
{ printf 'count=%s\n' "$#"; printf '%s\n' "$@"; } > "$HOME/rez/logs/args-stub.txt"
exec /usr/autodesk/maya2026/bin/maya "$@"
```

`tests/capture_maya.sh <label>` (`chmod +x`): run by hand in a terminal while Maya is open. It reads the real Maya process, not a script.

```sh
#!/bin/sh
P=$(pgrep -n -x maya.bin || pgrep -n -f '/maya\.bin') || { echo "no maya.bin process" >&2; exit 1; }
tr '\0' '\n' < "/proc/$P/environ" | sort > "$HOME/rez/logs/env-maya-$1.txt"
# argv without argv[0], with a count line, in the same format as args-stub.txt
{ printf 'count=%s\n' "$(( $(tr -cd '\0' < "/proc/$P/cmdline" | wc -c) - 1 ))"
  tr '\0' '\n' < "/proc/$P/cmdline" | tail -n +2; } > "$HOME/rez/logs/args-maya-$1.txt"
```

(`maya.bin` as the process name is an assumption; if neither `pgrep` form finds it, use `ps -ef | grep -i maya` and adjust. An argument that itself contains a newline would be miscounted; the spike uses none.)

**Step 1. Settings scope.** In the Ayon settings UI, record `ORIGINAL_EXEC_VALUE`, `AYON_SETTINGS_PATH` and `PROJECT_OVERRIDE` (try setting the executable at project level in a dev project and say whether it is accepted).

**Step 2. Stub through Ayon.** Set the dev variant executable to the absolute path of `tests/stub_maya`. Launch Maya 2026 from Ayon (GUI). Run `tests/capture_maya.sh before`. Record:

*   `EXEC_FIELD_RESULT`: `ok` if Maya started through the stub, else `rejected` with the message.
*   `ARGS_PASSTHROUGH_AYON`: `yes` if `args-stub.txt` and `args-maya-before.txt` are identical (the count line and the arguments), else `no`. Record the count; if it is `count=0`, Ayon sent no arguments and the check only proves nothing is added.
*   `AYON_ENV_PRESENT`: names of `AYON_*` variables in `env-maya-before.txt`.
*   `AYON_PYTHONPATH`: the `PYTHONPATH` value in `env-maya-before.txt` (may be empty).
*   `ENV_LEAKS`: names in `env-maya-before.txt` that match `LD_*`, `PYTHON*` or `QT_*` and are absent from `env -i HOME="$HOME" bash -lc env | sort`. The list may be empty. Other differences are noted in the results but are not gate inputs.
*   `OFFICIAL_BASELINE`: with this stub launch (no rez), pick an official plugin (mtoa, else Bifrost) and run in the Script Editor `cmds.pluginInfo("mtoa", query=True, loaded=True)`. `loaded` if true, `installed-not-loaded` if the plugin exists but is not loaded, `not-installed` if Maya cannot find it.

**Step 3. Quoting.** From a terminal run `tests/stub_maya -batch -command 'print("a b $HOME"); quit -f;'`. Record `ARGS_QUOTING`: `ok` if Maya prints `a b $HOME` with the dollar sign literal, else `broken`.

**Step 4. Maya facts.** Record `MAYA_PATH`, `MAYA_BUILD`, `MAYA_PYTHON`, `LICENSE_MECHANISM`, `NAS_MOUNT`, `ROCKY_VERSION`.

**P0a gate.** Continue to P0b only if `EXEC_FIELD_RESULT` is `ok`. If `rejected`, stop: restore `ORIGINAL_EXEC_VALUE`, launch Maya once and record `REVERT_CHECK`, then write a separate spike for Alternative G (hook route) before anything else is built. If `ok`, leave the Ayon variant on the stub until P0b ends; `REVERT_CHECK` is then recorded in step 10.

#### P0b: rez and the on/off switch

**Step 5. Install rez.** Pick the newest released rez tag, clone it, run its `install.py` into `/opt/rez`. Record `REZ_TAG`, `REZ_PYTHON`, `REZ_ENV_PATH`, `OS_STRING` (from `rez-env platform arch os -- printenv REZ_RESOLVE`). Run `rez-bind --help` and record `REZ_BIND_OPTION`. Create `$HOME/rez/repo` and bind `platform`, `arch`, `os` into it with that option. This step runs with rez's default configuration, before any spike config exists.

**Step 6. Spike artifacts.** Create these by hand. They are unverified drafts that the spike tests. From here on, every rez command in a terminal runs after `. tests/spike_env.sh`, which `tests/spike_env.sh` (create it first) defines:

```sh
# usage: . tests/spike_env.sh   (run from the repo root)
export PATH="/opt/rez/bin/rez:$PATH"
export REZ_CONFIG_FILE="$(readlink -f config/rezconfig.py)"
export STUDIO_REZ_NAS_ROOT="$HOME/rez/repo"
export REZ_DISABLE_HOME_CONFIG=1
mkdir -p "$HOME/rez/repo" "$HOME/rez/logs"
```

(Adjust the `PATH` line to `REZ_ENV_PATH`.)

`config/rezconfig.py`:

```python
import os
_nas = os.environ["STUDIO_REZ_NAS_ROOT"]
_local = os.environ.get("STUDIO_REZ_LOCAL_ROOT")
packages_path = ([_local] if _local else []) + [_nas]
local_packages_path = os.path.expanduser("~/rez/unused_local")
parent_variables = ["PYTHONPATH", "MAYA_SCRIPT_PATH"]   # key name measured as PARENT_VARIABLES_KEY
```

`packages/maya/2026.0/package.py` (replace the path with `MAYA_PATH`):

```python
name = "maya"
version = "2026.0"
build_command = False
def commands():
    env.MAYA_LOCATION = "/usr/autodesk/maya2026"
    env.PATH.prepend("/usr/autodesk/maya2026/bin")
```

`packages/td_scripts/1.0.0/package.py`, with the payload folders `python/td_scripts/__init__.py` (one `def run(): print("td_scripts active")`) and `scripts/` (empty) beside it:

```python
name = "td_scripts"
version = "1.0.0"
requires = ["maya-2026"]
build_command = "cp -r python $REZ_BUILD_INSTALL_PATH/python && mkdir -p $REZ_BUILD_INSTALL_PATH/scripts"
def commands():
    env.PYTHONPATH.append("{root}/python")
    env.MAYA_SCRIPT_PATH.append("{root}/scripts")
```

Install `maya` first, then `td_scripts` (it requires `maya-2026`), with `rez-build --install --prefix $HOME/rez/repo` run in each package folder (if `REZ_BUILD_INSTALL_PATH` is not set by rez, copy the payload into the installed folder by hand and record that in the results).

`presets/maya2026_default.txt`: one line, `maya-2026` for the first launch, `maya-2026 td_scripts` for the second.

`tests/probe_maya` (`chmod +x`): temporary wrapper with the safety rules the final wrapper must follow.

```sh
#!/bin/sh
set -f
D=$(dirname "$(readlink -f "$0")")
unset PYTHONHOME LD_LIBRARY_PATH REZ_PACKAGES_PATH
export REZ_DISABLE_HOME_CONFIG=1
export REZ_CONFIG_FILE="$D/../config/rezconfig.py"
export STUDIO_REZ_NAS_ROOT="${STUDIO_REZ_NAS_ROOT:-$HOME/rez/repo}"
REZ_ENV=${REZ_ENV:-/opt/rez/bin/rez/rez-env}
[ -x "$REZ_ENV" ] || { echo "probe_maya: rez-env not found: $REZ_ENV" >&2; exit 64; }
read -r REQ < "$D/../presets/maya2026_default.txt"
[ -n "$REQ" ] || { echo "probe_maya: empty preset" >&2; exit 66; }
for W in $REQ; do case "$W" in -*) echo "probe_maya: bad request word: $W" >&2; exit 66;; esac; done
timeout 30 "$REZ_ENV" $REQ -- true || { echo "probe_maya: resolve failed or timed out" >&2; exit 67; }
exec "$REZ_ENV" $REQ -- maya "$@"
```

(`REZ_DISABLE_HOME_CONFIG` and `REZ_PACKAGES_PATH` are the rez variables believed to override or bypass the config; unverified.)

**Step 7. Rez facts.** Record:

*   `PARENT_VARIABLES_KEY`: run `REZ_CONFIG_FILE=config/rezconfig.py STUDIO_REZ_NAS_ROOT=$HOME/rez/repo rez-config parent_variables`; the key name if it returns the list, else `unsupported`.
*   `NO_LOCAL_BEHAVIOR`: with the config above, run `rez-config packages_path`. `config-only` if only the config's roots appear, `rez-adds-local` if the rez default local path is also listed.
*   `REZ_INPUT_FORM`: run `rez-env maya-2026 td_scripts --output /tmp/ctx.rxt`, then `rez-env --input /tmp/ctx.rxt -- maya -batch -command 'quit -f;'`; record the working command or `none`.
*   `RESOLVE_TIME_LOCAL`: `time rez-env maya-2026 td_scripts -- true`; `RESOLVE_TIME_NAS` the same on the NAS root if it exists.
*   `REZ_PYTHONPATH_CLASH`: with `PYTHONPATH` set to the value of `AYON_PYTHONPATH` (or `/tmp/dummy` if empty), `yes` if `rez-env` fails or prints Python import errors, else `no`.

**Step 8. Plugin-off test through Ayon (GUI).** If `REZ_PYTHONPATH_CLASH` is `yes`, first create `tests/probe_maya_clean` as a copy of `tests/probe_maya` with two changes: add `export AYON_PP="$PYTHONPATH"; unset PYTHONPATH` before the first `rez-env` call, and replace the last line with `exec "$REZ_ENV" $REQ -- sh -c 'PYTHONPATH="$AYON_PP${PYTHONPATH:+:$PYTHONPATH}" exec maya "$@"' sh "$@"`. Use it in place of `probe_maya` below. Set the Ayon variant executable to `tests/probe_maya`. Before each launch start Ayon's launcher normally; if `AYON_PYTHONPATH` was empty, set `PYTHONPATH=/tmp/dummy` in the shell that starts the launcher so the survival test can fail.

1.  Preset `maya-2026`. Launch. In the Script Editor `import td_scripts` must fail. Run `tests/capture_maya.sh probe1`.
2.  Preset `maya-2026 td_scripts`. Launch. `import td_scripts; td_scripts.run()` must work. Run `tests/capture_maya.sh probe2`. Together with launch 1 this gives `PLUGIN_OFF_TD`.
3.  Using `probe2`: `PYTHONPATH_SURVIVES` is `yes` if every entry of `AYON_PYTHONPATH` (or `/tmp/dummy`) is in `env-maya-probe2.txt` **and** the td_scripts `python` folder is also present (proves append, not replace); else `no`. `AYON_PRESENT` is `yes` if all names in `AYON_ENV_PRESENT` are in `env-maya-probe2.txt`. `ARGS_PASSTHROUGH` is `yes` if `args-maya-probe2.txt` is identical to `args-maya-before.txt` (same count and arguments reach Maya). Repeat the quoting test: `tests/probe_maya -batch -command 'print("a b $HOME"); quit -f;'` must print `a b $HOME` literally.
4.  Official plugin: use the plugin from `OFFICIAL_BASELINE`, with the preset not naming it. This test is valid only if `OFFICIAL_BASELINE` is `loaded`. In the Script Editor run `cmds.pluginInfo("mtoa", query=True, loaded=True)` and print `os.environ.get("MAYA_MODULE_PATH")`. `PLUGIN_OFF_OFFICIAL` is `absent` if it is not loaded and its folder is not in the path, `present` if it is loaded, and `no-candidate` if `OFFICIAL_BASELINE` was not `loaded` for any plugin (the test then proves nothing).

**Step 9. Alternative A.** Set the executable to the single-command form with the request typed into the field (`/opt/rez/bin/rez/rez-env maya-2026 td_scripts -- maya`, using `REZ_ENV_PATH`). Launch. The Ayon field cannot set environment variables, so for this test only, write `~/.rezconfig` containing `packages_path = ["/home/<user>/rez/repo"]` (absolute path), unset `REZ_DISABLE_HOME_CONFIG`, and delete `~/.rezconfig` afterwards. Record `ALT_A_RESULT` (`works` or `fails` with the message). Alternative A has no preset file, so it can only be a fixed request in Ayon settings. It also has no timeout, no scrub and no custom error message (Goal 3 reduces to rez's own error).

**Step 10. Revert.** Restore `ORIGINAL_EXEC_VALUE` and launch Maya once. Record `REVERT_CHECK` (`pass` or `fail`). This is the last step, so no later step can leave it stale.

**Alternative G in P0.** The hook route is not executed in this spike (it needs an addon development setup). P0 records `ALT_G_NOTE`: a written comparison on coupling and failure visibility, based on reading the ayon-core 1.9.12 prelaunch hook code, marked "not tested". If the gate gives no-go on `EXEC_FIELD_RESULT`, a separate spike for the hook is written.

### Spike fields and allowed values

| Field | Allowed values | How measured |
| :--- | :--- | :--- |
| `ORIGINAL_EXEC_VALUE`, `AYON_SETTINGS_PATH`, `AYON_PYTHONPATH`, `AYON_ENV_PRESENT`, `MAYA_PATH`, `MAYA_BUILD`, `MAYA_PYTHON`, `LICENSE_MECHANISM`, `NAS_MOUNT`, `ROCKY_VERSION`, `REZ_TAG`, `REZ_PYTHON`, `REZ_ENV_PATH`, `OS_STRING`, `ALT_G_NOTE` | text | Steps 1 to 5 |
| `PROJECT_OVERRIDE` | `per-project`, `variant-only`, `unmeasured` | Step 1 |
| `EXEC_FIELD_RESULT` | `ok`, `rejected`, `unmeasured` | Step 2 |
| `ARGS_PASSTHROUGH_AYON`, `ARGS_PASSTHROUGH` | `yes`, `no`, `unmeasured` | Steps 2, 8.3 (the `maya.bin` command line, not the script's log) |
| `ARGS_QUOTING` | `ok`, `broken`, `unmeasured` | Steps 3, 8.3 |
| `ENV_LEAKS` | list of names (may be empty) | Step 2 |
| `OFFICIAL_BASELINE` | `loaded`, `installed-not-loaded`, `not-installed`, `unmeasured` | Step 2 |
| `REZ_BIND_OPTION` | option name or `none` (fallback: copy the bound packages by hand) | Step 5 |
| `PARENT_VARIABLES_KEY` | key name or `unsupported` (fallback: each package appends explicitly) | Step 7 |
| `NO_LOCAL_BEHAVIOR` | `config-only`, `rez-adds-local` | Step 7 |
| `REZ_INPUT_FORM` | working command or `none` (fallback: single-command form) | Step 7 |
| `REZ_PYTHONPATH_CLASH` | `yes`, `no` | Step 7 |
| `RESOLVE_TIME_LOCAL`, `RESOLVE_TIME_NAS` | seconds | Step 7 |
| `PLUGIN_OFF_TD` | `pass` or `fail` | Step 8.1, 8.2 |
| `PYTHONPATH_SURVIVES`, `AYON_PRESENT` | `yes`, `no`, `unmeasured` | Step 8.3 (launch 2, with the td_scripts append present) |
| `PLUGIN_OFF_OFFICIAL` | `absent`, `present`, `no-candidate`, `unmeasured` | Step 8.4 |
| `ALT_A_RESULT` | `works`, `fails` | Step 9 |
| `REVERT_CHECK` | `pass`, `fail` | Step 10 |

### Go/no-go gate (end of P0b)

The P0a gate (`EXEC_FIELD_RESULT`) is decided earlier and is not repeated here. The author writes `GO_DECISION` and the date in `docs/spike-results.md`. Gate fields are every field in the table above with a fixed set of values (not the free-text fields). Apply the **stop rows** in order; the first match decides. If none matches, the result is go, and every **modifier** whose condition is true is then applied (several can apply together).

**Stop rows**

| Condition | Decision |
| :--- | :--- |
| Any gate field is `unmeasured` or missing | **Stop.** Measure it first. |
| `REVERT_CHECK` = `fail` | **Stop.** Fix the revert before anything else. |
| `PLUGIN_OFF_TD` = `fail` | **No-go.** The core mechanism does not work; redesign. |
| `ARGS_PASSTHROUGH_AYON` = `no`, `ARGS_PASSTHROUGH` = `no`, or `ARGS_QUOTING` = `broken` | **No-go for the wrapper** unless a fix is found and retested in the spike. |

**Modifiers on go** (each edits the plan for P1 to P3)

| Condition | Plan edit |
| :--- | :--- |
| `PYTHONPATH_SURVIVES` = `no` or `AYON_PRESENT` = `no` | Add to the P3 wrapper plan a re-export of the lost variables, then repeat steps 8.2 and 8.3 with the fix. |
| `REZ_PYTHONPATH_CLASH` = `yes` | The final wrapper follows `tests/probe_maya_clean` (Ayon's `PYTHONPATH` removed for rez's own Python and restored for Maya). |
| `ENV_LEAKS` is not empty | The wrapper unsets exactly those names (replacing the candidate list in the Wrapper script section). |
| `PLUGIN_OFF_OFFICIAL` = `present` or `no-candidate` | The first slice covers in-house packages only. Disabling official plugins is a separate design (candidates: `MAYA_MODULE_PATH` override, `MAYA_PLUG_IN_PATH` scrub). `no-candidate` means the official-plugin question stays open rather than answered. |
| `REZ_INPUT_FORM` = `none` | The wrapper uses the single-command form. |
| `PARENT_VARIABLES_KEY` = `unsupported` | Packages append explicitly. |
| `ALT_A_RESULT` = `works` and `ENV_LEAKS` is empty | Alternative A may replace the wrapper if the author accepts a fixed request in Ayon settings and rez's own error text (see Alternative A and step 9). The author decides and records it. |

### Verification of Phase 0

*   Every field has a value in `docs/spike-results.md` and none is `unmeasured` when the gate is decided.
*   `GO_DECISION` is written, and the defaults table in this document is replaced by measured values in the closing commit.
*   `REVERT_CHECK` is `pass`, so the Ayon dev variant is back to `ORIGINAL_EXEC_VALUE`.
*   No P1 to P3 file is written before the gate passes. After the gate, the plan for P1 to P5 is written from the measured values.

--------------------------------------------------------------------------------

*Drafted with EGM*
