---
version: 1.0.0
description: |
  Takes a design doc and produces a vertical slicing plan. Each slice is independently deliverable and validatable. Phases are optional groupings of slices — slices are the fundamental unit. Max ~200 lines. Output feeds into /spec.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
  - Skill
---

# Slice — Vertical Slicing Plan

Your job is to read a design doc and produce a slicing plan. Bdon will review this deeply before any spec is written.

---

## Phase 0 — Load inputs

If a design doc path was passed as an argument, read it. If not, ask:

> "Which design doc are we slicing? (path to file)"

Also read the design doc's linked project context — architecture files, CONSTRAINTS.md, DECISIONS.md if referenced.

---

## Phase 1 — Understand and confirm

Restate in 2-3 sentences what the design doc is asking for. Ask Bdon to confirm or correct before producing any slices.

---

## Phase 2 — Identify slices

Produce a draft list of slices. Apply these rules strictly:

**Vertical, not horizontal.** Each slice delivers observable value end-to-end, even if narrow. Not "build the model layer" or "add all the tests" — those are horizontal cuts. A vertical slice is thin but full-stack: someone (user, API caller, agent) can do something after it that they couldn't do before.

**Each slice must have:**
- A clear goal (what this delivers — observable, not implementation)
- A validation signal (how you know it's done without reading the code)
- What changes (files, systems, architectural areas affected)

**Slices should be small.** Smaller than feels natural. If a slice touches more than ~5 files or has more than 3 distinct "changes", consider splitting it.

**Phases are optional groupings.** Use them when a natural sequence exists — e.g., "Phase 1: read path, Phase 2: write path." Don't manufacture phases for the sake of structure. The slice is the atom; phases are just labels for clusters.

---

## Phase 3 — Clarify if needed

If anything in the design doc is ambiguous for slicing purposes, ask before proceeding. Keep this short — the design doc should have resolved most questions. Only ask what you genuinely can't determine.

---

## Phase 4 — Stress test each slice

Before writing the final output, check every slice:

1. **Is this vertical?** Does it deliver observable value, or is it a layer? A layer is not a slice.
2. **Is the validation signal checkable without reading code?** If you'd need to read the implementation to verify it, the signal is wrong.
3. **Is it small enough?** If it touches more than ~5 files or has more than 3 "changes" bullets, split it.
4. **Is the sequence right?** Could a later slice be blocked by an earlier one unexpectedly?

Fix any issues before writing the output.

---

## Phase 5 — Write the slices doc

Target: as short as the content genuinely allows, max ~200 lines. Do not compress unnaturally — if the plan needs more space to be clear, use it.

---

### Slices doc format

```markdown
---
type: slices
date: YYYY-MM-DD
design: [path to design doc]
feature: [short kebab-case name]
status: ready
---

# [Feature/Change Name] — Slices

## Overview

[1-2 sentences: what we're building and how many slices total.]

---

[Option A — with phases, when a natural sequence exists:]

## Phase 1: [Name]

[1 sentence: what this phase delivers.]

### Slice 1.1 — [Name]

**Goal:** [What this delivers. Observable, not implementation.]
**Changes:** [Files, systems, or architectural areas affected.]
**Validation:** [How you verify this slice works without reading the code.]

### Slice 1.2 — [Name]

...

---

## Phase 2: [Name]

...

---

[Option B — no phases, just sequential slices:]

### Slice 1 — [Name]

**Goal:** [What this delivers.]
**Changes:** [What changes.]
**Validation:** [How you verify it.]

### Slice 2 — [Name]

...
```

---

## Phase 6 — Bdonize and save

Apply bdonizer patterns directly to the draft before saving. Do not invoke the bdonizer Skill tool — it loads instructions but does not produce revised output in this context. Apply inline:

- **Phase 1 — Strip AI patterns:** significance inflation, AI vocabulary ("crucial", "highlight", "landscape", "underscore", "vibrant"), em dash overuse, inline-header lists, filler phrases ("in order to", "it is important to note"), excessive hedging, sycophantic tone, chatbot artifacts.
- **Phase 2 — Tune to voice:** no warmup sentence, short declarative payoffs, deadpan over dramatic, practical framing over emotional, stop when done (no summary sentence). Sentence case headings. Terse fragments are fine.

Save the file:
- If the current project's CLAUDE.md specifies where to save slice docs, follow those instructions.
- If `.orchestration/` exists in the project root, save to `.orchestration/specs/slices/YYYY-MM-DD-[short-name].md`.
- Otherwise default to `specs/slices/YYYY-MM-DD-[short-name].md`.

Write using the full absolute path (never pass `~/...` to Write). Confirm the path to Bdon.

---

## Behavior rules

- Never skip the vertical check. A horizontal slice is a planning bug.
- If the design doc has gaps that block slicing, ask before guessing.
- Phases are groupings — use them only when a sequence is genuinely there.
- The slices doc is Bdon's second deep review gate. Make it worth reviewing: clear goals, clear validation signals, no fuzz.
