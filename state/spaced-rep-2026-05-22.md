---
last_updated: 2026-05-22T19:08:58+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-22
stale_flags: []
---

# Spaced rep — 2026-05-22

## Target
- **Weak spot:** F3 — Operator/condition confusion
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T20:38:09+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-21T21:05:00+05:30)

## Drill prompt

Spaced rep — F3: range_len_refactors. Band 2. Reps 0/2. Refactor the 3 snippets below — each misuses `range(len(...))`. Before each refactored version write exactly ONE comment line naming: (a) the anti-pattern, and (b) any `<` vs `<=` or `+1` boundary decision you make.

```python
# Snippet 1
for i in range(0, len(nums), 1):
    print(nums[i])

# Snippet 2
pairs = []
for i in range(len(a)):
    pairs.append((a[i], b[i]))

# Snippet 3
result = []
for i in range(len(words)):
    if len(words[i]) > 3:
        result.append(words[i])
```

Rules:
- No `range(len(...))` in any refactored version.
- Comment line must be above the refactored loop, not below.
- Parallel iteration (Snippet 2) must use `zip` — name the boundary: does `zip` stop at the shorter or longer sequence?
- Filter refactor (Snippet 3) must be a comprehension — name the `>` vs `>=` decision for `> 3`.

This is an F3 earn-back rep. Every operator decision stated aloud counts.

## Selection rationale
Highest band among active (Band 2 escalated), lowest reps_so_far (0/2). Drill target #1 from F3's list — not prompted in last 3 days (May-19 was `upper_triangular_boundary`, May-20 was `set_membership_boolean_ops` covering target #4, May-21 was A1).
