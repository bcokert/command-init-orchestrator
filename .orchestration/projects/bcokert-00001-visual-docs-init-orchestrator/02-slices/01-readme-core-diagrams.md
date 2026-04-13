---
type: slice
slice: 01
order: 1
project: visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: specced
---

# Slice 01 — README rewrite + core diagrams

**Goal:** README.md is a complete rewrite — value props up front, mechanics introduced gradually — with the happy path flowchart and project lifecycle state machine embedded as SVGs. A developer new to the system can read top to bottom, understand the value, and follow the quick start without help.

## Happy path

- README.md opens with 8 value props in the "**Anchor.** What it means. Why that matters." pattern from the design doc — no warmup, no inflation
- Core concepts section follows: slices, worktrees, human gates — each explained briefly with an analogy where it helps
- Quick start section gives the 6-step sequence (design → review → continue → implement → review)
- Happy path flowchart renders inline as `docs/diagrams/happy-path.svg` — shows `/design` (interview → slicing → spec → breakdown), `/implement` (worktree → tasks → QA), `/review` (approve → merge → archive) with human gates as distinct decision nodes
- Lifecycle state machine renders inline as `docs/diagrams/lifecycle.svg` — all stage values as states, transitions labelled with the driving command, `feedback_pending` loop visible
- Customization section explains `.claude/commands/` vs `defaults/commands/` distinction explicitly — editing local commands only affects this repo; editing defaults ships to users
- All `.d2` source files committed to `docs/diagrams/`; SVGs committed alongside

## Edge cases

- Wide diagrams: if `direction: right` makes the happy path flowchart too wide for GitHub's default column, fall back to `direction: down` — verify by checking rendered width against a typical 900px GitHub viewport
- SVG alt text must be descriptive enough to partially convey the diagram if it fails to render — "Happy path flowchart: design → implement → review" not "diagram"
- d2 `vars` block must be identical across both diagrams for visual consistency — define once in a comment or note in the source files
- README line count: no artificial compression. If a section needs 10 lines to be clear, use 10 lines. Bdonizer pass before finalising — no AI vocabulary, no inflation, sentence case headings throughout
- Customization section must not imply the system is unchangeable — it's a scaffold, the point is you own it
