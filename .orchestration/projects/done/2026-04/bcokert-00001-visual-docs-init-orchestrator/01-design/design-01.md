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

This project rewrites the README as a proper introduction: value props up front, mechanics introduced gradually, with embedded d2 diagrams that make the flow and complexity concrete. The d2 source lives in `docs/diagrams/`, rendered SVGs embed in the README. Scope is 7 diagrams, a full README rewrite, a rewritten `defaults/README.md`, and a `CLAUDE.md`. Additional diagrams can be added via feedback slice.

## Current state

- README.md is short, functional, descriptive. It tells you what things do in the order they were built. No diagrams, no motivation, no mental model.
- `defaults/README.md` is an older version of the system docs — diverged, references old command names (`/pipeline`, `/migrate`, `/breakdown`). Gets copied into `.orchestration/README.md` on install; currently useless as a reference.
- `docs/` exists but only contains `education-audit.md`.
- No d2 files exist anywhere in the repo.

## Desired end state

- README.md is a complete rewrite. Structure: why this exists → core concepts (slices, worktrees, human gates) → quick start → usage flowchart → complex cases → customization note.
- Several d2 diagrams exist as `.d2` source in `docs/diagrams/` and as rendered SVGs embedded in the README.
- A developer who has never heard of this system can read the README, understand the value, and follow the quick start in one sitting. Analogies and comparisons used where they help.
- `defaults/README.md` is rewritten as a short (~50 line) installed reference guide: commands cheatsheet, stage list, file layout. No motivation pitch — that's the GitHub README's job. This file is for people already running the system.

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

### 3–6. Complex cases — individual diagrams (gallery)
Each case gets its own diagram. Cramming them into one requires a legend and swim lanes that eat the clarity. A gallery of focused mini-flowcharts is more scannable and more referenceable. Each is ~10-15 nodes.

- **3. Pause and resume** — implement gets interrupted mid-execution, re-run picks up from the last completed task
- **4. Concurrent projects** — two projects running in parallel on separate worktree branches, both visible in `/status`
- **5. Multi-slice sequence** — shows a full project backlog (slices 01–N) advancing in order; each slice completes before the next is specced and implemented; backlog slices stay rough until they become next
- **6. Feedback loop** — review → feedback → new slice written to backlog → back to `/design` → implement

Rendered in a "Common patterns" section of the README with a short intro sentence before the gallery.

### 7. Folder structure reference
Static tree diagram showing `.orchestration/projects/{id}/` layout with all artifact types labeled. Not a flow — just a reference visual to anchor the concepts. Could be d2 or just a clean code block depending on what renders better.

## Patterns to follow

- README voice: matches Bdonizer register — direct, dry, short declarative payoffs, no inflation. Sentence case headings.
- Introduce from value → mechanics, not the other way. Reader earns the diagram by understanding why it matters first.
- Diagrams supplement prose, don't duplicate it. Caption, don't caption-and-explain.
- d2 diagrams use the `vars` block for consistent styling. Flowcharts use `direction: right` or `direction: down` depending on which reads better.
- Rendered SVGs go in `docs/diagrams/*.svg`. Source `.d2` files go in `docs/diagrams/*.d2`.
- README embeds via `![alt](docs/diagrams/name.svg)`.

## CLAUDE.md for diagram sync

A `CLAUDE.md` at the repo root should instruct any agent working in this repo that changes to command files (`.claude/commands/*.md`, `defaults/commands/*.md`) or the orchestration system flow require updating the diagrams and README to match. Without this, diagrams drift silently the moment someone ships a flow change.

Content to include:
- **Two sets of command files exist and serve different purposes.** `.claude/commands/` is the local install — what this repo uses to manage its own projects. `defaults/commands/` is the source code — what gets copied when someone runs `/init-orchestrator`. Changes to `.claude/commands/` only affect this repo. Changes to `defaults/commands/` ship to users.
- When modifying `defaults/commands/*.md`: check whether the change affects flow, stages, or terminology. If it does, update `docs/diagrams/*.d2`, re-render the affected SVGs, and update README.md prose to match. Also sync `.claude/commands/` if the change should apply locally too, enabling dogfooding
- When adding new project stages or commands to `defaults/`: update the lifecycle state machine diagram and the happy path flowchart.
- The `.d2` source is the source of truth for diagrams. SVGs are derived artifacts — always regenerate from source.

This CLAUDE.md is a deliverable of this project alongside the README and diagrams.

## Key edge cases

- d2 is an external tool — rendered SVGs must be committed alongside source so the README works without a build step. The implementation task should include rendering the SVGs and committing both.
- `defaults/README.md` is being rewritten as a short installed reference guide. It should not duplicate the GitHub README's motivation content — commands, stages, and file layout only.
- The folder structure diagram and `defaults/README.md` file layout section must both reflect the current `.orchestration/` layout, not the old one (which referenced `/pipeline`, `/migrate`, etc.).
- SVG embed sizing: GitHub renders inline SVGs at full width. Wide diagrams may need a max-width wrapper or a note to view in full.
- The `.claude/commands/` vs `defaults/commands/` distinction must be clearly explained in both the GitHub README (customization section) and CLAUDE.md. It's the most likely point of confusion for contributors.

## Resolved design decisions

**Embed SVGs in README, source in docs/diagrams/**
Why: SVGs render natively in GitHub, no external link required, no CDN dependency. Source stays in repo so diagrams can be updated.
Rejected: linking to an external d2 playground (fragile, not self-contained).

**Full README rewrite, not an append**
Why: the current structure introduces commands before motivation. Reordering requires a rewrite. Appending would leave the weak intro intact.
Rejected: adding a "Visual overview" section at the bottom and leaving the rest alone. The prose order matters.

**7 diagrams in first slice, more via feedback**
Why: the complex cases split from one diagram to four individual ones, making 7 total. All seven are focused and small enough to implement in one slice. Diagram sprawl before the prose is solid is backwards — but these are all in scope now.
Rejected: implementing all complex cases as a single diagram (requires legend and swim lanes, kills clarity). Rejected: deferring complex cases to a feedback slice (they're the core of the visual supplement).

**CLAUDE.md at repo root enforces diagram sync**
Why: without an explicit instruction, any future agent changing a command file has no reason to know diagrams exist. A CLAUDE.md makes the sync obligation discoverable and automatic.
Rejected: relying on PR review to catch diagram drift (too late, too manual). Rejected: a CI lint step (over-engineered for a docs repo).

**defaults/README.md rewritten as short installed reference guide**
Why: it gets copied into `.orchestration/README.md` on install and serves a different audience than the GitHub README — people already using the system, wanting a quick lookup. A pointer to GitHub adds browser friction. A ~50-line cheatsheet mirrors stable concepts and won't diverge fast.
Rejected: pointing to GitHub README (requires connectivity, wrong orientation). Rejected: leaving it as-is (it's broken and actively misleading).

## Agent decisions

Decisions made implicitly — not explicitly discussed. Listed for review to catch unexamined assumptions.

**SVG format for rendered diagrams.** Context: SVGs render natively in GitHub without a CDN, scale cleanly, and stay diff-friendly. Alternative: PNG (simpler tooling, no scaling concerns, but loses crispness and can't be diffed meaningfully).

**Markdown image syntax (`![alt](path)`) over HTML `<img>` tags.** Context: simpler, works everywhere GitHub renders markdown. Alternative: `<img>` with explicit width/height constraints — would solve the wide-diagram sizing issue but adds HTML to a markdown file.

**d2 `vars` block for consistent diagram styling.** Context: standard d2 pattern for shared colour/font across diagrams in the same repo. Alternative: per-diagram inline styles (more flexible, harder to keep consistent).

**README structure order: value props → core concepts → quick start → flowcharts → complex cases → customization.** Context: leads with motivation before mechanics, earns the diagrams. Alternative: quick start first (optimised for "I just want to try it" readers, but skips the why).

**"Common patterns" as the section heading for the complex cases gallery.** Context: descriptive and neutral. Alternative: "Advanced usage", "Edge cases", "More examples" — all have slightly wrong connotations.

**The 4 complex cases chosen (pause/resume, concurrent, multi-slice, feedback loop).** Context: these cover the main non-obvious behaviours of the system. Alternative: could have included "wrong-command routing" or "QA iteration" as cases — left out as they're edge errors rather than intentional patterns.

**Folder structure as diagram 7 rather than a prose code block.** Context: a d2 tree makes artifact types visually distinct from folder names. Alternative: plain code block (no d2 dependency, simpler, but harder to annotate).

**CLAUDE.md at repo root rather than in `.orchestration/` or `.claude/`.** Context: repo root is where Claude Code looks first; agents working anywhere in the repo will see it. Alternative: `.orchestration/CLAUDE.md` (scoped to orchestration work only, but misses contributors editing command files).

**~50 lines for `defaults/README.md`.** Context: enough for a commands cheatsheet, stage list, and file layout without becoming a second README. Alternative: no fixed target — could grow naturally, but without a cap it tends to drift toward the full README's scope.

**Value props ordering (single source of truth → docs in sync → slicing → status → isolation → gates → QA → scaffold).** Context: ordered from "what you get" to "how it works" — tangible benefits first, structural benefits later. Alternative: ordered by usage frequency or pipeline order.

