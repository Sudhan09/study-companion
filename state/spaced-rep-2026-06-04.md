---
last_updated: 2026-06-04T19:08:02+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-04
stale_flags: [active_weak_spots.md (~334h old — >72h threshold), room-to-improve/state/current_state.md (~308h old — >72h threshold)]
---

# Spaced rep — 2026-06-04

## Target
- **Weak spot:** F1 — Variable mix-up / naming (parallel-list iteration: plural collection → singular loop variable; never reuse collection name as loop variable)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~334h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~308h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~334h old, current_state.md ~308h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: make_profiles. Band 2. Reps 0/2. Write a function that zips three parallel lists into dicts — each list's loop variable must be its singular form, never the list name itself.**

Write this function from scratch:

```python
def make_profiles(names: list[str], scores: list[int], grades: list[str]) -> list[dict]:
    ...
```

Returns a list of dicts, one per position, pairing each name/score/grade together.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# names:   input list of name strings — parameter name stays 'names'; never 'name', 'ns', 'n'
# scores:  input list of score ints  — parameter name stays 'scores'; never 'score', 'ss', 's'
# grades:  input list of grade chars — parameter name stays 'grades'; never 'grade', 'gs', 'g'
# name:    ONE element drawn from 'names'  (singular) — never 'names', 'n', 'nm'
# score:   ONE element drawn from 'scores' (singular) — never 'scores', 's', 'sc'
# grade:   ONE element drawn from 'grades' (singular) — never 'grades', 'g', 'gr'
# result:  the output list being built — never 'res', 'r', 'out', 'profiles'
```

**Step 2 — Write the function body.** Use `zip` to iterate all three lists in parallel.

**The trap this drill tests (parallel-list face of the F1 escalation):**

The exact escalation trigger on 2026-05-21 was C.4 Drill 3: the task said build a dict per student using `ages`/`scores` lists, but the loop used `for ages, scores in zip(ages, scores):` — plural variable names reusing the collection names. Result: every inner dict got the whole list, not one value. That's this bug.

Today's version has THREE parallel lists. The risk lines, in order:

1. The `zip` header — each loop variable must be the **singular** of its collection:
   ```python
   for name, score, grade in zip(names, scores, grades):   # ✅
   for names, scores, grades in zip(names, scores, grades): # ❌ reuses collection names
   for n, s, g in zip(names, scores, grades):               # ❌ abbreviations
   ```

2. The dict literal — each key's value must use the singular loop variable:
   ```python
   {"name": name, "score": score, "grade": grade}  # ✅
   {"name": names, "score": scores, "grade": grades} # ❌ would grab the whole list
   ```

**Expected behaviour:**
```python
make_profiles(["Asta", "Yuno"], [95, 88], ["A", "B"])
# → [{"name": "Asta",  "score": 95, "grade": "A"},
#    {"name": "Yuno",  "score": 88, "grade": "B"}]

make_profiles(["Rex"], [72], ["C"])
# → [{"name": "Rex", "score": 72, "grade": "C"}]

make_profiles([], [], [])
# → []
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order:
1. `zip` header — all three loop variables are singular, none reuse the collection name
2. Dict literal — all three values reference the singular loop variable, not the collection
3. `result.append(...)` — `result` not aliased

Any reuse of collection name as loop var, or any abbreviated alias (`n`, `s`, `g`) = redo. Output paste required — run all three assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Name both sub-steps (build the dict, then append it) before touching the keyboard. (A1 rep #3 of 3 toward Band 2 graduation is still open — this drill keeps the pattern warm.)

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets; id "F1" < "A1" < "F3" breaks the Band-2 tie). Last 3-day window: `filter_and_scale` (2026-06-01, define-name=use-name face), `collect_unique` (2026-06-02, default-args/None-sentinel face), `Pipeline` (2026-06-03, class-method/self.attribute face). None of those covered the **parallel-list plural-to-singular** face — the direct 2026-05-21 C.4 Drill 3 escalation trigger (`ages`/`scores` plural loop vars). `make_profiles` targets that face with three parallel collections.
