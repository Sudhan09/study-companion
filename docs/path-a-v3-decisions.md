<!-- Final user decisions on Path A v3 design. Verified by consequence-trace agent on 2026-05-07. -->
<!-- Reference: docs/path-a-v3-design-research.md (research findings) + docs/path-a-v3-issues.md (issue inventory) -->
<!-- This document supersedes any conflicting recommendations in the research doc. -->

# Path A v3 — Locked Design Decisions

**Status:** Approved by Sudhan, verified by consequence-trace audit.
**Date:** 2026-05-07
**Effect on estimate:** 45–65h → **38–58h** (CRIT-13 elimination saves 5–7h).

---

## Decisions (Q1–Q10)

### Q1 — Replay strategy
✅ **Option-C: NO back-dated replay.**

Mid-day skip = missed routines for that day are dropped (recorded in `state/missed_routines.md` as "skipped (vacation)" for audit trail, but not replayed).

Rationale: CRIT-15 evidence — 7-day pause × 8 routines = 56 catch-up pushes would overflow Actions concurrency queue. Per `docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax`: "By default, any existing pending job or workflow in the same concurrency group will be canceled."

**Implementation:**
- `state/missed_routines.md` exists as audit log only, not replay queue
- `/resume-routines` does NOT iterate through missed entries
- Daily-wrap's MISSING section is the observable signal that routines didn't fire

---

### Q2 — `/pause-routines` surface availability
✅ **BOTH Cowork + Claude Code app, with documented asymmetric confirmation.**

**Cowork (local Cowork sandbox):**
- `gh` CLI is locally installed
- Skill polls `gh run list --workflow=auto-merge-and-notify --branch=claude/pause-routines-<date>` for merge confirmation
- Confirmation level: "merge landed on main"

**Claude Code app (cloud session):**
- `gh` CLI NOT pre-installed (per `code.claude.com/docs/en/claude-code-on-the-web`)
- Fallback: `git ls-remote origin claude/pause-routines-<date>` confirms push only
- Confirmation level: "push landed; watch Slack for merge"

**Skill output MUST say:** "Pause pushed. On Cowork: poll confirms merge. On Code app: watch Slack for merge confirmation within ~3 min."

**Idempotency guard (closes CRIT-12):** First action in skill body is `git fetch origin main && git diff HEAD origin/main -- state/vacation.md`. If diff non-empty: error "Pause already in progress — wait for Slack confirmation before re-invoking."

---

### Q3 — Branch protection on `main`
✅ **VERIFIED OFF** (via `gh api repos/Sudhan09/study-companion/branches/main/protection` → HTTP 404 "Branch not protected").

**Implementation:**
- No GitHub App token bypass needed — `GITHUB_TOKEN` works as-is
- R-01 risk register entry → "low/zero probability"
- **Document in workflow YAML:** "If branch protection is ever enabled, replace `GITHUB_TOKEN` with `actions/create-github-app-token` per R-01 mitigation."

---

### Q4 — Inline pipeline-clone in `/resume-routines`
🤷 **MOOT under Q10.**

Q10's user-maintained `current_day` eliminates CRIT-13's auto-compute path. `/resume-routines` no longer needs `progress_state.xml` to be fresh because it doesn't read `progress_state.xml.completed_through_day` at all. No inline curriculum-sync needed.

**Effect:** Skip Q4 implementation entirely. CRIT-13 disappears.

---

### Q5 — Hooks pause-awareness scope
⚠️ **Stop + `/day-wrap` + UserPromptSubmit (3, not 2).**

| Hook/Skill | V1 scope | Reason |
|---|---|---|
| `stop.js` | ✅ Required | Prevents drift_log corruption from casual vacation sessions (CRIT-14) |
| `/day-wrap` skill | ✅ Required | Prevents `bootcamp.current_day` increment during pause (state corruption) |
| `user-prompt-submit.js` | ✅ Required | Catches `:wrap`-while-paused token before it routes to `/day-wrap` |
| `session-start.js` | ⏭️ V2 | Cosmetic — pause-banner is nice-to-have |
| PreCompact (no current handler) | ⏭️ V2 | vacation.md snapshot only matters if mid-vacation context compacts |

**Implementation in V1:**
- `stop.js`: read `state/current_day.md`, if `mode == paused`, early-return without appending drift_log
- `/day-wrap` SKILL.md: add pause-guard at top — refuse to advance day if paused
- `user-prompt-submit.js`: extend WRAP_RE handler — if `:wrap` token detected AND `state/current_day.md.mode == paused`, inject confirmation prompt instead of routing

---

### Q6 — Slack username/icon/channel cleanup
✅ **Remove. 4-line change in `post-to-slack.sh:42-47`.**

```bash
# OLD (lines 42-47):
payload=$(jq -n \
  --rawfile text "${text_file}" \
  --arg username "Asta" \
  --arg icon ":dagger_knife:" \
  --arg channel "#study-routines" \
  '{text: $text, username: $username, icon_emoji: $icon, channel: $channel}')

# NEW:
payload=$(jq -n \
  --rawfile text "${text_file}" \
  '{text: $text}')
```

Per `docs.slack.dev/messaging/sending-messages-using-incoming-webhooks`: "You cannot override the default channel, username, or icon." These three fields are silently ignored on modern app-attached webhooks.

---

### Q7 — `git commit --allow-empty` for markers
❌ **NOT IN SCOPE for Path A v3.**

No specific fix in Path A v3 requires empty marker commits. The current workflow's "already-merged" path (auto-merge-and-notify.yml:178-180) handles no-op cases without empty commits. Daily-wrap heartbeat uses `git log --grep` on actual merge commits.

**Skip this question entirely** — it's premature.

---

### Q8 — Resume Slack format
✅ **Verbose.**

Format:
```
✅ Resumed at <HH:MM> IST
─────────────────
📍 bootcamp Day <N>
🎯 loop_week: <active Day X | paused | completed>
📅 First task: <today's morning briefing fires at 09:00 IST>
🛬 Vacation duration: <N> days
─────────────────
🔗 Branch: claude/resume-routines-<date>
🔀 Merged to main: <SHA>
```

Total ~600 chars including envelope. Well under Slack's 4KB recommended cap.

---

### Q9 — 30-day cap escalation
✅ **Persistent ALERT in daily-wrap until manually cleared.**

`build-daily-wrap.sh` ALERTS array gets a new check:

```bash
if [ -f "state/vacation.md" ]; then
  start_date=$(awk '/^start_date:/ { print $2; exit }' state/vacation.md)
  days_paused=$(( ( $(TZ=Asia/Kolkata date +%s) - $(TZ=Asia/Kolkata date -d "${start_date}" +%s) ) / 86400 ))
  if [ "${days_paused}" -gt 30 ]; then
    over_limit=$(( days_paused - 30 ))
    ALERTS+=("⚠️ Pause exceeds 30-day cap (day ${over_limit} over limit) — run /resume-routines or update vacation.md")
  fi
fi
```

Fires every day after day 30. User clears by running `/resume-routines` (which removes `vacation.md`).

---

### Q10 — Resume day calculation
✅ **Don't auto-compute. `bootcamp.current_day` is user-maintained.**

#### Rationale (verified via consequence trace)

Per `state/current_day.md`: `current_day: 35` but `completed_through_day: 21`. These track different things:
- `bootcamp.current_day` = where Sudhan IS in the curriculum (his actual progress)
- `progress_state.xml.completed_through_day` = how much content has been GENERATED in the pipeline

Sudhan generates 10+ days of curriculum content in batches without studying them all (per CLAUDE.md and SECURITY.md). Auto-computing `current_day = completed_through_day + 1` would jump him forward past content he hasn't studied.

#### Required changes

**1. Add `user` to ALLOWED_WRITERS for `current_day.md`** (CRITICAL — Q10 blocker):

In `scripts/validate-state-schemas.js:19`:
```javascript
// OLD:
'current_day.md': ['build-init', '/day-wrap'],
// NEW:
'current_day.md': ['build-init', '/day-wrap', '/pause-routines', '/resume-routines', 'user'],
```

Without this, manual edits with `updated_by: user` fail validation, blocking the whole flow.

**2. Redesign CRIT-06** (was: auto-compute from pipeline; now: user-confirm prompt):

`/resume-routines` skill body:
```
1. Read state/current_day.md
2. Display: "Currently at bootcamp Day <N>. Resume here? (y/n)"
3. If yes: leave bootcamp.current_day unchanged
4. If no: prompt "What day to resume? (number)" → set bootcamp.current_day = <user input>
5. Update updated_by: /resume-routines
6. Continue with rest of /resume-routines flow
```

**3. Eliminate CRIT-13 entirely**:

CRIT-13's "inline curriculum-sync before resume-day calc" is no longer needed because there IS no auto resume-day calc. Remove from implementation plan. Saves 5-7h.

**4. Update SOURCE_OF_TRUTH.md**:

Writer column for `current_day.md` becomes: `/day-wrap, /pause-routines, /resume-routines, user`.

#### Side effects (all benign)

- Morning-briefing reads `bootcamp.current_day` → still works correctly (just doesn't get auto-incremented)
- Carry-forward semantics → unchanged (Option-C means no replay anyway)
- Loop_week → bootcamp transition → `/day-wrap` handles via mode change, `bootcamp.current_day` left alone
- Validators → already check schema, not temporal monotonicity (no monotonicity assumption to break)
- Other routines (#3, #5, #6, #7) → don't read `bootcamp.current_day`, unaffected

---

## New findings to incorporate

### Finding 1: Validator blocker for Q10
File: `scripts/validate-state-schemas.js:19`
Change: Add `user`, `/pause-routines`, `/resume-routines` to `current_day.md` ALLOWED_WRITERS.
**Must ship in Phase 1 alongside `mode` field addition.**

### Finding 2: CRIT-13 disappears
The whole CRIT-13 cascade (resume needs fresh curriculum-sync inline) is eliminated under Q10. Remove from CRIT list. Implementation plan reduces by 5-7h.

### Finding 3: CRIT-06 redesigned
Was: "/resume-routines reads `progress_state.xml.completed_through_day + 1`."
Now: "/resume-routines displays current `bootcamp.current_day`, prompts user to confirm or change."

### Finding 4: CRIT-09 verified still open
`build-daily-wrap.sh` has zero references to `state/vacation.md` or `current_day.md.mode`. The CRIT-09 fix (mode-awareness) is required code work, not yet done.

### Finding 5: CRIT-14 verified still open
`stop.js` lines 179-313 have zero check for `state/current_day.md.mode`. The CRIT-14 fix (Stop-hook pause-skip) is required code work, not yet done.

---

## Updated implementation phases (post-Q10)

| Phase | Original hours | Adjusted hours | Reason |
|---|---|---|---|
| Phase 1 — Schema + Validators | 5–8h | 5–8h | Same — adds `user` to ALLOWED_WRITERS |
| Phase 2 — Routine Step 0 Preamble | 8–12h | 8–12h | Same |
| Phase 3 — Skills | 10–15h | **5–8h** | CRIT-13 elimination + simpler /resume-routines |
| Phase 4 — Workflow + Observability | 5–8h | 5–8h | Same |
| Phase 5 — Hardening + Documentation | 5–8h | 5–8h | Same |
| **TOTAL** | **45–65h** | **38–58h** | -5 to -7h via Q10 |

---

## Open Q items NOT requiring further user input

Q4 is moot (eliminated by Q10).
Q7 is dropped (no Path A v3 fix needs `--allow-empty`).
All other questions have locked answers above.

---

## Hand-off note for executor

This document supersedes any conflicting guidance in `path-a-v3-design-research.md`. Specifically:

- **Section 1 CRIT-13:** REMOVE entirely from implementation plan
- **Section 2 CRIT-06:** REPLACE auto-compute logic with user-confirm prompt design
- **Section 6 Open Question #4:** Skip — Q10 makes inline-clone unnecessary
- **Section 6 Open Question #7:** Skip — empty markers not needed
- **Section 6 Open Question #10:** Resolved per Q10 above

All other Path A v3 design decisions stand as documented in the research doc.
