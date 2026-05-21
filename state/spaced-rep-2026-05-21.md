---
last_updated: 2026-05-21T19:10:58+05:30
updated_by: study-spaced-rep-reminder
date: 2026-05-21
stale_flags: [active_weak_spots.md, room-to-improve/state/current_state.md]
---

# Spaced rep — 2026-05-21

## Target
- **Weak spot:** A1 — Multi-step loop body (one-step transform not automatic)
- **Band:** 2 escalated (reps so far 1/3 toward graduation)
- **Source:** active_weak_spots.md (last_updated 2026-05-12T16:30:00+05:30 ⚠️ STALE ~9d) + room-to-improve/state/current_state.md (last_updated 2026-05-12T16:00:00+05:30 ⚠️ STALE ~9d)

[STALE input ~216h — no sessions since 2026-05-12; stale by design not drift]

## Drill prompt

[STALE input ~216h — no sessions since 2026-05-12; stale by design not drift] Spaced rep — A1: dict_accumulator_pattern. Band 2. Reps 1/3. Two functions — `word_frequency` and `group_by_length` — using the multi-step dict accumulator body. Write the body STEP by STEP comment before any code.

**The A1 trap:** you know the loop skeleton. You know `.get()`. The failure mode is collapsing the multi-step body into a one-liner guess without naming the steps — "look up current → compute new → store back." Naming them first forces the assembly. Write this 3-line comment block before each function body:

```python
# step 1: look up current value (what key? what default?)
# step 2: compute new value (what operation?)
# step 3: store back (same key)
```

---

### Problem 1 — `word_frequency`

```python
def word_frequency(text: str) -> dict:
    ...
```

Given a string of space-separated words, return a dict mapping each word to how many times it appears. Case-sensitive. Preserve whatever case the input uses.

Rules:
- Single loop over `text.split()`.
- Use `dict.get(key, 0) + 1` pattern (no `Counter`, no `defaultdict` — use plain dict).
- Write the 3-line step comment before the loop body.

```python
assert word_frequency("the cat sat on the mat") == {"the": 2, "cat": 1, "sat": 1, "on": 1, "mat": 1}
assert word_frequency("a a a")                  == {"a": 3}
assert word_frequency("one")                    == {"one": 1}
assert word_frequency("")                       == {}
```

---

### Problem 2 — `group_by_length`

```python
def group_by_length(words: list) -> dict:
    ...
```

Given a list of strings, return a dict mapping each word-length (int) to a list of words that have that length. Order within each list must match the order words appear in the input.

Rules:
- Single loop.
- Use `dict.setdefault(key, [])` + `.append()` pattern (no `defaultdict` — use plain dict).
- Write the 3-line step comment before the loop body.

```python
assert group_by_length(["hi", "go", "hey", "run", "ok"]) == {2: ["hi", "go", "ok"], 3: ["hey", "run"]}
assert group_by_length(["a"])                             == {1: ["a"]}
assert group_by_length([])                               == {}
assert group_by_length(["ab", "cd", "ef"])               == {2: ["ab", "cd", "ef"]}
```

---

**Independence target:** both cold, no hints, each under 10 minutes. Paste your output — "done" without paste is not a lock. If you write the loop body before the 3-line step comment: automatic redo. Same assembly error twice = STOP, name the pattern (A1), don't continue.

## Selection rationale

F3 (Band 2, 0/2 reps) sorts above A1 (Band 2, 1/3 reps) — lower reps_so_far takes priority. However, all three F3 drill targets were prompted within the last 3 days (drill #2 on 2026-05-18, drill #3 on 2026-05-19, drill #1 on 2026-05-20) — no F3 target available outside the 3-day window. Fall through to A1. A1 drill #1 (dict accumulator: word_frequency / group_by_length) not prompted in any spaced-rep file in last 3 days → selected.
