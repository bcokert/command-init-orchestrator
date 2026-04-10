---
version: 1.0.0
description: |
  Reads the orchestration dashboard, identifies the next actionable task, and provides the exact kickoff prompt for a human to run. Updates the task status to in-progress.
allowed-tools:
  - Read
  - Write
  - Glob
  - AskUserQuestion
---

# Implement — Guided Task Kickoff

Your job is to read the dashboard, find the next ready task, and give Bdon the exact prompt to kick it off.

---

## Phase 0 — Load state

Read `.orchestration/dashboard/summary.md`. If it doesn't exist, say:

> "No dashboard found. Run /breakdown on a spec first."

Show the active specs and current state.

---

## Phase 1 — Identify next task

If a spec-id was passed as argument, read `.orchestration/dashboard/{spec-id}.md`.
If not, show the active specs and ask which one to work on.

Find the next task that is:
- Status: `todo`
- All `depends_on` tasks have status `done`

If no task is actionable, say so and explain what's blocking.

---

## Phase 2 — Present the kickoff

Read the task file. Present:

**Task:** {title} — {one-sentence summary of what it does}
**Agent role:** {agent_type} — {brief reason, e.g. "server-side Go work"}

**Kickoff prompt** (paste into a new Claude Code session):

```
Read .orchestration/agents/{agent_type}.md for your role context.
Read .orchestration/specs/tasks/{spec-id}/NN-{slug}.md and implement it.
Read the full spec at .orchestration/specs/briefs/{spec-filename} for constraints and observable outcomes.
When done, update the task file frontmatter status to "done".
```

**Done signal to watch for:**
{Restate the done signal from the task file in 1-2 lines.}

---

## Phase 3 — Update dashboard

Ask: "Ready to mark this as in-progress?"

If yes:
- Update task file frontmatter: `status: in-progress`
- Update `.orchestration/dashboard/{spec-id}.md` — change status in the table
- Update `.orchestration/dashboard/summary.md` — no change needed until task completes

---

## Behavior rules

- Only show tasks that exist in task files. Never invent.
- Always verify depends_on before recommending a task.
- The kickoff prompt must be exact and complete — agent should need nothing else to start.
