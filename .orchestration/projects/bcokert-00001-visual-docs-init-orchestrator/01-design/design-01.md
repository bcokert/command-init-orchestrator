---
type: design
date: 2026-04-13
feature: visual-docs-init-orchestrator
project_id: bcokert-00001-visual-docs-init-orchestrator
status: ready
---

# Visual docs — init-orchestrator

## Intent

The current README describes what the commands do. It doesn't motivate them, doesn't show how they connect, and doesn't give a first-time reader a mental model of what using the system actually looks like. Someone who lands on the repo should be able to understand why it exists, see the flow, and want to try it — all before reading a single command file.

This project rewrites the README as a proper introduction: value props up front, mechanics introduced gradually, with embedded d2 diagrams that make the flow and complexity concrete. The d2 source lives in `docs/diagrams/`, rendered SVGs embed in the README. Scope is ~3-4 diagrams and a full README rewrite. Additional diagrams can be added via feedback slice.

## Current state

- README.md is short, functional, descriptive. It tells you what things do in the order they were built. No diagrams, no motivation, no mental model.
- `defaults/README.md` is an older version of the system docs — diverged, references old command names (`/pipeline`, `/migrate`, `/breakdown`). Not a good reference for this project.
- `docs/` exists but only contains `education-audit.md`.
- No d2 files exist anywhere in the repo.

## Desired end state

- README.md is a complete rewrite. Structure: why this exists → core concepts (slices, worktrees, human gates) → quick start → usage flowchart → complex cases → customization note.
- 3-4 d2 diagrams exist as `.d2` source in `docs/diagrams/` and as rendered SVGs embedded in the README.
- A developer who has never heard of this system can read the README, understand the value, and follow the quick start in one sitting.
- defaults/README.md is left alone — it documents an earlier version and is out of scope.

## Value props to lead with (in order)

1. **Single source of truth.** Every project artifact — design doc, slices, briefs, tasks, QA reports — lives in `.orchestration/projects/{id}/`. One folder. Nothing scattered.
2. **Docs stay in sync.** Design decisions flow through structured stages with committed artifacts at each gate. When a later stage reshapes something, the upstream doc gets updated before moving on. The system makes it harder to let docs go stale than to keep them current.
3. **Slicing discipline built in.** The system encourages (and enforces) thin vertical slices — something observable and testable on its own. Small slices mean you validate assumptions early and fail cheap, not at the end.
4. **Status that reflects reality.** `status.md` is the ground truth. `/status` gives you a table of every active project, its stage, its worktree, and how long it's been there. Replaces JIRA-level tracking without needing JIRA.
5. **Work isolation by default.** Each `/implement` creates a git worktree — isolated branch, isolated working directory. Multiple projects can run concurrently. Main stays clean for planning.
6. **Human gates where they matter.** Gates exist after design, slicing, spec, and QA. Not after every command. The system trusts mechanical steps and gates judgment calls.
7. **QA is a first-class citizen.** QA runs automatically at the end of every implementation slice. You can customize what it checks. Nothing reaches signoff without it.
8. **Project scaffold, not a server.** `/init-orchestrator` installs a scaffold you own — command files in `.claude/commands/`, folder structure in `.orchestration/`. Tweak the commands, add root context, modify QA checks. No singleton to update, no breaking API.

## Diagrams planned

### 1. Happy path flowchart
End-to-end flow for a single project: `/design` (interview → slicing → spec → breakdown) → `/implement` (worktree → tasks → QA) → `/review` (approve → merge → archive). Shows human gates as decision points. d2 flowchart style.

### 2. Project lifecycle state machine
All possible `stage` values as states. Transitions labelled with the command that drives them. Human gates visually distinct. Shows `feedback_pending` looping back to design. State machine style.

### 3. Complex cases flowchart
Covers: concurrent projects (two projects in parallel on separate branches), multi-slice sequence (slice 01 done → review → slice 02 specced → implement), feedback loop (review → feedback → new slice), and pause/resume (implement interrupted → resume picks up where it left off). Flowchart style, possibly a split-lane diagram for concurrent case.

### 4. Folder structure reference
Static tree diagram showing `.orchestration/projects/{id}/` layout with all artifact types labeled. Not a flow — just a reference visual to anchor the concepts. Could be d2 or just a clean code block depending on what renders better.

## Patterns to follow

- README voice: matches Bdonizer register — direct, dry, short declarative payoffs, no inflation. Sentence case headings.
- Introduce from value → mechanics, not the other way. Reader earns the diagram by understanding why it matters first.
- Diagrams supplement prose, don't duplicate it. Caption, don't caption-and-explain.
- d2 diagrams use the `vars` block for consistent styling. Flowcharts use `direction: right` or `direction: down` depending on which reads better.
- Rendered SVGs go in `docs/diagrams/*.svg`. Source `.d2` files go in `docs/diagrams/*.d2`.
- README embeds via `![alt](docs/diagrams/name.svg)`.

## Key edge cases

- d2 is an external tool — rendered SVGs must be committed alongside source so the README works without a build step. The implementation task should include rendering the SVGs and committing both.
- `defaults/README.md` is diverged from the current system. Don't update it — it documents a previous version and touching it is out of scope here.
- The README rewrite should not reference `defaults/README.md` anywhere.
- SVG embed sizing: GitHub renders inline SVGs at full width. Wide diagrams may need a max-width wrapper or a note to view in full.
- The folder structure diagram should reflect the current layout, not the old one from `defaults/README.md`.

## Resolved design decisions

**Embed SVGs in README, source in docs/diagrams/**
Why: SVGs render natively in GitHub, no external link required, no CDN dependency. Source stays in repo so diagrams can be updated.
Rejected: linking to an external d2 playground (fragile, not self-contained).

**Full README rewrite, not an append**
Why: the current structure introduces commands before motivation. Reordering requires a rewrite. Appending would leave the weak intro intact.
Rejected: adding a "Visual overview" section at the bottom and leaving the rest alone. The prose order matters.

**~3-4 diagrams in first slice, more via feedback**
Why: first slice should ship something coherent and complete. Diagram sprawl before the prose is solid is backwards.
Rejected: planning all diagrams upfront and implementing in one shot. Too much to QA in one pass.

**defaults/README.md left untouched**
Why: it documents an earlier version of the system. Updating it to match the current system is a separate project.
Rejected: updating it as part of this project. Scope creep, different audience.
