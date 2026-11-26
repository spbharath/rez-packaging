# Rez packages for Maya 2026, launched through Ayon

*   **Author:** blazentamilgaming
*   **Status:** Draft
*   **Date:** 2026-11-26

--------------------------------------------------------------------------------

## Overview

Ayon launcher 1.6.3 (ayon-core 1.9.12) starts Maya 2026 on Rocky Linux. Rez builds the environment that Maya runs in. The rez request names the packages, and those packages decide which plugins and TD scripts Maya can see. Rez and the package repository live on the NAS. A local repository on the Rocky test machine is used first.

The first milestone covers Maya 2026 only. Nuke, 3DEqualizer and Silhouette follow the same pattern later.

Terms used in this document:

*   **Rez package**: a versioned folder with a `package.py` file.
*   **Maya plugin**: a `.so` file or script that Maya loads.
*   **Maya module**: a folder that Maya finds through `MAYA_MODULE_PATH`, usually described by a `.mod` file.
*   **Ayon addon**: code the Ayon server delivers in a bundle, such as ayon-core and ayon-maya.
*   **Request**: the list of packages given to `rez-env`, such as `maya-2026 pix_hello`.
*   **Preset**: a request saved in a git file, used as the default.

## The Problem

Today the Maya environment is whatever the Ayon applications addon and the Maya install give it. There is no single place to say "this launch gets Arnold and the studio TD scripts, that launch does not". Adding or removing a plugin means editing the machine, the Ayon settings, or both. TD scripts and tools on the NAS have no versioned way to reach Maya.

The proposed solution: Ayon runs one launcher script. The script calls `rez-env` with a request, and Maya starts inside the resolved environment. Changing the request changes what Maya can load. Packages live in a versioned repository, so a launch can be pinned and repeated.

## Goals

*   Install rez on the Rocky Linux machine at a fixed path that the Ayon-launched process can find.
*   Create a `maya-2026` rez package that points at the existing Maya 2026 install and does not copy Maya.
*   Create a small test package, `pix_hello`, that sets an environment variable and offers a small function Maya can call, to prove the on/off switch without shipping a `userSetup.py`.
*   Provide one launcher script that Ayon calls. It starts Maya through `rez-env`, writes a timestamped log, and prints an error and exits non-zero if rez or the NAS is unavailable.
*   Point a dev variant of the Ayon applications addon settings at the launcher script. Record the original value so the change can be reverted.
*   Define one place where the plugin on/off choice lives, and show it working. Removing `pix_hello` from the request removes its effect; adding it back restores it.
*   Run the same flow against a local repository first, then against the NAS repository, with the same layout and only the root path changed.
*   Deliver TD scripts to Maya through a rez package that adds script folders to `MAYA_SCRIPT_PATH` and `PYTHONPATH`.
*   Record the tested version set: Ayon launcher 1.6.3, ayon-core 1.9.12, Maya 2026, rez version, Rocky Linux version.

## Non-Goals

*   Nuke, 3DEqualizer and Silhouette packages (later).
*   Packaging ayon-core or ayon-maya in rez. Ayon delivers them.
*   Shipping a `userSetup.py` from any rez package. Ayon's prelaunch hook owns Maya startup.
*   Managing shelves, shelf paths or `MAYA_APP_DIR`. Shelf content is TD scripts only.
*   Copying Maya or vendor installers into rez.
*   Rewriting vendor `.mod` files or writing a `.mod` generator.
*   Build and release tooling, CI, and a GUI.
*   Migrating existing artist Maya preferences.

## Open Questions

*   **Executable field**: Does ayon-core 1.9.12 accept a multi-word command in the executable setting, or does it check that the path exists and split the string itself? Test on the Rocky machine and record the exact working value. A single launcher script is the fallback.
*   **On/off switch location**: Options are a named preset kept in git, or one variable (for example `STUDIO_REZ_REQUEST`) set in the Ayon app variant that the launcher reads, with a default when unset. A rez context file (`.rxt`) is rejected for daily toggling because it is a frozen resolve. One option must be chosen before the first plugin package.
*   **Disabling official plugins**: Maya also scans its default Autodesk module folders. Leaving a package such as mtoa or Bifrost out of the request may not stop Maya from loading it. Test this early. If it fails, plugin preference control is needed.
*   **Environment leakage**: Ayon's frozen launcher may pass `PYTHONPATH`, `PYTHONHOME` or `LD_LIBRARY_PATH` into Maya. Compare an `env` dump before rez, after rez and inside Maya. Decide which variables rez resets. Ayon's own project and task variables must still reach Maya.
*   **Maya facts to read from the machine**: install path (usually `/usr/autodesk/maya2026`), Python version (expected 3.11), license mechanism.
*   **Rez install**: rez version, Python used for rez, and the fixed install path. Rez on the NAS bakes in an interpreter path, so every host needs the same one.
*   **NAS**: mount path, whether it is identical on every workstation, who publishes packages, file-locking and symlink support, and resolve time over the NAS. A launch-time budget (for example, resolve under 10 seconds) is proposed.
*   **First plugins after `pix_hello`**: candidates are mtoa, Yeti and in-house tools. Their official and custom status and Maya 2026 Linux build availability are unconfirmed.
*   **Ayon settings scope**: Can the executable be overridden per project, or only per variant? This decides how a test change avoids affecting everyone.

## Critical User Journeys (CUJs)

### CUJ 1: Artist launches Maya from Ayon

*   **Given**: Ayon launcher 1.6.3 is connected to a server whose Maya 2026 app variant points at the launcher script. Rez and the package repository are reachable.
*   **When**: The artist launches Maya 2026 for a task.
*   **Then**: Maya opens. `REZ_RESOLVE` inside Maya lists the requested packages. Ayon's project and task variables are present. The launcher log holds the request, the resolved packages and the resolve time.

### CUJ 2: TD turns a plugin or tool on or off

*   **Given**: Maya launches correctly with `pix_hello` in the request.
*   **When**: The TD removes `pix_hello` from the request (by the mechanism chosen in Open Questions) and relaunches Maya.
*   **Then**: The `pix_hello` environment variable is gone and its function can no longer be imported. Adding it back restores both. No machine or Maya install change was needed.

### CUJ 3: Launch fails because rez or the NAS is missing

*   **Given**: The NAS is unmounted or `rez-env` is not at its fixed path.
*   **When**: The artist launches Maya from Ayon.
*   **Then**: The launcher script prints an error to stderr, writes a log entry with the cause, and exits non-zero. Maya does not start half-configured.

### CUJ 4: TD tests a new package locally before release

*   **Given**: A new or changed package is in the git repo on the Rocky machine.
*   **When**: The TD builds it into the local repository and runs `rez-env` with the new version.
*   **Then**: The local repository shadows the NAS version for that machine. After testing, the TD releases the package to the NAS, and a released version is never edited afterwards.

## Technical Plan (Architecture)

Ayon is unchanged. Its applications addon runs one executable, and that executable is a launcher script kept in git. The script owns everything rez-related. Rez resolves a request against package repositories and starts Maya in the resulting environment.

```text
Artist -> Ayon launcher 1.6.3
            |  (applications addon: Maya 2026 executable = launcher script)
            v
   bin/maya2026_rez  (wrapper)
     1. check rez-env and repo path exist, else log + error + exit 1
     2. scrub leaked variables (PYTHONHOME, LD_LIBRARY_PATH; decided by env dump)
     3. read request: $STUDIO_REZ_REQUEST, else default preset
     4. log request, repo paths, start time
     5. exec rez-env <request> -- maya "$@"
            |
            v
   rez resolves against packages_path:
     [ local repo (test machine only) ] -> [ NAS repo ]
            |
            v
   Maya 2026 starts with the environment from the packages
     maya-2026   : MAYA_LOCATION, PATH (existing install)
     pix_hello   : test variable and an importable function
     td_scripts  : MAYA_SCRIPT_PATH, PYTHONPATH
     (later) mtoa, yeti, in-house tools: MAYA_MODULE_PATH or direct paths
   Ayon addons (ayon-core, ayon-maya) arrive from the Ayon bundle, outside rez.
   Ayon's prelaunch hook owns Maya startup (userSetup.py).
```

**Launcher script.** One script per DCC version. It is the only thing that knows the rez path, the default request and the log location. Ayon settings hold the script path and, once chosen, one variable that overrides the request. Fallback if Ayon will not run the script directly: see the executable-field question.

**On/off switch (proposed).** The rez request is the switch. The default request lives in git next to the script. A variable set on the Ayon app variant can replace it, which gives per-project and per-task requests without a second plugin list in server settings. This is a proposal; the choice between this and a named preset is still open.

**Package conventions.**
*   Rez names a package and a version separately. `maya-2026` in a request means package `maya`, version `2026` or any `2026.x` release. The package points at the existing install and sets `MAYA_LOCATION` and `PATH`. It does not copy Maya. It declares the platform and OS it was tested on.
*   Vendor plugin packages append their module folder to `MAYA_MODULE_PATH` and let Maya read the vendor `.mod`. Each vendor `.mod` is checked for hard-coded absolute paths.
*   In-house packages without a `.mod` set `MAYA_SCRIPT_PATH`, `MAYA_PLUG_IN_PATH`, `PYTHONPATH` and `XBMLANGPATH` directly. `XBMLANGPATH` entries on Linux usually end in `/%B`.
*   No package ships `userSetup.py`. A package that needs startup work exposes a function, and Ayon's startup path or a TD calls it.
*   Compiled Python dependencies must match Maya 2026's Python (expected 3.11). Rez's own Python is not a requirement of any Maya package.
*   Released versions are immutable. Production requests pin versions. Package names are lowercase and carry no per-DCC folder level (for example `maya-2026`, `td_scripts`).

**Repository layout (one git repo, in this folder).** Released packages are not stored in git.

```text
rez-packaging/
  packages/<name>/<version>/package.py   source of every package, flat
  config/rezconfig.py                    packages_path, env reset rules
  bin/maya2026_rez                       launcher script
  presets/                               default request(s)
  bootstrap/                             rez install and repository setup
  docs/                                  runbook, version matrix
  tests/                                 smoke test
```

Flow: edit in git, build to the local repository, test, then release to the NAS. The local and NAS repositories use the same layout, and only the root path changes through `rezconfig.py`. On the test machine the local repository comes first in `packages_path`. Rez's `package_cache` may later copy NAS payloads to local disk if measurement shows slow resolves (verify option names for the installed rez version).

**Observability.** Each launch logs the request, `REZ_RESOLVE`, repository paths, resolve time and the exit code. A saved context from `rez-env --output` is kept for failed or pinned sessions.

**Rollout and rollback.** The Ayon change is made in a dev settings variant or project override first. The original executable value is recorded before the edit, and reverting it restores the old behavior.

**Order of work and verification gates.** The spike comes first because several design points depend on measured facts.
1.  Launch Maya through Ayon without rez and record the baseline environment, Maya path, Python version and how Ayon runs the executable.
2.  Install rez at a fixed path and sanity check it.
3.  Create the local repository and set `packages_path`.
4.  Write `maya-2026` and hand-test `rez-env maya-2026 -- maya -batch ...`.
5.  Add `pix_hello`.
6.  Point a dev Ayon settings variant at the launcher script.
7.  Run the acceptance checks below.
8.  Repeat against the NAS repository.
9.  Add `td_scripts`, then mtoa, then Yeti.

Acceptance checks:
*   A. Maya starts from Ayon and the launcher log shows the rez command.
*   B. `REZ_RESOLVE` inside Maya lists the expected packages.
*   C. `MAYA_LOCATION` matches the baseline.
*   D. Removing `pix_hello` removes its effect, and adding it back restores it.
*   E. Ayon's own environment variables survive.
*   F. A bad request or missing NAS gives an error on stderr, a log entry and a non-zero exit.
*   G. Checks A to D pass with both the local and the NAS repository.
*   H. Reverting the Ayon setting restores the old behavior.

## Alternatives Considered

### Alternative A: Put the `rez-env ... -- maya` command directly in the Ayon executable field

*   **Pros**: No extra script to maintain. Everything is visible in Ayon settings.
*   **Cons**: Ayon may check that the executable path exists or split and quote the string itself, so a multi-word command may fail (unverified). Failures are easy to miss because Ayon detaches the child. Logging, environment scrubbing and error messages have nowhere to live.
*   **Reason for Rejection**: Kept only as something to test in the spike. If it works, the launcher script still carries the logging and error handling, so the script stays.

### Alternative B: A rez context file (`.rxt`) as the on/off switch

*   **Pros**: A saved context reproduces an exact resolve, including versions.
*   **Cons**: It is a frozen resolve. Turning one plugin off means making a new context file. It cannot vary per project or task without one file per combination.
*   **Reason for Rejection**: It suits pinning a production session, not daily toggling. Saved contexts are still kept for failed or pinned sessions.

### Alternative C: Keep the full plugin list in Ayon server settings

*   **Pros**: One place that Ayon admins already know. No variable or preset file.
*   **Cons**: A second source of truth next to the packages, with no git history and no review. Changes affect everyone in that settings scope.
*   **Reason for Rejection**: Ayon holds only the script path and, optionally, one override variable. The default request lives in git.

### Alternative D: Package ayon-core and ayon-maya in rez

*   **Pros**: One mechanism for everything Maya loads.
*   **Cons**: Ayon already delivers these as server addons in a bundle. Packaging them again creates two versions of the same code and a startup ownership clash over `userSetup.py`.
*   **Reason for Rejection**: Decided by you: ayon-maya stays outside rez.

### Alternative E: Copy Maya and vendor plugins into rez packages

*   **Pros**: Fully self-contained packages. No dependence on the machine install.
*   **Cons**: Large payloads on the NAS and slow copies. Licensing and installer questions. Duplicates what the installer already does.
*   **Reason for Rejection**: `maya-2026` points at the existing install. Plugin payloads may be installed by rez only where a vendor ships them as plain folders.

### Alternative F: A fixed NAS folder of Maya modules, no rez

*   **Pros**: Simplest possible. Set `MAYA_MODULE_PATH` once in Ayon settings.
*   **Cons**: No versions, no per-launch choice, no pinning, and no way to turn a plugin off for one project without editing the folder.
*   **Reason for Rejection**: It does not meet the goal of controlling plugins per launch.

### Alternative G: Resolve rez from an Ayon launcher hook in Python

*   **Pros**: No shell script. Closer to how Ayon builds environments.
*   **Cons**: The hook runs inside Ayon's frozen launcher, whose Python and libraries differ from rez's. Rez's resolver would be embedded in a process it was not tested in. It also couples the rez setup to an Ayon addon release.
*   **Reason for Rejection**: A separate process through `rez-env` keeps rez in its own Python. May be revisited if the script route fails the spike.

### Alternative H: A per-DCC folder level in the repository

*   **Pros**: Easy to browse by DCC.
*   **Cons**: Rez packages are per tool and a tool can be shared across DCCs. A folder per DCC would duplicate shared packages.
*   **Reason for Rejection**: A flat layout with one folder per package name (for example `maya`, `nuke`) works for Nuke, 3DEqualizer and Silhouette later.

## Detailed Implementation Plan

All paths are relative to the repository root, which is cloned on the Rocky machine. Defaults below are chosen so no decision is left to the implementer. Items marked **(confirm)** are defaults you should check against your machine.

**Defaults used**

| Item | Default | Note |
| :--- | :--- | :--- |
| Rez install path | `/opt/rez` | **(confirm)** Must be the same on every host. |
| Rez install method | Official `install.py` from the rez repo, pinned to the latest stable 3.x tag at install time | Record the tag in `docs/version-matrix.md`. |
| Local repository (test machine) | `$HOME/rez/local` | Where `rez-build --install` writes. |
| NAS repository | `/nas/rez/packages` | **(confirm)** Placeholder until you give the mount path. |
| Maya install | `/usr/autodesk/maya2026` | **(confirm)** Read from the machine in the spike. |
| Log directory | `$HOME/rez/logs` locally; moves to a shared path later | One file per launch, timestamped. |
| Switch mechanism | Variable `STUDIO_REZ_REQUEST`, falling back to `presets/maya2026_default.txt` | Proposal from the Technical Plan. |
| Env reset | `rezconfig.py` resets `PYTHONPATH`, `PYTHONHOME` and `LD_LIBRARY_PATH` instead of inheriting them | Final list decided from the spike env dumps. |

### Target Files to Create/Modify

#### 1. `bootstrap/install_rez.sh` (Create)

*   **Type / Scope**: Shell script, run once per host.
*   **Proposed Changes**: Takes the rez tag and the install path as arguments. Clones rez at that tag, runs the official `install.py` into `/opt/rez`, then runs `rez-bind` for `platform`, `arch`, `os` and `python`. Creates `$HOME/rez/local` and `$HOME/rez/logs`. Prints the rez version, Python used and the OS string so they can be copied into the version matrix, and the `packages_path` value that `config/rezconfig.py` will use. Stops with a clear message if the install path already exists. Does not edit shell profiles; the launcher script calls rez by absolute path.

#### 2. `config/rezconfig.py` (Create)

*   **Type / Scope**: Rez configuration, loaded through `REZ_CONFIG_FILE` by the launcher script.
*   **Proposed Changes**: Sets `packages_path` to the local repository first and the NAS repository second, both read from environment variables so only the root changes between machines. Sets `local_packages_path` and `release_packages_path` to the local repository. Resets `PYTHONPATH`, `PYTHONHOME` and `LD_LIBRARY_PATH` rather than inheriting them. Leaves `package_cache` off in the first slice; it is enabled only if the NAS resolve time misses the budget (verify option names for the installed rez).

#### 3. `bin/maya2026_rez` (Create)

*   **Type / Scope**: POSIX shell script, the Maya 2026 executable that Ayon runs.
*   **Proposed Changes**: In order:
    1.  Fail with an error message and exit 1 if `/opt/rez/bin/rez-env`, the config file or the first repository path does not exist. The error goes to stderr and to the log file.
    2.  Set `REZ_CONFIG_FILE` to the repo's `config/rezconfig.py`.
    3.  Choose the request: `STUDIO_REZ_REQUEST` if set and non-empty, otherwise the contents of `presets/maya2026_default.txt`.
    4.  Open a log file named with the date, time and process ID. Write the request, repository paths, the Ayon variables present (names only, not values) and the start time.
    5.  Run `rez-env <request> --output <saved context path> -- maya "$@"` through `exec` so Ayon sees Maya's exit code. Exact flag for saving the context and for skipping shell startup files is verified in the spike.
    6.  Pass arguments through unchanged. A scene path containing a space is part of the smoke test.

#### 4. `presets/maya2026_default.txt` (Create)

*   **Type / Scope**: One-line text file.
*   **Proposed Changes**: The default request, initially `maya-2026 pix_hello td_scripts`. The text file is a single source for TDs to edit and review in git.

#### 5. `packages/maya/2026.0/package.py` (Create)

*   **Type / Scope**: Rez package definition, no build step.
*   **Proposed Changes**: Name `maya`, version `2026.0`. Sets `MAYA_LOCATION` to the install path and prepends its `bin` to `PATH`. Restricts to Linux with a `requires` line on `platform-linux` and the Rocky OS string found in the spike. Sets no plugin or script paths. The install path is read from the machine in the spike and written into the file as a plain string.

#### 6. `packages/pix_hello/1.0.0/package.py` and `packages/pix_hello/1.0.0/python/pix_hello/__init__.py` (Create)

*   **Type / Scope**: Test package.
*   **Proposed Changes**: Sets `PIX_HELLO=1` and adds `python/` to `PYTHONPATH`. The module exposes one function, `say()`, that prints a line naming the package version. Used by acceptance check D. Does not ship `userSetup.py`.

#### 7. `packages/td_scripts/1.0.0/package.py` and `packages/td_scripts/1.0.0/scripts/` (Create)

*   **Type / Scope**: TD scripts package.
*   **Proposed Changes**: Adds `scripts/` to `MAYA_SCRIPT_PATH` and the Python subfolder to `PYTHONPATH`. Starts with one placeholder script so shelf buttons can call it. TD scripts later get their own versions. No shelf files and no `MAYA_APP_DIR`.

#### 8. `tests/env_dump.sh` (Create)

*   **Type / Scope**: Shell script.
*   **Proposed Changes**: Writes `env` sorted to a file. Run at three points in the spike: before rez, inside `rez-env`, and inside Maya through `maya -batch -command` calling Python `os.environ`. A diff shows which variables leak.

#### 9. `tests/smoke_test.sh` (Create)

*   **Type / Scope**: Shell test of acceptance checks B, C, D and F that can run without Ayon.
*   **Proposed Changes**: Runs `maya -batch` through the launcher script and checks `REZ_RESOLVE` and `MAYA_LOCATION` from inside Maya. Runs again with `pix_hello` left out and checks that `PIX_HELLO` is absent and `import pix_hello` fails. Runs with a bad request and with the repository path unavailable, and checks for a non-zero exit and a log entry. Runs with a scene path containing a space.

#### 10. `docs/version-matrix.md` (Create)

*   **Type / Scope**: Documentation.
*   **Proposed Changes**: Table of Ayon launcher 1.6.3, ayon-core 1.9.12, Maya 2026 build, rez tag, Rocky version, Python versions. Updated whenever a version changes.

#### 11. `docs/runbook.md` (Create)

*   **Type / Scope**: Documentation.
*   **Proposed Changes**: Steps for the Ayon settings change (path to edit, original value recorded, how to revert), how to read a launcher log, how to build a package and copy a built version to the NAS with `rez-cp` or `cp` (never overwriting a released version), and how to pin a production request.

#### 12. `.gitattributes` and `.gitignore` (Create)

*   **Type / Scope**: Git configuration.
*   **Proposed Changes**: `.gitattributes` forces LF line endings so scripts written on Windows run on Linux. `.gitignore` excludes logs and built repositories.

#### 13. Ayon server settings, Maya 2026 executable (Modify, not a file in this repo)

*   **Type / Scope**: Manual change in the Ayon applications addon settings, in a dev variant or project override.
*   **Proposed Changes**: Record the current executable value. Replace it with the absolute path of `bin/maya2026_rez` on the Rocky machine. Optionally add `STUDIO_REZ_REQUEST` to the Maya app environment for per-project requests. Revert by restoring the recorded value.

### Verification Plan

*   **Compilation/Build**: `rez-build --install` for each package into `$HOME/rez/local`, with `rez-search` showing the three packages.
*   **Unit Tests**: None. The packages contain no logic beyond environment setup.
*   **Static Analysis & Linting**: `shellcheck` on every script in `bin/`, `bootstrap/` and `tests/`. Python syntax check on `config/rezconfig.py` and the `package.py` files.
*   **Test Coverage Requirement**: Acceptance checks A to H from the Technical Plan. B, C, D and F run through `tests/smoke_test.sh`. A, E, G and H are manual and recorded in `docs/runbook.md`.
*   **E2E/Integration**: Launch Maya 2026 from Ayon launcher 1.6.3 with the dev settings variant, first against the local repository, then against the NAS repository, and compare `tests/env_dump.sh` output to the pre-rez baseline.

--------------------------------------------------------------------------------

*Drafted with EGM*
