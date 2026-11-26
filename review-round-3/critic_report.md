# Stage 7: Critic (Design + Structural + Style, Round 3)

**Target:** lines 1-249. Reviewers: `egm-design`, `egm-structural`, `egm-style`. Behavior claims (rez/Ayon/Maya) unverified.

| Lens | Blocker | Major | Nit |
| :--- | :--- | :--- | :--- |
| Design | 0 | 8 | 9 |
| Structural | 0 | 2 | 10 |
| Style | 0 | 5 | 16 |
| **Total** | **0** | **15** | **35** |

## Design (Major)
1. **Preset option injection/globbing (L103, L125, L133, L175).** Unquoted expansion lets a word like `--paths` become a rez-env flag, bypassing "config owns search order". Read into an array with globbing off, reject words starting with `-`, add a smoke test.
2. **Ayon `PYTHONPATH` also reaches rez's own Python (L61, L105, L198E).** Could shadow modules rez needs (unverified). Test rez under the real Ayon environment; decide stash/re-inject.
3. **Arguments through `rez-env -- maya "$@"` (L125, L59).** Quoting/spaces may be lost (unverified). Add a case with spaces, quotes, `$`.
4. **Config precedence asserted (L110, L137).** `REZ_PACKAGES_PATH` and `~/.rezconfig` may override or merge (unverified). Wrapper should unset related `REZ_*`, consider `REZ_DISABLE_HOME_CONFIG=1`, and test that resolved `packages_path` is as intended.
5. **Hung NAS (L103, L82-86, L170).** Fail-closed check cannot detect a blocking mount; no timeout; resolve-time budget deferred so the gate has no threshold. State a provisional ceiling and a bounded check.
6. **Distribution of wrapper/preset/config to artist machines unspecified (L96, L133, L148-162, L179).** "Next launch" in Goal 2 depends on it; rez install on every machine unaddressed.
7. **Publishing and immutability unenforced (L146, L162, L192).** Release command not named; nothing stops overwriting a version. Name it now.
8. **Official-plugin off switch under-scoped (L34, L60, L168).** Maya user prefs autoload (`pluginPrefs.mel`, under out-of-scope `MAYA_APP_DIR`) can defeat "off". Add to the test matrix.

Design Nits: L3 stale round; running session unaffected not stated; CUJ 4 bare `rez-env` lacks wrapper-exported vars; local root leaks if Ayon started from that shell; unsetting `LD_LIBRARY_PATH` may break Maya (confirm Maya still starts); `exec` and Ayon PID/exit-code tracking; version/platform claims need P0 record; Alt G lacks a decision rule; no alternative for Ayon environment settings injection.

## Structural (Major)
1. **L185-187, L57: references to "Detailed Implementation Plan"/"Phase 0 section"/"outcome table" have no link** and, within the feature range, no definition. (Section exists at L250; add anchors.)
2. **L55-66: Open Questions are measurements, not decisions.** No owner, no tie to gate outcomes; use Question/Field/Decides/Fallback table.

Structural Nits: L3 stale; Risks/Rollout/Phases/Acceptance are H3 under Technical Plan (promote Risks & Mitigations); heading casing inconsistent; glossary has no heading; one `---` only; P0 row has no work; L194 dense sentence; diagram steps duplicate Wrapper section; sub-label bolding inconsistent; no legend for Alternative status values.

## Style (Major)
1. L9 vs L39: "Rez is installed" stated as fact but installing is a goal (P1).
2. L34 "guaranteed" overclaims before measurement.
3. L194 "(from review)" and seven-item semicolon chain.
4. L3 review-round metadata in the body.
5. Terms overloaded: request/preset/preset file; "baseline" means two things; "switch".

Style Nits (16): "build-out", "minimum contract (the baseline)", "extras", duplicate "alone unsets", "readable error", "wins", "half-configured", L144 grammar, L146 mixed rules, L150 "in this folder", L168 speculative, Phase 0 vs P0, L198 run-on, L234 "few moving parts", L240 colloquial, L241 "second mechanism" unspecified.
