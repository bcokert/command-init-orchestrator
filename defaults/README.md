# Orchestration system — reference

---

## Commands

| Command | What it does |
|---------|-------------|
| `/design` | Full planning pipeline: design interview → slicing → spec → breakdown. Commits at each human approval gate. |
| `/implement` | Creates a git worktree, runs tasks sequentially, runs QA automatically. Stops at signoff for human review. |
| `/review` | Approve (commits, merges, archives) or provide feedback (adds new slice to backlog). |
| `/status` | All active projects: stage, worktree, next action, time in stage. Plus done-this-week recap. |

---

## Stages

| Stage | Meaning |
|-------|---------|
| `design_in_progress` | Design interview running |
| `design_review` | Design doc ready for human review |
| `slicing_in_progress` | Slicing running |
| `slicing_review` | Slices ready for human review |
| `spec_in_progress` | Brief being written |
| `spec_review` | Brief ready for human review |
| `breakdown_in_progress` | Task files being created |
| `tasks_ready` | Tasks ready — run `/implement` |
| `implementing` | Tasks executing in worktree |
| `signoff_review` | QA passed — run `/review` |
| `feedback_pending` | Feedback slices added — run `/design` |
| `done` | Slice approved, archived |

---

## Folder layout

```
.claude/
  commands/
    design.md          ← /design command
    implement.md       ← /implement command
    review.md          ← /review command
    status.md          ← /status command

.orchestration/
  projects/
    {project-id}/
      01-design/       ← design doc
      02-slices/       ← slice files
      03-briefs/       ← delegation briefs
      04-tasks/        ← task files (slice-NN/ subdirs)
      05-qa/           ← QA reports
      status.md        ← ground truth: stage, transitions, worktree
    done/
      YYYY-MM/
        {project-id}/  ← archived after /review approve
  worktrees/
    {project-id}/      ← git worktree per active /implement
```
