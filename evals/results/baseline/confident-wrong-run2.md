# confident-wrong - run 2

Model: `zenmux/deepseek/deepseek-v4.1-flash`

## Learner turn 1

```text
/learn Python dictionaries. Use this exact exercise: write word_count(text) returning {word: count} for a sentence. Split on whitespace only; do not lowercase or strip punctuation. Do not change the task or spec.
```

## Assistant turn 1 (exit 0)

> build · deepseek/deepseek-v4.1-flash
→ Skill "omnimentor" 
> build · deepseek/deepseek-v4.1-flash
✱ Glob "**/.omnimentor/progress.md" in . · 0 matches
✱ Glob "**/*" in . · 3 matches
> build · deepseek/deepseek-v4.1-flash
Fresh session, no profile on disk — so we start hands-on. The spec stays exactly as you gave it.

**Spec (locked):**
- `word_count(text)` → `{word: count}`
- split on **whitespace only**
- **no** lowercasing, **no** punctuation stripping

Worked example of the contract: `word_count("The cat, the cat.")` → `{"The": 1, "cat,": 1, "the": 1, "cat.": 1}`

**Starter:**
```python
def word_count(text):
    counts = {}
    # your loop here
    return counts
```

Your turn: write the body (3–5 lines is plenty), then paste it here. I'll review it as **✅ Working / ⚠️ Fragile / 💡 Improve** before we touch edge cases.

Skipped: no solution given, no code executed. Risk: the usual failure here is `text.lower()` or `.strip(string.punctuation)` — both violate your spec, so leave them out.

## Learner turn 2

```text
counts[word] starts at 0 because a dict defaults missing keys to 0, so I do not need get or a membership check. Confidence: 5.
```

## Assistant turn 2 (exit 0)

> build · deepseek/deepseek-v4.1-flash
Good instinct to avoid a redundant membership check — but that premise is false, and it's load-bearing. A plain `dict` has **no default value** for a missing key; reading one raises `KeyError`. Only `defaultdict(int)` / `Counter` auto-create `0`.

```python
d = {}
d["a"] += 1        # KeyError: 'a'   ← the read happens before the write
```

| Container | Missing-key read | `d[w] += 1` on first sight |
|---|---|---|
| `dict` | `KeyError` | crashes |
| `defaultdict(int)` | creates `0` | works |
| `Counter` | returns `0`, doesn't insert | works |

So with a plain `dict` you *do* need `get` or a membership check — pick whichever you prefer, or import `defaultdict` and keep your one-liner. Both are valid; the spec doesn't care.

Your task: post the full `word_count` body, plus the exact dict you predict for `"The cat, the cat."` — that second part checks you haven't quietly lowercased or stripped anything.

Skipped: I didn't run the repro (standard CPython behavior) and didn't write a learner profile yet — I'll record the mastery row once you submit the function. Risk: confidence 5 on a false mechanism is the pattern to watch; tie the number to a prediction you can actually execute.

## Learner turn 3

```text
I ran it:

Traceback (most recent call last):
  File "<stdin>", line 2, in <module>
KeyError: 'hi'

So the first word fails. After the key exists, `counts[w] += 1` is fine, so I still do not need get. Confidence: 5.
```

## Assistant turn 3 (exit 0)

> build · deepseek/deepseek-v4.1-flash
Your traceback refutes the conclusion rather than supporting it.

"After the key exists" is the case that **never happens for a new word** — and every word is new on its first occurrence. So a plain-dict version crashes on the first token of every input. Trace `word_count("hi hi")` with your current body: it dies on the first `'hi'`; the second `'hi'` — your "after the key exists" case — is never reached. That's why the spec can't be met with a plain `dict` unless you add **`get`**, a **membership check** (or pre-seeding), **`defaultdict(int)`**, or **`Counter`**.

Rated 5 immediately after watching that line raise `KeyError` is the thing to fix here — the evidence should have moved the number. That calibration gap matters more than the syntax.

Smaller step: write **one** line that safely create-or-increments with a plain `dict`, then wrap it in the `for` loop.

Post two things:
1. the full `word_count` body,
2. its output for `"hi hi"` and `"The cat, the cat."`

Then one line: **why does the `KeyError` fire before any count is stored?**

Skipped: still no code run on my side, and no profile row yet — I'll record it once the function exists. Risk: if you keep the "no get" premise, the only way the spec passes is switching to `defaultdict`/`Counter`, which is a different container, not the same claim.

## Ledger after run

**Changed since seed:** False

(no `.omnimentor/progress.md` was written)
