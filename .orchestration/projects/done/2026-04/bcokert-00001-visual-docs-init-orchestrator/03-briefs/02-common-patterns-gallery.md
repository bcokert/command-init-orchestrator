---
type: brief
slice: 02
project: bcokert-00001-visual-docs-init-orchestrator
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/02-slices/02-common-patterns-gallery.md
design: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/01-design/design-01.md
date: 2026-04-14
---

# Delegation brief — Slice 02: Common patterns gallery

**Type:** Task (AI agent)
**Date:** 2026-04-14

---

## 1. Intent

This project rewrites the README for `command-init-orchestrator` — a 4-command Claude Code orchestration system (`/design`, `/implement`, `/review`, `/status`). Slice 01 delivered the README prose and two core diagrams (artifacts.svg, lifecycle.svg). Slice 02 adds a "Common patterns" gallery: 4 mini-flowcharts showing non-obvious system behaviours, plus a folder structure reference.

The README currently ends after the lifecycle diagram with an Install section and a Customization section. The gallery section goes between them — after `## How a project flows`, before `## Install`. The section heading to locate by is `## Install`.

All diagrams must use `d2` (https://d2lang.com). Source files go in `docs/diagrams/`, rendered SVGs are committed alongside them and embedded in the README with `![alt](docs/diagrams/name.svg)`.

Existing diagrams to reference for styling: `docs/diagrams/artifacts.d2` and `docs/diagrams/lifecycle.d2`. Both use a `vars` block with a shared colour palette and `layout-engine: dagre`.

---

## 2. Observable outcomes

**Pause and resume**
```
Given a project is mid-execution with 3 tasks (2 done, 1 remaining)
When the user re-runs /implement
Then the diagram shows: tasks 1+2 as done, task 3 still running, with a "resume" arrow entering between task 2 and task 3
```

**Concurrent projects**
```
Given two projects A and B are both at "implementing" on separate branches
When the user runs /status
Then the diagram shows: both projects with their own worktrees, both visible in a status table, main branch untouched
```

**Multi-slice sequence**
```
Given a project has 3 slices planned
When slice 01 is complete and /review approved
Then the diagram shows: slice 01 archived, slice 02 becoming "next" (detailed), slice 03 staying rough until slice 02 is done
```

**Feedback loop**
```
Given /review receives feedback instead of approval
When the feedback is processed
Then the diagram shows: /review → feedback slice written → /design specs it → /implement runs it → back to /review
```

**Folder structure**
```
Given a project named "bcokert-00001-example" exists
When an agent looks at the project folder
Then the reference shows the full .orchestration/projects/{id}/ tree with all 5 artifact directories labeled (01-design, 02-slices, 03-briefs, 04-tasks, 05-qa)
```

---

## 3. Constraints

**Must:**
- 4 mini-flowcharts in `docs/diagrams/` as `.d2` source + rendered `.svg`
- Folder structure reference as a 5th diagram OR as a clean annotated code block in the README — use whichever renders more clearly; d2 tree syntax is fine if it works, markdown code block is the fallback
- "Common patterns" section inserted into README.md after `## How a project flows` and before `## Install` (locate by the `## Install` heading — insert the new section immediately before it)
- Each diagram uses the same `vars` block as `docs/diagrams/artifacts.d2` — same colours, same layout-engine
- All diagrams rendered and committed as SVG
- Each mini-flowchart is ~10-15 nodes max; if a case requires more, simplify

**Must not:**
- Touch any section of README.md above `## Install` — the rewritten content from slice 01 is final
- Add explanatory prose beyond a short intro sentence before the gallery and the individual alt-text captions
- Delete or replace `artifacts.d2`, `artifacts.svg`, `lifecycle.d2`, or `lifecycle.svg`
- Use a diagram style that doesn't match the `vars` block from the existing diagrams

**Preferences:**
- Folder structure: if d2 tree syntax makes the artifact types visually distinct from folder names, use it; otherwise use a markdown code block with inline comments
- Keep arrows and labels short — diagrams carry the meaning, not the labels
- Matching naming convention: `pause-resume.d2`, `concurrent-projects.d2`, `multi-slice-sequence.d2`, `feedback-loop.d2`

**Escalation triggers:**
- If `d2` is not installed or `d2 --version` fails — stop and report: "d2 is not installed. Install from https://d2lang.com before proceeding."
- If any rendered SVG is over 2000px wide — flag it before committing; wide diagrams may need layout restructuring

---

## 4. Done definition

1. `docs/diagrams/pause-resume.d2` exists, `docs/diagrams/pause-resume.svg` exists and is > 500 bytes
2. `docs/diagrams/concurrent-projects.d2` exists, `docs/diagrams/concurrent-projects.svg` exists and is > 500 bytes
3. `docs/diagrams/multi-slice-sequence.d2` exists, `docs/diagrams/multi-slice-sequence.svg` exists and is > 500 bytes
4. `docs/diagrams/feedback-loop.d2` exists, `docs/diagrams/feedback-loop.svg` exists and is > 500 bytes
5. Folder structure reference present in README.md (as diagram or annotated code block) — contains at minimum: `01-design/`, `02-slices/`, `03-briefs/`, `04-tasks/`, `05-qa/`, and `done/`
6. README.md contains a `## Common patterns` section placed after `## How a project flows` and before `## Install`
7. The section has a short intro sentence (1 sentence max), then one `![alt](docs/diagrams/name.svg)` line per diagram
8. All 4 SVG filenames appear in README.md as image embeds
9. `d2 --version` succeeds and SVGs were generated from source (not manually created)

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Write pause-resume diagram | `docs/diagrams/pause-resume.d2`, rendered `pause-resume.svg` | SVG exists, > 500 bytes, renders without error |
| 2 | Write concurrent-projects diagram | `docs/diagrams/concurrent-projects.d2`, rendered `concurrent-projects.svg` | SVG exists, > 500 bytes, renders without error |
| 3 | Write multi-slice-sequence diagram | `docs/diagrams/multi-slice-sequence.d2`, rendered `multi-slice-sequence.svg` | SVG exists, > 500 bytes, renders without error |
| 4 | Write feedback-loop diagram | `docs/diagrams/feedback-loop.d2`, rendered `feedback-loop.svg` | SVG exists, > 500 bytes, renders without error |
| 5 | Add folder structure reference + "Common patterns" section to README | README.md updated with gallery section | Section present between `## How a project flows` and `## Install`, all 4 SVGs embedded, folder structure reference present |
