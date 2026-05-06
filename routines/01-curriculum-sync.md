<!-- Per design §E #1 study-curriculum-sync. User pastes into Cowork /schedule UI per build plan Phase 12.2. -->
<!-- Routine #1 in cross-routine ordering: runs at 08:30 IST, BEFORE routine #2 (morning-briefing) at 08:45 IST. -->

# Routine 1: study-curriculum-sync

## Schedule
- **Cron (UTC):** `0 3 * * *`
- **IST equivalent:** 08:30 daily (every day of week)
- **Frequency:** Daily, before morning briefing (#2)

## Repository config
- **Push target (write):** `Sudhan09/study-companion` (private). Configured as the primary repo in the Cowork /schedule UI.
- **Pipeline source (read-only clone):** `Sudhan09/python_bootcamp_claude_code` (private). MUST be added as a secondary repo in the Cowork /schedule UI for this routine; Cowork's runtime then clones it before the routine starts. The `git clone` step in the routine prompt becomes a no-op verification (the directory should already exist).
- **Authentication:** Anthropic-managed proxy (Claude GitHub App installed on **BOTH** repos AND both repos in the routine's /schedule UI repo list). User-action prerequisite: (a) install Claude GitHub App on `python_bootcamp_claude_code`; (b) add it to this routine's repo list in /schedule UI.
- **Branch policy:** push to `claude/curriculum-sync-<YYYY-MM-DD>` on study-companion. Default-deny on main per design §H Rule 9. Pipeline repo is never written to.

## Reads
The routine sandbox clones the pipeline repo into `./pipeline/` at start of run, then reads from `pipeline/config/`:
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
- Commit + push to `claude/curriculum-sync-<YYYY-MM-DD>` (IST date via `TZ=Asia/Kolkata date +%F`).
- On STALE/error, the `.last-sync-status` JSON is the user's polling surface (downstream routines and morning-briefing read it).
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. The committed .last-sync-status file is the polling surface. -->

## Routine prompt (paste this into Cowork /schedule UI)

```
You are the study-curriculum-sync routine. Your one job is to mirror authoritative curriculum files from the bootcamp pipeline repo (Sudhan09/python_bootcamp_claude_code) into the study-companion repo's instructions/curriculum/ directory.

## Critical rules (read first, do not skip)

1. The pipeline repo `Sudhan09/python_bootcamp_claude_code` is READ-ONLY. You will clone it locally into `./pipeline/`, read files from there, and at end of run NEVER push, commit, or modify anything in the pipeline repo. Any attempt to do so is a routine failure — abort and write STALE marker.

2. DO NOT FABRICATE curriculum scope. If a required pipeline file is missing or unreadable, write a STALE marker. Never invent `<completed_through_day>`, `<active_files>`, or any scope content.

3. Pipeline is authoritative. Overwrite study repo files directly. No diff merge, no reconciliation. If the pipeline says completed_through_day=21, the study repo gets completed_through_day=21 — period.

## Steps

Step 1: Clone the pipeline repo into ./pipeline/.
- Run: `git clone https://github.com/Sudhan09/python_bootcamp_claude_code.git pipeline`
- The clone is performed by Cowork's runtime at routine start (because the pipeline repo is in the routine's /schedule UI repo list — see Setup prerequisite below). The shell `git clone` line above is a verification step; if the directory `./pipeline/` doesn't exist, the secondary repo is misconfigured.
- If the directory does NOT exist after Cowork's runtime initialization, jump to STALE-handling (step 7) with error: "pipeline repo not configured in /schedule UI repo list".
- If clone fails (404, auth error, network), jump to STALE-handling (step 7) with error: "pipeline clone failed: <stderr>".
- Verify `pipeline/config/` directory exists. If missing, jump to step 7.

Step 2: Read pipeline/config/progress_state.xml.
- Read state/SOURCE_OF_TRUTH.md and confirm its "Curriculum scope (separate registry, synced not authored)" subsection mentions instructions/curriculum/ as synced from the pipeline.
- Parse the `<active_files>` element in pipeline/config/progress_state.xml to determine the active curriculum chunk filename (e.g., curriculum_weeks04-06.xml). Do NOT hardcode this name — use whatever `<active_files>` resolves to.
- If `<active_files>` is empty/malformed/missing, that is a STALE condition. Go to step 7.

Step 3: Build the file list.
Required files from pipeline/config/:
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
- For each file, check existence at pipeline/config/<filename>. Track missing files in a list.
- If ANY required file is missing, do not partially sync — go to step 7 with the missing list.

Step 5: Copy files (only if step 4 passed cleanly).
- For each required file: read content from pipeline/config/<filename>, write to instructions/curriculum/<filename> in the study repo. Overwrite without prompting.
- Atomic-write: use `bash scripts/atomic-write.sh <tmpfile> <dst>` (added in Task 3.10) per file. DO NOT direct-Write to the destination.

Step 6: Write success status.
- Write instructions/curriculum/.last-sync-status with JSON:
  {"status": "OK", "timestamp": "<ISO-8601 with timezone>", "active_chunk": "<resolved filename from step 2>", "pipeline_commit": "<git rev-parse HEAD inside pipeline/>", "files_synced": [<list>], "missing": []}
- Stage all changes in study repo (NOT in pipeline/, which we leave untouched).
- Build commit message via `printf %q` to escape `<chunk>` and `<short-sha>`:
    msg=$(printf 'chore(curriculum-sync): mirror pipeline as of %s (active=%q, pipeline=%s)' "$date" "$chunk" "$sha")
    git commit -m "$msg"
  This prevents shell-injection if the pipeline's <active_files> XML contains shell metacharacters.
- Push to claude/curriculum-sync-$(TZ=Asia/Kolkata date +%F).
- Done. The `.last-sync-status` with `"status": "OK"` is the success signal.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. -->

Step 7: STALE / error handling.
- Write instructions/curriculum/.last-sync-status with:
  {"status": "STALE", "timestamp": "<ISO-8601>", "active_chunk": "<best-guess or null>", "missing": [<list of unreadable/missing files>], "error": "<short description>"}
- Commit + push the .last-sync-status file to claude/curriculum-sync-<YYYY-MM-DD> (so the next morning-briefing routine sees the STALE flag).
- The committed `.last-sync-status` with `"status": "STALE"` IS the alert — morning-briefing reads it and surfaces a [STALE-CURRICULUM] warning to the user.
<!-- Dispatch removed: notification mechanism not in Anthropic's web-scheduled-tasks spec. The .last-sync-status file is the polling surface. -->
- Exit with non-zero status code.

## What you MUST NOT do (anti-fabrication, anti-drift)

- DO NOT push, commit, or modify anything inside the cloned pipeline/ directory. Treat it as read-only.
- DO NOT invent `<completed_through_day>`, day numbers, phase numbers, scope rules, or curriculum content. If pipeline data is unavailable, write STALE and alert. Never guess.
- DO NOT push to main on study-companion. Push only to claude/curriculum-sync-<date>.
- DO NOT skip the .last-sync-status write. Downstream routines (especially #2) depend on it.
- DO NOT diff-merge or "reconcile" pipeline vs study content. Pipeline always wins.
- DO NOT copy verifier-only files (transition_map.xml, transition_briefs/, quality_gates.xml).
- DO NOT commit the pipeline/ clone directory into the study repo. It's a build-time artifact in the routine sandbox; the study repo only gets the synced files in instructions/curriculum/.
```

## Success criteria
- Pipeline repo cloned into `./pipeline/` successfully.
- `instructions/curriculum/progress_state.xml` content matches `pipeline/config/progress_state.xml` byte-for-byte (modulo line endings).
- `.last-sync-status` exists with `"status": "OK"`, a fresh timestamp, and `pipeline_commit` pinning the upstream SHA.
- A new commit appears on `claude/curriculum-sync-<YYYY-MM-DD>` branch of study-companion.
- Pipeline repo on GitHub is unchanged (no push, no PR opened against it).
- The `.last-sync-status` file holds the success/failure signal (no external dispatch in either path).

## Setup prerequisite (one-time, user-action)
- Install Claude GitHub App on `Sudhan09/python_bootcamp_claude_code` (in addition to study-companion). Visit github.com/apps/claude/installations/new → select the pipeline repo. Without this, Step 1 clone will fail with auth error and routine will go STALE every run.
- Add `Sudhan09/python_bootcamp_claude_code` as a secondary repo in this routine's Cowork /schedule UI repo list (Settings → routine 01 → "Connect repository"). Without this, the runtime cannot clone the pipeline.

## What this routine MUST NOT do
- MUST NOT push, commit, or modify the cloned `pipeline/` directory or its upstream repo.
- MUST NOT fabricate scope, day numbers, or curriculum content. If pipeline files are missing/unreadable, write STALE marker — never guess values.
- MUST NOT push to `main` or any branch other than `claude/curriculum-sync-<date>` on study-companion.
- MUST NOT diff-merge. Pipeline is authoritative; overwrite directly.
- MUST NOT copy verifier-only files (`transition_map.xml`, `transition_briefs/`, `quality_gates.xml`).
- MUST NOT skip writing `.last-sync-status` — downstream routine #2 depends on it.
- MUST NOT commit `pipeline/` into the study repo (use `.gitignore` if needed; routine sandbox is ephemeral so this should not happen, but defensive against staging mistakes).
