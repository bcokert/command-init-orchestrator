---
spec: specs/briefs/project-sequencing-and-status/10-init-and-education-audit.md
slice: 10
step: 3
title: Education audit
status: done
depends_on: [02-readme.md]
agent_type: architect
assigned_at: 2026-04-12T00:00:00Z
completed_at: 2026-04-12T00:00:00Z
---

## Work

Read all 4 command files (`design.md`, `implement.md`, `review.md`, `status.md`). For each, check every output block — stage transitions, gate messages, error messages — and verify it tells the user what to do next.

Checklist format:

```markdown
# Education audit

| Command | Location | Output type | Has "what next"? | Fix applied |
|---------|----------|-------------|------------------|-------------|
| /design | Phase 4 gate | stage transition | yes | — |
| /implement | Phase 1 failure | error | no | added "run /design..." |
```

For each gap found: fix the output text in the command file directly. Then mark "Fix applied" in the checklist.

Verify specifically:
- Every `*_review` gate tells the user what to run next
- Every wrong-command error names the correct command
- First-time worktree creation explains what worktrees are (implement.md Phase 1)
- `/review` feedback path tells the user to run `/design`

## Done signal

Audit checklist committed. Every gap found has a fix applied. All 4 command files have complete "what to do next" guidance at every output point.
