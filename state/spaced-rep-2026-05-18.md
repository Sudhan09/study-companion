---
last_updated: 2026-05-18T19:07:44+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-18
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-18

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2 toward graduation)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30 ⚠️ STALE ~144h) + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30 ⚠️ STALE ~144h)

[STALE input — RTI state may be ahead; no session logged 2026-05-13 through 2026-05-17, stale by design not drift]

## Drill prompt

[STALE input ~144h — no sessions since 2026-05-12; stale by design not drift] Spaced rep — F3: two_sum_complement_check (variant 2). Band 2. Reps 0/2. Two problems — check-before-add order and correct `in`/`not in` direction. Operator comment mandatory before each function body.

**Full spec:**

The F3 trap: deciding too fast whether to use `in` or `not in`, and whether the membership check happens BEFORE or AFTER adding to the seen structure. Get both wrong together and you get silent false positives. The 2-line comment ritual forces the decision to be made consciously.

Before writing any code, write this 2-line comment block:

```python
# membership check: <'in' or 'not in'> — because <1-clause reason>
# order: check <BEFORE or AFTER> add — because <1-clause reason>
```

---

### Problem 1 — `count_pairs_with_diff`

```python
def count_pairs_with_diff(nums: list, k: int) -> int:
    ...
```

Return the count of unique index pairs `(i, j)` where `i < j` and `abs(nums[i] - nums[j]) == k`.

Rules:
- One pass with a set `seen`. For each number, check whether `num + k` or `num - k` is already in `seen`, then add `num` to `seen`.
- Write the 2-line operator comment first.
- Two checks per iteration: `num + k in seen` AND `num - k in seen` (both directions of the difference).

```python
assert count_pairs_with_diff([1, 5, 3, 4, 2], 2) == 3  # (1,3), (3,5), (2,4)
assert count_pairs_with_diff([1, 1, 1, 1], 0)    == 6  # all pairs (0,1),(0,2),(0,3),(1,2),(1,3),(2,3)
assert count_pairs_with_diff([1, 2, 3], 5)        == 0  # no pair
assert count_pairs_with_diff([], 1)               == 0  # empty
assert count_pairs_with_diff([3], 0)              == 0  # single element
```

---

### Problem 2 — `first_pair_summing_to`

```python
def first_pair_summing_to(nums: list, target: int) -> tuple:
    ...
```

Return the **values** `(a, b)` where `a` appears before `b` in `nums` and `a + b == target`. Return `(-1, -1)` if no such pair. Guaranteed at most one valid pair.

Rules:
- One pass with a set `seen`. Check `complement in seen` **before** adding the current number.
- Write the 2-line operator comment first.
- Return order matters: `a` is the element found in `seen`, `b` is the current element.

```python
assert first_pair_summing_to([2, 7, 11, 15], 9)   == (2, 7)   # 2 seen first, 7 current
assert first_pair_summing_to([4, 3, 2, 5], 7)      == (4, 3)   # 4 seen first
assert first_pair_summing_to([3, 3], 6)            == (3, 3)   # distinct indices, same value
assert first_pair_summing_to([1, 2, 3], 10)        == (-1, -1) # no pair
assert first_pair_summing_to([], 5)                == (-1, -1) # empty
```

---

**Independence target:** both cold, no hints, each under 10 minutes. Paste your output — "done" without paste is not a lock. Any operator slip (wrong `in`/`not in`, or reversed check/add order): name the slip before fixing. Same slip twice = STOP, name the pattern, do not continue.

## Selection rationale
F3 sorts above A1: both Band 2 escalated; F3 has 0 reps vs A1's 1 — lower reps_so_far takes priority. F3 drill #1 (set_membership_boolean_ops) prompted 2026-05-16 — within last 3 days, skipped. F3 drill #3 (upper_triangular_boundary) prompted 2026-05-15 — within last 3 days, skipped. F3 drill #2 (two_sum_complement_check) last prompted 2026-05-13 — outside last 3-day window → selected. Fresh variant composed (different problems from 2026-05-13 run) to avoid memorization.
