<!-- Per design §E #1 study-curriculum-sync. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->
<!-- Routine #1 in cross-routine ordering: runs at 08:30 IST, BEFORE routine #2 (morning-briefing) at 08:45 IST. -->

# Routine 1: study-curriculum-sync

## Schedule
- **Cron (UTC):** `0 3 * * *`
- **IST equivalent:** 08:30 daily (every day of week)
- **Frequency:** Daily, before morning briefing (#2)

## Repository config
- **Repo:** Sudhan09/study-companion (private)
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on this repo per build Phase 1.7). No PAT in env vars.
- **Branch policy:** push to `claude/curriculum-sync-<YYYY-MM-DD>`. Default-deny on main per design §H Rule 9 (`claude/`-prefix is the safety net).
- **Pipeline repo access:** routine must be configured to ALSO be able to read the bootcamp pipeline repo at `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\` (or the cloud-side equivalent if mirrored). The pipeline repo is **READ-ONLY** for this routine.

## Reads
From the bootcamp pipeline repo at `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\` (read-only):
- `progress_state.xml` (authoritative day/phase/block, drives `<active_files>` selection)
- `deviation_log.xml` (scope additions/removals — required for scope-purity rule)
- `rules.xml` (engineering rules)
- `scope_registry.xml` (allowed/forbidden concept lists)
- The active curriculum chunk per `progress_state.xml`'s `<active_files>` element. As of build, this is `curriculum_weeks04-06.xml` — but the routine MUST read `<active_files>` and use whatever it points to, not the hardcoded name.
- `structure_current.xml` (current bootcamp structure)

**Files explicitly skipped** (do not copy):
- `transition_map.xml` (verifier-only, not session-load)
- `transition_briefs/` (verifier-only)
- `quality_gates.xml` (verifier-only)

From study repo (already cloned by routine sandbox):
- `state/SOURCE_OF_TRUTH.md` (registry verification)

## Writes
To `instructions/curriculum/` in the study repo:
- `progress_state.xml`
- `deviation_log.xml`
- `rules.xml`
- `scope_registry.xml`
- `<active-chunk>.xml` (whatever filename `<active_files>` resolved to)
- `structure_current.xml`
- `.last-sync-status` (JSON: `{"status": "OK"|"STALE", "timestamp": "...", "active_chunk": "...", "missing": [...]}`)

**Overwrite semantics:** straight overwrite. No diff merge. Pipeline is authoritative.

## Output target
- Commit + push to `claude/curriculum-sync-<YYYY-MM-DD>`.
- Dispatch alert ONLY on STALE/error (success runs are silent).

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-curriculum-sync routine. Your one job is to mirror authoritative curriculum files from the bootcamp pipeline repo into the study-companion repo's instructions/curriculum/ directory.

## Critical rules (read first, do not skip)

1. The pipeline repo at C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\ is READ-ONLY. You MUST NOT write, modify, delete, or commit anything there. Any attempt to do so is a routine failure — abort and Dispatch alert.

2. DO NOT FABRICATE curriculum scope. If a required pipeline file is missing or unreadable, write a STALE marker and alert. Never invent `<completed_through_day>`, `<active_files>`, or any scope content.

3. Pipeline is authoritative. Overwrite study repo files directly. No diff merge, no reconciliation. If the pipeline says completed_through_day=21, the study repo gets completed_through_day=21 — period.

## Steps

Step 1: Verify environment.
- Read state/SOURCE_OF_TRUTH.md. Confirm the registry table includes instructions/curriculum/ as a synced target.
- Confirm pipeline repo path is accessible. If not, jump to STALE-handling (step 7).

Step 2: Read pipeline progress_state.xml.
- Parse the `<active_files>` element to determine the active curriculum chunk filename (e.g., curriculum_weeks04-06.xml). Do NOT hardcode this name — use whatever `<active_files>` resolves to.
- If `<active_files>` is empty/malformed/missing, that is a STALE condition. Go to step 7.

Step 3: Build the file list.
Required files from pipeline `config/`:
  - progress_state.xml
  - deviation_log.xml
  - rules.xml
  - scope_registry.xml
  - structure_current.xml
  - <active-chunk>.xml (resolved in step 2)

Explicitly SKIP (do not copy):
  - transition_map.xml
  - transition_briefs/ (any contents)
  - quality_gates.xml

Step 4: Verify all required files exist + are readable.
- For each file, check existence and read access. Track missing files in a list.
- If ANY required file is missing, do not partially sync — go to step 7 with the missing list.

Step 5: Copy files (only if step 4 passed cleanly).
- For each required file: read pipeline content, write to instructions/curriculum/<filename> in the study repo. Overwrite without prompting.
- Atomic-write pattern: write to tmpfile (e.g., progress_state.xml.tmp) then rename. This guards against half-written files if the routine is killed mid-copy.

Step 6: Write success status.
- Write instructions/curriculum/.last-sync-status with JSON:
  {"status": "OK", "timestamp": "<ISO-8601 with timezone>", "active_chunk": "<resolved filename from step 2>", "files_synced": [<list>], "missing": []}
- Stage all changes, commit with message "chore(curriculum-sync): mirror pipeline as of <date> (active=<chunk>)", push to claude/curriculum-sync-<YYYY-MM-DD>.
- Done. No Dispatch alert on success.

Step 7: STALE / error handling.
- Write instructions/curriculum/.last-sync-status with:
  {"status": "STALE", "timestamp": "<ISO-8601>", "active_chunk": "<best-guess or null>", "missing": [<list of unreadable/missing files>], "error": "<short description>"}
- Commit + push the .last-sync-status file (so the next morning-briefing routine sees the STALE flag).
- Dispatch alert: "study-curriculum-sync STALE: <reason>. Morning briefing will warn. Investigate pipeline repo."
- Exit with non-zero status code.

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT modify any file in C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\. Read-only access ONLY.
- DO NOT invent `<completed_through_day>`, day numbers, phase numbers, scope rules, or curriculum content. If pipeline data is unavailable, write STALE and alert. Never guess.
- DO NOT push to main. Push only to claude/curriculum-sync-<date>.
- DO NOT skip the .last-sync-status write. Downstream routines (especially #2) depend on it.
- DO NOT diff-merge or "reconcile" pipeline vs study content. Pipeline always wins.
- DO NOT copy verifier-only files (transition_map.xml, transition_briefs/, quality_gates.xml).
```

## Success criteria
- `instructions/curriculum/progress_state.xml` content matches pipeline byte-for-byte (modulo line endings).
- `.last-sync-status` exists with `"status": "OK"` and a fresh timestamp.
- A new commit appears on `claude/curriculum-sync-<YYYY-MM-DD>` branch.
- Pipeline repo state is unchanged (verifiable via `git status` in pipeline dir if it's a git repo, or mtime check on its files).
- No Dispatch alert was emitted (success path is silent).

## What this routine MUST NOT do
- MUST NOT modify, write, delete, or commit anything in `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\`. The pipeline repo is read-only from this routine's perspective. Any write attempt = routine failure.
- MUST NOT fabricate scope, day numbers, or curriculum content. If pipeline files are missing/unreadable, write STALE marker — never guess values.
- MUST NOT push to `main` or any branch other than `claude/curriculum-sync-<date>`.
- MUST NOT diff-merge. Pipeline is authoritative; overwrite directly.
- MUST NOT copy verifier-only files (`transition_map.xml`, `transition_briefs/`, `quality_gates.xml`).
- MUST NOT skip writing `.last-sync-status` — downstream routine #2 depends on it.
