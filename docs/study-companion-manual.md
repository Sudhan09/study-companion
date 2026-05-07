# Study Companion ("Asta") — Operations Manual

**Owner:** Sudhan
**Generated:** 2026-05-07 (post Path A v3 merge)
**Source of truth:** `Sudhan09/study-companion` (granted folder), `Sudhan09/study-companion-plugin` (plugin), `Sudhan09/python_bootcamp_claude_code` (pipeline)
**Surfaces:** Cowork (Claude Desktop) + claude.ai/code (web/CLI)
**Slack:** workspace `bootcamp-notification`, channel `#study-routines`

---

## 1. What this is

A personal Claude-based study companion ("Asta", emoji 🗡️) for Sudhan's 22-week Python + Stats + SQL bootcamp targeting FAANG DA/DS roles by July 2026. Asta:

1. Enforces a locked teaching method (the **5 Locks**) — slow-ladder layering, inline visualization, teach-before-drill, drill-to-drill deltas, one-analogy-per-concept.
2. Tracks pattern-failure state (the **RTI system** — 6 pattern families, 4 difficulty bands).
3. Logs drift across sessions (banned phrases, missing pulse-checks, batched visuals, etc.).
4. Runs 8 daily/weekly cron routines that push state updates to GitHub.
5. Auto-merges those branches into `main` and notifies Slack.
6. Supports pause/resume for vacations + skip days (Path A v3, shipped 2026-05-07).

The whole system is "available, not performed" — Sudhan is a peer, not a customer.

---

## 2. System map

Three GitHub repositories, all owned by `Sudhan09`:

| Repo | Role | Local path |
|---|---|---|
| **`study-companion`** (granted folder) | Holds `state/`, `instructions/`, `routines/`, `scripts/`, `wins/`, `drills/`, `room-to-improve/`, `archive/`, `.github/`. Loaded via CLAUDE.md @-imports in every Cowork session. Auto-merge workflow lives in `.github/workflows/auto-merge-and-notify.yml`. | `/home/sudhan/study-companion-real` (Linux), `C:\Users\sudha\study-companion` (Windows) |
| **`study-companion-plugin`** | Claude Code plugin — 14 skills, 2 sub-agents, 3 hook handlers (SessionStart, UserPromptSubmit, Stop). | `/home/sudhan/study-companion-plugin` (Linux), `C:\Users\sudha\.claude\plugins\study-companion` (Windows) |
| **`python_bootcamp_claude_code`** | Upstream curriculum pipeline. Read-only from Asta's view — synced daily by routine 01 into `instructions/curriculum/`. | not cloned locally; Anthropic's routine sandbox clones at run start |

**Rule:** Treat the pipeline repo as a content library. `progress_state.xml.completed_through_day` tracks intended curriculum, NOT actual study progress. Sudhan generates 10+ days of curriculum content in batches without studying them all. **`bootcamp.current_day` in `state/current_day.md` is user-maintained — never auto-computed from the pipeline** (Path A v3 Q10 decision).

---

## 3. The 8 cron routines

Anthropic web-scheduled-tasks runs each routine as a full Claude Code cloud session on managed VMs (4 vCPU, 16 GB RAM, 30 GB disk, ephemeral). Each clones `study-companion` (and `python_bootcamp_claude_code` for routine 01) at run start, executes the saved prompt, commits + pushes to `claude/<routine>-<YYYY-MM-DD>`. Auto-merge workflow takes it from there.

| # | Routine | Cron (IST) | Cron (UTC) | Days | Writes |
|---|---|---|---|---|---|
| 01 | `study-curriculum-sync` | `30 8 * * *` | `0 3 * * *` | Daily | `instructions/curriculum/*.xml` (6 files) + `.last-sync-status` |
| 02 | `study-morning-briefing` | `0 9 * * *` | `30 3 * * *` | Daily | `state/schedule.md`, `logs/<date>.md` (header) |
| 03 | `study-spaced-rep-reminder` | `0 19 * * 1-6` | `30 13 * * 1-6` | Mon–Sat | `state/spaced-rep-<date>.md` |
| 04 | `study-github-commit-reminder` | `30 20 * * 1-6` | `0 15 * * 1-6` | Mon–Sat | `logs/<date>.md` (`## Commit reminder` section) |
| 05 | `study-weekly-review` | `0 10 * * 0` | `30 4 * * 0` | Sun | `state/weekly-review-<date>.md` |
| 06 | `study-monday-distillation` | `0 9 * * 1` | `30 3 * * 1` | Mon | `archive/completed_days/<date>.md` + `state/distilled.md` index |
| 07 | `study-drift-audit` | `30 10 * * 0` | `0 5 * * 0` | Sun | `state/drift-audit-<date>.md` |
| 08 | `study-branch-cleanup` | `30 11 * * 0` | `0 6 * * 0` | Sun | `logs/<date>.md` (`## Branch cleanup` section); deletes merged `claude/*` branches >30d |

**Cross-routine ordering:** #1 must precede #2 (curriculum-sync writes `.last-sync-status` that morning-briefing reads to detect STALE). #5 should precede #7 on Sundays (weekly-review's output is cross-referenced by drift-audit).

**Repository config per routine:** all routines have only `Sudhan09/study-companion` as repo, EXCEPT routine 01 which adds `Sudhan09/python_bootcamp_claude_code` as secondary (read-only, gets cloned to `./pipeline/`).

**Connectors:** none for any routine. Strip default MCP connectors when configuring.

**Triggers:** cron-only. No GitHub event hooks, no API triggers.

**Step 0 preamble (Path A v3, all 8 routines):** every routine reads `state/current_day.md.mode` first. If `mode == paused` AND this routine is in `vacation.md.suppress_routines`, it appends an audit row to `state/missed_routines.md`, commits, pushes, and exits cleanly. Default suppress list: `[study-morning-briefing, study-spaced-rep-reminder, study-github-commit-reminder]` (per GAP-04 Option-B). Other routines run through pause with vacation-aware annotation downstream.

**Routine prompt bodies:** stored at `~/routine-prompts/0X-study-<name>.md`. Re-paste into `https://claude.ai/code/routines` whenever the source files in `routines/0X-*.md` change. Verify with `bash scripts/check-routine-skew.sh` (note: routine 08's hash is unreliable due to nested triple-backticks; use `diff` instead).

---

## 4. Skills inventory (14 skills)

All in `study-companion-plugin/skills/`, auto-namespaced as `/study-companion:<name>` (or `/<name>` for short).

### Teaching skills

- **`/teach`** — Substantive teaching of a new concept. Enforces 3-layer structure with inline visualization and pulse-checks between layers.
- **`/teach-from-win`** — Apply the kind-of-move from past wins to a current concept. Forces precondition-first workflow (read user's current confusion before generating).
- **`/drill`** — Issue a coding drill at a specific RTI band, with explicit pattern-family target and delta from previous drill.
- **`/trace`** — Force mental simulation of an iteration (trace tables only — no execution) before any code is written.
- **`/calibrate`** — Mid-teaching check: output a draft, then ask "mechanical/generic/on-target?". User-in-the-loop, faster than `/self-review`.
- **`/self-review`** — Critique your own draft response before sending. Catches stacked analogies, missing pulse-checks, batched visuals, banned phrases.

### Win/state-capture skills

- **`/lock-decision`** — Capture a teaching win. Schema: `user_precondition` (verbatim), `concept_gap`, `test` (counterfactual), `artifact`. Triggered by `:lock`, "lock it in", "mark it", "remember this".
- **`/lock-weak-spot`** — Append a new RTI pattern-family failure to `state/active_weak_spots.md` after a drill miss or repeated bug.
- **`/post-session`** — Forced session debrief template. Updates RTI state + `state/last_session_summary.md`. Mandatory after any session with ≥1 drill.
- **`/day-wrap`** — End-of-day debrief. Updates `state/current_day.md` + `state/last_session_summary.md`, appends to `logs/<date>.md`. Triggered by `:wrap`, "day wrap", "wrap up". **Pause-aware:** refuses to advance `bootcamp.current_day` when `mode=paused` (CRIT-14 fix).

### RTI infrastructure

- **`/rti-preflight`** — Required preamble before any RTI drill session. Reads `room-to-improve/state/current_state.md`, emits `[RTI preflight: ...]` marker.

### Mode skills

- **`/companion`** — Drop teacher voice for casual/banter mode. Triggered by `:companion`, "be a companion", "chat with me".

### Path A v3 skills (shipped 2026-05-07)

- **`/pause-routines`** — Self-committing pause flow. Writes `state/vacation.md`, sets `mode=paused`, writes paused banner to `state/schedule.md`, commits + pushes. Asymmetric confirm: full poll via `gh` on Cowork; `git ls-remote` push-only on cloud. `disable-model-invocation: true` (only user-invoked).
- **`/resume-routines`** — Self-committing resume flow. Prompts user to confirm or change `bootcamp.current_day` (Q10 — never auto-computed). Archives `last_session_summary.md` to `archive/sessions/<start>-pre-resume.md`, rewrites with vacation gap notice, appends to `archive/vacations.md`, removes `vacation.md`, restores prior mode. `disable-model-invocation: true`.

### Sub-agents (2)

- **`pattern-detector`** — Read-only RTI pattern classifier. Reads `instructions/rti-method.md` + drill artifacts, returns `PATTERN: <code>` + 1-line justification + drill recommendation. Tools: `Read` only.
- **`researcher`** — Read-only research subagent. Tools: `Read, Grep, Glob, WebSearch`. NO writes, NO bash.

---

## 5. Hooks (3 active on claude.ai/code, dormant in Cowork per #40495)

| Hook | Fires on | What it does |
|---|---|---|
| **SessionStart** | Session begin or resume | Reads 13 state/instruction files in deterministic order (`hooks/_lib.js` LOAD_ORDER). Wraps `state/*` files in `<untrusted-state>` sentinels. Prepends ⚠️ STALE warning if `last_updated` >24h. Touches `state/.locks/session.lock` with IST timestamp. |
| **UserPromptSubmit** | Before each user prompt is sent | Detects confusion phrases ("I don't get it", "I'm lost", 🤔, etc.) and injects re-angle directive. Detects deterministic tokens (`:lock`, `:companion`, `:wrap`) and injects skill-invocation hints. **Pause-aware:** when `mode=paused` AND `:wrap` token, injects confirmation prompt instead of routing to `/day-wrap` (CRIT-14 fix). |
| **Stop** | After assistant response | Runs 7 detectors on the response (`#3` stacked analogies, `#6` batched visuals, `#7` missing pulse-check, `#9` markdown on light Q, `#10` filler phrases, `#11` missing curriculum anchor, `#15` over-apology). Appends drift entries to `state/drift_log.md`. **Pause-aware:** skips drift detection entirely when `mode=paused` (CRIT-14 fix); does NOT create empty drift_log.md if it doesn't exist. Daily + per-session log writes happen unconditionally. |

**Cowork dormancy** ([#40495](https://github.com/anthropics/claude-code/issues/40495), OPEN): hooks defined in user `~/.claude/settings.json` are silently ignored in Cowork (the sandbox doesn't mount user settings). All three hooks above are repo-committed in the plugin, but project-scope hook firing in Cowork is undocumented — assume they DO NOT fire reliably in Cowork.

**`additionalContext` cap:** 10K chars per hook event. Overflow saved to file with preview.

**No PreCompact / PostCompact:** by design. SessionStart re-reads state files fresh on every session, so no compaction snapshot is needed.

### Plugin loading by surface

Different surfaces load the study-companion plugin via different mechanisms. The asymmetry matters when a skill appears available on one surface but missing on another.

| Surface | Loading mechanism | Plugin status today | Skills visible to model |
|---|---|---|---|
| **Cowork desktop (Windows, local-agent-mode)** | User-scope `~/.claude/plugins/study-companion/` (or `C:\Users\sudha\.claude\plugins\study-companion\`) | Loaded ✓ | 12 in registry; pause/resume hidden by `disable-model-invocation: true` but **on disk and user-invokable via `/pause-routines`** |
| **Local Claude Code CLI** (`claude` from terminal) | Same user-scope path | Loaded ✓ if locally installed; not currently installed on Linux box. Same mechanics as Cowork once installed | Same as Cowork: 12 + 2 hidden |
| **claude.ai/code cloud session** (web/sessions UI) | **Repo-scope `.claude/settings.json` only** — user-scope does NOT transfer to cloud sessions per Anthropic docs | **NOT loaded** ✗ — granted folder has no `.claude/settings.json` declaring the plugin marketplace | 0 plugin skills (none of the 14) |

**Implication:** `/pause-routines` and `/resume-routines` work on Cowork + local CLI but **NOT in claude.ai/code cloud sessions**. This is by design per Path A v3 Q2 (Cowork is the trusted surface — full `gh run list` poll → "merged into main at `<SHA>`" confirmation; cloud session would only get push-only confirmation anyway). Building `Sudhan09/study-companion-marketplace` (per `docs/2026-05-06-windows-handoff.md` §9 Track 4, deferred) would close the cloud-session gap if needed later.

**Diagnostic test** to disambiguate "skill missing because of registry blind spot vs not loaded at all" — see Section 16 troubleshooting "Asta says /pause-routines doesn't exist" below.

---

## 6. State files registry

Each fact has exactly one writer per `state/SOURCE_OF_TRUTH.md`:

| File | Writer(s) | Purpose |
|---|---|---|
| `state/current_day.md` | `/day-wrap`, `/pause-routines`, `/resume-routines`, `user` | Bootcamp day/phase, loop_week state, mode (Path A v3) |
| `state/active_weak_spots.md` | `/post-session`, `/lock-weak-spot`, `user` | RTI pattern-family failures + bands |
| `state/drift_log.md` | Stop hook (claude.ai/code only) | Append-only drift events; pause-skipped |
| `state/last_session_summary.md` | `/post-session`, `/day-wrap`, `/resume-routines` | Yesterday's session debrief |
| `state/schedule.md` | `study-morning-briefing`, `/pause-routines` | Today's plan |
| `state/repos.md` | user | List of additional repos for routine 04 |
| `state/vacation.md` | `/pause-routines`, user | Active vacation record (only exists during pause) |
| `state/missed_routines.md` | All 8 routines (Step 0 append), `/resume-routines` | Audit log of skipped routines during pause |
| `archive/vacations.md` | `/resume-routines` | Append-only vacation history |
| `archive/sessions/<date>-pre-resume.md` | `/resume-routines` | One-shot pre-vacation last_session_summary archive |
| `room-to-improve/state/current_state.md` | `/post-session` | RTI live state (read by `/rti-preflight`) |
| `wins/<date>-<slug>.md` | `/lock-decision` | Captured teaching wins |

**Freshness rules:** Every state file must have `last_updated` (RFC 3339 with IST offset preferred) and `updated_by` frontmatter. SessionStart hook prepends ⚠️ STALE if >24h. Files >72h would refuse injection (not yet enforced).

**Mode field (Path A v3):** `current_day.md` accepts optional `mode: bootcamp | loop_week | paused`. Absent = treated as `bootcamp` (M1-1 default).

---

## 7. Validators

Three Node validators + one cross-file consistency validator. Run pre-merge AND post-merge by the auto-merge workflow's `bash .github/scripts/run-validators.sh`.

| Validator | What it blocks |
|---|---|
| `scripts/validate-imports.js` | Bad CLAUDE.md @-imports (missing files, traversal, absolute paths) |
| `scripts/validate-state-schemas.js` | State files missing frontmatter, missing/unparseable `last_updated`, unauthorized `updated_by` (per ALLOWED_WRITERS), `current_day.md` missing `bootcamp:`/`loop_week:` sections, invalid `mode` value, `vacation.md` schema violations (RFC 3339 offsets required) |
| `scripts/validate-wins-schemas.js` | Wins missing required fields (`date, concept, user_precondition, concept_gap, test, artifact`) or carrying forbidden legacy `trigger:` field |
| `scripts/validate-vacation-consistency.js` | (Path A v3 GAP-03) `vacation.md` exists but `mode != paused` (or vice versa), date-sanity violations |

Plus one operator-run hash-check tool: `scripts/check-routine-skew.sh` (extracts each routine's prompt body and prints sha256-16. Routine 08's hash is unreliable due to nested triple-backticks).

---

## 8. GitHub Actions workflow

`.github/workflows/auto-merge-and-notify.yml`. Two jobs:

### Job A — `per-push-merge-and-notify`

Trigger: push to `claude/<allowlisted>-*` branches. Allowlist: 8 routine prefixes + `claude/pause-routines-*` + `claude/resume-routines-*`.

Steps: repo guard → secret check → checkout main fetch-depth=0 → parse branch → fetch → pre-merge validators (against branch tree, detached HEAD) → merge `--no-ff` → post-merge validators → push main → build Slack body → post to Slack (HTTP 200 assert).

**Failure handling:**
- Pre-merge fail → skip merge, post 🚨 Slack alert (special copy for pause/resume vs generic).
- Post-merge fail → `git reset --hard HEAD~1` to revert, do NOT push, post 🚨 alert.
- Slack post step uses `if: always()` so failures still notify.

### Job B — `daily-wrap`

Trigger: cron `30 15 * * *` UTC (21:00 IST) OR `workflow_dispatch` with `mode=wrap`.

Steps: repo guard → secret check → checkout main → build daily-wrap body via `.github/scripts/build-daily-wrap.sh` → post to Slack.

**Mode-aware (Path A v3):** when `current_day.md.mode == paused`:
- Day 1 of vacation → "🛫 Vacation started" full banner
- Day 2–30 → minimal heartbeat ("🛌 paused · day N · <date>")
- Day 31+ → 🚨 persistent 30-day cap alert
- Last day (when `end_date` reached) → "🛬 Last day of vacation" full banner

Otherwise normal flow: routines fired today (vs expected for day-of-week), drift count, alert markers.

### Mitigations baked in (10)

1. Heartbeat-by-design (daily-wrap always posts)
2. Branch allowlist (not `claude/**`)
3. Validators run pre+post merge
4. Notify decoupled (`if: always()`)
5. Concurrency lock (`group: auto-merge-and-notify, cancel-in-progress: false`)
6. Timeout (10 min Job A, 5 min Job B)
7. Branch filter via push event
8. HTTP 200 assert on Slack POST
9. Scoped `permissions: contents: write`
10. SHA-pinned `actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5` (v4.3.1)

### Setup expectations

- Default branch: `main`
- Branch protection on `main`: **OFF** (per Q3 audit). If ever turned on, `GITHUB_TOKEN` push will fail; use `actions/create-github-app-token` instead per R-01 mitigation.
- Secret: `SLACK_WEBHOOK_URL` (Settings → Secrets and variables → Actions)

---

## 9. Slack notifications

Channel: `#study-routines` in workspace `bootcamp-notification`. Webhook URL is the GitHub secret.

**Per modern app-attached webhook constraints:** username, icon, and channel are FIXED at app install time — they CANNOT be overridden by payload. The post-to-slack.sh script sends only `{text: ...}`.

Rate limit: 1 msg/sec (with short bursts allowed). HTTP 200 = success (plain-text "ok" body, NOT JSON). HTTP 404 = `no_service` (revoked/invalid). HTTP 429 + Retry-After = rate-limited.

### Expected message shapes

**Per-routine success:**
```
🗡️  Routine: <routine-name> · ✅
📅 <date> <HH:MM> IST
─────────────────
<canonical body — frontmatter-stripped state file or extracted section>
─────────────────
🔗 Branch: claude/<routine>-<date>
🔀 Merged to main: <short SHA>
```

**Pre-merge validation failure (pause/resume special-cased):**
```
🚨 PAUSE NOT APPLIED · pause-routines · ❌
📅 <date> <HH:MM> IST

Pre-merge validation failed. `main` is UNCHANGED.
...
🔗 Run: <URL>
```

**Daily wrap (clean day):**
```
🗡️  Asta — Daily Wrap
📅 <date> (<DOW>) • 21:00 IST

📊 Routines today: <fired>/<expected> ✅
- ✅ <routine>: <HH:MM> IST
...

🔀 Auto-merge: <count> branches → main ✅
✅ Validators: passed on all merges

📈 Drift today: <count> entries
ℹ️  Cowork sessions don't log drift (#40495)

🟢 All clean.
```

**Daily wrap (problem day):** has 🚨 ALERTS section first, then routine status with ❌ for missing.

**Mid-vacation:** one-line `🛌 paused · day <N> · <date>`.

---

## 10. Path A v3 — pause/resume flow

Shipped 2026-05-07 to handle vacations, skip days, and mid-day breaks.

### What it does

- Adds `mode: paused` to `state/current_day.md` (alongside existing `bootcamp:` and `loop_week:` blocks)
- Records active pause in `state/vacation.md` with `start_date`, optional `end_date`, `suppress_routines` list, `reason`
- Routines in `suppress_routines` skip via Step 0 preamble (audit-only, no replay)
- Hooks are pause-aware: Stop skips drift detection, /day-wrap refuses to advance day, UserPromptSubmit confirms `:wrap`-while-paused
- Daily-wrap posts mode-aware messages (Day 1 / silent middle / last day / 30-day cap alert)

### Pause flow

1. From Cowork or Code app: `/pause-routines`. **Must invoke from a trusted local surface (Cowork on Windows or local Claude Code CLI). claude.ai/code cloud sessions cannot invoke pause/resume — plugin not loaded there per the Plugin loading by surface section.**
2. Skill checks idempotency (existing `vacation.md`?), cross-surface race (`git fetch && git diff`)
3. Skill prompts for end_date (optional), reason, suppress list (default = 3 study-facing routines)
4. Confirms with user, then writes `state/vacation.md`, sets `mode=paused`, writes paused-banner `schedule.md`
5. Commits + pushes to `claude/pause-routines-<date>`
6. Polls `gh run list` (Cowork) or `git ls-remote` (cloud) for confirmation
7. Reports back to user: "Paused — merged into main at <SHA>" or "Pause pushed; watch Slack for merge"

### Resume flow

1. From Cowork or Code app: `/resume-routines`
2. Skill verifies `mode==paused` AND `vacation.md` exists (otherwise errors)
3. Skill prompts: "Currently at bootcamp Day <N>. Resume here? (y/n)" — Q10 user-maintained
4. Skill archives current `last_session_summary.md` to `archive/sessions/<start>-pre-resume.md`
5. Rewrites `last_session_summary.md` with `vacation_gap_days: <N>` notice
6. Appends entry to `archive/vacations.md` (append-only history)
7. Updates `current_day.md`: `bootcamp.current_day` per Step 3, `mode` deduced from `loop_week.active`
8. `git rm state/vacation.md`
9. Commits + pushes to `claude/resume-routines-<date>`
10. Polls + reports verbose Q8 format:
    ```
    ✅ Resumed at <HH:MM> IST
    ─────────────────
    📍 bootcamp Day <N>
    🎯 loop_week: active Day X | paused | completed
    📅 First task: today's morning briefing fires at 09:00 IST
    🛬 Vacation duration: <N> days
    ```

### 30-day cap

`vacation.md` start_date + 30 days hard limit. After Day 30, daily-wrap posts persistent 🚨 alert every day until cleared. User clears by running `/resume-routines` (or manually deleting `vacation.md` and setting `mode` back).

### Default suppress_routines

```
[study-morning-briefing, study-spaced-rep-reminder, study-github-commit-reminder]
```

These three are paused-skipped during vacation. Other 5 routines (curriculum-sync, weekly-review, monday-distillation, drift-audit, branch-cleanup) keep running, with vacation-aware annotation downstream (e.g., monday-distillation marks logs as `vacation_gap` per CRIT-07).

---

## 11. Operating cadence

### Daily

- Routines fire automatically. No user action required.
- Open a study session in Cowork (recommended for full hooks-dormant tradeoff: CLAUDE.md @-imports work, drift detection doesn't) or claude.ai/code (full hooks active).
- End session with `/post-session` (mandatory if ≥1 drill) or `/day-wrap`.
- Watch `#study-routines` for the morning-briefing Slack ping at 09:00 IST. If it shows `[STALE-CURRICULUM]`, routine 01 didn't merge in time — check `gh run list` for the curriculum-sync workflow.

### Sundays

- 10:00 IST: weekly-review fires
- 10:30 IST: drift-audit fires (depends on weekly-review)
- 11:30 IST: branch-cleanup fires (no-op for first ~5 weeks)
- Read the weekly-review Slack message; identify highest-band weak spot for next week's drill focus.

### Mondays

- 09:00 IST: BOTH morning-briefing AND monday-distillation fire (same time, different concerns; both run)
- Distillation archives logs >7 days old into `archive/completed_days/`.

### Monthly

- Review unmerged `claude/*` branches: `git ls-remote --heads origin 'refs/heads/claude/*'`. Anything unmerged for >30 days needs a manual decision (keep or delete).
- Routine 08 only auto-deletes branches that ARE merged AND >30 days old.

### When you want to pause

- `/pause-routines` from Cowork or Code app. Set end_date if known, otherwise leave open-ended.
- Slack will post 🛫 within ~3 min.
- Routines #2/#3/#4 will skip silently from next fire onward.
- Daily-wrap goes minimal heartbeat for Days 2–30, persistent alert past Day 30.

### When you return

- `/resume-routines` from Cowork or Code app. Confirm or change current bootcamp day at the prompt.
- Slack will post ✅ Resumed within ~3 min.
- All routines back to normal from next fire.

---

## 12. The 5 Locks (teaching method)

Per `instructions/teaching-method.md`. Asta enforces these on every substantive teaching response.

1. **Slow ladder by default** — One concept per layer. Pulse-check between layers ("Tracking?" / "Click?" / "With me?"). Never three subconcepts in one paragraph. Confusion → re-angle, not repeat.
2. **Inline visualization** — ASCII / number-line / side-by-side-table visuals are DEFAULT for any new mechanic, placed INLINE with each piece of explanation. Never batched at the end.
3. **Teach before first drill of any new sub-stage** — Even when the underlying pattern feels familiar.
4. **Drill-to-drill deltas explicit** — Show the side-by-side diff between drill N and N+1.
5. **One analogy per concept, mechanism-matched** — Stacked analogies for related concepts are banned.

The Stop hook detects violations and logs to `state/drift_log.md` (failure numbers #3 stacked analogies, #6 batched visuals, #7 missing pulse-check, etc.).

---

## 13. RTI (room-to-improve) system

### 6 pattern families (per `instructions/rti-method.md`)

| Code | Name | One-line |
|---|---|---|
| **A** | Assembly Collapse | Can do parts, breaks wiring them together |
| **B** | Freeze | Shuts down before writing a line |
| **C** | Misread | Didn't read problem / params / correction |
| **D** | Shape | Right logic, wrong return type/structure |
| **E** | Scope | Code at wrong nesting level |
| **F** | Mechanical | Syntax/variable/operator slips |

Subtypes: A1 multi-step loop body, A2 grouping, B1 freeze, B2 bail-to-AI, D1 wrong container, F3 operator confusion, etc.

### 4 difficulty bands

| Band | What | Time |
|---|---|---|
| 1 | Warm-up — single-step loop, one operation | 5–10 min |
| 2 | Structure — one pattern, 2-step loop body | 20–30 min |
| 3 | Integration — two patterns combined | 20–30 min |
| 4 | Implementation — 3+ patterns, multi-function | 30–45 min |

### Non-negotiable rules

1. **Same bug twice = STOP.** Name it. Tag the family. Tomorrow's drill targets exactly that.
2. **AI-completed != completed.** Tag `[AI]`. Doesn't count toward mastery.
3. **Block 2 success does NOT predict Block 3 success.** Track independence at Block 3+.

### Path A v3 nuance

- RTI bands do NOT auto-decay during pause (informational annotation only per Q9 Option-C).
- Drift logged during paused sessions is excluded from drift-audit's window (Stop hook pause-skip).

---

## 14. Curriculum scope (Rule 1)

Per `instructions/scope-purity.md`. **Severity: absolute. Fail closed.**

> If a concept hasn't been covered in completed bootcamp days, it doesn't exist in this session.

- **Allowed:** concepts from completed days per `progress_state.xml.<completed_through_day>` + `<scope_additions>` per phase.
- **Forbidden:** using out-of-scope concepts in any exercise prompt, assertion, solution hint, or "just use library X" advice.
- **Read-only allowed:** a pre-registered concept may be SHOWN as a future preview but not used.
- **Exception:** ONE approved out-of-scope tool per mini-project IF specified in the trigger prompt or curriculum spec, with explicit scope note.

**Scope test before any drill, code block, or hint:** "Could Sudhan write this using ONLY completed days + today's concepts?" If no → remove that part. Don't ask. **Fail closed.**

**Bootstrap state:** until routine 01 has run at least once, fall back to `state/current_day.md.bootcamp.completed_through_day`. Flag the missing-XML state with `[BOOTSTRAP — instructions/curriculum/progress_state.xml not yet synced]`.

---

## 15. Loop Boot Camp curriculum

7-day intensive Sudhan runs alongside the daily bootcamp to lock loop fluency before recursion (bootcamp Day 16+). Files at `instructions/loop_curriculum/loop_week_day_XX.md` (Days 1–7).

| File | Day | Topic |
|---|---|---|
| `loop_week_day_01.md` | 1 | Lists, Tuples & Nested Loop Foundations |
| `loop_week_day_02.md` | 2 | Dicts, Sets & Pattern Stacking |
| `loop_week_day_03.md` | 3 | Strings & Variable-Width Shapes |
| `loop_week_day_04.md` | 4 | Comprehensions, zip, Range Mastery |
| `loop_week_day_05.md` | 5 | Functions DEEP + While Family |
| `loop_week_day_06.md` | 6 | Mini-Problems Day (Final Boss) |
| `loop_week_day_07.md` | 7 | Project, Retrospective & Bridge |

**Authoring discipline:** user-authored, NOT auto-synced (unlike `instructions/curriculum/*.xml`). Manual PRs only. Cross-day references ("Day 2 Block B.2 Pattern 1") must remain accurate.

Loop Week → bootcamp transition: after Loop Week Day 7's mini-boss is cold-clean, `/day-wrap` auto-transitions `current_day.md.mode` from `loop_week` to `bootcamp`.

---

## 16. Common troubleshooting

### `[STALE-CURRICULUM]` in morning-briefing Slack

Routine 01 didn't merge to `main` before routine 02 fired.
- Check: `gh run list --workflow=auto-merge-and-notify --limit=5`
- Manual fix: merge today's `claude/curriculum-sync-<date>` branch by hand, then re-trigger morning-briefing.
- Root cause: usually transient (Actions queue delay). Persistent → check Claude GitHub App access on `python_bootcamp_claude_code`.

### Slack post fails with HTTP 404

Webhook URL has been revoked (Slack auto-detects leaked secrets). Re-create webhook in Slack admin, update GitHub secret `SLACK_WEBHOOK_URL`.

### Validator fails post-merge → revert

Look at the workflow's "Post-merge validation" step output for which validator failed and what error. Common: `vacation.md` schema mismatch, `current_day.md` writer not in allowlist.
- Fix: edit the file on the original `claude/<routine>-<date>` branch, push again. Workflow re-fires on push.

### `/pause-routines` on Cowork: skill exits with "Pause already in progress"

The cross-surface race check fired. Either:
- A previous `/pause-routines` invocation is still pending merge → wait 3 min, then re-invoke.
- An old `claude/pause-routines-<date>` branch wasn't cleaned up → manually merge or delete.

### `/resume-routines` shows "State inconsistency"

`mode=paused` but `vacation.md` is missing (or vice versa). The cross-file consistency validator (`validate-vacation-consistency.js`) should have caught this on push, so the situation usually means manual edits.
- Fix: either re-create `vacation.md` (if pause was intended) or set `mode` back to `bootcamp` / `loop_week` (if not paused).

### Routine prompts in /schedule UI drifting from local files

Run `bash scripts/check-routine-skew.sh`. All 8 routines including routine 08 are reliably hashed post-2026-05-07 fix (PR #6 — script now uses `## Success criteria` as sentinel and takes first+last ` ``` ` as outer fences, correctly preserving inner heredoc fences as content). For UI-paste verification:

```bash
# Copy prompt body BACK out of /schedule UI textbox into /tmp/ui-paste.txt, then:
diff ~/routine-prompts/0X-study-<name>.md /tmp/ui-paste.txt
# Empty diff = perfect paste. Any output = mismatch (smart quotes, CRLF, truncation).
```

### Routine prompt body files in `~/routine-prompts/` desync from `routines/0X-*.md`

If you edit a routine prompt in the granted folder + merge to main, the `~/routine-prompts/0X-study-*.md` files are now stale (still showing old prompt body). Regenerate:

```bash
cd ~/study-companion-real
git pull origin main          # ensure source files are current
bash ~/extract-routine-prompts.sh
```

The script walks all 8 `routines/0X-*.md` files, extracts the prompt body (between outer ` ``` ` fences under `## Routine prompt`, using `## Success criteria` as the section sentinel — same algorithm as `scripts/check-routine-skew.sh`), and writes to `~/routine-prompts/0X-study-<name>.md`. Idempotent.

### Cowork hooks not firing

Per [#40495](https://github.com/anthropics/claude-code/issues/40495) (OPEN). Hooks defined in user `~/.claude/settings.json` are silently dormant in Cowork sandbox. CLAUDE.md @-imports DO work (`.claude/` is bind-mounted). Workaround: rely on skill bodies (which DO fire on Cowork) for state-critical operations.

### Asta says /pause-routines doesn't exist

Two failure modes look similar but have opposite causes — diagnosis below.

**On Cowork desktop:** false negative caused by `disable-model-invocation: true` frontmatter on `pause-routines/SKILL.md` and `resume-routines/SKILL.md`. The skills ARE loaded and ARE on disk; they're hidden from the model's auto-routing registry by design (per Anthropic docs: *"Description not in context, full skill loads when you invoke"*). **Type `/pause-routines` directly** — the slash command works even though Asta's standard available-skills snapshot omits them. If Asta says they don't exist, push back; the second-turn introspection (after the model checks disk directly) will find them.

**On claude.ai/code cloud session:** TRUE negative. Plugin is genuinely not loaded — Anthropic loads cloud-session plugins from the cloned repo's `.claude/settings.json`, not from user-scope `~/.claude/plugins/`. The granted folder has no `.claude/settings.json` declaring the plugin, so all 14 study-companion plugin skills are absent (not just pause/resume). **Use Cowork instead** — pause/resume is by design a Cowork-primary surface per Path A v3 Q2.

**Diagnostic test** to disambiguate which case you're in (Cowork blind-spot vs cloud not-loaded):

> Ask Asta: *"List every study-companion skill you can see in your skill registry, with their on-disk path."*

| Asta's response | Diagnosis | Action |
|---|---|---|
| Lists 0 plugin skills | Case B: cloud session, plugin not loaded | Switch to Cowork |
| Lists exactly 12 (calibrate, companion, day-wrap, drill, lock-decision, lock-weak-spot, post-session, rti-preflight, self-review, teach, teach-from-win, trace) | Case A: Cowork blind-spot (normal). pause/resume are user-only invokable | Type `/pause-routines` directly; ignore the registry omission |
| Lists all 14 | Both fully loaded; original "doesn't exist" was a model-introspection error | Move on |

### Routine pushes silently lost

Per [#53497](https://github.com/anthropics/claude-code/issues/53497) (OPEN). Routine sandbox creates commit but session ends before `git push` completes — work is lost without warning. Mitigation: every routine prompt MUST include explicit `git push` step (already done for all 8 routines + both new pause/resume skills).

---

## 17. File-system layout reference

```
/home/sudhan/
├── study-companion-real/          # granted folder repo
│   ├── .github/
│   │   ├── workflows/auto-merge-and-notify.yml
│   │   └── scripts/
│   │       ├── run-validators.sh
│   │       ├── extract-canonical-body.sh
│   │       ├── post-to-slack.sh
│   │       └── build-daily-wrap.sh
│   ├── instructions/
│   │   ├── identity.md            # Asta personality
│   │   ├── teaching-method.md     # 5 Locks
│   │   ├── banned-phrases.md      # Stop hook regex
│   │   ├── trigger-phrases.md     # `:lock` `:companion` `:wrap`
│   │   ├── scope-purity.md        # Rule 1
│   │   ├── rti-method.md          # 6 families, 4 bands
│   │   ├── loop-strategy.md       # Loop Boot Camp 4-phase plan
│   │   ├── curriculum/            # synced from pipeline daily
│   │   │   └── progress_state.xml
│   │   └── loop_curriculum/       # user-authored loop week
│   │       └── loop_week_day_0[1-7].md
│   ├── routines/0[1-8]-*.md
│   ├── scripts/
│   │   ├── validate-imports.js
│   │   ├── validate-state-schemas.js
│   │   ├── validate-wins-schemas.js
│   │   ├── validate-vacation-consistency.js   # NEW Path A v3
│   │   ├── atomic-write.sh
│   │   └── check-routine-skew.sh
│   ├── state/
│   │   ├── SOURCE_OF_TRUTH.md
│   │   ├── current_day.md
│   │   ├── active_weak_spots.md
│   │   ├── drift_log.md           # append-only, claude.ai/code only
│   │   ├── last_session_summary.md
│   │   ├── schedule.md
│   │   ├── repos.md
│   │   └── (vacation.md           # only when paused)
│   │       missed_routines.md     # only after first paused-skip)
│   ├── archive/
│   │   ├── completed_days/        # distilled logs >7d old
│   │   └── (vacations.md          # vacation history append-log)
│   │   └── (sessions/             # pre-resume archives)
│   ├── room-to-improve/
│   │   └── state/current_state.md # RTI live state
│   ├── wins/<date>-<slug>.md
│   ├── drills/
│   ├── logs/<date>.md             # daily session logs
│   ├── docs/                      # build/design/handoff docs + Path A v3 archive
│   │   ├── 2026-05-06-windows-handoff.md
│   │   ├── design-plan-snapshot.md
│   │   ├── build-plan-snapshot.md
│   │   ├── path-a-v3-issues.md            # 84-issue audit (PR #8)
│   │   ├── path-a-v3-decisions.md         # Q1-Q10 locked decisions (PR #8)
│   │   └── path-a-v3-design-research.md   # 36-citation evidence doc (PR #8)
│   ├── CLAUDE.md                  # @-imports loaded into every session
│   ├── README.md
│   └── SECURITY.md
├── study-companion-plugin/        # plugin repo
│   ├── .claude-plugin/plugin.json
│   ├── hooks/
│   │   ├── _lib.js                # shared helpers (parseFrontmatter, readMode, ...)
│   │   ├── hooks.json
│   │   ├── session-start.js
│   │   ├── user-prompt-submit.js
│   │   └── stop.js
│   ├── skills/
│   │   ├── teach/SKILL.md
│   │   ├── teach-from-win/SKILL.md
│   │   ├── drill/SKILL.md
│   │   ├── trace/SKILL.md
│   │   ├── calibrate/SKILL.md
│   │   ├── self-review/SKILL.md
│   │   ├── lock-decision/SKILL.md
│   │   ├── lock-weak-spot/SKILL.md
│   │   ├── post-session/SKILL.md
│   │   ├── day-wrap/SKILL.md
│   │   ├── rti-preflight/SKILL.md
│   │   ├── companion/SKILL.md
│   │   ├── pause-routines/SKILL.md      # NEW Path A v3
│   │   └── resume-routines/SKILL.md     # NEW Path A v3
│   ├── agents/
│   │   ├── pattern-detector.md
│   │   └── researcher.md
│   ├── tests/
│   │   ├── run-all.js
│   │   ├── _lib.test.js
│   │   ├── session-start.test.js
│   │   ├── user-prompt-submit.test.js
│   │   ├── stop.test.js
│   │   ├── validate-skills.js
│   │   └── validate-agents.js
│   ├── README.md
│   └── SECURITY.md
├── routine-prompts/               # local reference, not in any repo
│   └── 0[1-8]-study-*.md          # extracted prompt bodies
└── extract-routine-prompts.sh     # local script — regenerates routine-prompts/ from routines/0X-*.md
```

---

## 18. Glossary

- **Asta** — the persona; raw, relentless, no-magic-needed energy from Black Clover.
- **CLAUDE.md @-imports** — depth-5 walk; loads instruction + state files into every Cowork session at startup. Project-root file re-injected after `/compact`.
- **Cowork** — Claude Desktop's agentic mode tab. Hooks dormant per #40495.
- **`disable-model-invocation: true`** — frontmatter flag set on `/pause-routines` and `/resume-routines` skills. Hides the skill from the model's auto-routing registry (model can't see it in its skill snapshot and can't auto-invoke it) but keeps it user-invokable via slash command (`/pause-routines`). Per Path A v3 Q2 design — these skills are user-only by intent (state-critical actions with side effects on `main` branch; the user, not the model, must initiate). Side effect: Asta's standard skill listing omits them, which can read as "skill missing" — see Section 16 troubleshooting "Asta says /pause-routines doesn't exist".
- **Drift** — patterns the Stop hook detects in assistant responses (filler phrases, stacked analogies, missing pulse-checks, etc.) and logs to `drift_log.md`.
- **Granted folder** — the study-companion repo, granted as a directory to Cowork sessions.
- **Hook** — JSON-stdin command-style handler in `study-companion-plugin/hooks/`. Three active: SessionStart, UserPromptSubmit, Stop.
- **mode** — Path A v3 field in `current_day.md`. Values: `bootcamp` (default), `loop_week`, `paused`.
- **Path A v3** — pause/resume + carry-forward feature shipped 2026-05-07.
- **RTI** — "room to improve". Pattern-failure tracking system (6 families, 4 bands).
- **Routine** — Anthropic web-scheduled-task that runs as a full Claude Code cloud session on a managed VM. 8 routines total.
- **SOURCE_OF_TRUTH.md** — registry mapping each fact to its writer file. Validators enforce.
- **Step 0 preamble** — Path A v3 universal pause-check inserted at top of every routine prompt's `## Steps` section.
- **suppress_routines** — list in `vacation.md` of routines that pause-skip via Step 0. Default: 3 study-facing routines.

---

## 19. Useful URLs

- **Granted folder repo:** https://github.com/Sudhan09/study-companion
- **Plugin repo:** https://github.com/Sudhan09/study-companion-plugin
- **Pipeline (curriculum) repo:** https://github.com/Sudhan09/python_bootcamp_claude_code
- **Routine UI:** https://claude.ai/code/routines
- **Claude GitHub App installations:** https://github.com/apps/claude/installations
- **Cowork hook dormancy issue:** https://github.com/anthropics/claude-code/issues/40495 (OPEN)
- **Routine push silent-loss issue:** https://github.com/anthropics/claude-code/issues/53497 (OPEN)
- **Anthropic routines docs:** https://code.claude.com/docs/en/routines
- **Anthropic claude-code-on-the-web docs:** https://code.claude.com/docs/en/claude-code-on-the-web

---

## 20. Useful commands

```bash
# All-in-one validators
cd ~/study-companion-real
bash .github/scripts/run-validators.sh

# Hash-check routine prompts (file-side)
bash scripts/check-routine-skew.sh

# Manual daily-wrap dispatch
gh workflow run auto-merge-and-notify --ref main -f mode=wrap

# Watch the latest workflow run
gh run watch $(gh run list --workflow=auto-merge-and-notify --limit=1 --json databaseId -q '.[0].databaseId')

# List unmerged claude/* branches (mostly relevant if auto-merge fails)
git ls-remote --heads origin 'refs/heads/claude/*'

# Sweep granted folder for any regression after a routine
git fetch && git log main --since=midnight --oneline

# Plugin tests
cd ~/study-companion-plugin
node tests/run-all.js

# Manual fire of a routine (also works from claude.ai/code/routines UI)
# (no canonical CLI command — use the UI)

# Pull latest on both repos
cd ~/study-companion-real && git pull
cd ~/study-companion-plugin && git pull
```

---

## 21. Known issues + verified-as-of (2026-05-07)

### Known issues

1. **Manual-fire branch naming — FIXED + VERIFIED 2026-05-07 (PR #7).** Each routine's prompt now begins with `git checkout -B claude/<routine>-$(TZ=Asia/Kolkata date +%F)` (Option B from prior triage). No-op for cron fires; fixup for manually-fired runs (which would otherwise start on a `claude/<random-slug>` working branch). End-to-end verified at 19:32 IST: manual fire of `study-curriculum-sync` produced canonically-named branch `claude/curriculum-sync-2026-05-07`, auto-merged into main as `936d259`, Slack ping arrived in `#study-routines` (3-min wall clock). All 8 prompt hashes changed — see updated table below.

2. **Three open Anthropic issues affecting this system:**
   - [#40495](https://github.com/anthropics/claude-code/issues/40495) (OPEN) — Cowork hooks dormant. CLAUDE.md @-imports DO work because `.claude/` is bind-mounted, but hooks defined in user `~/.claude/settings.json` are silently ignored. Project-scope `.claude/settings.json` hook firing in Cowork is undocumented. Mitigation: state-critical logic lives in skill bodies (which DO fire on Cowork), not hooks.
   - [#53497](https://github.com/anthropics/claude-code/issues/53497) (OPEN) — routine push silent loss. Anthropic's runtime tears down the sandbox before `git push` completes. Mitigation: every routine prompt explicitly includes `git push origin claude/<branch>-<date>` as its final step.

3. **`progress_state.xml.completed_through_day` ≠ actual progress.** Pipeline tracks intended curriculum, not what Sudhan has actually studied. Sudhan generates 10+ days of curriculum content in batches without studying them all. Per Path A v3 Q10: `bootcamp.current_day` is user-maintained — never auto-computed from the pipeline. `/resume-routines` prompts user to confirm or change.

### Verified end-to-end as of 2026-05-07

| Path | Result | Evidence |
|---|---|---|
| Job A — happy path | ✅ | Smoke test push to `claude/curriculum-sync-2099-01-02` → workflow ran 19s → all 11 steps `success` → merge `4b56e5e` on main → Slack POST 200 (403 bytes) |
| Job A — validator-failure (rogue writer) | ✅ | Smoke test push with `updated_by: rogue-writer-not-in-allowlist` → `validate-state-schemas.js: FAILED` → merge/post-merge/push `skipped` → branch unmerged → Slack POST 200 (1581 bytes — failure template) |
| Job A — pause-routines special case | ✅ | Smoke test push to `claude/pause-routines-2099-01-04` with bare-date in `vacation.md` → 3 validators failed (RFC 3339, cross-file consistency, future-date sanity) → 🚨 PAUSE NOT APPLIED template selected → Slack POST 200 (1966 bytes) |
| Job B — daily-wrap manual dispatch | ✅ | `gh workflow run auto-merge-and-notify -f mode=wrap` → Slack message arrived |
| Plugin tests | ✅ | `node tests/run-all.js` → 53 assertions pass + 14 skills + 2 agents validated |
| Granted-folder validators | ✅ | `bash .github/scripts/run-validators.sh` → all 4 validators OK on main |
| Routine prompts re-pasted | ✅ | All 8 prompts pasted into `claude.ai/code/routines` UI on 2026-05-07 |
| Auto-merge workflow PR | ✅ | PR #2 merged 2026-05-07 09:10 UTC |
| Path A v3 schema PR | ✅ | PR #5 merged 2026-05-07 12:03 UTC |
| Path A v3 plugin PR | ✅ | PR #1 (plugin repo) merged 2026-05-07 12:03 UTC |
| Skew script fix | ✅ | PR #6 merged 2026-05-07 |
| Option B fix (force canonical working-branch) | ✅ | PR #7 merged 2026-05-07 |
| **Manual fire → canonical branch → auto-merge → Slack (end-to-end)** | ✅ | Manual fire of `study-curriculum-sync` at 19:29 IST produced `claude/curriculum-sync-2026-05-07` (NOT random slug), auto-merged at `936d259`, Slack arrived 19:32 IST with the curriculum-sync success template |
| Path A v3 history archive (PR #8) | ✅ | path-a-v3-{issues,decisions,design-research}.md committed to main `c60111f` |
| End-of-session repo state | ✅ | Granted on main `c60111f`, plugin on main `1387e37`, both working trees clean. Granted has 1 preserved local branch `feat/loop-curriculum` (unmerged — `fdff05b feat(curriculum): add Loop Boot Camp Day 1-7 curriculum` queued for a future PR). 5 merged-to-main stale local branches deleted at session end (`feat/auto-merge-workflow`, `feat/path-a-v3-core`, `feat/skew-script-nested-fence-fix`, `feat/manual-fire-branch-naming`, `docs/path-a-v3-archive`). Plugin has no stale local branches. |

### Runtime environment

- **Linux Node** at session-end: `v22.22.2`. All plugin tests (`node tests/run-all.js`) ran cleanly here.
- **Windows Node:** any **Node 18 LTS or newer** is fine. Plugin uses only `fs` and `path` Node built-ins (no third-party dependencies, no `package.json`, no `.nvmrc`). Verify with `node --version` from `C:\Users\sudha\study-companion-plugin\`.
- **No version pin:** the plugin is deliberately lightweight; no version-specific APIs are used.

### Extraction-logic parity (skew script ↔ extraction script)

`scripts/check-routine-skew.sh` (in repo) and `~/extract-routine-prompts.sh` (local-only) use the **same algorithm**:
1. `## Routine prompt` as section start
2. `## Success criteria` as section end sentinel
3. First and last ` ``` ` between those as outer fences
4. Body = lines strictly between the fences (inner ` ``` ` lines are content)

So the body extracted by both is byte-identical, modulo **one trailing newline** (sed adds one to file output; `printf '%s' | sha256sum` in the skew script doesn't). What this means:

| Verification method | Reliability |
|---|---|
| `diff ~/routine-prompts/0X-*.md /tmp/ui-paste.txt` (UI paste correctness) | **Reliable** — both sides have consistent trailing-newline handling |
| `bash scripts/check-routine-skew.sh \| grep <name>` against published hash table | **Reliable** — hash is computed deterministically from body content |
| Cross-comparing `sha256sum ~/routine-prompts/0X-*.md` with skew-script output | **Off by one trailing newline.** Do not use; prefer diff or skew script directly. |

### Pending verification

- [ ] First natural cron fire at 03:00 UTC 2026-05-08 (08:30 IST) — `study-curriculum-sync` should push `claude/curriculum-sync-2026-05-08`, auto-merge should trigger, Slack should post 🗡️ ✅. Cron path is no-op for the new `git checkout -B` first action (working branch already canonical), so behavior should be identical to today's manual-fire-via-Option-B test.
- [ ] Same for `study-morning-briefing` at 03:30 UTC (09:00 IST)
- [ ] Daily-wrap automatic cron fire at 15:30 UTC (21:00 IST) — Job B from natural schedule (vs manual dispatch)
- [ ] End-to-end pause/resume via `/pause-routines` + `/resume-routines` skills — defer until you actually want to pause for vacation/skip day

### Routine prompt hashes (post 2026-05-07 PR #7 + skew fix)

All 8 hashes changed in PR #7 (added `git checkout -B` first action). Re-paste all 8 prompts into `claude.ai/code/routines` UI to match.

| File | Current hash | Pre-PR-#7 hash |
|---|---|---|
| `01-curriculum-sync.md` | `4dc1e29ab81d1225` | `6ae275712249686e` |
| `02-morning-briefing.md` | `975f7b2cd338bca2` | `5c0fc6ada58dc637` |
| `03-spaced-rep-reminder.md` | `a3b396e73ac3153b` | `e6bbbd02179156b6` |
| `04-github-commit-reminder.md` | `a44d41efd22ae195` | `5966ae1b8a41e521` |
| `05-weekly-review.md` | `f17ab164a5040f71` | `9b08f93a08a3a035` |
| `06-monday-distillation.md` | `18aa8ab1525366f4` | `d764505adb9db5a9` |
| `07-drift-audit.md` | `66c1332fc8f65b01` | `f5332fde3feba959` |
| `08-branch-cleanup.md` | `7757ef31ad8c440c` | `ae9e032d0ea4864f` (was `c8a86440dc91c85f` pre-skew-fix) |

Verify any routine: `bash scripts/check-routine-skew.sh | grep <name>` from the granted folder. Should match the table.

---

*End of manual. Updated 2026-05-07.*
