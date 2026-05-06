<!-- Per design §E #7 study-drift-audit. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->
<!-- Per design §E "Per-routine resilience" subsection: if drift_log empty or only Cowork sessions in window, write a no-data note rather than fabricating patterns. -->

# Routine 7: study-drift-audit

## Schedule
- **Cron (UTC):** `0 5 * * 0`
- **IST equivalent:** 10:30 Sunday (after weekly-review at 10:00)
- **Frequency:** Weekly, Sunday morning

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/drift-audit-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9.

## Reads
From study repo:
- `state/SOURCE_OF_TRUTH.md` (registry verification)
- `state/drift_log.md` — entries from the last 7 days only
- `state/weekly-review-<this-Sunday>.md` (just written by routine #5; cross-reference)
- `instructions/teaching-method.md` (the 5 locked rules — input for tightening proposals)

## Writes
- `state/drift-audit-<YYYY-MM-DD>.md` (frequency analysis + proposed teaching-method tightenings)

## Output target
- Commit + push to `claude/drift-audit-<YYYY-MM-DD>`.
- Executive summary in `state/drift-audit-<date>.md`'s `## Executive summary` section is the deliverable. No external Dispatch.

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-drift-audit routine. Your job is to analyze the last 7 days of state/drift_log.md entries and propose teaching-method tightenings — but ONLY when there's enough signal. Empty drift = empty audit, never fabrication.

## Steps

Step 0: Verify routine #5 (weekly-review) ran today.
- Read state/weekly-review-$(TZ=Asia/Kolkata date +%F).md. If missing, set FRESHNESS_FLAG=stale.
- If present, parse `last_updated` from frontmatter. If older than 30 minutes, set FRESHNESS_FLAG=stale.
- If FRESHNESS_FLAG=stale, prepend [STALE-WEEKLY-REVIEW] to the audit output. Do NOT abort — drift_log analysis can still run on its own data.

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Define the window.
- Cron fires Sunday 10:30 IST = 05:00 UTC.
- Window: trailing 7 calendar days ending now.

Step 3: Read state/drift_log.md.
- Schema (per design §F): each line is `<ISO timestamp> | session=<id> | failure=#<N> | severity=<hard|soft> | detail="<quote>"`.
- Parse entries; filter to those whose ISO timestamp is in the window.
- Note: drift_log entries are ONLY written by the Stop hook on claude.ai/code (per design §B + #40495 — Cowork hooks dormant). If the user did all study sessions in Cowork this week, drift_log will be empty for the window. That is a data-availability fact, NOT a "no drift happened" conclusion.

Step 4: Detect the no-data case.
If filtered entries == 0:
- Compose state/drift-audit-<YYYY-MM-DD>.md with the no-data schema (below).
- Write the no-data audit file (per schema below) and exit. The committed `state/drift-audit-<date>.md` is the user's polling surface.
- Commit + push. Exit.

DO NOT FABRICATE patterns. DO NOT infer drift from indirect signals (wins captured, weak spots active). The drift_log is the ONLY source for this routine's analysis.

Step 5: If entries > 0, compute frequencies.

For each unique failure number in the window:
- Count of hard occurrences
- Count of soft occurrences
- Up to 3 example detail quotes (verbatim)
- Distinct sessions affected (count unique session=<id> values for this failure)

Sort failures by total count desc.

Step 6: Identify top patterns (only what the data actually shows).

Top patterns are the failures with:
- Total count >= 3 in the window, OR
- count >= 2 AND distinct sessions == count (i.e., recurring across sessions, not one bad session)

Anything below this threshold is "tail" — list but don't elevate to "top pattern".

Step 7: Propose teaching-method tightenings.

For each top pattern, examine instructions/teaching-method.md for the rule it most directly relates to (the design ties failures to method rules — e.g., #3 stacked analogies → "One Analogy Per Concept"; #7 pulse-checks missed → "Inline Visualization"/"Teach Before"). Propose ONE specific, observable tightening per top pattern. Format:

  - Failure #<N> (<count>x in window, <distinct sessions> sessions)
    - Current rule reference: <quote 1 line from teaching-method.md>
    - Proposed tightening: <1-2 sentence specific change, e.g., "Add explicit pre-output check: if response contains >1 of [imagine, think of, picture, like a, consider it as], abort and pick one">
    - Estimated impact: <"high" (top-3 by count) | "moderate" | "low">

DO NOT propose tightenings for patterns that aren't top patterns. DO NOT propose changes to locked rules; tightenings are added to a separate teaching-method-tightenings.md (which the user reviews and applies manually if desired).

Step 8: Compose state/drift-audit-<YYYY-MM-DD>.md.

Schema (with-data case):
---
last_updated: <ISO-8601>
updated_by: study-drift-audit
date: <YYYY-MM-DD>
window_start: <YYYY-MM-DD>
window_end: <YYYY-MM-DD>
total_entries: <N>
distinct_sessions: <N>
data_source: state/drift_log.md
---

# Drift audit — week ending <YYYY-MM-DD>

## Frequency table (sorted by count desc)

| Failure | Hard | Soft | Total | Sessions | Top example |
|---|---|---|---|---|---|
| #<N> | <h> | <s> | <total> | <sessions> | "<verbatim quote>" |
[repeat]

## Top patterns
[Per step 6 + 7. Each entry: failure id, count, current rule, proposed tightening, impact.]

## Tail (below threshold)
[Brief list of failures that occurred but didn't cross the top-pattern threshold.]

## Caveats
- Drift logged only from claude.ai/code (Cowork sessions don't log drift per #40495). Distinct claude.ai/code sessions in window: <N>.
- If <N> is small (1-2), patterns may be noise — treat tightening proposals as hypotheses for next week, not firm changes.

## Executive summary (also in Dispatch)
<2-3 lines: total drift count, top failure id + count, top tightening proposal>

Schema (no-data case):
---
last_updated: <ISO-8601>
updated_by: study-drift-audit
date: <YYYY-MM-DD>
window_start: <YYYY-MM-DD>
window_end: <YYYY-MM-DD>
total_entries: 0
data_source: state/drift_log.md
status: no-data
---

# Drift audit — week ending <YYYY-MM-DD>

No claude.ai/code drift entries in the 7-day window.

## What this means
- Drift logging is claude.ai/code-only (Cowork hooks dormant per #40495).
- An empty window indicates either: (a) no claude.ai/code sessions ran this week (all study was in Cowork), OR (b) the Stop hook didn't fire (check state/.locks/session.lock timestamps).
- It does NOT mean "no drift happened" — Cowork drift is invisible to this routine.

## Action
- If (a): expected; no audit possible.
- If (b): investigate Stop hook health on claude.ai/code surface.

[No top patterns. No tightening proposals. Wait for next week's data.]

Atomic-write: use `bash scripts/atomic-write.sh <tmpfile> <dst>` (added in Task 3.10).

Step 9: Commit + push.
- git add state/drift-audit-<YYYY-MM-DD>.md
- git commit -m "chore(drift-audit): week ending <date> — <N> entries, <top-failure-id-or-no-data>"
- git push origin claude/drift-audit-$(TZ=Asia/Kolkata date +%F)

Step 10: Audit-trail file is the deliverable.
- The committed `state/drift-audit-<date>.md` contains the executive summary in its dedicated section.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. -->

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT fabricate drift patterns when drift_log is empty for the window. The "no-data" branch exists for a reason — use it.
- DO NOT infer drift from wins, weak spots, or session counts. The drift_log is the ONLY input for this routine's pattern analysis.
- DO NOT propose tightenings for patterns below the top-threshold — those are noise.
- DO NOT modify instructions/teaching-method.md directly. Proposed tightenings go in the audit file only; the user reviews and applies manually.
- DO NOT push to main. Only claude/drift-audit-<date>.
- DO NOT confuse "no entries this week" with "no drift this week" — surface the Cowork-vs-code-surface distinction in the caveats section.
- DO NOT paraphrase drift detail quotes. Copy verbatim from drift_log.md.
```

## Success criteria
- `state/drift-audit-<YYYY-MM-DD>.md` exists with either with-data or no-data schema, correctly chosen based on actual filtered entry count.
- A new commit appears on `claude/drift-audit-<YYYY-MM-DD>` branch.
- A Dispatch executive summary arrives at user's phone.
- If drift_log was empty in the window, no top patterns or tightenings appear — only the no-data note + caveats.
- All quoted drift details are byte-equal to entries in `state/drift_log.md`.

## What this routine MUST NOT do
- MUST NOT fabricate drift patterns when `drift_log.md` is empty for the window. Empty data = no-data schema, never invented patterns.
- MUST NOT infer drift from indirect signals (wins, weak spots, session count). drift_log.md is the SOLE input.
- MUST NOT propose tightenings for tail patterns (below top-threshold).
- MUST NOT modify `instructions/teaching-method.md` directly — tightenings are proposals only, applied manually by user.
- MUST NOT confuse "no entries this week" with "no drift this week" — surface the Cowork-vs-claude.ai/code distinction in caveats.
- MUST NOT paraphrase drift detail quotes — copy verbatim.
- MUST NOT push to `main`. Only `claude/drift-audit-<date>`.
