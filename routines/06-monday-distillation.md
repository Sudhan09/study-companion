<!-- Per design §E #6 study-monday-distillation. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->

# Routine 6: study-monday-distillation

## Schedule
- **Cron (UTC):** `30 3 * * 1`
- **IST equivalent:** 09:00 Monday
- **Frequency:** Weekly, Monday morning (after Sunday's review + drift-audit)

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/monday-distillation-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9.

## Reads
From study repo:
- `state/SOURCE_OF_TRUTH.md` (registry verification)
- `logs/*.md` files **older than 7 days** (i.e., file's date frontmatter or filename date is more than 7 days before today)
- `state/distilled.md` (the running index, if it exists)

## Writes
- `archive/completed_days/<YYYY-MM-DD>.md` — one per archived log
- `state/distilled.md` — running index of archived dates with 1-line summary each
- Removes (via `git mv`) the source `logs/<YYYY-MM-DD>.md` files that were archived

## Output target
- Commit + push to `claude/monday-distillation-<YYYY-MM-DD>`.
- This is a maintenance routine; output is the cleaner `logs/` directory and the running `state/distilled.md` index.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. -->

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-monday-distillation routine. Your job is to compact logs/ files older than 7 days into archive/completed_days/, leaving an index in state/distilled.md.

**First action (Path A v3 followup — added 2026-05-08):** Before any other step, run `git checkout -B claude/monday-distillation-$(TZ=Asia/Kolkata date +%F)`. This is a no-op for cron-fired runs (working branch is already canonical) and a fixup for manually-fired runs from the /schedule UI (which start on a random-slug working branch). After the checkout, all subsequent commits + pushes target the auto-merge workflow's allowlist.

## Steps

Step 0: Pause check (Path A v3 universal preamble; added 2026-05-07).

- Read `state/current_day.md`. If the file does not exist, proceed to Step 1.
- Parse `mode`. If absent, treat as `bootcamp`. If `mode != paused`, proceed to Step 1.
- If `mode == paused`: read `state/vacation.md`. If absent, exit 1. Parse `suppress_routines`. By default, `study-monday-distillation` is NOT suppressed (it must run to annotate `vacation_gap` logs per CRIT-07). Proceed to Step 1; the downstream distillation logic checks `vacation.md.start_date`/`end_date` and labels each archived log accordingly.
- If user has explicitly added `study-monday-distillation` to `suppress_routines`: append entry, commit `chore(monday-distillation): skipped — mode=paused`, push, exit cleanly.

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Identify candidate logs.
- Cron fires Monday 09:00 IST.
- Cutoff: today (IST) minus 7 days. Any logs/<YYYY-MM-DD>.md where the date in its filename is strictly less than (today_IST - 7 days) is a candidate. Today's log (if morning-briefing already wrote it) MUST be excluded — verify by computing today_IST = `TZ=Asia/Kolkata date +%F` and comparing as strings.
- Build the list. If empty (week 1 of the study companion, or all already archived), write a "nothing to archive" status to state/distilled.md (or update its last_run timestamp), commit, exit.

Step 3: For each candidate log, distill it.

Distillation = preserve signal, drop chatter. The distilled archive file should be roughly 30-50% the size of the original log, retaining:
- Session count + start/end times
- Topics covered (1 line per session)
- Concepts that hit a "lock-in" or generated a win (linked to wins/<date>-*.md if so)
- Drill outcomes (band, pattern, pass/fail summary — not full transcripts)
- Unresolved items
- Drift entries logged on that date (count by severity, top 1-2 examples by source quote)

Schema for archive/completed_days/<YYYY-MM-DD>.md:
---
last_updated: <ISO-8601>
updated_by: study-monday-distillation
date: <YYYY-MM-DD>          # original log date
archived_on: <YYYY-MM-DD>    # today
source_log: logs/<YYYY-MM-DD>.md
type: <study_session | vacation_gap>   # Path A v3 CRIT-07 — see vacation-window logic below
---

Vacation-window check (Path A v3 CRIT-07):
- If `state/vacation.md` exists at distillation time, parse `start_date` and `end_date` (both ISO-8601 with offset). Convert to IST-date strings.
- For each candidate log file dated `<D>`: if `start_date_IST <= D <= end_date_IST` (inclusive both ends; treat null end_date as still-active), set `type: vacation_gap`. Otherwise `type: study_session`.
- If `state/vacation.md` does NOT exist (the common case), check `archive/vacations.md` append-log for any historical vacation that covered `<D>`. If found, set `type: vacation_gap`. Otherwise `type: study_session`.
- `vacation_gap`-typed archives MUST be excluded from the session-count column in `state/distilled.md`. The row is still appended (as audit trail), but with `Sessions: 0 (vacation_gap)` instead of any positive number, and `Wins/Drills/Drift` columns all zero.

# <YYYY-MM-DD> — distilled

## Sessions
- Session 1 (<HH:MM>-<HH:MM>): <topic>
[repeat]

## Concepts locked
- <concept> → wins/<file>.md (if win was created that day)
[or "None this day"]

## Drills
- <drill>: Band <N>, <pattern_id>, <result>
[or "None this day"]

## Drift on this date
- <count> total (<H>h/<S>s); top: <verbatim detail quote>
[or "None"]

## Unresolved (carried forward)
- <quote from log>
[or "None"]

Atomic-write: use `bash scripts/atomic-write.sh <tmpfile> <dst>` (added in Task 3.10). DO NOT use direct Write to the destination — guards against half-written files if the routine is killed mid-run.

Step 4: Update state/distilled.md (the running index).

If state/distilled.md does not exist, create it with frontmatter:
---
last_updated: <ISO-8601>
updated_by: study-monday-distillation
last_run: <YYYY-MM-DD>
---

# Distilled archive index

| Date | Sessions | Wins | Drills | Drift | File |

Append one row per newly archived date (and merge with any existing rows; sort by date desc). Each row links to archive/completed_days/<date>.md.

Atomic-write: use `bash scripts/atomic-write.sh <tmpfile> <dst>` (added in Task 3.10). DO NOT use direct Write to the destination — guards against half-written files if the routine is killed mid-run.

Step 5: Remove source logs.
For each successfully archived date:
- git mv logs/<YYYY-MM-DD>.md archive/completed_days/.source-<YYYY-MM-DD>.md
  (Move-don't-delete: keeping the original under a hidden prefix preserves it for one cycle in case distillation lost something. Next Monday's run will purge .source-* files older than 14 days from archive/completed_days/.)
- OR if the user prefers hard-delete, just `git rm` the source. Default: move with prefix.

Step 6: Purge old .source-* preservation files.
List archive/completed_days/.source-*.md. For any older than 14 days, git rm them. This keeps a 1-week safety net without indefinite accumulation.

Step 7: Commit + push.
- git add archive/completed_days/ state/distilled.md
- git rm -- (any removed files; git mv handles staging)
- git commit -m "chore(monday-distillation): archived <N> logs from <oldest-date> to <newest-archived>"
- git push origin claude/monday-distillation-$(TZ=Asia/Kolkata date +%F)

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT invent sessions, drill outcomes, or wins. Distill only what's in the source log. Empty sections stay empty ("None this day").
- DO NOT paraphrase wins or drift quotes — link to win files and quote drift verbatim.
- DO NOT delete logs without first writing the archive file. Order: archive write → state/distilled.md update → git mv source. If archive write fails, source stays.
- DO NOT push to main. Only claude/monday-distillation-<date>.
- DO NOT touch logs newer than the 7-day cutoff. Those are still active.
- DO NOT touch logs/sessions/ files (per-session granular logs) — they live alongside daily logs and follow their own lifecycle. This routine archives only logs/<date>.md.
```

## Success criteria
- For each candidate log older than 7 days, an `archive/completed_days/<date>.md` distilled version exists.
- `state/distilled.md` has rows for all newly archived dates, sorted desc.
- Source `logs/<date>.md` files for archived dates are gone (moved to `.source-*.md` or deleted), leaving `logs/` clean of >7d files.
- A new commit appears on `claude/monday-distillation-<YYYY-MM-DD>`.
- `logs/sessions/` is untouched.

## What this routine MUST NOT do
- MUST NOT fabricate distilled content. If the source log is sparse, the archive is sparse — "None this day" is a valid section value.
- MUST NOT paraphrase wins or drift entries — link/quote verbatim.
- MUST NOT delete a source log before its archive file is fully written. Order: archive → index → mv source.
- MUST NOT push to `main`. Only `claude/monday-distillation-<date>`.
- MUST NOT touch logs newer than the 7-day cutoff or the `logs/sessions/` subdirectory.
- MUST NOT keep `.source-*.md` preservation files indefinitely — purge >14d.
