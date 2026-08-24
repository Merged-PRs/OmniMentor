# OmniMentor as a ChatGPT Custom GPT — Build Kit

This turns OmniMentor into a **named, persistent GPT** you pick from your sidebar — no pasting a prompt every chat.

## Why this is split into two parts

ChatGPT's custom-GPT **Instructions** box has a character cap (**8,000 characters** as of early 2025). The full OmniMentor spec is **17,370 characters**, so it doesn't fit. The fix keeps full fidelity:

| Part | What goes there | File | Size |
|---|---|---|---|
| **Instructions field** | A self-sufficient compact operating brief — runs OmniMentor on its own | `chatgpt/instructions.txt` | 6,956 chars ✓ fits |
| **Knowledge file** | The full spec (resolution order, carve-outs, psychological basis) for depth | `core/omnimentor-core.md` | 17,370 chars |

The brief already contains every always-on rule, all 18 commands, all 5 modes, and the timeline structure — so the GPT behaves correctly even before it consults the knowledge file. The knowledge file is the reference of record for the fine detail.

> **If OpenAI has raised the Instructions cap since early 2025** (the editor shows a live character counter): skip the brief and paste the entire `core/omnimentor-core.md` straight into Instructions instead. Highest fidelity, one fewer moving part. Still attach `core/omnimentor-core.md` as a knowledge file as a backstop.

---

## Fields to paste

**Name**

```
OmniMentor
```

**Description** (shown under the GPT name)

```
A practical-first learning coach. Learn any skill by doing — coding, DSA, system design, theory, or a full study plan. Practice before theory, hints before answers, and a concrete next step every time. Try /learn, /dsa, /timeline, or /quiz.
```

**Instructions** — paste the full contents of `chatgpt/instructions.txt` (or the full `core/omnimentor-core.md` if your cap allows, per the note above).

**Conversation starters**

```
/learn React hooks
/timeline System Design in 3 months
/dsa sliding window
Teach me Python from scratch — I have about 1 hour a day
```

**Knowledge** — upload `core/omnimentor-core.md`.

---

## Capabilities (Configure tab)

| Capability | Setting | Why |
|---|---|---|
| **Code Interpreter & Data Analysis** | **ON** | Lets OmniMentor actually *run* the learner's code instead of reviewing by eye — this lifts the "static review only" ceiling for `/debug`, `/review`, and Programming Mode. |
| **Web Browsing** | Optional | ON if you want it to pull current docs or fresh practice problems; OFF keeps sessions focused and faster. |
| **Canvas** | Optional | Handy for longer code/writing the learner iterates on. |
| **Image Generation (DALL·E)** | OFF | Not needed for a coaching workflow. |

---

## Step-by-step

1. Go to **chatgpt.com** → sidebar → **GPTs** → **+ Create** (or **Explore GPTs → Create**). *(Creating GPTs needs a Plus / Pro / Team / Enterprise plan — see fallback below if you don't have one.)*
2. Open the **Configure** tab (skip the chat-based "Create" builder — Configure gives you the raw fields).
3. Paste **Name** and **Description**.
4. Paste the **Instructions** (the compact brief, or full core if it fits).
5. Add the four **Conversation starters**.
6. Under **Knowledge**, click **Upload files** and add `core/omnimentor-core.md`.
7. Set **Capabilities** per the table above.
8. Top-right **Create / Update** → set access to **Only me** (or share via link).
9. Test it: open the GPT and send `/dsa two sum` — it should ask a guiding question, *not* hand you the pattern.

---

## Fallbacks if you can't build a GPT

- **ChatGPT Projects** (available more broadly): create a Project, paste the compact brief into the Project's **custom instructions**, and attach `core/omnimentor-core.md` to the Project's files. Every chat in that Project inherits it.
- **No Projects or GPTs either:** start a fresh chat by pasting the full `core/omnimentor-core.md` as your first message. Least convenient, but identical behavior. Save it as a saved prompt/snippet to make it one click.

---

## Keeping it in sync with the Claude skill

`core/omnimentor-core.md` is the **single source of truth**. When you change behavior:

1. **Always** re-upload `core/omnimentor-core.md` as the GPT's knowledge file, **and** re-sync the Claude skill from the same core.
2. If the change touches an **always-on rule, a mode, or a command**, also update the compact brief (`chatgpt/instructions.txt`) and re-paste it into Instructions.
3. **Detail-only** changes (e.g. the First-Message Resolution Order or a carve-out) need only the knowledge re-upload — the brief points to the file for those.
