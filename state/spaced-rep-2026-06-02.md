---
last_updated: 2026-06-02T19:08:22+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-02
stale_flags: [active_weak_spots.md (286h old — >72h threshold), room-to-improve/state/current_state.md (261h old — >72h threshold)]
---

# Spaced rep — 2026-06-02

## Target
- **Weak spot:** F1 — Variable mix-up / naming (default-argument context; never reuse a parameter name as a loop variable inside the body)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~286h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~261h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~286h old, current_state.md ~261h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: collect_unique. Band 2. Reps 0/2. Write a function with a `None`-sentinel default — fix the mutable default trap AND keep parameter names distinct from every internal loop variable.**

Write this function from scratch:

```python
def collect_unique(values: list[int], seen: list[int] = None) -> list[int]:
    ...
```

Returns a new list of elements from `values` that are NOT already present in `seen`. Elements appear in input order; duplicates within `values` are only added once. If `seen` is not provided, treat it as empty (fix the mutable default trap with a `None` sentinel).

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# values:  input list parameter — stays 'values' throughout; never 'vals', 'v', 'lst', 'items'
# seen:    the "already exists" list parameter — stays 'seen'; never 's', 'existing', 'cache'
# value:   ONE element drawn from 'values' in the loop (singular of 'values') — never 'v', 'val', 'x', 'item'
# result:  the output list being built — never 'res', 'r', 'out', 'unique'
```

**Step 2 — Write the function body.** Include the `None`-sentinel fix at the top.

**The trap this drill tests (A.6 default-args face of F1):**

The F1 escalation bugs on 2026-05-22 were both "define-name ≠ use-name": defined `mat`, used `m`; parameter named `num`, body used `n`. The default-argument variant is:

- You have `seen` (the parameter) and `seen` must stay `seen` everywhere — inside the sentinel check AND inside the loop condition. The moment you write `if s is None` or `if val in s`, F1 fires.
- The loop's iteration variable over `values` MUST be named `value` (singular). Writing `for values in values:` (reusing the param name as the loop variable) is the exact "never reuse param name as loop var" rule from Day 5 Block A.6.

The two highest-risk lines (examined first on grade):
1. The sentinel fix line: `if seen is None:` — `seen` must not be aliased
2. The loop condition: `if value not in seen:` — `value` (loop var) and `seen` (param) must both be their full names

**Expected behaviour:**
```python
collect_unique([1, 2, 3, 2, 4], seen=None)
# → [1, 2, 3, 4]  (None sentinel → start fresh; 2 appears twice, added once)

collect_unique([1, 2, 3], seen=[2, 3])
# → [1]            (2 and 3 already in seen; only 1 is new)

collect_unique([5, 5, 5], seen=[5])
# → []             (5 is already seen; all three occurrences skipped)

collect_unique([], seen=None)
# → []             (empty input)
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order:
1. Sentinel fix line — `seen` spelled out in full, not aliased
2. Loop header — `for value in values:` (singular loop var, plural collection, no reuse)
3. Loop body condition — `if value not in seen:` (both full names)

Any alias or reuse (`s`, `val`, `v`, `vals`, `for values in values`) = redo. Output paste required — run all four assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Name both steps before touching the keyboard.

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps since escalation — lowest reps among active targets F3/A1/F1; id "F1" < "A1" < "F3" breaks the Band-2 tie). Last 3 days' F1 drills: `collect_scores_by_grade` (2026-05-29, collection-vs-loop-var face), `running_total` (2026-05-30, while-loop parameter-alias face), `filter_and_scale` (2026-06-01, define-name = use-name face). Today's drill targets the **default-args face** (A.6 Day 5 content: `None` sentinel + never reuse param name as loop var) — not prompted in the 3-day window.
