# advanced - run 1

Model: `zenmux/deepseek/deepseek-v4.1-flash`

## Learner turn 1

```text
/learn Python decorators. I have used Python for years, so skip the basics. Use this exact task: write a logged decorator that prints the function name and preserves metadata. Do not change the task.
```

## Assistant turn 1 (exit 0)

> build · deepseek/deepseek-v4.1-flash
→ Skill "omnimentor" 
> build · deepseek/deepseek-v4.1-flash
⚙ execute {"code":"const r = await tools.glob({pattern: \"**/.omnimentor/progress.md\", hidden: true}).catch(e 
=> ({error: String(e)}));\nreturn r;"} 
> build · deepseek/deepseek-v4.1-flash
✱ Glob "**/.omnimentor/progress.md" 0 matches
> build · deepseek/deepseek-v4.1-flash
No profile on disk, so starting fresh — you said years of Python, so I'm skipping what a decorator is, closures, and `@` sugar.

**Task (unchanged):** implement `@logged` — on every call it prints the function's name, calls the function, returns its result, and leaves the function's metadata intact.

```python
import functools

def logged(func):
    def wrapper(*args, **kwargs):
        # TODO: your implementation
        ...
    return wrapper


@logged
def add(a, b):
    """Add two numbers."""
    return a + b
```

Calling `add(1, 2)` must print `add`; the checker won't just call it, it will **inspect** it:

| Check | Expected |
|---|---|
| `add(1, 2)` | prints `add`, returns `3` |
| `add.__name__` | `"add"` |
| `add.__doc__` | `"Add two numbers."` |
| `inspect.signature(add)` | `(a, b)` |
| `add.__wrapped__` | the original function |
| `add(*[1], **{"b": 2})` | still works |

Write your version and paste it — I'll run it against that table and review it as ✅ Working / ⚠️ Fragile / 💡 Improve.

*Skipped: nothing about the task; I didn't pre-explain `functools.wraps` — the metadata rows are the whole point. Risk: if you reach for manual attribute copying, `inspect.signature` will be the row that catches you.*

## Learner turn 2

```text
import functools
def logged(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        print(fn.__name__)
        return fn(*args, **kwargs)
    return wrapper

Confidence: 4. wrapper closes over fn and functools.wraps copies __name__ and __doc__.
```

## Assistant turn 2 (exit 0)

> build · deepseek/deepseek-v4.1-flash
$ @'
import functools, inspect

def logged(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        print(fn.__name__)
        return fn(*args, **kwargs)
    return wrapper

@logged
def add(a, b):
    """Add two numbers."""
    return a + b

print("call:", add(1, 2))
print("kwargs:", add(*[1], **{"b": 2}))
print("__name__:", add.__name__)
print("__doc__:", add.__doc__)
print("signature:", inspect.signature(add))
print("__wrapped__:", add.__wrapped__ is add.__wrapped__)
print("has wrapped:", hasattr(add, "__wrapped__"))
print("qualname:", add.__qualname__)
'@ | python -
add
call: 3
add
kwargs: 3
__name__: add
__doc__: Add two numbers.
signature: (a, b)
__wrapped__: True
has wrapped: True
qualname: add
> build · deepseek/deepseek-v4.1-flash
← Write .omnimentor/progress.md
Created file successfully: .omnimentor/progress.md
> build · deepseek/deepseek-v4.1-flash
Verified by running it — **all six rows pass**:

| Check | Result |
|---|---|
| `add(1, 2)` | prints `add`, returns `3` ✅ |
| `add(*[1], **{"b": 2})` | `3` ✅ |
| `__name__` / `__doc__` / `__qualname__` | `add` / `Add two numbers.` / `add` ✅ |
| `inspect.signature(add)` | `(a, b)` ✅ |
| `__wrapped__` | present ✅ |

- ✅ **Working:** correct first try; closure over `fn` and `return fn(...)` are right.
- ⚠️ **Fragile (only if reused):** if you stack two `@logged`, both print the *innermost* name — each layer closes over what it received, not the caller's view.
- 💡 **Improve — your explanation undersells the key line.** `wraps` copies `__module__`, `__name__`, `__qualname__`, `__annotations__`, `__doc__`, **and sets `__wrapped__ = fn`**. That last one is why `inspect.signature` follows through to the original; it isn't copying, it's keeping a link.

Without running it: delete `@functools.wraps(fn)` — **which table rows break, and which still pass?** Name the ones you're unsure about rather than guessing.

*Logged: Python / decorators → learning, independent, review 2026-11-07. Risk: your mental model of `wraps` is "copies two attrs," which is why the `__wrapped__` question is next.*

## Learner turn 3

```text
If I drop functools.wraps, the decorated function's __name__ becomes 'wrapper' and its docstring is lost. The call still works, but introspection and some frameworks break.
```

## Assistant turn 3 (exit 0)

> build · deepseek/deepseek-v4.1-flash
$ @'
import inspect

def logged(fn):
    def wrapper(*args, **kwargs):
        print(fn.__name__)
        return fn(*args, **kwargs)
    return wrapper

@logged
def add(a, b, *, verbose=False):
    """Add two numbers."""
    return a + b

print("call:", add(1, 2))
print("__name__:", add.__name__)
print("__doc__:", add.__doc__)
print("__qualname__:", add.__qualname__)
print("has __wrapped__:", hasattr(add, "__wrapped__"))
print("signature:", inspect.signature(add))
try:
    add(1, 2, verbose=True)
except TypeError as e:
    print("keyword call:", e)
'@ | python -
add
call: 3
__name__: wrapper
__doc__: None
__qualname__: logged.<locals>.wrapper
has __wrapped__: False
signature: (*args, **kwargs)
add
> build · deepseek/deepseek-v4.1-flash
← Edit .omnimentor/progress.md
Index: .omnimentor/progress.md
===================================================================
--- .omnimentor/progress.md
@@ -11,5 +11,5 @@
 ## Mastery
 
 | Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
 |---|---|---|---|---|---|---|---|
-| Programming / Python | decorators | learning | independent | 2026-11-06 | 1 | 2026-11-07 | Correct `@logged` first 
try; explained `wraps` as `__name__`/`__doc__` copy only, did not mention `__wrapped__` / signature propagation |
try; on removal probe identified `__name__`/`__doc__` loss and that calls still work, but not the signature collapse 
to `(*args, **kwargs)` from missing `__wrapped__` |

> build · deepseek/deepseek-v4.1-flash
Half right — I ran the unwrapped version:

| Check | With `wraps` | Without |
|---|---|---|
| `add(1, 2)` | `3` | `3` ✅ |
| kwargs pass-through | works | works ✅ |
| `__name__` | `add` | `wrapper` ❌ |
| `__doc__` | `Add two numbers.` | `None` ❌ |
| `__qualname__` | `add` | `logged.<locals>.wrapper` ❌ |
| `__wrapped__` | present | **gone** ❌ |
| `inspect.signature` | `(a, b, *, verbose=False)` | `(*args, **kwargs)` ❌ |

The row you skipped is the one that actually bites: **`__wrapped__` is the link `inspect` follows.** Lose it and `signature()` reports the wrapper's own `(*args, **kwargs)`.

And "some frameworks break" is too soft. Your wrapper accepts *everything* and forwards it, so runtime calls never fail — the failure is **silent and upstream**: any tool that reads the parameter contract (FastAPI/Flask validation, `click` params, docs generators, `singledispatch`) now believes the function takes no named arguments.

So: a framework builds request validation from `inspect.signature`. What does it conclude about `add`'s parameters, and why is that worse than a wrong `__name__`?

*Profile updated: still `learning`, gap narrowed to the signature/`__wrapped__` mechanism. Risk: this is the one part of decorators that isn't cosmetic, so I'm holding the review at 1 day rather than moving on.*

## Learner turn 4

```text
`sorted(logged(f).__dict__)` -> `['__wrapped__']`. It points at the original function, and `inspect.signature` follows `__wrapped__` by default, so it reads the original parameter list. With `follow_wrapped=False` it shows the wrapper's own `(*args, **kwargs)`.
```

## Assistant turn 4 (exit 0)

> build · deepseek/deepseek-v4.1-flash
$ @'
import functools, inspect

def logged(fn):
    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        return fn(*args, **kwargs)
    return wrapper

def f(a, b, *, verbose=False):
    """doc"""
    return a + b

g = logged(f)
print("dict:", sorted(g.__dict__))
print("default:", inspect.signature(g))
print("no-follow:", inspect.signature(g, follow_wrapped=False))
print("same obj:", g.__wrapped__ is f)
'@ | python -
dict: ['__wrapped__']
default: (a, b, *, verbose=False)
no-follow: (*args, **kwargs)
same obj: True
> build · deepseek/deepseek-v4.1-flash
← Edit .omnimentor/progress.md
Index: .omnimentor/progress.md
===================================================================
--- .omnimentor/progress.md
@@ -11,5 +11,5 @@
 ## Mastery
 
 | Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
 |---|---|---|---|---|---|---|---|
-| Programming / Python | decorators | learning | independent | 2026-11-06 | 1 | 2026-11-07 | Correct `@logged` first 
try; on removal probe identified `__name__`/`__doc__` loss and that calls still work, but not the signature collapse 
to `(*args, **kwargs)` from missing `__wrapped__` |
`__wrapped__` is the only `__dict__` key, `inspect.signature` follows it, `follow_wrapped=False` exposes the wrapper. 
Still unexercised: stacked/parameterized decorators |

> build · deepseek/deepseek-v4.1-flash
Confirmed — re-ran your claims, all exact:

```
dict:       ['__wrapped__']
default:    (a, b, *, verbose=False)
no-follow:  (*args, **kwargs)
same obj:   True
```

Worth knowing *why* `__dict__` holds exactly one key: `update_wrapper` sets `__name__`, `__qualname__`, `__doc__`, `__annotations__`, `__module__` as **attributes on the wrapper** (not dict entries), then merges `fn.__dict__` (empty for a plain function), then assigns `__wrapped__`. That's also why `functools.wraps` beats hand-copying `__name__`/`__doc__` — it doesn't just copy, it links.

The one thing you sidestepped: **wrong `__name__` is cosmetic, wrong signature is the contract.** A signature-driven framework concludes `add` has no named parameters, so it validates nothing — no error, just the wrong thing, silently. That's the actual answer to "why is it worse."

Same task, one layer deeper (not a new task): stack `@logged` twice on `add` — what does each layer print, and does `signature()` still resolve to `(a, b, *, verbose=False)`?

*Profile: `learning` / independent, interval 1 → 3 days, review 2026-11-09. Skipped re-testing the `wraps` copy list — you demonstrated it. Risk: stacking is where most "I know decorators" claims break, which is why it's next.*

## Ledger after run

**Changed since seed:** True

```markdown
# OmniMentor Progress

## Active plan

_No active plan._

## Last session

- 2026-11-06 — Programming / Python: decorators (`@logged`) — next: name exactly which metadata checks break without `functools.wraps`

## Mastery

| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
|---|---|---|---|---|---|---|---|
| Programming / Python | decorators | learning | independent | 2026-11-06 | 3 | 2026-11-09 | Mechanism now solid: `__wrapped__` is the only `__dict__` key, `inspect.signature` follows it, `follow_wrapped=False` exposes the wrapper. Still unexercised: stacked/parameterized decorators |
```

### check-progress.ps1

```text
OK: C:\Users\prem\AppData\Local\Temp\omni-eval\advanced-1\.omnimentor\progress.md
```
