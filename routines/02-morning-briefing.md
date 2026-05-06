<!-- Per design §E #2 study-morning-briefing. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->
<!-- Routine #2 in cross-routine ordering: runs at 09:00 IST, AFTER routine #1 (curriculum-sync) at 08:30 IST. -->
<!-- Per design §E "Per-routine resilience" subsection: if #1 failed, this routine MUST detect staleness and Dispatch-alert rather than briefing on stale curriculum. -->

# Routine 2: study-morning-briefing

## Schedule
- **Cron (UTC):** `30 3 * * *`
- **IST equivalent:** 09:00 daily (every day of week)
- **Frequency:** Daily, 30 minutes after curriculum-sync (#1) — gives #1 time to complete + commit (cold-start sandbox + clone + LLM-driven sync routinely takes 5-10 min wall-clock)

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/morning-briefing-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9.

## Reads
From study repo:
- `state/SOURCE_OF_TRUTH.md` (registry verification, freshness reference)
- `state/current_day.md` (bootcamp + loop_week dimensions per design §J #11)
- `state/active_weak_spots.md` (priority drill targets)
- `state/last_session_summary.md` (yesterday's session debrief)
- `instructions/curriculum/progress_state.xml` (just-synced by routine #1 — verify timestamp)
- `instructions/curriculum/<active-chunk>.xml` (filename from `<active_files>` in progress_state)
- `instructions/curriculum/.last-sync-status` (verify routine #1 succeeded)

## Writes
- `state/schedule.md` (today's plan: blocks, drill targets, focus topic)
- `logs/<YYYY-MM-DD>.md` (header only — body filled by interactive session + Stop hook)

## Output target
- Commit + push to `claude/morning-briefing-<YYYY-MM-DD>`.
- The committed `state/schedule.md` is the user's polling surface (no external dispatch).
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. -->

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-morning-briefing routine. Your job is to write today's plan into state/schedule.md and stamp a header on logs/<today>.md, based on freshly-synced curriculum + current state files.

## Cross-routine prerequisite (DO NOT SKIP)

Routine #1 (study-curriculum-sync) runs at 08:30 IST and pushes to claude/curriculum-sync-<date>. You run at 09:00 IST. Before reading any curriculum file, you MUST verify routine #1 succeeded:

- Read instructions/curriculum/.last-sync-status.
- Confirm "status": "OK" AND the "timestamp" field's IST date matches today's IST date (`TZ=Asia/Kolkata date +%F`). Yesterday's success is NOT sufficient — routine #1 must have run today.
- If status is STALE, missing, or timestamp's IST date != today's IST date, you are briefing on stale curriculum. DO NOT proceed normally:
  1. The [STALE-CURRICULUM] flag in `state/schedule.md` IS the alert — morning-briefing surfaces it for the user to see when they read schedule.md.
  2. Continue with briefing BUT prepend the entire state/schedule.md output with a [STALE-CURRICULUM] warning block at the top, citing the sync status timestamp + reason.
  3. DO NOT invent scope or guess day numbers from memory. Use only what's already on disk; flag uncertainty.
  <!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. The committed state/schedule.md with [STALE-CURRICULUM] flag is the polling surface. -->

## Steps

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Verify curriculum freshness (per cross-routine prerequisite above). Set a STALE_FLAG variable accordingly.

Step 3: Read inputs:
- state/current_day.md — extract bootcamp.phase, bootcamp.completed_through_day, bootcamp.current_day, bootcamp.active_chunk, loop_week.current_day, loop_week.next_topic.
- state/active_weak_spots.md — list active entries (id, pattern, band, reps so far).
- state/last_session_summary.md — extract yesterday's "Completed" and "Unresolved" sections.
- instructions/curriculum/progress_state.xml — verify <completed_through_day> matches state/current_day.md (cross-check). Mismatch = freshness warning, do not silently overwrite.
- instructions/curriculum/<active-chunk>.xml — read today's expected concept block per current_day. Pull the day's micro-objective, drill bands, scope tokens.

For each input file, check the last_updated frontmatter (where applicable). If older than expected (state files >24h, curriculum >30 min from last sync), add a [STALE-INPUT] note to the briefing pointing at the offending file. DO NOT GUESS values from memory.

Step 4: Compose state/schedule.md.

Schema:
---
last_updated: <ISO-8601 with TZ>
updated_by: study-morning-briefing
date: <YYYY-MM-DD>
stale_flags: [<list of STALE_FLAGs encountered, or empty>]
---

# Today's plan — <YYYY-MM-DD> (Phase <P> • Day <D> • Loop Week Day <LWD>)

[If STALE_FLAG set: prepend a [STALE-CURRICULUM] or [STALE-INPUT] warning block here with specifics.]

## Topic
<from active-chunk.xml or current_day.md loop_week.next_topic>

## Block plan
- Block A (1.5h): <warm-up / review per loop-strategy.md>
- Block B (1.5h): <new mechanics from active-chunk for today's day>
- Block C (2h): <combined drills, Band <N> targeting active weak spot>

## Active weak spots in scope today
- <id> — <pattern> (Band <N>, reps so far <X>) → drill target: <specific drill name>
[repeat for each]

## Yesterday recap
**Completed:** <from last_session_summary>
**Unresolved:** <from last_session_summary; if non-empty, surface as a candidate for today's Block A>

## Curriculum anchor
[Phase <P> • Day <D> • Block <B>] — sourced from progress_state.xml + active-chunk.xml.

Atomic-write: use `bash scripts/atomic-write.sh state/schedule.md.tmp state/schedule.md` (added in Task 3.10).

Step 5: Stamp logs/<YYYY-MM-DD>.md header.

If logs/<YYYY-MM-DD>.md does not exist, create it with:
---
last_updated: <ISO-8601>
updated_by: study-morning-briefing
date: <YYYY-MM-DD>
---

# <YYYY-MM-DD> session log

## Morning briefing
<copy state/schedule.md content here, condensed to topic + block plan + weak spots>

## Sessions
[Stop hook will append here per session.]

## Commits today
[study-github-commit-reminder routine appends here at 20:30 IST.]

(If logs/<YYYY-MM-DD>.md already exists from an earlier routine run today — e.g., manual re-run — do NOT overwrite. Append a "## Re-briefing at <time>" section instead.)

Step 6: Commit + push.
- git add state/schedule.md logs/<YYYY-MM-DD>.md
- msg=$(printf 'chore(morning-briefing): plan for %s [%q/%q]%s' "$date" "$phase" "$day" "$stale_tag")
  git commit -m "$msg"
- git push origin claude/morning-briefing-$(TZ=Asia/Kolkata date +%F)

Step 7: Confirm audit-trail file is the deliverable.
- The committed `state/schedule.md` contains the day summary (Phase, Day, Loop Week, topic, weak spots) in its header.
- If any STALE flag was set during the run, [STALE-CURRICULUM] / [STALE-INPUT] tags are baked into the file at the top.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. Read the committed state/schedule.md. -->

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT brief on stale curriculum without flagging. If .last-sync-status is STALE/missing, the briefing top must say [STALE-CURRICULUM] (the file IS the alert).
- DO NOT invent the day number, phase, active chunk, or weak spots from memory. Read them from disk. If unreadable, flag.
- DO NOT push to main. Push only to claude/morning-briefing-<date>.
- DO NOT silently overwrite a current_day vs progress_state mismatch. Surface it in the briefing as a freshness warning.
- DO NOT skip the atomic-write pattern (tmpfile + rename) — a half-written schedule.md breaks the next session.
```

## Success criteria
- `state/schedule.md` exists with today's date, today's blocks, active weak spots, curriculum anchor.
- `logs/<YYYY-MM-DD>.md` exists with the morning-briefing header.
- A new commit appears on `claude/morning-briefing-<YYYY-MM-DD>`.
- If `.last-sync-status` was OK and within 30 min, no STALE flags in the briefing.
- If routine #1 failed, briefing is still produced but [STALE-CURRICULUM] is the first thing in `state/schedule.md` (the committed file IS the alert).

## What this routine MUST NOT do
- MUST NOT brief on stale curriculum silently. If routine #1 (curriculum-sync) failed or its `.last-sync-status` is missing/old, the briefing MUST be flagged `[STALE-CURRICULUM]` at the top of the committed `state/schedule.md`.
- MUST NOT fabricate day numbers, phase, active chunk filename, or weak-spot list. All must come from disk; missing data = staleness flag, never a guess.
- MUST NOT push to `main`. Only to `claude/morning-briefing-<date>`.
- MUST NOT silently reconcile current_day.md vs progress_state.xml mismatches — surface as freshness warning.
- MUST NOT skip the atomic-write helper (`scripts/atomic-write.sh`).
