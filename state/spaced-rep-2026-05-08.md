---
last_updated: 2026-05-08T00:31:20+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-08
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-08

## Target
- **Weak spot:** A1 — Multi-step loop body / recursive one-step transform not automatic
- **Band:** 2 escalated (reps so far 0/3 at Band 2, then 1 at Band 3)
- **Source:** active_weak_spots.md (last_updated 2026-05-06T20:00:00+05:30) [STALE — 28h old] + room-to-improve/state/current_state.md (last_updated 2026-05-06T20:00:00+05:30) [STALE — 28h old]

[STALE input — RTI state may be ahead]

## Drill prompt

[STALE] Spaced rep — A1: sum_of_digits. Band 2. Reps 0/3. Write sum_digits(n) recursively — name the one-step reduction first.

**Full spec:**

Write a function `sum_digits(n: int) -> int` that returns the sum of all digits of a non-negative integer using recursion.

Rules:
- No loops — recursion only.
- Before writing a single line of code, write a comment that names the one-step reduction: what is one digit you can extract, and what is the smaller version of `n` you recurse on?
- No imports. No built-ins other than `%` and `//`.

Example asserts (do NOT look at these until you've written the comment):
```python
assert sum_digits(0)    == 0
assert sum_digits(5)    == 5
assert sum_digits(123)  == 6
assert sum_digits(9999) == 36
```

Independence target: solve cold, no hints, under 10 minutes.

## Selection rationale
Highest band among active (all Band 2 escalated/watch); A1 has lowest reps_so_far (0/3) vs B2 (2/5) and F3 (0/3 sessions clean); A1 < F3 by id; first drill target (sum-of-digits) not prompted in last 3 days (no prior spaced-rep files found).
