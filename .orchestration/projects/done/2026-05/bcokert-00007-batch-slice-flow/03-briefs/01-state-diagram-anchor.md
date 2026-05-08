# Brief 01 — state-diagram canonical anchor

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`.root-context/state-diagram.md` is currently a partial source of truth — it has the state machine but lacks frontmatter schemas, vocabulary, batch principles, and consolidated crash recovery. Commands restate these inline and drift independently. This slice makes state-diagram.md the canonical anchor every later slice can link to instead of restating.

## 2. Observable outcomes

```
Given state-diagram.md before this slice
When a reader looks for "what does slice frontmatter contain"
Then they find typed schema tables (field | type | values | required) for slice, design, and task frontmatter
```

```
Given state-diagram.md before this slice
When a reader looks for crash recovery semantics
Then they find a single Crash recovery subsection consolidating re-read-from-disk, idempotent spec/breakdown, and brief+tasks fast-forward
```

```
Given state-diagram.md before this slice
When a reader scans state-machine transitions
Then wantMoreSlicesBrokenDown is gone; Signoff.Approved is split into three batch-aware transitions; Signoff.Review.containsFeedback retargets to match /review Phase 2; Implementation.QA → Running added; Slicing.Generating self-loop collapsed; Slicing.Asking comment deleted; review_context replaces "agent tracks last prompt"
```

```
Given state-diagram.md after this slice
When a reader searches for "user", "active project", "queue", "transition", "action"
Then each is defined once in the Vocabulary section and used consistently
```

## 3. Constraints

**Must:**
- Schemas list every frontmatter field every command writes today (one documented exception: design `status: ready` — known bug fixed in slice 04; the schema lists `in_progress | review | approved` and notes the discrepancy).
- Vocabulary section has at least: user, active project, queue, transition, action.
- review_context enum lists: initial, post_iteration, question.
- Run a cohesion read end-to-end after each section change.
- Add the principle "Batch is the default. A command's full scope runs end-to-end without inter-item gates. Per-slice gates fire only when a slice's state genuinely needs human input."

**Must not:**
- Introduce contradictions with existing principles.
- Use "human" or "operator" as the actor — canonical is "user".
- Reorganize existing sections unless required by the changes.

**Preferences:**
- Append new sections after existing ones.
- Keep schema tables compact.

**Escalation triggers:**
- If a current command behavior cannot be captured in the documented schema, surface the conflict before silently adapting the schema.

## 4. Done definition

- state-diagram.md renders cleanly (no broken markdown).
- Three schema tables present (slice, design, task) with `field | type | values | required` columns.
- Vocabulary section present with ≥ 5 locked terms.
- Crash recovery subsection consolidates the rules currently scattered in command files and the Error handling section.
- `grep -n 'wantMoreSlicesBrokenDown\|Slicing.Asking\|agent tracks last prompt' .root-context/state-diagram.md` returns no matches.
- `grep -nw 'human\|operator' .root-context/state-diagram.md` returns no matches as actor terms.
- All four cut/added transitions visible.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update Principles section | "Batch is the default" added; Crash recovery subsection consolidates re-read, idempotent spec/breakdown, brief+tasks fast-forward | Grep finds new principle and subsection |
| 2 | Add Vocabulary section | One-line definitions for user, active project, queue, transition, action | Section present; ≥ 5 entries |
| 3 | Write typed schema tables | Slice / design / task frontmatter tables incl. review_context enum and follow_up_of | All three tables present |
| 4 | Fix state-machine transitions | Deletions + additions per Outcomes block 3 | Grep verifies all six changes |
| 5 | Cohesion read | End-to-end re-read; no internal contradictions | Visual inspection passes |
