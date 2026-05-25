---
last_updated: 2026-05-25T19:00:00+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-25
stale_flags: [active_weak_spots.md (84h old — >72h threshold), room-to-improve/state/current_state.md (60h old — >24h threshold)]
---

# Spaced rep — 2026-05-25

## Target
- **Weak spot:** F1 — Variable mix-up / naming (define-name = use-name; singular loop var vs plural collection)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is 84h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is 60h old (>24h threshold).

## Drill prompt

[STALE inputs — active_weak_spots.md 84h old, current_state.md 60h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: group_by_length. Band 2. Reps 0/2.**

Write this function from scratch:

```python
def group_by_length(words: list[str]) -> dict[int, list[str]]:
    ...
```

**Rules (enforced — this is what the drill is testing):**
1. Parameter name stays `words` from signature to last use. No aliasing.
2. Loop variable is `word` (singular of `words`). Not `w`, not `item`, not `words[i]`.
3. Accumulator dict is `groups` — not `result`, not `d`, not `g`.
4. If any helper variable is introduced, it must have a name that matches exactly what it holds — no short-hand abbreviations.
5. Write the define-to-use path for each name out loud as a comment before coding:
   ```python
   # words: input list, stays 'words' throughout
   # word: one element from words (singular)
   # groups: the dict being built
   # length: int key — word's length
   ```

**Then write the function body.**

Expected behaviour:
```python
group_by_length(["hi", "bye", "go", "hello", "ok"])
# → {2: ["hi", "go", "ok"], 3: ["bye"], 5: ["hello"]}
```

**Pass condition:** zero naming mismatches — the comments must match the code 1-to-1. A single `w = words[0]`-style abbreviation is a redo.

## Selection rationale
Highest band among active (Band 2 escalated), lowest reps_so_far: F1 and F3 tied at 0/2 — F1 wins on id asc (F1 < F3). F3 was also prompted on 2026-05-22 and 2026-05-23; F1 not prompted in last 3 days.
