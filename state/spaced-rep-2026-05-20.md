---
last_updated: 2026-05-20T19:02:21+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-20
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-20

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2 toward graduation)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30 ⚠️ STALE ~8d) + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30 ⚠️ STALE ~8d)

[STALE input ~192h — no sessions since 2026-05-12; stale by design not drift]

## Drill prompt

[STALE input ~192h — no sessions since 2026-05-12; stale by design not drift] Spaced rep — F3: set_membership_boolean_ops (cycle 2 variant). Band 2. Reps 0/2. Three problems on operator decisions — mandatory 1-line operator comment before each function body.

**The F3 trap:** every slip on 2026-05-12 was an operator decision made too fast — `>` vs `>=`, wrong `in`/`not in` direction, wrong `and`/`or` short-circuit. Protocol: write the 1-line operator comment BEFORE the function body. The comment is the target, not a box-tick.

Operator comment format (required for all three problems):
```
# operator: <which one> — because <1-clause reason>
```

---

### Problem 1 — `filter_above_threshold`

```python
def filter_above_threshold(nums: list, threshold: int) -> list:
    ...
```

Return a list of all numbers **strictly above** `threshold`. The threshold itself does NOT count.

Rules: single loop, one operator decision. Write the operator comment first — `>` or `>=`?

```python
assert filter_above_threshold([1, 5, 3, 7, 5], 5) == [7]        # 5 itself excluded
assert filter_above_threshold([1, 2, 3], 0)        == [1, 2, 3]  # all above 0
assert filter_above_threshold([4, 4, 4], 4)        == []         # none strictly above
assert filter_above_threshold([], 10)              == []         # empty
```

---

### Problem 2 — `in_both`

```python
def in_both(items: list, pool_a: list, pool_b: list) -> list:
    ...
```

Return elements from `items` that appear in **both** `pool_a` and `pool_b`. Order of `items` preserved.

Rules: convert both pools to sets first (O(1) membership), then single loop over `items`. Operator comment: which operator connects the two membership checks — `and` or `or`?

```python
assert in_both([1, 2, 3, 4], [1, 2, 3], [2, 3, 4])   == [2, 3]
assert in_both([1, 2, 3], [1, 2], [3, 4])             == []       # nothing in both
assert in_both([], [1, 2], [2, 3])                     == []       # empty items
assert in_both([1, 1, 2], [1, 2], [1, 3])             == [1, 1]   # duplicates preserved
```

---

### Problem 3 — `any_absent`

```python
def any_absent(query: list, reference: list) -> bool:
    ...
```

Return `True` if **at least one** element in `query` is NOT present in `reference`. Return `False` if every element is present.

Rules: convert `reference` to a set, then single loop over `query`. Operator comment must name: `in` or `not in`, AND the early-return direction — do you return `True` early or `False` early?

```python
assert any_absent([1, 2, 5], [1, 2, 3, 4]) == True   # 5 missing
assert any_absent([1, 2, 3], [1, 2, 3, 4]) == False  # all present
assert any_absent([], [1, 2])              == False  # vacuous — nothing to be absent
assert any_absent([1], [])                == True   # reference empty, 1 is absent
```

---

**Independence target:** all three cold, no hints, each under 10 minutes. Paste output — "done" without paste is not a lock. Any operator slip: name it before fixing. Same slip twice = STOP, name the pattern, don't continue.

## Selection rationale

F3 sorts above A1: both Band 2 escalated; F3 has 0 reps vs A1's 1 — lower reps_so_far takes priority. F3 drill #2 (two_sum_complement_check) prompted 2026-05-18, drill #3 (upper_triangular_boundary) prompted 2026-05-19 — both within last 3 days, skipped. Drill #1 (set_membership_boolean_ops) last prompted 2026-05-16 — outside 3-day window → selected. Fresh variant (different problems from 2026-05-16 run) to prevent memorization.
