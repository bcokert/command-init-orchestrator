---
version: 1.0.0
description: |
  Takes a delegation brief and breaks it into task files in specs/tasks/{spec-id}/. Each task maps to one slice and is self-contained for an agent to execute. Updates the orchestration dashboard.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Breakdown — Spec to Task Files

Your job is to read a delegation brief and produce one task file per slice, ready for an agent to execute.

---

## Phase 0 — Load inputs

If a spec file path was passed as argument, read it. If not, ask:

> "Which spec are we breaking down? (path to file, e.g. .orchestration/specs/briefs/2026-04-08-name.md)"

Read the spec. Extract `id` from frontmatter. If there's no `id` field, derive one from the filename (strip date prefix and extension, kebab-case slug).

Also read:
- The linked slices doc if referenced in the spec or its frontmatter
- `.orchestration/dashboard/summary.md` if it exists (to check if this spec is already there)

---

## Phase 1 — Confirm

Restate what you're breaking down and how many tasks you identified from the spec's breakdown table (Section 5). Ask Bdon to confirm before writing files.

---

## Phase 2 — Generate task files

For each row in the spec's breakdown table:

1. Assign a zero-padded task number: `00`, `01`, `02`, ...
2. Derive a kebab-case slug from the step title
3. Determine `agent_type` from the work involved:
   - API, HTTP, Go, server, vault, daemon, internal packages → `server-dev`
   - React, TypeScript, frontend, UI, web, CSS → `client-dev`
   - Tests, fixtures, QA, verification, coverage → `quality`
   - Architecture, schema, structure decisions, ADRs → `architect`
   - Default: `server-dev`
4. Set `depends_on` — list task filenames that must be done first. Default to sequential (each depends on previous). Only make parallel if the spec explicitly says tasks are independent.
5. Write the task file.

### Task file format

Path: `.orchestration/specs/tasks/{spec-id}/NN-{slug}.md`

```
---
spec: {spec-id}
spec_file: .orchestration/specs/briefs/{spec-filename}
step: {N}
title: {title from breakdown table}
status: todo
depends_on: [{NN-slug.md}, ...]
agent_type: {server-dev|client-dev|quality|architect|standards}
worktree: false
---

## Work

{Derived from the breakdown step and any matching slice detail. Be specific:
what files to create or modify, what functions to implement, what behavior to add.
Include enough detail that an agent can execute with only this file and the spec.}

## Context

Read first:
- `{spec_file}` — full delegation brief with observable outcomes and constraints

{Any architecture or context files relevant to this step, derived from the spec's constraints section.}

{Step-specific context: what the previous step produced, what this step builds on.}

## Done Signal

{Observable verification criteria from the slice validation and spec done definition.
Specific commands to run, outputs to check, endpoints to hit.
Must be verifiable without reading the implementation.}
```

---

## Phase 3 — Update the dashboard

After writing all task files:

**Create `.orchestration/dashboard/{spec-id}.md`:**

```markdown
---
spec: {spec-id}
updated: {today}
---

# {Spec Title} — Task Queue

| # | Task | Status | Agent | Notes |
|---|------|--------|-------|-------|
| 00 | {title} | todo | {agent_type} | |
| 01 | {title} | todo | {agent_type} | depends: 00 |
...

## How to kick off a task

\`\`\`
Read .claude/agents/{agent_type}.md for your role.
Read .orchestration/specs/tasks/{spec-id}/NN-{slug}.md and implement it.
Read the full spec at .orchestration/specs/briefs/{spec-filename} for context.
When done, update the task file status to "done".
\`\`\`
```

**Update `.orchestration/dashboard/summary.md`:** Add or update the row for this spec.

If `summary.md` doesn't exist, create it:

```markdown
---
updated: {today}
---

# Orchestration Summary

## Active specs

| ID | Title | Status | Tasks | Done | QA |
|----|-------|--------|-------|------|----|
| {spec-id} | {title} | ready | {N} | 0 | — |

## Blocked

*(none)*
```

---

## Behavior rules

- Always confirm with Bdon before writing task files.
- Task files are self-contained — agent needs only the task file and the spec, nothing else.
- `depends_on` defaults to sequential. Only loosen if the spec explicitly marks slices as parallel.
- Never invent work not in the spec. Derive everything from what's written.
- Each done signal must be observable without reading the implementation.
