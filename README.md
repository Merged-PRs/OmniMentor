# OmniMentor

**A practical-first learning coach, packaged for Claude Code and ChatGPT.**

OmniMentor makes you *do* the thing you're learning instead of reading about it: practice before theory, hints before answers, and a concrete next step every time. It adapts to your demonstrated level, plans study timelines, and covers coding, DSA, system design, theory, and general skills through 18 slash-commands.

One shared behavior spec (`core/omnimentor-core.md`) drives two installable forms — a **Claude Code skill** and a **ChatGPT Custom GPT** — so it runs natively in either tool instead of being pasted each time.

> **On "standalone app":** OmniMentor is an *instructions* artifact, not compiled software — nothing executes inside the model. The runnable form is an installed **skill** (Claude Code) and a named **Custom GPT** (ChatGPT), invoked by name.

## Repository layout

```
omnimentor/
├── README.md
├── LICENSE
├── .gitignore
├── .gitattributes
├── core/
│   └── omnimentor-core.md      # SHARED SOURCE OF TRUTH (also the ChatGPT knowledge file)
├── .claude/
│   └── skills/
│       └── omnimentor/
│           └── SKILL.md        # Claude Code skill — auto-loads when this repo is open
└── chatgpt/
    ├── instructions.txt        # compact brief for the GPT "Instructions" box (6,956 chars)
    └── SETUP.md                # step-by-step Custom GPT build guide
```

## Install — Claude Code

- **Use it in this repo:** clone and open the folder in Claude Code. The skill at `.claude/skills/omnimentor/` loads automatically for this project. Invoke with `/omnimentor`, or just type a command like `/learn rust`.
- **Use it everywhere:** copy the skill folder to your personal skills directory:

  ```bash
  cp -r .claude/skills/omnimentor ~/.claude/skills/omnimentor
  ```

- **Claude desktop app:** you can also save the contents of `SKILL.md` as a personal skill so it persists across all sessions.

OmniMentor's `/learn`, `/dsa`, etc. are conventions the skill interprets — type them as text. They won't appear in the `/` autocomplete menu (only `/omnimentor` does); that's expected.

## Install — ChatGPT

Full walkthrough in [`chatgpt/SETUP.md`](chatgpt/SETUP.md). Short version:

1. Create a Custom GPT → **Configure** tab.
2. Paste `chatgpt/instructions.txt` into **Instructions**.
3. Upload `core/omnimentor-core.md` as a **Knowledge** file.
4. Turn **Code Interpreter ON** (lets it actually run your code).

The two-part split exists because ChatGPT caps the Instructions box at ~8,000 characters while the full core is 17,370 — the brief runs OmniMentor on its own, and the knowledge file supplies the fine detail. If your editor accepts a larger paste, you can drop the full core straight into Instructions instead.

## Commands

| Group | Commands |
|---|---|
| Learn & plan | `/learn` · `/timeline` · `/roadmap` |
| Force a mode | `/program` · `/dsa` · `/design` · `/theory` |
| Practice & test | `/quiz` · `/practice` · `/challenge` · `/recap` |
| Code help | `/debug` · `/review` |
| Explain | `/explain` · `/eli5` |
| Adjust difficulty | `/harder` · `/easier` |
| Build | `/project` |

Full behavior for each is defined in [`core/omnimentor-core.md`](core/omnimentor-core.md).

## Editing & keeping the two forms in sync

`core/omnimentor-core.md` is the **single source of truth**. After any behavior change:

1. **Always** re-sync both: update the skill (the SKILL.md carries the full core inline) and re-upload the core as the GPT's knowledge file.
2. **If you changed an always-on rule, a mode, or a command,** also update `chatgpt/instructions.txt` (the compact brief) and re-paste it into the GPT.
3. **Detail-only changes** (the First-Message Resolution Order, carve-outs) need only the knowledge re-upload — the brief points to the file for those.

## Known ceilings

- **No memory across chats.** OmniMentor treats any recap you give as a hypothesis and verifies it with a quick diagnostic before trusting your stated level.
- **Code correctness isn't guaranteed by inspection.** Where the host can run code (ChatGPT Code Interpreter, or a Claude Code session with file access), OmniMentor prefers running your code over eyeballing it.

## Smoke test (either tool)

- `/dsa two sum` → should ask a guiding question, not reveal "use a hash map."
- `/timeline python 2 months` → should return the 5-part plan with the exact phase-table columns.
- `what's the syntax for a python list comprehension?` → should answer directly and stop (transactional escape hatch), no quiz tacked on.

## License

[MIT](LICENSE).
