<!-- Per design §E #3 study-spaced-rep-reminder. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->

# Routine 3: study-spaced-rep-reminder

## Schedule
- **Cron (UTC):** `30 13 * * 1-6`
- **IST equivalent:** 19:00 Mon-Sat (no Sunday — recovery / weekly review day)
- **Frequency:** 6 days/week, evening drill prompt

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/spaced-rep-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9.

## Reads
From study repo:
- `state/SOURCE_OF_TRUTH.md` (registry verification)
- `room-to-improve/state/current_state.md` (RTI patterns, current band per family)
- `state/active_weak_spots.md` (priority drill targets, reps so far)

## Writes
- `state/spaced-rep-<YYYY-MM-DD>.md` (today's recommended drill — single artifact for that date)

## Output target
- Commit + push to `claude/spaced-rep-<YYYY-MM-DD>` (IST date via `TZ=Asia/Kolkata date +%F`).
- Audit-trail file `state/spaced-rep-<date>.md` is the user's polling surface.

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-spaced-rep-reminder routine. Your job is to pick ONE drill targeting an active weak spot and write it to `state/spaced-rep-<date>.md` at 19:00 IST. The committed file is the user's polling surface.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. -->

## Steps

Step 0: Pause check (Path A v3 universal preamble; added 2026-05-07).

- Read `state/current_day.md`. If the file does not exist (bootstrap), proceed to Step 1.
- Parse the `mode` field from the YAML frontmatter. If absent, treat as `bootcamp`.
- If `mode != paused`, proceed to Step 1.
- If `mode == paused`:
  - Read `state/vacation.md`. If absent, log to stderr and exit 1.
  - Parse `suppress_routines`. Default per GAP-04 Option-B: `[study-morning-briefing, study-spaced-rep-reminder, study-github-commit-reminder]`.
  - If `study-spaced-rep-reminder` is NOT in `suppress_routines`, proceed to Step 1.
  - If `study-spaced-rep-reminder` IS in `suppress_routines`:
    1. Append to `state/missed_routines.md`: `| <today-IST-date> | study-spaced-rep-reminder | skipped-vacation | n/a |`. Use atomic-write helper. Create file if absent.
    2. Commit `chore(spaced-rep): skipped — mode=paused` and push to `claude/spaced-rep-<today-IST-date>`. Exit cleanly. No replay.

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Read inputs:
- room-to-improve/state/current_state.md — extract active families with non-empty patterns and their current bands.
- state/active_weak_spots.md — extract active entries: (id, pattern, band, reps_so_far, reps_to_graduate, drill_targets).

For each input, check last_updated frontmatter. If older than 24h, add [STALE] tag to the spaced-rep file output AND include a "[STALE input — RTI state may be ahead]" line in the file body.

Step 3: Pick a drill.
Selection algorithm (deterministic, not creative):
1. Sort active weak spots by: (band desc) → (reps_so_far asc) → (id asc). Top of sort = today's target.
2. From that weak spot's drill_targets list, pick the FIRST entry the user has not been prompted on within the last 3 days. Track this via state/spaced-rep-<previous-3-dates>.md inspection (read those files if they exist; if they don't, proceed with the first entry).
3. If active_weak_spots.md is empty (no active patterns), pick a Band 1 review drill from room-to-improve/state/current_state.md graduated families to keep them fresh.

DO NOT INVENT a drill if both sources are empty — that's a STALE condition. Write `state/spaced-rep-<date>.md` with body "no active weak spots and no graduated families to refresh — RTI state may not be syncing. Investigate." and exit. The committed file IS the alert.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. The committed state/spaced-rep-<date>.md is the user's polling surface. -->

Step 4: Compose state/spaced-rep-<YYYY-MM-DD>.md.

Schema:
---
last_updated: <ISO-8601>
updated_by: study-spaced-rep-reminder
date: <YYYY-MM-DD>
stale_flags: [<list>]
---

# Spaced rep — <YYYY-MM-DD>

## Target
- **Weak spot:** <id> — <pattern>
- **Band:** <N> (reps so far <X>/<reps_to_graduate>)
- **Source:** active_weak_spots.md (last_updated <ISO>) + room-to-improve/state/current_state.md (last_updated <ISO>)

## Drill prompt
<full drill prompt body — see Step 5 format>

## Selection rationale
<1-line: e.g., "Highest band among active (Band 2), lowest reps_so_far (1/3), drill not prompted in last 3 days">

Atomic-write: use `bash scripts/atomic-write.sh <tmpfile> <dst>`. DO NOT direct-Write to the destination — guards against half-written files if the routine is killed mid-run.

Step 5: Compose drill prompt body (written into the file's `## Drill prompt` section).

Format (keep <140 chars for readability):
"Spaced rep — <weak_spot_id>: <drill_name>. Band <N>. Reps <X>/<Y>. <1-line problem statement>."

Example:
"Spaced rep — A1: count_vowels. Band 2. Reps 1/3. Write a function that counts vowels in a string using a single loop, no built-ins."

If [STALE] flag is set, prepend "[STALE] " to the drill prompt body and include the staleness reason in 1 short clause.

Step 6: Commit + push.
- git add state/spaced-rep-<YYYY-MM-DD>.md
- git commit -m "chore(spaced-rep): <weak_spot_id> drill <drill_name> for <YYYY-MM-DD>"
- git push origin claude/spaced-rep-$(TZ=Asia/Kolkata date +%F)
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. The committed file is the user's polling surface. -->

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT invent a drill problem if active_weak_spots.md and room-to-improve are both empty. Write a "no targets, investigate" file body and exit.
- DO NOT pick a random drill — use the deterministic algorithm in step 3.
- DO NOT push to main. Only claude/spaced-rep-<date>.
- DO NOT skip the staleness check. Sudhan needs to know if the RTI state hasn't been updated.
- The committed state/spaced-rep-<date>.md IS the deliverable. No external dispatch.
```

## Success criteria
- `state/spaced-rep-<YYYY-MM-DD>.md` exists with target, band, drill prompt.
- A new commit appears on `claude/spaced-rep-<YYYY-MM-DD>` branch.
- The committed `state/spaced-rep-<YYYY-MM-DD>.md` is the user's polling surface; they read it for the day's drill.
- If both RTI state and active_weak_spots are empty, no drill is fabricated — instead, a "no targets" alert is dispatched.

## What this routine MUST NOT do
- MUST NOT fabricate a drill prompt when no active weak spots / RTI patterns exist. Empty state = "no targets" file body, written and committed.
- MUST NOT use a non-deterministic drill picker (no random, no LLM creativity for selection — only the deterministic sort+filter algorithm).
- MUST NOT push to `main`. Only `claude/spaced-rep-<date>`.
- MUST NOT silently ignore stale RTI state (>24h old). Tag `[STALE]` in the committed file.
