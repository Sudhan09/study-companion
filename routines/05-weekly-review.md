<!-- Per design §E #5 study-weekly-review. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->

# Routine 5: study-weekly-review

## Schedule
- **Cron (UTC):** `30 4 * * 0`
- **IST equivalent:** 10:00 Sunday
- **Frequency:** Weekly, Sunday morning (before drift-audit at 10:30)

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/weekly-review-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9.

## Reads
From study repo:
- `state/SOURCE_OF_TRUTH.md` (registry verification)
- `logs/*.md` for the last 7 days (today inclusive — but typically 6 prior days have content)
- `wins/*.md` with `date` frontmatter falling in the last 7 days
- `state/drift_log.md` — entries from the last 7 days only
- `state/active_weak_spots.md` (current state)
- `state/last_session_summary.md` (most recent debrief)

## Writes
- `state/weekly-review-<YYYY-MM-DD>.md` (single file per Sunday)

## Output target
- Commit + push to `claude/weekly-review-<YYYY-MM-DD>`.
- **Dispatch summary** to user's phone (3-5 line digest of the week).

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-weekly-review routine. Your job is to summarize the last 7 days of study activity into a structured review and Dispatch a digest. You are summarizing WHAT IS THERE, not interpreting or inventing.

## Steps

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Define the window.
- Cron fires Sunday 10:00 IST = 04:30 UTC.
- Window: last 7 IST days inclusive of today (i.e., previous Sunday-through-this-Sunday-morning, or whatever 7-day window the user prefers — default is "trailing 7 calendar days" ending today).

Step 3: Read inputs (with freshness checks).
For each input file, check the last_updated frontmatter where applicable. If older than expected (state files >7d for a weekly review is OK, but >14d is suspicious — flag), add a [STALE] note.

- logs/<date>.md for each date in the window. If a log file is missing for a date, that date had no logged session — note it as "no log" rather than fabricating activity.
- wins/*.md — read all, filter to those with date frontmatter in window.
- state/drift_log.md — parse entries (one per line, ISO timestamp prefix). Filter to entries in window.
- state/active_weak_spots.md and state/last_session_summary.md — current state, used for "where things stand now".

Step 4: Compute counts (only from data that's there — no estimates).
- Sessions logged: <count of log files in window>
- Days with zero sessions: <list of dates with no log>
- Wins captured: <count of wins/*.md in window>
- Drift log entries: <count by severity: hard / soft>; <count by failure #>
- Weak spots: <delta from a week ago — if the previous weekly-review file exists, diff the active_weak_spots count; otherwise just current count>

If the previous weekly-review file (state/weekly-review-<previous-Sunday>.md) doesn't exist, do NOT fabricate a delta. Say "no prior review for delta".

Step 5: Compose state/weekly-review-<YYYY-MM-DD>.md.

Schema:
---
last_updated: <ISO-8601>
updated_by: study-weekly-review
date: <YYYY-MM-DD>
window_start: <YYYY-MM-DD>
window_end: <YYYY-MM-DD>
stale_flags: [<list>]
---

# Weekly review — week ending <YYYY-MM-DD>

## Activity counts
- Sessions logged: <N>
- Days with no log: <list, or "0">
- Wins captured: <N>
- Drift entries: <total> (<hard count> hard, <soft count> soft)

## Wins this week
[For each win in window: bullet with date, concept, 1-line artifact summary. Reference the win file path. Do NOT paraphrase the artifact — quote it.]

## Drift patterns this week
[Top 3 by frequency, format: "failure #N (<severity>): <count>x. Examples: <up to 2 short detail quotes from drift_log>". If <3 distinct failures, list what's there. If 0 entries, write "No drift logged this week (note: claude.ai/code-only — Cowork sessions don't log drift per #40495)."]

## Weak spots — current state
- <id>: <pattern>, Band <N>, reps <X>/<Y>
[repeat for each entry in active_weak_spots.md as of now]

[If a prior weekly-review exists, add: "Delta vs week ending <prior-date>: <+/- counts, graduations, escalations>". Otherwise: "No prior weekly review for delta."]

## Open questions / unresolved
[From last_session_summary "Unresolved" + any logs/<date>.md sections tagged unresolved or open. Quote-don't-paraphrase.]

## Suggested focus next week
[2-3 bullets, deterministic from the data: highest-band weak spot → drill more; failure # with highest count → tightening candidate for /calibrate. NO speculative roadmap.]

Atomic-write: tmpfile + rename.

Step 6: Commit + push.
- git add state/weekly-review-<YYYY-MM-DD>.md
- git commit -m "chore(weekly-review): summary for week ending <YYYY-MM-DD>"
- git push origin claude/weekly-review-<YYYY-MM-DD>

Step 7: Dispatch summary.

Format (3-5 lines, ≤500 chars):
"Week ending <date>: <N> sessions, <N> wins, <N> drift entries (<H>h/<S>s). Top weak spot: <id> Band <N>. Top drift: failure #<N> <count>x. Full review: state/weekly-review-<date>.md."

If [STALE] flags set, prepend "[STALE]" and include 1 short reason.

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT estimate or interpolate counts. If logs are missing for a date, count it as "no log" — never make up sessions.
- DO NOT paraphrase win artifacts or drift detail quotes. Copy verbatim from the source files.
- DO NOT speculate about "trends" or "improvement trajectory" beyond what numeric deltas show.
- DO NOT push to main. Only claude/weekly-review-<date>.
- DO NOT skip the staleness check on inputs.
- DO NOT fabricate a delta if no prior review file exists.
```

## Success criteria
- `state/weekly-review-<YYYY-MM-DD>.md` exists with all sections (counts, wins, drift, weak spots, suggested focus).
- A new commit appears on `claude/weekly-review-<YYYY-MM-DD>` branch.
- A Dispatch summary arrives at user's phone with 3-5 lines.
- All numbers in the file map back to actually-counted source files (verifiable by spot-check).

## What this routine MUST NOT do
- MUST NOT estimate counts. Missing log = "no log" entry, not a guess.
- MUST NOT paraphrase win artifacts or drift quotes — copy verbatim.
- MUST NOT speculate about "trends" beyond literal numeric deltas.
- MUST NOT fabricate a week-over-week delta when no prior review exists.
- MUST NOT push to `main`. Only `claude/weekly-review-<date>`.
- MUST NOT skip Dispatch — the digest is the primary user-facing output of this routine.
