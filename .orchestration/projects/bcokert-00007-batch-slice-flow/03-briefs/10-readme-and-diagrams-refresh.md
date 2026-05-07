# Brief 10 — README + defaults/README + diagram refresh

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

`README.md`, `defaults/README.md`, and the d2 diagrams have drifted from the post-batch state machine. The user explicitly flagged this in the original ask. This slice realigns prose and visuals to match what slices 01-09 produced. Tables become links to state-diagram.md (single source of truth) instead of re-lists.

## 2. Observable outcomes

```
Given README.md before this slice
When a reader scans for human gates
Then "spec review" is gone; the four real gates are listed (design review, slicing review, signoff review)
```

```
Given README.md before this slice
When a reader looks at the folder layout block
Then observability/ and support/ are present; the install description lists agents and support classes
```

```
Given defaults/README.md before this slice
When a reader looks for the stage table
Then it's a link to state-diagram.md (or its schema/state tables) instead of a re-list
```

```
Given the diagrams before this slice
When d2 source files are inspected
Then lifecycle.d2 has no spec_review diamond; state-machine.d2 has no wantMoreSlicesBrokenDown edge; multi-slice-sequence.d2 archives only on full completion; feedback-loop.d2 notes batched /review continuation
```

```
Given the diagrams after this slice
When the SVGs are checked
Then each .svg is freshly rendered from its .d2 source via the d2 CLI
```

## 3. Constraints

**Must:**
- README.md: drop spec_review gate, fix "specced slice" → "spec", add observability/support to layout, align "interleaved" wording with oldest-first sort, list agents+support classes in install description.
- defaults/README.md: replace stage table with link to state-diagram.md anchor; replace folder layout with link; purge feedback_pending; describe agents and support files (or link).
- Update each affected .d2 source per spec.
- Re-render every changed .svg via `d2 docs/diagrams/{name}.d2 docs/diagrams/{name}.svg`.
- Verify all README links land on existing anchors.

**Must not:**
- Edit SVG files directly (per CLAUDE.md).
- Restate state info in defaults/README.md instead of linking — re-listing reintroduces drift.

**Preferences:**
- Use stable anchor names in state-diagram.md (e.g. `#vocabulary`, `#slice-states`).

**Escalation triggers:**
- If a state-diagram.md anchor doesn't exist after slice 01, surface for fix before linking.

## 4. Done definition

- `grep -n 'spec review\|specced slice\|feedback_pending' README.md defaults/README.md` returns no matches.
- README folder layout shows observability/ and support/.
- defaults/README.md has links to state-diagram.md, no re-listed tables.
- All affected .d2 sources updated.
- All affected .svg files re-rendered (mtime newer than .d2 source).
- Manual link-check passes (every link resolves to an existing section).

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | README.md prose update | Spec_review gate removed; specced→spec; folder layout enriched; install lists agents+support; "interleaved" wording aligned | grep clean; visual review |
| 2 | defaults/README.md update | Stage table → link; folder layout → link; feedback_pending purged; agents/support described | grep clean; links present |
| 3 | Update lifecycle.d2 | spec_review diamond removed; spec → breakdown one auto stage | Source updated |
| 4 | Update state-machine.d2 | wantMoreSlicesBrokenDown edge removed; Signoff.Approved retargeted; Implementation.QA → Running added; Slicing.Generating self-loop collapsed | Source updated |
| 5 | Update multi-slice-sequence.d2 | Archive only on full completion | Source updated |
| 6 | Update feedback-loop.d2 | Note batched /review continuation | Source updated |
| 7 | Re-render all affected SVGs via d2 CLI | Each .svg mtime newer than .d2 | mtime check |
| 8 | Verify all README links | Every link resolves | Manual check |
