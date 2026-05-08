---
spec: .orchestration/projects/bcokert-00007-batch-slice-flow/03-briefs/10-readme-and-diagrams-refresh.md
slice: 10
step: 7
title: Re-render affected SVGs via d2 CLI
status: done
depends_on: [06-update-feedback-loop-d2.md]
agent_type: architect
model: sonnet
effort: default
assigned_at: null
completed_at: null
qa_result: null
---

For each updated `.d2` source (lifecycle, state-machine, multi-slice-sequence, feedback-loop), run `d2 docs/diagrams/{name}.d2 docs/diagrams/{name}.svg` to regenerate the SVG. Per CLAUDE.md, never edit SVGs directly.

**Done signal:** Each updated .svg's mtime is newer than its .d2 source.
