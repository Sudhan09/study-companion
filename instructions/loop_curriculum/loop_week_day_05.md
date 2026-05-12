# 🔁 Loop Week — Day 5: Functions DEEP + While Family + Nested-Loop Traps

> **Theme:** The day functions stop being "wrappers" and become first-class tools. Plus the while-family of nested loops finally gets its own focused drill, and the 4 classic nested-loop traps get diagnosed cold. The day's secret: function discipline IS the cure for the nested-loop traps. `return` beats flag-and-break. Helpers beat shadowing. Refactor beats `else` confusion.
>
> **Time budget:** 7-8 focused hours
>
> **Phase 3b coverage:** L5 (While family + hybrid loops) + L6 (4 classic traps)
>
> **Mini-boss:** Hybrid halving + 4 broken-loop debugs + higher-order pair (count_matching + apply_to_all)
>
> **Day 5 is heavy on while.** This is the day that counterbalances Day 4's for-only pass. Honest split: ~40% for, 60% while.

---

## 🎯 Day 5 Learning Goals

By end of day, you should be able to **without notes**:

1. Write pure functions — input via parameters, output via return, no side effects
2. Multi-return via tuple and unpack on the caller side
3. Write predicate functions and use them as filter / sort key / condition
4. Write higher-order functions (function takes function, function returns function)
5. Use closures to build customized functions (function factories)
6. Spot and fix the mutable default argument trap cold
7. Use `*args` and `**kwargs` for flexible signatures, plus call-site unpacking
8. Read a basic decorator and explain what `@decorator` does
9. Write nested `while` loops correctly — including the inner-reset discipline
10. Pick the right hybrid form (for+while or while+for) given the problem shape
11. Identify all 4 classic nested-loop traps and fix each
12. Refactor flag-and-break into a function with early `return`
13. Use `for/while else` correctly (and recognize when to skip it)

---

## 🗓 Day 5 Time Layout

| Block | Time | Content |
|---|---|---|
| **Block A — Morning** | 1.5 hr | Pure functions, multi-return, predicates, scope (LEGB), type hints |
| **Block B — Midday** | 1.5 hr | Higher-order functions, closures, function factories, lambdas, map/filter/reduce |
| **Block C — Afternoon Part 1** | 1.5 hr | Phase 3b L5 — While family + hybrid loops |
| **Block D — Afternoon Part 2** | 1 hr | Phase 3b L6 — 4 classic traps + the function-based fix |
| **Block E — Wrap Block** | 1 hr | `Pipeline` class (composition + fluent API) + `*args`/`**kwargs` + decorators (light) |
| **Block F — Evening Mini-Boss** | 30 min | Hybrid halving + 4 debugs + higher-order pair, cold |

Total: ~7 hours.

---

## 📚 Block A — Pure Functions, Multi-Return, Predicates (1.5 hr)

### A.1 — Pure function discipline (15 min)

**The core rule:** A pure function takes input via parameters, returns output via `return`, and has no side effects.

**Side effects to avoid:**
- Printing inside the function (return the value, let the caller print)
- Writing to files
- Modifying arguments (especially lists/dicts)
- Modifying global state
- Calling functions that have side effects

**Why pure functions matter:**
- Easier to test — same input always produces same output
- Easier to debug — no hidden state
- Easier to compose — predictable behavior
- Easier to parallelize (later in bootcamp)

**Anti-example:**
```python
# ❌ Impure — prints inside, modifies argument
def total_score(scores):
    scores.sort()                       # modifies caller's list!
    print(f"Sorted: {scores}")          # side effect
    total = sum(scores)
    print(f"Total: {total}")            # side effect
    # No return! Caller can't use the result.

# ✅ Pure — clean
def total_score(scores):
    return sum(scores)

# Caller:
result = total_score([3, 1, 2])
print(f"Total: {result}")               # caller decides whether to print
```

**Drill problems:**
1. Write a pure function `count_evens(lst)`. Don't print. Don't modify input. Return the count.
2. Bug spot: function modifies passed list — show it, then refactor to pure (use `.copy()` if needed).
3. Bug spot: function prints instead of returning — refactor.

### A.2 — Multi-return via tuple (15 min)

Python auto-tuples when you `return` multiple values.

```python
def find_min_max(lst):
    return min(lst), max(lst)        # auto-tuples

low, high = find_min_max([3, 1, 4, 1, 5, 9, 2, 6])
# low → 1, high → 9
```

**Caller patterns:**
```python
# Unpack into separate variables (most common)
low, high = find_min_max(lst)

# Capture as tuple
result = find_min_max(lst)
print(result[0], result[1])

# Ignore one (underscore convention)
_, high = find_min_max(lst)
```

**When to multi-return vs return a class/dict:**
- 2-3 related values → tuple
- 4+ values, or values with names that matter → return a `dict` or a small class
- Don't return more than 4 values via tuple — caller has to remember the order

**Drill problems:**
1. Write `find_extremes(lst)` returning `(min, max, mean)` as a tuple. Test with `[3, 1, 4, 1, 5, 9, 2, 6]`.
2. Write `parse_name(full_name)` returning `(first, last)` from a string like `"Sudhan Iyer"`.
3. Refactor a function that returns 5 values via tuple into one that returns a dict — explain why dict is clearer here.

### A.3 — Predicate pattern (15 min)

Predicates are functions that return `bool`. They answer yes/no questions.

**Naming convention:**
- `is_*` — `is_even`, `is_palindrome`, `is_prime`
- `has_*` — `has_duplicates`, `has_vowels`
- `can_*` — `can_factor`
- Verb-form questions — `contains_only_digits`

**Use cases:**
- Filter argument: `[x for x in lst if is_even(x)]`
- Sort key (rarely — usually you want a comparable value, not bool)
- Condition in higher-order: `filter(is_even, nums)`
- Validation gate: `if not is_valid(input): raise`

```python
def is_palindrome(s):
    return s == s[::-1]

def is_even(n):
    return n % 2 == 0

def has_duplicates(lst):
    return len(lst) != len(set(lst))
```

**Drill problems:**
1. Write 5 predicates: `is_prime`, `is_even`, `is_palindrome`, `has_vowels`, `is_sorted_ascending`. Each should return a `bool` only.
2. Use `is_even` inside a list comp: `[x for x in range(20) if is_even(x)]`.
3. Use `is_palindrome` inside `filter`: `list(filter(is_palindrome, ["racecar", "hello", "level", "world"]))`.

### A.4 — Scope (LEGB) reinforcement (15 min)

**The lookup order:**
- **L**ocal — defined inside the current function
- **E**nclosing — defined in an outer function (for nested defs)
- **G**lobal — defined at module top-level
- **B**uiltin — Python built-ins like `len`, `range`, `print`

**The trap — variable shadowing:**
```python
total = 100         # global

def add_to_total(x):
    total = x       # creates LOCAL total, doesn't touch global
    return total

print(add_to_total(5))    # → 5
print(total)              # → 100   (global unchanged)
```

**`global` keyword (avoid almost always):**
```python
total = 100

def reset():
    global total           # tells Python: I mean the module-level one
    total = 0
```

**`nonlocal` keyword (for closures, drilled in Block B):**
```python
def make_counter():
    count = 0
    def increment():
        nonlocal count     # access enclosing scope's count
        count += 1
        return count
    return increment
```

**Drill problems:**
1. Write code where a local shadows a global. Show that the global is unchanged.
2. Bug spot: function tries to modify a global without `global` keyword. Predict the error or behavior.
3. Memory hook reminder: *"Learning Effective Gen-Z Bootcamp"* = LEGB.

### A.5 — Type hints (light) (10 min)

Modern Python encourages annotations. They don't enforce anything at runtime, but they help editors and future-you.

```python
def add(a: int, b: int) -> int:
    return a + b

def find_longest(words: list[str]) -> str:
    return max(words, key=len)

def lookup(d: dict[str, int], key: str) -> int | None:
    return d.get(key)
```

**Common annotations:**
- `int`, `float`, `str`, `bool`
- `list[str]`, `dict[str, int]`, `tuple[int, int]`
- `int | None` (Python 3.10+) — formerly `Optional[int]`
- `Callable[[int], bool]` — function taking int, returning bool

**Drill problems:**
1. Add type hints to `count_evens`, `find_min_max`, `is_palindrome` from earlier.
2. Annotate a function that takes a list of dicts: `def process(records: list[dict[str, int]]) -> int:`.
3. Try calling `add(2, "3")` (string instead of int). Predict: does Python catch it? (No — type hints don't enforce.)

### A.6 — Default arguments + the mutable default trap (20 min)

**Default args — the basics:**
```python
def greet(name, greeting="Hello"):
    return f"{greeting}, {name}!"

greet("Sudhan")              # → "Hello, Sudhan!"
greet("Sudhan", "Hey")       # → "Hey, Sudhan!"
```

**The trap — mutable defaults:**
```python
# ❌ Bug — the [] is created ONCE at function definition
def add_item(item, lst=[]):
    lst.append(item)
    return lst

add_item("apple")            # → ["apple"]
add_item("banana")           # → ["apple", "banana"]    !!! shared default
add_item("cherry")           # → ["apple", "banana", "cherry"]
```

**The fix:**
```python
# ✅ Use None sentinel, build inside
def add_item(item, lst=None):
    if lst is None:
        lst = []
    lst.append(item)
    return lst

add_item("apple")            # → ["apple"]
add_item("banana")           # → ["banana"]   ✅ fresh list each call
```

**Why this happens:** Python evaluates defaults ONCE when the function is defined. The `[]` is the same list object every call.

**Drill problems:**
1. Write the buggy version. Call it 3 times, observe the accumulation.
2. Write the fixed version. Verify each call starts fresh.
3. Same trap with `dict`: `def f(x, d={}): d[x] = True; return d`. Fix it.
4. Quick bonus: which of these is a SAFE default? `def f(x=10)`, `def f(x="hi")`, `def f(x=None)`, `def f(x=[])`, `def f(x=(1,2))` — predict each.

---

## 🔄 Block B — Higher-Order Functions, Closures, Lambdas (1.5 hr)

### B.1 — Higher-order functions (20 min)

**Functions are first-class objects.** They can be:
- Stored in variables
- Passed as arguments
- Returned from other functions
- Stored in lists/dicts

**Function as argument:**
```python
def apply_to_all(lst, func):
    return [func(x) for x in lst]

apply_to_all([1, 2, 3, 4], lambda x: x**2)        # → [1, 4, 9, 16]
apply_to_all(["hi", "bye"], str.upper)            # → ["HI", "BYE"]
```

**The mental shift:** the function `apply_to_all` doesn't know what it's applying. It just applies. That's what makes it reusable.

**Drill problems:**
1. Write `apply_to_all(lst, func)` — apply `func` to each element, return new list.
2. Write `count_matching(lst, predicate)` — count items where `predicate(item)` is True.
3. Write `find_first(lst, predicate)` — return first item where predicate is True, or `None`.
4. Use all three with different functions/predicates: `count_matching([1,2,3,4,5], lambda x: x > 2)`, etc.

### B.2 — Lambda functions (15 min)

**Anonymous one-line functions.** Useful where naming feels overkill.

```python
square = lambda x: x ** 2
square(5)        # → 25

# Used inline (most common):
sorted(words, key=lambda w: len(w))
filter(lambda x: x > 0, nums)
```

**Constraints:**
- Single expression only — no statements (`if`/`else` ternary works, multi-line blocks don't)
- No annotations
- No docstrings
- Can have multiple args: `lambda x, y: x + y`

**When to use lambda:**
- Short callbacks (`key=`, `filter`, `map`)
- Functional pipelines
- One-shot transformations

**When NOT to use lambda:**
- Anything with logic complexity → name it with `def`
- Anything you'll reuse → name it
- Anything where the lambda becomes longer than the comment explaining it

**Drill problems:**
1. Sort `[(1, "b"), (3, "a"), (2, "c")]` by second element using lambda.
2. Sort `["apple", "banana", "kiwi", "date"]` by length, ties broken alphabetically. (Hint: `key=lambda w: (len(w), w)`)
3. Filter `[-2, -1, 0, 1, 2, 3]` to keep only positives using `filter(lambda x: ..., nums)`.

### B.3 — `map`, `filter`, `reduce` — and why comprehensions usually win (15 min)

```python
from functools import reduce

# map — apply to each
list(map(lambda x: x**2, [1,2,3,4]))       # → [1, 4, 9, 16]
[x**2 for x in [1,2,3,4]]                   # comp form — usually preferred

# filter — keep matching
list(filter(lambda x: x > 0, nums))
[x for x in nums if x > 0]                  # comp form

# reduce — fold left
reduce(lambda a, b: a + b, [1,2,3,4], 0)   # → 10
sum([1,2,3,4])                              # built-in for this case
```

**The Pythonic call:**
- `map` and `filter` → almost always replaced by comprehensions
- `reduce` → use `sum`, `max`, `min`, `any`, `all` when they fit; reduce only for non-trivial folds

**When `reduce` survives:**
- Building a single value from a sequence with custom logic
- Multiplying all elements: `reduce(lambda a,b: a*b, nums, 1)` (no built-in `product`)
- Right-fold or specific accumulator patterns

**Drill problems:**
1. Compute product of `[1, 2, 3, 4, 5]` using `reduce`. (Should be 120.)
2. Find max in `[3, 1, 4, 1, 5, 9, 2, 6]` using `reduce`. Compare with built-in `max`.
3. Refactor `list(map(lambda x: x*2, lst))` and `list(filter(lambda x: x > 0, lst))` into comprehensions.

### B.4 — Closures + function factories (25 min)

**A closure is a function that captures variables from its enclosing scope.**

```python
def make_multiplier(n):
    def multiply(x):
        return x * n        # captures n from enclosing scope
    return multiply

times3 = make_multiplier(3)
times5 = make_multiplier(5)

times3(10)        # → 30
times5(10)        # → 50
```

**The mental model:** *A closure is like a function that packs a lunchbox of its parent's variables. Even after the parent function is gone, the inner function still has the lunchbox.*

**Function factory pattern** — make customized functions on demand:

```python
def make_validator(min_val, max_val):
    def validator(x):
        return min_val <= x <= max_val
    return validator

is_grade = make_validator(0, 100)
is_age = make_validator(0, 150)

is_grade(85)        # → True
is_age(200)         # → False
```

**The late binding gotcha:**
```python
# ❌ All multipliers reference the SAME i (the final value)
multipliers = []
for i in range(5):
    multipliers.append(lambda x: x * i)

multipliers[0](10)        # → 40 (NOT 0! All lambdas captured i, which ended at 4)

# ✅ Fix — bind i at lambda creation
multipliers = []
for i in range(5):
    multipliers.append(lambda x, i=i: x * i)        # default arg captures current i

multipliers[0](10)        # → 0 ✅
```

**`nonlocal` for modifying enclosing scope:**
```python
def make_counter():
    count = 0
    def increment():
        nonlocal count       # without nonlocal, this would create a new local
        count += 1
        return count
    return increment

c = make_counter()
c()        # → 1
c()        # → 2
c()        # → 3
```

**Drill problems:**
1. Write `make_multiplier(n)` and create `double`, `triple`, `times10`. Test each.
2. Write `make_validator(min_val, max_val)` and create `is_grade`, `is_age`, `is_temperature`. Test each.
3. Write `make_counter()` using `nonlocal`. Verify that two counters maintain independent state.
4. Demonstrate the late-binding gotcha. Then fix it with the default-arg trick.

### B.5 — Lambda + closures cross-pollination (15 min)

Closures don't always need a `def`. Lambdas can close over enclosing scope too.

```python
def make_multiplier(n):
    return lambda x: x * n      # lambda is the inner function

times7 = make_multiplier(7)
times7(6)        # → 42
```

**Drill problems:**
1. Refactor `make_validator` to use a lambda inside.
2. Use `sorted` with a lambda that closes over an external priority dict:
   ```python
   priority = {"high": 1, "medium": 2, "low": 3}
   tasks = ["low", "high", "medium", "high", "low"]
   sorted(tasks, key=lambda t: priority[t])
   ```
3. Write a function `make_filter(predicate)` that returns a function that filters a list using the predicate.

---

## 🪜 Block C — Phase 3b L5: While Family + Hybrid Loops (1.5 hr)

### C.1 — `while` inside `while` (30 min)

**The skeleton:**
```python
i = 0
while i < n:
    j = 0                # ← THE inner reset, easy to forget
    while j < m:
        # work with i, j
        j += 1
    i += 1
```

**The reset trap — drill cold:**

```python
# ❌ Missing reset
i = 0
while i < 3:
    while j < 4:         # j was 4 from somewhere, never resets
        print(i, j)
        j += 1
    i += 1
# Inner runs once (using leftover j from outside), then never again.
```

**Why for loops don't have this problem:** `for j in range(m)` automatically re-creates `j` each outer iteration. While loops require manual discipline.

**Drill problems:**
1. Print a 4×3 grid of `(i, j)` using only `while` loops. Verify the reset.
2. Trace 3 broken nested-while snippets where `j = 0` is missing. What happens?
3. Convert a working nested `for` loop to nested `while` form. Compare line counts.
4. Build a multiplication table (3×3) using nested while.

### C.2 — `for` inside `while` (20 min)

**Use case:** Outer loop has uncertain count (sentinel/convergence), inner loop is a fixed sweep.

```python
# Process input until "stop", scan each input
while True:
    text = input("Enter text (stop to quit): ")
    if text == "stop":
        break
    for char in text:
        print(char.upper(), end=" ")
    print()
```

**Another classic — convergence outer, fixed inner:**
```python
# Halve a list of numbers until all are <= 1, printing each step
nums = [16, 7, 100, 1, 50]
while any(n > 1 for n in nums):
    for i in range(len(nums)):
        if nums[i] > 1:
            nums[i] //= 2
    print(nums)
```

**Drill problems:**
1. Build a sentinel-based input loop: keep asking for words, scan each for vowels, count total. Stop when user enters "done".
2. For-while combo: while a list contains any number > 100, scan and halve those entries. Each pass should be a `for` over the list.

### C.3 — `while` inside `for` (20 min)

**Use case:** Outer is fixed iterations, inner runs until some condition.

```python
# For each number, halve until 1, print sequence
for n in [16, 7, 100, 1, 50]:
    seq = [n]
    while n > 1:
        n //= 2
        seq.append(n)
    print(seq)
```

**Another:**
```python
# For each name, prompt until valid input
names = ["Alice", "Bob", "Charlie"]
for name in names:
    score = -1
    while score < 0 or score > 100:
        score = int(input(f"Score for {name}: "))
    print(f"{name}: {score}")
```

**Drill problems:**
1. For each `n` in `[16, 7, 100, 1, 50]`, print the halving sequence (Collatz-flavored).
2. For each word in `["banana", "apple", "kiwi"]`, repeatedly remove the last char until length is even or 0. Print intermediate states.
3. For each of 3 students, prompt for grade until valid (0-100).

### C.4 — Decision rules — when to pick which (10 min)

Lock this table:

| Outer needs | Inner needs | Pick |
|---|---|---|
| Fixed count | Fixed count | `for` + `for` |
| Fixed count | Convergence/sentinel | `for` + `while` |
| Convergence/sentinel | Fixed count | `while` + `for` |
| Convergence/sentinel | Convergence/sentinel | `while` + `while` |

**Drill problems:**
1. For each problem, name the right hybrid:
   - "For each number 1-10, halve until 1." → ?
   - "Read user input until 'stop', for each input scan all chars." → ?
   - "Print a 5×5 grid." → ?
   - "Until total exceeds 1000, repeatedly add user-input numbers." → ?
2. Pick the wrong hybrid intentionally — write the same problem with the wrong combo. Why is it ugly?

### C.5 — Range-equivalent while patterns (10 min)

Every Tier 2 range form has a while equivalent. Drill the conversion.

| `for` form | `while` equivalent |
|---|---|
| `for i in range(n):` | `i = 0; while i < n: ...; i += 1` |
| `for i in range(a, b):` | `i = a; while i < b: ...; i += 1` |
| `for i in range(a, b, step):` | `i = a; while i < b: ...; i += step` |
| `for i in range(n-1, -1, -1):` | `i = n-1; while i >= 0: ...; i -= 1` |

**Drill problems:**
1. Convert `for i in range(len(lst)):` to while form. Verify identical output.
2. Convert `for i in range(0, 100, 5):` to while form.
3. Convert `for i in range(10, 0, -2):` to while form.

---

## ⚠️ Block D — Phase 3b L6: 4 Classic Traps + Function-Based Fixes (1 hr)

### D.1 — The 4 traps with examples and fixes (40 min)

#### Trap 1 — Variable shadowing (10 min)

```python
# ❌ BUG — i used for both loops
for i in range(3):
    for i in range(2):       # silently overwrites outer i
        print(i)
    print(f"outer i: {i}")    # inner i leaked out
```

Output:
```
0
1
outer i: 1     ← outer expected 0
0
1
outer i: 1     ← outer expected 1
0
1
outer i: 1     ← outer expected 2
```

**Fix:** Use different variable names. `i, j, k` is the universal convention.

**Function-based fix (the L5 + L6 merger):**
```python
def inner_work():
    for i in range(2):       # safe — different scope
        print(i)

for i in range(3):           # also safe now
    inner_work()
    print(f"outer i: {i}")    # correctly shows outer i
```

The helper function gives the inner loop its own scope. No collision possible.

**Drill problems:**
1. Run the buggy code, observe shadowing.
2. Fix by renaming inner to `j`.
3. Fix by extracting inner into a helper function.

#### Trap 2 — `break` only exits the inner loop (10 min)

```python
# ❌ Common mistake — assumes break exits BOTH loops
for i in range(5):
    for j in range(5):
        if i + j == 4:
            break               # only exits inner!
    # outer keeps running
```

**Fix 1 — Flag and break (Trap 3, often paired):**
```python
found = False
for i in range(5):
    for j in range(5):
        if i + j == 4:
            found = True
            break
    if found:
        break
```

**Fix 2 — Refactor to function with `return` (the cleaner fix):**
```python
def find_pair():
    for i in range(5):
        for j in range(5):
            if i + j == 4:
                return (i, j)        # exits everything immediately
    return None
```

**Why the function fix is better:** `return` exits all loops at once. No flag, no boilerplate. This is why function discipline IS the cure for nested-loop traps.

**Drill problems:**
1. Run the buggy code. Confirm outer continues after inner breaks.
2. Fix using flag-and-break.
3. Refactor into a function with `return`. Compare line counts.

#### Trap 3 — Flag-and-break boilerplate (10 min)

When you genuinely can't refactor into a function (e.g., you need to keep mutating outer state), flag-and-break is the pattern.

```python
# Skeleton
flag = False
for i in range(n):
    for j in range(m):
        if condition(i, j):
            flag = True
            break
    if flag:
        break
```

**Drill problems:**
1. Find first cell in a 2D matrix matching `target`. Use flag-and-break.
2. Same problem, refactored into a function with `return`. Compare.
3. When does flag-and-break beat the function refactor? (Answer: rare, but if you need to keep multiple outer-scoped variables updated mid-search.)

#### Trap 4 — `for/while else` clause (10 min)

The `else` on a loop runs ONLY if the loop completes WITHOUT `break`.

```python
def find(lst, target):
    for x in lst:
        if x == target:
            print("found!")
            break
    else:
        print("not found")        # runs only if break didn't fire
```

**Use case:** Search-not-found notification, validation passes.

**Common confusion:** Most developers expect `else` to be the "if condition fails" branch. It's actually the "loop completed cleanly" branch.

**The function-based alternative — usually cleaner:**
```python
def find(lst, target):
    for x in lst:
        if x == target:
            return "found!"
    return "not found"        # no else needed — return falls through
```

**Drill problems:**
1. Write a search using `for/else`. Test on found and not-found cases.
2. Refactor into function with `return`. Note how `else` becomes unnecessary.
3. When IS `for/else` cleaner? Rare answer: when you want to do additional work AFTER the loop in the not-found case. Usually still cleaner with `return` + post-call logic.

### D.2 — The merger — function discipline as the cure (10 min)

Lock this mental model:

| Trap | Function-based fix |
|---|---|
| Shadowing | Helper function gives inner loop its own scope |
| `break` only exits inner | `return` exits everything |
| Flag-and-break boilerplate | `return` replaces the flag |
| `for/while else` confusion | `return` falls through, no `else` needed |

**Memory hook:** *"`return` is the cleanest exit from any loop nest. If you're flag-and-breaking, ask whether you should be in a function instead."*

### D.3 — Performance awareness (10 min)

Two nested loops over size-n input = O(n²). Triple nested = O(n³).

**At what size does it matter?**

| n | n² operations | n³ operations |
|---|---|---|
| 10 | 100 | 1,000 |
| 100 | 10,000 | 1,000,000 |
| 1,000 | 1,000,000 | 1,000,000,000 |
| 10,000 | 100,000,000 | (too slow) |

**The mental shift:**
- Up to n=1000: nested loops are usually fine
- n=10,000+: think hash maps, sorting, or smarter algorithms
- LeetCode problems often have constraints that signal whether O(n²) is acceptable

**Drill problems:**
1. Write a brute-force two-sum using nested loops. Estimate operations for n=1000.
2. Refactor using a hash map (Day 2). Compare operation counts.
3. Why is sorting (O(n log n)) sometimes faster than a clever O(n²) algorithm?

---

## 🎁 Block E — Wrap Block: `Pipeline` Class + `*args`/`**kwargs` + Decorators (1 hr)

### E.1 — `Pipeline` class — composition + fluent API (30 min)

A class that stores a list of operations (functions), then applies them in order.

```python
class Pipeline:
    def __init__(self):
        self.steps = []
    
    def add(self, func):
        # Append a step. Return self for fluent chaining.
        self.steps.append(func)
        return self
    
    def run(self, data):
        # Apply each step in order.
        for step in self.steps:
            data = step(data)
        return data
```

**Usage — fluent style:**
```python
pipeline = (Pipeline()
            .add(lambda x: x * 2)
            .add(lambda x: x + 1)
            .add(lambda x: x ** 2))

pipeline.run(3)
# Step 1: 3 * 2 = 6
# Step 2: 6 + 1 = 7
# Step 3: 7 ** 2 = 49
# Result: 49
```

**Why this class teaches Day 5 patterns:**
- Functions stored in a list (functions as data)
- Lambda used cleanly (short, single-purpose)
- `return self` enables chaining (fluent API)
- Pure-function discipline (`run` doesn't print)

**Drill: Build the class. Use it for:**
1. Numeric pipeline: double, add 1, square.
2. String pipeline: lowercase, strip, replace spaces with underscores.
3. Filter pipeline: take a list, filter positives, then double them, then sum. (Hint: a step can return a list, next step processes it.)

### E.2 — `*args` and `**kwargs` (15 min)

**`*args`** collects extra positional arguments into a tuple:
```python
def sum_all(*nums):
    return sum(nums)

sum_all(1, 2, 3)              # → 6
sum_all(1, 2, 3, 4, 5)        # → 15
sum_all()                      # → 0
```

**`**kwargs`** collects extra keyword arguments into a dict:
```python
def make_record(**fields):
    return fields

make_record(name="Sudhan", age=24, city="Chennai")
# → {"name": "Sudhan", "age": 24, "city": "Chennai"}
```

**Combined:**
```python
def flexible(*args, **kwargs):
    print(f"Positional: {args}")
    print(f"Keyword: {kwargs}")

flexible(1, 2, 3, name="Sudhan", role="learner")
# Positional: (1, 2, 3)
# Keyword: {"name": "Sudhan", "role": "learner"}
```

**Call-site unpacking — the inverse:**
```python
def add(a, b, c):
    return a + b + c

nums = [1, 2, 3]
add(*nums)                    # → 6   (unpacks list into positional args)

kwargs = {"a": 1, "b": 2, "c": 3}
add(**kwargs)                 # → 6   (unpacks dict into keyword args)
```

**Drill problems:**
1. Write `sum_all(*nums)` accepting any number of args.
2. Write `make_record(**fields)` returning the kwargs as dict.
3. Use `*` to unpack a list into a function call: given `args = [1, 2, 3]` and `def add(a, b, c)`, call it.

### E.3 — Decorators (light touch — preview only) (15 min)

A decorator wraps a function. `@decorator` is syntactic sugar for `func = decorator(func)`.

**Basic structure:**
```python
import time

def timer(func):
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        print(f"{func.__name__} took {elapsed:.4f}s")
        return result
    return wrapper

@timer
def slow_function():
    total = 0
    for i in range(1_000_000):
        total += i
    return total

slow_function()
# slow_function took 0.0521s
# → 499999500000
```

**What's happening:**
1. `@timer` is shorthand for `slow_function = timer(slow_function)`
2. `timer` returns `wrapper`, which becomes the new `slow_function`
3. When you call `slow_function()`, you're really calling `wrapper()`
4. `wrapper` times the original and forwards args/kwargs

**Why this fits Day 5:**
- Function takes a function (higher-order)
- Function returns a function (closure/factory)
- `*args/**kwargs` for forwarding
- Decorators are everywhere in Python (Flask routes, pytest, dataclasses)

**Drill problems:**
1. Read the `@timer` decorator. Explain what each line does.
2. Write a `@logger` decorator that prints `"Calling {name}"` before and `"Done"` after.
3. (Bonus, optional) Write a `@memoize` decorator using a dict — caches results so repeated calls are instant. (This is `lru_cache` from scratch — relevant for recursion in Day 16.)

---

## 🏆 Block F — Day 5 Mini-Boss (30 min)

**Cold attempts. No notes from this chat. Each problem stands alone.**

### Mini-Boss A — Hybrid Halving Sequence

For each number in `[16, 7, 100, 1, 50]`, print the halving sequence (integer division by 2) until 1 is reached. Use `for` outer + `while` inner.

Expected output (one sequence per line):
```
[16, 8, 4, 2, 1]
[7, 3, 1]
[100, 50, 25, 12, 6, 3, 1]
[1]
[50, 25, 12, 6, 3, 1]
```

**Tests:** Phase 3b L5 (for + while hybrid), edge case `n = 1` (no halving needed).

### Mini-Boss B — Debug 4 Broken Nested-Loop Snippets

Each snippet has exactly one of the 4 classic traps. Identify the trap + fix.

**Snippet 1:**
```python
for i in range(3):
    for i in range(4):
        print(i)
```
Trap: ?
Fix: ?

**Snippet 2:**
```python
i = 0
while i < 3:
    while j < 4:
        print(i, j)
        j += 1
    i += 1
```
Trap: ?
Fix: ?

**Snippet 3:**
```python
def find_first_match(matrix, target):
    for i in range(len(matrix)):
        for j in range(len(matrix[0])):
            if matrix[i][j] == target:
                break        # bug: only breaks inner
    return None
```
Trap: ?
Fix: ?

**Snippet 4:**
```python
def search(lst, target):
    for x in lst:
        if x == target:
            return "found"
        else:
            return "not found"        # bug: returns on first miss
```
Trap: ?
Fix: ?

**Tests:** Phase 3b L6 (all 4 traps), function-based fixes preferred.

### Mini-Boss C — Higher-Order Pair

Write two higher-order functions:

```python
def count_matching(lst, predicate):
    # Return count of items where predicate(item) is True.
    ...

def apply_to_all(lst, transform):
    # Return new list with transform applied to each item.
    ...
```

Then use them to:
1. Count evens in `[1, 2, 3, 4, 5, 6, 7, 8]` — should return 4.
2. Double every value in `[1, 2, 3, 4, 5]` — should return `[2, 4, 6, 8, 10]`.
3. Combo: count items in `[1, 2, 3, 4, 5]` where the doubled value exceeds 5.
   ```python
   doubled = apply_to_all([1, 2, 3, 4, 5], lambda x: x * 2)
   count = count_matching(doubled, lambda x: x > 5)
   # → 3
   ```

**Tests:** Higher-order function fluency, lambda usage, function composition.

---

## 🚦 Day 5 Pass/Fail Rules

**3-strike rule per drill problem:**
- 1st miss → diagnosis hint
- 2nd miss → structural hint (skeleton with blanks)
- 3rd miss → I show full solution + you re-attempt fresh

**Mini-boss pass condition:**
- All 3 mini-boss problems correct cold OR with at most 1 self-corrected bug per problem
- If hints needed on more than one → loop back to Block C (while family) or Block D (traps) before Day 6
- Trap diagnosis errors are weighted heavily — getting 3/4 traps right is a fail, not a pass

---

## 📋 Day 5 Tracker Recap (paste into progress_tracker.md)

```
Day 5 of Loop Week — Functions DEEP + Phase 3b L5 + L6 (While Family + Traps)

Locked:
- Pure function discipline (input → return, no side effects)
- Multi-return via tuple
- Predicate pattern (is_*, has_*, can_*)
- Scope (LEGB) reinforcement
- Type hints (light)
- Mutable default argument trap + fix
- Higher-order functions (function as arg, function as return)
- Lambdas (where to use, where not to)
- map / filter / reduce — and why comp usually wins
- Closures + function factories + late binding gotcha
- nonlocal keyword for closures
- Phase 3b L5: while-while, for-while, while-for hybrids
- Decision table for hybrid loop selection
- Range → while form conversions
- Phase 3b L6: 4 classic traps (shadowing, break scope, flag-and-break, for/else)
- Function-based fixes for all 4 traps (return is the cure)
- Performance awareness — O(n²) thresholds
- *args / **kwargs + call-site unpacking
- Decorators (light touch — @timer, @logger)
- Pipeline class (fluent API + composition)

Mini-boss results:
- Hybrid halving: ✓/✗
- 4 broken-loop debugs: ✓/✗ (record which traps were correctly diagnosed)
- count_matching + apply_to_all: ✓/✗

Weak spots flagged: [fill in]
Tomorrow's bridge: Mini-problems day — every solution is a clean function from the start
```

---

## 🧠 Day 5 Memory Hooks

- *"Pure function: input via param, output via return, no side effects."*
- *"`return` is the cleanest exit from any loop nest. Better than flag-and-break."*
- *"Functions are first-class — pass them, return them, store them in a list."*
- *"Mutable default = shared default. Use `None` sentinel + build inside."*
- *"`for/while else` runs only if `break` didn't fire. Most developers forget this exists."*
- *"Nested while: don't forget the inner reset (`j = 0`)."*
- *"`i, j, k` for nested indices. Shadowing `i` is silent and catastrophic."*
- *"Closures pack a lunchbox. Late binding empties the lunchbox at access time, not at creation."*
- *"`@decorator` = `func = decorator(func)`. Syntactic sugar."*

---

## 🔮 What unlocks after Day 5

- Day 6 (Mini-problems) — every solution is a clean function from the start, no top-level scripts
- Day 7 (Project) — composition of small pure functions into a real program
- Week 2 callback — OOP days reuse closures and decorators heavily
- Week 4+ — hash map problems benefit from predicate functions + higher-order patterns
- Week 12+ — DP solutions are functions with memoization (memoize decorator preview today)
- Week 14+ — `@lru_cache` for recursive problems builds on memoize concept

---

*End of Day 5 curriculum. Brainstorm complete. Ready to lock or refine.*
