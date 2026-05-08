# Brief 08 — qa, slice, spec cleanup

**Type:** Task (AI agent)
**Date:** 2026-05-06

## 1. Intent

Three support files (`qa.md`, `slice.md`, `spec.md`) carry stale references, drift, and the bdonize block now consolidated in slice 02. This slice corrects the drift and references the shared bdonize.

## 2. Observable outcomes

```
Given qa.md before this slice
When a reader looks at the description frontmatter
Then it points to .orchestration/projects/{id}/05-qa/slice-{NN}-qa-report.md (matching Phase 3 actual write), not .orchestration/dashboard/
```

```
Given qa.md before this slice
When grep searches for "reviewed" or "Bdon"
Then no matches
```

```
Given slice.md before this slice
When a reader looks for state-machine transitions
Then they find a reference to .root-context/state-diagram.md instead of inline prose
```

```
Given spec.md before this slice
When grep searches for "/delegate"
Then no matches
```

```
Given slice.md / spec.md after this slice
When a reader looks at the bdonize section
Then it references support/bdonize.md instead of repeating the voice block
```

## 3. Constraints

**Must:**
- Fix qa.md:1 description path to match Phase 3 actual write.
- Replace qa.md:70 `reviewed` with `review`.
- Purge "Bdon" from qa.md, slice.md, spec.md → "the user".
- Cut spec.md:139 `/delegate` reference.
- Cut slice.md inline state-machine prose at line 114; replace with reference to state-diagram.md.
- Replace bdonize blocks in slice.md and spec.md with reference to support/bdonize.md.
- Bump versions on all three files.

**Must not:**
- Lose load-bearing behavior — verify state-diagram.md (post-slice 01) covers slice.md's previous "draft → review on approval" semantics before cutting.
- Break .orchestration/support/ copies — they're byte-identical pairs; both must update.

**Preferences:**
- Keep the references explicit and short ("see `support/bdonize.md`" not vague pointers).

**Escalation triggers:**
- If state-diagram.md after slice 01 doesn't cover slice.md's transition prose, surface and stop until it does.

## 4. Done definition

- `grep -nw 'Bdon\|/delegate\|reviewed' defaults/commands/{qa,slice,spec}.md` returns no matches.
- qa.md description path matches actual Phase 3 write.
- slice.md state-machine prose at line 114 gone; reference to state-diagram.md present.
- bdonize blocks in slice.md / spec.md replaced with references to support/bdonize.md.
- All three files version bumped.

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Fix qa.md description path | Path matches Phase 3 write | grep verifies |
| 2 | qa.md misc fixes | reviewed→review (line 70); Bdon→user (line 121); version bump | grep returns no matches |
| 3 | spec.md cleanup | /delegate reference cut; Bdon→user; bdonize block replaced with reference; version bump | grep clean; reference present |
| 4 | slice.md cleanup | State-machine prose cut and replaced with state-diagram.md reference; Bdon→user; bdonize block replaced with reference; version bump | grep clean; references present |
