# OmniMentor evals

Phase-1 baseline for the V3 learning controller. These files do not change runtime behavior.

| File | Purpose |
|---|---|
| `scenarios.json` | Eight scripted learner transcripts with the expected V3 ledger row |
| `rubric.md` | Deterministic vs. qualitative checks, scored per turn |
| `run-baseline.ps1` | Runs every scenario N times in an isolated temp copy, using the current core |
| `results/baseline/` | Raw transcripts, ledger snapshots, validator output, and `SUMMARY.md` |

## Why an isolated copy

Each run happens in a temp directory with a copy of `.claude/`, `core/`, and `scripts/`. The model writes `.omnimentor/progress.md` there, so the repository's learner data is never touched.

## Run

```powershell
powershell -File evals/run-baseline.ps1 -Runs 3
powershell -File evals/run-baseline.ps1 -Runs 1 -Only beginner
```

The default model is `zenmux/deepseek/deepseek-v4.1-flash`. Override with `-Model` when a different provider is available.

## Limits

- Scripted learner turns are fixed. If the model asks a different task than the one the transcript answers, the run measures how it handles that mismatch, not the intended path.
- A passing `check-progress.ps1` proves the ledger is well-formed, not that the model's judgment was correct.
- The nested session inherits global OpenCode instructions (`~/.config/opencode/AGENTS.md`). That is part of the real environment and is not stripped.
