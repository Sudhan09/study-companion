# Build Plan Snapshot — 2026-05-06

> Repo-local snapshot of the build plan (TDD task list). Authoritative copy is at the user's private path; this file exists so Linux Cowork maintainers can reference it without leaving the repo.
>
> **Sync action required:** paste the build plan content below this line. Until that's done, references like "per build plan Phase 12.2" cite content that's not in the repo.

## Phases (typical structure)
- Phase 1 — Repository setup
- Phase 2 — Schema + state seeds
- Phase 3 — Instructions ports
- Phase 4 — Routines authoring
- Phase 5 — Plugin manifest + skills
- Phase 6 — Hook handlers
- Phase 7 — Validators + tests
- Phase 8 — Drills templates
- Phase 9 — RTI seed
- Phase 10 — Wins seed
- Phase 11 — Audit + freshness
- Phase 12 — Cowork /schedule UI submission
- Phase 13 — First-session validation per design §I
- Phase 14 — Closeout


---

# Cowork Study Companion — Build Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Cowork study companion per the locked design at `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion.md` — a granted folder + Cowork plugin + 7 cloud routines that solve Sudhan's 40-50-min priming-time problem.

**Architecture:** Two artifact trees on Windows:
- `C:\Users\sudha\study-companion\` — the granted folder + Git repo (instructions, state, logs, wins, drills, RTI tracking, curriculum sync target)
- `C:\Users\sudha\.claude\plugins\study-companion\` — the Cowork plugin (manifest, hooks, skills, sub-agents). Same plugin file installs to both Cowork (skills active, hooks dormant per #40495) and claude.ai/code (full hooks).

**Tech Stack:** Node.js (hook handlers), Markdown + YAML frontmatter (skills, sub-agents, state), Git (sync between Cowork and claude.ai/code), GitHub private repo (cloud-routine target). No Discord. No WHOOP. No MCP servers beyond Cowork built-ins.

**Design citation:** every file created in this build maps to a section of the design plan. Where the design specifies content (skill bodies, schema details, hook responsibilities), the build task references that section rather than reproducing it.

---

## Pre-build checklist (user actions BEFORE any task starts)

- [ ] **U1 — Create private GitHub repo** named `study-companion` (or chosen name). Note the SSH/HTTPS push URL. The agent cannot create this repo for you.
- [ ] **U2 — Confirm `git`, `node`, and `gh` CLI are installed:** run `git --version`, `node --version`, `gh --version` in PowerShell. Install missing tools before proceeding.
- [ ] **U3 — Confirm Cowork is logged in on Max 20x.** Open Claude Desktop → Cowork tab → verify subscription state at claude.ai/settings/usage.
- [ ] **U4 — Decide auto-merge policy for routine branches.** Recommended for first 2 weeks: NO auto-merge. Routines push to `claude/<routine>-<date>`; you merge manually. After 2 weeks of clean unattended runs, consider per-routine auto-merge.

When U1–U4 are complete, agent proceeds with Phase 1.

---

## Phase 1 — Repo + Git setup

**Files:**
- Create: `C:\Users\sudha\study-companion\.git\` (via `git init`)
- Create: `C:\Users\sudha\study-companion\.gitignore`
- Create: `C:\Users\sudha\study-companion\README.md` (1-line, points to design plan)

### Task 1.1: Create study-companion directory

- [ ] **Step 1: Verify parent does not already exist as a populated dir**

Run: `ls "C:\Users\sudha\study-companion"` (PowerShell)
Expected: directory does not exist OR is empty. If populated, STOP and ask user.

- [ ] **Step 2: Create the directory**

Run: `mkdir "C:\Users\sudha\study-companion"`

### Task 1.2: Initialize Git repo

- [ ] **Step 1: `git init`**

Run: `git -C "C:\Users\sudha\study-companion" init -b main`
Expected: "Initialized empty Git repository in C:/Users/sudha/study-companion/.git/"

### Task 1.3: Create .gitignore

- [ ] **Step 1: Write .gitignore per design §A**

Write `C:\Users\sudha\study-companion\.gitignore`:

```
state/.locks/
state/.compact-state-pending.json
*.swp
.DS_Store
Thumbs.db
```

Note: per design §A, `whoop/` is dropped (locked decision d), so no whoop entries.

### Task 1.4: Create README.md placeholder

- [ ] **Step 1: Write README.md**

Write `C:\Users\sudha\study-companion\README.md`:

```markdown
# study-companion

Sudhan's bootcamp study companion. Granted folder for Cowork (primary surface) and claude.ai/code (RTI surface).

**Design plan:** `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion.md`
**Build plan:** `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion-build.md`

Do not fork curriculum XMLs into this repo. They live in the bootcamp pipeline at
`C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\` and sync into
`instructions/curriculum/` via the `study-curriculum-sync` cloud routine.
```

### Task 1.5: USER-ACTION — provide GitHub remote URL

- [ ] **Pause for user.** Ask user for the private repo push URL (HTTPS or SSH). Example: `git@github.com:Sudhan09/study-companion.git`.

### Task 1.6: Add remote

- [ ] **Step 1: Configure remote** (after user provides URL)

Run: `git -C "C:\Users\sudha\study-companion" remote add origin <USER-PROVIDED-URL>`

- [ ] **Step 2: Verify** 

Run: `git -C "C:\Users\sudha\study-companion" remote -v`
Expected: shows `origin` with fetch + push URLs.

### Task 1.7: USER-ACTION — install Claude GitHub App or run /web-setup

- [ ] **Pause for user.** Per design §E pre-flight checklist step 5: install [github.com/apps/claude](https://github.com/apps/claude) on the new repo (recommended) OR run `/web-setup` in Claude Code CLI to sync `gh` OAuth. Do not skip — routines will fail to clone otherwise. User confirms when complete.

---

## Phase 2 — Folder skeleton

**Files:**
- Create: 11 subdirectories per design §A
- Create: 11 `.gitkeep` files (placeholders for empty dirs)

### Task 2.1: Create all subdirectories

- [ ] **Step 1: Create them**

Run (PowerShell):
```powershell
$base = "C:\Users\sudha\study-companion"
$dirs = @(
  "instructions",
  "instructions\curriculum",
  "state",
  "logs",
  "logs\sessions",
  "wins",
  "drills",
  "drills\templates",
  "drills\solutions",
  "room-to-improve",
  "room-to-improve\state",
  "room-to-improve\sessions",
  "archive",
  "archive\completed_days"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path "$base\$d" | Out-Null }
```

- [ ] **Step 2: Verify** 

Run: `ls "C:\Users\sudha\study-companion" -Recurse -Directory | Select-Object FullName`
Expected: all 14 dirs listed.

### Task 2.2: Create .gitkeep for empty dirs

- [ ] **Step 1: Add .gitkeep where dir starts empty**

Empty dirs that need .gitkeep: `logs/sessions/`, `drills/solutions/`, `room-to-improve/sessions/`, `archive/completed_days/`, `instructions/curriculum/` (filled by routine on first run, but Git needs it tracked now).

For each: `New-Item -ItemType File -Path "<base>\<dir>\.gitkeep" | Out-Null`

---

## Phase 3 — Port content from openclaw_setup → instructions/

**Files:**
- Create: `instructions/teaching-method.md` (verbatim port)
- Create: `instructions/rti-method.md` (verbatim port)
- Create: `instructions/identity.md` (adapted from IDENTITY+SOUL+USER, Discord stripped)
- Create: `instructions/banned-phrases.md` (new, per design §C)
- Create: `instructions/trigger-phrases.md` (new, per design §G)
- Create: `instructions/scope-purity.md` (port spirit of rules.xml Rule 1)
- Create: `instructions/loop-strategy.md` (verbatim port of loop-bootcamp-strategy)
- Create: `drills/templates/pattern_to_drill_map.md` (verbatim port)
- Create: `drills/templates/decision_tree.md` (verbatim port)

### Task 3.1: Port teaching-method.md (verbatim)

- [ ] **Step 1: Copy** 

Run: `Copy-Item "C:\Users\sudha\openclaw_setup\bootcamp\loop-week\teaching_method_locked.md" "C:\Users\sudha\study-companion\instructions\teaching-method.md"`

- [ ] **Step 2: Add provenance comment at top** (per build constraint "cite the plan section for every file you create")

Prepend to file:
```markdown
<!-- Per design §G port plan: verbatim port of openclaw_setup/bootcamp/loop-week/teaching_method_locked.md -->
<!-- DO NOT EDIT. The 5 locked rules are battle-tested. Tighten via teaching-method-tightenings.md instead. -->
```

- [ ] **Step 3: Verify 5 locked rules present** 

Run grep: `Select-String -Path "...\instructions\teaching-method.md" -Pattern "Slow Ladder","Inline Visualization","Teach Before","Drill-to-Drill Deltas","One Analogy Per Concept"`
Expected: 5 matches.

### Task 3.2: Port rti-method.md (verbatim)

- [ ] **Step 1: Copy** 

Run: `Copy-Item "C:\Users\sudha\openclaw_setup\room-to-improve\room-to-improve-architecture\ROOM_TO_IMPROVE_MVP.md" "C:\Users\sudha\study-companion\instructions\rti-method.md"`

- [ ] **Step 2: Add provenance comment**

- [ ] **Step 3: Verify 6 families + 4 bands + 3 non-negotiables** 

Run grep for "Family A","Family B","Family C","Family D","Family E","Family F","Band 1","Band 2","Band 3","Band 4","Same bug twice","AI-completed","Block 2 success"
Expected: ≥13 matches.

### Task 3.3: Port pattern_to_drill_map and decision_tree (verbatim)

- [ ] **Step 1: Copy both files**

```
Copy-Item "...\openclaw_setup\room-to-improve\room-to-improve-architecture\pattern_to_drill_map.md" "...\study-companion\drills\templates\pattern_to_drill_map.md"
Copy-Item "...\openclaw_setup\room-to-improve\room-to-improve-architecture\drill_decision_tree.md" "...\study-companion\drills\templates\decision_tree.md"
```

- [ ] **Step 2: Add provenance comments to both**

### Task 3.4: Port loop-strategy.md (verbatim)

- [ ] **Step 1: Copy + provenance**

Source: `openclaw_setup/bootcamp/loop-bootcamp-strategy.txt` → `instructions/loop-strategy.md` (rename .txt → .md)

### Task 3.5: Author identity.md (adapted from IDENTITY + SOUL + USER, Discord stripped)

- [ ] **Step 1: Read source files**

Read: `openclaw_setup/config/IDENTITY.md`, `openclaw_setup/config/SOUL.md`, `openclaw_setup/config/USER.md`

- [ ] **Step 2: Combine into instructions/identity.md per design §G adapt rules**

Structure:
```markdown
<!-- Per design §G adapt: combines IDENTITY + SOUL + USER. Discord-specific rules stripped. -->

# Identity

**Name:** Asta
**Emoji:** 🗡️
**Vibe:** Raw, relentless, no magic. Outwork everyone. NEVER GIVES UP.

## Communication style (from SOUL.md)

- No filler openers ("Great question!", "Sure!", "Certainly!" — banned)
- No "as an AI" disclaimers
- Match energy to message length
- Opinions encouraged; sarcasm allowed when fitting
- If unsure, say so. No guessing.
- Talk like a real person, not a report generator

## Self-architecture rule

When asked about own services, cron, hooks, or model config, ALWAYS read `state/SOURCE_OF_TRUTH.md` and `instructions/curriculum/progress_state.xml` first. Never guess about own infrastructure.

## About the user (Sudhan)

[Port USER.md content. STRIP: outdated bootcamp-day numbers (USER.md says Day 5; actual state per progress_state.xml is Phase 2 / Day 21+). Strip Discord references.]

[KEEP: name, location (Chennai, IST), age (25), Alienware/Ubuntu weekends + Windows daily, transitioning trading→DS/DA, FAANG target Jul 2026, 22-week bootcamp from Feb 24 2026, anime (Zoro, Itachi, Luffy, Asta), F1 (Verstappen), football (Messi, Barcelona), height 172cm, target weight 67kg, PPL split, vibe (Gen Z, direct, no fluff, zero tolerance for filler).]

[KEEP: bootcamp current state — but reference `state/current_day.md` and `instructions/curriculum/progress_state.xml` as source of truth, do not hardcode day numbers.]
```

- [ ] **Step 3: Validate file size <200 lines** 

Run: `(Get-Content "...\identity.md" | Measure-Object -Line).Lines`
Expected: <200.

### Task 3.6: Write banned-phrases.md (new)

- [ ] **Step 1: Author**

Write `instructions/banned-phrases.md`:

```markdown
<!-- Per design §C context-loading and §D failure #10. Detected by Stop hook in claude.ai/code. -->

# Banned phrases

Never use these. Detection regex in Stop hook:

- "Hope this helps"
- "Would you like me to..."
- "Let me know if..."
- "Feel free to..."
- "Happy to help" / "Happy to assist"
- "Great question!"
- "Sure!"
- "Certainly!"
- "I'd be happy to..."

Why: filler phrases signal "performance mode" instead of "available mode" (per design §D failure #8). Sudhan is a peer, not a customer.

Replacement: end the response when the response ends. No closing pleasantry.
```

### Task 3.7: Write trigger-phrases.md (new)

- [ ] **Step 1: Author**

Write `instructions/trigger-phrases.md`:

```markdown
<!-- Per design §G adapt: ports OpenClaw's trigger phrase vocabulary. Detected by UserPromptSubmit hook in claude.ai/code. -->

# Trigger phrases

User says these → corresponding response or skill invocation.

## Lock-in triggers
- "lock it in" / "mark it" / "remember this" / "note this"  
  → invoke `/lock-decision` skill, write to `wins/{date}-{slug}.md`, respond "Locked ✅"

## Confusion signals
- "I don't get it" / "I don't understand" / "I'm lost" / "I'm confused" / "still confused" / "huh?" / "wait what" / "you lost me" / 🤔
  → NEVER repeat slower or louder. MUST re-angle: switch domain analogy, run ASCII trace, or pulse-check what specifically is unclear. State which angle in first sentence.

## Companion mode
- "be a companion" / "chat with me" / "banter mode"
  → invoke `/companion` skill

## Day wrap
- "day wrap" / "wrap up" / "done for today"
  → invoke `/day-wrap` skill
```

### Task 3.8: Write scope-purity.md (port spirit of rules.xml Rule 1)

- [ ] **Step 1: Read pipeline rules.xml**

Source: `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\rules.xml` (already read in design phase). Extract Rule 1 statement, scope_test, allowed_in, prohibited_in.

- [ ] **Step 2: Write scope-purity.md**

Write per design §G "rules.xml scope-purity rule" subsection. Schema:

```markdown
<!-- Per design §G adapt: spirit of rules.xml v2.5 Rule 1 (scope_purity). Authoritative XMLs synced daily by study-curriculum-sync routine into instructions/curriculum/. Read those files for the runtime registry. -->

# Scope Purity (Rule 1, ported)

If a concept hasn't been covered in completed bootcamp days, it doesn't exist in this session.

[Full content per design §G "rules.xml scope-purity rule" subsection. Includes: Allowed (taught concepts), Read-only allowed (preview), Forbidden (out-of-scope use), Scope test ("Could Sudhan write this using ONLY completed days + today's concepts?"), Fail closed.]

## Runtime scope source

- Live registry: `instructions/curriculum/progress_state.xml` `<completed_through_day>` + active curriculum chunk per `<active_files>` + `instructions/curriculum/deviation_log.xml` `<scope_additions>`.
- Synced daily by `study-curriculum-sync` routine at 08:30 IST.
- Pipeline repo at `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\` is the authoritative source.

## On scope violation

Stop. Tell user: "That uses [concept], which is Phase [P] / Day [D] material — outside today's scope per progress_state. Proceed with [in-scope alternative] or skip the example."
```

### Task 3.9: Write top-level CLAUDE.md (~150 lines, @-imports)

- [ ] **Step 1: Author CLAUDE.md per design §C and §B install path**

Write `C:\Users\sudha\study-companion\CLAUDE.md`:

```markdown
<!-- Per design §C context-loading order. Cowork natively reads CLAUDE.md from granted folder per code.claude.com/docs/en/memory. -->
<!-- Walk-up loading from cwd, depth-5 @-imports, concatenated. -->
<!-- Both Cowork (primary surface, hooks dormant per #40495) and claude.ai/code (RTI surface, full hooks) load this file. -->

# Asta — Sudhan's bootcamp study companion

@instructions/identity.md
@instructions/teaching-method.md
@instructions/banned-phrases.md
@instructions/trigger-phrases.md
@instructions/scope-purity.md
@instructions/rti-method.md
@instructions/loop-strategy.md

## Live state

@state/SOURCE_OF_TRUTH.md
@state/current_day.md
@state/active_weak_spots.md
@state/last_session_summary.md
@state/schedule.md

## Recent drift to watch for (last 7 days)

@state/drift_log.md

## Curriculum scope (synced daily from pipeline repo)

[Note: instructions/curriculum/*.xml are read directly when scope questions arise. Not @-imported because XML in markdown context isn't useful — Claude reads them via file tools when needed.]

## Operating reminders

- **Time-to-correct-mode is the primary metric.** First substantive response in a teaching session must demonstrate: one mechanism-matched analogy + inline visualization + identity-locked voice + curriculum anchor `[Phase P • Day D • Block B]` + at least one pulse-check phrase for multi-layer responses.
- **Wins library is calibration data, not scripts.** When applying a past win to a new concept, invoke `/teach-from-win` — it forces precondition-first workflow. Never reuse a past artifact verbatim.
- **Stop fires only on claude.ai/code surface.** In Cowork sessions, `/self-review` and `/calibrate` are the only pre-output drift catches.
- **Surface switch discipline:** commit before switching between Cowork and claude.ai/code. Routines push to `claude/` branches; merge to main between sessions.
```

- [ ] **Step 2: Validate @-imports resolve** 

Write a small Node script to check each `@path` referenced in CLAUDE.md exists. Run.

```javascript
// scripts/validate-imports.js
const fs = require('fs');
const path = require('path');
const claudeMd = fs.readFileSync('CLAUDE.md', 'utf8');
const imports = [...claudeMd.matchAll(/^@(\S+)/gm)].map(m => m[1]);
let missing = imports.filter(p => !fs.existsSync(p));
if (missing.length) {
  console.error('MISSING IMPORTS:', missing);
  process.exit(1);
}
console.log(`OK: ${imports.length} imports resolve`);
```

Run: `cd C:\Users\sudha\study-companion && node scripts/validate-imports.js`
Expected: "OK: 12 imports resolve" (state files don't exist yet — Phase 9 will create them; this validation runs after Phase 9).

---

## Phase 4 — defer

CLAUDE.md authored in Phase 3.9. Validation run in Phase 9 after state files exist.

---

## Phase 5 — Plugin scaffold

**Files:**
- Create: `C:\Users\sudha\.claude\plugins\study-companion\.claude-plugin\plugin.json`
- Create: `C:\Users\sudha\.claude\plugins\study-companion\hooks\hooks.json`

### Task 5.1: Create plugin directory tree

- [ ] **Step 1: Verify ~/.claude/plugins/ exists**

Run: `ls "C:\Users\sudha\.claude\plugins"` — if not, `mkdir`.

- [ ] **Step 2: Create plugin tree**

```powershell
$plg = "C:\Users\sudha\.claude\plugins\study-companion"
foreach ($d in @(".claude-plugin","hooks","skills","agents","tests","tests\fixtures")) {
  New-Item -ItemType Directory -Force -Path "$plg\$d" | Out-Null
}
```

### Task 5.2: Write plugin.json

- [ ] **Step 1: Author per design §B**

Write `.claude-plugin/plugin.json`:
```json
{
  "name": "study-companion",
  "description": "Sudhan's bootcamp study companion. Enforces locked teaching method, tracks RTI pattern-failure state, logs drift across sessions. Pure desktop, no Discord, no WHOOP.",
  "version": "0.1.0",
  "license": "private",
  "homepage": "local",
  "repository": "local"
}
```

- [ ] **Step 2: Validate JSON parses**

Run: `node -e "JSON.parse(require('fs').readFileSync('C:/Users/sudha/.claude/plugins/study-companion/.claude-plugin/plugin.json'))"`
Expected: no error.

### Task 5.3: Write hooks.json

- [ ] **Step 1: Author per design §B**

Write `hooks/hooks.json` per design §B exactly. 5 hooks: SessionStart, UserPromptSubmit, Stop, PreCompact, PostCompact. Each handler: `node ${CLAUDE_PLUGIN_ROOT}/hooks/<name>.js`.

- [ ] **Step 2: Validate JSON parses**

---

## Phase 6 — Hook handlers (TDD)

**Files (5 handlers + 5 test files + shared fixtures):**
- Create: `hooks/session-start.js`
- Create: `hooks/user-prompt-submit.js`
- Create: `hooks/stop.js`
- Create: `hooks/pre-compact.js`
- Create: `hooks/post-compact.js`
- Create: `tests/session-start.test.js`
- Create: `tests/user-prompt-submit.test.js`
- Create: `tests/stop.test.js`
- Create: `tests/pre-compact.test.js`
- Create: `tests/post-compact.test.js`
- Create: `tests/fixtures/state/*.md` (fake state files for unit tests)
- Create: `tests/fixtures/events/*.json` (fake hook event payloads)

### Task 6.0: Create test fixtures

- [ ] **Step 1: Write fixture state files**

Per design §F schemas, create minimal valid state files in `tests/fixtures/state/`:
- `current_day.md` (frontmatter with bootcamp + loop_week dimensions, last_updated within 1h)
- `active_weak_spots.md` (3 entries: A1, B2, F3 per RTI seed)
- `drift_log.md` (5 sample append-only entries)
- `last_session_summary.md` (single overwritten file)
- `schedule.md` (today's plan placeholder)
- `SOURCE_OF_TRUTH.md` (the registry table per design §A)

- [ ] **Step 2: Write fake event payloads**

Per Claude Code hooks spec at code.claude.com/docs/en/hooks, each hook receives an event JSON. Create:
- `tests/fixtures/events/session-start.json` — minimal valid event
- `tests/fixtures/events/user-prompt-submit-confusion.json` — prompt with "I'm still confused"
- `tests/fixtures/events/user-prompt-submit-lockit.json` — prompt with "lock it in"
- `tests/fixtures/events/user-prompt-submit-neutral.json` — neutral prompt
- `tests/fixtures/events/stop-clean.json` — assistant response with no banned phrases
- `tests/fixtures/events/stop-fillerphrase.json` — assistant response containing "Hope this helps"
- `tests/fixtures/events/stop-stacked-analogies.json` — response with "imagine X" + "think of it as Y"
- `tests/fixtures/events/pre-compact.json`
- `tests/fixtures/events/post-compact.json`

### Task 6.1: SessionStart hook (TDD)

- [ ] **Step 1: Write the failing test**

Write `tests/session-start.test.js`:
```javascript
const { test, expect } = require('node:test') === undefined ? require('./mini-test') : require('node:test');
// ... test setup using fixtures/events/session-start.json + fixtures/state/*.md
// Spawn `node hooks/session-start.js` with fixture event on stdin
// Assert: stdout JSON includes additionalContext
// Assert: additionalContext concatenates state files in deterministic order per design §C
// Assert: warning prepended if any state file >24h old (test by timestamp manipulation)
```

Full test code: write per design §B "SessionStart" handler responsibility table. Test asserts:
- 12 state-and-instruction files concatenated in order from §C
- Freshness warning prepended for >24h-old fixture file
- Touch `state/.locks/session.lock` (test runs in tempdir to avoid polluting real state)

- [ ] **Step 2: Run test to verify it fails**

Run: `cd C:\Users\sudha\.claude\plugins\study-companion && node tests/session-start.test.js`
Expected: FAIL with "Cannot find module './hooks/session-start.js'"

- [ ] **Step 3: Implement handler**

Write `hooks/session-start.js` per design §B handler responsibility:
- Read CLAUDE_PROJECT_DIR (env var Cowork/Code provides)
- Read 12 files in deterministic order (instructions/identity.md, teaching-method.md, banned-phrases.md, rti-method.md, scope-purity.md, trigger-phrases.md, state/SOURCE_OF_TRUTH.md, state/current_day.md, state/active_weak_spots.md, state/last_session_summary.md, state/schedule.md, last 7 days of state/drift_log.md filtered)
- For each: parse `last_updated` frontmatter, compare to now, prepend `⚠️ STALE: ...` if >24h old
- Concatenate to single string
- Output JSON `{"additionalContext": "..."}` to stdout
- Touch state/.locks/session.lock with timestamp
- On any read error: log to stderr, output `{"additionalContext": ""}` (graceful degrade — don't block session start)

- [ ] **Step 4: Run test to verify it passes**

Expected: PASS.

- [ ] **Step 5: Commit**

```
git add hooks/session-start.js tests/session-start.test.js tests/fixtures/
git commit -m "feat(hooks): SessionStart handler reads state, injects context (per design §B)"
```

### Task 6.2: UserPromptSubmit hook (TDD)

- [ ] **Step 1: Write the failing test**

Write `tests/user-prompt-submit.test.js`:
- Test 1: confusion-trigger fixture → expect additionalContext containing "NEVER repeat slower or louder. MUST re-angle"
- Test 2: lock-it-in fixture → expect additionalContext suggesting `/lock-decision`
- Test 3: neutral fixture → expect empty additionalContext

- [ ] **Step 2: Run test (FAIL)**

- [ ] **Step 3: Implement** `hooks/user-prompt-submit.js` per design §B:
- Read prompt from event payload
- Confusion regex: `/(I don'?t (get|understand)|I'?m (lost|confused)|still (lost|confused)|huh\??|wait,? what|you lost me|🤔)/i`
- Lock-in regex: `/(lock it in|mark it|remember this|note this)/i`
- Output appropriate additionalContext per design §D #2 remediation
- Default: empty additionalContext

- [ ] **Step 4: Run test (PASS)**

- [ ] **Step 5: Commit**

### Task 6.3: Stop hook (TDD)

- [ ] **Step 1: Write the failing test**

Write `tests/stop.test.js`:
- Test 1: clean response → no drift_log entries written
- Test 2: filler-phrase response → 1 drift_log entry written, severity=hard, failure=#10
- Test 3: stacked-analogies response → 1 drift_log entry, severity=soft, failure=#3
- Test 4: append-only invariant — pre-existing drift_log entries preserved

- [ ] **Step 2: Run test (FAIL)**

- [ ] **Step 3: Implement** `hooks/stop.js` per design §B + §D detection rules:

Detection regexes (per §D table):
- #10 hard: `/(Hope this helps|Would you like (me )?to|Let me know if|Feel free to|Happy to (help|assist))/i`
- #3 soft: count distinct analogy markers `/imagine\b|think of (it )?as|it'?s like|picture\b|consider it\b/gi` — flag if >1
- #6 soft: code-block batching heuristic — flag if ≥3 code blocks AND ≥2 in last 30% AND none in first 50%
- #7 soft: substantive (≥500 words) AND multi-paragraph AND no pulse phrases (`/Tracking\?|Click\?|With me\?|Make sense\?|Following\?/`)
- #9 soft: short response (<300 words) AND heavy markdown (≥2 headers OR ≥5 bullets) AND short prompt (<50 words)
- #11 soft: substantive teaching response (>100 words) lacks `[Day \d+|Phase \d+|Block \d+]` anchor
- #15 soft: regex `/(I'?m (so |really |very )?sorry|I apologize|My (mistake|apologies|bad))/gi` count > 1

For each match, append to `state/drift_log.md`:
```
{ISO timestamp} | session={session_id} | failure=#{N} | severity={hard|soft} | detail="{specific quote or count}"
```

Also append a single line to `logs/{date}.md` and `logs/sessions/{date}-{time}.md` summarizing the response (length, drift counts).

Atomic write: tmpfile + rename for the daily/session logs; append for drift_log (append is atomic on POSIX; on Windows NTFS use `fs.appendFileSync` which is good enough for single-writer hooks).

- [ ] **Step 4: Run test (PASS)**

- [ ] **Step 5: Commit**

### Task 6.4: PreCompact hook (TDD)

- [ ] **Step 1: Write the failing test**

`tests/pre-compact.test.js`:
- Test: PreCompact fixture event → `state/.compact-state-pending.json` written with `{sessionKey, timestamp, paths: [...]}` per design §B + §H Rule 10

- [ ] **Step 2: Run test (FAIL)**

- [ ] **Step 3: Implement** `hooks/pre-compact.js`:
- Read event payload
- Snapshot list of state file paths (NOT content) into `state/.compact-state-pending.json`
- No additionalContext output (PreCompact doesn't inject context)

- [ ] **Step 4: Run test (PASS)**

- [ ] **Step 5: Commit**

### Task 6.5: PostCompact hook (TDD)

- [ ] **Step 1: Write the failing test**

`tests/post-compact.test.js`:
- Test 1: pending file exists → re-read state files → output additionalContext recreating SessionStart load
- Test 2: pending file missing → output empty additionalContext

- [ ] **Step 2: Run test (FAIL)**

- [ ] **Step 3: Implement** `hooks/post-compact.js`:
- If `state/.compact-state-pending.json` exists, read paths, re-load files (same logic as session-start.js), output additionalContext, delete pending file
- Else: empty additionalContext

- [ ] **Step 4: Run test (PASS)**

- [ ] **Step 5: Commit**

### Task 6.6: Run full hook test suite

- [ ] **Step 1: Add a test runner script**

Write `tests/run-all.js` that runs all 5 hook tests sequentially.

- [ ] **Step 2: Run**

Expected: 5/5 PASS. If any fails, fix before proceeding to Phase 7.

---

## Phase 7 — Skills (12)

**Files:** 12 SKILL.md files under `skills/<name>/SKILL.md`. Bodies authored per design §B exactly.

For each of the 12 skills below, the task is: (a) create directory, (b) write SKILL.md per design §B, (c) lint frontmatter, (d) smoke-test invocation pattern.

### Task 7.1–7.12: Author each skill

Skills (per design §B, in order):

| # | Skill | Design §B reference | Notes |
|---|---|---|---|
| 7.1 | `/teach` | "/teach — mandatory wrapper" | Skill body = full template with Layer 1 → pulse → Layer 2 etc. |
| 7.2 | `/drill` | "/drill — band-aware drill issuer" | Includes band/pattern arguments |
| 7.3 | `/companion` | "/companion — explicit companion-mode entry" | Drops teacher voice; opt-in |
| 7.4 | `/lock-decision` | "/lock-decision — capture user_precondition + concept_gap + test + artifact (REVISED schema)" | Use the revised schema, not the original |
| 7.5 | `/lock-weak-spot` | "/lock-weak-spot — append to active_weak_spots.md" | Append, not overwrite |
| 7.6 | `/post-session` | "/post-session — forced session debrief template" | Port from openclaw post_session_template.md |
| 7.7 | `/self-review` | "/self-review — meta-skill" | 6-item checklist per design §B |
| 7.8 | `/rti-preflight` | "/rti-preflight — RTI session preamble" | Emits the [RTI preflight: ...] marker |
| 7.9 | `/day-wrap` | "/day-wrap — end-of-day routine" | Updates current_day.md + last_session_summary.md |
| 7.10 | `/trace` | "/trace — mental simulation drill" | Phase 1 of loop-bootcamp-strategy |
| 7.11 | `/teach-from-win` | NEW per design §B Revision 2 | Forces precondition-first |
| 7.12 | `/calibrate` | NEW per design §B Revision 2 | Mid-teaching iteration check |

For each skill:
- [ ] **Step 1: Create dir** `mkdir skills/<name>`
- [ ] **Step 2: Write SKILL.md** copying the design §B specification verbatim. Add provenance comment at top: `<!-- Per design §B skill /<name> -->`
- [ ] **Step 3: Validate frontmatter** — write a small Node validator that checks each SKILL.md has at minimum `name` and `description` fields per code.claude.com/docs/en/skills schema.

### Task 7.13: Validate all 12 skills

- [ ] **Step 1: Write `tests/validate-skills.js`**

```javascript
const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml'); // npm install if needed; or hand-parse frontmatter
const skillsDir = path.join(__dirname, '..', 'skills');
const required = ['name', 'description'];
let errors = [];
for (const skillName of fs.readdirSync(skillsDir)) {
  const skillFile = path.join(skillsDir, skillName, 'SKILL.md');
  if (!fs.existsSync(skillFile)) { errors.push(`MISSING: ${skillFile}`); continue; }
  const content = fs.readFileSync(skillFile, 'utf8');
  const m = content.match(/^---\n([\s\S]+?)\n---/);
  if (!m) { errors.push(`NO FRONTMATTER: ${skillFile}`); continue; }
  let fm;
  try { fm = yaml.load(m[1]); }
  catch (e) { errors.push(`BAD YAML: ${skillFile}: ${e.message}`); continue; }
  for (const k of required) {
    if (!fm[k]) errors.push(`MISSING ${k}: ${skillFile}`);
  }
  if (fm.name !== skillName) errors.push(`NAME MISMATCH: ${skillFile} dir=${skillName} frontmatter=${fm.name}`);
}
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }
console.log(`OK: 12 skills validated`);
```

- [ ] **Step 2: Run** — expected: "OK: 12 skills validated"

- [ ] **Step 3: Commit**

```
git add skills/ tests/validate-skills.js
git commit -m "feat(skills): 12 skills authored per design §B (incl. revised /lock-decision schema, new /teach-from-win and /calibrate)"
```

---

## Phase 8 — Sub-agents (2)

**Files:**
- Create: `agents/researcher.md`
- Create: `agents/pattern-detector.md`

### Task 8.1: Author researcher.md

- [ ] **Step 1: Write per design §B "agents/researcher.md"**

```yaml
---
name: researcher
description: Read-only research subagent. Use for parallel investigations across docs/files. NO writes, NO bash, NO state mutations.
tools: Read, Grep, Glob, WebSearch, WebFetch
model: haiku
color: blue
---

You are a focused read-only researcher. Investigate the user's question across the granted folder and the web. Return a tight summary (≤500 words) with file paths and URLs cited inline.

Do NOT modify files. Do NOT run code. Do NOT mutate state. If asked to do any of those, decline and tell the parent thread.
```

### Task 8.2: Author pattern-detector.md

- [ ] **Step 1: Write per design §B "agents/pattern-detector.md"**

(Body per design §B verbatim.)

### Task 8.3: Validate

- [ ] Extend the skill-validator from Task 7.13 to also validate `agents/*.md` frontmatter (`name`, `description` required).

---

## Phase 9 — Seed state files

**Files:**
- Create: `state/SOURCE_OF_TRUTH.md`
- Create: `state/current_day.md` (two-dimension schema per §J #11 clarification)
- Create: `state/active_weak_spots.md` (seed: A1, B2, F3 from RTI state)
- Create: `state/drift_log.md` (empty append-only with header)
- Create: `state/last_session_summary.md` (placeholder)
- Create: `state/schedule.md` (placeholder)

### Task 9.1: Write SOURCE_OF_TRUTH.md

- [ ] Per design §A registry table verbatim. Plus header noting it's the auditor for SessionStart.

### Task 9.2: Write current_day.md (two-dimension)

- [ ] Per design §J #11 schema:

```yaml
---
last_updated: 2026-05-06T20:00:00+05:30
updated_by: build-init
---

bootcamp:
  phase: 2
  completed_through_day: 21       # per pipeline progress_state.xml as of 2026-04-16
  current_day: 35                  # estimated; will refine at next Sunday Review checkpoint
  active_chunk: curriculum_weeks04-06.xml
  active_structure: structure_phase2.xml
  status: in_progress

loop_week:
  current_day: 3
  active: true
  next_topic: "Strings & Variable-Width Shapes"

# Today's plan and yesterday recap will be written by morning-briefing routine.
```

### Task 9.3: Write active_weak_spots.md

- [ ] Per design §F schema. Seed entries: A1 (escalated band-2), B2 (watch, improving), F3 (watch, one-off) — copied from RTI current_state in openclaw_setup.

### Task 9.4: Write drift_log.md

- [ ] Empty file with header explaining append-only schema:

```
# Drift log — APPEND ONLY. Written by Stop hook (claude.ai/code only per #40495). Read by SessionStart hook + drift-audit routine.
# Schema: {ISO timestamp} | session={id} | failure=#{N} | severity={hard|soft} | detail="..."
```

### Task 9.5: Write last_session_summary.md

- [ ] Placeholder with frontmatter only; will be overwritten on first /post-session or /day-wrap invocation.

### Task 9.6: Write schedule.md

- [ ] Placeholder with frontmatter; will be overwritten by morning-briefing routine.

### Task 9.7: Validate state-file schemas

- [ ] **Step 1: Write `tests/validate-state-schemas.js`**

Checks:
- Every `state/*.md` file has `last_updated` and `updated_by` frontmatter
- `last_updated` is a parseable ISO timestamp
- `current_day.md` has both `bootcamp:` and `loop_week:` sections

- [ ] **Step 2: Run** — expected: "OK: 6 state files validated"

### Task 9.8: NOW run CLAUDE.md @-import validation from Task 3.9

- [ ] All 12 @-imports referenced in CLAUDE.md should now resolve. Run `node scripts/validate-imports.js`. Expected: "OK: 12 imports resolve".

---

## Phase 10 — Seed wins (5)

**Files:**
- Create: `wins/2026-03-22-closures-barista-recipe-card.md`
- Create: `wins/2026-03-22-factory-locked-machine.md`
- Create: `wins/2026-03-22-backpack-captured-vars.md`
- Create: `wins/2026-03-22-legb-room-search.md`
- Create: `wins/2026-03-22-nonlocal-old-house.md`

### Task 10.1–10.5: Author each seed win

Per design §G "Seed wins from MEMORY.md" subsection. Each file uses revised /lock-decision schema with `user_precondition: "historical — original confusion context not preserved..."` flag.

For each:
- [ ] **Step 1: Write file** with full frontmatter + 1-2 paragraph body reproducing the analogy. Provenance comment: `<!-- Per design §G Revision 3 seed wins. Historical capture; user_precondition is best-effort. -->`

Example (Task 10.1):

```markdown
<!-- Per design §G Revision 3. Historical capture from MEMORY.md "barista with recipe card in pocket" reference. -->
---
date: 2026-03-22
concept: closures
user_precondition: |
  historical — original confusion context not preserved in MEMORY.md;
  future captures will be higher fidelity per revised /lock-decision schema.
concept_gap: abstract environment-capture (LEGB, scope chain) vs concrete carry-something-along
test: |
  If LEGB-rules-first / definition-first approach had been used instead, would have memorized
  but not internalized — works in toy cases (factorial wrapped in maker), breaks at first
  novel application (state machine, currying real workflow).
artifact: "Closures = barista with recipe card in pocket. The function carries its environment."
---

The barista isn't a generic coffee-maker function. The barista you hand a recipe card to KEEPS that recipe card in their pocket — and uses it every time you ask them to make a drink later. The recipe card is the captured variable. The barista is the closure. Whether you ask them today or tomorrow, the recipe is in their pocket.

This bridge worked because Sudhan was thinking "where does the variable LIVE after the function returns?" — the abstract scope-chain answer doesn't satisfy that question; the recipe-card answer makes the location concrete.
```

(Tasks 10.2–10.5 follow same pattern with their respective concept_gap and test fields per design §G table.)

### Task 10.6: Validate seed wins

- [ ] Extend state-schema validator to also check `wins/*.md` for required frontmatter: date, concept, user_precondition, concept_gap, test, artifact.

---

## Phase 11 — RTI seed

**Files:**
- Create: `room-to-improve/state/current_state.md` (verbatim port from openclaw_setup)

### Task 11.1: Port RTI current_state.md

- [ ] **Step 1: Copy + provenance**

Source: `openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md` → `room-to-improve/state/current_state.md`. Add provenance comment.

- [ ] **Step 2: Update last_updated frontmatter** to today's date (the file is the seed; from this point /post-session updates it).

- [ ] **Step 3: Verify** A1, B2, F3 are listed as active targets matching state/active_weak_spots.md.

---

## Phase 12 — Cloud routines (USER-ACTION HEAVY)

**Files:**
- Create: `routines/<name>.md` — 7 files containing the exact routine prompts the user will paste into Cowork's `/schedule` UI

### Task 12.1: Author 7 routine prompt files

For each routine in design §E, write a markdown file containing:
- Cron schedule
- Repository config (the user's private GitHub repo)
- The exact prompt to paste into the routine creation UI
- Expected outputs and success criteria
- Dispatch destination (if any)

**Files:**

| # | Filename | Schedule (UTC) | Source design ref |
|---|---|---|---|
| 1 | `routines/01-curriculum-sync.md` | `0 3 * * *` | §E #1 |
| 2 | `routines/02-morning-briefing.md` | `15 3 * * *` | §E #2 |
| 3 | `routines/03-spaced-rep-reminder.md` | `30 13 * * 1-6` | §E #3 |
| 4 | `routines/04-github-commit-reminder.md` | `0 15 * * 1-6` | §E #4 |
| 5 | `routines/05-weekly-review.md` | `30 4 * * 0` | §E #5 |
| 6 | `routines/06-monday-distillation.md` | `30 3 * * 1` | §E #6 |
| 7 | `routines/07-drift-audit.md` | `0 5 * * 0` | §E #7 |

(Note: §E was reordered post-second-pass — `study-curriculum-sync` is routine #1, `study-morning-briefing` is #2.)

For each: write per design §E table. Include a "What this routine MUST NOT do" section listing fabrication guards (e.g., for the curriculum-sync routine: "MUST NOT modify any file in the pipeline repo at `~/claude_bootcamp/python_bootcamp_claude_code-main/`. Read-only.").

### Task 12.2: USER-ACTION — submit each routine to Cowork

- [ ] **Pause for user.** Provide a checklist:

For each of the 7 routine files in `routines/`:
1. Open Claude Desktop → Routines tab → "New routine"
2. Set name, schedule, repo (user's private GitHub repo)
3. Paste prompt from `routines/0N-<name>.md`
4. Configure environment (no env vars needed for routines 2-7; routine 1 needs the pipeline repo path accessible — see routine 1's specific config notes)
5. Save routine
6. Click "Run now" once — verify clone + push works, no `[STALE]` flag, no Dispatch error
7. If success, enable scheduled execution. If failure, surface the error to the agent for debugging.

- [ ] **Verification** — agent waits for user confirmation that all 7 routines ran successfully at least once before proceeding to Phase 13.

---

## Phase 13 — Initial commit + push

### Task 13.1: Stage and commit everything

- [ ] **Step 1: Review what's staged**

Run: `git -C "C:\Users\sudha\study-companion" status`
Expected: all the files created in Phases 1–11 (plus routines/ from Phase 12) are listed as new.

- [ ] **Step 2: Stage**

Run: `git -C "C:\Users\sudha\study-companion" add -A`

- [ ] **Step 3: Commit**

```
git -C "C:\Users\sudha\study-companion" commit -m "feat: initial study-companion build per design 2026-05-06

- Folder skeleton + .gitignore (§A)
- 9 instructions/* files (verbatim ports + adapted)
- Top-level CLAUDE.md with 12 @-imports (§C)
- 6 seed state files (§F)
- 5 seed wins from MEMORY.md (§G Revision 3)
- RTI seed state (verbatim port)
- 7 routine prompt files (§E)
- Plugin: 5 hook handlers + 12 skills + 2 sub-agents (§B)

Build plan: docs/superpowers/plans/2026-05-06-cowork-study-companion-build.md
Design plan: docs/superpowers/plans/2026-05-06-cowork-study-companion.md"
```

- [ ] **Step 4: Push**

Run: `git -C "C:\Users\sudha\study-companion" push -u origin main`
Expected: pushes to private repo, sets upstream.

### Task 13.2: Tag the build

- [ ] Run: `git tag -a v0.1.0-build-init -m "Initial build complete; awaiting first session-1 audit per §I"`
- [ ] Run: `git push --tags`

---

## Phase 14 — User verification + first session audit

### Task 14.1: USER-ACTION — Cowork folder grant

- [ ] **Pause for user.** Open Claude Desktop → Cowork → Customize → "Add Folder" → grant `C:\Users\sudha\study-companion\`. Confirm in chat.

### Task 14.2: USER-ACTION — install plugin to Cowork

- [ ] **Pause for user.** Zip the plugin directory: `C:\Users\sudha\.claude\plugins\study-companion\` → `study-companion.zip`. Open Cowork → Customize → "Upload custom plugin" → select the zip. Confirm install.

(Note: skills will work immediately. Hook handlers install but stay dormant per #40495.)

### Task 14.3: USER-ACTION — clone repo for claude.ai/code

- [ ] **Pause for user.** Visit claude.ai/code, configure routine access to the private repo. The same Git repo is now accessible from both surfaces.

### Task 14.4: Run §I session-1 audit

- [ ] **Step 1: Open Cowork session.** Confirm CLAUDE.md auto-loads — Claude's first response should reflect identity (Asta voice) + curriculum anchor (Phase 2 / Day ~35).

- [ ] **Step 2: Test `/teach` skill.** Type `/teach decorators`. Expected: Layer 1 → pulse → Layer 2 → pulse → Layer 3 → drill transition.

- [ ] **Step 3: Test `/lock-decision` revised schema.** Trigger with "lock it in" after a teaching moment. Verify a file appears in `wins/` with `user_precondition` and `concept_gap` fields populated, no `trigger` field.

- [ ] **Step 4: Open claude.ai/code session on the same repo.** Confirm SessionStart hook fires (check `state/.locks/session.lock` timestamp updates; check `logs/sessions/` for new session log).

- [ ] **Step 5: Test banned-phrase detection (claude.ai/code only).** Engineer a casual Q&A where Claude is likely to say "Hope this helps". Verify `state/drift_log.md` gets a new entry tagged `failure=#10 severity=hard`.

- [ ] **Step 6: Time-to-correct-mode measurement.** Note timestamp of session open. Note timestamp of first response demonstrating: one analogy + inline viz + identity voice + curriculum anchor + (if multi-layer) a pulse phrase. Compute delta. Target: <5 minutes. Baseline (Sudhan's Claude.ai): 40-50 minutes.

- [ ] **Step 7: Verify routine reliability.** Check `claude/study-curriculum-sync-2026-05-07` (or whatever date) branch on GitHub the morning after build complete. Verify content of `instructions/curriculum/` matches pipeline repo state.

### Task 14.5: First-session report

- [ ] **Step 1: User writes a first-session.md** at `state/first-session-audit.md` capturing:
  - Time-to-correct-mode result
  - Each §I session-1 check pass/fail
  - Surface used (Cowork or claude.ai/code or both)
  - Anything unexpected

- [ ] **Step 2: Commit first-session-audit.md**

### Stop conditions for build phase

- All Phase 1–14 tasks completed.
- All hook tests passed (Phase 6).
- All skill validators passed (Phase 7).
- All state schema validators passed (Phase 9).
- Initial commit + tag pushed (Phase 13).
- All 7 routines ran successfully at least once (Phase 12).
- Session-1 audit completed and committed (Phase 14).

**Agent does NOT claim full design success on session 1.** Sessions 2 and 3 per §I are user-led and happen after this build phase concludes. Build is "complete"; design validation runs in user's hands over the trend window (sessions 1–7 per §I).

---

## Subagent allocation (subagent-driven mode)

The user requested subagent-driven parallelism. Below is the allocation matrix:

| Subagent | Phases | Why this grouping | Independence |
|---|---|---|---|
| **A — Content port** | 2, 3, 9, 10, 11 | Mostly file I/O + content authoring. No code dependencies between these. | Fully parallel with B and C. |
| **B — Plugin authoring** | 5, 6, 7, 8 | Plugin scaffold + hooks + skills + agents — all in `~/.claude/plugins/study-companion/`. Self-contained. | Fully parallel with A. |
| **C — Routine prompts** | 12 (Task 12.1 only — file authoring; UI submission stays with user) | 7 routine prompt files. Independent. | Fully parallel with A and B. |
| **Main thread** | 1 (Git, requires user pause for repo URL), 4 (CLAUDE.md validation, depends on A's state files), 13 (commit), 14 (verification, requires user actions) | Coordination + user-action handling | Sequential at end |

**Subagents must NOT spawn their own subagents.** Per Claude Code agent docs, sub-agents cannot recursively nest. All inter-phase coordination flows through main thread.

**Parallel start:** A, B, C all kick off simultaneously after Phase 1.7 (user has provided GitHub URL and confirmed App install). Main thread waits for all three before Phase 13.

---

## Self-review (writing-plans skill checklist)

**1. Spec coverage:**
- All 14 phases from build-prompt are covered ✅
- All 12 skills from design §B are covered (Tasks 7.1–7.12) ✅
- All 5 hooks from design §B are covered with TDD (Tasks 6.1–6.5) ✅
- All 7 routines from design §E are authored as prompt files (Task 12.1) ✅
- All 5 seed wins from design §G are authored (Tasks 10.1–10.5) ✅
- Verbatim ports from §G port plan all have explicit copy + provenance tasks ✅
- USER-ACTION boundaries are explicit (U1–U4 pre-build; Tasks 1.5, 1.7, 12.2, 14.1, 14.2, 14.3) ✅
- §I session-1 audit is the verification target (Task 14.4) ✅

**2. Placeholder scan:** No "TBD", "TODO", "as appropriate". Skills reference design §B for body content rather than reproducing — that's intentional (per opening note: design §B is already authored at the right level of specification; reproducing here would be 1500+ lines of duplication for no information gain).

**3. Type consistency:**
- Path conventions: Windows-style `C:\Users\sudha\...` throughout ✅
- File names match between Phase 7 task table, Phase 8 agent files, Phase 9 state files, and §F schemas ✅
- Routine numbering matches between Task 12.1 table and design §E (curriculum-sync = #1, morning-briefing = #2) ✅
- Skill count = 12 (matches design §B revised count) ✅

**4. Gaps found inline-fixed:**
- Phase 4 in original prompt (CLAUDE.md @-imports) was already done in Phase 3.9; build plan notes Phase 4 is deferred validation that runs at end of Phase 9 when state files exist. Not a real Phase 4.

---

## Execution handoff

Plan complete and saved to `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion-build.md`.

**Per the user's stated preference:** subagent-driven execution. Main thread orchestrates Phase 1 (with user-action pauses), then dispatches A/B/C in parallel for Phases 2–12, then resumes for Phases 13–14 (user verification).

**Build will pause at these user-action points:**
1. Phase 1.5 — GitHub repo URL needed
2. Phase 1.7 — Claude GitHub App install confirmation
3. Phase 12.2 — submit 7 routines via Cowork UI (after agent provides prompt files)
4. Phase 14.1 — Cowork folder grant
5. Phase 14.2 — plugin upload to Cowork
6. Phase 14.3 — claude.ai/code repo configure
7. Phase 14.4 — run session-1 audit (user-led)

**The agent should pause and request user input at each of these points; do not work around UI-only steps.**

---

## REVIEW REQUEST

This plan is the build task breakdown for user review BEFORE implementation begins, per the build-prompt instruction: *"Output the TDD task breakdown first (review-able by user) for confirmation before proceeding to implementation."*

**Awaiting user confirmation to proceed.** Specifically:
- Confirm path conventions (Windows-style throughout) match user's environment
- Confirm subagent allocation (A/B/C parallel) is acceptable, or request a different split
- Confirm pre-build U1–U4 are actionable
- Confirm any phase ordering concerns
- Surface any phases the user wants to skip / defer / customize
