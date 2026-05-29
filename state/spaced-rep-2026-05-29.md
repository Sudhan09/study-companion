---
last_updated: 2026-05-29T19:08:56+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-29
stale_flags: [active_weak_spots.md (189h old — >72h threshold), room-to-improve/state/current_state.md (164h old — >72h threshold)]
---

# Spaced rep — 2026-05-29

## Target
- **Weak spot:** F1 — Variable mix-up / naming (collection-vs-loop-var disambiguation; the `ages`/`age` real-bug pattern)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 189h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 164h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md 189h old, current_state.md 164h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: collect_scores_by_grade. Band 2. Reps 0/2. Write a dict-accumulator that groups scores by grade — loop var is singular, collection name stays plural, never mixed.**

Write this function from scratch:

```python
def collect_scores_by_grade(students: list[dict]) -> dict[str, list[int]]:
    ...
```

Each dict in `students` has three keys: `"name"` (str), `"grade"` (str: `"A"`, `"B"`, or `"C"`), and `"score"` (int). Return a dict where each grade maps to the list of scores for that grade.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# students:  input list — stays 'students' throughout, never 's', 'lst', 'data'
# student:   one element from the loop (singular of 'students') — never 'stu', 's', 'item'
# by_grade:  the accumulator dict — never 'result', 'res', 'd', 'groups'
# grade:     the string from student["grade"] — a local variable, never student["grade"] inline twice
# score:     the int from student["score"] — a local variable, same rule
```

**Step 2 — Then write the function body.**

**The trap this drill is testing (direct C.4 Drill 3 escalation trigger):**
The original bug: loop variable was named `age` but the code wrote `ages["dob"]` — accessing the *collection* instead of the *element*. That's a `TypeError` or `KeyError` at runtime. The equivalent here would be writing `students["score"]` (a list has no key `"score"`) instead of `student["score"]`.

**Naming rules:**
1. `students` is the collection. It does not go inside the loop body for data access.
2. `student` is the loop variable. It is the only thing you call `["grade"]` and `["score"]` on inside the loop.
3. `by_grade` stays `by_grade`. Never one-letter or shortened.
4. Extract `grade` and `score` into local variables on their own lines — do not inline `student["grade"]` twice in the same expression.
5. Comments from Step 1 must match code names exactly, 1-to-1.

**Expected behaviour:**
```python
students = [
    {"name": "Arjun",  "grade": "A", "score": 91},
    {"name": "Priya",  "grade": "B", "score": 74},
    {"name": "Vikram", "grade": "A", "score": 88},
    {"name": "Divya",  "grade": "C", "score": 62},
    {"name": "Rahul",  "grade": "B", "score": 79},
]

collect_scores_by_grade(students)
# → {"A": [91, 88], "B": [74, 79], "C": [62]}
```

**Pass condition:** Zero places where the collection name (`students`) appears inside the loop body for data access. Any `students["grade"]`, `students["score"]`, or `students[...]` inside the `for` block = redo. Output paste required.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X, then Y." Name both steps before touching the keyboard.

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps, id "F1" < "F3"). F1's `filter_positives_scaled` (2026-05-26) and `count_above_threshold` (2026-05-28) both within the 3-day window — skipped. This drill (`collect_scores_by_grade`) targets the **collection-vs-loop-var** face of F1 — the exact real-bug from C.4 Drill 3 that triggered the escalation (`ages`/`age` mismatch; every inner dict got the whole list). Not prompted in last 3 days.
