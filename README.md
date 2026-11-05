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

<h1 align="center">OmniMentor</h1>

<p align="center">
  <b>One mentor. Every skill.</b><br />
  An adaptive learning system that makes you do the work, then remembers what you can actually do.
</p>

<p align="center">
  <a href="#purpose">Purpose</a> &nbsp;/&nbsp;
  <a href="#quick-start">Quick start</a> &nbsp;/&nbsp;
  <a href="#commands">Commands</a> &nbsp;/&nbsp;
  <a href="#how-it-works">How it works</a> &nbsp;/&nbsp;
  <a href="#memory">Memory</a> &nbsp;/&nbsp;
  <a href="#faq">FAQ</a>
</p>

---

## Purpose

> **Don't just teach someone something. Make them capable of doing it themselves.**

OmniMentor exists for one outcome: **you can do the thing without it.**

Most tools optimize for the moment of the answer. OmniMentor optimizes for the moment after: the tab is closed, the problem is still in front of you, and you can solve it anyway.

Three commitments follow from that:

- **Practice before theory.** You attempt first. Explanations arrive when they unblock you, not before.
- **A method per subject.** Programming, DSA, system design, theory, and general skills are taught differently because they are learned differently.
- **Evidence over self-report.** Progress counts only when you demonstrate it independently, and it is revisited on a schedule.

It is not a course library and not an answer machine. It is a behavior specification that turns a general model into a deliberate teacher.

## The problem

| | Typical AI chat | Typical course | OmniMentor |
|---|---|---|---|
| When you ask | You get an answer | You follow a syllabus | You get a task |
| Difficulty | Resets every chat | Fixed for everyone | Calibrated to evidence |
| Progress | Not tracked | Lessons completed | Capability demonstrated |
| After the session | Nothing persists | Next video | Weak spots return on schedule |

Answers feel productive and disappear. Courses are structured and inflexible. OmniMentor keeps the structure and drops the script.

## What you get

- **Five teaching modes** that change the method, not just the topic.
- **Twenty commands** for learning, practice, assessment, debugging, and planning.
- **A persistent learner profile** with mastery, gaps, and review dates.
- **Adaptive roadmaps** that compress, repair, or reorder phases from checkpoint evidence.
- **Mock interviews** with scored feedback and a top-three fix list.
- **Three hosts**: Claude Code, ChatGPT, and OpenCode, from one shared spec.

## Who it is for

| You are | You want | Start with |
|---|---|---|
| An engineer leveling up | Depth in DSA, system design, or a new language | `/learn`, `/dsa`, `/design` |
| A student or career switcher | A plan that survives contact with reality | `/timeline`, `/progress` |
| A working professional | Interview or communication practice | `/mock`, `/practice` |

## What it is not

| Not this | Because |
|---|---|
| A course library | There is no fixed curriculum or video backlog. |
| An answer machine | It withholds complete solutions until you have genuinely tried. |
| A model or an app | It is an instruction layer that runs on the model you already use. |
| A replacement for building | Practice is the point, not a supplement to it. |

## See it work

An abridged `/dsa` exchange:

```text
You    /omnimentor /dsa two sum

Coach  You have [2, 7, 11, 15] and target 9. Describe how you would
       find the pair by hand, then write the brute-force version and
       tell me its time complexity.

You    Two nested loops, compare every pair. O(n^2).

Coach  Correct. At 10,000 items that is about 50 million comparisons.
       What could you remember about each number you have already seen,
       so one pass is enough?
```

No pattern name. No solution. One question that moves you forward.

When the request is purely transactional, the coaching stops:

```text
You    what is the syntax for a Python list comprehension?

Coach  [expr for item in iterable if condition]
```

## Quick start

### Claude Code

```bash
git clone https://github.com/Merged-PRs/OmniMentor.git
cd OmniMentor
cp -r .claude/skills/omnimentor ~/.claude/skills/omnimentor
```

```text
/omnimentor learn rust
```

`/omnimentor` is the registered command. The `/learn`, `/dsa`, and `/timeline` tokens are conventions the loaded skill interprets; typing a bare `/learn` will not reach the model.

### ChatGPT

1. **Explore GPTs -> Create** -> open the **Configure** tab.
2. Paste [`chatgpt/instructions.txt`](chatgpt/instructions.txt) into **Instructions**.
3. Upload [`core/omnimentor-core.md`](core/omnimentor-core.md) as a **Knowledge** file.
4. Turn **Code Interpreter & Data Analysis** on, so it can run your code instead of inspecting it.

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

### Compatibility

| Host | Form | Persistent profile |
|---|---|---|
| Claude Code | `.claude/skills/omnimentor` skill | Yes, file-based |
| ChatGPT | Custom GPT, brief + knowledge file | No, paste the profile |
| OpenCode | `.claude/skills` compatibility | Yes, file-based |

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

## How it works

<div align="center">
  <img src="assets/architecture.svg" alt="A shared core generates the Claude Code skill, the ChatGPT brief, and the OpenCode skill" width="100%" />
</div>

One source of truth, three host packages. Behavior cannot drift between Claude, ChatGPT, and OpenCode because all three are generated from the same file.

<div align="center">
  <img src="assets/loop.svg" alt="Attempt, hint, feedback, spaced review" width="100%" />
</div>

| Mode | Applies to | Method |
|---|---|---|
| Programming | Languages and frameworks | Build first; syntax on demand; review as Working / Fragile / Improve |
| DSA | Algorithms and data structures | Pattern discovery, never a spoiler; the same pattern disguised differently |
| System Design | Architecture | Scenario first, then scale and failure constraints, then trade-offs |
| Theory | Concepts | Short explanation, immediate quiz, a different analogy on a miss |
| General Skill | Everything else | The smallest real unit of practice, done now, with specific feedback |

A topic plus a timeframe triggers **Adaptive Timeline Planning** instead: a phase table, a weekly rhythm, and checkpoints you can verify by doing.

## Memory

Where the host can write files, OmniMentor keeps a learner profile at `.omnimentor/progress.md` (git-ignored). Three sections: the active plan, the last session, and a mastery table.

| Topic | Subtopic / pattern | Status | Proof | Last evidence | Interval (days) | Next review | Gap notes |
|---|---|---|---|---|---|---|---|
| DSA | sliding window | learning | hinted | 2026-11-06 | 1 | 2026-11-07 | window shrink off-by-one |

- **Proof** separates knowing from copying: `independent` (no hint, can explain it), `hinted` (after help), `solution` (revealed, copied, or cannot explain it).
- Only `independent` earns `mastered` and advances the interval: **1 -> 3 -> 7 -> 21 -> 60 days**. A hint, a copied answer, or a miss resets it to 1.
- Topics use fixed namespaces (`Programming / <lang>`, `DSA`, `System Design`, `AI/ML`, `Theory`, `General Skill`), so Rust, DSA, and AI/ML are calibrated independently.
- One row per topic and subtopic, updated in place. Duplicates are merged, never accumulated.

Validate a profile with:

```powershell
powershell -File scripts/check-progress.ps1
powershell -File scripts/check-progress.ps1 -SelfTest
```

## Roadmaps that move

A plan is not a calendar. At every checkpoint, OmniMentor adjusts from evidence:

- **Passed** - compress the next phase and keep its milestone.
- **Blocking prerequisite missing** - insert a repair block before the dependent phase.
- **Non-blocking gap** - postpone that topic only; do not stall the whole plan.
- **Wrong depth** - change the phase's focus and rewrite the milestone.

Every change is logged in the active plan. Structural changes reprint the phase table; a date shift gets one line.

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

## Development

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

## FAQ

**Do I need an API key?**
No. OmniMentor runs inside a host you already use; model usage is billed by that host.

**Does it remember me between chats?**
Where the host can write files (Claude Code, OpenCode), yes, through `.omnimentor/progress.md`. In a Custom GPT or plain chat, paste the profile in and ask for an updated copy to save.

**Can I use it for non-technical skills?**
Yes. General Skill Mode covers writing, speaking, interviews, research, and other practice-based skills.

**Can I change how it teaches?**
Yes. Edit `core/omnimentor-core.md`, run `scripts/sync.ps1`, and update the ChatGPT brief if a rule or command changed. The spec is the only place behavior lives.

**Which host should I use?**
Claude Code or OpenCode if you want file-based memory. ChatGPT if you want a portable GPT. The teaching behavior is identical.

## Limitations

- **No memory on chat-only hosts.** A Custom GPT cannot write the profile; paste it in and save the updated copy.
- **Code review is static unless the host can execute.** Where a runtime is available, OmniMentor runs the code instead of inspecting it.
- **Commands are conventions.** Only `/omnimentor` (Claude Code) and `@omnimentor` (OpenCode) are host-level entry points; the rest are interpreted by the loaded skill.
- **ChatGPT has an 8,000-character instruction cap.** The compact brief plus the knowledge file is the supported split.

## Contributing

`core/omnimentor-core.md` is the only place behavior should change. After editing it:

1. Run `scripts/sync.ps1` to regenerate the skill and check sizes.
2. Update `chatgpt/instructions.txt` if an always-on rule, mode, or command changed.
3. Run the validator self-test before opening a pull request.

If OmniMentor helps you learn something, star the repo. It is the simplest signal that the approach is worth continuing.

## License

[MIT](LICENSE) - Copyright (c) 2026 prem
