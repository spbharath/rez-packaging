# Stage 6: Comprehension (Round 3)

**Target:** lines 1-249. Reviewer: `egm-comprehension` (naive reader). No source docs for rez/Ayon/Maya were checked; all behavior claims unverified.

Counts: Blocker 0, Major 5, Nit 13.

## Major
1. **Phase 0 fields are bare tokens in the feature range (L9, L57, L187).** `EXEC_FIELD_RESULT`, `PLUGIN_OFF_OFFICIAL`, `ENV_LEAKS`, `PYTHONPATH_SURVIVES`, `PROJECT_OVERRIDE`, `NO_LOCAL_BEHAVIOR` are not defined until the Detailed Plan (L335+). Note: this is a consequence of the range split, and the plan does define them; fix is an anchor link plus a one-phrase meaning on first use.
2. **Behavior claims stated as fact without source (L3, L34, L125, L137, L141, L142, L194, L240, L241, L51).** Examples: `REZ_RESOLVE` format, `--` separator, `rez-build --install` writing to `local_packages_path`, `maya-2026` matching `2026.x`, "Ayon's prelaunch hook owns Maya startup". Add an Assumptions table with source or "measured in P0 (field)".
3. **Wrapper flow ambiguities (L103-107, L125-127, L162, L173).** `STUDIO_REZ_NAS_ROOT` can name a local folder; why `exec` matters is unsaid; the local-root stderr warning is absent from the step list and minimum contract.
4. **Preset definition split across L20, L133, L190.** Multi-line behavior unstated; no example preset line.
5. **Undefined named systems.** Ayon applications addon, bundle, variant, `rez-bind`, `rez-search`, what rez is.

## Nit
1. L3 stale round. 2. L15 packed glossary; P0-P5 undefined where first used. 3. L17 `.so` is Linux-specific. 4. L33/L39 no method to check `REZ_RESOLVE` in Maya. 5. L41 `pix_hello.say()` behavior unspecified. 6. L86 "fail-closed" undefined. 7. L105 candidates only. 8. L110 vs L137 duplicate. 9. L154 "flat" explained only at L248. 10. L162 add table of three env vars (who sets/reads). 11. L175 read-only mount not a requirement or checked in P5. 12. L194 "from review" and "P2 plan" refer to invisible things. 13. L198 A-H overlap outcomes 1-3.
