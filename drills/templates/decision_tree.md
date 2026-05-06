<!-- Per design §G port plan: verbatim port of openclaw_setup/room-to-improve/room-to-improve-architecture/drill_decision_tree.md -->
<!-- DO NOT EDIT. Q1-Q4 flowchart for tomorrow's drills. -->

# Drill Decision Tree

Use after every post-session to decide tomorrow's drills.
Start at the top. Follow the first YES branch.

---

## What to drill tomorrow

```
Q1: Did any bug appear TWICE in today's session?
│
├─ YES ──> Drill ONLY that pattern at Band 2 tomorrow.
│          Generate 3 reps with different data contexts.
│          Do NOT attempt Band 3 on that pattern until
│          2 consecutive independent Band 2 reps succeed.
│          STOP HERE.
│
└─ NO ──> Continue to Q2.


Q2: Did a freeze event happen today? (Family B)
│
├─ YES ──> Which problem caused the freeze?
│          │
│          ├─ Can you identify which sub-pattern triggered it?
│          │   (e.g., "froze because grouping + aggregation together")
│          │   │
│          │   ├─ YES ──> Drill that sub-pattern at Band 2.
│          │   │          Do NOT retry the integrated version yet.
│          │   │
│          │   └─ NO ──>  Run the decomposition protocol on the frozen
│          │              problem: input? output? one thing I know?
│          │              Tomorrow: Band 1 warm-up on the problem's
│          │              component parts, then Band 2 on the
│          │              easiest component.
│          │
│          └─ STOP HERE.
│
└─ NO ──> Continue to Q3.


Q3: Was AI assistance used on any problem today?
│
├─ YES ──> Identify which pattern families the AI-solved
│          problem stressed.
│          │
│          ├─ Were those patterns already stable at Band 2?
│          │   │
│          │   ├─ YES ──> The problem was Band 3+ difficulty.
│          │   │          Generate Band 2.5 drills:
│          │   │          same pattern + ONE small addition.
│          │   │
│          │   └─ NO ──>  Generate pure Band 2 drills on the
│          │              unstable pattern. 3-4 reps.
│          │
│          Tag AI-solved problem as future re-test.
│          Continue to Q4.
│
└─ NO ──> Continue to Q4.


Q4: What was today's independence score?
│
├─ 0-1 ──> Stay at current phase.
│          Add MORE Band 2 reps (not harder ones).
│          Warm-up tomorrow: weakest pattern from today.
│          Do NOT attempt Band 3.
│
├─ 2 ──>   Current targeting is working. Continue.
│          Warm-up: yesterday's weakest.
│          Structure reps: today's weakest pattern at Band 2.
│          Integration: ONE Band 3 attempt on strongest pattern.
│
├─ 3 ──>   Patterns stabilizing. Push integration.
│          Reduce Band 2 reps to 2.
│          Add Band 3 reps combining weak + strong patterns.
│          Consider Band 4 attempt if Band 3 was clean.
│
└─ 4 ──>   Strong session.
│          Check: is this 3 sessions in a row at 3+?
│          ├─ YES ──> Consider advancing to next phase.
│          └─ NO ──>  Continue current phase. Test with
│                     new context domains to confirm stability.
```

---

## Step-up / Step-down Quick Reference

| Signal | Action |
|---|---|
| Same bug twice (any band) | Step down one band on that pattern |
| Freeze on Band 3 | Step down to Band 2 (or Band 1 if can't identify sub-pattern) |
| AI needed on Band 3 | Step down to Band 2 for the stressed patterns |
| 3 independent completions at Band 2 | Step up to Band 3 |
| 3 independent completions at Band 3 | Step up to Band 4 or advance phase |
| Band 1 warm-up fails | Do NOT proceed. Diagnose. Repeat at Band 1 until clean. |
| Pattern hasn't failed in 3 sessions | Reduce its Band 2 reps. Combine it with weaker pattern at Band 3. |
| Pattern hasn't failed in 5 sessions | Graduate. Monitor at Band 3 only. Drop from warm-up. |

---

## After same-session repeated bug (special protocol)

1. Name the bug: "[pattern family] — [exact description]"
2. Tomorrow: 3 Band 2 reps on ONLY that pattern
3. Day after: if 2/3 were independent, add one Band 2.5 rep (same pattern + one addition)
4. Day after that: if Band 2.5 was independent, retry Band 3
5. If it repeats again at Band 3: go back to step 2 with different context variations

---

## After AI-assisted completion (special protocol)

1. Tag the problem `[AI]` in post-session
2. Identify which pattern families it stressed (usually 2-3)
3. For each pattern: is it stable at Band 2 independently?
   - If no: tomorrow's drill = Band 2 on that pattern
   - If yes: tomorrow's drill = Band 2.5 (pattern + one addition)
4. The AI-solved problem becomes a re-test target in 3-5 sessions
5. Re-test must be independent to count as cleared
