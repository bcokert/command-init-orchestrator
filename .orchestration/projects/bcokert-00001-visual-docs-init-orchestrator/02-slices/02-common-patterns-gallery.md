---
type: slice
slice: 02
order: 2
project: visual-docs-init-orchestrator
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
status: tasks_ready
---

# Slice 02 — Common patterns gallery

**Goal:** README gains a "Common patterns" section with 5 diagrams (4 case flowcharts + folder structure reference) showing how the system handles concurrent projects, multi-slice sequences, feedback loops, pause/resume, and what the project folder layout looks like.

## Happy path

- 4 mini-flowcharts written as `.d2` source and rendered to SVG in `docs/diagrams/`
  - pause-resume.d2/svg — implement interrupted, re-run picks up from last completed task
  - concurrent-projects.d2/svg — two projects on separate branches, both visible in /status
  - multi-slice-sequence.d2/svg — full backlog advancing in order, slices 02+ staying rough until next
  - feedback-loop.d2/svg — review → feedback → new slice → /design → implement
- Folder structure reference written as `.d2` or clean code block in `docs/diagrams/` — `.orchestration/projects/{id}/` tree with artifact types labelled
- "Common patterns" section added to README.md after the lifecycle diagram, before the customization note
- Short intro sentence before the gallery, minimal prose — diagrams carry the weight

## Edge cases

- Depends on slice 01 README structure — "Common patterns" section is inserted after `## How a project flows` (the section containing the two core diagrams), before `## Install`; locate by section heading, not line number
- Each mini-flowchart is ~10-15 nodes — if any diagram grows beyond that, it's a sign the case is too complex and should be simplified or split
- Folder structure diagram: if d2 tree syntax doesn't render well for a file tree, fall back to a markdown code block with annotations — clarity beats format consistency
- All 5 diagrams must use the same `vars` styling as slice 01 diagrams
