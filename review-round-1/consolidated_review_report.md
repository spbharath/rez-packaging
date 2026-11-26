# Consolidated Review Report

**Target:** `docs/designs/rez-maya-2026-ayon.md` (323 lines; FeatureRange 1-221, DetailedRange 222-323)
**Date:** 2026-11-26
**Mode:** Uninterrupted full flow. No findings were applied to the design.

## Verdict

The design is not ready to implement. Its direction holds up: Ayon stays unchanged, one launcher script runs `rez-env` as a separate process, and every stage found no architectural dead end. The weak points are open decisions that the later sections treat as settled, and a launcher design with several mechanical faults.

| Stage | Report | Blocker | Major | Nit |
| :--- | :--- | :--- | :--- | :--- |
| 5 Initial Zoom Out | `zoom_out_report.md` | 0 | 4 | 6 |
| 6 Comprehension | `comprehension_report.md` | 3 | 8 | 8 |
| 7 Critic (design, structural, style) | `critic_report.md` | 0 | 10 | 14 |
| 8 Intermediate Zoom Out | `intermediate_zoom_out_report.md` | 0 | 8 | 4 |
| 9 Implementation Readiness | `implementation_readiness_report.md` | 6 | 15 | 12 |

None of the reviewers ran Ayon, rez or Maya. Statements about rez paths, flags and config keys come from reviewer memory. Items marked **verify** must be confirmed in the spike before the design is edited around them.

## Consolidated actions

### 🔴 Blockers

**B1. Make the spike the first phase, with a defined output and a go/no-go gate.**
The Rocky OS string, Maya path, executable-field behavior, env-reset list and NAS path are deferred to a spike that has no steps or output format. The central claim (leaving a package out turns a plugin off) is untested and Maya also scans its default module folders, so the design could shrink to in-house tools only. Add Phase 0 with named output fields (for example `docs/spike-results.md`), a stated fallback scope, and phases P0 to P5, each with an exit check. Consider splitting the design so this one covers the spike and a follow-up covers the build-out.

**B2. Decide the on/off switch once and state it in one place.**
Open Questions say it is undecided. The diagram, Alternative C and the Defaults table treat `STUDIO_REZ_REQUEST` as the answer. The variable is also a hidden second plugin list, which Alternative C rejects, and per-project overrides are claimed while the open question says they may not exist. Reviewers suggest the git preset as the default with the variable as an optional override, or cutting the variable from the first slice.

**B3. Fix the launcher flow so it can log, time and report failures.**
Two faults are joined here.
* `exec` replaces the shell, so the exit code, end time and `rez-env` resolve errors cannot be logged, and Ayon detaches the child so those errors are lost.
* `rez-env <request> --output <file> -- maya` is reported to save the context and exit without starting Maya (**verify**). Suggested flow: resolve to a context file first and time it, log the result and exit 1 on failure, then launch Maya from that context.
Also specify the log file name pattern, exact error text, which repository path is checked, and the Ayon variable prefix to log (reviewers suggest `AYON_*`).

**B4. Correct and complete the install contract.**
* The launcher and install script point at `/opt/rez/bin/rez-env`, but `install.py` is reported to place commands under `bin/rez/` (**verify**), so every launch would fail the first check.
* The rez tag is "latest stable at install time", which gives different results per host. Pin one tag and state which Python runs `install.py`.
* `rez-bind` is reported to write to `~/packages` unless given an install path, and the OS and arch bindings were not confirmed to exist (**verify**).
* State privileges, argument order, exit codes and failure text.

**B5. Make package payloads install and give full package files.**
With no build step, `rez-build --install` is reported to copy only `package.py` (**verify**), so `pix_hello/python/` and `td_scripts/scripts/` would never reach the local repository and `import pix_hello` fails. Give `pix_hello` and `td_scripts` a build command that copies their payload, and keep "no build" for `maya`. Write out all package contents: `requires`, `commands`, `tools`, the `say()` output and version source, the Python folder name, and the placeholder script.

**B6. Give rez configuration one owner and one scrubbing layer.**
Repository paths and environment reset are described in the wrapper, `rezconfig.py`, environment variables and `install_rez.sh`. Rez's real keys are reported to be `resetting_variables` and `parent_variables` and to affect only variables a package sets (**verify**). A blanket reset of `PYTHONPATH` could drop the path Ayon's pre-launch hook relies on, which breaks CUJ 1 and check E. Pick one place for scrubbing (the wrapper is suggested), name the Ayon variables that must survive, and name the variables `rezconfig.py` reads.

### 🟡 Majors

1. **Rez location contradicts itself.** The Overview says NAS, Goal and Defaults say `/opt/rez` per host, and line 60 notes a NAS install bakes in an interpreter path. State one choice and the update policy.
2. **No Risks and Mitigations, and no path from one test machine to the artist fleet.** Cover a bad package on the NAS, NAS-down policy, who may publish, a last-known-good pinned preset as rollback, and staged rollout gates.
3. **Plugin loading and startup are undefined** now that no package ships `userSetup.py`. `pix_hello` only proves importability. State how real plugins load (`.mod` autoload, `MAYA_PLUG_IN_PATH` with preferences, or an Ayon hook) and how a TD calls a package function.
4. **Verification gaps.**
   * Add a GUI launch check, a full environment diff against the baseline, and a `td_scripts` check.
   * Batch tests are reported to hang unless they quit explicitly or use `mayapy` (**verify**).
   * State the 10-second budget as a check or drop it.
   * Write a test table with commands and expected results, and restate checks A to H in the plan.
5. **`pix_hello` and `td_scripts` overlap.** Use `td_scripts` with a placeholder script as the toggle test, or justify the separate package.
6. **`maya` package pins the OS.** This fails to resolve on any other host, including the Windows machine. Leave it out of the first slice or move it to a variant.
7. **Local repository is required first on every machine.** Artist machines have no local repository, and `rez-env` adds `local_packages_path` itself unless told not to (**verify**). Add the local path only if it exists, require only the NAS, and define the release target.
8. **Ayon settings are not concrete.** Name the settings path, field, dev variant and platform key, the way the variable reaches Maya, and add a revert check.
9. **Alternative D is rejected by "Decided by you".** Give the technical reason (duplicate code, `userSetup.py` clash) with an owner and date, in impersonal wording.
10. **"No decision is left to the implementer" is untrue** with several defaults marked **(confirm)**. Reword to "defaults to confirm".
11. **Scripts lose the executable bit** when authored on Windows. Set it in git or run the launcher through `sh`.
12. **Unverified claims stated as fact.** For example "Ayon detaches the child" and "frozen launcher differs". Mark as unverified.
13. **Overreach in the first slice.** `package_cache`, the saved context, the resolve budget and per-project requests are speculative. Package conventions for mtoa and Yeti describe packages that do not exist yet.
14. **Altitude.** Detailed Plan items such as `.gitattributes`, `.gitignore` and `env_dump.sh` as numbered deliverables are code-level detail. Fold them into the smoke test or the runbook.

### 🟢 Nits

* Move Open Questions after the architecture, or add forward references and a decision-status note. Promote bold run-in labels to headings.
* Add a CUJ-to-check mapping and a heading for the acceptance checks.
* One term for the script ("wrapper script"), and define "request", "preset", "context", EGM. Name the repo root.
* Define the launcher naming rule, version matrix columns, preset file name and format (one line, no comments, `set -f`), and the Rocky version.
* Give contents for `.gitattributes` (`* text=auto eol=lf`) and `.gitignore`.
* Name the verification tools (`python -m py_compile`, `shellcheck`), name the three packages, and make `rez-search` list them.
* Confirm `shellcheck` exists on Rocky and record manual checks as a known gap.
* Reword vague or subjective phrases ("clear message", "fully self-contained", "simplest possible"), second-person text, and the shelf-button wording that contradicts "no shelf files".
* State "must pin exact versions" and confirm rez range behavior for `2026` against `2026.x`.
* Add reviewers and a last-updated field to the header, and explain or drop the "Drafted with EGM" footer.
* Add a one-line rejection reason for Ayon per-variant environment settings (Alternative F) and a success metric such as launch success rate.
* Decide where the NAS publish step lives and test it, including refusal to overwrite.
* Link to rez documentation instead of carrying a rez primer, and move Maya plugin detail to the runbook.

## Traceability matrix

| Action | Stage 5 | Stage 6 | Stage 7 | Stage 8 | Stage 9 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| B1 spike and gate | Too many unknowns | Defaults are placeholders | Verification gaps | Central claim untested | Values deferred; no phasing |
| B2 switch | Undecided but default | Blocker: proposed vs open | Undecided but treated decided | Duplicates Alternative C | (deferred to Technical Plan) |
| B3 launcher flow | | Blocker: log contract | `exec` vs exit code | `exec` defeats logging | `--output` does not launch; `exec` |
| B4 install contract | | Blocker: install contracts | | | Wrong rez-env path; rez unpinned; rez-bind |
| B5 package payloads | pix_hello overlap | Package contents | | | Payloads never installed |
| B6 config owner | Scrubbing in two layers | Blocker: rezconfig contract | Scrubbing may break Ayon | No single owner | Env reset mechanism wrong |
| M1 rez location | Rez location open | | Rez location contradicts | Carried over | |
| M2 risks and rollout | | | No Risks section; no fleet path | | |
| M3 plugin loading | | Startup mechanism | Plugin loading undefined | | |
| M4 verification | Verification gaps | NAS budget; build settings | Budget; verification gaps | | Test plan hangs; env_dump |
| M6 OS pin | | Package contents | | `maya` pins OS | |
| M7 local repo | | | | | Local repository required |
| M8 Ayon settings | | Variant variable | | | Runbook not concrete |
| M9 Alt D wording | "Decided by you" | "Decided by you" | Alt D by authority | | Intro uses "you" |

## Not checked

* No Ayon 1.6.3, ayon-core 1.9.12, rez or Maya 2026 behavior was verified. Rez paths, flags, config keys and `rez-build` behavior come from reviewer memory.
* Stage 9 reviewed lines 222-323 only. Stage 7 reviewed lines 1-221 only.
* The repository has no code, so no reuse or codebase search was possible.
* No second independent instance (A and B) was run for any reviewer.
