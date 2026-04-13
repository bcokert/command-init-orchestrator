**Type:** Task (AI agent)
**Date:** 2026-04-13

---

### 1. Intent

`command-init-orchestrator` is a Claude Code command that installs a 4-command AI project orchestration system into any git repo. The current README describes the commands but doesn't motivate them — no value props, no mental model, no diagrams. Someone landing on the repo has to piece together what problem it solves and why they'd use it.

This slice rewrites README.md from scratch and creates two d2 diagrams: a happy path flowchart and a project lifecycle state machine. After this slice, a developer new to the system can open the README, understand the value, see the full flow, and follow the quick start without help.

The d2 source lives in `docs/diagrams/`. Rendered SVGs are committed alongside. The README embeds SVGs directly via markdown image syntax — no external links, no build step required to view.

---

### 2. Observable outcomes

**README rewrite — happy path**
```
Given a developer opens README.md on GitHub with no prior knowledge of init-orchestrator
When they read from top to bottom
Then they understand what problem it solves, what the 4 commands do, how to install and use it,
     and can follow the quick start sequence without referring to any other file
```

**Happy path diagram**
```
Given docs/diagrams/happy-path.svg exists and is embedded in README.md
When viewed on GitHub
Then the full project flow is visible: /design (with its internal stages), /implement (worktree → tasks → QA),
     and /review (approve or feedback), with human gates clearly distinct from automated steps
```

**Lifecycle state machine**
```
Given docs/diagrams/lifecycle.svg exists and is embedded in README.md
When viewed on GitHub
Then all stage values are visible as states, transitions are labelled with the driving command,
     human gates are visually distinct, and the feedback_pending loop back to design is shown
```

**Edge case — wide diagram**
```
Given the happy-path diagram is rendered with direction: right
When viewed in a standard GitHub viewport (~900px wide)
Then the diagram is fully readable without horizontal scrolling;
     if it overflows, direction: down is used instead
```

**Edge case — SVG fallback**
```
Given an SVG fails to render in a particular viewer
When the img alt text is read instead
Then the alt text conveys enough to understand what the diagram shows
     (e.g. "Happy path flowchart: /design → /implement → /review with human gates")
```

---

### 3. Constraints

**Must:**
- README.md is a complete rewrite — not an append. The existing file is replaced in full.
- README structure order: value props → core concepts → quick start → diagrams → customization note. This order is non-negotiable — motivation before mechanics.
- Value props use the exact pattern: `**Short anchor.** One sentence of what it means. One sentence of why it matters.` — no more, no less per prop.
- The 8 value props must be included in this order:
  1. Single source of truth
  2. Docs stay in sync
  3. Slicing discipline built in
  4. Status that reflects reality
  5. Work isolation by default
  6. Human gates where they matter
  7. QA is a first-class citizen
  8. Project scaffold, not a server
- d2 source files go in `docs/diagrams/` with `.d2` extension. SVGs go in the same folder with `.svg` extension.
- Both `.d2` source and `.svg` renders are committed. SVGs must be committed so the README works without a d2 install.
- README embeds diagrams via `![descriptive alt text](docs/diagrams/filename.svg)` — markdown syntax only, no HTML img tags.
- Both diagrams use a shared `vars` block for consistent font and colour styling.
- Apply bdonizer voice throughout: no warmup sentences, no AI vocabulary ("crucial", "highlight", "landscape", "vibrant", "underscore"), no significance inflation, sentence case headings, short declarative payoffs.
- The `.claude/commands/` vs `defaults/commands/` distinction must be explained in the customization section: local commands affect only this repo; defaults commands ship to users on install.

**Must not:**
- Do not reference `/pipeline`, `/migrate`, `/breakdown`, or any old command names — these are from a previous version.
- Do not reference `defaults/README.md` anywhere in README.md.
- Do not add motivational language to the customization section — it explains mechanics, not selling points.
- Do not use HTML in README.md except if absolutely required for diagram sizing, and only as a last resort.

**Preferences:**
- Analogies welcome where they aid understanding — keep them brief and practical, not extended metaphors.
- Diagram direction: try `direction: right` first for the happy path flowchart; fall back to `direction: down` if it overflows a ~900px viewport.
- The lifecycle state machine suits `direction: down` or a circular layout — choose whichever makes the feedback loop most readable.
- Human gates in diagrams should be visually distinct from automated stages — use a different shape (e.g. diamond or double-border) or colour via the `vars` block.
- Quick start should be numbered steps, not prose.

**Escalation triggers:**
- Stop and check in if d2 CLI is not installed or `d2 --version` fails — SVGs can't be rendered without it.
- Stop and check in if any diagram exceeds ~25 nodes — it may need to be simplified or split.
- Stop and check in if the README rewrite exceeds 120 lines — something is over-explained.

---

### 4. Done definition

- `README.md` exists, replaces the previous version entirely, opens with the 8 value props section.
- `docs/diagrams/happy-path.d2` exists with valid d2 syntax.
- `docs/diagrams/happy-path.svg` exists and renders correctly (non-empty, not an error SVG).
- `docs/diagrams/lifecycle.d2` exists with valid d2 syntax.
- `docs/diagrams/lifecycle.svg` exists and renders correctly.
- Both SVGs are embedded in README.md and render on GitHub — verify by checking that the `![...](docs/diagrams/...)` syntax is correct and the files exist at those paths.
- Both `.d2` files use a shared `vars` block with matching font/colour values.
- README contains these sections in order: value props, core concepts, quick start, diagrams (happy path + lifecycle), customization note.
- README does not contain the words: "crucial", "highlight", "landscape", "vibrant", "underscore", "pipeline", "migrate" (in a command context), "breakdown" (as a command name).
- Customization section explicitly names `.claude/commands/` (local) vs `defaults/commands/` (ships to users).

**Test vectors:**

| Check | Pass condition |
|-------|---------------|
| README opens with value props | First `##` heading after the title is "Why" or equivalent value props section |
| Value prop format | Each prop is `**Anchor.** Sentence. Sentence.` — bold anchor, exactly 2 sentences |
| Happy path diagram shows human gates | At least 4 distinct human gate nodes visible in the SVG (design_review, slicing_review, spec_review, signoff_review) |
| Lifecycle shows feedback loop | `feedback_pending` state present with transition back toward design |
| SVG files are non-trivial | `wc -c docs/diagrams/happy-path.svg` > 500 bytes; same for lifecycle.svg |
| No old command names | `grep -i "pipeline\|/migrate\|/breakdown" README.md` returns nothing |
| Customization distinction present | `grep -i "defaults/commands" README.md` returns at least one match |

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Write README.md prose | `README.md` rewritten with all sections; diagram image tags present as placeholders pointing to final SVG paths | File exists, structure matches spec, bdonizer pass applied, no old command names |
| 2 | Write and render happy-path.d2 | `docs/diagrams/happy-path.d2` + `docs/diagrams/happy-path.svg` | SVG is non-empty, renders without error, human gates visually distinct from automated steps |
| 3 | Write and render lifecycle.d2 | `docs/diagrams/lifecycle.d2` + `docs/diagrams/lifecycle.svg` | SVG is non-empty, all stage values present as states, feedback_pending loop visible |
| 4 | Verify README end-to-end | README.md with both SVGs embedded, all done-definition checks passing | All test vectors in section 4 pass; README renders correctly with images on GitHub |
