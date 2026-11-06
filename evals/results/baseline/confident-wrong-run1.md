# confident-wrong - run 1

Model: `zenmux/deepseek/deepseek-v4.1-flash`

## Learner turn 1

```text
/learn Python dictionaries. Use this exact exercise: write word_count(text) returning {word: count} for a sentence. Split on whitespace only; do not lowercase or strip punctuation. Do not change the task or spec.
```

## Assistant turn 1 (exit 0)

> build · deepseek/deepseek-v4.1-flash
→ Skill "omnimentor" 
> build · deepseek/deepseek-v4.1-flash
⚙ execute {"code":"const r = await tools.glob({ pattern: \".omnimentor/**\", hidden: true });\nconst rows = 
r.entries ?? r;\nreturn JSON.stringify(rows);"} 
> build · deepseek/deepseek-v4.1-flash
✱ Glob ".omnimentor/**" 0 matches
> build · deepseek/deepseek-v4.1-flash
**Task — `word_count(text)`** (spec locked exactly as you gave it)

| Rule | Meaning |
|---|---|
| Return | `{word: count}` for one sentence |
| Split | Whitespace only — words are the whitespace-separated tokens |
| Case | **No** lowercasing |
| Punctuation | **No** stripping — it stays on the word |

Examples that follow this spec:

| Input | Expected |
|---|---|
| `"the cat the"` | `{"the": 2, "cat": 1}` |
| `"Hi, hi"` | `{"Hi,": 1, "hi": 1}` |

Write it in `word_count.py` and paste your attempt. Include one line answering: why do `"Hi,"` and `"hi"` end up as two separate keys here?

Skipped: no dictionary syntax lecture and no starter code — you're writing those from memory. Risk: if you split on spaces instead of whitespace, tabs and newlines will break it; that's a bug in your code, not in the spec.

## Learner turn 2

```text
counts[word] starts at 0 because a dict defaults missing keys to 0, so I do not need get or a membership check. Confidence: 5.
```

## Assistant turn 2 (exit 0)

> build · deepseek/deepseek-v4.1-flash
**That's wrong, and it's worth catching now:** a plain `dict` has no default. Reading a missing key raises `KeyError` — it doesn't hand back `0`.

| Your claim | What Python actually does |
|---|---|
| `counts[word]` is `0` for unknown words | `counts[word]` → `KeyError` |
| `counts[word] += 1` works on first sight | Crashes on the first **new** word |

So `counts[word] += 1` on an empty dict would blow up at word one, before it ever counts.

Run this exactly as written and predict the output first:

```python
counts = {}
counts["the"] += 1
print(counts)
```

Then answer: what are **two** different ways to get the "starts at 0" behavior you assumed — and what does each one cost you? Once you've said that, fix `word_count` without the bug and paste the code.

Skipped: I didn't hand you the two mechanisms or a corrected `word_count` — that's the answer. Risk: at confidence 5 you'd have shipped this and hit `KeyError` on real input; your confidence number is the thing to distrust, not the dict.

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
Your run is correct evidence — `KeyError` on the first word, exactly as predicted. Two things though:

1. Your traceback says `'hi'`, so you ran your own input, not my snippet. Same bug, different key — fine, but note you changed the experiment.
2. You still haven't answered the question: **what are two ways to get "starts at 0", and what does each cost?**

And watch the claim drifting:

| Turn | Your statement | Status |
|---|---|---|
| 1 | "no `get` **and no membership check**" | False |
| 2 | "I still don't need `get`" | Possibly true — but only if you *reintroduce* the membership check you just dropped |

"`+= 1` is fine once the key exists" is true for **that word**. It says nothing about the first sight of the *next* new word, which hits the same `KeyError`. So whatever you write has to run on every unseen word, not just word one.

**Next:** write `word_count` now — `get` optional, your call. Then point at the exact line that handles a word appearing for the first time, and paste the code.

Skipped: didn't name the two mechanisms or write the function for you. Risk: confidence 5 twice in a row, once while wrong — that number is currently measuring your feeling, not your code.

## Ledger after run

**Changed since seed:** False

(no `.omnimentor/progress.md` was written)
