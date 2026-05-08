---
version: 2.12.0
description: |
  Full planning pipeline: design interview → slicing → spec → breakdown → tasks_ready. Resumes from wherever the project left off. Commits at each user approval gate. Ends with tasks ready for /implement.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Plan-project — full planning pipeline

Take a project from idea to `tasks_ready`. Owns: design interview → slicing → spec → breakdown. Resume from wherever the project last stopped.

State, schemas, principles, vocabulary, and crash recovery rules live in `.root-context/state-diagram.md`. Helpers used: `support/next-actions.md` (scope reader), `support/status-write.md` (frontmatter helper), `support/bdonize.md` (voice).

---

## Phase 0 — Resolve scope

Run `support/next-actions.md`. Filter to projects with at least one slice in `{draft, review, speccing, breakdown}`, OR no slice files yet, OR no design doc yet. With a project ID arg: restrict to that project.

If no match: proceed to Step 4 (create new project).
If multiple match without an arg: list them, ask which to resume or to start a new one.

Wrong-command shortcuts (stop on first match):

| Slice state in selected project | Action |
|---|---|
| `implementing` / `qa_in_progress` | "Slice {NN} is currently implementing — run `/implement` to resume." Stop. |
| `signoff_review` | "Slice {NN} is awaiting signoff — run `/review` to approve or provide feedback." Stop. |

**Route by state** (first match wins):

| Condition | Action |
|---|---|
| No project directory | Step 4 → Phase 1 |
| Directory exists, no `01-design/design-{NN}.md` | Phase 1 (interview didn't complete) |
| Design doc exists, no `02-slices/*.md` | Phase 5 (slicing) |
| First slice in `review` or `speccing` and eligible (slice 01, or slice N-1 ≥ `tasks_ready`) | Phase 6 (spec) — Phase 7 follows |
| First slice in `breakdown` (crash resume) | Phase 7 |
| First slice has `follow_up_of:` set and is `draft` | Surface as a follow-up: "Slice {NN.N} is feedback from prior signoff. Review at {path} and re-run /plan-project." Stop. |
| Next actionable slice is `draft` (fresh) | "Slice {NN} hasn't been reviewed yet. Edit at {path}; re-run /plan-project when ready." Stop. |

**Ordering constraint:** to spec slice N, slice N-1 must be at `tasks_ready` or beyond. Slice 01 has no prior. If blocked: "Slice {N-1} must reach tasks_ready before slice {N} can advance."

### Step 4 — Create new project

1. `git config user.name` (fallback: prefix of `git config user.email`).
2. Slug from project name: lowercase, kebab-case, max 5 words, strip stop words (the, a, an, for, of, in, to). Format: `{username}-{NNNNN}-{slug}`.
3. Highest existing sequence + 1, zero-padded to 5 digits. Increment if collision.
4. Create `.orchestration/projects/{id}/` and `observability/` files (`questions.md`, `iterations.md`, `decisions.md`) with their template headers. Non-blocking on write failures.
5. Load context: `CLAUDE.md`, `.root-context/architecture.md`, `.root-context/CONSTRAINTS.md`, `.root-context/DECISIONS.md` if present. Skip questions the docs already answer.

Escalation before Step 4:
- Not a git repo → stop, ask the user to init git first.
- `.orchestration/` has unexpected structure → stop, ask before proceeding.

---

## Phase 1 — Understand the request

Restate in one sentence what the user wants. Ask to confirm or correct. If nothing has been described yet: "What are we designing?"

---

## Phase 2 — Interview

> model: opus · effort: max

Surface everything the user knows but hasn't said. **No filter on questions** — only stage where every question is on the table.

Ask **3–5 questions per turn**. Wait for answers.

Append each question to `observability/questions.md` with status `open`. Update to `answered` and add the answer when received. Non-blocking.

Areas: intent + motivation, current state, desired end state, patterns + conventions, design decisions, boundaries.

**Context log every turn:**

```
> **Context so far:**
> - resolved: [key fact]
> - open: [unanswered question]
```

Move to Phase 3 only when no `open` items remain. "I think I have everything. Ready to write the design doc?"

---

## planIteration — staging step

At the start of each iteration pass (any re-run during interview, design iteration, or slicing iteration):

0. Recreate any missing files in `observability/` (template headers). Non-blocking.
1. `git status`. Auto-stage `.orchestration/`, `.root-context/`, `CLAUDE.md`, plus any unstaged code files. Surface a one-line summary: "Staging: N orchestration, M source." User can abort if the summary surprises them.
2. If `git add` fails: surface to the user, wait. Do not advance state.
3. Append one entry to `observability/iterations.md`: `## YYYY-MM-DD HH:MM — [state] What changed. Why.` Non-blocking.
4. **When invoked during slicing**: after updating affected slice files, run a forward cohesion pass over remaining slices not at `tasks_ready` or beyond.

---

## Phase 3 — Write the design doc

Begin only when Phase 2 has no open questions. Target ~200 lines; don't compress unnaturally.

Apply voice patterns inline per `support/bdonize.md` before saving.

### Format

```markdown
---
type: design
date: YYYY-MM-DD
feature: [short kebab-case]
project_id: {id}
status: in_progress
---

# [Name] — Design

## Intent
[1-2 paragraphs. Full context for someone with no prior knowledge.]

## Current state
[Bullets. Pain points, constraints, what exists today.]

## Desired end state
[Bullets. Observable facts when this is done.]

## Patterns to follow
[Bullets. What to follow, what to avoid, and why.]

## Key edge cases
[Bullets. Crashes, partial state, wrong-command errors, unrecoverable data.]

## Resolved design decisions
[Decision / Why / Rejected alternatives.]

## Agent decisions
[Decisions made implicitly by the agent. Listed for review. Decision made / Context / Alternative.]
```

Write to `.orchestration/projects/{id}/01-design/design-{NN}.md`. After writing, append each Resolved decision to `observability/decisions.md`.

---

## Phase 4 — Design review gate

Show:

```
Design interview complete — {project_id}

Saved: .orchestration/projects/{id}/01-design/design-{NN}.md

Highest-leverage review point. Corrections here cost nothing.
After slicing, corrections require updating slice files.
After implementation, corrections cost the most.

Edit the design doc directly if anything needs changing.
When ready, run /plan-project to continue to slicing.
※ design_review · design interview complete → review doc and re-run /plan-project 📄
```

`status-write.md` → set design status to `review`. **Wait.** Do not proceed until the user re-runs.

**Approval transition** (re-run with design `status: review`): run the design-approval block at the top of Phase 5. Idempotent on crash resume.

---

## Phase 5 — Slicing

### On entry — design approval

Re-read the design doc from disk.

If design `status: review` (approval transition):
- `git add .orchestration/projects/{id}/01-design/design-{NN}.md`
- `git commit -m "Design approved — {project_id}"` — skip if clean
- `status-write.md` → design `status: approved`

If design `status: approved`: skip. Proceed to slicing.

### Crash resume

If `02-slices/` has files but slicing wasn't completed (all slices `draft` AND no commit referencing `02-slices/` in git log): delete and regenerate. Otherwise resume per slice statuses.

### Slicing

Read and follow `support/slice.md` in full. Pass the design doc as input. Produce slice files at `02-slices/{NN}-{slug}.md` (or `{NN.N}-{slug}.md` for follow-ups).

### After all slice files written

Show the gate:

```
Slicing complete — {project_id}

{N} slice files in .orchestration/projects/{id}/02-slices/

Review the slices. Approve or provide feedback below.
※ Slicing.Review · slicing complete → approve or give feedback 📄
```

For every generated slice: `status-write.md` → `status: review` and add `review_context: initial` to frontmatter. **Wait.**

### Response handling

| Signal | Action |
|---|---|
| Approval (clear sign-off; possibly with subset like "approve 1, 2") | Approve listed slices (default: all). Continue. |
| Feedback on specific slices | Run planIteration on those slices; add `review_context: post_iteration`; resurface. |
| Mixed (e.g. "approve 1 and 2, feedback on 3-5") | Split: approve subset advances, feedback subset gets planIteration. Resurface only affected slices. |
| Ambiguous | Re-ask once. If still ambiguous: treat as feedback. |

**On approval (full or subset):**
1. `git add .orchestration/projects/{id}/02-slices/` then `git commit -m "Slices approved — {project_id}"` — skip if clean.
2. For approved slices: `status-write.md` → `status: speccing`.
3. Loop in slice-number order: for each approved slice, run Phase 6 → Phase 7. No inter-slice gates. Slice N+1's spec depends on slice N's task files for cohesion — sequential, no user pause.

**Crash resume in the loop:** re-read disk on entry. Find the first slice still in `review` / `speccing` / `breakdown`. Continue from there. If brief + task files both exist for a slice still at `speccing` or `breakdown`: fast-forward `status-write.md` → `tasks_ready` and skip to next.

---

## Phase 6 — Spec

`status-write.md` → `status: speccing` (idempotent).

**Crash resume:** brief exists → skip write, proceed to Phase 7. Otherwise write from scratch.

Read and follow `support/spec.md`. Write the brief to `03-briefs/{NN}-{slug}.md`.

Proceed directly to Phase 7. No gate.

---

## Phase 7 — Breakdown

`status-write.md` → `status: breakdown`.

**Crash resume:** if task files exist, delete all in `04-tasks/slice-{NN}/` and regenerate.

1. Read the brief's Breakdown table. Zero rows → stop and ask.

2. **Diagram-first trigger:** if the brief's frontmatter has `state_machine: true` OR any breakdown row's deliverable mentions state-machine work, prepend a step `0` to the breakdown: "Confirm `state-diagram.md` reflects this slice's behavior; update if drift, record confirmation if accurate." This task is `agent_type: architect`.

3. Delete any existing `.md` files in `04-tasks/slice-{NN}/` and create one task file per breakdown row. See `state-diagram.md` Frontmatter schemas for the task schema.

`agent_type` derivation:
- `architect` — modifying command/prompt/markdown files
- `server-dev` — Go or other backend code
- `client-dev` — frontend code
- `quality` — tests, QA, verification

`depends_on` is sequential by default. Use `[]` only if the brief explicitly marks the step independent.

### After creating task files

1. `status-write.md` → `status: tasks_ready`.
2. `git add .orchestration/projects/{id}/04-tasks/ .orchestration/projects/{id}/02-slices/{NN}-*.md`
3. `git commit -m "Tasks ready — {project_id} slice {NN} ({N} tasks)"`
4. Output:
   ```
   Tasks ready — slice {NN}: {title}
   {N} tasks in 04-tasks/slice-{NN}/
   Run /implement to start implementation.
   ※ Slice {NN} · tasks_ready · breakdown complete → run /implement ▶️
   ```

No team-confirmation gate. The team gate fires once in `/implement` Phase 1, batched across all queued slices.

---

## Behavior rules (plan-project deltas)

Shared rules — commits only after user approval, re-read from disk on resume, skip-if-clean idiom — live in `.root-context/state-diagram.md` Principles and Vocabulary.

- Never write the design doc before all Phase 2 questions are resolved.
- Never ask more than 5 questions per turn.
- If the user gives a vague answer, ask a focused follow-up rather than accepting it.
- Surface contradictions with earlier answers before moving on.
- After any change to the design doc — during writing or during design_review — do a full cohesion pass before saving. New decisions don't automatically update sections above.
- **Root context conflicts require a prompt, not a note.** If a design decision contradicts something in `.root-context/*` or `CLAUDE.md`, ask: "This decision conflicts with [file] — [what it says]. Update [root context|CLAUDE.md] to reflect the new direction?" If yes: update the file, note what changed at the bottom of the design doc under "Root context updates made". If no: record as an open question. Never update root context silently.
