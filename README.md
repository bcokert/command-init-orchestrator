# command-init-orchestrator

A Claude Code command that installs a project-level AI orchestration layer — a 4-command system for taking ideas from design through implementation to signoff.

## What it does

Run `/init-orchestrator` in any git repo. It installs 4 commands and creates the project folder structure. Safe to re-run.

## The 4 commands

| Command | What it does |
|---------|-------------|
| `/design` | Full planning pipeline: design interview → slicing → spec → breakdown. Stops when tasks are ready for implementation. Commits at each human approval gate. |
| `/implement` | Execution pipeline: creates a git worktree, runs tasks sequentially, runs QA automatically. Stops at signoff_review for human review. Nothing committed until `/review` approves. |
| `/review` | Closes the loop: approve (commits everything, merges branch, archives project) or provide feedback (adds new slices to backlog). |
| `/status` | Shows all active projects in a table: stage, worktree, next action, time in stage. Plus a done-this-week recap. |

## Project lifecycle

```
/design          /implement       /review
   │                  │               │
interview       worktree created   approve ──► merged + archived
   │                  │               │
slicing         tasks execute      feedback ──► new slices → /design
   │                  │
spec            auto QA
   │                  │
breakdown       signoff_review ──► /review
   │
tasks_ready
```

Each project lives in `.orchestration/projects/{username}-{seq}-{slug}/`. One folder, all artifacts.

## Slices

Work is planned and delivered one slice at a time. A slice is a thin vertical cut — something someone can observe and verify without reading code. Slices 02+ are intentionally rough until they become next; implementation reshapes them.

Human review gates exist after design, after slicing, after spec, and after QA. Nothing advances without a human re-running the command.

## Worktrees

`/implement` creates a git worktree for each project at `.orchestration/worktrees/{id}` on branch `project/{id}`. Multiple projects can run concurrently — each is isolated on its own branch. Main stays clean for planning. On signoff, the branch merges to main and the worktree is removed.

## Install

```bash
# In your target project:
/init-orchestrator
```

Installs: `design.md`, `implement.md`, `review.md`, `status.md` → `.claude/commands/`  
Creates: `.orchestration/projects/`, `.orchestration/worktrees/` (gitignored)

## Quick start

```
1. /design          — describe what you want to build
2. Review the design doc, edit if needed, re-run /design to continue
3. Review slice 01, set status: reviewed, re-run /design
4. Review the spec, re-run /design to generate tasks
5. /implement       — confirm agent team, tasks run automatically
6. /review          — approve or provide feedback
```

Run `/status` at any point to see where everything is.
