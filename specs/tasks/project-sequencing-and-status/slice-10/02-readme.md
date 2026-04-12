---
spec: specs/briefs/project-sequencing-and-status/10-init-and-education-audit.md
slice: 10
step: 2
title: Write README
status: todo
depends_on: [01-init-orchestrator-update.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Write or rewrite `README.md` to describe the system as actually implemented. Target ~100 lines.

Must cover:
- What this is (one paragraph)
- The 4-command surface: what each command does and when to use it
- The project lifecycle: from `/design` to `/review`, with the key human gates
- Worktrees: what they are, why the system uses them, that multiple projects can run in parallel
- The slice-at-a-time approach: why slices are small, what review gates exist
- How to install: `init-orchestrator`
- Quick start: "start a new project" in ~5 steps

Must not describe features not yet implemented (e.g. cross-project metrics dashboard, external integrations).

## Done signal

README.md exists and accurately describes the implemented system. No aspirational features described as present. A new user could understand the lifecycle and run their first project from it.
