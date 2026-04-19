---
version: 2.4.0
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

# Plan-project — Full planning pipeline

Your job is to take a project from idea to tasks_ready. You own the full planning pipeline: design interview → slicing → spec → breakdown. You resume from wherever the project last stopped.

---

## Phase 0 — Detect state and route

### Step 1 — Identify the project

If a project ID or path was passed as argument, use it.

If no argument:
1. Glob `.orchestration/projects/*/` directories, excluding any path under `done/`.
2. For each directory, read slice files at `.orchestration/projects/{id}/02-slices/*.md`. Collect `status:` frontmatter for each.
3. A project has actionable work for plan-project if it has at least one slice in `draft`, `reviewed`, or `specced` state, or has no slice files yet, or has no design doc yet.
4. If one match: use it.
5. If multiple matches: list them and ask which to resume, or offer to start a new one.
6. If no matches: start a new project (proceed to Step 3).

### Step 2 — Wrong-command routing

Read all slice files for the selected project. If any condition below matches, output the error and stop.

| Condition | Error message |
|-----------|---------------|
| Any slice at `implementing` or `qa_in_progress` | "Slice {NN} is currently implementing — run `/implement` to resume." |
| Any slice at `signoff_review` | "Slice {NN} is awaiting signoff — run `/review` to approve or provide feedback." |
| No slice is in `draft`, `reviewed`, or `specced` — all slices are `tasks_ready` or beyond | "All slices are queued or complete — run `/implement` to start implementation." |

### Step 3 — Route by current state

Derive state from artifacts on disk. Check conditions in order — stop at the first match.

| Condition | Action |
|-----------|--------|
| No project directory | Create project (Step 4), run interview (Phase 1) |
| Directory exists, no `01-design/design-01.md` | Inform user interview didn't complete, run interview (Phase 1) |
| Design doc exists, no `02-slices/*.md` | Run slicing (Phase 5) |
| Scan slices 01, 02, … in order: first slice that is `reviewed` and eligible for spec (N=1, or slice N-1 is `specced` or beyond) | Run spec (Phase 6) for that slice |
| Scan slices in order: first slice that is `specced` and eligible for breakdown (N=1, or slice N-1 is `tasks_ready` or beyond) | Run breakdown (Phase 7) for that slice |
| Next actionable slice is `draft` | Prompt user to review it (see below). Stop. |

Draft prompt:
```
Slice {NN} — {title} — hasn't been reviewed yet.

Review the slice file at .orchestration/projects/{id}/02-slices/{NN}-{slug}.md.
Edit it directly if anything needs changing, then set status: reviewed.
When ready, run /plan-project to continue.
```

**Ordering constraint:** before advancing slice N to any state, slice N-1 must already be at that state or beyond. To spec slice N, slice N-1 must be at `specced` or beyond. To break down slice N, slice N-1 must be at `tasks_ready` or beyond. Slice 01 has no prior — no constraint applies.

If a slice would be eligible but the ordering constraint blocks it, report:
```
Slice {N-1} must reach {required_state} before slice {N} can advance. Run /plan-project to advance slice {N-1} first.
```

### Step 4 — Create new project

1. Get github username: `git config user.name`, fall back to prefix of `git config user.email`.
2. Derive slug from the project name: lowercase, kebab-case, max 5 words, strip stop words (the, a, an, for, of, in, to). The project ID format is `{username}-{NNNNN}-{slug}` (e.g. `bcokert-00003-claire-full-system`).
3. Scan `.orchestration/projects/` for folders matching `{username}-*`, find the highest sequence number, add 1, zero-pad to 5 digits. If folder already exists at derived path, increment and retry.
4. Create `.orchestration/projects/{id}/`. Create `.orchestration/projects/` if it doesn't exist.
5. Load project context before starting the interview:
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

> model: opus · effort: max

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

## Agent decisions
[Decisions made implicitly by the agent based on context — not explicitly discussed with the human. Listed for review to catch unexamined assumptions. One entry per decision.

Format: **Decision made.** Context: why this call seemed obvious. Alternative: what else could have been chosen.]
```

Write to `.orchestration/projects/{id}/01-design/design-01.md` (or `design-{NN}.md` for run N on a feedback_pending project). Create `01-design/` if it doesn't exist.

---

## Phase 4 — Design review gate

After writing the design doc, show the review gate:

```
Design interview complete — {project_id}

Saved: .orchestration/projects/{id}/01-design/design-01.md

Highest-leverage review point. Corrections here cost nothing.
After slicing, corrections require updating slice files.
After implementation, corrections cost the most.

Review the design doc. Edit it directly if anything needs changing.
When ready, run /plan-project to continue to slicing.
※ design_review · design interview complete → review doc and re-run /plan-project 📄
```

**Wait here.** Do not proceed to slicing until Bdon says to continue.

---

## Phase 5 — Slicing

### On entry

Commit any pending changes to the design doc before slicing:
- `git add .orchestration/projects/{id}/01-design/design-{NN}.md`
- `git commit -m "Design approved — {project_id}"` — only if files have changes; skip if clean
- `git push`

**Crash resume:** check `.orchestration/projects/{id}/02-slices/` for existing files. If any exist but slicing wasn't completed (some slices missing or all are `draft` with no slice gate previously shown): delete them all, log "previous slicing incomplete — regenerating", then proceed.

Always re-read `01-design/design-{NN}.md` from disk before slicing. Never use cached content.

### Slicing

Read and follow `.orchestration/support/slice.md` in full.

Pass `design-{NN}.md` as input. Produce individual slice files at `.orchestration/projects/{id}/02-slices/{NN}-{slug}.md`. Each slice: Goal + Happy path + Edge cases, 30–50 lines, hard cap 100.

### After all slice files written

Show the slicing gate:

```
Slicing complete — {project_id}

{N} slice files in .orchestration/projects/{id}/02-slices/

Slice 01 is fully detailed. Slices 02+ are intentionally rough — flesh
them out when they become next.

Every slice requires human review before it can be specced.
Review slice 01, edit directly if needed, then set status: reviewed.
When ready, run /plan-project to continue to spec.
※ Slice 01 · slicing_review · slicing complete → review slices and re-run /plan-project 📄
```

**Wait here.**

---

## Phase 6 — Spec

### On entry

Commit any pending changes to slice files before speccing:
- `git add .orchestration/projects/{id}/02-slices/`
- `git commit -m "Slices approved — {project_id}"` — only if files have changes; skip if clean
- `git push`

**Crash resume:** if a brief already exists for the target slice but its slice file is still `reviewed` (not `specced`): skip writing the brief and show the spec gate. If no brief exists: run spec from the beginning.

### Slice selection

The target slice is already determined by Phase 0 Step 3 routing. Use the slice number passed from routing.

### Writing the brief

Read and follow `.orchestration/support/spec.md` in full.

Write the delegation brief to `.orchestration/projects/{id}/03-briefs/{NN}-{slug}.md`.

### After writing

1. Update slice file frontmatter: `status: specced` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}`

2. Show the spec gate (light review):

```
Spec complete — slice {NN}: {title}

Saved: .orchestration/projects/{id}/03-briefs/{NN}-{slug}.md

Light review — check:
- Intent gives enough context for an agent with no prior knowledge
- Observable outcomes cover happy path and key edge cases
- Constraints are specific enough to enforce
- Breakdown maps cleanly to the slice

Run /plan-project to continue to breakdown, or edit the brief directly first.
※ Slice {NN} · spec_review · spec complete → review brief and re-run /plan-project 📄
```

**Wait here.**

---

## Phase 7 — Breakdown

### On entry

Commit any pending changes to the brief and slice file before running breakdown:
- `git add .orchestration/projects/{id}/03-briefs/{NN}-*.md .orchestration/projects/{id}/02-slices/{NN}-*.md`
- `git commit -m "Spec approved — {project_id} slice {NN}"` — only if files have changes; skip if clean
- `git push`

1. Read the brief's breakdown table (Section — Breakdown). If zero rows: stop and ask.

2. Resume detection: count existing `.md` files in `.orchestration/projects/{id}/04-tasks/slice-{NN}/`. If the count does not match the breakdown table row count: delete all existing task files and regenerate all (idempotent overwrite).

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
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null  # set by QA: pass | fixed (passed after QA fixed it) | manual
---
```

Derive `agent_type` from the work description:
- `architect` — modifying command/prompt/markdown files
- `server-dev` — Go or other backend code
- `client-dev` — frontend code
- `quality` — tests, QA, verification

`depends_on` is sequential by default (each task depends on the previous). Use `[]` only if the brief explicitly marks the step as independent.

### After creating all task files

1. Update slice file frontmatter: `status: tasks_ready` and `status_updated_at: {current ISO 8601 timestamp with timezone offset}`

2. Commit and push:
   - `git add .orchestration/projects/{id}/04-tasks/ .orchestration/projects/{id}/02-slices/{NN}-*.md`
   - `git commit -m "Tasks ready — {project_id} slice {NN} ({N} tasks)"`
   - `git push` — if push fails, report clearly and continue. Status is committed locally.

3. Surface the agent team:

   Read all task files just created. Collect unique `agent_type` values and count tasks per type. Output:

   ```
   Proposed agent team for slice {NN}:
     - {agent_type} ({N} tasks)          ← list each type
     [Single agent] or [Team of N]

   Confirm or adjust before /implement:
   ```

   Wait for confirmation. User may add or remove agent types. Do not proceed to the output below until confirmed.

4. Output:

```
Tasks ready — slice {NN}: {title}

{N} tasks created in .orchestration/projects/{id}/04-tasks/slice-{NN}/

Run /implement to start implementation.
※ Slice {NN} · tasks_ready · breakdown complete → run /implement ▶️
```

---

## Behavior rules

- Never write the design doc before all Phase 2 questions are resolved.
- Never ask more than 5 questions per turn.
- Always update the context log every turn during Phase 2.
- If Bdon gives a vague or short answer, ask a focused follow-up rather than accepting it.
- If something contradicts an earlier answer, surface the conflict and resolve it before moving on.
- Never commit or push mid-phase — only at phase entry (committing the previous phase's artifacts) and after breakdown task creation. Gates stop and wait for the human; commits happen when the human re-runs.
- The execution pipeline (implement → QA → signoff_review) has its own commit cadence: nothing is committed until the human runs /review and approves. All implementation changes, task status updates, QA reports, and slice status changes stay uncommitted until then.
- After any change to the design doc — whether during writing or during design_review — do a full cohesion pass before saving: check every section for contradictions with the change. A new decision at the bottom does not automatically update the sections above. This applies to edits made in response to human feedback during review, not just initial writing.
- **Root context conflicts require a prompt, not a note.** If a design decision contradicts or supersedes something in the project's root context (`.root-context/*`) or `CLAUDE.md`, do not leave a note in the design doc. Ask: "This decision conflicts with [file] — [what it says]. Update [root context|CLAUDE.md] to reflect the new direction?" If yes: update the file, note what changed at the bottom of the design doc under "Root context updates made". If no: record the conflict in the design doc as an open question. Never update root context silently. Always ask first — root context varies by project and may be shared or sensitive.
- Resuming: always re-read files from disk. Never use cached content from earlier in the session.
