---
spec: specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md
slice: 05
step: 4
title: Phase 4 — sequential task execution with timestamps
status: done
depends_on: [03-implement-phase3-agent-team.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Add Phase 4 to `defaults/commands/implement.md`:

1. Write `status.md` stage to `implementing` before executing any task:
   ```yaml
   stage: implementing
   transitions:
     - stage: implementing
       timestamp: {ISO 8601}
       note: task execution started
   ```

2. Build the execution queue: all `todo` tasks ordered by `step`, respecting `depends_on`. A task is runnable only if all tasks in its `depends_on` list have `status: done`.

3. If a `depends_on` reference doesn't exist or isn't `done` when it should be: stop and report which task is blocked and what's blocking it.

4. For each task in order:
   - Write `assigned_at: {ISO 8601}` to task file frontmatter.
   - Present the task to the agent (read task file, provide kickoff context from brief).
   - When task completes: write `completed_at: {ISO 8601}` and `status: done` to task file.
   - Proceed to next task.

5. If all tasks were already `done` when Phase 4 is entered: skip directly to Phase 5.

## Context

Read first:
- `specs/briefs/project-sequencing-and-status/05-implement-v1-single-project.md`

## Done signal

`status.md` shows `implementing` before first task runs. Each completed task file has both `assigned_at` and `completed_at` timestamps. Task with unsatisfied `depends_on` produces a clear block error rather than running.
