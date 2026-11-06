# OmniMentor V3 Baseline Rubric

Scoring per turn: **0** = absent or violated, **1** = present and correct, **NA** = not applicable.

| ID | Criterion | How to judge |
|---|---|---|
| R1 | **Mode / intent** | Correct teaching mode for the subject, or transactional handling for a quick fact. |
| R2 | **Withholding** | No complete solution before 2 genuine attempts or an explicit ask. Transactional answers are exempt. |
| R3 | **Question budget** | At most one question in the reply. A confidence rating must be embedded in the task instruction, not asked as a separate question. |
| R4 | **Confidence** | A 1-5 confidence rating is requested or recorded when the task is issued. |
| R5 | **Proof** | The recorded proof matches how the answer was produced: `independent`, `hinted`, or `solution`. |
| R6 | **Write timing** | The ledger is updated in the same reply as the assessment, not deferred to the end of the session. |
| R7 | **Promotion** | Independent pass keeps `learning` and advances the interval; `mastered` needs an independent pass plus explanation plus an independent transfer pass; hinted resets to 1; a copied attempt gets no credit and does not downgrade earlier evidence by itself. |
| R8 | **Misconception** | A repeated misconception (or a confident wrong model) is named, recorded, repaired before progression, and retested. |
| R9 | **Transactional** | Direct, complete answer; no quiz, no forced next action, no ledger write. |
| R10 | **Next action** | Exactly one checkable next action, or an explicit command menu. Absent in transactional replies. |
| R11 | **Cold start / diagnostic** | A 2-3 item diagnostic only when there is no reliable profile. A fresh profile (independent evidence within 21 days) skips it. |
| R12 | **Evidence label** | Code or output is marked `Executed` when actually run, `Static` when only inspected. |

## Deterministic checks

Run `scripts/check-progress.ps1` on the ledger produced by each run. It proves:

- the file parses as the expected table
- no duplicate topic/subtopic keys
- valid status and proof values
- `mastered` only with `independent` proof
- `Next review = Last evidence + Interval`
- interval is one of 1, 3, 7, 21, 60
- valid top-level topic namespace
- `weak` rows carry a gap note

It does **not** prove model judgment. A clean validator result says nothing about R1-R5 or R7-R12. Those require reading the transcript.

## Interpretation rules

- Three runs per scenario. A criterion counts as **stable** only if it scores the same in all three.
- A single run that fails R2 (leaks a full solution) is a defect even if the other two pass.
- Ledger writes are compared against the expected row in `scenarios.json`; dates are checked relative to the run date.
- If the model does not write a ledger at all, treat R6 as 0 for scenarios that performed an assessment.
