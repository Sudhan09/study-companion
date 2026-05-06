<!-- Per design §G port plan: verbatim port of openclaw_setup/room-to-improve/room-to-improve-architecture/ROOM_TO_IMPROVE_MVP.md -->
<!-- DO NOT EDIT. 6 families, 4 bands, 3 non-negotiables — empirically validated on 9 days of real RTI evidence. -->

# #room-to-improve — Daily Field Manual

---

## The 6 Pattern Families

| Code | Name | One-line | Typical signal |
|---|---|---|---|
| **A** | Assembly Collapse | Can do parts, breaks wiring them together | Block 2 fine, Block 3 collapses |
| **B** | Freeze | Shuts down before writing a line | "no idea", long idle, bail to AI |
| **C** | Misread | Didn't read problem / params / correction | Hardcoded values, prior-problem bleed, same bug after fix |
| **D** | Shape | Right logic, wrong return type/structure | Returns tuple not value, flat not grouped, f-string not dict |
| **E** | Scope | Code at wrong nesting level | try/except wrapping whole loop, else on wrong block |
| **F** | Mechanical | Syntax/variable/operator slips | Wrong var name, `or` vs `and`, typos |

**Subtypes you'll reference most:**
- A1 = multi-step loop body
- A2 = grouping/bucketing
- A3 = nested validation + error collection
- A4 = pipeline chaining
- B1 = total freeze, B2 = bail to AI
- D1 = wrong container, D3 = shape mismatch

---

## The 4 Difficulty Bands

| Band | What | Time | Move up when | Move down when |
|---|---|---|---|---|
| **1** Warm-up | Single-step loop. One operation. | 5-10 min | Automatic (< 3 min, no errors) | N/A — this is the floor |
| **2** Structure | One pattern, 2-step loop body. | 20-30 min | 3 independent completions in a row | Same bug appears twice |
| **3** Integration | Two patterns combined. | 20-30 min | 3 independent completions in a row | Freeze, or needed AI help |
| **4** Implementation | 3+ patterns, multi-function. | 30-45 min | Checkpoint passes | Band 3 not yet stable |

---

## The 3 Non-Negotiable Rules

**1. Same bug twice = STOP.**
Name it. Tag the pattern family. Tomorrow's drill targets exactly that. Nothing else until 2 independent reps succeed.

**2. AI-completed != completed.**
Tag it `[AI]`. It doesn't count toward pattern mastery. It becomes a future re-test.

**3. Block 2 success does NOT predict Block 3 success.**
Micro-exercises landing means nothing if integrated problems collapse. Track independence at Block 3+.

---

## Freeze Protocol (Family B)

When you freeze — blank screen, "no idea," reaching for AI before trying:

```
1. What is the INPUT?  (read function signature)
2. What is the OUTPUT? (read the asserts)
3. What is ONE thing I know how to do here?
4. Write that one thing.
```

If still nothing after 5 minutes: step down to Band 1 for the sub-pattern causing the freeze. Do not force through. Do not hand over the answer.

---

## Return-Shape Protocol (Family D)

Before writing ANY function body:

```
1. Read the asserts — what type is expected? list? dict? tuple? float?
2. Write the return statement FIRST:
   return {}    # or return []  or return 0.0
3. Then build the body to fill that shape.
```

This catches shape errors before they happen.

---

## "Same Bug Twice" Escalation

If any bug appears a second time in the same session:

1. **Stop** current work immediately
2. **Name it**: "[Family X] — [exact description]"
   - Example: "A2 — forgot to initialize list before appending"
   - Example: "F3 — used `or` instead of `and` again"
3. **Log it** in today's post-session as a same-session repeat
4. **Tomorrow**: Band 2 drills on ONLY that pattern. No other targets.
5. **Don't return** to the difficulty where it happened until 2 independent Band 2 reps succeed

---

## Daily Flow (< 10 min overhead)

| When | What | Time |
|---|---|---|
| Before study | Glance at yesterday's post-session. Know today's drill target. | 2 min |
| During study | Note freezes, hesitations, errors in real-time. | 0 min extra |
| During study | If same bug appears twice: stop and name it. | 1 min |
| After study | Fill post-session template. | 5-8 min |

---

## Quick Tag Reference

**Independence tags:** `[independent]` `[hint]` `[scaffolded]` `[AI]` `[abandoned]`

**Pattern tags:** `A1` `A2` `A3` `A4` `B1` `B2` `B3` `C1` `C2` `C3` `C4` `D1` `D2` `D3` `E1` `E2` `E3` `E4` `F1` `F2` `F3`

**Evidence strength:** `strong` (repeated/freeze/AI-needed) `moderate` (hints needed) `weak` (one-off, self-corrected)
