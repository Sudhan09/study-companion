---
last_updated: 2026-06-05T19:08:01+05:30
updated_by: study-spaced-rep-reminder
date: 2026-06-05
stale_flags: [active_weak_spots.md (~358h old — >72h threshold), room-to-improve/state/current_state.md (~333h old — >72h threshold)]
---

# Spaced rep — 2026-06-05

## Target
- **Weak spot:** F1 — Variable mix-up / naming (while-loop context: define a full-name variable on one line, use it under its full name on every subsequent line — never alias to a single character mid-loop)
- **Band:** 2 escalated (reps so far 0/2)
- **Source:** active_weak_spots.md (last_updated 2026-05-21T21:05:00+05:30) + room-to-improve/state/current_state.md (last_updated 2026-05-22T22:24:29+05:30)

> [STALE input — RTI state may be ahead]
> `active_weak_spots.md` is ~358h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-21.
> `room-to-improve/state/current_state.md` is ~333h old (>72h threshold) — values sourced from disk; confirm no manual updates since 2026-05-22.

## Drill prompt

[STALE inputs — active_weak_spots.md ~358h old, current_state.md ~333h old — RTI state may have advanced since last session (2026-05-22)]

**Spaced rep — F1: first_longer_than. Band 2. Reps 0/2. Write a while-loop function — every variable defined under its full name must be used under that exact full name on every subsequent line. No mid-loop aliasing to single chars.**

Write this function from scratch:

```python
def first_longer_than(words: list[str], threshold: int) -> str | None:
    ...
```

Returns the first string in `words` whose length exceeds `threshold`. Returns `None` if no such string exists or if `words` is empty.

**Step 1 — Name map first (mandatory, write as comments before any code):**

```python
# words:      input list parameter — stays 'words'; never 'word', 'ws', 'lst', 'items', 'w'
# threshold:  length cutoff parameter — stays 'threshold'; never 't', 'th', 'limit', 'n'
# index:      position counter for while loop — stays 'index'; never 'i', 'idx', 'ix'
# word:       words[index], one element drawn from the list — stays 'word'; never 'w', 'item', 'val', 'x'
```

**Step 2 — Write the function body.** Use a `while` loop (not a `for` loop — the while variant is the drill).

**The trap this drill tests (while-loop face of F1 escalation):**

The F1 escalation bugs on 2026-05-22 were both "define-name ≠ use-name" NameErrors:
- Defined variable as `mat`, referenced it as `m` one line later (D.3.3 — NameError)
- Function parameter named `num`, but range calls inside used `n` (E.1.4 — NameError)

In a while loop the same slip looks like this:

```python
# ❌ F1 slip pattern — define-name ≠ use-name
index = 0
while i < len(words):          # 'index' defined, 'i' used → NameError
    word = words[index]
    if len(w) > threshold:     # 'word' defined, 'w' used → NameError
        return w               # same bug
    i += 1                     # 'index' defined, 'i' used → NameError
```

vs

```python
# ✅ correct — define-name = use-name throughout
index = 0
while index < len(words):      # 'index' used everywhere
    word = words[index]
    if len(word) > threshold:  # 'word' used everywhere
        return word
    index += 1                 # 'index' used everywhere
```

**The four lines examined first on grade (in order):**
1. `while` condition — must say `while index < len(words):`, not `while i < ...`
2. Extraction line — must say `word = words[index]`, not `word = words[i]`
3. Check line — must say `if len(word) > threshold:`, not `len(w)` or `len(words[index])`
4. Increment line — must say `index += 1`, not `i += 1`

Any single-char alias for `index` or `word` = redo. Shortening `threshold` to `t` or `thresh` in the condition also = redo.

**Expected behaviour:**
```python
first_longer_than(["hi", "there", "Asta"], 3)
# → "there"  (len("there") = 5 > 3; "hi" skipped, "there" is first match)

first_longer_than(["hi", "yo", "ok"], 3)
# → None     (all lengths ≤ 3)

first_longer_than([], 3)
# → None     (empty input, while condition false immediately)

first_longer_than(["hello"], 4)
# → "hello"  (len("hello") = 5 > 4)
```

**Pass condition:** Step 1 comment map and Step 2 code are 1-to-1. Grading order:
1. `while` header — `index` in full, `words` in full
2. Extraction line — `word = words[index]`, both full names
3. Check line — `len(word) > threshold`, all three identifiers in full
4. Increment — `index += 1`, not `i += 1`

Any single-char alias for any named variable = redo. Output paste required — run all four assertions.

**Bonus (A1 keep-warm):** Before writing the loop body, state in one sentence: "For each iteration, I do X first, then Y." Name the two sub-steps (extract the word, then test it) before touching the keyboard. (A1 rep #3 of 3 toward Band 2 graduation is still open — naming the steps aloud keeps the pattern warm.)

## Selection rationale
F1 tops sort (Band 2 escalated, 0/2 reps since escalation — lowest reps_so_far among active targets; id "F1" < "F3" breaks the Band-2 tie; A1 at 2/3 reps sorts lower). Last 3-day window: `Pipeline` (2026-06-03, class-method/self.attribute face), `collect_unique` (2026-06-02, default-args/None-sentinel face), `make_profiles` (2026-06-04, parallel-list plural-to-singular face). None of those covered the **while-loop / define-name=use-name** face — the direct 2026-05-22 escalation trigger (`mat`/`m` NameError, `num`/`n` NameError). Last time this face ran was 2026-06-01 (`filter_and_scale`, for-loop variant). Today's drill uses a `while` loop, which also directly targets Day 5 Block C content (while family).
