# 🔁 Loop Week — Day 6: Mini-Problems Day (Phase 3b Final Boss + Synthesis)

> **Theme:** The proving ground. Days 1-5 built the toolkit. Day 6 is where you solve real problems cold, with every pattern fair game, and prove that loops are now a tool you reach for instinctively rather than a topic you study. No new concepts. Pure application. Phase 3b L8 (mixed synthesis) and Final Boss territory.
>
> **Time budget:** 7-8 focused hours
>
> **Phase 3b coverage:** L8 (Mixed synthesis drills) + Final Boss (P8 + P15 + bonus)
>
> **Day 6 has a different shape than Days 1-5.** No fundamentals block. No wrap block. No separate mini-boss — the Final Boss IS the mini-boss. Pure problem-solving rounds at increasing difficulty.
>
> **Day 6 is the truth-teller.** If Round 1 wobbles, Days 1-2 didn't lock. If Round 6 wobbles, Phase 3b isn't done. Honesty over comfort.

---

## 🎯 Day 6 Learning Goals

By end of day, you should be able to **without notes**:

1. Solve a single-pattern problem in under 5 minutes cold (Round 1)
2. Solve a multi-pattern stacked problem in under 15 minutes cold (Rounds 2-3)
3. Recognize when nested loops are wrong — reach for hash map automatically (Round 5)
4. Solve any visual loop pattern (triangle, diamond, hollow shape) cold (Round 4)
5. Solve P8 (Multiplication Table, formatted) cold — Phase 3b Final Boss A
6. Solve P15 (Diamond, height 5) cold — Phase 3b Final Boss B
7. Handle edge cases without prompting (empty, single, all-duplicate)
8. Refactor any solution > 30 lines into helper functions
9. Pass Round 1 cold-clean — proving Days 1-2 are locked
10. Pass Round 6 cold-clean — closing Phase 3b officially

---

## 🗓 Day 6 Time Layout

| Block | Time | Content |
|---|---|---|
| **Round 1 — Warmup** | 45 min | 3 single-pattern problems (Days 1-2 verification) |
| **Round 2 — Pattern Stacking** | 75 min | 3 multi-pattern problems (Day 2 + Phase 3b L3) |
| **Round 3 — Multi-Tracker (Phase 3c absorbed)** | 75 min | 2 problems requiring 3+ trackers in one pass |
| **Round 4 — Variable-Width Shapes** | 60 min | 2 visual loop problems (Phase 3b L4 + L4.5) |
| **Round 5 — Performance Refactor** | 45 min | 2 brute-force → hash refactors |
| **Round 6 — FINAL BOSS** | 45 min | P8 + P15 cold (Phase 3b exit gate) |
| **Optional Round 7 — Interview Flavor** | 30 min | 1 LeetCode-shaped problem if Rounds 1-6 went clean |

Total: ~7 hours (Round 7 optional pushes to 7.5).

---

## 🚦 Day 6 Discipline Rules

These carry from Days 1-5 but apply STRICTER on Day 6:

1. **Every problem solved as a function from the start.** No top-level scripts. Clean signatures.
2. **Edge cases must be handled** — empty input, single element, all-duplicates. The function should never crash on degenerate input. It should return the natural empty/zero/None value.
3. **Both `for` and `while` versions on at least 3 problems** — equal-footing rule stays alive.
4. **Any solution > 30 lines triggers a refactor** — decompose into helpers. Day 5's discipline pays dividends.
5. **No notes from this chat.** Day 6 is cold. The point is to prove Days 1-5 actually landed.

---

## 🔥 ROUND 1 — WARMUP (45 min)

**Difficulty:** Easy. Single-pattern. Should solve cold without strikes.
**Goal:** Verify Days 1-2 didn't decay overnight.
**Pass condition:** All 3 cold-clean. Any strike → flag as decay.

---

### Problem 1.1 — Second Largest

Write `second_largest(lst)` returning the second largest distinct value, or `None` if the list has fewer than 2 distinct values.

```python
second_largest([3, 1, 4, 1, 5, 9, 2, 6])    # → 6
second_largest([5, 5, 5])                    # → None
second_largest([])                           # → None
second_largest([7])                          # → None
second_largest([7, 7, 3])                    # → 3
```

**Pattern:** Tracker (two trackers — `largest` and `second`).
**From:** Day 1 Block B.

**Hint if stuck:** Don't sort. Walk once, maintain two trackers.

---

### Problem 1.2 — Word Frequency

Write `word_frequency(text)` returning a dict of word → count. Words separated by whitespace. Case-insensitive.

```python
word_frequency("the cat and the dog and the bird")
# → {"the": 3, "cat": 1, "and": 2, "dog": 1, "bird": 1}

word_frequency("HELLO hello Hello")
# → {"hello": 3}

word_frequency("")
# → {}
```

**Pattern:** Frequency counting (Day 2).
**From:** Day 2 Block B.2 Pattern 1.

**Hint if stuck:** `text.lower().split()` gives you the word list. Then `Counter` or manual frequency build.

---

### Problem 1.3 — Reverse Each Word

Write `reverse_each_word(sentence)` returning a string where each word is reversed but the word order is preserved.

```python
reverse_each_word("hello world")             # → "olleh dlrow"
reverse_each_word("Python is fun")           # → "nohtyP si nuf"
reverse_each_word("a")                       # → "a"
reverse_each_word("")                        # → ""
reverse_each_word("racecar level")           # → "racecar level" (palindromes!)
```

**Patterns:** String split + reverse (slicing) + join.
**From:** Day 3.

**Hint if stuck:** Split → list comprehension reversing each → join with space.

---

## 🥞 ROUND 2 — PATTERN STACKING (75 min)

**Difficulty:** Medium. 2-3 patterns combined.
**Goal:** Prove pattern composition is automatic.
**Phase 3b L3 territory.**

---

### Problem 2.1 — Find Duplicates

Write `find_duplicates(lst)` returning a sorted list of values that appear more than once.

```python
find_duplicates([1, 2, 3, 2, 4, 1, 5])       # → [1, 2]
find_duplicates([1, 2, 3, 4])                # → []
find_duplicates([1, 1, 1, 1])                # → [1]
find_duplicates([])                          # → []
```

**Patterns:** Frequency dict + filter + sort.
**Two solution paths:**
- **A:** Use `Counter` then filter keys with count > 1
- **B:** Use two sets — `seen` and `duplicates`

Solve BOTH ways. Compare line counts.

---

### Problem 2.2 — Group Anagrams

Write `group_anagrams(words)` returning a list of groups, where each group is a list of words that are anagrams of each other.

```python
group_anagrams(["eat", "tea", "tan", "ate", "nat", "bat"])
# → [["eat", "tea", "ate"], ["tan", "nat"], ["bat"]]
# (group order can vary; word order within groups can vary)

group_anagrams([])                # → []
group_anagrams(["abc"])           # → [["abc"]]
group_anagrams(["a", "b", "c"])   # → [["a"], ["b"], ["c"]]
```

**Patterns:** Grouping + dict-with-tuple-key + comprehension (optional).
**From:** Day 2 Block B.2 Pattern 2 + Day 3 anagram concept.

**Hint if stuck:** Use the sorted-tuple-of-chars as the dict key. `defaultdict(list)` is cleanest.

---

### Problem 2.3 — Two-Sum: Brute Force vs Hash

Write BOTH solutions and compare.

**Part A — Brute force (nested loops, O(n²)):**
```python
def two_sum_brute(nums, target):
    # Return (i, j) of first pair summing to target.
    # Use upper-triangular nested loops.
    ...
```

**Part B — Hash (single pass, O(n)):**
```python
def two_sum_hash(nums, target):
    # Same return value — but using a dict to track seen values.
    ...
```

Test both with:
```python
two_sum_brute([2, 7, 11, 15], 9)             # → (0, 1)
two_sum_hash([2, 7, 11, 15], 9)              # → (0, 1)

two_sum_brute([3, 2, 4], 6)                  # → (1, 2)
two_sum_hash([3, 2, 4], 6)                   # → (1, 2)

two_sum_brute([1, 2, 3], 100)                # → None
two_sum_hash([1, 2, 3], 100)                 # → None
```

**Bonus:** Time both on a list of 5000 random numbers. Note the speed difference.

**Patterns:** Search inside nested (brute) + frequency hash (hash).
**From:** Day 2 Block B.3 (the mindset shift).

---

## 🎯 ROUND 3 — MULTI-TRACKER (Phase 3c absorbed) (75 min)

**Difficulty:** Medium-hard. Multi-tracker, parallel iteration, the P10-style problems.
**Goal:** Lock the multi-tracker skill that Phase 3c was originally for.

---

### Problem 3.1 — Parallel Grading (the original P10)

Given parallel lists of student names and their grades, plus a class average, in a SINGLE pass through the data:

- Find the highest scorer (name + score)
- Find the lowest scorer (name + score)
- Count students above average
- Count students below average
- Count students at exactly average
- Compute total of all grades

Return as a dict.

```python
def grade_summary(names, grades, class_avg):
    ...

names = ["Alice", "Bob", "Charlie", "Diana", "Eve"]
grades = [85, 70, 92, 60, 78]
class_avg = 77

grade_summary(names, grades, class_avg)
# → {
#     "highest": ("Charlie", 92),
#     "lowest": ("Diana", 60),
#     "above": 2,    # Alice, Charlie
#     "below": 2,    # Bob, Diana
#     "at": 0,
#     "total": 385
#   }
```

**Patterns:** 4+ trackers running concurrently + `zip` + accumulator.
**From:** Phase 3c absorbed into Day 6.

**Discipline check:** ONE pass through the data. If you wrote 5 separate loops, refactor. Use `zip(names, grades)` to walk both lists in lockstep.

**Edge cases to handle:**
- Empty lists → return zeroes/None for trackers
- Single student → `highest == lowest`

---

### Problem 3.2 — Stock Buy-Sell

Given a list of stock prices over time, find the maximum profit possible from a single buy followed by a single sell. Return 0 if no profit is possible.

```python
def max_profit(prices):
    ...

max_profit([7, 1, 5, 3, 6, 4])                # → 5  (buy at 1, sell at 6)
max_profit([7, 6, 4, 3, 1])                   # → 0  (only descending — no profit)
max_profit([1, 2, 3, 4, 5])                   # → 4  (buy at 1, sell at 5)
max_profit([])                                # → 0
max_profit([5])                               # → 0
```

**Patterns:** Two trackers — `min_so_far` and `max_profit_so_far` — single pass.
**The trap:** Don't use nested loops to compare every pair. That's O(n²) and wrong.

**Hint if stuck:** As you walk the list, ask: "What's the lowest price I've seen so far? What's the best profit if I sold today?"

---

## 🔺 ROUND 4 — VARIABLE-WIDTH SHAPES (60 min)

**Difficulty:** Medium. Phase 3b L4 / L4.5 boss-equivalent under timed cold conditions.
**Goal:** Prove visual loops are now reflexive.

---

### Problem 4.1 — Hollow Diamond

Print a hollow diamond of `*`, height 5 (9 rows total). Only border cells show `*`; interior cells show space.

Expected output:

```
    *
   * *
  *   *
 *     *
*       *
 *     *
  *   *
   * *
    *
```

**Patterns:** Pyramid + inverted pyramid + conditional inside inner loop.
**From:** Day 3 Block D.4 (hollow shapes) extended.

**Hint if stuck:** Same skeleton as solid diamond, but inner loop prints `*` only at the first and last position of each row's content; otherwise prints space.

---

### Problem 4.2 — Pascal's Triangle

Generate the first `n` rows of Pascal's Triangle. Each cell is the sum of the two cells above it. Edges are always 1.

```python
def pascal_triangle(n):
    # Return list of lists. row[0] = [1]. row[i] for i > 0 builds from row[i-1].
    ...

pascal_triangle(1)
# → [[1]]

pascal_triangle(5)
# → [[1],
#    [1, 1],
#    [1, 2, 1],
#    [1, 3, 3, 1],
#    [1, 4, 6, 4, 1]]

pascal_triangle(0)
# → []
```

**Patterns:** Variable-width nested + neighbour access (row[i] depends on previous row[i-1] and previous row[i]).
**From:** Day 1 (lists) + Day 3 (neighbour access from strings, applied here to lists).

**Hint if stuck:** Row 0 is `[1]`. Each subsequent row starts with 1, ends with 1, and the middle elements come from the previous row's adjacent pairs.

---

## ⚡ ROUND 5 — PERFORMANCE REFACTOR (45 min)

**Difficulty:** Mixed.
**Goal:** Prove you can spot O(n²) and refactor to O(n) using hash maps.

---

### Problem 5.1 — Contains Duplicate (within k distance)

Given a list and a value `k`, return `True` if there are two distinct indices `i` and `j` such that `lst[i] == lst[j]` AND `abs(i - j) <= k`.

```python
def contains_nearby_duplicate(lst, k):
    ...

contains_nearby_duplicate([1, 2, 3, 1], 3)        # → True (1 at indices 0 and 3, distance 3)
contains_nearby_duplicate([1, 0, 1, 1], 1)        # → True (1 at indices 2 and 3, distance 1)
contains_nearby_duplicate([1, 2, 3, 1, 2, 3], 2)  # → False (closest duplicates are 3 apart)
contains_nearby_duplicate([], 5)                  # → False
contains_nearby_duplicate([1], 0)                 # → False
```

**Two solution paths:**
- **A — Brute force (O(n*k) or O(n²)):** Nested loops.
- **B — Hash with index tracking (O(n)):** Dict mapping value → most recent index.

Solve BOTH. Compare.

**Performance lesson:** If `k` is small (say 5) and `n` is huge (1 million), the brute force is O(n*k) = 5 million ops, which is acceptable. If `k` is close to `n`, brute force is O(n²) = 10¹². Hash version is O(n) = 1 million regardless.

---

### Problem 5.2 — Longest Substring Without Repeating Characters

Given a string, return the length of the longest substring with no repeated characters.

```python
def longest_unique_substring(s):
    ...

longest_unique_substring("abcabcbb")   # → 3  ("abc")
longest_unique_substring("bbbbb")      # → 1  ("b")
longest_unique_substring("pwwkew")     # → 3  ("wke")
longest_unique_substring("")           # → 0
longest_unique_substring("a")          # → 1
```

**Two solution paths:**
- **A — Brute force (O(n³)):** Nested loops checking every substring.
- **B — Sliding window with set (O(n)):** Two pointers, set tracks current window.

Solve BOTH if time allows; otherwise just Solution B (the real interview answer).

**Patterns:** Two-pointer + set membership + tracker.
**From:** Day 2 (sets) + Day 3 (two-pointer) + tracker pattern.

**Hint if stuck:** Maintain a window `[left, right]`. Expand right while chars are unique. When a duplicate appears, shrink from left until the duplicate is gone. Track max window size seen.

---

## 🏆 ROUND 6 — FINAL BOSS (45 min)

**This is the Phase 3b exit gate.** Both problems must be cold-clean (or with at most one self-corrected bug each) for Phase 3b to officially close.

**Strikes here are weighted:** 1 strike on either problem → loop back to Day 3 (shapes) before attempting the next.

---

### Final Boss A — P8: Multiplication Table (Formatted)

Print a 10×10 multiplication table with aligned columns. Use `f"{x:4d}"` for 4-character right-aligned formatting.

Expected output:

```
   1   2   3   4   5   6   7   8   9  10
   2   4   6   8  10  12  14  16  18  20
   3   6   9  12  15  18  21  24  27  30
   4   8  12  16  20  24  28  32  36  40
   5  10  15  20  25  30  35  40  45  50
   6  12  18  24  30  36  42  48  54  60
   7  14  21  28  35  42  49  56  63  70
   8  16  24  32  40  48  56  64  72  80
   9  18  27  36  45  54  63  72  81  90
  10  20  30  40  50  60  70  80  90 100
```

**Tests:** Phase 3b L1 (mental model) + L2 (for × for) + Day 4 (f-string format specs).

**Discipline:** Wrap as `def multiplication_table(size=10):` — accept variable size, default 10. Return the string OR print it (your choice — defend your choice).

---

### Final Boss B — P15: Diamond Pattern, Height 5

Print a SOLID diamond of `*`, height 5 (9 rows total). Use the two-loop-per-row pattern.

Expected output:

```
    *
   ***
  *****
 *******
*********
 *******
  *****
   ***
    *
```

**Tests:** Phase 3b L4 + L4.5 (variable-width + pyramid + diamond stacking).

**Discipline:** Wrap as `def diamond(height):`. Handle edge cases: `height=0` → empty output. `height=1` → single `*`. `height=2` → `*\n***\n*` (3 rows).

---

## 🌟 ROUND 7 — OPTIONAL INTERVIEW FLAVOR (30 min)

Only attempt if Rounds 1-6 went clean. ONE problem cold. This is real LeetCode Easy/Medium difficulty.

**Pick ONE:**

### Option A — Valid Palindrome (LeetCode #125)

Write `is_palindrome_alphanum(s)` returning `True` if the string is a palindrome considering only alphanumeric characters and ignoring case.

```python
is_palindrome_alphanum("A man, a plan, a canal: Panama")    # → True
is_palindrome_alphanum("race a car")                         # → False
is_palindrome_alphanum(" ")                                  # → True (vacuously)
is_palindrome_alphanum("0P")                                 # → False ('0' vs 'p')
```

**This is identical to Day 3's Mini-Boss B.** If you nailed it then, lock it again. If not, this is the second chance.

---

### Option B — First Missing Positive (LeetCode #41 — Hard)

Given an unsorted list of integers, find the smallest missing positive integer. Aim for O(n) time and O(1) auxiliary space.

```python
first_missing_positive([1, 2, 0])             # → 3
first_missing_positive([3, 4, -1, 1])         # → 2
first_missing_positive([7, 8, 9, 11, 12])     # → 1
first_missing_positive([])                    # → 1
first_missing_positive([1])                   # → 2
```

**This is genuinely hard.** Use the in-place index-as-hash trick: place each number `n` at index `n-1`, then scan for the first index where `lst[i] != i+1`.

If you crack this cold on Day 6, that's a serious signal — interview-ready on this class of problem.

---

### Option C — Best Time to Buy and Sell Stock II (LeetCode #122)

Given prices, find max profit from MULTIPLE buy-sell transactions (one stock at a time, must sell before buying again).

```python
max_profit_multi([7, 1, 5, 3, 6, 4])     # → 7  (buy 1, sell 5; buy 3, sell 6)
max_profit_multi([1, 2, 3, 4, 5])        # → 4  (buy 1, sell 5)
max_profit_multi([7, 6, 4, 3, 1])        # → 0
```

**Trick:** Sum every positive consecutive difference. Don't actually simulate transactions.

---

## 📋 Day 6 Tracker Recap (paste into progress_tracker.md)

```
Day 6 of Loop Week — Mini-Problems Day + Phase 3b Final Boss

Round results:
- Round 1 (warmup, 3 problems): ✓/✗ each
- Round 2 (pattern stacking, 3 problems): ✓/✗ each
- Round 3 (multi-tracker, 2 problems): ✓/✗ each — THIS WAS PHASE 3C
- Round 4 (variable-width shapes, 2 problems): ✓/✗ each
- Round 5 (performance refactor, 2 problems): ✓/✗ each
- Round 6 FINAL BOSS:
  - P8 multiplication table: ✓/✗
  - P15 diamond: ✓/✗

Phase 3b status: [CLEARED / PARTIAL / NEEDS REWORK]

Optional Round 7: [ATTEMPTED Y/N — which option — outcome]

Total problems solved cold (no strikes): X / 12
Total strikes triggered: X
Weak patterns flagged: [fill in — e.g. multi-tracker, hash refactor instinct]

Tomorrow's bridge: Day 7 — integration project + week review
```

---

## 🚦 Day 6 Pass/Fail Rules

**Round 1 (warmup):**
- All 3 cold-clean → Days 1-2 locked, proceed
- 1 strike on any → light flag, proceed but watch
- 2+ strikes total in Round 1 → stop, re-drill Days 1-2 fundamentals

**Rounds 2-5:**
- Standard 3-strike rule per problem
- Track which patterns trigger strikes — those are weak spots for Day 7 review

**Round 6 (Final Boss):**
- Both problems cold-clean (or with one self-corrected bug) → Phase 3b CLEARED
- Strike on either → loop back to Day 3 (shapes) before re-attempting
- If Phase 3b doesn't clear today → Day 7 includes a Phase 3b re-attempt block

**Round 7 (optional):**
- No pass/fail — pure data on interview readiness
- A clean solve here is a strong signal; a struggle is fine and expected

---

## 🧠 Day 6 Memory Hooks

- *"Day 6 is the proving ground. No new tools. Every loop is a tool I already know."*
- *"If I'm reaching for nested loops on a frequency or pair-sum problem, I'm doing it wrong. Reach for the hash map."*
- *"One pass beats five separate loops. Multi-tracker over multi-loop."*
- *"Edge cases are a discipline check, not an afterthought."*
- *"Solution > 30 lines? Refactor into helpers. Day 5 paid for the privilege."*
- *"Round 1 strikes = decay. Round 6 strikes = Phase 3b not done."*

---

## 🔮 What unlocks after Day 6

- **Day 7 (Project)** — integration day. Composing functions and classes into a working program. The patterns drilled today become tools used together.
- **Phase 3b OFFICIALLY CLOSED** (assuming Round 6 clean) — every nested-loop concept, every range tier, every shape pattern locked
- **Resume Day 16+** — backtracking and divide-and-conquer no longer feel intimidating; they're just nested patterns at a higher abstraction
- **Week 4+ readiness** — hash map / two-pointer / sliding window problems on LeetCode become routine
- **Real coding** — when faced with any list/dict/string problem, the right pattern surfaces in seconds

---

*End of Day 6 curriculum. The proving ground awaits.*
