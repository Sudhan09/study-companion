<!-- Per design §G port plan: verbatim port of openclaw_setup/room-to-improve/room-to-improve-architecture/pattern_to_drill_map.md -->
<!-- DO NOT EDIT. Canonical drill skeletons per pattern. -->

# Pattern-to-Drill Map

Skeleton + 3 drill shells + common wrong versions + success criteria per pattern.

---

## A1 — Multi-Step Loop Body

**Skeleton:**
```python
def process(items):
    result = []
    for item in items:
        if condition(item):            # filter
            transformed = op(item)     # transform
            result.append(transformed) # accumulate
    return result
```

**Drills:**
1. **(B2)** List of student dicts -> return names of students scoring >= 70, uppercased
2. **(B2)** List of `"LEVEL: message"` strings -> return messages from ERROR lines only
3. **(B3)** List of order dicts -> return `{"customer": name, "total": amount}` dicts for completed orders only

**Common wrong versions:**
```python
# return inside loop — exits on first match
for item in items:
    if condition(item):
        return op(item)

# filter step missing — accumulates everything
for item in items:
    result.append(op(item))

# appends original instead of transformed
for item in items:
    transformed = op(item)
    if condition(item):
        result.append(item)       # should be transformed
```

**Success:** all 3 steps in one loop body, return OUTSIDE loop, correct result type. < 5 min independent.

---

## A2 — Grouping / Bucketing

**Skeleton:**
```python
def group_by_x(items):
    groups = {}
    for item in items:
        key = derive_key(item)
        if key not in groups:
            groups[key] = []
        groups[key].append(item)
    return groups
```

**Drills:**
1. **(B2)** List of `{"name", "department"}` dicts -> group by department
2. **(B2)** List of words -> group by first letter
3. **(B3)** List of `{"student", "grade", "score"}` dicts -> group by grade, compute average score per grade. Return `{"A": 92.5, "B": 83.0}`

**Common wrong versions:**
```python
# no init check — KeyError
groups[key].append(item)

# returns flat list, not grouped dict
result = []
for item in items:
    result.append(derive_key(item))

# overwrites instead of appending
groups[key] = item

# .get() creates a new list but doesn't store it
groups.get(key, []).append(item)   # list is thrown away
```

**Success:** `groups = {}` before loop, init check present, appends under key, returns dict of lists. < 5 min independent.

---

## A3 — Nested Validation + Error Collection

**Skeleton:**
```python
def validate_all(items):
    valid = []
    errors = []
    for item in items:
        try:
            check(item)              # per-ITEM, inside loop
            valid.append(item)
        except SomeError as e:
            errors.append((item, str(e)))
    return valid, errors
```

**Drills:**
1. **(B2)** `["10", "abc", "20", "", "30"]` -> parse each to int. Return `(valid_ints, error_strings)`
2. **(B2)** List of user dicts -> validate non-empty `"name"` and positive `"age"`. Return valid users + error reports
3. **(B3)** List of row dicts -> validate required fields exist and numeric fields parse. Return `(valid_rows, error_rows)` with error detail

**Common wrong versions:**
```python
# try/except wraps entire loop — one failure kills all
try:
    for item in items:
        check(item)
        valid.append(item)
except SomeError as e:
    errors.append(str(e))

# errors silently dropped
    except:
        pass

# returns only valid, errors lost
return valid
```

**Success:** try/except INSIDE the loop, both accumulators exist, errors capture what + why, returns both, loop continues after error. < 8 min independent.

---

## A4 — Pipeline / Chain

**Skeleton:**
```python
def stage1(data):
    for item in data:
        yield parse(item)

def stage2(records):
    for r in records:
        if passes(r):
            yield r

result = list(stage2(stage1(raw)))
```

**Drills:**
1. **(B2)** `parse_lines(lines)` yields `(level, message)` tuples; `filter_errors(records)` yields ERROR-level only. Chain them.
2. **(B2)** `double_values(numbers)` yields each number * 2; `filter_positive(numbers)` yields only > 0. Chain them.
3. **(B3)** Three stages: parse CSV lines -> filter by field value -> aggregate into `{"count", "total", "average"}` dict.

**Common wrong versions:**
```python
# materializes between stages — defeats lazy evaluation
stage1_result = list(stage1(data))
stage2_result = list(stage2(stage1_result))

# return instead of yield — only returns first item
def stage1(data):
    for item in data:
        return parse(item)

# chains in wrong order
result = list(stage1(stage2(raw)))
```

**Success:** each stage uses `yield`, stages chain directly (no intermediate `list()`), correct order, final consumer at end. < 10 min for 2-stage Band 2.

---

## D — Output Shape (protocol, not standalone drills)

Apply to every drill:
1. Read asserts -> what TYPE is expected?
2. Write `return {}` or `return []` or `return 0.0` FIRST
3. Build body to fill that shape

**Common wrong shapes:**

| Expected | Got instead | Cause |
|---|---|---|
| `dict` of lists | flat `list` | A2 failure |
| `(valid, errors)` | just `valid` | A3 forgot dual accumulator |
| `list` of items | single item | return inside loop |
| `dict` with stats | `float` | computed one stat, not the collection |

---

## E2 — try/except Scope

```python
# WRONG — one bad item kills loop    # RIGHT — bad item logged, loop continues
try:                                  for item in items:
    for item in items:                    try:
        process(item)                         process(item)
except ValueError:                        except ValueError:
    handle()                                  handle(item)
```

**Drill:** take any A1 or A2 drill, add "some items are malformed — skip bad ones, log them, keep processing."

---

## B, C, F — Protocol-Managed (no dedicated drills)

**B (Freeze):** Decomposition protocol. Step down band. Never force through.

**C (Misread):** 60-second input/output read before every problem:
read signature -> read asserts -> write "input is ___, output is ___"

**F (Mechanical):** Escalate only if same bug repeats in-session. Otherwise ignore.
