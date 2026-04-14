---
spec: .orchestration/projects/bcokert-00001-visual-docs-init-orchestrator/03-briefs/01-readme-core-diagrams.md
slice: 01
step: 4
title: Verify README end-to-end
status: done
depends_on: [03-lifecycle-diagram.md]
agent_type: architect
assigned_at: 2026-04-13T12:39:00-07:00
completed_at: 2026-04-13T12:41:00-07:00
qa_result: null
---

Wire the SVGs into README.md and run all done-definition checks from the brief.

1. Confirm `README.md` image tags point to the correct paths (`docs/diagrams/happy-path.svg`, `docs/diagrams/lifecycle.svg`) and the SVG files exist at those paths.
2. Run each test vector from brief section 4:

| Check | Command / method |
|-------|-----------------|
| README opens with value props | Read README.md — first `##` section after title is value props |
| Value prop format | Each prop line matches `**X.** Sentence. Sentence.` |
| Happy path shows human gates | Open SVG — at least 4 human gate nodes visible |
| Lifecycle shows feedback loop | Open SVG — `feedback_pending` state present with back-edge |
| SVG files non-trivial | `wc -c docs/diagrams/happy-path.svg` > 500; same for lifecycle |
| No old command names | `grep -i "pipeline\|/migrate\|/breakdown" README.md` returns nothing |
| Customization distinction present | `grep -i "defaults/commands" README.md` returns at least one match |

3. Fix any failures before marking done.

Done signal: all 7 test vectors pass, README.md and both SVGs committed.
