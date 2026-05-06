<!-- Per design §G: bootcamp pipeline repo (Sudhan09/python_bootcamp_claude_code, config/ directory) is the authoritative source. -->
<!-- This directory is synced daily by the `study-curriculum-sync` cloud routine (§E #1, 08:30 IST / 03:00 UTC). -->
<!-- Do not edit files here manually — they will be overwritten on the next sync. -->

# instructions/curriculum/

Synced from the bootcamp pipeline repo. Read by `instructions/scope-purity.md` and the SessionStart hook (claude.ai/code) when scope questions arise.

**Authoritative source:** Sudhan09/python_bootcamp_claude_code, `config/` directory
**Sync routine:** `study-curriculum-sync` (cron `0 3 * * *` UTC)
**Files synced (per design §E #1):**
- `progress_state.xml` — `<completed_through_day>`, `<active_files>`, current phase
- `deviation_log.xml` — `<scope_additions>` per phase (registry-enforceable scope)
- `rules.xml` — cardinal rules (Rule 1 scope-purity, Rule 6 missing-file STOP)
- `scope_registry.xml` — explicit scope registry
- Active curriculum chunk per `progress_state.xml`'s `<active_files>` (currently `curriculum_weeks04-06.xml`)
- `structure_current.xml` (currently `structure_phase2.xml`)

**Empty at build time** — first populated by the routine's first run.
