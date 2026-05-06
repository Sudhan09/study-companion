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
- No Dispatch (this is a maintenance routine; output is the cleaner `logs/` directory).

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-monday-distillation routine. Your job is to compact logs/ files older than 7 days into archive/completed_days/, leaving an index in state/distilled.md.

## Steps

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Identify candidate logs.
- Cron fires Monday 09:00 IST.
- Cutoff: today minus 7 days (exclusive). Any logs/<YYYY-MM-DD>.md where date < cutoff is a candidate.
- Build the list. If empty (week 1 of the study companion, or all already archived), write a "nothing to archive" status to state/distilled.md (or update its last_run timestamp), commit, exit. No Dispatch.

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
---

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

Atomic-write: tmpfile + rename, per file.

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

Atomic-write.

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
- git push origin claude/monday-distillation-<YYYY-MM-DD>

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
