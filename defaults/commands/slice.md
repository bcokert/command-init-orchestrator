---
version: 1.2.0
description: |
  Takes a design doc and produces a vertical slicing plan. Each slice is independently deliverable and validatable. Phases are optional groupings of slices — slices are the fundamental unit. Output feeds into /spec.
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
---

# Slice — vertical slicing plan

Read a design doc and produce a slicing plan. The user reviews this deeply before any spec is written.

State, schemas, principles, and slice frontmatter live in `.root-context/state-diagram.md`. Helper used: `support/bdonize.md` (voice).

---

## Phase 0 — Load inputs

If a design doc path was passed as argument, read it. Otherwise: "Which design doc are we slicing? (path to file)".

Also read the design doc's linked project context — architecture files, CONSTRAINTS.md, DECISIONS.md if referenced.

---

## Phase 1 — Understand and confirm

Restate in 2-3 sentences what the design doc is asking for. Ask the user to confirm or correct before producing any slices.

---

## Phase 2 — Identify slices

Produce a draft list. Apply these rules strictly:

**Vertical, not horizontal.** Each slice delivers observable value end-to-end. Not "build the model layer" or "add all the tests" — those are horizontal cuts. A vertical slice is thin but full-stack: someone (user, API caller, agent) can do something after it that they couldn't before.

**Each slice has:**
- A clear goal (what this delivers — observable, not implementation)
- A validation signal (how you know it's done without reading the code)
- What changes (files, systems, architectural areas affected)

**Slices should be small.** Smaller than feels natural. If a slice touches more than ~5 files or has more than 3 distinct "changes", consider splitting.

**Phases are optional groupings.** Use them when a natural sequence exists. The slice is the atom; phases are just labels for clusters.

---

## Phase 3 — Clarify if needed

If anything in the design doc is ambiguous for slicing purposes, ask before proceeding. Keep it short — only ask what you genuinely can't determine.

---

## Phase 4 — Stress test each slice

Before writing the output, check every slice:

1. **Is this vertical?** Delivers observable value, not a layer.
2. **Is the validation signal checkable without reading code?**
3. **Is it small enough?** ≤5 files, ≤3 "changes" bullets.
4. **Is the sequence right?** No unexpected blockers from earlier slices.

Fix any issues before writing.

---

## Phase 5 — Write the slices

Target each slice file 30–50 lines, hard cap 100. A slice that can't fit in 100 lines is too big — split it.

**Every slice gets full detail** — complete Goal, complete Happy path, complete Edge cases. Implementation and signoff feedback may revise later slices for cohesion, but they don't start rough.

**Follow-up slices** (from signoff feedback) use dot notation: `slice: 05.1`, `order: 5.1`, filename `05.1-{slug}.md`. `order` is the canonical sort key — `5.1` sorts between `5` and `6`.

Path: `.orchestration/projects/{id}/02-slices/{NN}-{slug}.md` (or `{NN.N}-{slug}.md` for follow-ups).

See `state-diagram.md` Frontmatter schemas for the slice file frontmatter; Slicing.Review section for the state transitions. Slices are written with `status: draft`. The calling command (`/plan-project`) handles approval flow and status transitions.

```markdown
---
type: slice
slice: {NN}
order: {NN}
project: [short kebab-case feature name]
design: [path to design doc]
status: draft
---

# Slice {NN} — [Name]

**Goal:** [1-2 sentences. What this delivers. Observable end state, not implementation steps.]

## Happy path

[3-5 bullets. What works correctly when this slice is done. Each is a testable statement.]

## Edge cases

[3-5 bullets. Crashes, partial state, wrong inputs, recovery. Each names the condition and the expected behavior.]
```

After writing all slice files, output a one-line summary of the full slice list so the user can see the whole plan at a glance.

---

## Phase 6 — Bdonize and save

Apply voice patterns inline per `support/bdonize.md` before saving.

Save slice files to `.orchestration/projects/{id}/02-slices/{NN}-{slug}.md`. One file per slice. Write using the full absolute path. Confirm the paths.

---

## Behavior rules (slice deltas)

Shared rules live in `.root-context/state-diagram.md`.

- Never skip the vertical check. A horizontal slice is a planning bug.
- If the design doc has gaps that block slicing, ask before guessing.
- Phases are groupings — use them only when a sequence is genuinely there.
- The slices output is the user's second deep review gate. Make it worth reviewing: clear goals, clear validation signals, no fuzz.
