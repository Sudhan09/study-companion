<!-- Per design §E #4 study-github-commit-reminder. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->

# Routine 4: study-github-commit-reminder

## Schedule
- **Cron (UTC):** `0 15 * * 1-6`
- **IST equivalent:** 20:30 Mon-Sat (no Sunday — review day)
- **Frequency:** 6 days/week, evening end-of-day commit nudge

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/commit-reminder-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9.

## Reads
From study repo (already cloned by routine sandbox):
- `state/SOURCE_OF_TRUTH.md` (registry verification)
- `state/repos.md` (optional list of additional repos to check; if missing, only checks study repo itself)
- Git log of study-companion: `git log --since=<YYYY-MM-DD>T00:00:00 --until=<YYYY-MM-DD>T20:30:00 --author=<configured>`

## Writes
- `logs/<YYYY-MM-DD>.md` — append a `## Commit reminder` section regardless of outcome (audit trail).

## Output target
- Commit + push to `claude/commit-reminder-<YYYY-MM-DD>`.
- **Dispatch only when zero commits today** (otherwise silent — no spam on productive days).

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-github-commit-reminder routine. Your job is to count today's commits across the user's repos and Dispatch a nudge ONLY if zero commits happened today.

## Steps

Step 1: Read state/SOURCE_OF_TRUTH.md and verify the registry is current.

Step 2: Determine "today" in IST.
- Cron fires at 15:00 UTC = 20:30 IST.
- "Today" = the IST calendar day. Convert: midnight-IST-today (which is 18:30-UTC-yesterday) through now.
- Use ISO date string YYYY-MM-DD for the IST date as the canonical "today".

Step 3: Build the repo list.
- Always include: the study-companion repo itself (already cloned in your sandbox).
- If state/repos.md exists: parse it. Schema is one repo URL or path per line, lines starting with "#" are comments. Add each to the list.
- If state/repos.md is missing or empty, just check study-companion.

Step 4: Count commits per repo, today.
For each repo:
- Run: git log --since="<YYYY-MM-DD>T00:00:00+05:30" --until="<YYYY-MM-DD>T20:30:00+05:30" --pretty=format:"%h %s"
- Count lines.
- For repos other than study-companion: if the routine sandbox cannot clone/access them (auth, network), record as "unreachable" — do NOT assume zero (that would be a false negative leading to a wrong Dispatch).

Total commits today = sum of counts across reachable repos. Track unreachable repos separately.

Step 5: Append to logs/<YYYY-MM-DD>.md.

If logs/<YYYY-MM-DD>.md does not exist, create it with a minimal frontmatter (this can happen if morning-briefing routine #2 failed earlier today).

Append:

## Commit reminder (<HH:MM> IST)
- **Today's commits:** <total>
- **Per repo:**
  - study-companion: <N> commits
  - <other-repo-1>: <N> commits or "unreachable"
  - ...
- **Recent commit subjects (last 5):** <list, newest first>
- **Status:** <"productive day" | "no commits — Dispatch sent" | "unreachable repos — partial count">

Step 6: Commit + push.
- git add logs/<YYYY-MM-DD>.md
- git commit -m "chore(commit-reminder): <total> commits today across <N> repos"
- git push origin claude/commit-reminder-<YYYY-MM-DD>

Step 7: Dispatch (CONDITIONAL).

Send Dispatch ONLY IF:
- Total commits today across reachable repos == 0, OR
- All non-study-companion repos were unreachable AND study-companion has 0 commits.

Dispatch message format:
- Zero commits + all reachable: "No commits today across <N> repos. Quick win before sleep? logs/<date>.md updated."
- Zero commits + some unreachable: "No commits in reachable repos (<list>); <N> unreachable. Verify auth or commit somewhere."

If commits > 0, send NO Dispatch. The audit trail in logs/ is sufficient.

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT count commits in the routine's own future commit (the chore commit-reminder commit you're about to make). Count strictly user-authored commits BEFORE the cron fires.
- DO NOT assume an unreachable repo has zero commits. Mark it unreachable explicitly. False zero leads to false-positive Dispatches.
- DO NOT push to main. Only claude/commit-reminder-<date>.
- DO NOT spam. If commits > 0, the file write is the only output. Dispatch is for silence-broken-by-zero-days.
- DO NOT use --author with a guessed email. If the configured author isn't known reliably, count all commits in the window (the user is the only committer in their personal repos).
```

## Success criteria
- `logs/<YYYY-MM-DD>.md` has a `## Commit reminder` section with today's count + per-repo breakdown.
- A new commit appears on `claude/commit-reminder-<YYYY-MM-DD>`.
- Dispatch arrives at phone IFF total commits today == 0 (or all non-study repos unreachable + study has 0).
- On productive days (commits >0), no Dispatch is sent.

## What this routine MUST NOT do
- MUST NOT count its own about-to-be-made chore commit as a "commit today" — that creates a self-fulfilling productive-day signal.
- MUST NOT treat unreachable repos as zero-commit. Unreachable ≠ silent.
- MUST NOT push to `main`. Only `claude/commit-reminder-<date>`.
- MUST NOT Dispatch on productive days. The whole point is to interrupt only on zero-commit days.
- MUST NOT skip the audit log even on productive days — the per-repo breakdown is useful weekly-review input.
