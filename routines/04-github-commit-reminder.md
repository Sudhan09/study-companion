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
- Commit + push to `claude/commit-reminder-<YYYY-MM-DD>` (IST date via `TZ=Asia/Kolkata date +%F`).
- On zero-commit days, commit message includes a `[ZERO-COMMIT]` tag so the user can grep for nudge days. No external Dispatch.

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
- If state/repos.md exists, parse it tolerantly:
  1. Strip YAML frontmatter (everything between the first two `---` lines) — `state/repos.md` is markdown with frontmatter, not bare lines.
  2. Strip HTML comments (`<!-- ... -->`).
  3. Strip markdown headers (`# ...`), prose paragraphs (lines that don't match `^- ?<owner>/<repo>$` or `^<owner>/<repo>$`), and blank lines.
  4. For each remaining line, strip leading `- ` if present. The result is a list of `<owner>/<repo>` tokens.
  5. Validate each token matches `^[A-Za-z0-9_-]+/[A-Za-z0-9_.-]+$`. Skip tokens that don't.
- If parsing fails or yields zero repos, fall through to study-companion only.
- If state/repos.md is missing or empty, just check study-companion.

Step 4: Count commits per repo, today.
For each repo:
- Run: git log --since="<YYYY-MM-DD>T00:00:00+05:30" --pretty=format:"%h %s" (no --until — count to "now"). Filter out the routine's own about-to-be-made commit by author email: add --invert-grep --grep="commit-reminder". If the configured author matches the routine's bot identity, also add --author=! <bot-email>.
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

Step 7: Tag commit message based on outcome.
- If total commits today across reachable repos == 0, OR all non-study-companion repos were unreachable AND study-companion has 0 commits, append `[ZERO-COMMIT]` to the commit message subject.
- Otherwise, the commit message tag is omitted — productive days are silent.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. The committed logs/<date>.md "## Commit reminder" section + commit-message tag together provide the audit trail. -->

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
