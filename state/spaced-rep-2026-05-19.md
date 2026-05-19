---
last_updated: 2026-05-19T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-19
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-19

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30) [STALE ~7d] + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30) [STALE ~7d]

[STALE input ~168h — no sessions since 2026-05-12; stale by design not drift]

## Drill prompt

[STALE input ~168h — no sessions since 2026-05-12; stale by design not drift] Spaced rep — F3: upper_triangular_boundary. Band 2. Reps 0/2. Write `find_closest_pair(nums)` — iterate all unique unordered pairs, return the pair with smallest absolute difference. Constraint: use `j > i` (not `j != i`). Mandatory: write a 1-line comment above the inner loop explaining WHY `j > i` prevents double-counting.

```
# Starter skeleton (fill in the body):
def find_closest_pair(nums):
    best_diff = float('inf')
    best_pair = None
    for i in range(len(nums)):
        for j in range(???):   # ← what goes here, and why?
            ...
    return best_pair

# Asserts:
assert find_closest_pair([4, 1, 7, 3]) == (3, 4)   # diff 1
assert find_closest_pair([10, 2, 5, 8]) == (8, 10)  # diff 2
assert find_closest_pair([1, 5, 3]) == (1, 3)        # diff 2
```

Pass condition: correct output on all 3 asserts, `j > i` used (not `j != i`), and the WHY comment is present.

## Selection rationale

Highest band among active (Band 2), lowest reps_so_far (0/2 vs A1's 1/3); F3 alphabetically first among Band-2/0-rep ties. Drill targets 1 (set_membership_boolean_ops, 2026-05-16) and 2 (two_sum_complement_check, 2026-05-18) both prompted within last 3 days — skipped to target 3 (upper_triangular_boundary), not prompted in last 3 days.
