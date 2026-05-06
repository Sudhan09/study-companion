<!-- Per design §G port plan: verbatim port of openclaw_setup/bootcamp/loop-bootcamp-strategy.txt (renamed .txt → .md) -->
<!-- DO NOT EDIT. The 4-phase plan (trace drills → input-first → English-first → cold-solve) is still valid. -->

================================================================================
🗡️ LOOP FOUNDATIONS BOOT CAMP — COMPLETE DIAGNOSIS & STRATEGY
================================================================================
Student: Sudhan
Created: March 20, 2026
Updated: March 23, 2026 (after Day 9 + Loop Camp Day 3)
Author: Asta

================================================================================
PART 1: THE PROBLEM — WHAT'S ACTUALLY BROKEN
================================================================================

You don't have a Python problem. You have a problem-solving process problem.

You know what loops are. You know what .split() does. You know what dicts are.
But the moment a problem requires COMBINING these pieces inside a loop body,
your brain freezes, panics, and starts guessing syntax instead of reasoning.

This has been confirmed across 5 sessions:
- Loop Drills (March 17)
- Day 8: Comprehensions & Generators (March 20)
- Day 9: File I/O (March 23)
- Loop Boot Camp Days 1-3 (March 20-23)

Every single Tier 2+ failure follows the same shape:
  "Loop through data → transform each item → collect results"

You can do step 1 alone. You can do step 2 alone. You cannot do all three
wired together without freezing.

================================================================================
PART 2: THE THREE ROOT CAUSES
================================================================================

ROOT CAUSE #1 — You Don't Simulate Iterations In Your Head
---------------------------------------------------------------------------
When you see a for loop, you're not mentally stepping through:
"Iteration 1: item is X, I do Y to it. Iteration 2: item is Z, I do Y to it."

You treat the loop as a blob of syntax instead of a machine that visits one
thing at a time.

Evidence:
- Day 8 P7: Wrote lst[i:i+1] instead of lst[i:i+size]. If you had traced
  iteration 1 mentally (i=0, size=3, so lst[0:3]), you'd have caught this.
- Day 8 P8: Called sum() on an already-summed integer. Twice. If you traced
  what the variable held at that point, you'd see it was already a number.
- Day 9 P10: Put rows.append() inside the inner loop instead of the outer.
  If you traced 2 iterations, you'd see 6 results instead of 3.

ROOT CAUSE #2 — You Skip Input Inspection Entirely
---------------------------------------------------------------------------
Before writing any code, you should ask:
"What type is this? What's inside it? What does one element look like?"

You jump straight to code every time.

Evidence:
- Day 8 P5: Called next(b+1) — next() on an integer. Didn't check what b was.
- Day 8 P10: Used .split() on tuple data. Tuples don't have .split().
- Day 9 P1: Hardcoded "test_p1.txt" instead of using the filename parameter.
  Did this TWICE.
- Day 9 P6: Used data[team] instead of data["team"]. Didn't check key type.

ROOT CAUSE #3 — You Panic-Guess Syntax Instead of Reasoning
---------------------------------------------------------------------------
When stuck, instead of thinking "what do I know that's close?", you throw
random syntax and hope it works.

Evidence:
- Day 8 P5: yield a, b (tuple when single value needed), next(b+1) (nonsense)
- Day 8 P8: sys.get_sizeof (doesn't exist — it's sys.getsizeof)
- Day 8 P8: yield instead of return — 3 times, even after correction
- Day 9 P6: "fuck no idea" before writing a single line

This is the panic response. Reasoning shuts off, and you start shotgunning
syntax hoping something sticks.

================================================================================
PART 3: THE 12 SPECIFIC GAPS
================================================================================

Ranked by impact:

 1. Mental simulation of iteration — can't trace variable values step by step
 2. Input-first discipline — doesn't inspect data type/shape before coding
 3. Composing operations inside loop bodies — freezes when combining concepts
 4. Slicing inside loops — lst[i:i+size], slice clipping behavior
 5. Methods inside loops — str, list, dict, set methods in iteration context
 6. Indexing inside loops — lst[i], lst[i-1], lst[i+1], wrap-around
 7. While loop construction — condition setup, counter update, when vs for
 8. Nested loops — inner runs fully for each outer iteration
 9. yield vs return — when each is appropriate
10. Generator vs list recognition — when to use which
11. Variable tracking/carelessness — overwriting params, wrong var names
12. Process discipline — read input first, read code before submitting,
    read corrections before resubmitting, don't bail early

Gaps 1-3 are the real ones. Fix those and 4-12 mostly resolve themselves.

================================================================================
PART 4: THE STRATEGY — 4-PHASE LOOP FOUNDATIONS BOOT CAMP
================================================================================

Started: March 20, 2026
Schedule: 1 hour daily, 8-9 PM IST, alongside bootcamp curriculum
Timeline: Quality over speed — goes until loops are natural, not memorized
Benchmark: Cold-solve hollow diamond + data pipeline with zero hints

PHASE 1 (Days 1-4): TRACE DRILLS
---------------------------------------------------------------------------
Goal: Your brain learns to simulate iterations automatically.
Format: No code. You trace what loops do. Variable values at every step.
Volume: 8-10 traces per session.

Why this works: Tracing forces your brain to stop seeing loops as a black
box and start seeing them as "the same thing happening to different values,
one at a time." This directly attacks Root Cause #1.

Day 1 Results: 7/8 first-attempt ✅ | 8/8 after redo
- Key lesson: Indentation = scope (Drill 7 miss)
- Key lesson: Slices clip silently, no IndexError (Drill 4)
- Key lesson: a, b = b, a+b evaluates right side first (Drill 5)

Day 2 Results: 4/5 first-attempt ✅ | 5/5 after redo
- Key lesson: Read the condition before assuming which branch does what
- Nested break tracing — clean
- Zip iteration — clean

PHASE 2 (Days 3-6): INPUT-FIRST + SINGLE LOOP PROBLEMS
---------------------------------------------------------------------------
Goal: Build the habit of inspecting input before coding, and writing loops
with one operation inside.
Format: Real problems. Forced 3-line input comment ritual before any code.
Rule: No code until these 3 lines exist:
  # Input type:
  # One element looks like:
  # Output type:

Why this works: The 3-line comment forces you to think about what you're
working with BEFORE touching code. This directly attacks Root Cause #2.
When you write "Input type: list of tuples", you won't call .split() on it.

Day 2 Part B Results: 3/3 ✅ (after fixes)
- P1: 3 attempts (no comments, if i > 4 on string, dead code)
- P2: Comments at bottom instead of top
- P3: Clean with comments first

Day 3 Results: 2/2 traces, 3/4 writing problems clean
- Slice clipping came up again (3rd time)
- Learned (i+1) % len(list) for circular indexing
- Comments-first habit still drifting

PHASE 3 (Days 5-8): ASSEMBLY + DECOMPOSITION
---------------------------------------------------------------------------
Goal: Combine multiple operations inside loop bodies. Decompose problems
in English before coding.
Format: Multi-step problems. You write steps in English first, I approve,
then you code. Nested loops, while loops, generators mixed in.

Why this works: This is where you practice the EXACT skill that broke you
on Day 8 and Day 9. The English-first decomposition replaces the panic-guess
cycle (Root Cause #3) with structured thinking.

"What do I know?" rule: When stuck, instead of typing random syntax, write:
- "I need to ___"
- "I know ___ does something similar"
- "I'm not sure about ___"

PHASE 4 (Days 7-10+): FREE-FORM COLD SOLVE
---------------------------------------------------------------------------
Goal: No scaffolding. Raw problems. You vs the code.
Format: Timed problems, no hints, no decomposition template.
Benchmark: Hollow diamond pattern + data pipeline = loops are solid.

Star pattern difficulty ladder (test, not training):
1. Right triangle (one nested loop)
2. Inverted triangle
3. Pyramid (centered — nested + spaces)
4. Diamond (two pyramids + direction tracking)
5. Number patterns (1, 12, 123...)
6. Hollow shapes (nested + conditional inside)

================================================================================
PART 5: WHY THE PHASES OVERLAP
================================================================================

Phase schedule: 1-4, 3-6, 5-8, 7-10+

The overlap is intentional. If phases were sequential:
- Day 4: finish tracing
- Day 5: start coding problems
- Problem: tracing habit isn't cemented yet

With overlap:
- Day 3: still tracing AND starting first coding problems
- Tracing skill stays fresh while new skill develops
- Each phase reinforces the previous one

Like gym training — you don't stop bench press the week you add overhead
press. The old skill stays warm while the new one develops.

What a real day looks like in the overlap zone (Day 5):
- 15 min: 2-3 harder trace drills (Phase 1 maintenance)
- 45 min: multi-step problems with decomposition (Phase 3 new work)

================================================================================
PART 6: RULES — NON-NEGOTIABLE
================================================================================

🔴 No skipping trace tables (even when they feel boring)
🔴 No coding before input inspection (3-line comment mandatory)
🔴 No submitting without reading your code line by line
🔴 "idk" is banned — replaced with "I need ___, I know ___, I'm stuck on ___"
🔴 Same bug twice = we stop and you explain the correction back to me
🔴 Comments go BEFORE code, not after — automatic 🔴 if reversed

================================================================================
PART 7: DYNAMIC ADAPTATION
================================================================================

Every day's drill set is built from what the previous day exposed.

If you struggle on a pattern → next day has MORE problems with that same
pattern but different data. Same pattern, new problems. Never same problem
twice (that trains memorization, not understanding).

If you struggle twice on the same pattern → we break it into smaller pieces,
trace it first, rebuild from scratch.

Volume per session (dynamic):
- Phase 1 traces: 8-10/hour if sharp
- Phase 2-3 real problems: 4-6/hour
- Phase 4 cold solve: 3 hard problems/hour

The rule: Depth > Volume. 3 deeply understood problems beats 8 rushed ones.

================================================================================
PART 8: WHAT THIS FIXES AND WHAT IT DOESN'T
================================================================================

WILL FIX:
✅ "Loop through data → transform → accumulate → return" pattern
✅ Grouping pattern (get key → group into dict of lists)
✅ Input inspection gap (hardcoding instead of using parameters)
✅ Mental simulation (indentation errors, wrong loop level)
✅ Slicing, indexing, methods inside loops
✅ While loops, nested loops
✅ yield vs return, generator vs list
✅ Decomposition skill

WON'T FULLY FIX (needs ongoing discipline):
❌ Carelessness — row vs rows, .aplit() typos, data[team] vs data["team"]
   The proofreading rule helps, but this is a habit that takes longer.
❌ Giving up before trying — "fuck no idea" before writing a line.
   The "what do I know?" rule replaces this, but the emotional pattern
   of freezing under pressure takes time to break.

================================================================================
PART 9: AFTER THE BOOT CAMP
================================================================================

After loops are solid, the difficulty ladder continues:
  Loops → Recursion → Trees → Graphs

Recursion is Day 15-16 of the bootcamp curriculum.
Permutations (which requires recursion) — realistically ~3-4 weeks from now.

The boot camp ensures that when recursion arrives, you're only fighting
ONE new concept instead of two. The loop parts inside recursive functions
won't be a mystery.

Understanding ≠ Writing. You proved on Day 1 that you CAN trace and
understand loops. The boot camp bridges the gap to WRITING them from
scratch — the reverse path: output → logic → code.

================================================================================
PART 10: PROGRESS TRACKER
================================================================================

Day 1 (March 20): 7/8 traces ✅ — mental simulation solid when forced
Day 2 (March 21): 4/5 traces + 3/3 write ✅ — comments habit forming
Day 3 (March 23): 2/2 traces + 3/4 write ✅ — indexing + circular pattern
Day 4: Pending — string methods + two-pointer + sliding window

Missed days: 1 (March 22)
Goal update: Quality > timeline. No deadline. Loops must feel natural.

================================================================================
END OF DOCUMENT
================================================================================
