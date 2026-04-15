---
type: slice
slice: 5
order: 5
project: bcokert-00001-visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: tasks_ready
follow_up_of: 01
---

# Slice 5 — Commit-on-approval audit

**Goal:** Commits must happen ONLY at human approval gates — never mid-stage, never automatically during execution. The four gates that commit are: approve design, approve slices, approve spec, and `/review` approve. Audit all four commands to verify this rule is enforced consistently, and fix any deviations.

## Happy path

- `design.md` commits only at: end of design_review (user re-runs /design to approve), end of slicing_review, end of spec_review, end of breakdown (tasks_ready)
- `implement.md` never commits — not during task execution, not after QA, not at signoff_review
- `review.md` commits only on explicit approve: once for the worktree changes (slice work), once for the signoff/archive state update
- The README and diagrams accurately reflect this: the flow shows "uncommitted work visible to reviewer" during QA/signoff_review, and "committed" only after gates
- Any command that currently auto-commits mid-stage has that commit removed or deferred to the next gate

## Edge cases

- Breakdown gate: breakdown produces tasks but no human reviews tasks before /implement — verify whether a commit here is the right gate or if it should be deferred to slicing_review approval (tasks are a mechanical output of spec approval, so committing at breakdown is arguably correct)
- Push failures at gates: all commands should handle push failure gracefully (report, continue) without leaving the project in an inconsistent state
- The rule applies to both the main worktree and the project worktree — neither should have auto-commits outside of gate boundaries
