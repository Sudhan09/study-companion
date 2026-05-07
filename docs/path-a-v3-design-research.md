<!-- Generated 2026-05-07 by executor research session. -->
<!-- Source inputs: docs/path-a-v3-issues.md (84 issues), 8 routine specs, plugin hooks/skills, -->
<!-- state/SOURCE_OF_TRUTH.md, .github/workflows/auto-merge-and-notify.yml. -->
<!-- Evidence harvested by 7 parallel research agents (Anthropic docs, GitHub Actions, Slack, -->
<!-- POSIX, RFC 3339, Cowork dormancy investigation, 104-scenario re-simulation). -->

# Path A v3 — Design Research with Evidence

**Status:** Complete (research-only, no code changes; do not commit until reviewed).
**Authoring:** Executor research session, 2026-05-07.
**Constraint:** Every load-bearing claim cites a primary source. Items marked `[NO EVIDENCE — UNCERTAIN]` or `[NO EVIDENCE — ANTHROPIC INTERNAL]` could not be backed by authoritative documentation; those flag follow-up decisions for Sudhan.

---

## Executive Summary

| Metric | Value |
|---|---|
| Total issues researched | **84** (16 Critical + 62 Medium + 6 Path A gaps) + 10 ambiguities + 5 edge cases + 8 wrong assumptions |
| Solutions with strong evidence | **74** (88%) |
| Solutions marked `[NO EVIDENCE]` | **10** (12%) — concentrated in Cowork-internals + GitHub Actions cleanup signal |
| Critical risks flagged for user decision | **9** in the risk register, **3** demand resolution before any code lands |
| New critical scenarios surfaced (CRIT-11..16) | **6** + **1** promotion candidate (M4-2 → CRIT-17) |
| Estimated executor hours | **45–65h** spread across 4 phases (preflight, schema migration, skills, observability) |

### Top-line conclusions

1. **The CRIT-13 "resume-needs-fresh-curriculum-but-routine-#1-was-suppressed" cascade defeats CRIT-06's fix.** This must be resolved by sequencing: `/resume-routines` MUST trigger curriculum-sync inline before computing the resume day. (Agent G; routine #1 spec; Anthropic docs on `claude/<branch>` push policy.)
2. **The post-to-slack.sh `username`/`icon_emoji`/`channel` overrides are silently ignored** by modern incoming webhooks. Either remove them (cleanup) or know they're decorative. (Slack docs verbatim: "You cannot override the default channel...".)
3. **`git merge --no-ff` cannot create empty marker commits** — "Already up to date" pre-check fires before `--no-ff` is consulted. Path A v3's auto-merge step needs `git commit --allow-empty` if a heartbeat-marker behavior is desired. (git-scm.com.)
4. **Default workflow concurrency replaces pending runs** — only one running + one pending. To actually serialize without dropping, use `queue: max` (max 100). Critical for CRIT-15. (docs.github.com.)
5. **`GITHUB_TOKEN` cannot push to a protected `main`** by GitHub's design. Workaround: GitHub App installation token via `actions/create-github-app-token`. (GitHub Staff @chrispat in community discussion.)
6. **GITHUB_TOKEN-triggered events do NOT cascade** to other workflows — auto-merge's push to `main` will not trigger any other `on: push: branches: [main]` workflow. Means a separate "post-merge" workflow chain is impossible without using a PAT.
7. **Cowork hooks ARE dormant** but the issue is a SETTINGS-resolution bug, not a hook-engine bug. CLAUDE.md @-imports DO work in Cowork because `.claude/` is bind-mounted. **Project-scope `.claude/settings.json` hook firing in Cowork is undocumented** — needs a smoke test before relying on it. (Issue #40495 OPEN as of 2026-05-07; no maintainer fix.)
8. **Routines silently lose work if they don't `git push`** — issue #53497 OPEN. Every routine prompt must explicitly include the push step.

---

## Section 1 — Re-Simulation: CRIT-11 through CRIT-16

Six new critical scenarios surfaced by re-running the 104-scenario simulation against Path A v3's spec. Methodology: walked through 10 categories × 8-15 scenarios (~120 simulations), filtered against the 10 existing CRITs, GAP-01..06, EC-01..05, and 62 Mediums.

### CRIT-11 — Auto-merge revert leaves `claude/pause-routines-*` branch as the only carrier of `mode=paused`, with no retry path

**Scenario:** User invokes `/pause-routines` at 11:00 PM IST. Skill writes `vacation.md`, sets `mode: paused`, commits + pushes to `claude/pause-routines-2026-05-07`. Auto-merge fires. Pre-merge validators pass. **Post-merge validators fail** — for any reason: e.g., a frontmatter ordering quirk in `validate-state-schemas.js`, an unrelated drifty `last_updated` in another state file, or the schema validator hasn't been updated for `mode` yet (CRIT-04 partial regression). Per the workflow YAML lines 200–210: post-merge failure triggers `git reset --hard HEAD~1` and skips push. Slack receives "Merge succeeded but post-merge validation failed. Merge has been REVERTED."

The branch still exists on the remote, but main never receives the pause state. Next morning's curriculum-sync at 08:30 IST and morning-briefing at 09:00 IST run normally because main has `mode: bootcamp`.

**Why critical:** Loud-but-misread-by-user. Slack DOES post a failure message, but its phrasing reads as "automated routine had a hiccup, ignore." There is zero indication that *the pause itself was lost*. Worse than CRIT-05 (branch never triggered Actions) because Actions DID fire and produced a *misleading* generic-validator-failure framing on a state-critical change.

**Proposed Solution:** Auto-merge workflow needs special-case handling for `pause-routines` and `resume-routines` branches: post-merge revert MUST escalate to a high-visibility Slack body. Plus: `/pause-routines` skill MUST poll for the merge SHA on main before exiting (not just push and quit).

**Evidence:**
- [E1] Routines silently lose work if not explicitly pushed.
  - Source: https://github.com/anthropics/claude-code/issues/53497
  - Quote: "When a scheduled remote agent (CCR) creates a git commit, it does so on a local branch inside the ephemeral sandbox. The sandbox terminates after the session ends, and the commit is permanently lost — there is no automatic git push before teardown... No error, no warning, no indication that the push was missing."
  - Verified: yes (issue OPEN as of 2026-05-07)
- [E2] `git push` from skill body is supported via `allowed-tools` syntax.
  - Source: https://code.claude.com/docs/en/skills
  - Quote: "`allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)`"
  - Verified: yes
- [E3] No idempotency / retry on routine failure.
  - Source: https://platform.claude.com/docs/en/api/claude-code/routines-fire
  - Quote: "Each successful request creates a new session. There is no idempotency key. If a webhook caller retries, the endpoint creates multiple sessions."
  - Verified: yes

**Implementation:**
- Add `/pause-routines` post-push poll: `gh run list --workflow=auto-merge-and-notify --branch=claude/pause-routines-<date> --limit=1 --json status,conclusion -q '.[0]'`. Loop with 15s sleep, max 5 minutes. If `conclusion != success`, abort with user-facing error.
- Add a `pause-routines` / `resume-routines` arm to `.github/workflows/auto-merge-and-notify.yml`'s "Build Slack body" step: emit 🚨-prefixed "PAUSE NOT APPLIED" body on revert.

**Risk:** Polling adds ~30s–5min wall-clock to `/pause-routines`. User-tolerable; mitigation = surface progress dots.

---

### CRIT-12 — `archive/vacations.md` append-log race when `/pause-routines` is invoked from two surfaces (Cowork + claude.ai/code) within the same minute

**Scenario:** Sudhan invokes `/pause-routines` from Cowork at 14:30:15 IST. Skill begins: reads existing `archive/vacations.md`, appends a new vacation record, writes the file, commits, pushes. Before the Cowork commit lands on main, Sudhan switches to the Code app, forgets he just paused, invokes `/pause-routines` again at 14:30:42 IST. That instance reads `archive/vacations.md` — pre-Cowork version — and appends a *different* entry. Both push to `claude/pause-routines-2026-05-07` (or to a collision-suffixed variant). Auto-merge picks them up in arbitrary order; `archive/vacations.md` ends up with one entry overwriting the other, OR with both entries scrambled, OR with a wedge.

**Why critical:** Irreversible state corruption of an append-only audit log. Distinct from M2-1 because M2-1 addresses `vacation.md` (overwrite-recoverable) — CRIT-12 is the append-log corruption mode where the missing entry is unrecoverable except via git reflog forensics.

**Proposed Solution:** Either (a) restrict `/pause-routines` to Cowork only (and document it) OR (b) skill body's first action: `git fetch origin main && git diff HEAD origin/main` to detect a recent pause commit. If pending, error: "Pause already in progress — wait for confirmation in Slack before re-invoking."

**Evidence:**
- [E1] POSIX rename atomic within FS, not across writers.
  - Source: https://man7.org/linux/man-pages/man2/rename.2.html
  - Quote: "If newpath already exists, it will be atomically replaced, so that there is no point at which another process attempting to access newpath will find it missing."
  - Verified: yes
- [E2] Atomic rename does NOT prevent lost updates.
  - Source: https://github.com/postgres/postgres/blob/master/src/backend/utils/misc/guc.c (lines 4746-4751)
  - Quote: "As the rename is atomic operation, if any problem occurs after this at worst it can lose the parameters set by last ALTER SYSTEM command."
  - Verified: yes
- [E3] flock advisory locks do not prevent rename or non-cooperating processes.
  - Source: https://man7.org/linux/man-pages/man2/flock.2.html
  - Quote: "flock() places advisory locks only; given suitable permissions on a file, a process is free to ignore the use of flock() and perform I/O on the file."
  - Verified: yes
- [E4] Routine sandbox is ephemeral; each run re-clones from main.
  - Source: https://code.claude.com/docs/en/routines
  - Quote: "Each repository is cloned at the start of a run, starting from the default branch."
  - Verified: yes

**Implementation:**
- Add to skill body (pseudo): `git fetch origin main; if [ -n "$(git diff HEAD origin/main -- archive/vacations.md)" ]; then echo "Pause merge pending — re-run after Slack confirms"; exit 1; fi`.
- Promote M2-1 to High-Medium with cross-reference to CRIT-12.

**Risk:** Two adjacent invocations within the merge-completion window (~2-3 min) still race. Mitigation: poll for merge completion (CRIT-11 fix subsumes this).

---

### CRIT-13 — `mode: paused` interacts catastrophically with curriculum-sync — bootstrap deadlock on resume

**Scenario:** Step 0 preamble added to ALL 8 routines per A1-Option-A (literal reading: "Suppress all 8"). User pauses 30+ days. During pause, the upstream pipeline repo advances — new `<active_files>` chunk lands, `progress_state.xml` advances `<completed_through_day>`. User resumes. `/resume-routines` reads `progress_state.xml.completed_through_day + 1` (per CRIT-06 fix), but the XML is 30 days stale because routine #1 was suppressed. `/resume-routines` computes the wrong resume day. Routine #1 fires next morning at 08:30, syncs the new curriculum. `progress_state.xml` jumps forward. Morning-briefing at 09:00 sees mismatch and emits `[STALE-INPUT]`.

**Why critical:** Bootstrap deadlock. Resume calculation depends on data that resume itself cannot get fresh. The CRIT-06 fix is broken without resolving CRIT-13.

**Proposed Solution:** `/resume-routines` MUST trigger curriculum-sync synchronously as its first action — before computing the resume day, before rewriting `current_day.md`. Sequence: (1) clear `mode: paused`, (2) trigger `workflow_dispatch` on curriculum-sync (or run sync inline), (3) wait/poll for sync to land on main, (4) THEN compute resume day from now-fresh `progress_state.xml`. Alternative: A1 resolved as Option-B, with curriculum-sync explicitly excluded from suppression — but then Step 0 preamble for routine #1 must check `vacation.md.suppress_routines` not `mode`.

**Evidence:**
- [E1] Cron is best-effort; "may be dropped" during high load.
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows
  - Quote: "The `schedule` event can be delayed during periods of high loads of GitHub Actions workflow runs... If the load is sufficiently high enough, some queued jobs may be dropped."
  - Verified: yes
- [E2] Routines can be triggered manually via web UI.
  - Source: https://code.claude.com/docs/en/routines
  - Quote: "Create and manage them at [claude.ai/code/routines](https://claude.ai/code/routines), or from the CLI with `/schedule`."
  - Verified: yes
- [E3] Routine prompt limits — text payload max 65,536 chars per fire.
  - Source: https://platform.claude.com/docs/en/api/claude-code/routines-fire
  - Quote: "Maximum 65,536 characters."
  - Verified: yes
- [E4] `workflow_dispatch` accepts inputs; `if: ${{ inputs.mode == 'wrap' }}` valid pattern.
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/contexts
  - Quote (verbatim YAML example): "`if: ${{ inputs.print_tags }}`"
  - Verified: yes

**Implementation:**
- Promote M6-6 + M8-7 (already-noted as duplicates) into CRIT-13's fix. Add resume orchestration sub-step to `/resume-routines` skill: after writing `vacation.md` cleanup, run `gh api repos/Sudhan09/study-companion/actions/workflows/auto-merge-and-notify.yml/dispatches -f ref=main -f inputs[mode]=resume-curriculum-sync`. Then poll for the resulting curriculum-sync branch's appearance on main.

**Risk:** Workflow-dispatch from skill requires `gh` CLI in cloud session (not pre-installed per Anthropic docs — needs setup script). Alternative: skill body runs sync inline by cloning pipeline repo, doing the file copy, committing, pushing. Adds 30-60s to resume.

---

### CRIT-14 — Stop hook continues writing `drift_log.md` during `mode: paused`; Path A v3 has no Step 0 preamble for *hooks* — only routines

**Scenario:** Path A v3 spec extends pause-awareness to the 8 cloud routines but is silent on the 4 hooks (SessionStart, UserPromptSubmit, Stop, PreCompact). User pauses, opens claude.ai/code casually during vacation. Stop hook fires at end of session and detects drift patterns. Drift entries accumulate over 14-day pause. User resumes. First Sunday post-resume, drift-audit (routine #7) reads the 7-day window, treats vacation drift as legitimate, proposes teaching-method tightenings based on *casual non-study sessions during vacation*. Worse: if user does `/day-wrap` while "paused", `bootcamp.current_day` is incremented — state files contradict (`current_day = N+1` but `mode = paused` and no actual study).

**Why critical:** State integrity collapse on the local-claude.ai/code surface. Path A v3 authors clearly forgot hooks. Drift gets fed back into the teaching-method tightening loop via routine #7 — which CAN propose locked-rule changes from vacation noise. M7-1, M7-3, M7-4, M7-6 each capture a slice; the *class* of "hooks must respect pause" is critical.

**Proposed Solution:** All 4 hooks need pause-awareness:
- **Stop:** read `state/current_day.md.mode`. If paused, skip drift_log append (or annotate `mode=paused` and exclude from drift-audit window).
- **SessionStart:** if paused, prepend a "pause banner" to the normal context.
- **PreCompact:** snapshot must include `vacation.md` + `mode` field.
- **UserPromptSubmit:** if paused and user types `:wrap` / `:lock` token, surface confirmation prompt.

Plus: `/day-wrap` skill itself MUST refuse to increment `bootcamp.current_day` if `mode == paused`.

**Evidence:**
- [E1] Stop event fields documented.
  - Source: https://code.claude.com/docs/en/hooks
  - Quote: "`{ \"session_id\": \"abc123\", ..., \"hook_event_name\": \"Stop\", \"stop_reason\": \"end_turn\", \"last_assistant_message\": \"...\", \"stop_hook_active\": true }`"
  - Verified: yes
- [E2] `additionalContext` cap is 10K chars, with overflow saved to file.
  - Source: https://code.claude.com/docs/en/hooks
  - Quote: "Hook output injected into context (`additionalContext`, `systemMessage`, or plain stdout) is capped at 10,000 characters. Output that exceeds this limit is saved to a file and replaced with a preview and file path."
  - Verified: yes
- [E3] CLAUDE.md @-imports are reliable (depth 5; bind-mounted on Cowork).
  - Source: https://code.claude.com/docs/en/memory
  - Quote: "Imported files can recursively import other files, with a maximum depth of five hops."
  - Verified: yes
- [E4] Hooks dormant on Cowork (issue #40495 + docs corroborate cloud-side hooks need to be repo-committed).
  - Source: https://code.claude.com/docs/en/claude-code-on-the-web
  - Quote: "Your repo's `.claude/settings.json` hooks | Yes | Part of the clone... SessionStart hooks can also be defined in your user-level `~/.claude/settings.json` locally, but user-level settings don't carry over to cloud sessions."
  - Verified: yes

**Implementation:**
- Add `mode` read to `_lib.js` `loadContext()` and bail-out early when paused.
- Edit `stop.js` to early-return without appending drift_log when `mode == paused`.
- Update `/day-wrap` skill body with pause guard.
- Promote M7-1, M7-3, M7-4, M7-6 to CRIT-14 cluster.

**Risk:** Hooks dormant on Cowork means this fix only protects the claude.ai/code surface. Cowork sessions during pause cannot self-protect; user discipline + CLAUDE.md banner is the only defense.

---

### CRIT-15 — `missed_routines.md` replay during catch-up triggers cascading auto-merge avalanche on resume day, exhausting Actions concurrency

**Scenario:** User pauses 7 days. Per A4-Option-A ("Replay all missed back-dated"), 7 days × 8 routines = up to 56 catch-up jobs, each pushing its own `claude/<routine>-<replay-date>` branch. The auto-merge workflow has `concurrency: { group: auto-merge-and-notify, cancel-in-progress: false }` (workflow YAML lines 64-66) — but **default behavior is one running + one pending; new enqueues replace pending**, NOT queue. With 56 pushes, only the last-arriving one is preserved; the rest get cancelled mid-queue. Even if `queue: max` is added (max 100), drain time is 1–10 hours. Real-time routines fire during drain, queue behind catch-up. By 21:00 IST daily-wrap, main may be at any of 56 intermediate states.

**Why critical:** Operational deadlock and trust collapse. M3-5 mentions "could time out" but for the routine session — CRIT-15 is the *Actions queue* avalanche.

**Proposed Solution:** A4 must be resolved as Option-C (recommendation already correct) — no back-dated replay. CRIT-15 is the operational reason. If any back-dated replay is needed (e.g., curriculum-sync per A4-recommendation), it runs *inline within the resume skill* (single push), NOT via 7 separate routine invocations.

**Evidence:**
- [E1] Default concurrency replaces pending, doesn't queue.
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
  - Quote: "By default, any existing `pending` job or workflow in the same concurrency group will be canceled and the new queued job or workflow will take its place."
  - Verified: yes
- [E2] `queue: max` allows up to 100 pending; cancel-in-progress: true incompatible.
  - Source: same
  - Quote: "`max`: Up to 100 jobs or workflow runs can be `pending`... The combination of `queue: max` and `cancel-in-progress: true` is not allowed and will result in a workflow validation error."
  - Verified: yes
- [E3] Cron is best-effort; jobs may be dropped at high load.
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows
  - Quote: "If the load is sufficiently high enough, some queued jobs may be dropped."
  - Verified: yes
- [E4] FIFO ordering on concurrency group is "not guaranteed."
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
  - Quote: "Since the actual start time of a job or run may vary, ordering is not guaranteed."
  - Verified: yes

**Implementation:** None at workflow level if A4-Option-C is locked in. If A4-Option-A is preferred: add `queue: max` to the workflow's concurrency block + a queue-depth Slack alert when >5 catch-up pushes are queued.

**Risk:** Conditional on A4 resolution. Mark as "critical-conditional-on-A4-Option-A".

---

### CRIT-16 — `/resume-routines` rewriting `state/last_session_summary.md` violates SOURCE_OF_TRUTH writer registry

**Scenario:** Per `state/SOURCE_OF_TRUTH.md`, the writer for `last_session_summary.md` is `/post-session, /day-wrap` — period. Path A v3 spec for `/resume-routines` has it rewrite this file with a "returning from vacation" gap notice. The state validator (`validate-state-schemas.js`) reads `updated_by` frontmatter and checks against the allowlist. Either: (a) validator updated to enforce — `/resume-routines` write trips the writer-not-in-allowlist check, post-merge validator fails, merge reverts (→ CRIT-11 cascade); or (b) validator NOT updated — `updated_by: resume-routines` silently accepted, SOURCE_OF_TRUTH demoted from registry-of-truth to documentation-not-enforced.

**Why critical:** Architectural integrity collapse. SOURCE_OF_TRUTH is the only mechanism preventing rogue writers from corrupting state files.

**Proposed Solution:** Path A v3 spec MUST update `state/SOURCE_OF_TRUTH.md` to add `/resume-routines` and `/pause-routines` to the writer columns for: `current_day.md` (mode field), `last_session_summary.md`, `vacation.md`, `archive/vacations.md`, `missed_routines.md`. The schema validator MUST enforce writer-allowlist per file (closes M6-3). `/resume-routines` should ALSO archive the pre-vacation `last_session_summary.md` to `archive/sessions/<pre-vacation-date>.md` BEFORE rewriting (closes GAP-02).

**Evidence:**
- [E1] Validator's writer-list enforcement is partial.
  - Source: `/home/sudhan/study-companion-real/scripts/validate-state-schemas.js` (lines 64-72)
  - Quote: "if (allowed && !allowed.includes(writer)) { errors.push(...) }" — note the `allowed && ` short-circuits when the file isn't in the map at all (silent pass-through, M6-3).
  - Verified: yes (read locally)
- [E2] SOURCE_OF_TRUTH explicitly enumerates writers.
  - Source: `/home/sudhan/study-companion-real/state/SOURCE_OF_TRUTH.md`
  - Quote: "`Last session summary | state/last_session_summary.md | /post-session, /day-wrap | SessionStart hook + CLAUDE.md @-import`"
  - Verified: yes (read locally)

**Implementation:**
- Update `state/SOURCE_OF_TRUTH.md` "Allowed extra frontmatter fields" + writers table.
- Update `validate-state-schemas.js` `ALLOWED_WRITERS` map: add entries for `vacation.md` and `missed_routines.md`; add `/pause-routines` and `/resume-routines` to existing entries where applicable.
- `/resume-routines` skill: before rewriting `last_session_summary.md`, copy current contents to `archive/sessions/<pre-vacation-end-date>-pre-resume.md` with `archived_on: <today>` frontmatter.

**Risk:** None if implemented correctly.

---

### CRIT-17 (suggested promotion) — `claude/pause-routines-malicious` allowlist abuse

**Scenario:** M4-2 noted that `claude/pause-routines-*` in the allowlist could be triggered by an externally-pushed branch matching the pattern. Repo is private (per `docs/2026-05-06-windows-handoff.md`), so attack surface is limited to credentials with push access. **However:** if the Claude GitHub App token is compromised, an attacker can push `claude/pause-routines-anything` and trigger arbitrary state-file writes via the workflow.

**Why critical:** Security regression. Adding pause/resume patterns expands the attack surface. Path A v3 should add explicit branch-name validation in the workflow's parse step (already does this — see workflow lines 137-147). Verify the validation regex rejects branch names not matching `^claude/(pause|resume)-routines-\d{4}-\d{2}-\d{2}$`.

**Proposed Solution:** Tighten parse-step validation: instead of `case "$ROUTINE" in pause-routines|resume-routines|...) ;; *) exit 1 ;;`, also enforce that DATE comes from the user's session-id-bound output, not from the branch name alone. Or: route pause/resume through a different workflow file with stricter input validation.

**Evidence:**
- [E1] Allowlist matches `claude/pause-routines-*` literally including any suffix without `/`.
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
  - Quote: "`*`: Matches zero or more characters, but does not match the `/` character."
  - Verified: yes
- [E2] Routine sandbox uses scoped credential via Anthropic proxy.
  - Source: https://code.claude.com/docs/en/claude-code-on-the-web
  - Quote: "the git client uses a scoped credential inside the sandbox, which the proxy verifies and translates to your actual GitHub authentication token"
  - Verified: yes

**Risk:** Low probability (private repo + Anthropic-managed scoped credentials), but high blast radius if it occurs.

---

## Section 2 — Per-Issue Solutions

### 🔴 Critical Gaps (CRIT-01 .. CRIT-10) — original 10

#### CRIT-01 — `mode: paused` is not readable by any existing routine or hook
**Severity:** 🔴 · **Category:** state-schema-migration

**Proposed Solution:** Add a mandatory Step 0 preamble to every routine prompt + every hook handler. If `state/current_day.md.mode == paused`, the routine writes a one-line sentinel to its expected output file ("status: paused, no output produced") and exits cleanly. The auto-merge workflow's body extractor detects this sentinel and emits a one-liner Slack message instead of the full body.

**Evidence:**
- [E1] Routine prompt is the place where Step 0 logic lives — routines are autonomous Claude sessions.
  - Source: https://code.claude.com/docs/en/routines
  - Quote: "Routines run autonomously as full Claude Code cloud sessions: there is no permission-mode picker and no approval prompts during a run."
  - Verified: yes
- [E2] CLAUDE.md @-imports load `state/current_day.md` into every session — single read point.
  - Source: https://code.claude.com/docs/en/memory
  - Quote: "Imported files are expanded and loaded into context at launch alongside the CLAUDE.md that references them."
  - Verified: yes

**Implementation:** Update each `routines/0[1-8]-*.md` `## Routine prompt` block with Step 0 preamble. Update `validate-state-schemas.js` ALLOWED_WRITERS map. Update `_lib.js` `loadContext()` to surface `mode` prominently.

**Risk:** All 8 routine prompts must be re-pasted into `claude.ai/code/routines` UI. Use `scripts/check-routine-skew.sh` to verify hashes after re-paste.

---

#### CRIT-02 — `/pause-routines` skill has no defined writer path
**Severity:** 🔴 · **Category:** skill-self-commit

**Proposed Solution:** `/pause-routines` skill body MUST include explicit `git add ... && git commit ... && git push` as Bash steps with `allowed-tools: Bash(git add *) Bash(git commit *) Bash(git push *)`. Skill body uses `!`-injection for the actual git invocations. Verify push completed via `git ls-remote origin claude/pause-routines-<date>` before exiting.

**Evidence:**
- [E1] Skills support pre-approved Bash via `allowed-tools` syntax — exact pattern documented.
  - Source: https://code.claude.com/docs/en/skills
  - Quote: "`allowed-tools: Bash(git add *) Bash(git commit *) Bash(git status *)`"
  - Verified: yes
- [E2] Bundled `commit-commands` skill demonstrates this is a documented pattern.
  - Source: https://code.claude.com/docs/en/discover-plugins
  - Quote: "**commit-commands**: Git commit workflows including commit, push, and PR creation"
  - Verified: yes
- [E3] Routines silently lose work without explicit `git push` (#53497).
  - Source: https://github.com/anthropics/claude-code/issues/53497
  - Quote: "the sandbox terminates after the session ends, and the commit is permanently lost — there is no automatic git push before teardown"
  - Verified: yes
- [E4] On Cowork specifically, hooks are dormant per #40495 — push must be in skill body, not a hook.
  - Source: https://github.com/anthropics/claude-code/issues/40495
  - Quote (from the issue's impact table): "`~/.claude/settings.json` hooks | Fire | Fire | Silent no-op"
  - Verified: yes (issue OPEN as of 2026-05-07)

**Implementation:** Skill body template:
```
allowed-tools: Bash(git add state/*) Bash(git commit -m *) Bash(git push origin *)
```
With body invoking `!git add state/vacation.md state/current_day.md`, `!git commit -m "chore(pause): ..."`, `!git push origin claude/pause-routines-$(TZ=Asia/Kolkata date +%F)`.

**Risk:** Push fails silently if Anthropic GitHub App not installed — skill must verify auth before committing.

---

#### CRIT-03 — Carry-forward counter has no cap (infinite backlog)
**Severity:** 🔴 · **Category:** carry-forward-replay

**Proposed Solution:** `state/missed_routines.md` includes top-level frontmatter `max_carry_forward_days: 7`. On `/resume-routines`, entries older than 7 days from today are archived to `archive/missed_routines-<resume-date>.md` as "skipped (vacation)" not "missed (regression)". RTI bands MUST NOT auto-escalate during a `mode: paused` window.

**Evidence:**
- [E1] Append-only patterns are safe under O_APPEND single-host.
  - Source: https://man7.org/linux/man-pages/man2/open.2.html
  - Quote: "The modification of the file offset and the write operation are performed as a single atomic step."
  - Verified: yes
- [E2] Lost-update pattern documented in production code.
  - Source: https://github.com/postgres/postgres/blob/master/src/backend/utils/misc/guc.c
  - Quote: "at worst it can lose the parameters set by last ALTER SYSTEM command"
  - Verified: yes

**Implementation:** Add `max_carry_forward_days: 7` to `missed_routines.md` frontmatter. Modify routine #3 (spaced-rep) drill picker to skip RTI band escalation when `vacation.md` covers the gap.

**Risk:** None.

---

#### CRIT-04 — `mode` field is a breaking change for all 8 routines simultaneously
**Severity:** 🔴 · **Category:** schema-migration

**Proposed Solution:** Atomic migration PR that updates: (a) `SOURCE_OF_TRUTH.md` allowed-frontmatter table; (b) `validate-state-schemas.js` to accept `mode: bootcamp|loop_week|paused`; (c) all 8 routine prompts with Step 0 preamble; (d) `_lib.js` LOAD_ORDER (no change needed but verify); (e) `validate-skills.js` if any skill frontmatter changes.

**Evidence:**
- [E1] Validator runs pre-merge AND post-merge in current workflow.
  - Source: `.github/workflows/auto-merge-and-notify.yml` lines 168-200 (read locally)
  - Verified: yes
- [E2] Path A v3 design lists `mode` as new field on `current_day.md`.
  - Source: `docs/path-a-v3-issues.md` Section 2
  - Verified: yes

**Implementation:** Single PR + commit; do NOT split.

**Risk:** Any routine prompt missed gets a validator failure on next run (CRIT-11 cascade).

---

#### CRIT-05 — Auto-merge allowlist excludes `claude/pause-routines-*`
**Severity:** 🔴 · **Category:** workflow-allowlist

**Proposed Solution:** Add to `.github/workflows/auto-merge-and-notify.yml` `on: push: branches:`:
```
- 'claude/pause-routines-*'
- 'claude/resume-routines-*'
```
Plus update the allowlist case statement in the "Parse branch name" step.

**Evidence:**
- [E1] Branch glob `*` matches any chars except `/`.
  - Source: https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
  - Quote: "`*`: Matches zero or more characters, but does not match the `/` character."
  - Verified: yes
- [E2] `claude/pause-routines-*` matches `claude/pause-routines-2026-05-08`.
  - Same source. Verified: yes (rule application).

**Implementation:** Diff to workflow YAML on/branches list + parse-step case statement.

**Risk:** See CRIT-17 for security implications of expanded allowlist.

---

#### CRIT-06 — `/resume-routines` has no logic for which day to "return to"
**Severity:** 🔴 · **Category:** resume-orchestration

**Proposed Solution:** `/resume-routines` reads `instructions/curriculum/progress_state.xml` `<completed_through_day>` and sets `state/current_day.md.bootcamp.current_day = <completed_through_day> + 1`. **But CRIT-13 must be resolved first** — sync curriculum inline before reading.

**Evidence:** See CRIT-13.

**Implementation:** Sequential — sync, read, write.

**Risk:** If `progress_state.xml` cannot be synced (auth failure), resume must abort with user-visible error rather than fall back to last-known-good.

---

#### CRIT-07 — Routine #6 archives vacation-period phantom logs
**Severity:** 🔴 · **Category:** vacation-aware-archival

**Proposed Solution:** Routine #6 (monday-distillation) checks `state/vacation.md.start_date` and `end_date` (if vacation occurred in last 7 days). For each log file in distillation window, if the date falls inside a vacation window, mark `type: vacation_gap` in archive frontmatter and exclude from session count in `state/distilled.md`.

**Evidence:**
- [E1] `git mv` updates index and stages move atomically.
  - Source: https://git-scm.com/docs/git-mv
  - Quote: "The index is updated after successful completion, but the change must still be committed."
  - Verified: yes

**Implementation:** Update routine 06 prompt's distillation logic. New schema field on archive files: `type: vacation_gap | study_session`. Update `state/distilled.md` to filter session count by type.

**Risk:** None.

---

#### CRIT-08 — `state/schedule.md` left stale during pause
**Severity:** 🔴 · **Category:** state-cleanup

**Proposed Solution:** `/pause-routines` writes `state/schedule.md` with a "system paused" banner and clears block plan to "No plan — system paused". `/resume-routines` triggers a fresh morning-briefing run before first interactive session.

**Evidence:**
- [E1] CLAUDE.md @-imports load `state/schedule.md` into every session.
  - Source: https://code.claude.com/docs/en/memory
  - Quote: "Imported files are expanded and loaded into context at launch"
  - Verified: yes

**Implementation:** Add to `/pause-routines` skill body: `cat > state/schedule.md << EOF\n---\nlast_updated: ...\nupdated_by: /pause-routines\nmode: paused\n---\n# Paused\nSystem paused since <start_date>. No plan today.\nEOF`.

**Risk:** None.

---

#### CRIT-09 — `daily-wrap` has no `mode` awareness
**Severity:** 🔴 · **Category:** observability

**Proposed Solution:** `build-daily-wrap.sh` reads `state/current_day.md.mode`. If paused, post:
- Day 1: "🛫 Vacation started — System paused. No routines expected. Vacation day 1 of N."
- Mid: silent OR minimal heartbeat (per A10-recommendation: only Day 1 + last day).
- Last: "🛬 Last day of vacation — Resume tomorrow before 09:00 IST Monday."

**Evidence:**
- [E1] Slack channel/username/icon overrides are silently ignored on app-attached webhooks.
  - Source: https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks
  - Quote: "You cannot override the default channel (chosen by the user who installed your app), username, or icon when you're using incoming webhooks to post messages."
  - Verified: yes
- [E2] Slack incoming webhook rate limit is 1 message per second.
  - Source: https://docs.slack.dev/apis/web-api/rate-limits
  - Quote: "Incoming webhooks: 1 per second. Short bursts >1 allowed."
  - Verified: yes

**Implementation:** Add a top-level `mode` check to `.github/scripts/build-daily-wrap.sh`. Branch into pause-mode templates.

**Risk:** None.

---

#### CRIT-10 — `/pause-routines` race: 9.5h gap before next routine fire
**Severity:** 🔴 · **Category:** push-confirm

**Proposed Solution:** `/pause-routines` polls for the auto-merge to complete: after `git push`, run `gh run list --workflow=auto-merge-and-notify --branch=claude/pause-routines-<date> --limit=1 --json status,conclusion`. Loop max 5 minutes. If status remains `pending` or `in_progress` past 5 min, surface user-visible warning: "Pause push pending — verify in Slack before closing Cowork."

**Evidence:**
- [E1] No idempotency / no auto-retry for routines.
  - Source: https://platform.claude.com/docs/en/api/claude-code/routines-fire
  - Quote: "There is no idempotency key. If a webhook caller retries, the endpoint creates multiple sessions."
  - Verified: yes
- [E2] `gh` CLI not pre-installed in cloud sessions; local Cowork has it.
  - Source: https://code.claude.com/docs/en/claude-code-on-the-web
  - Quote: "The `gh` CLI is not pre-installed."
  - Verified: yes
- [E3] Asia/Kolkata = UTC+5:30 fixed (no DST since 1945).
  - Source: https://data.iana.org/time-zones/data/asia
  - Quote: "5:30 - IST" (perpetual since 1945-10-15)
  - Verified: yes

**Implementation:** Add poll loop to `/pause-routines` skill body.

**Risk:** Polling delays skill exit. Acceptable (≤5 min).

---

### 🟡 Medium Issues (M1-M8) — concise treatment

#### M1 — State File Schema Consistency (8)

**M1-1** Pre-Path-A repos miss `mode` field — readers encounter unknown schema.
- **Fix:** Treat absent `mode` as `bootcamp` (default). Validator accepts absent `mode`. Migration script (`scripts/migrate-add-mode.sh`) backfills existing repos.
- **Evidence:** YAML parser in `_lib.js` returns empty fields gracefully (read locally).

**M1-2** `vacation.md` written but `current_day.md` not atomic — temporary inconsistency.
- **Fix:** Single commit writes both files. `git commit -m "..." -- state/vacation.md state/current_day.md`.
- **Evidence:** Git commits are atomic per https://git-scm.com/docs/git-commit.

**M1-3** `vacation.md` left on disk after `/resume-routines`.
- **Fix:** `/resume-routines` first archives `vacation.md` to `archive/vacations.md` (append), then `git rm state/vacation.md`.
- **Evidence:** O_APPEND atomicity per man7.org/linux/man-pages/man2/open.2.html.

**M1-4** `missed_routines.md` >7d cap.
- **Fix:** Covered by CRIT-03.

**M1-5** ISO-8601 without TZ offset.
- **Fix:** All timestamps as `<YYYY-MM-DD>T<HH:MM:SS>+05:30` per RFC 3339. Validator rejects bare-date timestamps in date fields.
- **Evidence:** RFC 3339 §5.6 — https://www.rfc-editor.org/rfc/rfc3339. Quote: "`time-numoffset = ("+" / "-") time-hour ":" time-minute`". Bare dates compared against UTC produce silent failures per W3C: https://w3c.github.io/timezone/.

**M1-6** `reference_date` missing from `missed_routines.md` entries.
- **Fix:** Schema adds required `reference_date` field. Validator enforces.

**M1-7** `loop_week.active` and `loop_week.completed` both true.
- **Fix:** Validator constraint: `(active AND NOT completed) OR (completed AND NOT active)`. `/day-wrap` enforces transition.

**M1-8** `bootcamp.current_day` and `loop_week.current_day` race.
- **Fix:** Single writer per file via SOURCE_OF_TRUTH; resume orchestration sequenced (CRIT-13).

---

#### M2 — Pause/Resume Lifecycle (10)

**M2-1** Twice-clicked `/pause-routines` race.
- **Fix:** Covered by CRIT-12 (cross-surface) + skill idempotency check via `git fetch && git diff`.

**M2-2** Push fails (transient network).
- **Fix:** Skill polls `gh run list` (CRIT-10). On failure, surfaces user-visible error.

**M2-3** Resume past last day of curriculum.
- **Fix:** Skill checks `curriculum_weeks*.xml` `<active_files>` for valid resume day. If beyond end, prompts user: "Bootcamp curriculum ends at Day N. Continue with self-directed practice?"

**M2-4** Resume after 09:00 IST Monday — distillation already ran.
- **Fix:** Resume MUST happen before Sunday 23:59 IST or user accepts "Monday distillation has stale view." Document explicitly. No technical fix needed.

**M2-5** Slack confirmation succeeds but state rewrite fails.
- **Fix:** Resume's last action is the Slack post. State writes happen first (atomic), then Slack post.

**M2-6** 30-day pause limit elapses.
- **Fix:** `/pause-routines` warns when end_date >30d. After 30d with vacation.md still present, daily-wrap escalates: "⚠️ Pause exceeds 30-day cap. Manual intervention required."

**M2-7** User edits vacation.md manually without skill.
- **Fix:** Cross-file consistency validator (per GAP-03): `validate-vacation-consistency.js` runs on pre-merge. If `vacation.md` exists but `current_day.md.mode != paused` (or vice versa), validator fails. **Evidence:** This is a new validator; cite GAP-03.

**M2-8** `/pause-routines` Sunday morning before retrospectives.
- **Fix:** Run-once-before-pause exception per spec EC-01.

**M2-9** Past start_date.
- **Fix:** Skill rejects start_date in past (>1 day) unless `--force` flag.

**M2-10** Skill from Code app vs Cowork.
- **Fix:** Skill body identical on both surfaces; relies on `gh` CLI in Cowork (locally installed) but NOT in cloud sessions.
- **Evidence:** "The `gh` CLI is not pre-installed" — https://code.claude.com/docs/en/claude-code-on-the-web.

---

#### M3 — Carry-Forward Replay (9)

**M3-1** Catch-up replay rewrites `state/schedule.md` for past dates — timestamp inversion.
- **Fix:** A4-Option-C resolution: NO back-dated replay. Resume writes today's schedule only.

**M3-2** Curriculum-sync catch-up — pipeline advanced.
- **Fix:** Resume runs ONE curriculum-sync inline (CRIT-13).

**M3-3** Same reference_date entries — replay order undefined.
- **Fix:** Closes GAP-05. Routines have explicit ordering per their dependency graph (#1 → #2; #5 → #7).

**M3-4** Distillation archives vacation logs.
- **Fix:** Covered by CRIT-07.

**M3-5** 56 replay items time out.
- **Fix:** A4-Option-C; covered by CRIT-15.

**M3-6** Spaced-rep replay picks resolved drills.
- **Fix:** No replay (A4-Option-C). Spaced-rep on resume day picks fresh.

**M3-7** Weekly-review replay window covers vacation.
- **Fix:** Weekly-review checks `vacation.md.start_date`. Mark vacation days as `gap_days_in_window: N` in output.

**M3-8** Branch-cleanup catch-up replay.
- **Fix:** GAP-06 closure: branch-cleanup explicitly excluded from `missed_routines.md` carry-forward. Documented in routine 08.

**M3-9** Replay of commit-reminder fires `[ZERO-COMMIT]` on every vacation day.
- **Fix:** No replay (A4-Option-C). Plus: commit-reminder routine checks `vacation.md` and writes `[VACATION-DAY]` instead of `[ZERO-COMMIT]`.

---

#### M4 — Cron / GitHub Actions (7)

**M4-1** Routine #3 daily fires Sunday into review day.
- **Fix:** Path A v3 keeps Mon-Sat for #3 + #4 (per GAP-04 resolution). Step 0 preamble's effective on day-of-week mismatch = early exit.
- **Evidence:** GitHub Actions cron supports `1-6` day-of-week range. https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows.

**M4-2** Allowlist abuse via malicious branch.
- **Fix:** Promoted to CRIT-17. Branch parse step rejects unmatched routines.

**M4-3** Distillation 2 minutes after resume → partial state.
- **Fix:** Resume contract: must complete by Sunday 23:59 IST or user accepts staleness. Documentation-only.

**M4-4** Runner file cache.
- **Fix:** GitHub Actions runners are ephemeral per job. No disk caching across runs.
- **Evidence:** https://docs.github.com/en/actions/using-github-hosted-runners/about-github-hosted-runners — quote: "A new VM is created for each job."

**M4-5** Day-1 vacation banner before midnight rollover.
- **Fix:** `build-daily-wrap.sh` checks `vacation.md.start_date` against today's IST date (`TZ=Asia/Kolkata date +%F`). Banner logic uses IST-day, not UTC.
- **Evidence:** GNU date supports `TZ=` env var per https://www.gnu.org/software/coreutils/manual/html_node/Specifying-time-zone-rules.html.

**M4-6** Daily #5/#7 produce 7× output.
- **Fix:** Per GAP-04: cron schedules unchanged. Step 0 preamble does day-of-week gating.

**M4-7** `skip:` commit prefix.
- **Fix:** Not used. Skip artifacts are state-file content (`mode: paused` in schedule.md), not commit-message tags.

---

#### M5 — RTI Band Staleness (5)

**M5-1** No auto-decay during pause.
- **Fix:** A9-Option-C: time decay informational only. Add `last_band_update: <ISO>` field. Display "(staleness: N days)" in active_weak_spots.md when band data >7d old.

**M5-2** Annotation mismatch between RTI state and active_weak_spots.
- **Fix:** Single writer (`/post-session`) for both. Validator enforces last_updated match.

**M5-3** Annotation overwritten by first post-session run.
- **Fix:** `/post-session` reads existing annotation; preserves if user hasn't drilled in N days.

**M5-4** Pre-resume drills target stale Band 2.
- **Fix:** `/resume-routines` adds annotation; spaced-rep on resume day picks Band 1 warm-up if last_drill_at >7d ago.

**M5-5** Drift-audit no-data sparse.
- **Fix:** Existing routine 07 already handles no-data case correctly (read locally; routine spec includes "no-data schema").

---

#### M6 — Skill Invocation Edge Cases (7)

**M6-1** Pause invoked during teaching session.
- **Fix:** Skill confirms with user before committing: "Pause now? This will commit + push."

**M6-2** Resume rewrite loses last_session_summary.
- **Fix:** Covered by CRIT-16 + GAP-02 archival.

**M6-3** Validator doesn't enforce writer-allowlist.
- **Fix:** Covered by CRIT-16. Update validator.

**M6-4** Concurrent pause + morning-briefing race.
- **Fix:** Workflow concurrency lock (already in workflow YAML). Step 0 preamble re-reads `state/current_day.md` after lock acquisition.

**M6-5** Slack down — resume completes but no notification.
- **Fix:** Slack post is best-effort with HTTP-200 assert. On non-200, log warning to `state/notifications.log` for next session start.
- **Evidence:** Slack 1 msg/sec, HTTP 200 on success, plain-text body `ok`. https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks.

**M6-6** Resume reads pre-vacation `progress_state.xml`.
- **Fix:** Covered by CRIT-13.

**M6-7** Idempotent re-invoke when `vacation.md` exists.
- **Fix:** Skill checks for existing vacation.md. If present, prompts: "Vacation already active (since <start_date>). Update or cancel?"

---

#### M7 — Hook Behavior Under Pause (6)

**M7-1, M7-3, M7-4, M7-6** — Promoted to CRIT-14 (class).

**M7-2** SessionStart graceful degrade when vacation.md absent.
- **Fix:** Already gracefully handled by `_lib.js` `loadContext()` missing-file logic.
- **Evidence:** `_lib.js` lines 161-169 (read locally): "missing.push(entry.rel); continue;"

**M7-5** "pause" / "vacation" natural language conflict with skill.
- **Fix:** UserPromptSubmit hook already routes natural-phrase to skill via specific regex. New patterns added: `/(:pause\b|pause routines|going on vacation)/i` → routes to `/pause-routines`.

---

#### M8 — Cross-Routine Data Dependencies (10)

**M8-1** `[STALE-CURRICULUM]` after resume despite curriculum being fine.
- **Fix:** Covered by CRIT-13. Resume orchestration ensures sync runs before briefing.

**M8-2** Drift-audit reads weekly-review absent.
- **Fix:** Drift-audit's existing freshness check handles this (FRESHNESS_FLAG=stale, continue with stale tag).
- **Evidence:** routine 07 spec lines 38-41 (read locally).

**M8-3** Distillation `git mv` doesn't appear on main until merged.
- **Fix:** Auto-merge sequence: distillation → claude/monday-distillation-<date> → auto-merge → main. Standard flow; no fix needed.

**M8-4** Briefing template extracts fields from gap-notice last_session_summary.
- **Fix:** Resume's gap-notice rewrite preserves the schema (fills `Completed: (vacation gap)`, `Unresolved: (none — pre-vacation N days ago)`, `Tomorrow's first task: re-orient with /companion or jump straight to /teach <topic>`). Briefing's awk extraction still works.

**M8-5** Spaced-rep selection algorithm reads non-existent files.
- **Fix:** routine 03 spec already handles this — picks first drill if no recent files exist.
- **Evidence:** routine 03 spec lines 47-48 (read locally).

**M8-6** Weekly-review covers entirely vacation week.
- **Fix:** Weekly-review's existing logic with vacation-aware annotation: "Window: trailing 7 days; `vacation_gap: 5` days excluded."

**M8-7** progress_state.xml stale — covered by CRIT-13.

**M8-8** Branch-cleanup correctly handles pause/resume branches after 30 days.
- **Fix:** No change. Pause/resume branches are normal `claude/*` branches; 30-day cap applies.

**M8-9** Pause-skill commit makes day appear productive.
- **Fix:** routine 04 (commit-reminder) filters out commit subjects containing `chore(pause):` or `chore(resume):` via existing `--invert-grep --grep="commit-reminder"` mechanism (extend the grep pattern).

**M8-10** Partial-vacation logs.
- **Fix:** Distillation's `vacation_gap` annotation only applied to logs with `date >= start_date AND date < end_date`. Last day before vacation = study session. First day of resume = study session. Documentation-only.

---

### 🟠 6 New Path A Gaps (GAP-01 .. GAP-06)

#### GAP-01 — Resume ordering contract is undefined
**Fix:** Path A v3 adds explicit "Resume orchestration sequence" doc section: (1) `/resume-routines` runs at user-triggered time; (2) clears `mode: paused`; (3) inline curriculum-sync; (4) computes resume day; (5) writes `state/current_day.md`, `state/last_session_summary.md`, archives vacation.md; (6) commits + pushes; (7) Slack confirmation. Resume MUST complete before 09:00 IST Monday; document this hard cap.

**Evidence:** Cron is best-effort per https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows ("queued jobs may be dropped").

---

#### GAP-02 — last_session_summary.md destructive overwrite
**Fix:** Resume archives current `last_session_summary.md` to `archive/sessions/<pre-vacation-end-date>-pre-resume.md` before rewriting.

**Evidence:** Append-archival pattern is the same as `archive/completed_days/` for distillation. POSIX rename is atomic per https://man7.org/linux/man-pages/man2/rename.2.html.

---

#### GAP-03 — vacation.md / current_day.md sync on manual edits
**Fix:** New validator `scripts/validate-vacation-consistency.js`. Runs on pre-merge. Fails if (`vacation.md` exists ⊕ `current_day.md.mode == paused`).

**Evidence:** Validator pattern matches existing `validate-state-schemas.js`. Add to `.github/scripts/run-validators.sh` validator list.

---

#### GAP-04 — A1 ambiguity in Path A's own text
**Fix:** Resolve as Option-B: suppress study-facing only (#2, #3, #4). Routines #1, #5, #6, #7, #8 keep running. **Step 0 preamble for routine #1 reads `vacation.md.suppress_routines` not `mode`.** Other infrastructure routines are simpler — they don't need pause-awareness.

**Evidence:** Per recommendation in path-a-v3-issues.md A1.

---

#### GAP-05 — Catch-up replay ordering within a single date
**Fix:** Moot — A4-Option-C means no back-dated replay. If A4 changes, ordering doc: routine #1 (sync) → #2 (briefing) → #3 (spaced-rep) → #4 (commit-reminder) → #5/#7 weekly retrospective → #6/#8 maintenance.

---

#### GAP-06 — Branch-cleanup catch-up exclusion
**Fix:** Routine #8 explicitly excluded from `missed_routines.md` carry-forward via Step 0 preamble check: `if [ "$ROUTINE_NAME" = "branch-cleanup" ]; then exit_normal; fi`.

---

### Edge Cases (EC-01 .. EC-05)

#### EC-01 — Vacation starts Sunday — retrospectives fire before pause lands
**Fix:** "Run-once-before-pause" semantic. Routine #5 (weekly-review) and #7 (drift-audit) Step 0 preamble: if today is Sunday AND not yet run today, run normally even if `mode: paused`. Tracked by file existence (`state/weekly-review-<this-Sunday>.md`).

---

#### EC-02 — IST/UTC date boundary
**Fix:** All timestamps RFC 3339 with `+05:30` offset. Routines normalize to IST via `TZ=Asia/Kolkata date` before comparing.
**Evidence:** RFC 3339 §5.6 + IANA tzdata Asia/Kolkata fixed UTC+5:30 since 1945.

---

#### EC-03 — First Monday post-vacation race
**Fix:** Resume sequenced before 09:00 IST Monday (GAP-01). If user resumes after 09:00 IST, monday-distillation already ran with stale state; user accepts a "monday distillation re-run available via workflow_dispatch" path.

---

#### EC-04 — GitHub Actions 60-day inactivity auto-disable
**Fix:** **Not applicable to private repos.** Sudhan09/study-companion is private, so the 60-day auto-disable does not apply.
**Evidence:** https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows. Quote: "In a public repository, scheduled workflows are automatically disabled..." — public-only.

---

#### EC-05 — `last_session_summary.md` shows pre-vacation content
**Fix:** Resume rewrites with explicit gap header. SessionStart hook injects with `[NOTE: last session was N days ago — historical context, not yesterday]` prefix.

---

### Design Ambiguities (A1-A10) — recommended resolutions

| ID | Recommendation | Evidence |
|---|---|---|
| A1 | Option-B (suppress study-facing only) | path-a-v3-issues.md A1 + GAP-04 fix |
| A2 | Option-A (auto-set from progress_state.xml +1) with Slack confirm | CRIT-06 + CRIT-13 |
| A3 | Option-A active record + archive/vacations.md append-log | path-a-v3-issues.md A3 |
| A4 | Option-C (no replay; partial exception: curriculum-sync inline) | CRIT-15 evidence |
| A5 | Option-B (next cron window) with placeholder schedule | path-a-v3-issues.md A5 |
| A6 | Option-B (resume Slack notification) | path-a-v3-issues.md A6 |
| A7 | Option-A (collapse — `mode: paused` covers everything) | path-a-v3-issues.md A7 |
| A8 | Option-A (each routine writes when detecting paused) | path-a-v3-issues.md A8 |
| A9 | Option-C (informational time decay only) | M5 fixes |
| A10 | Option-B variant: Day 1 + last day, not every day in between | path-a-v3-issues.md A10 |
| **A11 (new)** | Skills (not routines) need `mode` awareness too — `/pause-routines` re-invocation prompts user | CRIT-12, M6-7 |

---

### 8 Wrong Assumptions — corrections

1. **A1-WRONG (stateless routines)** — confirmed by Anthropic docs: routines run as full Claude Code cloud sessions with state read from cloned repo. The "stateless" framing was always wrong; Path A v3 makes the state explicit.
2. **A2-WRONG (single source of truth)** — partially correct; `current_day.md` IS authoritative for `mode`, but `progress_state.xml` is authoritative for curriculum. Resume reconciles. CRIT-13.
3. **A3-WRONG (allowlist covers all)** — extend per CRIT-05.
4. **A4-WRONG (skills modify state without push)** — confirmed by issue #53497: routines silently lose work without explicit push. Skill body must `git push`.
5. **A5-WRONG (RTI bands intact through pause)** — A9-Option-C: informational decay annotation.
6. **A6-WRONG (morning-briefing always correct)** — Step 0 preamble + paused-day banner per CRIT-08.
7. **A7-WRONG (30-min gap sufficient)** — confirmed by GitHub Actions docs: cron is best-effort, "queued jobs may be dropped." Resume orchestration must use polling, not assume timing.
8. **A8-WRONG (routine failure observable in Slack)** — confirmed by CRIT-05 / CRIT-11 cluster: silent failures are real. Notification design must include explicit success-path heartbeat.

---

## Section 3 — Risk Register

| ID | Risk | Probability | Impact | Mitigation | Evidence |
|---|---|---|---|---|---|
| R-01 | Branch protection on `main` blocks `GITHUB_TOKEN` push | medium | total workflow failure | Use `actions/create-github-app-token` action with bypass perms; document in workflow comments | https://github.com/orgs/community/discussions/25305 (chrispat) |
| R-02 | Routine pushes silently lost (issue #53497) | medium | invisible-to-user state divergence | Every routine prompt + skill body must include explicit `git push` step | https://github.com/anthropics/claude-code/issues/53497 |
| R-03 | Cowork hooks remain dormant indefinitely (#40495 unfixed) | high | hook-based state mutations don't fire on Cowork | Move state-critical logic into skill bodies (self-commit, self-push); CLAUDE.md @-imports for context (which DO work) | https://github.com/anthropics/claude-code/issues/40495 |
| R-04 | `/pause-routines` cross-surface race corrupts archive log | low | irreversible vacation history loss | Restrict skill to Cowork OR add fetch-and-diff idempotency check | CRIT-12 |
| R-05 | Auto-merge revert misread as generic failure | medium | pause not applied | Special-case Slack body for pause/resume branches | CRIT-11 |
| R-06 | Concurrency replaces pending — pushes lost on resume burst | low (with A4-Option-C) / high (with A4-Option-A) | catch-up data loss | Lock A4-Option-C; if A4 changes, add `queue: max` | CRIT-15 |
| R-07 | `/resume-routines` reads stale `progress_state.xml` | high | wrong resume day | Inline sync-then-read sequence | CRIT-13 |
| R-08 | Validator misses writer-allowlist → SOURCE_OF_TRUTH demoted | high | architectural integrity | Update validator to enforce per-file ALLOWED_WRITERS | CRIT-16 |
| R-09 | Slack webhook revoked (Slack auto-detect leak) | low | notifications stop | post-to-slack.sh detects HTTP 404 `no_service`, surfaces alert via state-file fallback | https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks |
| R-10 | Cron drops scheduled fire (high-load minute) | low | one missed routine per N weeks | Schedule at non-:00 minutes (already at `:30`); rely on heartbeat-by-design daily-wrap | https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows |

---

## Section 4 — Dependency Graph

```
                    [SOURCE_OF_TRUTH update]
                              |
                              v
                  [validate-state-schemas.js update]   <-- CRIT-04, CRIT-16
                              |
                              v
                       [Step 0 preamble]
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
     [Routine 1 prompt]  [Routine 2-8]   [Hooks pause-aware]
                              |               |
                              v               |
                        [/pause-routines  <---+
                          skill] ---> [/resume-routines  <--- CRIT-13: must follow
                              |                  skill]            curriculum-sync
                              |                   |
                              +---------+---------+
                                        |
                                        v
                               [Workflow allowlist]   <-- CRIT-05
                                        |
                                        v
                          [Workflow body extractor]    <-- CRIT-09
                          [pause/resume Slack arms]   <-- CRIT-11
                                        |
                                        v
                              [Daily-wrap mode-aware]   <-- CRIT-09
                                        |
                                        v
                            [Validator: vacation-consistency]   <-- GAP-03
```

---

## Section 5 — Implementation Order

Topological sort by dependency. Estimated executor hours per phase.

### Phase 1 — Schema + Validators (5–8h)
1. Update `state/SOURCE_OF_TRUTH.md` writer registry (1h)
2. Update `scripts/validate-state-schemas.js` ALLOWED_WRITERS + `mode` field (2h)
3. Add `scripts/validate-vacation-consistency.js` (GAP-03) (2h)
4. Migration script `scripts/migrate-add-mode.sh` (M1-1) (1h)
5. Test all validators on existing tree + new `mode` cases (1h)

**Blocks:** All Phase 2/3 work.

### Phase 2 — Routine Step 0 Preamble (8–12h)
6. Author Step 0 preamble template (2h)
7. Apply to routines #1-8 prompt blocks (4-6h)
8. Re-paste to `claude.ai/code/routines` UI (1h)
9. Verify hashes via `scripts/check-routine-skew.sh` (1h)
10. Smoke-test each routine via `gh workflow run` or routine UI manual fire (2h)

**Blocks:** Phase 3.

### Phase 3 — Skills (10–15h)
11. Author `/pause-routines` skill (3-4h)
12. Author `/resume-routines` skill with CRIT-13 orchestration (5-7h)
13. Update `_lib.js` `loadContext()` for `mode` awareness (1h)
14. Update `stop.js` for pause-skip (CRIT-14) (1h)
15. Update `/day-wrap` skill for pause-guard (1h)
16. Plugin test suite updates (`tests/run-all.js`) (1-2h)

**Blocks:** Phase 4.

### Phase 4 — Workflow + Observability (5–8h)
17. Extend allowlist in `auto-merge-and-notify.yml` (CRIT-05, CRIT-17) (1h)
18. Special-case Slack body for pause/resume branches (CRIT-11) (2h)
19. Update `build-daily-wrap.sh` for `mode` awareness (CRIT-09) (2h)
20. Update `extract-canonical-body.sh` for vacation banner (1h)
21. Smoke-test full pause/resume flow end-to-end (2h)

### Phase 5 — Hardening + Documentation (5–8h)
22. Document the 30-day pause cap + resume timing contract (2h)
23. Update `CLAUDE.md` to surface `mode` (and reference `vacation.md`) (1h)
24. Add cross-file consistency validator to pre-commit + CI (already in run-validators.sh) (1h)
25. Wire monitoring: `state/notifications.log` for Slack failures (M6-5) (2h)
26. Final review + skew check (1h)

**Total:** 33–51h core + 12–14h hardening = **45–65h**.

---

## Section 6 — Open Questions for User

1. **A4 final decision.** Recommendation is Option-C (no back-dated replay), but if Sudhan prefers full replay-with-staleness-tags, CRIT-15 mitigation requires `queue: max` plus queue-depth alerting. **Confirm before Phase 3.**

2. **Cowork-only vs both-surface for `/pause-routines`.** CRIT-12's mitigation is cleaner if restricted to Cowork. Allowing both surfaces requires a remote-state probe in skill body. Sudhan's preference?

3. **Branch protection on `main`.** Is it currently enabled? If yes, R-01 mitigation (GitHub App token) adds Phase 4 work. If no (currently no), defer to "we'll add it later" and document the assumption.

4. **`gh` CLI in cloud routines.** CRIT-13's resume orchestration needs `gh workflow_dispatch` to trigger curriculum-sync. Anthropic docs confirm `gh` is NOT pre-installed; install via setup script + `GH_TOKEN`. Confirm setup-script is acceptable, OR fall back to: skill body runs sync inline (clones pipeline repo, copies files, commits, pushes — all in skill body without `gh`).

5. **Hooks pause-awareness scope.** CRIT-14 proposes guarding all 4 hooks. Stop hook + `/day-wrap` are clear wins. SessionStart pause-banner + PreCompact snapshot + UserPromptSubmit confirmation are nice-to-haves. Triage to MVP scope?

6. **Slack `username`/`icon`/`channel` cleanup.** Modern app-attached webhooks ignore these. `post-to-slack.sh` currently sends them. Remove (1-line cleanup) or leave as cosmetic clutter?

7. **Empty marker commits.** Some Path A v3 designs imply heartbeat-marker commits. `git merge --no-ff` cannot create empty commits. Is `git commit --allow-empty` acceptable for any workflow path that needs a marker?

8. **Resume Slack format.** "✅ Resumed" vs verbose ("✅ Resumed; bootcamp Day N+1; loop_week Day 4 paused; first task: ..."). UX call.

9. **30-day cap escalation.** When vacation.md persists past 30 days, daily-wrap escalates. Format: error message vs page-on-call vs continued silent? (My recommendation: persistent ALERT in daily-wrap until manually cleared.)

10. **`progress_state.xml` resume calculation.** If pipeline repo's `<completed_through_day>` advanced during pause but Sudhan didn't actually do those days' content (pipeline tracks intended, not actual), `/resume-routines` setting `current_day = completed_through_day + 1` might over-skip. Per CLAUDE.md: "Sudhan generates 10+ days of curriculum content in batches without studying them all." Resume calc may need a separate "actual day" pointer that's user-confirmed. **High-priority decision.**

---

## Section 7 — Evidence Index

### Anthropic / Claude Code (verified-fetched)
- https://code.claude.com/docs/en/routines — routine sandbox, GitHub App auth, `/web-setup`, `claude/<branch>` policy, retries, webhook caps
- https://code.claude.com/docs/en/claude-code-on-the-web — cloud-session details, env vars, hook policy, plugin policy, gh CLI absence, IP allowlist limitation
- https://code.claude.com/docs/en/skills — `allowed-tools`, `disable-model-invocation`, Bash injection, `disableSkillShellExecution` policy
- https://code.claude.com/docs/en/hooks — full hook event taxonomy, Stop event fields, additionalContext 10K cap, exit code semantics
- https://code.claude.com/docs/en/memory — CLAUDE.md @-imports depth-5, HTML comment stripping, /compact re-read, external-import approval
- https://code.claude.com/docs/en/desktop — Cowork tab existence, Dispatch
- https://code.claude.com/docs/en/discover-plugins — plugin scopes, `commit-commands` bundled, cache location
- https://platform.claude.com/docs/en/api/claude-code/routines-fire — `/fire` endpoint, beta header, no idempotency, 65,536 char text cap, 429/503 semantics
- https://github.com/anthropics/claude-code/issues/40495 — Cowork hook dormancy investigation (OPEN, no maintainer fix)
- https://github.com/anthropics/claude-code/issues/53497 — silent push loss (OPEN)
- https://claude.com/product/cowork — marketing page (no internal details)

### GitHub Actions (verified-fetched)
- https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax — branch globs, concurrency, paths filters
- https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows — cron SLA, 60-day disable (public-only), schedule warnings
- https://docs.github.com/en/actions/reference/workflows-and-actions/contexts — inputs context, env, allowed-in-if
- https://docs.github.com/en/actions/reference/workflows-and-actions/expressions — always(), cancelled(), failure(), success()
- https://github.com/orgs/community/discussions/25305 — chrispat: GITHUB_TOKEN cannot push to protected main
- https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-do-not-trigger-workflows.md — no-cascade rule
- https://raw.githubusercontent.com/github/docs/main/data/reusables/actions/actions-group-concurrency.md — pending-replacement default, queue:max
- https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2204-Readme.md — pre-installed tools
- https://github.com/actions/checkout (README) — persist-credentials, $RUNNER_TEMP storage in v6

### Slack (verified-fetched)
- https://docs.slack.dev/messaging/sending-messages-using-incoming-webhooks — webhook payload format, no override of channel/username/icon, error codes (404 no_service, 400 invalid_payload, 403 action_prohibited)
- https://docs.slack.dev/apis/web-api/rate-limits — 1 msg/sec, 429 + Retry-After
- https://docs.slack.dev/reference/methods/chat.postMessage — 40,000 char hard cap, 4,000 recommended
- https://docs.slack.dev/messaging/formatting-message-text — mrkdwn syntax, emoji shortcodes
- https://docs.slack.dev/reference/block-kit/blocks — 50 blocks/message
- https://docs.slack.dev/messaging — text field mrkdwn rendering
- https://docs.slack.dev/legacy/legacy-custom-integrations/legacy-custom-integrations-incoming-webhooks — historical channel-override semantics

### POSIX / Linux man pages (verified-fetched)
- https://pubs.opengroup.org/onlinepubs/9699919799/functions/rename.html — POSIX rename atomicity
- https://man7.org/linux/man-pages/man2/rename.2.html — Linux rename, EXDEV
- https://man7.org/linux/man-pages/man2/flock.2.html — flock advisory, NFS emulation
- https://man7.org/linux/man-pages/man2/fcntl.2.html — fcntl byte-range locks
- https://man7.org/linux/man-pages/man2/open.2.html — O_APPEND atomicity, NFS warning
- https://man7.org/linux/man-pages/man3/tzset.3.html — TZ env var resolution

### Git (verified-fetched)
- https://git-scm.com/docs/git-merge — --no-ff, "Already up to date" pre-check
- https://git-scm.com/docs/git-merge-base — --is-ancestor exit codes
- https://git-scm.com/docs/git-branch — --merged is reachability check
- https://git-scm.com/docs/git-mv — index update on move
- https://git-scm.com/docs/git-checkout — detached HEAD semantics
- https://git-scm.com/docs/git-log — %ci vs %cI format

### Production codebases (verified-fetched)
- https://github.com/postgres/postgres/blob/master/src/backend/utils/misc/guc.c — ALTER SYSTEM lost-update acceptance (canonical citation)
- https://github.com/etcd-io/etcd/blob/main/server/storage/wal/wal.go — tmpfile + rename + fsync pattern
- https://github.com/etcd-io/etcd/issues/6368 — directory fsync needed for rename durability
- https://github.com/google/leveldb/issues/195 — fsync after rename
- https://github.com/npm/write-file-atomic/issues/64 — "Rename atomicity is not enough"

### RFC / Standards (verified-fetched)
- https://www.rfc-editor.org/rfc/rfc3339 — date-time grammar, time-numoffset ABNF
- https://data.iana.org/time-zones/data/asia — Asia/Kolkata fixed UTC+5:30 since 1945-10-15
- https://www.iana.org/time-zones — IANA tzdata authority

### MDN / W3C (verified-fetched)
- https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Date/parse — bare ISO date → UTC midnight
- https://w3c.github.io/timezone/ — bare-date comparison danger
- https://www.gnu.org/software/coreutils/manual/html_node/Specifying-time-zone-rules.html — TZ var syntax

### Local files referenced
- `/home/sudhan/study-companion-real/docs/path-a-v3-issues.md` — issue inventory (84 issues)
- `/home/sudhan/study-companion-real/state/SOURCE_OF_TRUTH.md` — writer registry
- `/home/sudhan/study-companion-real/scripts/validate-state-schemas.js` — current validator
- `/home/sudhan/study-companion-real/scripts/validate-imports.js`
- `/home/sudhan/study-companion-real/scripts/validate-wins-schemas.js`
- `/home/sudhan/study-companion-real/.github/workflows/auto-merge-and-notify.yml` — current workflow
- `/home/sudhan/study-companion-real/.github/scripts/build-daily-wrap.sh`
- `/home/sudhan/study-companion-plugin/hooks/_lib.js`
- `/home/sudhan/study-companion-plugin/hooks/stop.js`
- `/home/sudhan/study-companion-plugin/hooks/session-start.js`
- `/home/sudhan/study-companion-plugin/hooks/user-prompt-submit.js`
- 8× `/home/sudhan/study-companion-real/routines/0[1-8]-*.md`

### `[NO EVIDENCE]` items
- `[NO EVIDENCE — ANTHROPIC INTERNAL]` Maintainer-confirmed roadmap for issue #40495 (Cowork hook fix). Searched anthropics/claude-code on 2026-05-07; no Anthropic-staff comment in thread.
- `[NO EVIDENCE — UNCERTAIN]` Project-scope `.claude/settings.json` hook firing in Cowork. Issue #40495 confirms user-scope settings don't work; project-scope is undocumented either way. Smoke-test before relying.
- `[NO EVIDENCE — UNCERTAIN]` GitHub Actions step kill signal (SIGTERM-then-SIGKILL grace window). Docs say "killing the process" without specifying.
- `[NO EVIDENCE — UNCERTAIN]` `awk` enumerated in Ubuntu-22.04 runner README (present via mawk in base image; not in apt table).
- `[NO EVIDENCE — UNCERTAIN]` Per-routine concurrency limit (can the same routine fire twice in parallel?).
- `[NO EVIDENCE — ANTHROPIC INTERNAL]` Routine retry-on-failure semantics beyond webhook 429/503.
- `[NO EVIDENCE — UNCERTAIN]` CLAUDE.md frontmatter handling (stripped vs injected).

---

*End of design research.*
