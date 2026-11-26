# Stage 8: Intermediate Zoom Out (Round 3, new findings only)

**Target:** whole file (feature 1-249, detailed 250-381). Reviewer: `egm-zoom-out`. Nothing run; behavior claims unverified.

Counts: Blocker 2, Major 6, Nit 4.

## Blocker
1. **Phase 0 is not a spike (L267-333, L377, L194).** Steps 2-4 install rez, hand-write `maya`/`td_scripts` packages, a rezconfig and `probe_maya` (a near-final wrapper): the P1, P2 and P3 artifacts. P1-P3 then redo it, and "Nothing else is built until the gate passes" is false. Make P0 a throwaway answering only gate-deciding questions, and say whether artifacts are discarded or promoted.
2. **Ayon questions can be settled without rez (Step 1 vs Steps 2-4).** `EXEC_FIELD_RESULT`, `ARGS_PASSTHROUGH`, `ENV_LEAKS`, `PYTHONPATH_SURVIVES`, `AYON_PRESENT`, `PROJECT_OVERRIDE` need only the stub. Step 4 re-measures them with rez in the way (confounded). Split P0a (stub only; decides wrapper vs A vs G) and P0b (rez toggle, plugin-off).

## Major
3. **Gate table not exhaustive and contradicts Alt A rule (L361-370, L129, L206).** Row 3 repeats the `ARGS_PASSTHROUGH` test. "Alt A shrinks wrapper to the preset read" is self-contradictory: an Ayon field cannot read a preset file, so A drops the switch (it becomes Alt C, rejected). No row for A winning; row 6 conflicts with L370.
4. **Alt G built into decision structure but unscoped (L238-242, L333, L363).** Go-path "comparison from reading code, not tested" has no decision value; no-go "rewrite G as main design" is undefined. Keep G as a named fallback with no P0 work.
5. **Feature and detailed ranges disagree (L9, L183, L194, L34, L367).** P1-P3 partly pre-specified; architecture/trust model fixed before spike; row 5 says Goal 2/CUJ 2 "stay as written" while narrowing scope to in-house; P0 Steps 1/5 duplicate P4.
6. **Live Ayon dev variant mutated three times, manual revert (Steps 1, 4, 5; L376; L179).** Blast radius unbounded. Isolate with a named test variant/project first.
7. **Unverified flag incomplete in feature range (L98-121, L137, L141, L175).** Declarative rez claims; `maya-2026` vs version `2026.0` match has no field.
8. **Field/step overload (L335-355).** ~27 fields; `LICENSE_MECHANISM`, `RESOLVE_TIME_NAS`, NAS facts do not feed the gate. Keep gate-driving fields.

## Nit
9. NAS first touched "if it exists" with no schedule. 10. `probe_maya` unquoted `$(cat preset)` contradicts L133; mark throwaway. 11. Same risk repeated at L60/L168 and L61/L105. 12. Glossary adds length for an author who knows the terms.
