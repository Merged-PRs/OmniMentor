<div align="center">
  <img src="assets/hero.svg" alt="OmniMentor - one mentor, every skill" width="100%" />
</div>

<br />

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-5EEAD4?style=flat-square&amp;labelColor=0B0E14"></a>
  <img alt="Hosts: Claude Code, ChatGPT, OpenCode" src="https://img.shields.io/badge/hosts-Claude%20Code%20%7C%20ChatGPT%20%7C%20OpenCode-5EEAD4?style=flat-square&amp;labelColor=0B0E14">
  <img alt="20 commands" src="https://img.shields.io/badge/commands-20-5EEAD4?style=flat-square&amp;labelColor=0B0E14">
  <img alt="Verified on OpenCode" src="https://img.shields.io/badge/verified-OpenCode-34D399?style=flat-square&amp;labelColor=0B0E14">
</p>

<h1 align="center">One mentor. Every skill.</h1>

<p align="center">
  An adaptive learning coach that makes you <b>do</b> the work, then remembers what you actually mastered.<br />
  <sub>Claude Code &nbsp;/&nbsp; ChatGPT &nbsp;/&nbsp; OpenCode</sub>
</p>

---

OmniMentor turns a learning goal into a working practice loop. It picks a teaching method that fits the subject, gives you a task before it gives you theory, hints instead of answers, and tracks mastery by what you can do independently, not by what you have read.

It is an **instructions artifact**, not an app: one shared behavior spec that compiles into a Claude Code skill, a ChatGPT Custom GPT, and an OpenCode skill.

## Why it exists

| | A general chatbot | A fixed course | OmniMentor |
|---|---|---|---|
| Teaching method | Whatever you ask for | One method for everyone | Picks a mode per subject |
| Difficulty | Resets every chat | Fixed by the syllabus | Calibrated to demonstrated level |
| Progress | None | Lessons watched | Mastery, gaps, and review dates |
| Output | Answers | Completion | Independent capability |

## Architecture

<div align="center">
  <img src="assets/architecture.svg" alt="A shared core generates the Claude Code skill, the ChatGPT brief, and the OpenCode skill" width="100%" />
</div>

`core/omnimentor-core.md` is the single source of truth. Both host packages are generated from it, so behavior cannot drift between Claude, ChatGPT, and OpenCode.

## Install

### Claude Code

```bash
git clone https://github.com/Merged-PRs/OmniMentor.git
cd OmniMentor
cp -r .claude/skills/omnimentor ~/.claude/skills/omnimentor
```

Then, in any project:

```text
/omnimentor learn rust
```

Or simply ask: `teach me Rust from scratch, one hour a day`. `/omnimentor` is the registered command; the `/learn`, `/dsa`, `/timeline` tokens are conventions the loaded skill interprets. Typing a bare `/learn` will not reach the model.

### ChatGPT

1. **Explore GPTs -> Create** -> open the **Configure** tab.
2. Paste [`chatgpt/instructions.txt`](chatgpt/instructions.txt) into **Instructions**.
3. Upload [`core/omnimentor-core.md`](core/omnimentor-core.md) as a **Knowledge** file.
4. Turn **Code Interpreter & Data Analysis** on, so it can run your code instead of eyeballing it.

Full walkthrough: [`chatgpt/SETUP.md`](chatgpt/SETUP.md).

### OpenCode

No extra files. OpenCode 2.x discovers `.claude/skills` as a documented compatibility source, so opening this repository is enough:

```bash
cd OmniMentor
opencode
```

```text
@omnimentor /learn rust
```

Natural language works too. For a global install, copy the skill to `~/.claude/skills/omnimentor` (shared with Claude Code) or `~/.config/opencode/skills/omnimentor` (OpenCode only; higher precedence, so it shadows the project copy).

## Commands

| Group | Commands |
|---|---|
| Learn and plan | `/learn` `/timeline` `/roadmap` |
| Force a mode | `/program` `/dsa` `/design` `/theory` |
| Practice and test | `/quiz` `/practice` `/challenge` `/mock` `/recap` `/progress` |
| Code help | `/debug` `/review` |
| Explain | `/explain` `/eli5` |
| Adjust difficulty | `/harder` `/easier` |
| Build | `/project` |

Every command is specified in [`core/omnimentor-core.md`](core/omnimentor-core.md).

## How it teaches

<div align="center">
  <img src="assets/loop.svg" alt="Attempt, hint, feedback, spaced review" width="100%" />
</div>

| Mode | Applies to | Method |
|---|---|---|
| Programming | Languages and frameworks | Build first; syntax on demand; review as Working / Fragile / Improve |
| DSA | Algorithms and data structures | Pattern discovery, never a spoiler; same pattern disguised differently |
| System Design | Architecture | Scenario first, then scale and failure constraints, then trade-offs |
| Theory | Concepts | Short explanation, immediate quiz, a different analogy on a miss |
| General Skill | Everything else | The smallest real unit of practice, done now, with specific feedback |

A topic plus a timeframe triggers **Adaptive Timeline Planning** instead: a phase table, weekly rhythm, and checkpoints you can verify by doing.

## Memory

In hosts with file access, OmniMentor keeps a learner profile at `.omnimentor/progress.md` (git-ignored). Three sections: the active plan, the last session, and a mastery table.

| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
|---|---|---|---|---|---|---|---|
| DSA | sliding window | learning | hinted | 2026-11-06 | 1 | 2026-11-07 | window shrink off-by-one |

- **Proof** separates knowing from copying: `independent` (no hint, can explain it), `hinted` (after help), `solution` (revealed, copied, or cannot explain it).
- Only `independent` earns `mastered` and advances the review interval: **1 -> 3 -> 7 -> 21 -> 60 days**. A hint, a copied answer, or a miss resets it to 1.
- Topics use fixed namespaces (`Programming / <lang>`, `DSA`, `System Design`, `AI/ML`, `Theory`, `General Skill`), so Rust, DSA, and AI/ML are calibrated independently.
- One row per topic and subtopic, updated in place. Duplicates are merged, never accumulated.

Validate a profile with:

```powershell
powershell -File scripts/check-progress.ps1
powershell -File scripts/check-progress.ps1 -SelfTest
```

## Repository layout

```text
OmniMentor/
├── core/
│   └── omnimentor-core.md        # source of truth
├── .claude/skills/omnimentor/
│   └── SKILL.md                  # generated: Claude Code + OpenCode
├── chatgpt/
│   ├── instructions.txt          # compact brief, fits the 8k cap
│   └── SETUP.md
├── assets/                       # README visuals (SVG)
├── scripts/
│   ├── sync.ps1                  # regenerates SKILL.md, enforces the 8k cap
│   └── check-progress.ps1        # validates the learner profile
└── .omnimentor/progress.md       # created at runtime, git-ignored
```

## Verify

```powershell
powershell -File scripts/sync.ps1
```

```text
SKILL.md written      : <n> chars
core                  : <n> chars, 20 commands
chatgpt brief         : <n> chars (cap 8000), 20 commands
```

```powershell
powershell -File scripts/check-progress.ps1 -SelfTest
```

```text
SELFTEST PASS: good profile clean, bad profile caught 5 problems
```

OpenCode load test (2.1.4): `@omnimentor` resolves the skill and returns its rules verbatim, confirming the body is injected at load time rather than merely discovered.

## Design principles

OmniMentor operationalizes Bjork's *desirable difficulties* and the study-technique evidence behind them:

- **Retrieval practice** - attempt before being told, so recall does the work.
- **Desirable difficulty** - the hint ladder is the mechanism, not an inconvenience.
- **Spaced repetition** - review dates follow evidence, not a calendar.
- **Interleaving** - the same pattern appears in a new disguise, building recognition.

## Limitations

- **No memory on chat-only hosts.** A Custom GPT or plain chat cannot write `.omnimentor/progress.md`; paste the profile in and ask for an updated copy to save.
- **Code review is static unless the host can execute.** Where a runtime is available, OmniMentor runs the code instead of inspecting it.
- **Commands are conventions.** Only `/omnimentor` (Claude Code) and `@omnimentor` (OpenCode) are host-level entry points; the rest are interpreted by the loaded skill.
- **ChatGPT has an 8,000-character instruction cap.** The compact brief plus the knowledge file is the supported split.

## Contributing

`core/omnimentor-core.md` is the only place behavior should change. After editing it:

1. Run `scripts/sync.ps1` to regenerate the skill and check sizes.
2. Update `chatgpt/instructions.txt` if an always-on rule, mode, or command changed.
3. Run the validator self-test before opening a pull request.

## License

[MIT](LICENSE) - Copyright (c) 2026 prem
