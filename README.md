# OmniMentor

**A practical-first learning coach, packaged for Claude Code and ChatGPT.**

OmniMentor makes you *do* the thing you're learning instead of reading about it: practice before theory, hints before answers, and a concrete next step every time. It adapts to your demonstrated level, plans study timelines, remembers what you've mastered and what's slipping, and covers coding, DSA, system design, theory, and general skills through 20 commands.

One shared behavior spec (`core/omnimentor-core.md`) drives two installable forms — a **Claude Code skill** and a **ChatGPT Custom GPT** — so it runs natively in either tool instead of being pasted each time.

> **On "standalone app":** OmniMentor is an *instructions* artifact, not compiled software — nothing executes inside the model. The runnable form is an installed **skill** (Claude Code) and a named **Custom GPT** (ChatGPT), invoked by name.

## Repository layout

```
OmniMentor/
├── README.md
├── LICENSE
├── .gitignore
├── core/
│   └── omnimentor-core.md          # SHARED SOURCE OF TRUTH (also the ChatGPT knowledge file)
├── .claude/
│   └── skills/
│       └── omnimentor/
│           └── SKILL.md            # Claude Code skill — generated from the core, committed
├── chatgpt/
│   ├── instructions.txt            # compact brief for the GPT "Instructions" box (7,775 chars)
│   └── SETUP.md                    # step-by-step Custom GPT build guide
└── scripts/
    └── sync.ps1                    # regenerates SKILL.md from the core + checks the 8k cap
```

## Install — Claude Code

- **Use it in this repo:** clone and open the folder in Claude Code. The skill at `.claude/skills/omnimentor/` loads automatically for this project.
- **Use it everywhere:** copy the skill folder to your personal skills directory:

  ```bash
  cp -r .claude/skills/omnimentor ~/.claude/skills/omnimentor
  ```

- **Claude desktop app:** save the contents of `SKILL.md` as a personal skill so it persists across all sessions.

**How to invoke it in Claude Code.** `/omnimentor` is the real slash command. The `/learn`, `/dsa`, `/timeline`… tokens are conventions *inside* the skill's conversation, not registered commands — Claude Code intercepts unknown `/` commands and never sends them to the model. So use either:

```
/omnimentor learn rust
```

or just type normally — the skill description triggers it automatically:

```
teach me rust from scratch, I have an hour a day
```

Inside a session, `/dsa two sum` typed as a message is fine (the skill is already loaded).

## Install — ChatGPT

Full walkthrough in [`chatgpt/SETUP.md`](chatgpt/SETUP.md). Short version:

1. Create a Custom GPT → **Configure** tab.
2. Paste `chatgpt/instructions.txt` into **Instructions**.
3. Upload `core/omnimentor-core.md` as a **Knowledge** file.
4. Turn **Code Interpreter ON** (lets it actually run your code).

The two-part split exists because ChatGPT caps the Instructions box at ~8,000 characters while the full core is 21,524 — the brief runs OmniMentor on its own, and the knowledge file supplies the fine detail. If your editor accepts a larger paste, drop the full core straight into Instructions instead.

## Commands

| Group | Commands |
|---|---|
| Learn & plan | `/learn` · `/timeline` · `/roadmap` |
| Force a mode | `/program` · `/dsa` · `/design` · `/theory` |
| Practice & test | `/quiz` · `/practice` · `/challenge` · `/mock` · `/recap` · `/progress` |
| Code help | `/debug` · `/review` |
| Explain | `/explain` · `/eli5` |
| Adjust difficulty | `/harder` · `/easier` |
| Build | `/project` |

Full behavior for each is defined in [`core/omnimentor-core.md`](core/omnimentor-core.md).

## Memory: the learner profile

In hosts with file access (Claude Code), OmniMentor keeps a progress ledger at **`.omnimentor/progress.md`** in the current project:

| Topic | Subtopic / pattern | Status | Last evidence | Next review | Gap notes |
|---|---|---|---|---|---|
| DSA | sliding window | weak | 2026-11-06 | 2026-11-07 | off-by-one on window shrink |

- Read at the start of each session, updated after every assessment.
- Only **demonstrated application** earns `mastered` — never a topic merely "covered."
- Review dates follow a spaced schedule (1 → 3 → 7 → 21 → 60 days; a miss resets to 1).
- `/progress` shows it; `/recap` quizzes what's due plus past misses; `/timeline` uses it to place phases.
- The folder is git-ignored — it's your personal data, not project config.

In a plain chat or a Custom GPT there's no file system: paste your profile in, and ask for an updated one to save. Anything you claim is treated as a hypothesis and checked with a quick diagnostic — except for planning requests, where your stated level is used directly.

## Editing & keeping the three forms in sync

`core/omnimentor-core.md` is the **single source of truth**. After any behavior change:

1. **Always** run `powershell -File scripts/sync.ps1` — it regenerates `.claude/skills/omnimentor/SKILL.md` from the core and warns if the ChatGPT brief breaks the 8,000-char cap or drifts out of sync on command count.
2. Re-upload `core/omnimentor-core.md` as the GPT's knowledge file.
3. If you changed an always-on rule, a mode, or a command, also update `chatgpt/instructions.txt` and re-paste it into the GPT.

## Known ceilings

- **No memory across chats on chat-only hosts.** Claude Code gets the persistent profile above; a Custom GPT or plain chat starts fresh each conversation and falls back to diagnostic verification.
- **Code correctness isn't guaranteed by inspection.** Where the host can run code (ChatGPT Code Interpreter, or a Claude Code session with file access), OmniMentor runs your code instead of eyeballing it.

## Smoke test (either tool)

- `/dsa two sum` → should ask a guiding question, not reveal "use a hash map."
- `/timeline python 2 months` → should return the 5-part plan with the exact phase-table columns.
- `/progress` → in Claude Code, shows the ledger (or offers to create it); in ChatGPT, asks you to paste it.
- `what's the syntax for a python list comprehension?` → answers directly and stops (transactional escape hatch), no quiz tacked on.

## License

[MIT](LICENSE).
