# 🔁 Loop Week — Day 1: Lists, Tuples & Nested Loop Foundations

> **Theme:** Lock loop fluency on lists. Every loop form × every list pattern. End the day able to walk a list in any direction, with any technique, wrapped in functions or classes.
>
> **Time budget:** 6-7 focused hours
>
> **Phase 3b coverage:** L1 (Mental model + Range Tier 1-2) + L2 (for × for + Range Tier 4)
>
> **Mini-boss:** 5×5 coord grid + 6×6 even-cell grid, both cold

---

## 🎯 Day 1 Learning Goals

By end of day, you should be able to **without notes**:

1. Walk any list using for-each, index, enumerate, while+index, or while-pop
2. Use every list method correctly (sort/sorted, copy/deepcopy, append/extend/insert, etc.)
3. Slice lists in any direction with positive/negative indices and steps
4. Spot mutability traps (aliasing, modify-while-iterate, mutable defaults, shallow copy)
5. Write nested for loops with correct naming (`i`, `j`) and tracing
6. Generate all-pairs from one list (pair permutations) and from two lists (Cartesian)
7. Apply Counter / Tracker / Search / Filter / Accumulator inside any loop form
8. Wrap any loop solution in a function with clean parameters and return value
9. Wrap stateful loop logic in a class when state needs to persist

---

## 🗓 Day 1 Time Layout

| Block | Time | Content |
|---|---|---|
| **Block A — Morning** | 1.5 hr | List fundamentals + methods + slicing + mutability traps |
| **Block B — Midday** | 1.5 hr | Loop forms × lists (every base pattern, drilled) |
| **Block C — Afternoon** | 2 hr | Phase 3b L1 + L2 — Nested loops on lists, range tiers 1-2-4 |
| **Block D — Wrap Block** | 1.5 hr | Loops inside functions + classes (1-2 hr daily commitment) |
| **Block E — Evening Mini-Boss** | 30 min | 5×5 coord grid + 6×6 even-cell grid cold |

Total: ~7 hours. Adjust breaks as needed.

---

## 📚 Block A — List Fundamentals (1.5 hr)

### A.1 — Creation & access (15 min)

**Topics:**
- Literal: `[1, 2, 3]`
- From iterable: `list(range(5))`, `list("abc")`
- Empty list: `[]` vs `list()`
- Nested: `[[1,2], [3,4]]`
- Indexing: `lst[0]`, `lst[-1]`
- Length: `len(lst)`

**Drill problems:**
1. Create a list of integers 1 to 20 using `range`. Print first, last, middle elements.
2. Create a 3×3 nested list (matrix) of zeros. Access center element.
3. Given `lst = [10, 20, 30, 40, 50]`, print `lst[0]`, `lst[-1]`, `lst[2]`, `lst[-2]`. Predict before running.

### A.2 — Slicing deep (20 min)

**Topics:**
- `lst[start:stop:step]` — every variation
- `lst[:]` — copy
- `lst[::-1]` — reverse
- `lst[:n]`, `lst[n:]`, `lst[-n:]` — head, tail, last n
- Negative indices in slices
- Slice never crashes on out-of-range; index does

**Drill problems:**
1. Given `lst = [1,2,3,4,5,6,7,8,9,10]`, write slices for: first 3, last 3, middle 4, every other, reversed, every other reversed.
2. Predict output before running: `lst[100:200]` (out of range slice — what happens?). Confirm.
3. Reverse a list using slicing only. Compare with `.reverse()` and `reversed()`.

### A.3 — List methods (30 min)

**Topics:**
- `.append(x)` — O(1)
- `.extend(iter)` — add all
- `.insert(i, x)` — O(n)
- `.remove(x)` — first occurrence
- `.pop()` / `.pop(i)` — last / specific
- `.index(x)` — find position (raises if missing)
- `.count(x)` — frequency
- `.sort()` (in-place, returns None) vs `sorted()` (new list)
- `.reverse()` (in-place) vs `reversed()` (iterator)
- `.copy()` — shallow copy
- `.clear()` — remove all

**Drill problems:**
1. Build a list of 5 numbers using `.append()` in a loop.
2. Sort `[3, 1, 4, 1, 5, 9, 2, 6]` using `.sort()` and `sorted()`. Print both. Note which mutates.
3. Common bug fix: `result = lst.sort()` — what's wrong, fix it.
4. Reverse a list 3 ways: slicing, `.reverse()`, `reversed()`. Compare returns.

### A.4 — Tuples (15 min — light)

**Topics:**
- Creation: `(1, 2, 3)` or `1, 2, 3`
- Single-element: `(1,)` (the comma matters!)
- Immutability — what you can't do
- Unpacking: `a, b, c = (1, 2, 3)`
- Star unpacking: `first, *rest = [1, 2, 3, 4]`
- Tuples as dict keys (hashable)
- When to use tuple vs list (fixed record vs mutable collection)

**Drill problems:**
1. Try `t = (1, 2, 3); t[0] = 5` — predict, confirm error.
2. Swap two variables using tuple unpacking.
3. Given `data = [(1, "a"), (2, "b"), (3, "c")]`, loop and print using unpacking.

### A.5 — Mutability traps (10 min)

**Topics:**
- Aliasing: `a = b = [1,2,3]` — both point to same list
- Modifying inside function — caller sees changes
- Modifying list while iterating — silent bugs / RuntimeError
- Shallow vs deep copy: `.copy()` doesn't copy nested elements
- `.sort()` returns None (common mistake)
- Mutable default arg trap (preview — full coverage Day 5)

**Drill problems:**
1. Show aliasing: `a = [1,2,3]; b = a; b.append(4); print(a)` — predict before running.
2. Demonstrate shallow copy bug: `a = [[1,2],[3,4]]; b = a.copy(); b[0].append(99); print(a)`.
3. Bug spot: function modifies passed list, caller sees changes — fix without using `copy`.

---

## 🔄 Block B — Loop Forms × Lists (1.5 hr)

### B.1 — Five ways to walk a list (30 min)

**Drill ALL five forms on the SAME problem:** *"Print every element with a 1-based position label."*

```python
lst = ["apple", "banana", "cherry", "date"]
```

**Form 1 — for-each:**
```python
position = 1
for item in lst:
    print(f"{position}: {item}")
    position += 1
```

**Form 2 — index loop with `range(len(...))`:**
```python
for i in range(len(lst)):
    print(f"{i+1}: {lst[i]}")
```

**Form 3 — enumerate:**
```python
for i, item in enumerate(lst, start=1):
    print(f"{i}: {item}")
```

**Form 4 — while + index:**
```python
i = 0
while i < len(lst):
    print(f"{i+1}: {lst[i]}")
    i += 1
```

**Form 5 — while + pop (destructive):**
```python
lst_copy = lst.copy()
position = 1
while lst_copy:
    item = lst_copy.pop(0)
    print(f"{position}: {item}")
    position += 1
```

**Lock-in:** Write all 5 versions for the same input. Verify output matches across all 5.

### B.2 — Five base patterns on lists (45 min)

**Pattern: Counter** — *Count items matching a condition*
- Count even numbers in `[1, 4, 7, 8, 10, 13, 16]`
- Count strings longer than 5 chars in `["hi", "hello", "world", "Python", "list"]`
- Count duplicates of a target value: how many times does `2` appear in `[1, 2, 3, 2, 4, 2]`?

**Pattern: Tracker** — *Find max/min and remember position*
- Find longest string + its position in a list of words
- Find largest number + its position
- Find shortest non-empty string

**Pattern: Search** — *Find first match, break*
- Find first index of `target` in a list (without `.index()`)
- Find first negative number
- Find first string starting with "P"

**Pattern: Filter** — *Build subset matching condition*
- Keep only positive numbers
- Keep only strings of length >= 4
- Keep only every other element

**Pattern: Accumulator** — *Build a single result by combining*
- Sum a list of numbers
- Product of all elements (start with 1!)
- Concatenate all strings into one
- Find the maximum without using `max()`

### B.3 — Pattern stacking on a single list (15 min)

Combine 2 patterns in one loop:

1. **Counter + Tracker:** Find the longest word AND count words longer than average.
2. **Search + Counter:** Find the first negative number AND count how many numbers came before it.
3. **Filter + Tracker:** Build a list of words longer than 4 chars AND track the longest among them.

---

## 🪜 Block C — Nested Loops on Lists (Phase 3b L1 + L2) (2 hr)

### C.1 — Mental model lock-in (15 min)

**Recap (already cleared in earlier sessions):**
- Apartment building analogy: outer is the floor, inner is the apartment on that floor
- Outer waits at line `for i...`, inner sprints through all `j` values, then outer advances
- Naming: `i, j, k` for indices. Never `char` for an integer.
- Total iterations = outer × inner

**Drill problems (5):**
1. Predict output of `for i in range(2): for j in range(3): print(i, j)` before running.
2. Predict output of `for i in range(3): for j in range(2): print(i, j)`.
3. Predict total iterations: `for i in range(5): for j in range(4):` → ?
4. Predict: `for i in range(0): for j in range(100): print(i, j)` (empty outer).
5. Predict: `for i in range(5): for j in range(0): print(i, j)` (empty inner).

### C.2 — Range Tier 1 + Tier 2 in nested context (15 min)

**Tier 1:**
- `range(n)` — 0 to n-1
- `range(a, b)` — a to b-1
- `range(a, b, step)` — with step
- Half-open interval rule
- Empty cases: `range(5,5)`, `range(5,3)`, `range(0)`

**Tier 2:**
- `for i in range(len(lst))` — index loop
- `for i in range(len(lst) - 1)` — pair access setup
- `range(len(lst) // 2)` — first-half loops

**Drill problems:**
1. Given `lst = [10, 20, 30, 40]`, loop with `for i in range(len(lst) - 1):` — predict iterations.
2. Loop only over the first half of a 10-element list using `range(len(lst) // 2)`.
3. Loop over odd indices only using `range(1, len(lst), 2)`.

### C.3 — Coordinate grid output (20 min)

**Topic:** Build rectangular structured output.
- `print(end=" ")` for inline
- Bare `print()` for newline (after inner loop)

**Drill problems:**
1. Print a 3×3 grid where each cell shows `(i, j)`.
2. Print a 5×5 grid of `*` characters (just stars, no coords).
3. Print a 4×4 grid where the value is `i * j`.
4. Print a 5×3 grid (5 rows, 3 cols) of `(i, j)` pairs.

### C.4 — All-pairs from two lists (Cartesian product) (20 min)

**Skeleton:**
```python
for x in list1:
    for y in list2:
        print(x, y)
```

**Drill problems:**
1. Given `colors = ["red", "blue"]` and `sizes = ["S", "M", "L"]`, print all `(color, size)` combos.
2. Given two lists of 3 items each, print all pairs and count total (should be 9).
3. Given `digits = [1, 2, 3]` and `letters = ["A", "B"]`, build a list of all `f"{d}{l}"` strings.

### C.5 — Same-list pair generation (pair permutations) (25 min)

**Three flavors:**

**Flavor 1 — All n² pairs (with self-pairs and duplicates):**
```python
for i in range(len(lst)):
    for j in range(len(lst)):
        print(lst[i], lst[j])
```

**Flavor 2 — No self-pairs (`i != j`):**
```python
for i in range(len(lst)):
    for j in range(len(lst)):
        if i != j:
            print(lst[i], lst[j])
```

**Flavor 3 — Upper-triangular (unique unordered pairs, `j > i`):**
```python
for i in range(len(lst)):
    for j in range(i + 1, len(lst)):
        print(lst[i], lst[j])
```

**Drill problems:**
1. Given `nums = [1, 2, 3, 4]`, print all pairs (n²). Count: should be 16.
2. Same input, print all pairs without self-pairing. Count: should be 12.
3. Same input, print only unique unordered pairs. Count: should be 6.
4. Given `nums = [3, 1, 4, 1, 5]`, count pairs `(i, j)` where `i < j` and `nums[i] + nums[j] == 5`.

### C.6 — Range Tier 4 (steps in nested) (15 min)

**Topics:**
- `for i in range(0, n, 2)` — even rows only
- `for i in range(1, n, 2)` — odd rows only
- Reverse: `range(n-1, -1, -1)` for bottom-up
- Combining: outer steps by 2, inner steps by 3

**Drill problems:**
1. Build a 6×6 grid showing only even-indexed cells (where both `i` and `j` are even).
2. Print pairs `(i, j)` where outer steps by 2 and inner steps by 3, both `< 12`.
3. Walk a list backwards using `range(len(lst)-1, -1, -1)`.

### C.7 — Edge cases (10 min)

**Topics:**
- `range(0, 10, 0)` → ValueError (step can't be 0)
- `range(10, 0)` is empty (wrong direction without negative step)
- `range(0, 5, -1)` is empty
- Mutating list during `range(len(lst))` iteration — index drift bug

**Drill problems:**
1. Predict: `for i in range(5, 0): print(i)` — what happens?
2. Predict: `for i in range(0, 5, -1): print(i)` — what happens?
3. Bug spot: code that deletes items from a list during `for i in range(len(lst)):` — explain why it's broken.

---

## 🎁 Block D — Wrap Block: Functions + Classes on Lists (1.5 hr)

### D.1 — Functions wrapping list loops (45 min)

**Why this matters:** Real code wraps loops in functions. You're not writing top-level scripts forever.

**Convert every Block B problem to a function:**

```python
# Top-level form (drilled in Block B):
count = 0
for x in [1, 2, 3, 4]:
    if x % 2 == 0:
        count += 1
print(count)

# Function form:
def count_evens(lst):
    count = 0
    for x in lst:
        if x % 2 == 0:
            count += 1
    return count

print(count_evens([1, 2, 3, 4]))
```

**Drill problems — write each as a function:**

1. `count_evens(lst)` — count even numbers
2. `find_longest(lst)` — return longest string in list
3. `find_first_index(lst, target)` — return index of first match, or -1
4. `keep_positives(lst)` — return new list of positive numbers
5. `sum_of_squares(lst)` — return sum of each element squared
6. `count_pairs_summing_to(lst, target)` — count unordered pairs summing to target (uses upper-triangular nested!)
7. `cartesian_product(list1, list2)` — return list of all `(x, y)` tuples from two lists

**Function discipline:**
- ✅ Take input as parameter (don't hardcode)
- ✅ Don't print inside the function — return the result, let caller print
- ✅ Don't modify input list — work on a copy if you must
- ✅ Use clear parameter names (`lst`, `target`, not `x`, `y`)

### D.2 — Classes wrapping list state (45 min)

**When a class makes sense:**
- State persists across multiple operations
- You need multiple methods that share the same data
- The data has a meaningful identity (it's an Inventory, not just a list)

**Class to build: `ListAnalyzer`**

```python
class ListAnalyzer:
    def __init__(self, items):
        self.items = items
    
    def total(self):
        # sum all items (for numbers)
        ...
    
    def count_matching(self, predicate):
        # count items where predicate(item) is True
        ...
    
    def find_longest(self):
        # return longest item (assumes strings)
        ...
    
    def find_pairs_summing_to(self, target):
        # return list of pairs (i, j) where items[i] + items[j] == target
        ...
    
    def duplicates(self):
        # return list of items that appear more than once
        ...
```

**Drill: Build all 5 methods.** Each method internally uses one of the patterns from Block B.

**Class discipline:**
- ✅ Methods operate on `self.items`, not external lists
- ✅ Use `self` as the first parameter of every instance method
- ✅ `__init__` stores the data, doesn't process it
- ✅ Methods return values — don't print inside methods

**Bonus — `Inventory` class with stateful operations:**

```python
class Inventory:
    def __init__(self):
        self.items = []
    
    def add(self, item):
        ...
    
    def remove(self, item):
        # remove first occurrence; raise if not found
        ...
    
    def count(self, item):
        ...
    
    def most_common(self):
        # return item appearing most (uses tracker pattern)
        ...
```

---

## 🏆 Block E — Day 1 Mini-Boss (30 min)

**Cold attempts. No notes from this chat. Each problem stands alone.**

### Mini-Boss A — 5×5 Coordinate Grid

Print a 5×5 grid where each cell shows `(i, j)`:

```
(0,0) (0,1) (0,2) (0,3) (0,4)
(1,0) (1,1) (1,2) (1,3) (1,4)
(2,0) (2,1) (2,2) (2,3) (2,4)
(3,0) (3,1) (3,2) (3,3) (3,4)
(4,0) (4,1) (4,2) (4,3) (4,4)
```

**Tests:** Phase 3b L2 (Sub 2.2 boss equivalent)

### Mini-Boss B — 6×6 Even-Cell Grid

Print only the cells where BOTH `i` and `j` are even, on a 6×6 grid. Other cells should show as a dot `.`:

```
* . * . * .
. . . . . .
* . * . * .
. . . . . .
* . * . * .
. . . . . .
```

**Tests:** Phase 3b L2 (Sub 2.6 — Range Tier 4 step tricks)

### Mini-Boss C — Pair Counter (function)

Write `count_pairs_summing_to(lst, target)` as a function that returns the count of unordered pairs where elements sum to `target`.

```python
count_pairs_summing_to([1, 2, 3, 4, 5], 6)  # → 2 (pairs: (1,5), (2,4))
count_pairs_summing_to([3, 3, 3], 6)         # → 3 (every pair counts)
count_pairs_summing_to([1, 2, 3], 10)        # → 0
```

**Tests:** Phase 3b L3 (upper-triangular pair iteration), function discipline (Block D.1)

---

## 🚦 Day 1 Pass/Fail Rules

**3-strike rule per drill problem:**
- 1st miss → diagnosis hint
- 2nd miss → structural hint (skeleton with blanks)
- 3rd miss → I show full solution + you re-attempt fresh

**Mini-boss pass condition:**
- All 3 mini-boss problems correct cold OR with at most 1 self-corrected bug per problem
- If hints needed on more than one → loop back to weakest level before Day 2

---

## 📋 Day 1 Tracker Recap (paste into progress_tracker.md)

```
Day 1 of Loop Week — Lists & Tuples + Phase 3b L1+L2

Locked:
- 5 ways to walk a list (for-each, index, enumerate, while+index, while+pop)
- 5 base patterns on lists (counter, tracker, search, filter, accumulator)
- List methods + slicing + mutability traps
- Nested loop mental model + tracing
- Range Tier 1, 2, 4 in nested context
- All-pairs (3 flavors): n², no self, upper-triangular
- Functions wrapping list loops (7 functions)
- Classes wrapping list state (ListAnalyzer + Inventory)

Mini-boss results:
- 5×5 coord grid: ✓/✗
- 6×6 even-cell grid: ✓/✗
- count_pairs_summing_to: ✓/✗

Weak spots flagged: [fill in]
Tomorrow's bridge: Dicts/Sets + Phase 3b L3 (pattern stacking inside nested)
```

---

## 🧠 Day 1 Memory Hooks

- *"Five ways to walk a list — for-each, index, enumerate, while+index, while+pop."*
- *"Counter adds 1, Accumulator adds the value, Tracker remembers position, Search breaks, Filter keeps."*
- *"`range(i+1, n)` = upper triangle — unique unordered pairs, no double count."*
- *"`.sort()` returns None — sort first, then assign, never `x = lst.sort()`."*
- *"Aliasing trap — `a = b` makes them the same list, not a copy."*

---

## 🔮 What unlocks after Day 1

- Day 2 (Dicts/Sets) — applies same patterns to hashed structures
- Day 3 (Strings) — same patterns + slicing on immutable sequences
- Day 6 mini-problems — list-based problems become routine
- Phase 3b L3 (next day) — pattern stacking inside nested, builds on L2 fluency

---

*End of Day 1 curriculum. Brainstorm complete. Ready to lock or refine.*
