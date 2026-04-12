---
spec: specs/briefs/project-sequencing-and-status/05.1-post-qa-design-alignment.md
slice: 05.1
step: 2
title: Add agent surfacing to tasks_ready gate
status: done
depends_on: [01-numbered-subfolder-paths.md]
agent_type: architect
assigned_at: 2026-04-11T00:00:00Z
completed_at: 2026-04-11T00:00:00Z
---

## Work

In `defaults/commands/design.md` Phase 7, extend the tasks_ready gate output to include agent surfacing before the "Run /implement" message:

1. After creating all task files, collect unique `agent_type` values from the task files. Count tasks per type.
2. Determine: if only one unique type → "single agent"; if more than one → "team of N".
3. Add to the gate output block:

```
Agent team:
  single agent: {type} ({N} tasks)

  — or —

  team of {N}:
    - {type} ({N} tasks)
    - {type} ({N} tasks)

Is this the right team, or do you want to adjust agent_type fields in
the task files first? (Adjust task files directly, then run /implement.)
```

The gate already says "Run /implement to start implementation" — this goes before that line.

## Done signal

tasks_ready gate output includes agent team summary with single/team label and task counts. Gate asks the confirmation question.
