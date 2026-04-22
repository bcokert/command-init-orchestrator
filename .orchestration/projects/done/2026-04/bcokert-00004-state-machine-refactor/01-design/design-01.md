---
type: design
date: 2026-04-21
feature: state-machine-refactor
project_id: bcokert-00004-state-machine-refactor
status: approved
---

# State machine refactor — Design

## Intent

The orchestrator's state machine has several systematic bugs that cause incorrect behavior regardless of how carefully individual commands are written. Commits happen at the start of the next phase rather than at approval — so a human approves in conversation, then the commit lands later, disconnected from the moment of approval. Humans must manually edit slice frontmatter to set `status: reviewed`, which leaks orchestration internals to the operator and breaks the invariant that the agent owns all state transitions. There is no iteration loop during slicing, so feedback on slices requires manual file editing and re-running. QA sends failures directly to signoff without auto-retry. And there is no record of what questions were asked, what decisions were made, or why the system is in its current state.

This refactor rewrites the four main command files and two support files in `defaults/commands/` to match the explicit state machine defined in `.root-context/state-diagram.md`. That document was written and validated through deep design review in this project's session. The goal is a system where the state machine on paper and the code that runs are the same machine.

## Current state

- `plan-project` commits at the **start** of each phase, committing the previous phase's artifacts. This decouples the commit from the approval — the human approves in conversation, then the next run commits, making it unclear what was approved and when.
- `git push` runs automatically after every commit. The operator has no control over when the remote is updated.
- Human must manually edit `status: reviewed` in slice file frontmatter to advance a slice to spec. The agent is supposed to own the system; requiring human frontmatter editing is a leaky abstraction.
- No iteration loop during slicing. If slices need work, the human edits files manually and re-runs. Contrast with design, which has a full interview + planIteration loop.
- A spec gate exists between spec and breakdown. The human must re-run `/plan-project` to advance from spec to breakdown, adding friction with little quality benefit (slicing gate already caught major issues).
- QA escalates to `signoff_review` immediately on failure, with limited auto-fix attempts. Agent gives up too early.
- No observability artifacts. Questions asked, decisions made, and iteration history live only in the agent's session context — lost when the session ends.
- Status values (`reviewed`, `specced`) are past-tense action names, not state names. This is a naming inconsistency with no functional impact but causes confusion when reading the state machine.
- Implementation starts immediately after breakdown. No gate for the operator to choose to batch more slices before execution.
- `Slicing.Asking` appeared in the original state machine design as a separate state but had no outgoing transitions — a ghost state. Collapsed into `Slicing.Review`.
- `/status` uses `projects/*/` as its glob pattern. The Glob tool does not match directory paths with a trailing slash — projects are silently excluded from the scan. The entire multi-project view returns nothing if no files exist directly in the project root.
- `/status` has no display mode for design-phase projects (projects with a `01-design/` doc but no `02-slices/` directory). These projects show as a blank header at best, or are skipped entirely due to the glob bug.

## Desired end state

- Agent owns all status transitions. Operator responds to conversation prompts; agent writes all frontmatter updates. Operators can still edit content files directly, but they never need to.
- Commits happen exactly when a human approves at a review gate. The uncommitted diff is always "current work in progress." Agent never pushes — operator triggers push manually.
- At the start of each `planIteration`, the agent runs `git add` on `.orchestration/` and related files. Previous iteration's changes become staged; current changes stay unstaged. VS Code diff shows only the new changes.
- Slicing has a full iteration loop identical to design's: feedback triggers planIteration, which updates the target slice and all unimplemented artifacts for cohesion. Interview questions stored in `observability/questions.md`.
- Spec and breakdown are atomic. After slice approval, spec runs, then breakdown runs immediately. No gate between them. Both are crash-resumable via slice status field (`speccing` → `breakdown` → `tasks_ready`).
- `Implementation.Asking` gate exists before execution. Agent shows "X tasks across Y slices, ready to start?" Operator can say "yes" or "let me review more slices first" — which loops back to `Slicing.Review` before returning.
- QA auto-retries indefinitely, trying different approaches. Escalates to `Signoff.Review` only when the agent explicitly cannot continue without human input. Human fix (code edit, agent fix, or new 5.1 slice) → transition back to `qa_in_progress`.
- Each project has an `observability/` directory alongside `01-design/`, `02-slices/`, etc.:
  - `questions.md` — timestamped log of all interview questions and their status
  - `iterations.md` — replay log: timestamp, state, what changed, why
  - `decisions.md` — key decisions with reasoning and rejected alternatives
- Slice status values: `draft → review → speccing → breakdown → tasks_ready → implementing → qa_in_progress → signoff_review → done`
- Design doc status field: `in_progress → review → approved`
- `/status` glob fix: scan uses `projects/*` (no trailing slash). After globbing, filter to paths that are directories (or contain known subdirectories). Exclude any path containing `/done/`.
- `/status` design-phase display: a project with a design doc but no `02-slices/` directory is in design phase. Show it with a single design-phase row instead of a blank header:
  ```
  **{id}** · {MMM D} · design: {design_status}  →  **`/plan-project`**
  ```
  Where `design_status` is the `status:` field from `design-01.md` (`in_progress`, `review`, or `approved`). If the field is absent, show `in_progress`. Design-phase projects sort by design doc `date:` field.
- `status.md` updated to reflect new values and correct bucket assignments.

## Patterns to follow

- Source of truth is `.root-context/state-diagram.md`. If this design doc conflicts with that document, the state diagram wins.
- `defaults/commands/` is the source; local `.claude/commands/` and `.orchestration/support/` are installed copies. Update source only. Operator runs `/init-orchestrator` after implementation to install locally.
- Version bump required on every changed file in `defaults/`. Bump patch for fixes, minor for behavior changes. Most changes here are minor or major.
- Slices should leave the system in a working state. Each slice is a commit that someone could install and use. Don't break the system mid-refactor.
- QA for this project is manual review of command file behavior — these are prose instructions, not executable code. Done signals are: the command's behavior description matches the state machine; no contradictions between sections.
- Do not touch: `defaults/commands/commit.md`, `defaults/commands/learn.md`, `defaults/commands/migrate.md`, agent files — unrelated to the state machine.
- Do not touch: local `.claude/commands/` or `.orchestration/support/` during implementation. Those get updated via install after the fact.

## Key edge cases

- **Crash during planIteration staging** (`git add` fails): surface to operator, wait for resolution, do not advance state.
- **Crash mid-spec** (slice status is `speccing` but spec file missing): re-run spec idempotently, then continue to breakdown.
- **Crash mid-breakdown** (slice status is `breakdown`, partial task files): delete all task files and regenerate from breakdown table.
- **QA stuck loop**: no fixed retry cap. Agent must explicitly state "I cannot fix this without human input" to escalate. Vague or incomplete fixes do not count as genuine attempts.
- **Human provides fix after QA stuck**: Signoff.Review → Implementation.QA transition must exist and set slice status to `qa_in_progress`.
- **Signoff feedback** creates dot-notation slices (e.g., 5.1). These are fresh slices starting at `draft`, not pre-approved. They go through the full Slicing.Review → Speccing → Breakdown flow.
- **Code files appearing unstaged during planIteration**: surface to operator — "These code files changed during planning: [list]. Stage them too?" — wait for confirmation before staging.
- **Existing projects with old status values** (`reviewed`, `specced` from the old naming): commands should treat `reviewed` as equivalent to `review` when routing. This is a soft migration, not a hard cutover.
- **Design doc missing `status:` field** (old projects): treat as `in_progress`. Do not fail.
- **Slicing.Review asking interview questions**: if the human's answer doesn't contain feedback or approval, it should trigger planIteration (questions have design implications) — not accidentally advance to Speccing.
- **Implementation.Asking with "review more slices"**: loops back to Slicing.Review for the next pending slice. After that slice reaches `tasks_ready`, returns to Implementation.Asking, not Implementation.Running.
- **Multiple slices in `tasks_ready`**: Implementation.Asking shows total task count across all ready slices. Implementation.Running runs them in slice order, task order within slice.
- **`git push` failing**: out of scope — operator handles this. Agent reports the push prompt was shown; push result is the operator's concern.

## Resolved design decisions

**Commit at approval, not at phase entry.** Previously plan-project committed the previous phase's artifacts at the start of each new phase. Commits now happen when the operator approves at a review gate and re-runs the command. This makes the commit the signature of the approval, not a side effect of the next run. Rejected: keeping current behavior (would require documenting the counter-intuitive timing).

**No automatic push.** Push has external effects (updates the remote, triggers CI). Operator controls when this happens. Rejected: keeping automatic push (operators couldn't control remote state).

**planIteration stages previous changes.** `git add` at the start of each iteration moves the previous iteration's artifacts into the staging area, so `git diff` (unstaged) shows only the current iteration's new changes. This makes VS Code's diff view usable during active iteration. Rejected: leaving all changes unstaged (diff becomes unreadable with accumulated changes).

**Spec + breakdown atomic.** The spec gate added a required re-run between spec and breakdown with minimal quality benefit — slicing review already caught the major design issues, and the spec is auto-generated from the slice. The atomic flow is smoother without meaningful quality loss. Rejected: keeping spec gate (friction without benefit at this stage).

**Agent owns all status transitions.** The operator should not need to know frontmatter exists. The agent asks in conversation; the agent writes the file. Operators may still edit content files directly, but status fields are agent territory. Rejected: keeping manual `status: reviewed` (inconsistent with the agent-owns-everything principle).

**QA auto-retries indefinitely.** A fixed retry cap is arbitrary and doesn't match the goal: the agent should exhaust its own ability to fix something before escalating. The escalation signal is the agent explicitly stating it's stuck, not a counter reaching zero. Rejected: fixed 3-retry cap (would cause unnecessary escalations on hard-but-fixable bugs).

**Implementation.Asking gate.** Gives the operator a natural decision point before execution begins: confirm agent team and decide whether to batch more slices. Low-friction, high-value gate. Rejected: starting implementation immediately after breakdown (no opportunity to batch).

**Observability in `observability/` per project.** Currently impossible to understand why decisions were made or debug what went wrong. Three files cover the main gaps: question log, iteration replay, decision log. Richer replay (full state reconstruction) deferred. Rejected: keeping everything in agent context (invisible, lost on session end).

**Rename `reviewed` → `review`, `specced` stays.** The status value `reviewed` is past-tense, ambiguous — it means "the slice was reviewed" not "the slice is in review state." Renamed to `review` to match the state machine naming convention (state names, not action names). `specced` is kept as-is — it's a recognizable term meaning "spec has been written" and there's no cleaner alternative. Rejected: keeping `reviewed` (naming inconsistency with the state machine).

## Agent decisions

**`slice.md` needs updating.** The instruction "the human sets `status: reviewed` when ready to spec" must be removed since the agent now owns that transition. Context: this line was accurate under the old system. Alternative: leave it and let plan-project override with its own instructions — fragile, would cause confusion.

**`spec.md` does not need changes.** The spec writing logic is unchanged; only plan-project's behavior changes (no gate after spec). The spec.md file is instructions for how to write a spec, not when to show gates. Alternative: update spec.md to acknowledge it's called atomically with breakdown — adds context but isn't necessary for correctness.

**`status.md` gets a full rewrite of its state tables.** The existing tables reference `reviewed` and `specced` and are missing `speccing`, `breakdown`, `review`. Concrete changes:

Bucket table — replace current rows:

| Emoji | Slice states |
|-------|-------------|
| ✅ | `done` |
| 🤖 | `implementing`, `qa_in_progress` |
| 👤 | `draft`, `review`, `signoff_review` |
| ⏳ | `speccing`, `breakdown`, `tasks_ready` |

`reviewed` treated as alias for `review` for old-project compatibility (see soft migration decision above).

State abbreviation table — replace in full:

| Full state | Abbrev | Emoji |
|------------|--------|-------|
| `draft` | `draft` | 👤 |
| `review` | `review` | 👤 |
| `speccing` | `speccing` | *(none)* |
| `breakdown` | `bkdn` | *(none)* |
| `tasks_ready` | `ready` | *(none)* |
| `implementing` | `impl` | 🤖 |
| `qa_in_progress` | `qa` | 🤖 |
| `signoff_review` | `signoff` | 👤 |

Command routing table — replace in full:

| State | Command |
|-------|---------|
| `draft` | `/plan-project` |
| `review` | `/plan-project` |
| `speccing` | `/plan-project` |
| `breakdown` | `/plan-project` |
| `tasks_ready` | `/implement` |
| `implementing` | `/implement` |
| `qa_in_progress` | `/implement` |
| `signoff_review` | `/review` |

`prev→curr` derivation follows the new state sequence: `draft → review → speccing → breakdown → tasks_ready → implementing → qa_in_progress → signoff_review → done`. Context: `speccing` and `breakdown` are fast-moving transient states but still need a row in case the agent crashes mid-run. Alternative: map `speccing`/`breakdown` to 🤖 — but breakdown is deterministic, not agentic, so ⏳ is more accurate.

**No migration for old projects.** Existing projects with `reviewed` status will encounter the new code. Commands treat old values gracefully (routing logic checks both `review` and `reviewed`). No explicit migration step. Context: active projects are rare, transition is quick. Alternative: migration slice — overhead not worth it.
