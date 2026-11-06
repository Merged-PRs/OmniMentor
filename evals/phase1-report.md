# OmniMentor V3 - Phase 1 Baseline Report

**Status:** Phase 1 complete. **Core not modified.**
**Scope:** inspect, fixture, baseline, propose. No implementation.

- Repository: `Merged-PRs/OmniMentor`
- Core under test: `core/omnimentor-core.md` at commit `3c5f1df`
- Harness model: `zenmux/deepseek/deepseek-v4.1-flash`
- Isolation: every run executes in a temp copy of `.claude/`, `core/`, and `scripts/`; the repository's learner data is untouched.

## 1. Conflicts between the current core and the V3 design

| # | Severity | Conflict | Current core | V3 design |
|---|---|---|---|---|
| C1 | **High** | Cold-start diagnostic | Requested task ships immediately; at most one question per message (`First-Message Resolution Order` #2 and #5) | A 2-3 item diagnostic on cold start |
| C2 | **High** | Mastery promotion | Only `independent` is required; one pass can set `mastered` | `mastered` also needs explanation and an independent transfer pass |
| C3 | **High** | Copied or solution-revealed attempt | Sets `learning` or `weak` immediately and writes the gap | No credit, keep earlier evidence, downgrade only after a fresh independent failure |
| C4 | **High** | Confidence | No field, no rule | 1-5 rating embedded in the task and stored in the ledger |
| C5 | **High** | Ledger schema | Exactly 8 columns; `check-progress.ps1` rejects any other count | Optional `Prereq`, `Confidence`, `Misconception` columns |
| C6 | Medium | Multiple prerequisites / misconceptions | Not defined | Must be defined without breaking one-row-per-key |
| C7 | **High** | Controller target | `/learn` starts the requested topic immediately | Choose the weakest blocking skill; prerequisites first |
| C8 | Medium | Misconception vs plateau | Plateau asks the learner whether to push or repair | Same misconception twice forces a repair and retest |
| C9 | Medium | `/quiz` and `/recap` | `/quiz` skips explanation; `/recap` quizzes everything covered | Both become task types of one controller; `/recap` targets due reviews |
| C10 | Low | `/debug` ladder | Direct fix only after 2 failed attempts | Nudge -> error location -> sub-problem -> worked solution |
| C11 | Medium | New-row interval | "Advances 1 -> 3 -> 7..." with no defined starting value | Independent pass advances the interval |
| C12 | Medium | `Last session` write timing | Writes are tied to assessments | Needed for recovery even when no assessment happens |
| C13 | Medium | Profile vs recap | A recap mismatch can trigger a diagnostic first | A fresh profile skips the diagnostic |
| C14 | Low | Evidence labels | Prefer running code when possible | Every practical task is labeled `Executed` or `Static` |
| C15 | Medium | Token budget | Core is ~6.2k tokens | Net growth capped at ~400 tokens |

### C1 - Cold start

The current order is explicit: the requested task ships first, and a message may contain at most one question. The V3 controller wants 2-3 diagnostic questions before the first task when no profile exists. Those rules cannot both hold.

**Minimal fix:** a cold-start carve-out. It applies only when there is no profile and the learner supplies no level evidence, and it is capped at three items. Every other message keeps the one-question budget. A fresh profile always wins over a conflicting recap (`C13`).

### C2, C11 - Promotion and intervals

The current rule is a single gate: `independent` can set `mastered`. V3 needs three evidences: independent pass, explanation, independent transfer. Confidence adds a fourth interaction: correct-but-unsure should not master on the same evidence set, and confident-but-wrong outranks everything.

`independent` must also be redefined: it means **no help was used** (no hint, no solution seen), not "can explain". The current proof rule bundles the two, so a correct guess that cannot be explained becomes `solution`. Explanation belongs to the mastery gate, not to proof.

The starting interval is also undefined. The sample row shows `1`, and the text says "advances", which leaves a new row ambiguous. Phase 2 must state: first independent evidence creates the row at interval 1; each further independent pass advances one step.

### C3 - Copied attempts

The current sentence "`solution` or a wrong answer sets `learning` (or `weak`)" destroys prior evidence. V3 says the opposite: keep the earlier evidence, reset the interval, run a prerequisite check, and change status only if a fresh independent check fails. This is a direct reversal and must be rewritten, not appended.

### C4, C5, C6 - Ledger contract

`check-progress.ps1` enforces `$c.Count -ne 8`, so adding columns breaks the validator before the model can use them. The update must be header-driven, accept 8 or 11 columns, allow empty optional cells, and validate confidence as 1-5 when present. Multiple values need one delimiter; `;` is the safe choice because it cannot collide with the markdown pipe.

The core also says the profile has "exactly three sections". V3 adds columns, not sections, so this stays compatible. A baseline run already wrote a file with different headings (`# OmniMentor Profile`, `##` instead of `###`), which the validator did not catch. Phase 2 should either enforce the section headings or stop claiming an exact schema.

### C7 - Requested topic vs weakest blocking skill

If a learner asks for X while the profile shows a blocking prerequisite Y for X, V3 overrides the request. The current core never does. Phase 2 needs one precedence line: an explicit request wins unless the profile proves a *blocking* prerequisite is missing; then state why in one line and repair first.

### C8 - Misconception vs plateau

These are different triggers and must not merge. Plateau is a choice offered to the learner. A repeated misconception is a blocking condition with no choice. The current plateau paragraph should stay, with one sentence making the distinction.

### C9, C10 - Command mapping

The command table is the largest block in the core (~3.2k characters). Compressing it is also the main way to pay for the controller within the 400-token budget. `/quiz` keeps its output shape but becomes a task type; `/recap` chooses its target from what is due, plus session misses. `/debug` maps onto the feedback ladder and keeps its no-fix-before-two-attempts rule.

### C15 - Feasibility

Mode detail should **not** move out of the core. In the ChatGPT package the core is a knowledge file, and the brief says the knowledge file is consulted for detail, not guaranteed on every turn. Moving mode rules there risks behavior drift. The budget should be paid by compressing the command table and merging duplicated response rules instead. Estimate: +1.6k characters of new controller text, -2.0k from the command table and duplicates, net ~+80 tokens.

### Baseline-discovered gaps (not visible from the text alone)

| ID | Gap | Evidence |
|---|---|---|
| G1 | **The write trigger is discretionary.** "Write after every assessment" depends on the model deciding an assessment happened. | 11 of 18 assessment runs wrote a ledger. `confident-wrong` wrote 0/3 despite a supplied traceback. |
| G2 | **A correct guess becomes `solution`.** The current `independent` definition bundles "no help" with "can explain". A correct guess is therefore `solution`, which is consistent with the current text but wrong for V3. | `correct-uncertain` wrote `solution` in 2/2 ledgers. V3 must split: `independent` = no help; explanation gates `mastered`. |
| G3 | **Scaffold files are unmanaged.** "Give a starter skeleton" can create files in the user's working directory. | Runs created `word_count.py` and `decorators_lab.py`; one leaked into the real repo during a probe and was removed. |
| G4 | **Seeded and written ledgers look identical to a file-existence check.** | The harness reported "written" for six runs whose seeded profile was byte-identical at the end. Verified manually; the harness now hashes before/after. |

## 2. Baseline fixtures

| ID | Path | Expected V3 outcome | Primary rule probed |
|---|---|---|---|
| `beginner` | Cold start, correct independent attempt | learning / independent / confidence 3 / interval 1-3 | Practice-first, proof, promotion |
| `advanced` | Claimed expertise, pass + explanation + `__wrapped__` mechanism (4 turns) | mastered / independent / confidence 4 | Mastery needs three evidences |
| `copier` | Pasted Counter solution, admits copying | learning / solution / interval 1 / gap note | No credit, evidence preservation |
| `repeated-misconception` | Same `KeyError` twice | learning / hinted / interval 1 / KeyError recorded | Repeat triggers repair |
| `confident-wrong` | Wrong model, then the actual `KeyError` traceback (3 turns) | weak / hinted / confidence 5 / KeyError recorded | Confident-wrong priority |
| `correct-uncertain` | Correct code, confidence 2 | learning / independent / confidence 2 | No promotion on low confidence |
| `returning-learner` | Fresh profile, due review, sliding-window attempt (2 turns) | Existing DSA row updated, no diagnostic | Profile beats cold start; dedupe |
| `transactional` | Syntax question mid-session | Direct answer; no ledger write | Escape hatch survives the controller |

Fixtures live in `evals/scenarios.json`. Each turn is fixed; the first turn anchors the task and spec so the scripted answers stay valid. That deliberately removes task invention from this baseline.

The first baseline exposed three fixtures with no gradable final turn: `advanced` never answered the `__wrapped__` question, `confident-wrong` never pasted the traceback it was told to run, and `returning-learner` had no attempt at all. All three now end in a concrete artifact (mechanism explanation, traceback, code + output). The superseded runs were discarded; the repaired baseline is in `evals/results/baseline/` and was re-run 3× before any Phase 2 edit.

## 3. Deterministic vs qualitative checks

**Deterministic** (`scripts/check-progress.ps1` on each run's ledger):

- file parses as the expected table
- no duplicate keys
- valid status, proof, interval, dates, topic namespace
- `mastered` only with `independent`
- `Next review = Last evidence + Interval`

**Qualitative** (`evals/rubric.md`, R1-R12): mode selection, withholding, question budget, confidence capture, proof honesty, write timing, promotion, misconception repair, transactional stop, next action, diagnostic skip, evidence label.

A clean validator result does not prove model judgment. It only proves the artifact is well-formed.

## 4. Baseline results

**24/24 runs completed. All assistant turns exited 0. No validator failures. Seeded profiles unchanged.**

### Run matrix

| Scenario | Runs | Ledger written | Validator | Observed row | Outcome |
|---|---|---|---|---|---|
| beginner | 3 | 3/3 | 3/3 pass | `learning` / `hinted` / interval 1 | No confidence; proof is `hinted` because the task itself hinted `dict.get`; no mastery |
| advanced | 3 | 3/3 | 3/3 pass | `learning` / `independent` · `solution` · `hinted` | No mastery; the model kept probing transfer |
| copier | 3 | 2/3 | 2/2 pass | `learning` / `solution` / interval 1 | Correct no-credit handling; one run never reached an assessment |
| repeated-misconception | 3 | 1/3 | 1/1 pass | `weak` / `hinted` / interval 1 | `KeyError` recorded in Gap notes; no dedicated field, no repair/retest loop |
| confident-wrong | 3 | 0/3 | n/a | none | The traceback was provided; the model kept drilling and never wrote. This is the write-trigger gap, not a fixture defect |
| correct-uncertain | 3 | 2/3 | 2/2 pass | `learning` / `solution` / interval 1 | Consistent with the current `independent` definition; V3 splits help from explanation |
| returning-learner | 3 | 1/3 (existing row) | 3/3 pass | DSA row updated once; no duplicate | 2/3 used the profile directly; 1/3 updated the row. No diagnostic |
| transactional | 3 | 0/3 (seed unchanged) | 3/3 pass | seed rows | 3/3 direct answers, no quiz, no next action, no write |

### Deterministic signals

- **11 ledgers written** across the 18 assessment runs; **11/11 pass** `check-progress.ps1`. No duplicate keys, bad dates, invalid status, or invalid proof.
- **12 ledger writes across all 24 runs**, including one returning-learner update.
- **0/24 confidence values.** The column does not exist in the current schema.
- **0 dedicated misconception values.** The one `KeyError` sits in Gap notes.
- **7/18 assessment runs wrote nothing.** `confident-wrong` wrote 0/3 and `returning-learner` 1/3; both had a gradable final turn, so this is a write-trigger gap.
- Transactional profiles were byte-identical after all three runs; the returning profile changed once, as intended.

### Qualitative signals

| Criterion | Result |
|---|---|
| R1 mode | Correct mode in the learning runs; advanced and confident-wrong stayed in mode but never closed the loop |
| R2 withholding | Task turns gave skeletons/specs, not finished solutions. The beginner task pre-hinted `dict.get`, which made `independent` unreachable |
| R3 question budget | Not stable: several first turns contain two or more question marks |
| R4 confidence | **0/24** |
| R5 proof | beginner `hinted` 3/3; copier `solution` 2/2; correct-uncertain `solution` 2/2 (wrong under V3) |
| R6 write timing | 11/18 assessment runs wrote; `confident-wrong` kept drilling and wrote nothing |
| R7 promotion | No mastery occurred; correct-uncertain was misclassified |
| R8 misconception | Recorded once in Gap notes; no repair or retest |
| R9 transactional | **3/3 pass** |
| R10 next action | Present in learning runs; absent in transactional replies (correct) |
| R11 cold start | Returning runs skipped the diagnostic in 2/3; run 1 is inconclusive |
| R12 evidence label | **0/24**. OpenCode did execute code (`python ...` and tool calls), so this is a core gap, not a harness limitation |

### Model artifacts (not core defects)

- **Arithmetic false negative.** The model claimed "the" occurs 3 times in `"the cat and the dog and the bird"` (it occurs 2) and marked a correct output wrong. This produced false gap notes in all three beginner ledgers.
- **Scaffolding side effects.** `/learn` created `word_count.py` and `decorators_lab.py` inside the isolated copies. The core does not define where scaffolds may be written.
- **Scripted-turn mismatch.** `advanced` and `confident-wrong` never reached an assessment because the fixed learner turns did not answer the teacher's exact follow-up. Those no-writes are a harness limitation, not proof of a core defect.

## 5. Proposed minimal changes (Phase 2, after approval)

| Edit | Fixes scenario | Cost |
|---|---|---|
| Add `Learning Controller` section (locate, task, confidence, evaluate, ladder, write, next) | beginner, copier, returning | +160 tokens |
| Rewrite promotion rules: `independent` = no help (explanation is a mastery gate), explanation + transfer for `mastered`, low-confidence extra item, confident-wrong priority | advanced, correct-uncertain, confident-wrong | +150 |
| Reverse the copied-attempt rule (keep evidence, prerequisite check) | copier | +40 |
| Add optional ledger columns + delimiter rules | repeated-misconception, confident-wrong | +60 |
| Add cold-start carve-out and profile-over-recap precedence | beginner, advanced, returning | +50 |
| Add repeated-misconception repair rule | repeated-misconception | +40 |
| Make the ledger write part of the loop, not a model judgment call | advanced, confident-wrong | +30 |
| Define correct-but-unsure as `independent` + confidence, not `solution` | correct-uncertain | +25 |
| Compress the 20-row command table into grouped controller parameters | all | -300 |
| Merge duplicate response rules and trim worked examples | all | -200 |
| Update `check-progress.ps1` + self-test for 8/11 columns, confidence, delimiters | deterministic | (script) |

Estimated net core growth: **~0 to +135 tokens**, inside the ~400 cap.

Each edit names the scenario it fixes, as required. No new commands, no new `.omnimentor/` files, no mode detail moved out of the core.

**Comparison protocol.** After the core edit, run the same 24 runs (8 scenarios × 3), with the same fixtures and the same harness, on the same model. A second model, `z-ai/glm-4.7-flash-free`, runs the same matrix as a drift check. It is the only additional model available on this key; premium models are blocked by a $0 balance, so it is a different model, not a verified stronger one.

## 6. Pre-registered Phase 2 thresholds

Set before any core edit. "Assessment runs" = beginner, advanced, copier, repeated-misconception, confident-wrong, correct-uncertain (18 runs). Returning is graded separately after its fixture repair; transactional is graded for no-write.

| Criterion | Baseline | Target |
|---|---|---|
| Ledger written | 11/18 | **≥15/18** |
| Confidence in written rows | 0/11 | **≥90%** |
| Validator pass on written ledgers | 8/8 | **100%**, including new columns |
| Copier no-credit | 2/2 `solution` | **2/2** |
| Transactional | 3/3 direct, 0 writes | **unchanged** |
| Returning | 1/3 (repaired) | **≥2/3** update the existing row, no duplicate |
| Seeded profiles unchanged | 3/3 transactional | **3/3** transactional only |
| Evidence labels | 0/24 | **≥80%** of code-assessing runs |
| Second model | not run | **no regression** against its own baseline |

## 7. Limitations

- Three runs per scenario is a small sample and is model-specific.
- `deepseek-v4.1-flash` made an arithmetic false negative in all three beginner runs. Treat model-specific misgrading as noise when judging the core; the second model is the drift check.
- Premium models are blocked by a $0 ZenMux balance. The second model is the free `z-ai/glm-4.7-flash-free`, not a verified stronger model.
- Scripted learner turns are fixed. The first turn anchors the exercise; if the model changes it anyway, the run measures recovery, not the intended path.
- The nested sessions inherit the global `~/.config/opencode/AGENTS.md` (Ponytail style), which is a confound for response shape.
- `check-progress.ps1` cannot verify explanation, transfer, or confidence semantics; only the ledger shape.
- The baseline model is `deepseek-v4.1-flash` through ZenMux because the local free tier is exhausted. A different model may behave differently.

## 8. Review of the Phase 1 harness (ponytail-review)

**What this change does:** adds an isolated, repeatable baseline for a prompt-only system and records the evidence for every run.

**Must fix**

1. **"Ledger written" was only "file exists"** (`evals/run-baseline.ps1:L120`). Six seeded profiles made runs look like writes. I verified those six were byte-identical by hand, so no reported number depends on the old behavior. The harness now hashes the profile before and after and reports `changed`.

**Should fix**

2. **No retry on a transient model/API failure.** A failed turn becomes a false "no ledger". All 24 runs exited 0, so this baseline is unaffected, but Phase 2 should retry once before recording a failure.
3. **Logs keep PowerShell wrapper noise.** ANSI is stripped; the `NativeCommandError` block is not. It makes transcripts harder to read but does not change their content.

**Nice to have**

4. `$outFile` is assigned twice in the runner. Harmless.

**Verdict:** ship the Phase 1 artifacts with fix 1. No runtime risk. Not checked: Claude Code and ChatGPT behavior; only OpenCode 2.1.4 with `deepseek-v4.1-flash`.

## 9. Approval gate

No core edit has been made. Phase 2 starts only after approval of:

1. the conflict list,
2. the promotion and cold-start semantics,
3. the optional-column format, and
4. the compression plan.

On approval: implement, sync, run the full 24-run matrix on both models, then commit locally in two commits (`evals`, then `core`). No push and no issue until you have read the after-results.
