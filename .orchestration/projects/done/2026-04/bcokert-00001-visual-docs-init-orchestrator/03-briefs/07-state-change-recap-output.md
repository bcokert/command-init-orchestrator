---
type: brief
slice: 07
project: bcokert-00001-visual-docs-init-orchestrator
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/02-slices/07-state-change-recap-output.md
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
date: 2026-04-15
---

# Delegation brief — Slice 07: State change recap output

**Type:** Task (AI agent)
**Date:** 2026-04-15

---

## 1. Intent

After every stage transition, the active command should output a one-line status recap so the user always knows where the project is, what just happened, and what to run next — without scrolling. Currently the commands end with varying prose that doesn't follow a consistent pattern.

The recap line format:
```
※ Slice {NN} · stage {N}/{total} {stage_name} · {last event} → {next action} {emoji}
```

Two trailing emojis signal what kind of human action is needed:
- 📄 = review required (there's a doc, diff, or output to look at before proceeding)
- ▶️ = just run the next command (nothing to review, mechanical)

The stage counter `{N}/{total}` is derived from the ordered stage list in the command — not hardcoded. Current pipeline has 10 stages (design_in_progress through signoff_review). `feedback_pending` and `done` are outside the main sequence and rendered without a stage number.

Stage sequence and emoji:
| Stage | N | Emoji |
|-------|---|-------|
| design_in_progress | 1 | ▶️ |
| design_review | 2 | 📄 |
| slicing_in_progress | 3 | ▶️ |
| slicing_review | 4 | 📄 |
| spec_in_progress | 5 | ▶️ |
| spec_review | 6 | 📄 |
| breakdown_in_progress | 7 | ▶️ |
| tasks_ready | 8 | 📄 |
| implementing | 9 | ▶️ |
| signoff_review | 10 | 📄 |
| feedback_pending | — | 📄 |

---

## 2. Observable outcomes

**After /design gates**
```
Given /design completes slicing and reaches slicing_review
When the gate output is shown
Then the last line is:
  ※ Slice 01 · stage 4/10 slicing_review · slicing complete → review slices and re-run /design 📄
```

**After /implement QA pass**
```
Given QA passes and signoff_review is reached
When the output is shown
Then the last line is:
  ※ Slice 01 · stage 10/10 signoff_review · QA passed → run /review to approve 📄
```

**After /review approve**
```
Given /review runs and the slice is approved
When the output is shown
Then the last line is:
  ※ Slice 01 · feedback_pending · slice approved → run /design to spec next slice 📄
  (or "no slices remaining → project complete" if backlog is empty)
```

**After /review feedback**
```
Given /review records feedback
When the output is shown
Then the last line is:
  ※ Slice 01 · feedback_pending · {N} feedback slice(s) added → run /design to spec next 📄
```

---

## 3. Constraints

**Must:**
- Add the recap line to `defaults/commands/design.md` at: design_review gate, slicing_review gate, spec_review gate, tasks_ready output
- Add the recap line to `defaults/commands/implement.md` at: signoff_review (QA passed) output
- Add the recap line to `defaults/commands/review.md` at: approve path output, feedback path output
- Stage counter denominator must come from the length of the ordered stage list — not hardcoded as "10"
- Apply the same changes to `.claude/commands/` local copies
- The recap line is always the last line of output for that transition — nothing after it

**Must not:**
- Replace existing gate output prose — add the recap line after it
- Use hardcoded "10" as the denominator

**Preferences:**
- Keep the recap line on a single line — no wrapping, no extra blank line before it
- For new project (no slice number yet): `※ stage 1/10 design_in_progress · interview started → answer questions ▶️`

**Escalation triggers:**
- If a gate output block is ambiguous about where it ends (e.g., followed by a behavior rules section) — place the recap line before the "Wait here" instruction, not after the rules

---

## 4. Done definition

1. `defaults/commands/design.md` has a recap line after each of its 4 gate outputs
2. `defaults/commands/implement.md` has a recap line after the QA-passed output
3. `defaults/commands/review.md` has a recap line after both approve and feedback outputs
4. All recap lines match the format `※ Slice {NN} · stage {N}/{total} {stage_name} · {event} → {action} {emoji}`
5. The denominator in each recap is derived from a list length, not a literal "10"
6. `.claude/commands/` copies updated to match

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Add recap lines to `defaults/commands/design.md` (4 gates) + sync local copy | 4 recap lines added | Each gate output block ends with the recap line |
| 2 | Add recap line to `defaults/commands/implement.md` (1 gate) + sync local copy | 1 recap line added | QA-passed output ends with recap line |
| 3 | Add recap lines to `defaults/commands/review.md` (approve + feedback) + sync local copy | 2 recap lines added | Both output blocks end with recap line |
