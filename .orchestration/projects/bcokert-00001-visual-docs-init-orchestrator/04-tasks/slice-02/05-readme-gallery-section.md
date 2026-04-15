---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/02-common-patterns-gallery.md
slice: 02
step: 5
title: Add Common patterns section to README
status: done
depends_on: [04-feedback-loop-diagram.md]
agent_type: architect
assigned_at: 2026-04-14T10:19:00-07:00
completed_at: 2026-04-14T10:21:00-07:00
qa_result: null
---

Add a "## Common patterns" section to README.md. Insert it immediately before the `## Install` heading (locate by that heading, not by line number).

The section contains:
1. One intro sentence (e.g. "A few patterns worth knowing before you hit them in the wild.")
2. The 4 SVG image embeds: pause-resume.svg, concurrent-projects.svg, multi-slice-sequence.svg, feedback-loop.svg — each on its own line with alt text
3. A folder structure reference showing `.orchestration/projects/{id}/` with 01-design/, 02-slices/, 03-briefs/, 04-tasks/, 05-qa/, and done/ labeled — use a d2 diagram if the tree syntax rendered well in tasks 1-4, otherwise a markdown annotated code block

Do not modify any section above `## Install`. Do not add prose beyond the intro sentence and image captions.

Done signal: `## Common patterns` section present in README.md between `## How a project flows` and `## Install`, all 4 SVGs embedded, folder structure reference present with all 6 directories.
