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

### Slice file format

Each slice is its own file. Target 30–50 lines. Hard cap 100 lines. A slice that can't fit in 100 lines is too big — split it.

The next slice gets full detail. Subsequent slices are intentionally rough until they become next — implementation will reshape them anyway.

Path: `{slices-dir}/{NN}-{slug}.md` where `slices-dir` follows the same convention as the design doc location.

```markdown
---
type: slice
slice: {NN}
project: [short kebab-case feature name]
design: [path to design doc]
status: draft
---

# Slice {NN} — [Name]

**Goal:** [1-2 sentences. What this delivers. Observable end state, not implementation steps.]

## Happy path

[3-5 bullets. What works correctly when this slice is done. Each is a testable statement about the world.]

## Edge cases

[3-5 bullets. Crashes, partial state, wrong inputs, recovery. Each names the condition and the expected behaviour.]
```

After writing all slice files, output a one-line summary of the full slice list so the human can see the whole plan at a glance.

---

## Phase 6 — Bdonize and save

Apply bdonizer patterns directly to the draft before saving. Do not invoke the bdonizer Skill tool — it loads instructions but does not produce revised output in this context. Apply inline:

- **Phase 1 — Strip AI patterns:** significance inflation, AI vocabulary ("crucial", "highlight", "landscape", "underscore", "vibrant"), em dash overuse, inline-header lists, filler phrases ("in order to", "it is important to note"), excessive hedging, sycophantic tone, chatbot artifacts.
- **Phase 2 — Tune to voice:** no warmup sentence, short declarative payoffs, deadpan over dramatic, practical framing over emotional, stop when done (no summary sentence). Sentence case headings. Terse fragments are fine.

Save slice files:
- If `.orchestration/` exists in the project root, save to `.orchestration/specs/slices/[feature-name]/{NN}-{slug}.md`.
- Otherwise default to `specs/slices/[feature-name]/{NN}-{slug}.md`.
- One file per slice. Never combine into a single doc.

Write using the full absolute path (never pass `~/...` to Write). Confirm the paths to Bdon.

---

## Behavior rules

- Never skip the vertical check. A horizontal slice is a planning bug.
- If the design doc has gaps that block slicing, ask before guessing.
- Phases are groupings — use them only when a sequence is genuinely there.
- The slices doc is Bdon's second deep review gate. Make it worth reviewing: clear goals, clear validation signals, no fuzz.
