---
version: 2.0.0
description: |
  Full planning pipeline for a single project: design interview → slicing → spec → breakdown → tasks_ready. Resumes from wherever the project left off. Commits and pushes at each human approval gate. Ends when tasks are ready for /implement.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - Skill
---

# Design — Full planning pipeline

Your job is to take a project from idea to tasks_ready. You own the full planning pipeline: design interview → slicing → spec → breakdown. You resume from wherever the project last stopped.

---

## Phase 0 — Detect state and route

### Step 1 — Identify the project

If a project ID or path was passed as argument, use it.

If no argument:
1. Scan `.orchestration/projects/` for folders with `status.md` where `stage` is not `done`, `implementing`, `qa_in_progress`, or `signoff_review`.
2. If one match: use it.
3. If multiple matches: list them and ask which to resume, or offer to start a new one.
4. If no matches: start a new project (proceed to Step 3).

### Step 2 — Wrong-command routing table

Full routing table for all commands and stages. `/design` enforces its own rows; `/implement` and `/review` enforce theirs. Check this table first — if the current command is wrong for the current stage, output the error and stop.

| Stage | Wrong command | Error message |
|-------|---------------|---------------|
| `slicing_in_progress`, `slicing_review` | `/implement` or `/review` | "Project '{id}' is in {stage} — run `/design` to continue." |
| `spec_in_progress`, `spec_review` | `/implement` or `/review` | "Project '{id}' is in {stage} — run `/design` to continue." |
| `breakdown_in_progress` | `/implement` or `/review` | "Project '{id}' is in {stage} — run `/design` to continue." |
| `tasks_ready` | `/review` | "Project '{id}' is in tasks_ready — run `/implement` to start implementation." |
| `tasks_ready` | `/design` | "Project '{id}' is in tasks_ready — run `/implement` to start implementation." |
| `implementing`, `qa_in_progress`, `signoff_review`, `feedback_pending` | `/design` | "Project '{id}' is in {stage} — run `/implement` to execute tasks, or `/review` once implementation is complete." |

Stop after outputting the error. Do no further work.

### Step 3 — Route by current stage

Read `status.md` if it exists. Route:

| Status | Action |
|--------|--------|
| No project folder | Create project (Step 4), then run interview (Phase 1) |
| `design_in_progress`, no `01-design/design-01.md` | Inform user interview didn't complete, run interview (Phase 1) |
| `design_in_progress`, `01-design/design-01.md` exists | Interview completed but status wasn't advanced — skip to Phase 4 (advance status + gate) |
| `design_review` | Show review gate (Phase 4) |
| `slicing_in_progress` | Resume slicing (Phase 5) |
| `slicing_review` | Show slicing gate (Phase 5) |
| `spec_in_progress` | Resume spec (Phase 6) |
| `spec_review` | Show spec gate (Phase 6) |
| `breakdown_in_progress` | Resume breakdown (Phase 7) |
| `tasks_ready` | "Tasks are ready — run `/implement` to start." Stop. |
| `feedback_pending` | Resume as new design run (Phase 1), increment run counter |

### Step 4 — Create new project

1. Get github username: `git config user.name`, fall back to prefix of `git config user.email`.
2. Derive slug from the project name: lowercase, kebab-case, max 5 words, strip stop words (the, a, an, for, of, in, to).
3. Scan `.orchestration/projects/` for folders matching `{username}-*`, find the highest sequence number, add 1, zero-pad to 5 digits. If folder already exists at derived path, increment and retry.
4. Create `.orchestration/projects/{id}/`. Create `.orchestration/projects/` if it doesn't exist.
5. Write `status.md` immediately — before any interview interaction:

```yaml
stage: design_in_progress
project_id: {id}
next_action: complete design interview
transitions:
  - stage: design_in_progress
    timestamp: {ISO 8601 with timezone offset}
    note: project created
```

6. Load project context before starting the interview:
   - Read `CLAUDE.md` in the current project directory if it exists.
   - Read `.root-context/architecture.md`, `.root-context/CONSTRAINTS.md`, `.root-context/DECISIONS.md` if they exist.
   - Note what you've read — don't ask questions the docs already answer.

Escalation checks (run before Step 4):
- If git is not initialised: stop — "This directory is not a git repo. Initialise git first."
- If `.orchestration/` exists with unexpected structure: stop and ask before proceeding.

---

## Phase 1 — Understand the request

Restate in one sentence what you've heard Bdon wants to design. Ask him to confirm or correct.

If nothing has been described yet, open with: "What are we designing?"

---

## Phase 2 — Interview

Surface everything Bdon knows but hasn't said yet.

**No filter on questions.** This is the only stage where every question is on the table. Once the design doc is written, that window is closed.

Ask **3–5 questions per turn**. Never more. Wait for answers before the next round.

Surface questions across these areas:

**Intent and motivation** — What problem does this solve? Why now? What does success look like?

**Current state** — How does it work today? What are the pain points? What constraints come from the current system?

**Desired end state** — What can someone do when this is done that they couldn't before? What does failure look like?

**Patterns and conventions** — What patterns should this follow? What should it explicitly not follow? What architectural decisions are relevant?

**Design decisions** — Where are the real forks in the road? What trade-offs need to be made?

**Boundaries** — What is explicitly out of scope? What must not be touched?

---

Keep a running context log every turn during Phase 2:

```
> **Context so far:**
> - resolved: [key fact or decision]
> - open: [question still unanswered]
```

Never move to Phase 3 while any item is `open`.

When the list has no open items: "I think I have everything. Ready to write the design doc?"

---

## Phase 3 — Write the design doc

Only begin when Phase 2 is complete with no open questions.

Target: ~200 lines. Do not compress unnaturally.

Apply bdonizer patterns inline before writing:
- **Strip AI patterns:** significance inflation, AI vocabulary ("crucial", "highlight", "landscape", "underscore", "vibrant"), em dash overuse, inline-header lists, filler phrases, excessive hedging, sycophantic tone.
- **Tune to voice:** no warmup sentence, short declarative payoffs, deadpan over dramatic, practical framing. Sentence case headings. Terse fragments are fine.

### Design doc format

```markdown
---
type: design
date: YYYY-MM-DD
feature: [short kebab-case name]
project_id: {id}
status: ready
---

# [Feature/Change Name] — Design

## Intent
[1-2 paragraphs. Full context for someone with no prior knowledge.]

## Current state
[Bullet list. Pain points, constraints, what exists today.]

## Desired end state
[Bullet list. Observable facts about the world when this is done.]

## Patterns to follow
[Bullet list. What to follow, what to avoid, and why.]

## Key edge cases
[Bullet list. Crashes, partial state, wrong-command errors, unrecoverable data. Primary input for slice validation.]

## Resolved design decisions
[One entry per decision. Decision / Why / Rejected alternatives.]
```

Write to `.orchestration/projects/{id}/01-design/design-01.md` (or `design-{NN}.md` for run N on a feedback_pending project). Create `01-design/` if it doesn't exist.

---

## Phase 4 — Advance status and design review gate

After writing the design doc:

1. Append to `status.md` transitions and update stage:
```yaml
stage: design_review
next_action: review design doc and run /design to continue to slicing
transitions:
  - stage: design_review
    timestamp: {ISO 8601}
    note: design interview complete
```

2. Commit and push:
   - `git add .orchestration/projects/{id}/01-design/design-{NN}.md .orchestration/projects/{id}/status.md`
   - `git commit -m "Design interview complete — {project_id}"`
   - `git push` — if push fails, report clearly and continue. Status is committed locally.

3. Show the review gate:

```
Design interview complete — {project_id}

Saved: .orchestration/projects/{id}/01-design/design-01.md

Highest-leverage review point. Corrections here cost nothing.
After slicing, corrections require updating slice files.
After implementation, corrections cost the most.

Review the design doc. Edit it directly if anything needs changing.
When ready, run /design to continue to slicing.
```

**Wait here.** Do not proceed to slicing until Bdon says to continue.

---

## Phase 5 — Slicing

### On entry

Check the current stage before writing anything:

- **Entering from `slicing_review`** (stage is already `slicing_review`): skip straight to the slicing gate below. No re-slicing, no file changes.
- **Entering from `design_review`**: write `slicing_in_progress` to `status.md` first:
  ```yaml
  stage: slicing_in_progress
  next_action: complete slicing
  transitions:
    - stage: slicing_in_progress
      timestamp: {ISO 8601}
      note: slicing started
  ```
- **Entering from `slicing_in_progress`** (resume after crash): check `.orchestration/projects/{id}/02-slices/` for existing files. If any exist: delete them all, log "previous slicing incomplete — regenerating", then proceed. If none exist: proceed.

Always re-read `01-design/design-{NN}.md` from disk before slicing. Never use cached content.

### Slicing

Read and follow `.claude/commands/slice.md` in full.

Pass `design-{NN}.md` as input. Produce individual slice files at `.orchestration/projects/{id}/02-slices/{NN}-{slug}.md`. Each slice: Goal + Happy path + Edge cases, 30–50 lines, hard cap 100.

### After all slice files written

1. Update `status.md`:
```yaml
stage: slicing_review
next_action: review slice files and run /design to continue to spec
transitions:
  - stage: slicing_review
    timestamp: {ISO 8601}
    note: {N} slices created
```

2. Commit and push:
   - `git add .orchestration/projects/{id}/02-slices/ .orchestration/projects/{id}/status.md`
   - `git commit -m "Slicing complete — {project_id} ({N} slices)"`
   - `git push` — if push fails, report clearly and continue. Status is committed locally.

3. Show the slicing gate:

```
Slicing complete — {project_id}

{N} slice files in .orchestration/projects/{id}/02-slices/

Slice 01 is fully detailed. Slices 02+ are intentionally rough — flesh
them out when they become next.

Every slice requires human review before it can be specced.
Review slice 01, edit directly if needed, then set status: reviewed.
When ready, run /design to continue to spec.
```

**Wait here.**

---

## Phase 6 — Spec

### On entry

Check the current stage before writing anything:

- **Entering from `spec_review`** (stage is already `spec_review`): skip straight to the spec gate below. No re-spec, no file changes.
- **Entering from `slicing_review`**: write `spec_in_progress` to `status.md` first:
  ```yaml
  stage: spec_in_progress
  next_action: complete spec
  transitions:
    - stage: spec_in_progress
      timestamp: {ISO 8601}
      note: spec started
  ```
- **Entering from `spec_in_progress`** (resume after crash): check if brief already exists for the target slice. If it exists: skip writing and advance to spec gate. If not: restart spec from the beginning.

### Slice selection

First, check if any slice has `status: signoff_review`. If so:
```
Slice {NN} — {title} — is awaiting signoff review.

Run /review to approve it (marks done) or provide feedback
(adds a new slice to the backlog) before speccing the next slice.
```
Stop.

Otherwise, select the target slice: the lowest-numbered slice file in `.orchestration/projects/{id}/02-slices/` with `status: reviewed` that comes after all slices with `status: specced`, `tasks_ready`, `implementing`, or `done`. Never skip a slice.

If the next slice has `status: draft` (not yet reviewed):
```
Slice {NN} — {title} — is draft and hasn't been reviewed yet.

Review the slice file at .orchestration/projects/{id}/02-slices/{NN}-{slug}.md.
Edit it directly if anything needs changing, then set status: reviewed.
When ready, run /design to continue to spec.
```
Stop. Do not spec a draft slice.

### Writing the brief

Read and follow `.claude/commands/spec.md` in full.

Write the delegation brief to `.orchestration/projects/{id}/03-briefs/{NN}-{slug}.md`.

### After writing

1. Update slice file frontmatter: `status: specced`
2. Update `status.md`:
```yaml
stage: spec_review
next_action: review brief and run /design to continue to breakdown
transitions:
  - stage: spec_review
    timestamp: {ISO 8601}
    note: spec written for slice {NN}
```

3. Commit and push:
   - `git add .orchestration/projects/{id}/03-briefs/ .orchestration/projects/{id}/02-slices/{NN}-*.md .orchestration/projects/{id}/status.md`
   - `git commit -m "Spec complete — {project_id} slice {NN}"`
   - `git push` — if push fails, report clearly and continue. Status is committed locally.

4. Show the spec gate (light review):

```
Spec complete — slice {NN}: {title}

Saved: .orchestration/projects/{id}/03-briefs/{NN}-{slug}.md

Light review — check:
- Intent gives enough context for an agent with no prior knowledge
- Observable outcomes cover happy path and key edge cases
- Constraints are specific enough to enforce
- Breakdown maps cleanly to the slice

Run /design to continue to breakdown, or edit the brief directly first.
```

**Wait here.**

---

## Phase 7 — Breakdown

### On entry

1. Write `breakdown_in_progress` to `status.md` before any other work:
```yaml
stage: breakdown_in_progress
next_action: complete breakdown
transitions:
  - stage: breakdown_in_progress
    timestamp: {ISO 8601}
    note: breakdown started
```

2. Read the brief's breakdown table (Section — Breakdown). If zero rows: stop and ask.

3. Resume detection: count existing `.md` files in `.orchestration/projects/{id}/04-tasks/slice-{NN}/`. If the count does not match the breakdown table row count: delete all existing task files and regenerate all (idempotent overwrite).

### Task file creation

Create `.orchestration/projects/{id}/04-tasks/slice-{NN}/{NN}-{slug}.md` for each breakdown table row. Each task file:

```yaml
---
spec: .orchestration/projects/{id}/03-briefs/{NN}-{slug}.md
slice: {NN}
step: {step number}
title: {title}
status: todo
depends_on: [{previous task filename}]  # sequential by default; [] if first task or explicitly independent
agent_type: {derived from work description}
assigned_at: null
completed_at: null
---
```

Derive `agent_type` from the work description:
- `architect` — modifying command/prompt/markdown files
- `server-dev` — Go or other backend code
- `client-dev` — frontend code
- `quality` — tests, QA, verification

`depends_on` is sequential by default (each task depends on the previous). Use `[]` only if the brief explicitly marks the step as independent.

### After creating all task files

1. Update slice file frontmatter: `status: tasks_ready`
2. Update `status.md`:
```yaml
stage: tasks_ready
next_action: run /implement to start implementation
transitions:
  - stage: tasks_ready
    timestamp: {ISO 8601}
    note: {N} tasks created for slice {NN}
```

3. Commit and push:
   - `git add .orchestration/projects/{id}/04-tasks/ .orchestration/projects/{id}/02-slices/{NN}-*.md .orchestration/projects/{id}/status.md`
   - `git commit -m "Tasks ready — {project_id} slice {NN} ({N} tasks)"`
   - `git push` — if push fails, report clearly and continue. Status is committed locally.

4. Surface the agent team:

   Read all task files just created. Collect unique `agent_type` values and count tasks per type. Output:

   ```
   Proposed agent team for slice {NN}:
     - {agent_type} ({N} tasks)          ← list each type
     [Single agent] or [Team of N]

   Confirm or adjust before /implement:
   ```

   Wait for confirmation. User may add or remove agent types. Do not proceed to the output below until confirmed.

5. Output:

```
Tasks ready — slice {NN}: {title}

{N} tasks created in .orchestration/projects/{id}/04-tasks/slice-{NN}/

Run /implement to start implementation.
```

---

## Behavior rules

- Never write the design doc before all Phase 2 questions are resolved.
- Never ask more than 5 questions per turn.
- Always update the context log every turn during Phase 2.
- If Bdon gives a vague or short answer, ask a focused follow-up rather than accepting it.
- If something contradicts an earlier answer, surface the conflict and resolve it before moving on.
- Status update is always the last step of any stage. Never advance status before all artifacts for that stage are written.
- Never commit or push mid-stage — only at gates, on approval. "On approval" means when the human re-runs the command after reviewing, not when the gate is first reached.
- The execution pipeline (implement → QA → signoff_review) has its own commit cadence: nothing is committed until the human runs /review and approves. All implementation changes, task status updates, QA reports, and slice status changes stay uncommitted so the human can see the full diff at review time.
- After any change to the design doc, do a full cohesion pass before saving: check every section for contradictions with the change. A new decision at the bottom does not automatically update the sections above.
- Resuming: always re-read files from disk. Never use cached content from earlier in the session.
