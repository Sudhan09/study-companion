# study-companion

Sudhan's bootcamp study companion. Granted folder for Cowork (primary surface) and claude.ai/code (RTI surface).

**Design plan:** `docs/design-plan-snapshot.md` (repo-local snapshot; original at user-private location).
**Build plan:** `docs/build-plan-snapshot.md` (repo-local snapshot).

Do not fork curriculum XMLs into this repo. They live in the bootcamp pipeline (`Sudhan09/python_bootcamp_claude_code`, `config/` directory) and sync into `instructions/curriculum/` via the `study-curriculum-sync` cloud routine.

## Branch merge cadence

Routine output lands on dated `claude/<routine>-<YYYY-MM-DD>` branches per Anthropic's web-scheduled-tasks default-deny policy. Without merging, state is invisible to the next session. Cadence:

- **Daily (or as practical):** merge `claude/morning-briefing-*` and `claude/curriculum-sync-*` into `main` so today's session sees today's plan + today's curriculum scope. Quick pattern from `main`:
  ```bash
  git fetch origin
  for b in $(git branch -r | grep -E "origin/claude/(morning-briefing|curriculum-sync)" | sed 's|origin/||'); do
    git merge --no-ff "origin/$b" -m "merge: $b"
  done
  git push
  ```
  Or merge via the GitHub web UI.

- **Weekly (Monday morning):** merge the prior week's `claude/spaced-rep-*`, `claude/commit-reminder-*`, `claude/weekly-review-*`, `claude/monday-distillation-*`, `claude/drift-audit-*`. The `weekly-review-*` and `drift-audit-*` entries are the highest-value records; the rest are nudge artifacts that accumulate as audit trail.

- **Monthly:** review unmerged `claude/*` branches; if any are still unmerged, decide keep-or-discard. The `study-branch-cleanup` routine (Sun 11:30 IST) auto-deletes only branches that ARE merged AND >30 days old, so unmerged branches accumulate until you act on them.

If you let cadence slip: state files stay frozen on `main` (yesterday's `state/schedule.md`, last week's `state/active_weak_spots.md`, etc.), so SessionStart hooks inject stale context. The Stop hook's freshness check will surface ⚠️ STALE warnings >24h, which is your nudge.
