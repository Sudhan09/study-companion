<!-- Per design §G adapt: ports OpenClaw's trigger phrase vocabulary (AGENTS.md "Lock it in" patterns). -->
<!-- Detected by UserPromptSubmit hook in claude.ai/code (dormant in Cowork per #40495). -->
<!-- Per design §C: new file. -->
<!-- 2026-05-06: Added deterministic colon-prefix tokens after confirmed §J #1 failure of natural-phrase routing in Cowork. See design plan §J #1 (updated 2026-05-06). -->

# Trigger phrases

User says these → corresponding response or skill invocation.

## Why two tracks (natural + deterministic token)

Natural-phrase routing ("lock it in", "wrap up") is **best-effort** in Cowork. Anthropic's plugin system makes skill auto-invocation a model-judgment decision based on the skill's `description` / `when_to_use` text. When the natural phrase has a dominant conversational alternative interpretation (e.g., "lock it in" reads as drill-acceptance after a teaching turn), the model loses the routing fight. Hooks are the only deterministic input-layer mechanism, and Cowork doesn't fire hooks today (#40495).

**Workaround:** each routed skill also has a colon-prefix deterministic token. Use the natural phrase by default; fall back to the token when the natural phrase doesn't fire. Tokens have no conversational meaning — there's nothing else for the model to route them to.

| Skill | Natural triggers | Deterministic token |
|---|---|---|
| `/lock-decision` | "lock it in" / "mark it" / "remember this" / "note this" | `:lock` |
| `/companion` | "be a companion" / "chat with me" / "banter mode" | `:companion` |
| `/day-wrap` | "day wrap" / "wrap up" / "done for today" | `:wrap` |

**Confusion signals do NOT have a token** — they're a directive (re-angle), not a skill invocation. If they don't fire after a confused message, that's a different failure (see §J).

## Lock-in triggers

- `:lock` (deterministic — ALWAYS routes to `/lock-decision`)
- "lock it in" / "mark it" / "remember this" / "note this" (natural — best-effort)
  → invoke `/lock-decision` skill, write to `wins/{date}-{slug}.md`, respond "Locked ✅"

**UserPromptSubmit regex (claude.ai/code):**
```
/(:lock\b|lock it in|mark it|remember this|note this)/i
```

## Confusion signals

- "I don't get it" / "I don't understand" / "I'm lost" / "I'm confused" / "still confused" / "still lost" / "huh?" / "wait what" / "you lost me" / 🤔
  → NEVER repeat slower or louder. MUST re-angle: switch domain analogy, run ASCII trace, or pulse-check what specifically is unclear. State which angle in first sentence after the confusion signal.

**UserPromptSubmit regex (claude.ai/code):**
```
/(I don'?t (get|understand)|I'?m (lost|confused)|still (lost|confused)|huh\??|wait,? what|you lost me|🤔)/i
```

## Companion mode

- `:companion` (deterministic)
- "be a companion" / "chat with me" / "banter mode" (natural)
  → invoke `/companion` skill (drops teacher voice; opt-in)

## Day wrap

- `:wrap` (deterministic)
- "day wrap" / "wrap up" / "done for today" (natural)
  → invoke `/day-wrap` skill (updates `state/current_day.md` + `state/last_session_summary.md`)

## Silent question mark

- Just `?` on its own line
  → injected pulse-check: ask the user what specifically is unclear. Do not assume.
