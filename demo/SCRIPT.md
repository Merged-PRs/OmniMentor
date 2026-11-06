# Recording script

Target length: **2:30–3:00**. One take, trimmed.

## Before you record

1. Close Slack, Discord, and notifications. Turn on Focus Assist.
2. Open Windows Terminal. Dark theme. Font size 17–18. Window 1920×1080.
3. Run the demo:

   ```powershell
   powershell -File demo/run-demo.ps1
   ```

   It creates a temp copy, seeds a profile, and starts OpenCode with the working model.
4. Start OBS (window capture) or Windows Snipping Tool **before** the 5-second countdown ends.
5. Do a 5-second test recording and check the text is readable at 100% zoom.

## Act 1 — Purpose (0:00–0:20)

No typing. Voiceover over the terminal or the hero image.

> “Most AI tools answer the question. OmniMentor makes you answer it. One mentor, every skill, and a memory of what you can actually do.”

## Act 2 — Learn by doing (0:20–1:40)

Type:

```text
@omnimentor /learn Python dictionaries
```

Wait for the task. It should give a small exercise, not a syntax lecture.

Then paste the wrong attempt:

```python
counts = {}
for w in "apple banana apple".split():
    counts[w] += 1
print(counts)
```

Let it respond. It should ask about the first time a key appears, **not** hand over the fix.

Type:

```text
hint
```

It should give a smaller nudge (`dict.get` or a membership check), still not the full solution.

Then paste the fix:

```python
counts = {}
for w in "apple banana apple".split():
    counts[w] = counts.get(w, 0) + 1
print(counts)
```

Add one line:

```text
Confidence: 3. get starts a missing key at 0.
```

Voiceover while it grades:

> “It reviews the attempt, names what is fragile, and records how independently I got there.”

## Act 3 — Memory (1:40–2:15)

Type:

```text
/progress
```

Voiceover:

> “This is not a chat log. It is evidence: what I demonstrated, whether I needed help, and when it is due again.”

Point at the updated dictionaries row and the two overdue reviews.

## Act 4 — Plan (2:15–2:45, optional)

Type:

```text
/timeline Python 8 weeks
```

Voiceover:

> “The same profile turns a vague goal into phases, checkpoints, and a weekly rhythm — and the plan moves when the evidence does.”

## Act 5 — Close (2:45–3:00)

Type nothing. Voiceover:

> “Don’t just learn about it. Be able to do it. OmniMentor.”

## Retake rules

- If it gives the full fix before your attempt, stop and retake.
- If it misreads a correct count, stop and retake. Keep sentences short and use distinct words (`apple banana apple`).
- Reset between takes:

  ```powershell
  powershell -File demo/run-demo.ps1
  ```

- If the model errors with a usage limit, run `/models` and pick `zenmux/deepseek/deepseek-v4.1-flash`.

## Claude Code variant

```bash
cp -r .claude/skills/omnimentor ~/.claude/skills/omnimentor
cd <demo-directory>
claude
```

Then use `/omnimentor /learn Python dictionaries` instead of `@omnimentor`.

## What not to show

- The API key, `opencode.json`, or any config screen.
- The eval harness, the core file, or the terminal history.
- Dead air while the model thinks. Cut it in the edit.
