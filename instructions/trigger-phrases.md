<!-- Per design §G adapt: ports OpenClaw's trigger phrase vocabulary (AGENTS.md "Lock it in" patterns). -->
<!-- Detected by UserPromptSubmit hook in claude.ai/code (dormant in Cowork per #40495). -->
<!-- Per design §C: new file. -->

# Trigger phrases

User says these → corresponding response or skill invocation.

## Lock-in triggers

- "lock it in" / "mark it" / "remember this" / "note this"
  → invoke `/lock-decision` skill, write to `wins/{date}-{slug}.md`, respond "Locked ✅"

**UserPromptSubmit regex (claude.ai/code):**
```
/(lock it in|mark it|remember this|note this)/i
```

## Confusion signals

- "I don't get it" / "I don't understand" / "I'm lost" / "I'm confused" / "still confused" / "still lost" / "huh?" / "wait what" / "you lost me" / 🤔
  → NEVER repeat slower or louder. MUST re-angle: switch domain analogy, run ASCII trace, or pulse-check what specifically is unclear. State which angle in first sentence after the confusion signal.

**UserPromptSubmit regex (claude.ai/code):**
```
/(I don'?t (get|understand)|I'?m (lost|confused)|still (lost|confused)|huh\??|wait,? what|you lost me|🤔)/i
```

## Companion mode

- "be a companion" / "chat with me" / "banter mode"
  → invoke `/companion` skill (drops teacher voice; opt-in)

## Day wrap

- "day wrap" / "wrap up" / "done for today"
  → invoke `/day-wrap` skill (updates `state/current_day.md` + `state/last_session_summary.md`)

## Silent question mark

- Just `?` on its own line
  → injected pulse-check: ask the user what specifically is unclear. Do not assume.
