# Consolidated Review Report, Round 2

**Target:** `docs/designs/rez-maya-2026-ayon.md` (387 lines; FeatureRange 1-242, DetailedRange 243-387)
**Date:** 2026-11-26
**Mode:** Uninterrupted full flow, run on the revised design. Round 1 reports are in `review-round-1/`. No findings were applied.

## Verdict

Round 1's six Blockers are gone. Three new Blockers remain, all about one thing: the Phase 0 spike is not specified well enough to run. The architecture was judged sound by every stage.

| Stage | Report | Blocker | Major | Nit |
| :--- | :--- | :--- | :--- | :--- |
| 5 Initial Zoom Out | `zoom_out_report.md` | 0 | 5 | 4 |
| 6 Comprehension | `comprehension_report.md` | 0 | 7 | 6 |
| 7 Critic (design, structural, style) | `critic_report.md` | 0 | 8 | 14 |
| 8 Intermediate Zoom Out (new findings) | `intermediate_zoom_out_report.md` | 0 | 3 | 7 |
| 9 Implementation Readiness | `implementation_readiness_report.md` | 3 | 14 | 12 |
| Round 1 for comparison | `review-round-1/` | 9 | 45 | 44 |

Nothing was run. Statements about rez, Ayon and Maya behavior are reviewer knowledge and stay unverified until the spike.

## The main tension to resolve first

The reviewers pull in opposite directions about detail.
* **Zoom-out stages (5, 8)** say the Detailed Implementation Plan is over-specified, and that P1 to P5 are written in full before the P0 gate can change or cancel them.
* **Implementation readiness (9)** says the plan lacks detail and cannot be built from the spike output.

Both are right about different parts. The consistent fix is: **specify P0 completely, and reduce P1 to P5 to the phase table until the gate passes.** That answers the Stage 9 Blockers, which are all about P0, and the Stage 5 and 8 objections, which are about P1 to P5. It would also remove most of the Stage 9 Majors, because they describe P1 to P5 files.

## Consolidated actions

### 🔴 Blockers (all in Phase 0)

**B1. Phase 0 cannot be run as written.**
* Step 1 needs `tests/env_dump.sh`, but that file is created later, and no script exists to capture the Ayon-launched Maya environment before rez. The `maya` label runs `mayapy`, a different process.
* Fix: list exact P0 commands. Create a stub script as the executable in a dev Ayon variant that dumps its environment and then starts Maya. Capture the Maya process environment from the real process. Say which phase creates each P0 file.

**B2. The go/no-go gate is not a function of the recorded fields.**
* `PYTHONPATH` survival, argument pass-through and `AYON_*` presence have no field. Fields have no value domain. The plugin-off test has no pass criterion, and a `-batch` test can falsely report "off" because batch skips GUI autoload.
* The rules do not say what happens if `td_scripts` fails, or who decides.
* Fix: define every field with a measuring command and allowed values. Run the plugin-off test as a GUI launch through Ayon. Add an outcome table of result combinations, the plan edits each triggers, and the decider.

**B3. Several "confirm in P0" items have no spike step or field.**
* `parent_variables` key, `--no-local` behavior, `rez-bind` option, `--input` with `--`, and how spike values reach code.
* Fix: add steps and fields (for example `PARENT_VARIABLES_KEY`, `NO_LOCAL_BEHAVIOR`, `REZ_BIND_OPTION`, `REZ_INPUT_FORM`), a fallback for each, and a rule that the commit closing P0 replaces default values with measured ones.

### 🟡 Majors

1. **Reduce P1 to P5 to the phase table until the gate passes** (resolves the tension above). Keep per-file detail for P0 only.
2. **Make the wrapper's baseline the single command** `rez-env <request> -- maya "$@"` with errors on stderr. The log file, exit-code table, two-step run and `/tmp` fallback depend on what the spike shows is missing. State the wrapper's minimum contract (preset in, scrub, run). Drop the saved context file unless something reads it.
3. **Compare Alternative G fairly inside the P0 gate.** A prelaunch hook can run `rez-env` as a subprocess, which gives the same isolation. Alternatives A and G need dispositions (Rejected, Deferred, Test-only), not "may be revisited".
4. **State that plugin-off is guaranteed only for packages delivered through rez** in Goals and CUJ 2 until the spike confirms official plugins, and add an official-plugin case to check D. List likely mitigations if the gate fails.
5. **Add Risks and Mitigations and a trust model**: NAS outage and latency, who may publish, `package.py` runs as code at resolve time, preset parsing rules, log location and retention, and fail-closed versus warn-and-continue.
6. **Local repo silently shadows the NAS.** Log or warn when a package resolves from the local root, or make the local root opt-in. This also removes the dual search-order owner (config and wrapper).
7. **Ayon test scope and rollback are inconsistent.** Resolve the project-override question in P0 and state the blast radius and revert steps.
8. **Wrapper and diagram disagree** (exit codes, step order, `--no-local`). After the simplification in item 2, rewrite both from one source.
9. **Reduce acceptance and test machinery** to three outcomes for the first slice: Maya launches from Ayon with the request visible, the toggle works, failure gives a non-zero exit and a log line. Keep checks A to H and T1 to T7 as a post-gate list. Tests should assert "non-zero and a log line", not specific codes.
10. **Config and tooling faults to fix when P1 is specified**: `rez-build --install` writes to `local_packages_path` which the config never sets; the P1 exit check cannot pass from a clean shell without a sourced helper; `install_rez.sh` hard-codes `python3`, mishandles `HOME` under `sudo` and its `OS_STRING` command prints nothing useful; T3 and T5 are not implementable as written; payload build commands and `package.py` contents are left to the implementer; `PYTHONPATH` handling between Ayon and rez's own Python is unspecified.
11. **Missing publish procedure for P5** (choose `rez-cp`, give command, permissions, write check) and **missing Ayon dev-variant procedure** (test-script content, how to create the variant, fallback if the field rejects the path).
12. **Goals not measurable and terms inconsistent**: name the test function, say stderr, define "preset" versus "preset file", and add a `td_scripts` check.
13. **Undefined shorthand** (check letters, "item 9", phases) and **misfitting Verification Plan headings**.

### 🟢 Nits (grouped)

* Drop speculative surface: `td_hello.mel`, the shelf-button remark, `XBMLANGPATH` and `MAYA_PLUG_IN_PATH` conventions with no user, padded Non-Goals, padded Alternatives.
* Consider a constant instead of a preset file, one doc instead of three (spike results, version matrix, runbook), and a runbook section instead of `install_rez.sh` for one host.
* Cut observability to request, resolved packages and exit code.
* Wording and terms: define TD, DCC, NAS, CUJ, `.rxt`, Rocky; "Ayon is unchanged" and "only owner" overstate; "used first" is ambiguous; unsupported claims in Alternatives; duplicate statements; inconsistent "unverified" markers.
* Git details: `git init` and `git add` before `chmod`, `logs/` ignore entry points outside the repo, preset trailing newline, release command choice.
* Cite a project context document if one exists, and say what the `maya-2026` package version ties to in the real Maya build.

## Traceability matrix

| Action | Stage 5 | Stage 6 | Stage 7 | Stage 8 | Stage 9 |
| :--- | :--- | :--- | :--- | :--- | :--- |
| B1 P0 runnable | P1-P5 before gate | | | | Blocker: env_dump circularity |
| B2 gate function | Plugin-off overstated | | Official-plugin assumption | | Blocker: gate not deterministic |
| B3 confirm items | Unverified two-step flow | Undefined constants | | | Blocker: confirm items lack steps |
| 1 reduce P1-P5 | Over-detailed; post-gate phases | | | Test machinery too large | (conflicts; resolved above) |
| 2 wrapper baseline | Unverified two-step | Wrapper vs diagram | Fail-closed undecided | Wrapper justified by logging | Wrapper decisions open |
| 3 Alternatives A and G | | | Alternatives lack dispositions | Alternative G thin | |
| 4 plugin-off wording | Goals overstate | | Official-plugin fallback thin | | |
| 5 risks and trust | | | No Risks section; trust model | | |
| 6 local shadowing | Dual repository | | Local repo shadows NAS | Two layers own search order | |
| 7 Ayon scope | | | Test scope and rollback | | Dev-variant procedure |
| 9 test machinery | | Checks to tests map | Budget untested | Machinery too large | T1-T7 not implementable |
| 10 config faults | | install_rez.sh, package.py | | | Several Majors |
| 11 publish and variant | | | | | P5 no publish; variant procedure |

## Not checked

* No Ayon 1.6.3, ayon-core 1.9.12, rez or Maya 2026 behavior was verified.
* Stage 7 reviewed lines 1-242 only. Stage 9 reviewed lines 243-387 only.
* No second independent instance of any reviewer was run.
* The repository has no code, so no reuse search was possible.
