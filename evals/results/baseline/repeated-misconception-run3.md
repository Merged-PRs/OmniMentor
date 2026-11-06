# repeated-misconception - run 3

Model: `zenmux/deepseek/deepseek-v4.1-flash`

## Learner turn 1

```text
/learn Python dictionaries. Use this exact exercise: write word_count(text) returning {word: count} for a sentence. Split on whitespace only; do not lowercase or strip punctuation. Do not change the task or spec.
```

## Assistant turn 1 (exit 0)

opencode.exe : 
At C:\Users\prem\AppData\Roaming\npm\opencode.ps1:14 char:3
+   & "$basedir/node_modules/@opencode/cli/bin/opencode.exe"   $args
+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
> build ┬╖ deepseek/deepseek-v4.1-flash
ΓåÆ Skill "omnimentor" 
> build ┬╖ deepseek/deepseek-v4.1-flash
$ if (Test-Path .omnimentor\progress.md) { Get-Content .omnimentor\progress.md } else { "NO_PROFILE" }
NO_PROFILE
> build ┬╖ deepseek/deepseek-v4.1-flash
**Exercise: `word_count(text)`** ΓÇö return a dict mapping each word to how many times it appears.

**Spec (fixed, unchanged)**
- Split on whitespace only.
- Do **not** lowercase.
- Do **not** strip punctuation.
- Signature: `def word_count(text): ...` ΓåÆ `{word: count}`

**Starter**
```python
def word_count(text):
    counts = {}
    # your code here
    return counts

print(word_count("the cat the"))
```

One clarifying example, consistent with the spec: `"the cat the"` ΓåÆ `{"the": 2, "cat": 1}`.

Write your version now (a first attempt is fine ΓÇö it doesn't need to be clean). Then tell me what `word_count("A a")` should return and why.

## Learner turn 2

```text
counts = {}
for w in "a b a".split():
    counts[w] += 1
print(counts)
```

## Assistant turn 2 (exit 0)

opencode.exe : 
At C:\Users\prem\AppData\Roaming\npm\opencode.ps1:14 char:3
+   & "$basedir/node_modules/@opencode/cli/bin/opencode.exe"   $args
+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
> build ┬╖ deepseek/deepseek-v4.1-flash
**Γ£à Working** ΓÇö the plan is right: empty dict, loop over `text.split()`, bump a count per word.

**ΓÜá∩╕Å Broken (2 things)**

| Line | Problem |
|---|---|
| `for w in a" b "a.split():` | Quoting is mangled ΓÇö that won't parse. You likely meant one string literal like `"a b a"`. Also this sits at top level; the spec wants it inside `def word_count(text):`. |
| `counts[w] += 1` | Works only if `w` is **already** a key. First time you hit `"b"`, `counts["b"]` doesn't exist yet. |

**Answer this before editing** (no code needed for #1):

1. What does `counts["b"]` return when `"b"` was never added? What does `counts.get("b", 0)` return in that same state?
2. Then: rewrite just that one line so a brand-new word starts at 0 and an existing word goes up by 1.

And still unanswered: what should `word_count("A a")` return, and why?

## Learner turn 3

```text
counts = {}
for w in "x y x".split():
    counts[w] += 1
print(counts)
```

## Assistant turn 3 (exit 0)

opencode.exe : 
At C:\Users\prem\AppData\Roaming\npm\opencode.ps1:14 char:3
+   & "$basedir/node_modules/@opencode/cli/bin/opencode.exe"   $args
+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:String) [], RemoteException
    + FullyQualifiedErrorId : NativeCommandError
 
> build ┬╖ deepseek/deepseek-v4.1-flash
Same line, same bug ΓÇö so let's kill the dict one properly instead of retrying it.

**Why `counts[w] += 1` dies**
`counts[w] += 1` is shorthand for `counts[w] = counts[w] + 1`. Python evaluates the right side first, so on an empty dict it tries to *read* `counts["x"]` ΓåÆ `KeyError: 'x'`. A dict has no "missing key counts as 0" behaviour; plain `[]` demands the key already exists.

**Fill the blank** (don't copy a solution from elsewhere ΓÇö this is the whole lesson):

```python
counts[w] = counts.____(w, 0) + 1
```

Two things to decide: which dict method returns a fallback instead of raising, and what fallback makes sense for a counter.

**Also still wrong, separate issue**
`x" y "x.split()` is a malformed string literal ΓÇö should read `for w in "x y x".split():`. And per spec this must live in `def word_count(text):`, ending in `return counts` (not `print`).

**One-line check:** what does `word_count("hi, hi")` return? Mind the comma and the no-strip rule.

## Ledger after run

(no `.omnimentor/progress.md` was written)
