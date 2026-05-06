# Design Plan Snapshot — 2026-05-06

> Repo-local snapshot of the design plan. Authoritative copy is at the user's private path; this file exists so Linux Cowork maintainers can verify "Per design §X" references.
>
> **Sync action required:** paste the design plan content below this line. Until that's done, "Per design §X" comments cite a section that's not in the repo.

## Sections
- §A — Folder structure / source-of-truth schemas
- §B — Plugin design (skills + hooks + agents specs)
- §C — Context-loading order
- §D — 16-failure table (surface-aware enforcement)
- §E — 7 cloud routines
- §F — State-file schemas
- §G — Port plan (verbatim ports + adapts + new files)
- §H — 11 anti-drift rules
- §I — Measurement protocol
- §J — Residuals (#1 through #14)


---

# Cowork Study Companion — Design Plan

> **For agentic workers:** This is the **design** document, not the build task-list. The user reviews this, then a separate build prompt produces the executing-plans task breakdown. Save this design as the source-of-truth design spec.

**Goal:** A self-contained Cowork desktop study companion that enforces Sudhan's locked teaching method, tracks RTI pattern-failure state across sessions, runs 7 cloud routines on Max-20x, and addresses the 16 specific behavioral failures from prior Claude.ai study sessions — with honest residuals where the architecture cannot fully prevent drift.

**Architecture:** A single `~/study-companion/` folder Cowork is granted access to, containing CLAUDE.md + instructions + state + logs + drills + RTI tracking. A user-installed plugin (`study-companion`) provides skills, sub-agents, and 5 hook handlers (SessionStart, UserPromptSubmit, Stop, PreCompact, PostCompact) that enforce structure and log drift. State persists in markdown/JSON files in the granted folder; the folder is a Git repo so cloud routines can clone, edit, and commit. PII lives in a separate folder Cowork is never granted.

**Tech Stack:** Cowork (Claude Desktop, Max 20x) · Claude Code v2.1.59+ engine · Node.js for hook handlers · Git for state synchronization between interactive Cowork sessions and cloud routines · Dispatch for mobile · WHOOP API v2 for fitness data · No Discord, no MCP servers beyond what Cowork ships.

**Citations key:** Claims about Cowork capabilities link to Anthropic's first-party docs; where a claim is third-party-only or inferred from architecture, it's flagged in section J.

---

## Locked decisions (2026-05-06)

**Hooks: Option Z (hybrid).** Cowork is the **primary** surface for daily teaching + casual sessions — CLAUDE.md @-imports handle priming, skills handle structure, the 5 plugin hooks sit dormant due to bug [#40495](https://github.com/anthropics/claude-code/issues/40495). **claude.ai/code** (web Claude Code) is the **secondary** surface for RTI drill sessions — hooks fully fire there (SessionStart, UserPromptSubmit, Stop, PreCompact, PostCompact). Both surfaces read/write the same Git repo at `~/study-companion/`. Surface-by-failure breakdown is annotated throughout §D.

**WHOOP: Option (d) — dropped entirely.** No `study-whoop-pull` routine, no `whoop/` folder, no WHOOP references in state/instructions/skills. If recovery state matters later, paste manually.

**Git pre-flight: accepted.** §E 10-step setup runs before first routine. §J #14 (Git operational complexity) stands as documented residual, not a blocker.

**Why this section was an ESCALATION:** Concern 1 verification surfaced bug [#40495](https://github.com/anthropics/claude-code/issues/40495) (label: bug, area:cowork, area:hooks, has-repro). Cowork's Linux sandbox VM does not mount `~/.claude/`; the binary looks for `cowork_settings.json` at `CLAUDE_CONFIG_DIR=/sessions/<name>/mnt/.claude` which doesn't exist. So the 5 hooks in §B do not fire in Cowork today. The hybrid (Z) routes hook-dependent work (RTI drills) to claude.ai/code where hooks DO fire, while keeping the day-to-day teaching surface in Cowork. Track #40495 for the day Cowork hooks land — at that point Cowork becomes a full-fat surface and claude.ai/code becomes optional.

---

## A. Folder structure

### Granted to Cowork: `~/study-companion/`

**Cross-surface mounting (Option Z):** the same `~/study-companion/` folder is accessible from BOTH surfaces:
- **Cowork (primary, daily teaching):** Cowork → Add Folder → `~/study-companion/`. Cowork's Linux sandbox VM mounts the folder per [support.claude.com/.../use-claude-cowork-safely](https://support.claude.com/en/articles/13364135-use-claude-cowork-safely). Hooks dormant per #40495.
- **claude.ai/code (secondary, RTI drills):** the folder is a Git repo on GitHub; claude.ai/code clones it into a fresh sandbox per session per [code.claude.com/docs/en/claude-code-on-the-web](https://code.claude.com/docs/en/claude-code-on-the-web). Hooks fire normally. Commits push to `claude/`-prefixed branches.

**Sync between surfaces is via Git, not shared mount.** Working in Cowork → commit + push before opening claude.ai/code. Working in claude.ai/code → routine commits to `claude/<routine>-<date>` → user merges to `main` → Cowork pulls on next session. Cross-surface discipline detailed in §H Rule 11 (added).

```
~/study-companion/                                # ← Cowork "Add Folder" target
├── .git/                                          # Git repo (state sync with cloud routines)
├── .gitignore                                     # See below
├── CLAUDE.md                                      # Top-level instructions, ~150 lines, walks-up at SessionStart
├── README.md                                      # Human-facing project notes (not loaded into context)
│
├── instructions/                                  # Read at SessionStart, never edited mid-session
│   ├── identity.md                                # Asta identity (ported from openclaw_setup/config/IDENTITY.md + SOUL.md, Discord parts removed)
│   ├── teaching-method.md                         # 5 locked rules (verbatim port)
│   ├── banned-phrases.md                          # Filler phrase blocklist
│   ├── rti-method.md                              # 6 families, 4 bands, 3 non-negotiables, freeze + return-shape protocols
│   ├── scope-purity.md                            # "If a concept hasn't been taught, it doesn't exist" (port from rules.xml)
│   └── trigger-phrases.md                         # "Lock it in" / "Mark it" / confusion-signal vocabularies
│
├── state/                                         # Single source of truth per fact (see §F)
│   ├── SOURCE_OF_TRUTH.md                         # Registry: which file owns which fact
│   ├── current_day.md                             # Bootcamp day/phase/block, machine-updated
│   ├── active_weak_spots.md                       # RTI pattern-family weakness tracker
│   ├── drift_log.md                               # APPEND-ONLY, machine-written by Stop hook
│   ├── last_session_summary.md                    # Written by /post-session and /day-wrap
│   ├── schedule.md                                # Today's plan, written by morning routine
│   └── distilled.md                               # Compacted older logs (Monday routine)
│
├── logs/
│   ├── 2026-05-06.md                              # Daily log, append-only, one per day
│   └── sessions/
│       └── 2026-05-06-1430.md                     # Per-session log, written by Stop hook on session end
│
├── wins/                                          # Pinned teaching gold-standards
│   └── 2026-04-15-closures-barista-analogy.md     # Captured by /lock-decision
│
├── drills/
│   ├── templates/
│   │   ├── pattern_to_drill_map.md                # Verbatim port from openclaw_setup/room-to-improve
│   │   ├── decision_tree.md                       # Verbatim port
│   │   └── band_<1-4>_skeleton.md                 # 4 templates, one per band
│   └── solutions/
│       └── 2026-05-06/
│           └── A1_sum_of_digits/
│               ├── prompt.md                       # The drill spec
│               ├── solution.py                     # User's solution
│               ├── test.py                         # Test cases
│               └── postmortem.md                   # /post-session output
│
├── room-to-improve/                                # Verbatim port from openclaw_setup
│   ├── ROOM_TO_IMPROVE_MVP.md                     # Field manual
│   ├── state/
│   │   └── current_state.md                       # RTI single source of truth
│   └── sessions/
│       └── 2026-05-06.md
│
└── archive/
    └── completed_days/                            # Compacted older logs (rotated by Monday routine)
```

### Plugin location: `~/.claude/plugins/study-companion/`

Lives outside the granted folder. Installed via Cowork → Customize → "Upload custom plugin" or via marketplace once published.

```
~/.claude/plugins/study-companion/
├── .claude-plugin/
│   └── plugin.json                                # Manifest
├── hooks/
│   ├── hooks.json                                  # Hook event registration
│   ├── session-start.js
│   ├── user-prompt-submit.js
│   ├── stop.js
│   ├── pre-compact.js
│   └── post-compact.js
├── skills/
│   ├── teach/SKILL.md
│   ├── drill/SKILL.md
│   ├── companion/SKILL.md
│   ├── lock-decision/SKILL.md
│   ├── lock-weak-spot/SKILL.md
│   ├── post-session/SKILL.md
│   ├── self-review/SKILL.md
│   ├── rti-preflight/SKILL.md
│   ├── day-wrap/SKILL.md
│   └── trace/SKILL.md
└── agents/
    ├── researcher.md
    └── pattern-detector.md
```

### NOT granted (excluded by exclusion, not by trust): `~/personal/`

```
~/personal/                                          # ← NEVER granted to Cowork
├── MEMORY.md                                       # Long-term curated memory (Discord-era, kept for archive)
├── archive/
│   ├── SLEEP-CASE-SUMMARY-2026-03-30.md            # Medical, doctor-handoff
│   └── sudhan-diet-plan.md                         # Nutrition + supplement + biometric data
├── expenses/
│   └── monthly-2026-*.md
└── openclaw_setup/                                 # The reference snapshot, retained read-only outside grant
```

### `.gitignore` (in `~/study-companion/`)

```
whoop/.last_health.json
whoop/*.json.tmp
state/.locks/
*.swp
.DS_Store
```

WHOOP raw JSON commits are intentionally tracked — they're per-day snapshots, no PII beyond fitness metrics, useful for routine state.

### Single-source-of-truth registry: `state/SOURCE_OF_TRUTH.md`

```
| Fact                          | File                                | Writer                | Reader                |
|-------------------------------|-------------------------------------|-----------------------|-----------------------|
| Current bootcamp day/phase    | state/current_day.md                | morning-briefing rtn  | SessionStart hook (claude.ai/code) + CLAUDE.md @-import (Cowork) |
| Active weak spots             | state/active_weak_spots.md          | /post-session, user   | SessionStart hook + CLAUDE.md @-import |
| Drift events                  | state/drift_log.md                  | Stop hook (claude.ai/code only — dormant in Cowork per #40495) | SessionStart hook + CLAUDE.md @-import |
| Last session summary          | state/last_session_summary.md       | /post-session, /day-wrap | SessionStart hook + CLAUDE.md @-import |
| Today's schedule              | state/schedule.md                   | morning-briefing rtn  | SessionStart hook + CLAUDE.md @-import |
| RTI live state                | room-to-improve/state/current_state.md | /post-session      | /rti-preflight        |
| Wins (gold-standard)          | wins/<date>-<slug>.md               | /lock-decision        | /teach-from-win, /self-review, manual review |
```

---

## B. Plugin design

### `.claude-plugin/plugin.json`

```json
{
  "name": "study-companion",
  "description": "Sudhan's bootcamp study companion. Enforces locked teaching method, tracks RTI pattern-failure state, logs drift across sessions. Pure desktop, no Discord.",
  "version": "0.1.0",
  "license": "private",
  "homepage": "local",
  "repository": "local"
}
```

Citation: Plugin manifest schema — [code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins).

**Install path (verified 2026-05-06):** Custom unpublished plugins install via Cowork → Customize → "Upload custom plugin file" — no marketplace publishing required. Quote from the help article: *"You can also upload a custom plugin file if you've built one yourself or received one from a colleague. Plugins you add yourself are saved locally to your machine."* Source: [support.claude.com/.../use-plugins-in-claude-cowork](https://support.claude.com/en/articles/13837440-use-plugins-in-claude-cowork). If the user later wants a personal marketplace (for cross-device install or sharing), the minimum is a private GitHub repo with `.claude-plugin/marketplace.json` containing `name`, `owner.name`, and `plugins[]` with each entry having `name` + `source`. For private-repo marketplaces, Cowork org admins use the GitHub-sync admin flow; solo users can use `gh` CLI auth or `GITHUB_TOKEN` env var per [code.claude.com/docs/en/plugin-marketplaces](https://code.claude.com/docs/en/plugin-marketplaces).

**Cross-surface plugin install under Option Z:** the **same plugin file** installs to both surfaces:
- **Cowork:** Customize → Upload custom plugin file → installed under `~/.claude/plugins/study-companion/` per Anthropic's "Plugins you add yourself are saved locally" doc. Skills + agents fire; hooks dormant per #40495.
- **claude.ai/code:** the same plugin lives at `.claude/plugins/study-companion/` inside the granted repo (gitignored or committed depending on user preference; recommended: commit so claude.ai/code clones it with the repo). Hooks fire normally per [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks). 

The plugin is authored once, deployed twice. No surface-specific code paths inside skill/hook source.

### `hooks/hooks.json`

```json
{
  "hooks": {
    "SessionStart": [
      {
        "type": "command",
        "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/session-start.js"
      }
    ],
    "UserPromptSubmit": [
      {
        "type": "command",
        "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/user-prompt-submit.js"
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/stop.js"
      }
    ],
    "PreCompact": [
      {
        "type": "command",
        "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/pre-compact.js"
      }
    ],
    "PostCompact": [
      {
        "type": "command",
        "command": "node ${CLAUDE_PLUGIN_ROOT}/hooks/post-compact.js"
      }
    ]
  }
}
```

Citation: Hook events list — [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks). Plugin-bundled hooks execute inside claude.ai/code sessions per [code.claude.com/docs/en/hooks](https://code.claude.com/docs/en/hooks). **In Cowork today, these hooks do NOT fire** per open bug [#40495](https://github.com/anthropics/claude-code/issues/40495) — root cause: the user's `~/.claude/` is not mounted into Cowork's Linux sandbox VM. Under Option Z (locked), the daily-teaching surface is Cowork (hooks dormant) and the RTI-drill surface is claude.ai/code (hooks fire). The hook configuration above is the design intent for both surfaces; only its execution differs by surface today. When #40495 lands, Cowork hooks activate without code changes. User-authored hooks in `~/.claude/settings.json` are **not** a documented Cowork feature regardless of bug status — plugin packaging is the only supported path.

### Hook handler responsibilities

| Hook | File | Reads | Writes | additionalContext injected |
|---|---|---|---|---|
| **SessionStart** | session-start.js | `instructions/*.md`, `state/SOURCE_OF_TRUTH.md`, `state/current_day.md`, `state/active_weak_spots.md`, `state/last_session_summary.md`, `state/schedule.md`, last 7 days of `state/drift_log.md` | Touches `state/.locks/session.lock` with timestamp | Concatenated content of read files in fixed order (see §C). Adds freshness warning if any state file is >24h old. |
| **UserPromptSubmit** | user-prompt-submit.js | User's prompt text only | None | If prompt matches confusion regex → injects re-angle directive. If matches "lock it in" trigger → injects `/lock-decision` invocation hint. If matches `/^\s*\?\s*$/` (silent question mark) → injects pulse-check prompt. |
| **Stop** | stop.js | Final assistant response text | Appends to `state/drift_log.md`, `logs/YYYY-MM-DD.md`, `logs/sessions/YYYY-MM-DD-HHMM.md` | None (Stop fires after display — see §J risk #1) |
| **PreCompact** | pre-compact.js | Current conversation summary (provided by harness) | Snapshots to `state/.compact-state-pending.json` | None |
| **PostCompact** | post-compact.js | `state/.compact-state-pending.json` | Deletes the pending snapshot after re-injecting | Re-injects: same content as SessionStart (state files), so post-compaction context is restored deterministically |

### Skills (12 total)

Each skill is a directory `~/.claude/plugins/study-companion/skills/<name>/SKILL.md`. Schema reference: [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills). All 12 skills work identically in Cowork and claude.ai/code — skill execution is unaffected by hook bug #40495.

#### `/teach` — mandatory wrapper for substantive teaching

```yaml
---
name: teach
description: Use for any substantive teaching of a new concept. Enforces slow-ladder structure, inline visualization, and pulse-checks between layers.
when_to_use: "User asks to learn, explain, or understand a new concept (closures, decorators, recursion, comprehensions, etc.). Mandatory for substantive teaching, optional for one-line clarifications."
allowed-tools: Read, Write, Edit
model: inherit
---

# /teach

Structure your response in this exact format. Do not skip any layer. Do not batch visuals at the end.

**Pre-flight (silent — for your own thinking):**
1. What is the ONE concept?
2. What's the smallest mental model that gets it across?
3. What's ONE analogy, mechanism-matched? (Russian dolls for recursion. Recipe card for closures. Don't stack analogies.)
4. What's the inline visualization? (ASCII trace, side-by-side variants, decision table.)

**Layer 1 — The mental model.**
[Plain-language explanation, 2-4 sentences. NO code yet.]
[Inline visualization here, immediately after the explanation.]

**Pulse check 1:** "Tracking?" / "Click?" / "With me?" — pick one. Wait for user response.

**Layer 2 — The mechanism.**
[How the language actually does it. Tied directly to Layer 1's mental model.]
[Inline visualization or short trace.]

**Pulse check 2.**

**Layer 3 — The pattern.**
[Where this shows up in real code. ONE example, fully worked.]

**Drill-1 transition:** "Want to try it? Here's a Band 1 warm-up: ..."

If the user signals confusion at any pulse-check: NEVER repeat slower or louder. Re-angle: switch domain analogy, run an ASCII trace from scratch, or pulse-check "what specifically is unclear about <X>". State which angle in your first sentence after the confusion signal.
```

#### `/drill` — band-aware drill issuer

```yaml
---
name: drill
description: Issue a coding drill at a specific RTI band, with explicit pattern family target and delta from previous drill.
when_to_use: "User says 'give me a drill', 'one more', 'harder version'. Or invoked automatically after /teach Layer 3."
arguments:
  band: "1|2|3|4 (default: read state/active_weak_spots.md to pick)"
  pattern: "A1|A2|A3|A4|B1|B2|B3|C1|C2|C3|C4|D1|D2|D3|E1|E2|E3|E4|F1|F2|F3 (default: top active weak spot)"
allowed-tools: Read, Write
---

# /drill

Generate a Band {band} drill targeting pattern {pattern}.

If this is drill 2+ in the session, FIRST output the **Delta from previous drill**:
- Previous: <pattern> at Band <N>, result: <pass|bug-found|freeze>
- This drill flips: <the 1-2 things that change>
- Side-by-side diff vs previous: [ASCII or code block]

Then issue the drill in this format:

```
## Drill {N} — Band {band} — Pattern {pattern}

**Time budget:** {5-10 min Band 1 / 20-30 min Band 2 / 20-30 min Band 3 / 30-45 min Band 4}

**Problem:** [one paragraph]

**Asserts (read these BEFORE writing code — return-shape protocol):**
```python
assert solve(...) == ...
```

**What to do if you freeze (Family B protocol):**
1. What is the INPUT?
2. What is the OUTPUT?
3. What is ONE thing I know how to do here?
4. Write that one thing.
```

After user submits solution, run it (Bash + Python), read actual output, append result to `drills/solutions/{date}/{problem}/postmortem.md`.
```

#### `/companion` — explicit companion-mode entry

```yaml
---
name: companion
description: Enter companion (banter, casual, peer) mode. Default mode is "available, not performed" — companion mode is opt-in.
when_to_use: "User explicitly says 'be a companion now', 'chat with me', 'banter mode', or asks an obviously casual question."
---

# /companion

Drop the teacher voice. No layers, no pulse-checks, no lock phrases. Match user's energy and length. Opinions allowed. Sarcasm allowed when fitting. No filler. No "Hope this helps!"

Stay until user invokes /teach or /drill or asks a substantive question — then snap back to that mode and announce the switch in one sentence.
```

#### `/lock-decision` — capture user_precondition + concept_gap + test + artifact (REVISED schema)

```yaml
---
name: lock-decision
description: Capture a teaching win — the user-side precondition that produced it, the structural gap it bridged, the counterfactual test, and the artifact. Triggered by "lock it in", "mark it", or after a clearly-landed explanation.
when_to_use: "User says 'lock it in', 'mark it', or you just delivered an explanation that visibly landed and you want to pin it for re-use."
allowed-tools: Read, Write, Edit
---

# /lock-decision

Schema revised post-coordinator-review (2026-05-06): the prior `trigger` field asked Claude to introspect on its own choice — that introspection is post-hoc storytelling, not the actual generative mechanism. New schema captures user-side state instead, which is observable and verbatim-quotable.

Write to `~/study-companion/wins/{date}-{slug}.md` with this exact frontmatter:

```yaml
---
date: {YYYY-MM-DD}
concept: {topic, e.g. closures}
user_precondition: |
  Verbatim quote of the user's confusion sentence that immediately preceded the win.
  Include the user's failed prior attempt verbatim if one exists in this conversation.
  Do NOT paraphrase. Do NOT introspect on why the user was confused.
  Example: "I keep losing where the variable went. I tried writing it like a regular function and it just... doesn't carry the count?"
concept_gap: {one line — the structural mismatch between the user's mental model and the language mechanism. NOT the analogy. The gap the analogy bridges.}
test: |
  Counterfactual: if [some other approach — abstract definition, LEGB rules first, etc.] had been used instead, what would have failed?
  Be specific about the failure mode (memorize-not-internalize, work-in-toy-cases-not-real-code, etc.)
artifact: {the analogy/visualization/sentence in one line — the bridge}
---
```

Then the body: 2-3 paragraphs reproducing the explanation that landed, plus the user's confirmation message verbatim.

Output to user: "Locked ✅" — nothing else.
```

#### `/teach-from-win` — apply past wins to a current concept (NEW)

```yaml
---
name: teach-from-win
description: Apply the kind-of-move from past wins to a current concept. Wins are calibration targets, not reproduction recipes. Use when user wants "teach me X like you did Y."
when_to_use: "User references a past win ('like the barista one', 'do that mechanism-matching thing again') for a NEW concept."
allowed-tools: Read, Write
---

# /teach-from-win

Wins library is calibration data, not a script. The artifact captured a past bridge over a past river. The current river is different. Don't re-use the past bridge — make a new one of the same kind.

**Mandatory order — do not skip:**

1. **Get current precondition first.** Before reading any wins, ask the user:
   "What's your current attempt? What specifically isn't clicking? Show me where you got stuck."
   Wait for the user's verbatim answer. This is the current river.

2. **Read 1-3 wins from related topics.** Filter by `concept_gap` similarity, not by `concept` similarity (a closures win may calibrate a generators explanation; an LEGB win may calibrate scoping in any context).

3. **Identify the kind-of-move.** What did the past wins have in common? Mechanism-matched (not just topical), one analogy (not stacked), inline visualization (not batched), bridge-not-jargon. The structural pattern, not the surface artifact.

4. **Generate fresh against the current precondition.** Use the kind-of-move as a quality bar. Do NOT reuse the past artifact's analogy unless it genuinely fits the current gap.

5. **Output:** the new explanation, opened with one sentence stating which kind-of-move you're aiming for. Example: "Going for mechanism-matched here — same as the barista win but for generators, your gap is X so the bridge is Y."

The honest framing: success is "does this land here, on this gap, now?" — not "does this match the previous version."
```

#### `/calibrate` — real-time iteration check (NEW)

```yaml
---
name: calibrate
description: Mid-teaching check on whether a draft response is landing. Faster than /self-review; user-in-the-loop, not self-applied.
when_to_use: "After drafting a substantive teaching response, BEFORE sending. Especially when uncertain whether mechanism-matched or generic."
allowed-tools: Read
---

# /calibrate

Output your draft response, then ask:

```
[Draft above]
---
Calibrating: mechanical / generic / on-target?
If not on-target, what's missing — wrong gap, wrong angle, or right idea wrong words?
```

Wait for user response. Two iterations max — if still not landing, switch to `/teach-from-win` from a different angle, or step back and ask the user to restate the gap in their own words (move the river before redesigning the bridge).

Do NOT use this for trivial questions or when the response is already short. Reserved for substantive teaching where landing matters and where the cost of "send hollow draft + correct after" exceeds the cost of "ask once mid-flight."
```

#### `/lock-weak-spot` — append to active_weak_spots.md

```yaml
---
name: lock-weak-spot
description: Append a new RTI pattern-family failure to active_weak_spots.md after a drill miss or repeated bug.
when_to_use: "After a drill where the same bug appeared twice in the same session, or when an escalation rule fires (Same bug twice = STOP)."
allowed-tools: Read, Edit
---

# /lock-weak-spot

Append (don't overwrite) to `state/active_weak_spots.md`:

```yaml
### {pattern_family}: {short name}
- First seen: {date}
- Last seen: {today}
- Pattern: {1-line description, specific not generic}
- Band: {1|2|3|4} ({watch|escalated})
- Reps to graduate: {3 independent at Band 2, then 1 at Band 3}
- Reps so far: {N}
- Drill targets: {specific drill names, not "more practice"}
```

Output: "Tagged ✅ — Band 2 drills on {pattern} only until 2 independent reps, then re-test at Band 3."
```

#### `/post-session` — forced session debrief template

Port from `openclaw_setup/room-to-improve/room-to-improve-architecture/post_session_template.md`. Forces user through:
1. Independence score (0-4) with specific definition per score
2. Pattern hits (which families fired, count)
3. Same-session repeats (escalation triggers)
4. AI-completed flag (`[AI]` tagged problems)
5. Tomorrow's drill targets (≤4)
6. One sentence on emotional state

Writes to `room-to-improve/sessions/{date}.md` and updates `room-to-improve/state/current_state.md`.

#### `/self-review` — meta-skill, invoked by Claude before final response on substantive work

```yaml
---
name: self-review
description: Critique your own draft response before sending. Catches stacked analogies, missing pulse-checks, batched visuals, banned phrases. Self-applied — best-effort, not enforced.
when_to_use: "Before any substantive teaching response (>200 words, multi-layer concept). Skip for one-liners."
disable-model-invocation: false
---

# /self-review

Before sending your draft, check it against these:

1. **One analogy?** Count distinct analogies (markers: "imagine", "think of it as", "it's like"). If >1, pick the strongest, drop the others.
2. **Visualization inline?** Are visuals next to the explanation they illustrate, or batched at the end? If batched, move them inline.
3. **Pulse-checks?** For multi-layer responses, is there a "Tracking?" / "Click?" / "With me?" between layers? If missing, add one.
4. **Banned phrases?** Scan for "Hope this helps", "Would you like me to", "Let me know if", "Feel free to", "Happy to", "Great question". Strip them.
5. **Curriculum anchor?** Did you reference [Day N • Phase P • Block B] for substantive teaching? If missing, add it.
6. **User-mastery override?** Are you contradicting the user's "I get this" without explicit failure evidence? If yes, defer to user.

Output the cleaned response. Do not output the checklist.
```

#### `/rti-preflight` — RTI session preamble

Port from `openclaw_setup/config/AGENTS.md` "#room-to-improve" section. Required before any RTI drill session. Reads `room-to-improve/state/current_state.md`, emits the preflight marker:

```
[RTI preflight: MVP loaded, state loaded. Phase {P} Day {D}. Targeting {patterns} at Band {B}. Last session: {date}.]
```

If state file is stale >3 days, emit `[RTI: state is N days stale — last session was DATE]`.

#### `/day-wrap` — end-of-day routine

```yaml
---
name: day-wrap
description: End-of-day debrief. Updates current_day.md, last_session_summary.md, and appends to logs/{date}.md.
when_to_use: "User says 'day wrap', 'wrap up', 'done for today', or it's >20:00 IST and a study session is closing."
allowed-tools: Read, Write, Edit
---

# /day-wrap

Walk through:
1. What landed today? (3 bullets max)
2. What didn't land or got paused?
3. Tomorrow's first task (specific, not "review notes")
4. Energy state (1-5)

Update `state/current_day.md`:
- If today's planned block was completed → advance day/block
- If paused → keep day, mark status `paused`, add `paused_reason`

Update `state/last_session_summary.md` (overwrite, not append).

Append to `logs/{date}.md` under "## Day Wrap" heading.

Output: terse confirmation + tomorrow's first task.
```

#### `/trace` — mental simulation drill (port from loop-bootcamp-strategy.txt Phase 1)

```yaml
---
name: trace
description: Force mental simulation of an iteration before any code is written. Trace tables only — no execution.
when_to_use: "User is about to attempt a loop/iteration drill, OR user has frozen on one. Phase 1 of loop-bootcamp-strategy."
---

# /trace

I'll give you a snippet. You produce a trace table BEFORE running anything.

```
| step | i | accumulator | output |
|------|---|-------------|--------|
| 0    | - | []          | -      |
| 1    | ? | ?           | ?      |
```

Fill 3-5 rows by hand. I check. THEN you may run the code.

If you skip the trace and run the code: I stop the drill. We restart with trace-first.
```

### Sub-agents (2)

#### `agents/researcher.md`

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

#### `agents/pattern-detector.md`

```yaml
---
name: pattern-detector
description: Analyze a drill solution (the user's code + actual output) and identify which RTI pattern family the bug fits. Returns family code + 1-line justification.
tools: Read, Bash
model: sonnet
color: orange
---

You are an RTI pattern classifier. Read `~/study-companion/instructions/rti-method.md` for the 6 families and subtypes. Then read the drill artifacts at the path the parent gives you.

Classify the failure (if any) into ONE of: A1, A2, A3, A4, B1, B2, B3, C1, C2, C3, C4, D1, D2, D3, E1, E2, E3, E4, F1, F2, F3.

Output exactly:
```
PATTERN: {code}
JUSTIFICATION: {1-2 sentences quoting the specific bug}
RECOMMENDATION: {specific drill family for tomorrow, not generic advice}
```

If no bug fits cleanly, output `PATTERN: clean` and skip the rest.
```

### Commands

The skills above replace separate commands. Per [code.claude.com/docs/en/skills](https://code.claude.com/docs/en/skills), custom commands have been merged into skills in 2026 — both `.claude/commands/foo.md` and `.claude/skills/foo/SKILL.md` create `/foo`. Skills are the modern path.

---

## C. Context-loading order at SessionStart

**Two paths under Option Z, identical files in identical order:**

- **claude.ai/code (RTI surface):** SessionStart hook fires, reads files in order, injects via `additionalContext`. Adds freshness-warning logic for >24h-stale files.
- **Cowork (daily surface):** the same files load via CLAUDE.md `@path` imports. Cowork natively reads `CLAUDE.md` from the granted folder per [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory) — walks up from cwd, depth-5 import chain, concatenated not overridden. The SessionStart hook is dormant here per #40495, so the freshness warning is missing — `state/SOURCE_OF_TRUTH.md` is read but not auto-checked. User can invoke `/freshness-check` skill (build later if needed) for the equivalent.

Either path: identical 12-file load, ~5,200 tokens, deterministic order. No retrieval lottery. The CLAUDE.md @-import path is what carries this design's primary enforcement layer (deterministic priming → solves time-to-correct-mode per §I) and is unaffected by #40495.

The SessionStart hook reads files in this exact order and concatenates them into `additionalContext` (claude.ai/code) or CLAUDE.md @-imports them in the same order (Cowork):

| # | File | Approx tokens | Purpose |
|---|---|---|---|
| 1 | `instructions/identity.md` | ~150 | Asta identity, vibe, banned-AI-disclaimers |
| 2 | `instructions/teaching-method.md` | ~1000 | 5 locked rules verbatim |
| 3 | `instructions/banned-phrases.md` | ~200 | Filler phrase blocklist |
| 4 | `instructions/rti-method.md` | ~1200 | 6 families, 4 bands, 3 non-negotiables, freeze + return-shape protocols |
| 5 | `instructions/scope-purity.md` | ~300 | "Concepts not yet taught don't exist" |
| 6 | `instructions/trigger-phrases.md` | ~150 | "Lock it in" / confusion vocabularies |
| 7 | `state/SOURCE_OF_TRUTH.md` | ~200 | Registry + freshness rules |
| 8 | `state/current_day.md` | ~300 | Today's day/phase/block |
| 9 | `state/active_weak_spots.md` | ~500 | Top 3 weak spots in priority order |
| 10 | `state/last_session_summary.md` | ~400 | What landed last session, what didn't |
| 11 | `state/schedule.md` | ~300 | Today's plan |
| 12 | Last 7 days of `state/drift_log.md` (filtered) | ~500 | Recent drift to watch for |

**Total target: ~5200 tokens.** With Cowork's 1M context window, this is 0.5%. Plenty of headroom.

`CLAUDE.md` at the granted folder root is read by Cowork natively (folder instructions). It contains imports via `@instructions/teaching-method.md` etc. as a redundancy layer — if the SessionStart hook fails, CLAUDE.md still pulls the same files via the documented `@path` import mechanism (depth 5). Citation: [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory).

**Freshness rule:** Each state file has a `last_updated` ISO timestamp. The hook flags any file >24h old by prepending a warning:

```
⚠️ STALE: state/current_day.md last updated 2026-05-04T08:45:00+05:30 (>24h ago).
The bootcamp day below may not reflect today's progress. Confirm with user before relying.
```

---

## D. Hook-based enforcement for the 16 behavioral failures

| # | Failure | Hook | Detection | Remediation | Honest residual |
|---|---|---|---|---|---|
| 1 | Teaching style swing (slow-ladder vs textbook) | SessionStart | None — proactive deterministic load | `instructions/teaching-method.md` injected verbatim every session | High compliance; same fundamental "self-applied at output" ceiling as CLAUDE.md but materially better than vector-retrieval Projects memory because the load is deterministic |
| 2 | Confusion met with louder repetition | UserPromptSubmit | Regex on user input: `/(I don'?t (get\|understand)\|I'?m (lost\|confused)\|still (lost\|confused)\|huh\??\|wait,? what\|you lost me\|🤔)/i` | additionalContext: "User signaled confusion. NEVER repeat slower or louder. MUST re-angle (switch domain analogy, run ASCII trace, or pulse-check what's specifically unclear). State which angle in first sentence." | Self-applied at output; arms race with phrasing variants (silence, "wait..." trail, emoji-only). False negatives accepted |
| 3 | Stacked analogies | Stop | Count distinct analogy markers per response: `/imagine\b\|think of (it )?as\|it'?s like\|picture\b\|consider it\b/gi`. Threshold >1 distinct subject = flag | Append entry to `state/drift_log.md`. Next-session SessionStart reads it and injects "Last session you stacked N analogies on {topic}; one analogy max." | **Stop fires after display.** Cannot un-display. Logs only — drift is corrected next session, not this one. Same fundamental Gap 1 |
| 4 | New mechanics dumped without teaching | /teach skill | Skill template forces Layer 1 → pulse → Layer 2 → pulse | Generation-prompt-level enforcement (via skill body) | Only works if substantive teaching is routed through /teach. If user just asks "explain decorators" without invoking /teach, only the SessionStart instructions apply. Mitigation: SessionStart instructions include "Substantive teaching of new concepts MUST use /teach unless user explicitly waives" |
| 5 | Drill-to-drill transitions skip the delta | /drill skill | Skill body requires "Delta from previous drill" section when drill index ≥2 in session. Stop hook also greps response for "Delta from previous" when 2+ `/drill` invocations occurred | If missing, log to drift_log | Same as #4; relies on /drill being invoked |
| 6 | Visuals batched at end instead of inline | Stop | Heuristic: count code blocks. If response has ≥3 code blocks AND ≥2 are in the final 30% of the message AND none are in the first 50% → flag | Append to drift_log | Heuristic, false positives possible (some responses legitimately load with explanation first). Tuned conservatively |
| 7 | Pulse-checks missed on heavy content | /teach skill template + Stop check | /teach forces "Pulse check: <q>" between layers. Stop scans substantive responses (>500 words, multi-paragraph) outside /teach for ≥1 pulse phrase: `/Tracking\?\|Click\?\|With me\?\|Make sense\?\|Following\?/` | If missing, log + injected warning next session | Heuristic; off-pattern phrasings ("Does that work?") not caught |
| 8 | Companion mode performed instead of available | /companion skill is opt-in | Default mode (per identity.md): "available, not performed". /companion is the explicit gate | Skill is the gate; SessionStart instructions explicitly state the default | Relies on user invoking /companion when they want it. Mitigation: UserPromptSubmit detects casual phrasings ("yo", "lol", "what's up") and suggests /companion |
| 9 | Markdown structure on light questions | Stop | Heuristic: response is short (<300 words) AND uses heavy markdown (≥2 headers OR ≥5 bullets) AND user prompt was short (<50 words AND ends with `?`) → flag | Append to drift_log | Cosmetic; logs only |
| 10 | Filler phrases ("Hope this helps", "Would you like me to") | Stop | Regex hard-fail: `/(Hope this helps\|Would you like (me )?to\|Let me know if\|Feel free to\|Happy to (help\|assist))/i` | Append HARD FLAG to drift_log; weekly drift-audit highlights | **Stop is post-display.** Cannot reject before user sees it. Mitigation: /self-review skill called by Claude before final response on substantive work catches this. Coverage estimate: 60-80% with /self-review, 30-50% without |
| 11 | Curriculum anchors skipped | SessionStart | Inject `state/current_day.md` verbatim. Instructions add: "First substantive response in study session MUST include `[Day N • Phase P • Block B]` anchor." | Stop hook checks first substantive response (>100 words) for `\[Day \d+` pattern; flags if missing | Self-applied; some sessions are non-study (e.g., quick admin question) where anchor is silly. Skill `/companion` exempts |
| 12 | Memory hooks attached inconsistently | /lock-decision skill template | Forced template captures trigger + test + artifact deterministically | Skill enforces structure | Quality of *content* (the trigger description) still relies on Claude's introspection. The capture is deterministic; the wisdom isn't |
| 13 | Drift correction not persistent across sessions | drift_log.md (append-only) + SessionStart reads last 7 days | Stop hook writes; SessionStart reads | Drift becomes persistent and visible | Coverage limited to what Stop hook can detect (regex + heuristics). Semantic drift (e.g., subtly wrong analogy choice) won't be flagged |
| 14 | User's self-assessment of mastery overridden | SessionStart instructions + /self-review check 6 | Inject: "Trust user's mastery claims. Override only if `state/active_weak_spots.md` shows recent failure on the same pattern within 7 days." | Self-review skill explicitly checks for this | Heuristic. The "recent failure" rule is deterministic, but judging "is the user contradicting weak_spots" requires semantic comparison Claude does, not the hook |
| 15 | Errors over-apologized for | Stop | Regex: `/(I'?m (so \|really \|very )?sorry\|I apologize\|My (mistake\|apologies\|bad))/gi` count >1 in same response | Append to drift_log | After-the-fact |
| 16 | Re-Run protocol reactive, not preventive (the meta) | Composite — all of the above | Stop hook logs + drift_log persists + SessionStart reads + /self-review pre-output check | The user is no longer the only enforcement layer; the system asynchronously audits itself | **The honest answer to the user's #1-ranked failure:** real-time prevention requires output-rejection-before-display, which Cowork does not provide. What this design gets is ~70% drift reduction (estimate, validate over 3 sessions) via deterministic load + post-display logging + next-session correction + /self-review pre-output critique. **The remaining 30% is the same gap that killed Claude.ai workarounds.** Don't promise 100% |

**Composite enforcement strategy ranking by reliability:**
1. **Strongest:** Deterministic SessionStart context load via CLAUDE.md @-imports (#1, #11, #13, #14) — works at the level Claude.ai's vector retrieval couldn't because it bypasses retrieval lottery. **Unaffected by #40495.** This layer is what directly targets the user's #1 pain — time-to-correct-mode. Both surfaces benefit equally.
2. **Strong:** Skill templates that force structure (#4, #5, #7, #8, #12) — works only when invoked. **Unaffected by #40495.** Both surfaces.
3. **Medium:** UserPromptSubmit context injection (#2) — works at input time, before generation, but still self-applied. **claude.ai/code only** (hook needed).
4. **Weak (logging only):** Stop hook detection (#3, #6, #9, #10, #15) — fires post-display; corrects next session, not this one. **claude.ai/code only.** In Cowork, drift is undetected for the affected failure numbers; only /self-review and /calibrate provide pre-output catches.
5. **Honest:** No layer in this design rejects Claude's output before the user sees it. That's an architectural fact for both surfaces.

### Surface-aware enforcement under Option Z

Each of the 16 failures fits one of three categories:

| Category | Failures | Both surfaces? |
|---|---|---|
| **Both surfaces (skills + CLAUDE.md @-imports)** | #1, #4, #5, #8, #11, #12, #14 | YES — primary enforcement layer works in Cowork AND claude.ai/code |
| **claude.ai/code only (hook-dependent)** | #2, #3, #6, #9, #10, #13, #15, #16 | NO — these need hooks. Cowork sessions for daily teaching don't get this enforcement; route RTI drills to claude.ai/code where these fire |
| **Both with degradation** | #7 (skill template fires both surfaces; Stop post-check only on claude.ai/code) | Partial — Cowork loses the post-/teach response check |

**Implication for Sudhan's workflow:** casual teaching, quick lookups, and CLAUDE.md-priming-driven needs run cleanly on Cowork. RTI drill sessions where drift detection (#3 stacked analogies, #10 filler phrases, #13 persistence, #15 over-apologies, #16 the meta) actually matters should run on claude.ai/code. The two surfaces share the same Git repo — drift logged in claude.ai/code is visible in next-session Cowork via CLAUDE.md @-import of `state/drift_log.md`.

### Cowork-side enforcement under #40495 (Option Z, daily-teaching surface)

Cowork sessions ignore all hooks today. The Cowork-side substitution layer is:
- **SessionStart hook** → CLAUDE.md @-imports. Cowork natively reads `CLAUDE.md` in the granted folder per [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory); imports up to depth 5. This is *deterministic enough* — same files load same order, no retrieval lottery — but lacks the freshness-warning logic the hook would add.
- **Plugin-bundled skills** → still work in Cowork. The install path (custom plugin file upload) functions normally; only hook execution is broken. So `/teach`, `/drill`, `/companion`, `/lock-decision`, `/lock-weak-spot`, `/post-session`, `/self-review`, `/rti-preflight`, `/day-wrap`, `/trace` all remain available.
- **UserPromptSubmit / Stop / PreCompact / PostCompact** → no substitute. These do not fire.

**Behavior of each of the 16 failures by surface (Option Z locked):**

| # | Failure | Cowork (daily) | claude.ai/code (RTI) |
|---|---|---|---|
| 1 | Teaching style swing | ✅ CLAUDE.md @-import loads teaching-method.md | ✅ Same + SessionStart hook adds freshness check |
| 2 | Confusion → louder repetition | ❌ UserPromptSubmit dead. User manually invokes `/teach` after confusion | ✅ UserPromptSubmit fires, injects re-angle directive |
| 3 | Stacked analogies | ❌ Stop dead. /self-review or /calibrate is the only pre-output catch | ✅ Stop hook detects + logs to drift_log.md |
| 4 | New mechanics dumped | ✅ /teach skill works | ✅ Same |
| 5 | Drill-to-drill skip delta | ✅ /drill skill works | ✅ Same |
| 6 | Visuals batched at end | ❌ Stop dead | ✅ Stop hook detects + logs |
| 7 | Pulse-checks missed | ⚠️ /teach skill forces pulse phrases inside response (works); Stop post-check on non-/teach responses dead | ✅ Both layers fire |
| 8 | Companion mode performed | ✅ /companion skill is the gate | ✅ Same |
| 9 | Markdown on light Q | ❌ Stop dead | ✅ Stop hook detects + logs |
| 10 | Filler phrases | ❌ Stop dead. /self-review + /calibrate catch some pre-output (estimate 30-50% coverage) | ✅ Stop hook hard-fails on regex match (60-80% coverage) |
| 11 | Curriculum anchors skipped | ⚠️ CLAUDE.md instruction works; Stop verification dead | ✅ Both layers fire |
| 12 | Memory hooks inconsistent | ✅ /lock-decision skill works | ✅ Same |
| 13 | Drift correction not persistent | ❌ Without Stop, no drift_log entries from Cowork sessions. BUT: drift_log entries from claude.ai/code sessions DO appear in Cowork via CLAUDE.md @-import of `state/drift_log.md` | ✅ Stop hook writes; SessionStart reads |
| 14 | User mastery overridden | ⚠️ CLAUDE.md instruction works; no enforcement check | ⚠️ Same — semantic comparison is hard for hooks too |
| 15 | Over-apologized errors | ❌ Stop dead | ✅ Stop hook detects + logs |
| 16 | Re-Run reactive (the meta) | ❌ For the failures that are ❌ above, user IS still the enforcement layer in Cowork | ✅ Composite of all the above |

**Honest tally for Option Z (locked):**
- **Cowork (daily teaching):** 5 fully addressed, 3 partial, 8 lost. The 5 fully-addressed ones include the design's primary lever (#1 — deterministic context load → time-to-correct-mode → §I primary metric). The 8 lost ones are post-display drift detection, which matters most for sustained drill sessions; route those to claude.ai/code.
- **claude.ai/code (RTI drills):** 14 fully addressed, 2 partial (#7, #14), 0 lost.

**Sync point:** drift_log entries from claude.ai/code sessions appear in subsequent Cowork sessions via CLAUDE.md @-import. Cowork doesn't add to drift_log, but it reads it — meaning patterns flagged during RTI drills inform daily-teaching sessions. One-way flow, but better than no flow.

---

## E. Cloud routines (7)

All routines run on Anthropic-managed cloud per [code.claude.com/docs/en/web-scheduled-tasks](https://code.claude.com/docs/en/web-scheduled-tasks). Each clones the `~/study-companion/` Git repo (must be on GitHub or routine-accessible Git host), runs as a full Cowork session with the plugin loaded, edits files, commits to a `claude/<routine-name>-<date>` branch, opens a PR (or pushes direct to `main` if user configures auto-merge for trusted routines).

| # | Name | Schedule (cron, UTC unless noted) | Reads | Writes | Output target |
|---|---|---|---|---|---|
| 1 | `study-curriculum-sync` | `0 3 * * *` (08:30 IST, before morning briefing) | Pipeline repo at `~/claude_bootcamp/python_bootcamp_claude_code-main/config/`: `progress_state.xml`, `deviation_log.xml`, `rules.xml`, `scope_registry.xml`, active curriculum chunk per progress_state's `<active_files>`, `structure_current.xml` | `instructions/curriculum/` in study repo (overwrites — pipeline is authoritative) | Commit + push. **Reads from pipeline repo, never writes to it.** |
| 2 | `study-morning-briefing` | `15 3 * * *` (08:45 IST) | `state/current_day.md`, `state/active_weak_spots.md`, `state/last_session_summary.md`, `instructions/curriculum/progress_state.xml` (just-synced) | `state/schedule.md`, `logs/{date}.md` (header) | Commit + push. Optionally Dispatch a 1-line summary to user's phone |
| 3 | `study-spaced-rep-reminder` | `30 13 * * 1-6` (19:00 IST Mon-Sat) | `room-to-improve/state/current_state.md`, `state/active_weak_spots.md` | `state/spaced-rep-{date}.md` (today's recommended drill) | Dispatch message to user's phone with the drill prompt |
| 4 | `study-github-commit-reminder` | `0 15 * * 1-6` (20:30 IST Mon-Sat) | `git log --since=midnight` on `~/study-companion/` and any other repos user lists in `state/repos.md` | `logs/{date}.md` append "## Commit reminder" | Dispatch — only if zero commits today |
| 5 | `study-weekly-review` | `30 4 * * 0` (10:00 IST Sun) | All of last week's `logs/`, `wins/`, `state/drift_log.md` | `state/weekly-review-{date}.md` | Commit + Dispatch summary |
| 6 | `study-monday-distillation` | `30 3 * * 1` (09:00 IST Mon) | `logs/` files older than 7 days | `archive/completed_days/`, `state/distilled.md` | Compaction + commit. Removes raw logs from `logs/`, leaves index in `distilled.md` |
| 7 | `study-drift-audit` | `0 5 * * 0` (10:30 IST Sun, after weekly review) | `state/drift_log.md` last 7 days | `state/drift-audit-{date}.md` (frequency by failure #, top patterns, proposed teaching-method tightenings) | Commit + Dispatch executive summary |

**On Max 20x ($200/mo): 7 daily routines = 7 daily runs.** Daily cap on Max is ~15/day, so 8 spare slots/day for ad-hoc routines. Citation: [claudefa.st](https://claudefa.st/blog/guide/development/routines-guide). 

**Cross-surface commit reality:** routines run in Anthropic's cloud, write to `claude/<routine>-<date>` branches. Both Cowork and claude.ai/code interactive sessions also commit to the repo. State changes from any source (routine, Cowork session, claude.ai/code session) merge into `main` via standard Git flow; the next session of any surface pulls before reading state. Discipline note in §H Rule 11.

### Git authentication (verified 2026-05-06)

Cowork cloud routines authenticate against private GitHub repos via an **Anthropic-managed GitHub proxy**. Credentials never enter the routine sandbox. Per [code.claude.com/docs/en/claude-code-on-the-web](https://code.claude.com/docs/en/claude-code-on-the-web): *"the git client uses a scoped credential inside the sandbox, which the proxy verifies and translates to your actual GitHub authentication token… sensitive credentials such as git credentials or signing keys are never inside the sandbox."* Two supported paths:

| Path | Mechanism | When to pick |
|---|---|---|
| **Claude GitHub App** | Install at [github.com/apps/claude](https://github.com/apps/claude) on the target repo | **Required** for GitHub-event triggers and Auto-fix; per-repo authorization |
| **`/web-setup`** | Syncs your local `gh` CLI OAuth token to your claude.ai account | Solo dev already authenticated with `gh` |

`/schedule` accepts either; routines doc: *"`/schedule` checks for either form of access and prompts you to run `/web-setup` if neither is configured."* For routines that only need to push to `claude/`-prefixed branches (the default policy), either path suffices. Citation: [code.claude.com/docs/en/web-scheduled-tasks](https://code.claude.com/docs/en/web-scheduled-tasks).

**Branch policy:** push restricted to `claude/<branch>` by default. Quote: *"By default, Claude can only push to branches prefixed with `claude/`. This prevents routines from accidentally modifying protected or long-lived branches. To remove this restriction… enable Allow unrestricted branch pushes for that repository."* The `claude/<routine>-<date>` sub-pattern in §E is **inferred** — the platform enforces only the `claude/` prefix; the rest is observed routine behavior, not a documented contract. Open issue [#27403](https://github.com/anthropics/claude-code/issues/27403) tracks user requests for custom branch naming.

**Secrets caveat:** there is **no first-party secrets vault for routines** today. Per the docs: *"A dedicated secrets store is not yet available. Both environment variables and setup scripts are stored in the environment configuration, visible to anyone who can edit that environment."* Open issue [#32733](https://github.com/anthropics/claude-code/issues/32733). For the WHOOP routine specifically, this matters — see revised architecture below.

**No first-party shared storage primitive.** No object store, KV, or workspace persistence is documented. Each routine run starts with a fresh clone of the GitHub repo's default branch. Cowork "projects" are interactive-session-only and there is no documented routine-to-project handoff — Git is the supported channel for routine output. (Source: docs above + verification report.)

**Pre-flight checklist — must complete BEFORE the first routine run:**

1. **Plan tier:** Confirm Max 20x is active and "Claude Code on the web" is enabled at [claude.ai/settings/capabilities](https://claude.ai/settings/capabilities).
2. **Disable Zero Data Retention** on the org if enabled — ZDR orgs cannot use cloud sessions.
3. **Disable IP allowlist for Anthropic** if your org has it on, or every cloud session will 401.
4. **Create a private GitHub repo** for `~/study-companion/`. Verify it is private, not public.
5. **Install Claude GitHub App** on that repo (recommended): visit [github.com/apps/claude](https://github.com/apps/claude) → Configure → Only select repositories → pick the new repo. Required if you ever want GitHub-event triggers.
6. **Initial push from local:** `cd ~/study-companion && git init && git add . && git commit -m "initial" && git branch -M main && git remote add origin <repo-url> && git push -u origin main`.
7. **Verify the push succeeded** via the GitHub web UI — confirm `main` branch and folder structure match local.
8. **Open [claude.ai/code/routines](https://claude.ai/code/routines)** → New routine → confirm the repo appears in the picker. If not, GitHub App install didn't propagate; wait 1–2 min and retry.
9. **Branch policy decision per routine:** keep default (`claude/*` only) for the 7 routines in §E. Do NOT enable unrestricted branch pushes — the `claude/` prefix is the safety net.
10. **Run `study-morning-briefing` manually once** (`/schedule run study-morning-briefing`) to verify clone + edit + push works end-to-end. If it fails, do NOT enable scheduled execution — debug first.

### WHOOP — dropped (locked decision (d))

The original §E had a WHOOP-pull routine (#2) and a WHOOP-architecture-revised subsection. Both removed in this final pass per locked decision: WHOOP integration adds OAuth+atomic-write complexity for what turns out to be "occasionally interesting" recovery context for morning briefings, not load-bearing input. If recovery state matters in a given week, paste it manually into a session.

Trade accepted: lose automated recovery-aware morning briefings; gain zero new operational dependencies.

### Per-routine resilience (anti-OpenClaw-drift)
- Each routine starts with: read `state/SOURCE_OF_TRUTH.md`, verify expected files exist, freshness-check inputs.
- On any input older than expected (e.g., a state file from yesterday that should have been refreshed by a prior routine), routine writes a `[STALE]` flag to its output and emits a Dispatch alert — does not fabricate.
- Cross-routine ordering: routine #1 (curriculum-sync) runs at 08:30 IST so routine #2 (morning-briefing) at 08:45 reads fresh curriculum state. If #1 fails, #2 must detect the staleness and Dispatch-alert rather than briefing on stale curriculum.

---

## F. State-file schemas

### `state/current_day.md`

```yaml
---
last_updated: 2026-05-06T08:45:00+05:30
updated_by: study-morning-briefing
phase: 1
week: 4
day: 16
block: 2
status: in_progress  # in_progress | completed | paused
paused_reason: ""    # populated only when status=paused
---

## Today
**Topic:** Loop Week Day 3 — Strings & Variable-Width Shapes
**Block plan:**
- Block A (1.5h): String slicing review + edge cases
- Block B (1.5h): Variable-width grids (right-triangle, diamond)
- Block C (2h): Combined drills (Band 2)

## Yesterday (2026-05-05)
**Completed:** Loop Week Day 2 dicts/sets, scope-map locked
**Unresolved:** None

## Last 3 days summary
2026-05-03: Day 1 lists ✅ 7/8 traces clean
2026-05-04: Loop Week prep, scope maps Day 1-3 created
2026-05-05: Day 2 dicts/sets ✅ 4/5 + 3/3
```

**Update protocol:**
- Morning briefing routine writes `last_updated`, header, today's block plan.
- `/day-wrap` writes "Yesterday" and "Last 3 days" sections at end of each day.
- User can edit manually; freshness still enforced.

### `state/active_weak_spots.md`

```yaml
---
last_updated: 2026-05-06T20:15:00+05:30
updated_by: /post-session
total_active: 3
---

## Active (priority order — top is dominant)

### A1 — Multi-step loop body (one-step transform not automatic)
- **First seen:** 2026-04-08
- **Last seen:** 2026-04-09
- **Pattern:** "Recursive shell visible, one-step transform not automatic"
- **Band:** 2 (escalated — 6× same bug in same session)
- **Reps to graduate:** 3 independent at Band 2, then 1 at Band 3
- **Reps so far:** 1 independent (2026-04-09 sum_of_digits)
- **Drill targets:** count_vowels (Band 2 A1), list_max (Band 2 A1)

### B2 — Bail-to-AI (improving)
- **First seen:** 2026-04-07
- **Last seen:** 2026-04-08
- **Pattern:** "idk before meaningful attempt — execution avoidance"
- **Band:** 2 watch (improving — last 2 sessions tactical-help-only, not blunt handoff)
- **Reps to graduate:** 5 sessions with no bail
- **Reps so far:** 2 clean

### F3 — Operator confusion
- **First seen:** 2026-04-08
- **Last seen:** 2026-04-08
- **Pattern:** "or vs and on base case condition"
- **Band:** 2 watch (one-off)
- **Drill targets:** any base-case-heavy recursion drill
```

**Update protocol:**
- `/post-session` writes after every session.
- `/lock-weak-spot` appends new ones.
- Drift-audit routine cross-references with `drift_log.md`.

### `state/drift_log.md` (APPEND-ONLY)

```
2026-05-06T11:32:15+05:30 | session=abc123 | failure=#10 | severity=hard | detail="response ended with 'Hope this helps!'"
2026-05-06T11:45:02+05:30 | session=abc123 | failure=#3  | severity=soft | detail="2 distinct analogies in same explanation: 'imagine a backpack' AND 'think of it as a recipe card' (concept: closures)"
2026-05-06T12:01:43+05:30 | session=abc123 | failure=#7  | severity=soft | detail="substantive teaching response (820 words) without pulse phrase"
2026-05-06T12:15:30+05:30 | session=abc123 | failure=#11 | severity=soft | detail="first substantive response missing [Day N] anchor"
```

**Schema:** `ISO timestamp | session_id | failure=#N | severity=hard|soft | detail="..."`

**Severity:**
- `hard`: regex match on banned phrase / explicit rule violation. Always logged.
- `soft`: heuristic match (e.g., visuals batched). May have false positives.

**Update protocol:** Stop hook appends. Never edited. Drift-audit routine reads but doesn't modify. Monday distillation moves entries >30 days old to `archive/`.

### `state/last_session_summary.md` (overwritten each session, not appended)

```yaml
---
last_updated: 2026-05-06T20:15:00+05:30
session_id: abc123
session_duration_min: 87
---

## What landed
- {bullet}
- {bullet}

## What didn't land or got paused
- {bullet}

## Tomorrow's first task
{specific, not "review notes"}

## Energy state
{1-5}

## Drift this session
- {failure #} × {count}: {1-line detail}
```

### `room-to-improve/state/current_state.md`

Port verbatim from `openclaw_setup/room-to-improve/room-to-improve-architecture/state/current_state.md`. Schema:

```yaml
---
last_updated: 2026-05-06T20:15:00+05:30
phase: 1
rollout_day: 7
latest_session: 2026-05-06.md
independence_score: 2
active_targets: [A1, B2, F3]
escalated_bugs: ["A1 repeated 6× in same session, Day 15 Block 3"]
band_status:
  A1: escalated-band-2
  B2: watch
  F3: watch
---

[narrative section, 200-400 words, last session results + tomorrow's targets]
```

### `wins/{date}-{slug}.md`

```yaml
---
date: 2026-04-15
concept: closures
trigger: "User said 'I keep losing where the variable went' — domain mismatch with abstract LEGB rules"
test: "If I had given LEGB rules first, they'd have memorized but not internalized — would have failed Block 3 problem"
artifact: "Closures = barista with recipe card in pocket. The function carries its environment."
---

[full transcript or excerpt, 200-500 words]
```

---

## G. Port plan from `openclaw_setup/`

### Seed wins from MEMORY.md (NEW, day-1 calibration set)

Five named analogies in `~/personal/MEMORY.md` (out of grant) landed during prior bootcamp work. On day 1 of build, create these as seed files in `wins/`. The wins library starts non-empty so the new `/teach-from-win` skill (§B) and `/self-review` calibration check have something to read on day 1, instead of an empty folder + accumulating-from-zero startup curve.

Use the **revised** /lock-decision schema (per Revision 2: `user_precondition` not `trigger`, plus `concept_gap`):

| File path | concept | concept_gap (best inference) | artifact |
|---|---|---|---|
| `wins/2026-03-22-closures-barista-recipe-card.md` | closures | abstract environment-capture vs concrete carry-something-along | "Closures = barista with recipe card in pocket. The function carries its environment." |
| `wins/2026-03-22-factory-locked-machine.md` | factory functions | factory-as-pattern (abstract) vs factory-as-thing-with-locked-settings (concrete) | "Factory = machine with locked settings. Each call produces a configured worker." |
| `wins/2026-03-22-backpack-captured-vars.md` | closure variable capture | "what does a closure carry" vs LEGB rules | "Backpack = closure's captured variables. The function brings its scope along." |
| `wins/2026-03-22-legb-room-search.md` | LEGB scope rule | name resolution as algorithm vs LEGB as room search | "LEGB = searching rooms innermost to outermost: Local → Enclosing → Global → Built-in." |
| `wins/2026-03-22-nonlocal-old-house.md` | nonlocal keyword | which scope nonlocal targets | "nonlocal = 'I mean the OLD house' (the enclosing scope, not global, not local)." |

For all 5 seed files:
- `user_precondition`: `"historical — original confusion context not preserved in MEMORY.md; future captures will be higher fidelity per revised schema."`
- `test`: `"If [definition-first/abstract] approach had been used instead, would have memorized but not internalized — works in toy cases, breaks at first novel application."`
- Body: 1-2 paragraphs reproducing the analogy in usable form. Do NOT fabricate Sudhan's confusion verbatim — admit historical loss in the precondition field.

**Calibration usage:** /self-review checks "did I make a move of THIS KIND?" against these 5. /teach-from-win uses them as kind-of-move templates (mechanism-matched, one-analogy, concrete bridge to abstract concept) when teaching new concepts. They are NOT for reuse — if a new closures question comes up, generate fresh against the new precondition; the seed win is a quality bar, not a script. (See §J #13 artifact-vs-generator residual.)

### Carry over verbatim (port to `instructions/`)

| Source | Target | Why verbatim |
|---|---|---|
| `bootcamp/loop-week/teaching_method_locked.md` | `instructions/teaching-method.md` | The 5 locked rules are the spine of this whole design; one of the few documents proven to work |
| `room-to-improve/room-to-improve-architecture/ROOM_TO_IMPROVE_MVP.md` | `instructions/rti-method.md` | 6 families, 4 bands, 3 non-negotiables — empirically validated on 9 days of real RTI evidence |
| `room-to-improve/room-to-improve-architecture/pattern_to_drill_map.md` | `drills/templates/pattern_to_drill_map.md` | Canonical drill skeletons per pattern |
| `room-to-improve/room-to-improve-architecture/drill_decision_tree.md` | `drills/templates/decision_tree.md` | Q1-Q4 flowchart for tomorrow's drills |
| `room-to-improve/room-to-improve-architecture/post_session_template.md` | `/post-session` skill body | Forces structure |
| `room-to-improve/room-to-improve-architecture/state/current_state.md` | `room-to-improve/state/current_state.md` | RTI live state — the most recent file there is the seed |

### Curriculum XMLs — REVISED post-second-pass (2026-05-06)

The user pointed to a richer location: `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\`. This is the **bootcamp pipeline repo** (a 5-pass package-generator project), distinct from the study companion. Files there are dramatically more current than the openclaw snapshot:

| Source file (pipeline repo) | Version / last-updated | Content highlights |
|---|---|---|
| `progress_state.xml` | v2.4, 2026-04-16 | `<completed_through_day>21</completed_through_day>` — **Phase 1 complete, Phase 2 active** (Days 22-42). Active files: structure_phase2.xml, curriculum_weeks04-06.xml |
| `deviation_log.xml` | v2.4 | Phase 1 `scope_additions` block fully populated (16 concept categories: data_types, operators, string_methods, control_flow, lists, tuples, dicts, sets, collections, functions, comprehensions/generators, file I/O, error handling, modules, stdlib, OOP, dunders, recursion, numpy, pandas). 6 SD entries (SD-001 cognitive-science practice volume; SD-002–005 Phase 2 review-day and standard-day gate adjustments; SD-006 Day 23 LeetCode hardcoded URLs). DC-001/002/003 all PLACED |
| `rules.xml` | v2.5 | Cardinal rules + `<verifier_note>` describing runtime registries (SCOPE_BY_DAY, etc.). Rule 1 scope-purity, Rule 6 missing-file STOP protocol |
| `scope_registry.xml` | (not yet read) | **Explicit scope registry** the openclaw snapshot didn't have. Likely consumed by the verifier |
| `curriculum_manifest.xml` | — | Static registry of curriculum chunks |
| `curriculum_weeks01-03.xml` | — | Phase 1 spec |
| `curriculum_weeks04-06.xml` | — | Phase 2 spec, currently active |
| `structure_current.xml` | — | Loaded as Phase 2 structure |
| `structure_phase2.xml` | — | Phase 2 structure template |
| `quality_gates.xml` | — | 15 gate definitions for the verifier |
| `transition_map.xml` | — | Phase transition protocol |
| `transition_briefs/T1_weeks04-06.md` | — | T1 transition (Phase 1→2) brief |

**Architectural decision:** the study companion does **NOT fork these files**. The pipeline repo is the source of truth; the study companion subscribes to it via a scheduled sync routine. Reasons:
- The pipeline already has a working CLAUDE.md, verifier (`scripts/verify_package.py`), and 5-pass generation flow that updates progress_state.xml at every checkpoint.
- Forking would create the same drift problem the openclaw snapshot suffered (4 stale copies of "current bootcamp day").
- The study companion only needs to *read* curriculum scope, not maintain it.

**New routine added to §E:** `study-curriculum-sync` (daily). Pulls the pipeline repo, copies the active curriculum subset into `instructions/curriculum/`. Concretely: `progress_state.xml`, `deviation_log.xml`, `rules.xml`, `scope_registry.xml`, plus the active curriculum chunk per progress_state.xml's `<active_files>` (currently `curriculum_weeks04-06.xml`) and active structure (`structure_current.xml`). Total ~6 files synced daily. Drops `transition_map.xml` and `transition_briefs/` (one-time references; copied manually if needed) and `quality_gates.xml` (verifier-only, not relevant to study companion).

### Adapt (rewrite for new context)

| Source | Target | Adaptation |
|---|---|---|
| `config/IDENTITY.md` + `config/SOUL.md` | `instructions/identity.md` | Combine. Keep: name (Asta), vibe, banned-AI-disclaimers, banned filler openers. Drop: nothing important. |
| `config/AGENTS.md` (~400 lines) | `CLAUDE.md` (~150 lines) | Keep: teaching-method imports, memory protocol, banned phrases, "Lock it in" trigger phrases, /rti-preflight rule. **Drop:** Discord SDK rules, cross-channel notification protocol, target= vs channel= note, asta-mem CLI commands, Discord guild IDs. |
| `config/BOOT.md` | `hooks/session-start.js` logic | The "silently search asta-mem at boot" pattern becomes "silently read state/ files and inject". No Discord polling. |
| `config/RELEVANCE.md` | drop | Cross-channel surfacing makes no sense without channels. |
| `config/USER.md` | `instructions/identity.md` (Sudhan section) | Strip outdated bootcamp-day numbers (file says Day 5, reality is Day 16). Keep: name, location, timezone, target, anime/F1 trivia. |
| `config/TOOLS.md` | drop / partial reference in `README.md` | asta-mem commands gone. Discord channel IDs gone. Keep nothing critical. |
| `bootcamp/loop-bootcamp-strategy.txt` | `instructions/loop-strategy.md` | The 4-phase plan (trace drills → input-first → English-first → cold-solve) is still valid. Port verbatim. |
| `whoop/pull_data.sh` (hardened bash) | `study-whoop-pull` cloud routine (Python in agentic session) | Patterns that translate: lockfile (Git branch claim), retries on 429/5xx, atomic writes, `.last_health.json`, partial-write flag. Patterns that don't: `set -euo pipefail` (LLM session is not a shell). Add explicit error handling in routine prompt. |

### Drop entirely

| Source | Why dropped |
|---|---|
| `mantis-listener` references | No Discord listener |
| `asta-sync daemon` and `memory/sync/*` files | Replaced by Git + cloud routines |
| `asta-mem` CLI commands and `*.db` references | Folder-resident files; FTS5 not needed at Sudhan-scale |
| Per-channel routing | No channels |
| `docs/diagnostics/` (the discord_core audit) | Historical post-mortem; reference only, not active |
| `docs/guides/BOOTCAMP-SERVER-GUIDE.txt`, `GYM-SERVER-GUIDE.txt` | Discord server guides |
| `docs/prompts/daddy-*.txt` | One-time migration prompts |
| The 8 zero-byte note files | Cruft |
| `MEMORY.md` (curated long-term) | Personal/PII content; lives in `~/personal/`, not granted |
| `archive/personal/` | PII, lives outside grant |
| `bootcamp/python-bootcamp/python_claude_bootcamp/Python/architecture/*.xml` | Curriculum-architecture XMLs are referenced (`progress_state.xml`, `deviation_log.xml`) but the snapshot doesn't contain them; without those, the scope-purity rule can't be derived. **If Sudhan still has these somewhere, port them. If not, scope-purity becomes a softer rule: "concepts not yet covered in completed bootcamp days."** |

### "Lock it in" trigger phrases (adapt)

OpenClaw's `AGENTS.md` defined trigger phrases that wrote to BOTH hot-cache and asta-memory immediately: "Asta, note this", "Remember this", "Lock it in", "Mark it" → respond "Locked ✅".

In Cowork:
- UserPromptSubmit hook detects: `/(lock it in\|mark it\|remember this\|note this)/i`
- Injects: invoke `/lock-decision` skill with the prior conversation turn as the trigger source
- Claude responds "Locked ✅" after the skill writes to `wins/`

This is a high-value port — it's a deterministic capture trigger Sudhan already has muscle memory for.

### `rules.xml` scope-purity rule

Port the spirit, not the XML. Target file: `instructions/scope-purity.md`.

```markdown
# Scope Purity (Rule 6 from rules.xml)

If a concept hasn't been covered in completed bootcamp days, it doesn't exist in this session.

**Allowed:** Concepts from completed bootcamp days (per state/current_day.md "completed_days" registry — port from progress_state.xml if available, else day-by-day catch-up sheet).

**Read-only allowed:** A pre-registered concept may be SHOWN as a future preview, but not used in exercises, asserts, or solution hints.

**Forbidden:** Using out-of-scope concepts in any:
- Exercise prompt
- Assertion
- Solution hint
- "Just use library X" advice

**Scope test before any drill:** "Could Sudhan write this using ONLY concepts from completed days + today's concepts?" If no → remove that part of the drill.

**Fail closed.** When in doubt, narrow the scope.
```

The deviation_log.xml mechanism (logging when out-of-scope concepts get introduced via guided exercise) is not ported — overkill for a self-running design. If it becomes needed, add a `state/scope-deviations.md` append-only log later.

---

## H. Failure-mode design (anti-OpenClaw-drift)

The original OpenClaw cataloged 9 overlapping state files, contradictory bootcamp day across 4 sources, naming collisions, ghost cron entries, etc. (See openclaw_setup/docs/diagnostics/discord_core_flaw_audit.md.) This design's anti-drift rules:

### Rule 1 — Single source of truth per fact (registry-enforced)

`state/SOURCE_OF_TRUTH.md` is the registry. Each fact has exactly ONE writer file. SessionStart hook reads the registry and verifies all listed files exist. If a non-registered state file appears, hook flags it.

### Rule 2 — Mandatory freshness stamps on every state file

Every `.md` file in `state/`, `room-to-improve/state/`, and `whoop/` has YAML frontmatter with `last_updated: <ISO timestamp>` and `updated_by: <writer name>`. The SessionStart hook treats files >24h old as suspect and prepends a `⚠️ STALE` warning. Files >72h old refuse to inject without an explicit user override.

### Rule 3 — No naming collisions

- All cloud routines prefixed `study-` (`study-morning-briefing`, `study-whoop-pull`, etc.).
- All skills are plugin-namespaced (`study-companion:teach` is the fully qualified name).
- No bash-script-vs-systemd-unit ambiguity (no bash scripts; everything is in routines or hook handlers).

### Rule 4 — One-way data flow per fact

| Fact | Writer | Readers (no writes) |
|---|---|---|
| WHOOP daily summary | `study-whoop-pull` routine | morning-briefing routine, SessionStart hook |
| Drift events | Stop hook | SessionStart hook, drift-audit routine |
| Active weak spots | `/post-session`, `/lock-weak-spot` | SessionStart hook, drill routines |
| Current day | morning-briefing routine, `/day-wrap` | SessionStart hook |

A reader never modifies state it consumes. Cross-routine writes go through a documented chain (e.g., morning-briefing READS WHOOP summary, never edits it).

### Rule 5 — Append-only logs (compacted by routine, not user)

`drift_log.md`, `logs/{date}.md`, `logs/sessions/*.md` — append-only. The Monday distillation routine is the *only* process that moves entries from `logs/` to `archive/completed_days/`, with a documented compaction log.

### Rule 6 — Atomic state writes

When a writer updates a state file:
1. Write to `<file>.tmp` in the same directory
2. `git add` the tmp file (acts as crash-safe staging)
3. `mv <file>.tmp <file>` (atomic on POSIX, atomic-equivalent on NTFS via `MoveFileEx`)
4. Commit

If the routine crashes mid-update, the live file is unchanged. Port from `pull_data.sh`'s `mktemp + os.replace()` pattern.

### Rule 7 — SessionStart hook is the auditor

Every session start, the hook:
1. Reads `state/SOURCE_OF_TRUTH.md` registry
2. Verifies each registered file exists
3. Reads each file's `last_updated` and computes age
4. Flags any file >24h stale, any file present-but-not-registered, any file registered-but-missing
5. Injects warnings BEFORE the state content

The hook is the auditor, not the user.

### Rule 8 — State files are source of truth, not prior turns

Same rule MEMORY.md had ("trust asta-memory over MEMORY.md"). When the conversation context conflicts with state files, state wins. Claude's instructions: "Before answering questions about current state, read the state file. Don't recall from prior turns; the state file may have been updated by a routine while you weren't looking."

### Rule 9 — Cloud routine commits are atomic and reversible

Each routine commits to its own branch (`claude/study-morning-briefing-2026-05-06`). User can review and merge or revert. No routine pushes directly to `main` unless the user explicitly opts in for that routine after observing it for 2 weeks.

### Rule 10 — Compaction-resilient state

PreCompact hook snapshots all state file *paths* (not content) into `state/.compact-state-pending.json`. PostCompact hook re-reads those files (which haven't changed during compaction) and re-injects them via additionalContext. This recreates the SessionStart deterministic load mid-conversation, preventing the "post-compaction memory hole" the OpenClaw sync-compact-recovery hook was designed to address. **claude.ai/code only** under Option Z; in Cowork, compaction loses the in-conversation memory of state but the next CLAUDE.md @-import on next session restores the file load.

### Rule 11 — Cross-surface state sync (commit-between-switches discipline)

Under Option Z, the same Git repo is read/written by Cowork interactive sessions, claude.ai/code interactive sessions, and 7 cloud routines. Git is the only sync channel.

**Discipline:**
1. **Before switching surfaces, commit.** If you're working in Cowork and want to open claude.ai/code, commit pending changes first. claude.ai/code clones from `main` (or your configured default branch) on session start — it can't see uncommitted Cowork changes.
2. **After a routine commits to a `claude/` branch, merge or review before next interactive session.** Routines push to `claude/<routine>-<date>`; main moves only when user (or auto-merge config) merges. If `state/active_weak_spots.md` was updated by `/post-session` in a claude.ai/code RTI session, that update is on a `claude/` branch until merged. Cowork won't see it on next session unless merged.
3. **On surface open, pull first.** SessionStart hook (claude.ai/code) and a small wrapper in CLAUDE.md (Cowork) should remind: "Last commit on main was N hours ago. Last routine push was M hours ago. Pull recommended."
4. **Conflict resolution: standard Git merge.** If both surfaces edited `state/active_weak_spots.md` on different branches, manual merge. Risk is low — most state files have single writers per §F's one-way data flow rule. The exception is `wins/`, which both surfaces can write to via `/lock-decision`.
5. **Routine writes go to dedicated branches always.** Never auto-merge a routine to `main` until that routine has run unattended for 2 weeks without producing a `[STALE]` or fabrication issue.

**The honest residual:** if Sudhan forgets to commit between surface switches, work is lost. Mitigation: a small script (`bin/study-switch.sh` or equivalent) that does `git add -A && git commit -m "checkpoint: switching surface" && git push` could automate this, but is build-time work, not design-time. Documented as risk #14 (Git operational complexity) in §J.

---

## I. First-session validation protocol

The user's principle: "the first three sessions are the audit." Concrete checklist:

### Session 1 — System loads correctly

| Check | Pass criterion | Failure → action |
|---|---|---|
| SessionStart hook fires | `logs/sessions/{date}-{time}.md` exists with timestamp ≤ session start time | Hook not installed or not registered. Re-check `~/.claude/plugins/study-companion/hooks/hooks.json` and Cowork plugin install. |
| Folder grant works | Claude can `Read` files from `~/study-companion/instructions/teaching-method.md` | Folder not granted, or wrong path. Re-grant via Cowork → Add Folder. |
| Context appears in first response | Claude's first substantive response references `[Day N • Phase P • Block B]` from `state/current_day.md` | additionalContext not being injected. Check hook handler logs. |
| `/teach` skill invocable | Type `/teach closures` — Claude routes through skill template, produces Layer 1 → pulse → Layer 2 structure | Skill not loaded. Verify `~/.claude/plugins/study-companion/skills/teach/SKILL.md` exists with valid frontmatter. |
| `/lock-decision` writes to wins/ | After a deliberate "lock it in" trigger, `wins/{date}-<slug>.md` exists with all 4 frontmatter fields populated | Skill template not enforcing structure. Tighten template. |
| Banned phrase detection | Force Claude to say "Hope this helps" (request a casual Q&A). Verify `state/drift_log.md` got an entry tagged `failure=#10 severity=hard` | Stop hook not firing or regex broken. Test handler in isolation. |

### Session 2 — Drift detection and persistence work

| Check | Pass criterion | Failure → action |
|---|---|---|
| Substantive teaching session detected | Run a 30-min teaching block on a topic with known prior drift (decorators, recursion). Stop hook logs ≥0 entries — flagged drift if any | Stop hook silent on a session known to have drift = detection broken. |
| Confusion trigger detected at input | Type "I'm still confused" mid-explanation. Claude's next response opens with "Let me re-angle:" or equivalent (NOT "Let me try slower") | UserPromptSubmit context injection too weak. Restructure as system message or escalate severity. |
| Drift log persists | Open new session. Verify SessionStart includes a "Recent drift this week" section in injected context referencing yesterday's `drift_log.md` entries | SessionStart not reading drift_log. Bug in handler. |
| `/self-review` reduces drift | Run two parallel 200-word teaching responses, one with `/self-review` invoked, one without. Compare drift_log entries. | If `/self-review` doesn't reduce drift, the meta-skill prompt is too weak. Tighten the checklist. |
| `/post-session` updates active_weak_spots correctly | Run a drill where A1 fires twice. `/post-session` should append to `active_weak_spots.md` with band-2 escalation flag | `/post-session` template missing the escalation rule. |

### Session 3 — Real-world workflow

| Check | Pass criterion | Failure → action |
|---|---|---|
| Full RTI drill session end-to-end | `/rti-preflight` → 4 drills → `/post-session` → `state/active_weak_spots.md` updated → next-day morning routine reads updated state | Any handoff break = audit which file/skill failed. |
| Cloud routine smoke test | Run `study-morning-briefing` manually via `/schedule run`. Verify `state/schedule.md` updated and committed to a `claude/` branch | Routine doesn't have folder access (cloud sandbox issue), doesn't have Git push perms, or prompt malformed. |
| WHOOP routine integration | Run `study-whoop-pull` manually. Verify `whoop/{date}.json` and `whoop/daily_summary.md` written, `.last_health.json` shows OK | OAuth secret not in routine config; or WHOOP API change; check `.last_health.json` for FAIL detail. |
| Same-week drift reduction | Compare drift_log entries from session 1 vs session 3 (similar duration/topic). If session 3 has ≥30% fewer flagged failures, system is working. | If drift count is flat or higher, the design's claim of "70% reduction" is invalidated. Re-evaluate. |

### Primary metric — time to correct teaching mode

The user's actual cost in Claude.ai sessions is **40-50 minutes per session** spent priming Claude into the right teaching mode (slow ladder, inline viz, one analogy, identity loaded) before any actual studying happens. Once primed, study takes 10-15 minutes. So 75-80% of session time today is lost to priming, not learning. **This is the user's #1 pain.** The drift count metric (the prior version of §I) was the wrong primary signal.

**Primary success metric — first-response-in-correct-mode time:**

Measured as: minutes elapsed from session-open to the first Claude response that demonstrably operates in correct teaching mode. "Correct teaching mode" is operationally defined as the response simultaneously exhibiting:
- One mechanism-matched analogy (not stacked)
- Inline visualization (not batched at end)
- Identity-locked voice (no "Great question!", no "as an AI...")
- Curriculum anchor present (`[Phase P • Day D • Block B]` or equivalent) for substantive teaching responses
- For multi-layer responses: at least one pulse-check phrase ("Tracking?", "Click?", "With me?")

**Target: <5 minutes consistently across sessions 3–7.**
**Baseline: 40-50 minutes (Sudhan's own report from Claude.ai sessions).**
**Mechanism: deterministic SessionStart context-load via CLAUDE.md @-imports + folder instructions auto-load. This is unaffected by hook bug #40495 — both Cowork and claude.ai/code surfaces benefit equally** (per §D ranking #1: Strongest layer).

If first-response-in-correct-mode is **NOT achieved by session 3**, the design has failed at its primary purpose and a redesign is needed. Drift count residuals (the secondary metric below) do not save the design if the primary metric is missed.

### Secondary metric — drift count over time (was the primary in prior version)

Coordinator concern #4 correctly flagged that the "~70% drift reduction" estimate had no evidence base. Demoting drift to secondary and replacing percentage prediction with a measurement protocol.

**What we measure (per session, deterministic):**
- `drift_log.md` entry count, broken down by failure number (#1–#16) and severity (hard | soft)
- `drift_log.md` entries per substantive minute of session (normalize for session length)
- Total session word count of substantive responses (denominator for normalization)
- Number of times user fired manual Re-Run / "do that again" / re-prompted

**Baseline window:** sessions 1–2 establish the per-session-minute drift rate. These are *audit* sessions, not target sessions. Don't claim success or failure based on them.

**Trend window:** sessions 3–7 are evaluated against the session-1–2 baseline:
- Per-failure-number drift count, week 1 vs week 2 vs week 3
- Per-substantive-minute drift rate, smoothed over 3-session rolling window

**Drift success criterion:** monotonically declining or stable-below-baseline drift rate over 3 consecutive sessions, AND no individual failure number reappearing in 3+ consecutive sessions after one logging cycle. **No specific percentage target** — empirical, not predicted.

**Confound to watch:** Stop hook fires only on claude.ai/code under Option Z; Cowork sessions don't add to drift_log. Drift measurement is therefore partial in Cowork — only #1, #4, #5, #7, #8, #11, #12, #14 are observable via Cowork-side logs. RTI sessions on claude.ai/code provide full drift coverage. Plan to evaluate drift trend primarily from claude.ai/code session logs.

### Tertiary metric — routine reliability

- Routines commit on schedule, no `[STALE]` flags in first 7 days
- No silent failures (every failed run produces a Dispatch alert)
- Curriculum-sync routine successfully mirrors pipeline repo every morning

### What proves the plan is working

In priority order:

1. **Time-to-correct-mode <5 minutes by session 3** — primary success signal. If achieved, the user's #1 pain is solved regardless of drift residuals.
2. **Drift rate at session 7 below the session-1–2 baseline AND stable** (claude.ai/code sessions) — secondary; tracks within-response quality.
3. **Specific failures that recurred early stop recurring** after 1–2 logging cycles.
4. **Sudhan completes a 90-min study session without manually firing Re-Run.**
5. `/lock-decision` (revised schema) captures clean user_precondition+concept_gap+test+artifact in ≤2 turns.
6. Cloud routines run on schedule, commit successfully, no `[STALE]` flags after first 7 days.

### What proves the plan is failing

In priority order:

1. **Time-to-correct-mode still >15 minutes by session 3.** Primary metric missed. Redesign needed regardless of drift status.
2. Drift rate flat or rising at session 7 (relative to baseline).
3. Same failure number in 3+ consecutive sessions after ≥2 logging cycles.
4. User editing state files manually >2x/week (auto-update broken).
5. /teach skill produces responses indistinguishable from un-templated teaching (template too weak).
6. Cloud routines fail silently (no Dispatch alert).

### Don't claim success on session 1

The system *loading* is not the system *working*. Claim success only after the measurement window (sessions 3–7) shows the **time-to-correct-mode primary criterion** AND a routine has run unattended for ≥7 days. The drift secondary criterion is informative but not pass/fail on its own — the user's stated cost is priming-time, not within-response polish.

---

## J. Risk register — what this design WON'T solve

These are the honest unsolved residuals. Don't soften.

### 1. Output enforcement at generation time (the Gap-1 wall)

**Problem:** Stop hook fires *after* Claude's response is displayed to the user. There is no Cowork mechanism to reject "Hope this helps!" before the user reads it. **No rule in this design rejects output at generation time.**

**Mitigations in this design:**
- Deterministic SessionStart context load (eliminates retrieval lottery)
- /self-review skill called pre-output for substantive responses (self-applied)
- Stop hook detection + drift_log persistence + next-session injection (asynchronous correction)
- UserPromptSubmit context injection for confusion triggers (input-time, before generation)

**Compliance:** measured, not predicted. Per the §I measurement protocol (replacing the prior "~70% reduction" guess that had no evidence base), the design's effectiveness is empirical — observe the per-substantive-minute drift rate over sessions 1–7, evaluate trend vs baseline. **Do not claim a specific percentage in advance.** The remaining drift after the design takes effect is the architectural gap; the size of that gap will only be known after measurement.

#### Confirmed instance (2026-05-06): trigger-phrase-driven skill auto-invocation in Cowork

User reported that typing "lock it in" in Cowork after a teaching response did NOT invoke `study-companion:lock-decision`; it was interpreted as drill-acceptance. Explicit `/study-companion:lock-decision` worked fine.

**Investigation outcome:** This is a confirmed instance of §J #1 + §J #12 (Cowork hooks dormant per #40495). Anthropic's own plugin and skill reference docs ([code.claude.com/docs/en/plugins](https://code.claude.com/docs/en/plugins), [/skills](https://code.claude.com/docs/en/skills)) confirm:

1. Skill auto-invocation is a model-judgment decision based on `description` and `when_to_use` text. It is NOT a deterministic input-layer match.
2. SKILL.md frontmatter has no regex/pattern field for input matching. Closed list of fields: `name`, `description`, `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `model`, `effort`, `context`, `agent`, `hooks`, `paths` (FILE globs only), `shell`. The `paths` field matches files, not user input.
3. `plugin.json` manifest has no input-trigger field.
4. Plugin can register `skills/`, `agents/`, `commands/`, `hooks/`, `monitors/`, `.mcp.json`, `.lsp.json`, `bin/`, `settings.json`. None of these intercept user input outside the hooks system. (`monitors/` tails outbound streams; doesn't read user prompts.)
5. Anthropic's own troubleshooting page for "skill not triggering" ends with: *"Strengthen the skill's description and instructions so the model keeps preferring it, **or use hooks to enforce behavior deterministically**."* The "or" confirms hooks are the only deterministic mechanism.

**Generalization:** the failure mode is "trigger phrase has dominant conversational alternative interpretation in current context." The model picks the dominant prior; the skill description loses. This affects:
- "lock it in" → drill-acceptance after a teaching turn (CONFIRMED FAILURE)
- "wrap up" → casual sign-off vs `/day-wrap` (LIKELY)
- "be a companion" → could be metaphorical use vs `/companion` (UNLIKELY but possible)
- Confusion signals ("I don't get it", "huh?") → semantic content is unambiguous; should route reliably without intervention. If not, that's a different failure (skill description tuning).

**Mitigation applied (2026-05-06):** dual-track trigger system added to each skill that has a routed natural-phrase trigger:

- Each affected skill now has a colon-prefix deterministic token in its `when_to_use`: `/lock-decision` accepts `:lock`, `/companion` accepts `:companion`, `/day-wrap` accepts `:wrap`. Tokens have no conversational meaning, so the model has nothing else to route them to.
- Natural phrases retained — they remain the default; users only fall back to the token when the natural phrase loses.
- `instructions/trigger-phrases.md` updated to document the convention and explain why the two tracks exist.

**This mitigation does NOT eliminate the residual.** What it does:
- Gives Sudhan a deterministic-enough fallback when natural-phrase routing fails.
- Costs a habit change (Sudhan must remember the tokens for the failure cases).
- Does not help on first natural-phrase attempt — still self-applied at output.

**This residual is fully eliminated only when #40495 lands** and Cowork can fire UserPromptSubmit hooks against the regex documented in `instructions/trigger-phrases.md`. Until then, the dual-track system is the best Cowork can offer per Anthropic's own documented limits.

**Sudhan-side discipline:** if a natural phrase fails twice in a row on the same trigger after a teaching turn, switch to the token for the rest of that session. Don't argue with the model layer.

### 2. Detection regex is heuristic, not semantic

"Hope this helps" is easy. "Stacked analogies" is hard — distinguishing one analogy phrased twice ("imagine a backpack" + "think of it as a backpack") from two distinct analogies needs NLP, not regex. Coverage will be partial. False positives and negatives both expected. **Don't trust drift_log as ground truth — review periodically.**

### 3. /lock-decision content quality depends on Claude introspection

The capture is deterministic (file gets written). The *content* of "what made this analogy work" is Claude generating prose about its own choice — same model-introspection limit Claude.ai has. Some wins captured will be hollow. Pin the genuinely good ones manually.

### 4. PromptArmor Files-API exfiltration vuln remains technically unmitigated

PII excluded from grant mitigates blast radius (no sleep-summary or diet-plan reachable), not the vector itself. **Risks accepted by this design:**
- A malicious markdown in `~/study-companion/` could still exfiltrate other study-companion files via the Anthropic Files API allowlist
- WHOOP JSON contains fitness PII — heart rate, sleep, weight — which a prompt injection could exfiltrate

**Mitigation guidance for the user:**
- Don't paste content from untrusted sources (web pages, third-party MCP outputs) into the granted folder
- Don't connect a Discord MCP or any internet-side MCP to this Cowork install
- Periodically audit `whoop/` for unexpected files
- Citation: [promptarmor.com/resources/claude-cowork-exfiltrates-files](https://www.promptarmor.com/resources/claude-cowork-exfiltrates-files)

### 5. Cloud routines have a 1h floor and consume Max budget

7 daily routines on Max 20x is comfortable (15/day cap), but burning runs on a slow workflow eats from the same token bucket as interactive sessions. If Sudhan does heavy interactive work + 7 routines daily, expect to brush quotas in week 2. Not a stop, but a reality. Plan for one slack day per week.

### 6. User self-assessment override (#14) is heuristic

If user says "I get loops" and `active_weak_spots` says they failed Band 3 yesterday, who's right? This design defaults to user *unless* recent (≤7 days) failure on the same pattern is in `active_weak_spots`. Edge cases:
- User's confidence is genuine but state file is stale → system over-corrects user
- User's confidence is performative → system doesn't catch it (unless drift_log shows the over-claim pattern)

Accept as judgment-call territory.

### 7. Confusion trigger detection (#2) is an arms race

Covered: "I don't get it", "I'm lost", "still confused", "huh?", "🤔". Not covered: "wait, what?", "you lost me" without those words, silence after a question, frustrated sighs in voice mode (if Cowork ever has voice). False negatives accepted. Quarterly: review `drift_log` for confusion patterns the regex missed; tighten.

### 8. Single-device lock means no parallel laptop+desktop Cowork

Cowork enforces one Cowork session per account. Sudhan's weekend Linux dev work and weekday Windows work both want Cowork → can't run simultaneously. State syncs via Git (the routines push, Sudhan pulls before opening Cowork on the other machine). Acceptable trade-off given Discord is dropped.

### 9. PostCompact recovers state but not conversation memory

PostCompact hook re-reads state files and re-injects context — but the conversation history of "we just discussed X" is gone. If drift accumulated in compacted-out turns, the new session sees `drift_log` entries but not the live context that produced them. Same fundamental limit Cowork's auto-compaction imposes.

### 10. WHOOP — RESOLVED: option (d) drop entirely

Locked decision: WHOOP integration removed from the design. No `study-whoop-pull` routine, no `whoop/` folder, no WHOOP references in state/instructions/skills. If recovery state matters in a given week, paste manually. No residual.

### 11. Bootcamp curriculum architecture XMLs — RESOLVED + UPGRADED post-second-pass (2026-05-06)

The user pointed to the actual current location: `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\`. The openclaw snapshot held *stale* copies (Day 2, 2026-02-25); the live pipeline repo holds **current** copies as of 2026-04-16.

**Live state from pipeline repo:**
- `progress_state.xml` v2.4: `<completed_through_day>21</completed_through_day>` — **Phase 1 complete, Phase 2 active** (Days 22-42, Basic DSA + Stats Tier 1A). Phase transition T1 completed 2026-04-17. Active curriculum chunk: `curriculum_weeks04-06.xml`.
- `deviation_log.xml` v2.4: Phase 1 `scope_additions` block fully populated with 16 concept categories — full inventory of every concept Sudhan has been formally taught. This is the **registry-enforceable scope-purity source** the design needs.
- `rules.xml` v2.5: 6 cardinal rules including Rule 1 scope-purity (fail-closed) and Rule 6 missing-file STOP protocol.
- Plus `scope_registry.xml` (explicit registry not present in openclaw snapshot), `quality_gates.xml`, `structure_current.xml`, `structure_phase2.xml`, `curriculum_weeks01-03.xml`, `curriculum_weeks04-06.xml`, `transition_map.xml`, `transition_briefs/T1_weeks04-06.md`.

**The pipeline repo also has its own CLAUDE.md** describing a 5-pass package-generator workflow (read config → build cross-reference registry → expand sections → verify 15 gates → self-review). That CLAUDE.md is **for the pipeline, not the study companion** — they are separate concerns. The pipeline GENERATES daily packages; the study companion is the LEARNER's interface to study them.

**Resolution:** scope-purity rule is fully registry-enforced via the live pipeline files. §G updated to point to the correct path and add a sync routine. The "Day 2 stale" caveat in the prior version of this entry is **deleted** — files are current to 2026-04-16. Sudhan is on Phase 2; concrete day within Phase 2 will be reflected in progress_state.xml at the next Sunday Review checkpoint (Day 28 / Week 4 review).

**Day-state clarification:** Sudhan tracks two parallel day dimensions:
- **Bootcamp day** (per `progress_state.xml`): completed through Day 21, currently in Phase 2 (Days 22-42).
- **Loop Week day** (per `state/current_day.md` and `bootcamp/loop-week/`): a separate ~7-day remediation mini-curriculum running alongside Phase 2 to consolidate iteration fluency. Currently around Day 3.

These are NOT the same and must not be conflated. The 4 different "day" numbers across the openclaw snapshot (Day 4 in feeds, Day 5 in USER.md, Day 8 in MEMORY.md, Day 15-16 in loop-strategy) reflect this conflation plus stale-state drift. Study companion's `state/current_day.md` should track BOTH dimensions explicitly:

```yaml
bootcamp:
  phase: 2
  completed_through_day: 21
  current_day: 35  # estimated, refined at next checkpoint
  active_chunk: curriculum_weeks04-06.xml
loop_week:
  current_day: 3
  active: true
```

### 12. Cowork hook bug #40495 (NEW residual)

Per ⚠️ ESCALATION at top of plan and §B/§D updates: Cowork sessions ignore all hooks today, both user-authored and plugin-bundled. Open bug, no documented ETA. Under Option X (Cowork-only), 7 of the 16 failures lose enforcement entirely; 3 become partial. The skills layer (10 skills + 2 sub-agents + plugin install via custom file upload) all function normally. The hook layer is dormant. Resolution path is Anthropic landing #40495; mitigation paths are Option Y (Claude Code terminal) or Option Z (hybrid). Watch [github.com/anthropics/claude-code/issues/40495](https://github.com/anthropics/claude-code/issues/40495) for status.

### 13. Wins library preserves evidence of capability, not reproduction recipes (NEW residual, surfaces a real limit)

A captured win (e.g., "closures = barista with recipe card") preserves the **artifact**, not the **generative conditions**. The original moment included: the user's specific confusion phrasing, the user's failed prior attempt, the exact gap that made *that* analogy bridge *that* mismatch. By the time the artifact is written down, the bridge is captured but not the river it spanned. Future sessions have different rivers. The bridge dropped on different water doesn't span anything.

This is not a bug in /lock-decision or in the wins schema — it's a property of how generation works. Each LLM response is a fresh sample from a distribution conditioned on the full context. The context can be similar across sessions, but it can't be identical, and small differences in context produce qualitatively different outputs because language models are sensitive to phrasing in ways humans aren't. The "aliveness" in any given teaching moment is partly user-side (the user's state, their readiness, their phrasing) and not engineerable from the agent side.

**This residual cannot be eliminated by any harness on any platform today.** Not by Cowork hooks, not by claude.ai/code hooks, not by a vector store, not by fine-tuning. The user's prior diagnosis was correct: "the reference reaches the artifact, not the generator."

**What this means in practice:**
- Wins are **calibration targets** ("this companion is capable of mechanism-matched analogies, one-analogy-at-a-time, inline visualization") — not scripts.
- /self-review checks "did I make a move of THIS KIND?" not "did I reuse this analogy?"
- /teach-from-win (new in §B) explicitly forces structural mapping rather than artifact reproduction: it asks for the user's current precondition first, then uses 1-3 prior wins as quality calibration, then generates fresh.
- /calibrate (new in §B) accepts that aliveness needs user-in-the-loop iteration: 2 turns to land on-target rather than 1 turn that reproduces a hollow past version.

**Mitigations baked into this design:**
1. /lock-decision schema captures `user_precondition` (verbatim user confusion + verbatim failed prior attempt) instead of the previously-named `trigger` (Claude's introspection on its own choice — confabulation, not mechanism). Higher fidelity capture; future generations have more authentic context to calibrate against.
2. /teach-from-win forces precondition-first, win-as-calibration workflow. Disrupts the "do that again" reflex that produces hollow versions.
3. /calibrate accepts 2-turn iteration as the actual route to landing, not 1-turn re-summoning.
4. `concept_gap` field in /lock-decision schema captures the structural mismatch the artifact bridged. Two future sessions on different topics with the same `concept_gap` can be calibrated against each other usefully — even though their artifacts will differ.

**The honest reframe:** success is "did this land here, on this gap, now?" — not "does this match the previous version." When that criterion holds, aliveness comes back. Different aliveness than the past win. **Same kind.** This is a different success criterion than "reproduce the win" and the design now reflects that.

### 14. Cloud-routine Git setup operational complexity (renumbered from #13)

§E now enumerates a 10-step pre-flight checklist before the first routine runs. Failure modes specific to this stack:

- **No first-party secrets vault.** Per [code.claude.com/docs/en/claude-code-on-the-web](https://code.claude.com/docs/en/claude-code-on-the-web): *"A dedicated secrets store is not yet available. Both environment variables and setup scripts are stored in the environment configuration, visible to anyone who can edit that environment."* Open issue [#32733](https://github.com/anthropics/claude-code/issues/32733). For this design's WHOOP option (a), VPS auth doesn't enter routines at all (the VPS pushes to Git separately) — so this matters less. But if any future routine needs an API key, the key sits in plaintext-equivalent env vars.
- **Branch policy is enforced, not configurable per-routine.** All 7 routines push to `claude/<routine>-<date>` (the prefix is mandatory; the suffix is convention). Open issue [#27403](https://github.com/anthropics/claude-code/issues/27403) tracks user requests for custom naming. Routines do not push to `main` unless "Allow unrestricted branch pushes" is toggled on per repo, which this design does NOT recommend. So state changes always land on `claude/` branches first; user (or auto-merge config) is responsible for merging to `main`. Adds friction; design considered acceptable.
- **No first-party shared storage** between routines and interactive Cowork sessions. Git is the only supported channel. If GitHub is down, routines fail to clone; interactive sessions can still operate on the local checkout but won't see routine output until GitHub recovers.
- **GitHub App vs `/web-setup`:** Recommendation is GitHub App (per-repo install) rather than `/web-setup` (which syncs the user's `gh` CLI OAuth scope and is broader). GitHub App is more constrained — only the repos you authorize. `/web-setup` is convenient but exposes anything `gh` can reach.
- **ZDR and IP allowlist incompatibility:** Zero Data Retention and IP allowlists block cloud sessions entirely. Sudhan is on a personal Max plan, not enterprise — neither applies. Worth noting if he ever switches to an enterprise plan.

Operational burden estimate: ~30 min one-time for the 10-step checklist, then ~5 min/week to merge `claude/` branches into `main`. If automated merge is configured later (after observing routines for 2 weeks per §H Rule 9), the weekly burden drops to ~0.

### 12. The "all rules are still self-applied" critical path

This design is deterministic at the *load* layer (SessionStart, UserPromptSubmit) and at the *post-display detection* layer (Stop hook). It is NOT deterministic at the *output generation* layer. The /self-review skill helps but is itself a Claude prompt Claude self-applies. **The honest summary: this is the best Cowork can offer today, materially better than Claude.ai but not output-enforcement.**

---

## Self-review (writing-plans skill checklist)

Per the writing-plans skill self-review protocol:

**1. Spec coverage:**
- §A folder structure ✅
- §B plugin design (manifest + 5 hooks + 10 skills + 2 agents) ✅
- §C context-loading order (12 files, ~5200 tokens) ✅
- §D 16-failure enforcement table ✅ — every failure has a row with hook, detection, remediation, residual
- §E 7 cloud routines with cron + reads + writes ✅
- §F state-file schemas with examples ✅
- §G port plan (verbatim/adapt/drop) ✅
- §H 10 anti-drift rules ✅
- §I 3-session validation protocol ✅
- §J 12 honest residuals ✅

**2. Placeholder scan:** Searched for "TBD", "TODO", "later", "appropriate", "as needed". The only "as needed" is in the section header for §J — kept; not a placeholder. No code-block-required-but-missing instances. Schema examples are complete YAML, not stub.

**3. Type consistency:**
- Pattern family codes (A1-F3) consistent across §D, §F (`active_weak_spots.md`), and §G (port from MVP)
- Hook names match across §B (hooks.json) and §D (enforcement table)
- Skill names match across §B (skills/) and §D (enforcement column references)
- File paths consistent across §A (folder structure) and §F (schemas) — `state/active_weak_spots.md`, `state/drift_log.md`, etc.
- Routine names match across §E (table) and §H (one-way data flow table)

**4. Gaps found and noted:**
- ~~Curriculum architecture XMLs missing from snapshot — flagged in §J #11.~~ **Resolved 2026-05-06 post-coordinator-review:** XMLs found at `bootcamp/python-bootcamp/python_claude_bootcamp/Python/architecture/`; ported per §G; §J #11 updated to "resolved" status.
- ~~"deviation_log" mechanism not ported — flagged in §G.~~ **Reversed:** deviation_log.xml schema validated and ported. Worth the file overhead given the registry-enforcement value.
- **NEW (post-coordinator-review):** Cowork hook bug #40495 collapses ~half the §D enforcement table today. Three options presented in ⚠️ ESCALATION at top of plan; user must pick before build.
- **NEW:** WHOOP routine architecture revised; LLM-session option (c) rejected; user picks (a) VPS or (d) drop.
- **NEW:** "70% drift reduction" prediction replaced with §I measurement protocol — observed, not predicted.

---

## Execution handoff

Plan complete and saved to `C:\Users\sudha\docs\superpowers\plans\2026-05-06-cowork-study-companion.md`.

**This is the design document, not the build task-list.** Per the user's constraint "No code yet. This is design, not build."

When the user is ready to build, the next step is a separate prompt that takes this design and produces a TDD-style task breakdown for the writing-plans skill (or executes inline via subagent-driven-development). Until then, this document is the source-of-truth design spec for review and revision.

**Build is UNBLOCKED.** All three prior blocking decisions are now locked (see top of plan):
1. ✅ Hooks: Option Z (hybrid Cowork primary + claude.ai/code RTI).
2. ✅ WHOOP: option (d) drop entirely.
3. ✅ Git pre-flight: accepted; §E 10-step checklist + cross-surface commit discipline (§H Rule 11) baked in.

The plan is build-ready. Coordinator drafts the build prompt next.

---

## Coordinator-review changelog (2026-05-06)

- **§B: Plugin install path verified — confirmed BOTH paths exist.** Custom-unpublished plugin install via "Upload custom plugin file" works; marketplace publishing is NOT required. Quote source added in §B. Personal-marketplace minimum schema also documented (private GitHub repo with `.claude-plugin/marketplace.json` containing `name` + `owner.name` + `plugins[]`). **HOWEVER, escalated to top of plan as ⚠️ ESCALATION:** Cowork hook bug [#40495](https://github.com/anthropics/claude-code/issues/40495) confirmed via the GitHub issue tracker — Cowork sessions silently ignore ALL hooks today, both user-authored and plugin-bundled. New §D fallback table breaks down behavior of all 16 failures under Option X (Cowork-only). New §J #12 residual added.

- **§E + §J: Git-routine setup enumerated.** §E now contains a 10-step pre-flight checklist, the verified two-path GitHub auth model (Claude GitHub App vs `/web-setup`), the `claude/`-branch enforcement, and the documented absence of a first-party secrets vault. New §J #13 residual added covering the operational complexity, branch-merge friction, and ZDR/IP-allowlist gotchas.

- **§E #2 + §J #10: WHOOP routine architecture revised.** Coordinator concern #3 was correct — original "LLM session does OAuth refresh + atomic writes" is exactly the self-application failure mode this design refuses. New table in §E presents 4 options; recommendation is (a) keep the existing hardened `pull_data.sh` on a tiny VPS, routine just git-pulls and verifies staleness — or (d) drop WHOOP entirely. Option (c) LLM-session-with-belt-and-suspenders explicitly **rejected**. User picks (a) or (d) before build.

- **§D + §J #1 + §I: 70% estimate replaced with measurement protocol.** Coordinator concern #4 correctly flagged the prediction had no evidence base. §I now contains a per-substantive-minute drift-rate measurement protocol over a baseline window (sessions 1–2) and a trend window (sessions 3–7). Success/failure criteria stated empirically — no specific percentage target. §J #1 rewritten to remove the percentage and reference §I.

- **§J #11: Missing XMLs FOUND.** Both `progress_state.xml` (v2.4, last_updated 2026-02-25) and `deviation_log.xml` (v2.3) exist at `openclaw_setup/bootcamp/python-bootcamp/python_claude_bootcamp/Python/architecture/`. Schemas validated. §G port plan updated to include both files plus `rules.xml` and `curriculum_manifest.xml` from the same directory. Scope-purity rule is now registry-enforced, not soft. **Caveat:** the XMLs reflect Day 2 state from 2026-02-25; user must update `progress_state.xml`'s `<completed_through_day>` to current day before scope-purity has full bite. Fail-closed default means out-of-date registry yields conservative scope (good), not lenient scope (bad).

- **§J #11 + §G + §E: SECOND-PASS UPGRADE.** User pointed to richer location at `C:\Users\sudha\claude_bootcamp\python_bootcamp_claude_code-main\config\` — the bootcamp pipeline repo. Files there are dramatically more current and complete: `progress_state.xml` v2.4 last-updated 2026-04-16 with `<completed_through_day>21</completed_through_day>` (**Phase 1 complete, Phase 2 active**, not Day 2 stale), `deviation_log.xml` v2.4 with full Phase 1 scope_additions block (16 concept categories — registry-enforceable), `rules.xml` v2.5 (was v2.4), plus `scope_registry.xml` (an explicit registry the openclaw snapshot lacked), `curriculum_weeks04-06.xml` (active chunk), `structure_phase2.xml`, `quality_gates.xml`, `transition_map.xml`, `transition_briefs/T1_weeks04-06.md`. Architectural decision: study companion **does not fork** these XMLs — pipeline repo is authoritative, study companion subscribes via new daily routine (`study-curriculum-sync` added as routine #8 in §E). Day-state clarification added to §J #11: bootcamp day (per progress_state, currently Phase 2 / completed_through_day=21) and Loop Week day (per state/current_day.md, currently around Day 3) are independent dimensions and must not be conflated.

### Final revisions (2026-05-06, after blocking decisions)

- **Decisions locked** at top of plan: Hooks=Z (hybrid Cowork + claude.ai/code), WHOOP=dropped (option d), Git pre-flight=accepted. ⚠️ ESCALATION block rewritten as "Locked decisions" — the X/Y/Z option choice is closed.
- **§A**: `whoop/` folder removed from granted directory tree. Cross-surface mounting note added — same `~/study-companion/` Git repo accessed by both Cowork (folder grant) and claude.ai/code (per-session clone). State table updated with surface annotations.
- **§B**: skill count now **12** (was 10). `/lock-decision` schema **revised** — `trigger` field replaced with `user_precondition` (verbatim user confusion + verbatim failed prior attempt) plus new `concept_gap` field (structural mismatch the artifact bridged). Two new skills added: `/teach-from-win` (forces precondition-first calibration workflow when applying past wins to current concepts) and `/calibrate` (mid-teaching user-in-the-loop iteration check). Plugin install path clarified per surface — same plugin file deploys to both, hooks just don't fire in Cowork yet.
- **§C**: context-loading order now explicitly two-path. claude.ai/code uses SessionStart hook + additionalContext; Cowork uses CLAUDE.md `@path` imports per [code.claude.com/docs/en/memory](https://code.claude.com/docs/en/memory). Identical files in identical order on both. CLAUDE.md @-import path is the design's primary lever (deterministic priming → time-to-correct-mode metric in §I) and is unaffected by #40495.
- **§D**: 16-failure table annotated with surface-aware enforcement. Three categories: Both-surfaces (#1, #4, #5, #8, #11, #12, #14 — skills + CLAUDE.md @-imports); claude.ai/code-only (#2, #3, #6, #9, #10, #13, #15, #16 — hook-dependent); Both-with-degradation (#7). Cowork honest tally: 5 fully addressed, 3 partial, 8 lost. claude.ai/code honest tally: 14 fully addressed, 2 partial, 0 lost. Cross-surface drift_log import described — drift logged in claude.ai/code is visible in next-session Cowork.
- **§E**: WHOOP routine #2 deleted. Routine count now **7** (was 8). `study-curriculum-sync` promoted to routine #1 (runs at 08:30 IST, before morning briefing reads its output). Cross-surface commit reality noted — both Cowork and claude.ai/code interactive sessions commit to the same repo as routines do; sync via standard Git flow.
- **§F**: WHOOP file schemas confirmed absent. State-file schemas unchanged.
- **§G**: 5 seed wins from `~/personal/MEMORY.md` ported as day-1 calibration set (closures-barista, factory-locked-machine, backpack-captured-vars, legb-room-search, nonlocal-old-house). Each uses the revised /lock-decision schema with `user_precondition: "historical — original confusion context not preserved..."` flag. Wins library starts non-empty so /teach-from-win and /self-review have calibration data on day 1.
- **§H**: new Rule 11 added — cross-surface state sync via Git, commit-between-switches discipline. Rule 10 (compaction-resilient state) annotated as claude.ai/code-only (Cowork has no equivalent path until #40495 lands).
- **§I**: **primary success metric replaced.** Time-to-correct-mode (target <5 min vs Claude.ai baseline 40-50 min) is now the primary metric. Drift count demoted to secondary. Routine reliability is tertiary. The 70% drift-reduction prediction (already removed in concern-4 review) stays gone. Failure criterion at session 3: if first-response-in-correct-mode is NOT achieved by session 3, the design has failed at its primary purpose and a redesign is needed regardless of drift residuals.
- **§J**: WHOOP residual #10 now reads "RESOLVED: option (d) drop entirely". New residual #13 added — wins library preserves evidence of capability, not reproduction recipes (artifact-vs-generator gap; cannot be eliminated by any harness on any platform; mitigations are revised /lock-decision schema, /teach-from-win, /calibrate, and the reframe that success is "did this land here, on this gap, now?"). Git complexity renumbered #13 → #14.
- **Execution handoff** at bottom of plan now reads "Build is UNBLOCKED" — all three prior blocking decisions ✅ locked.

**Net plan health after final revisions:** primary user pain (40-50 min priming → <5 min target) addressed by the strongest layer in the design (deterministic CLAUDE.md @-imports, both surfaces). Cowork is the daily teaching surface with skills + folder priming; claude.ai/code is the RTI surface with full hook coverage. Wins library starts seeded, not empty. Surface-sync via Git is documented with commit-between-switches discipline. Three honest residuals named and reframed: hook bug (#12, awaiting Anthropic), artifact-vs-generator (#13, architectural — cannot be solved), Git operational complexity (#14, accepted).

**Plan is build-ready as of 2026-05-06.**

**Net plan health after review:** stronger on registry enforcement (#11 resolved), honest on prediction (70% removed), explicit on operational setup (Git pre-flight, WHOOP options). **Major regression flagged at top:** hook bug #40495 forces a user decision (X/Y/Z) before build. Without that decision, ~half the §D enforcement table is dormant in Cowork.
