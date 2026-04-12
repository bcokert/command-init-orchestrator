---
type: brief
slice: 02
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
slice_doc: specs/slices/project-sequencing-and-status/02-slicing-step.md
status: ready
date: 2026-04-11
---

# Delegation brief — Slice 02: Slicing step

## Intent

Extend `defaults/commands/design.md` Phase 5 (slicing) so it fully executes when `/design` is run from `design_review`. Phase 5 already exists as a stub in design.md from slice 01 — this slice makes it work: read the design doc, produce individual slice files, handle resume from partial state, and stop at `slicing_review` with a commit + push.

The slicing logic itself lives in `defaults/commands/slice.md` as an internal implementation file. `/design` reads and follows it. The user never calls `/slice` directly.

## Observable outcomes

**Approve design, run /design → slices produced:**
```
Given status.md shows stage: design_review
When the user runs /design
Then slicing runs using design-01.md as input
And individual slice files are written to .orchestration/projects/{id}/slices/
And each slice file is 30-50 lines (hard cap 100) with Goal + Happy path + Edge cases
And status.md advances to stage: slicing_review
And git commit contains all slice files and status.md
And git push runs
And the slicing review gate is shown
```

**Resume at slicing_review:**
```
Given status.md shows stage: slicing_review
When the user runs /design
Then the slicing review gate is shown immediately
And no re-slicing occurs
And no files are modified
```

**Resume: crashed mid-slicing, no slice files:**
```
Given status.md shows stage: slicing_in_progress and slices/ is empty or absent
When the user runs /design
Then slicing restarts from the beginning
And design doc is re-read from disk
```

**Resume: crashed mid-slicing, some files written:**
```
Given status.md shows stage: slicing_in_progress and slices/ contains some but not all slice files
When the user runs /design
Then all existing slice files are discarded and regenerated
And slicing completes fully before status advances
```

**Design doc manually edited:**
```
Given design-01.md was edited after design_review was set
When slicing runs
Then the latest version of design-01.md is used (re-read from disk, not cached)
```

**Slicing surfaces a gap in the design doc:**
```
Given slicing encounters an ambiguity that blocks producing a slice
When the gap is detected
Then slicing stops and asks the user to resolve the ambiguity
And no slice files are written until the gap is resolved
```

**Wrong command:**
```
Given status.md shows stage: slicing_in_progress or slicing_review
When the user runs /implement or /review
Then output is: "project is in {stage} — run /design to continue"
And no work is done
```

## Constraints

**Must:**
- Update `status.md` to `slicing_in_progress` before writing any slice files — crash during slicing is detectable
- Write all slice files before advancing status to `slicing_review` — status advance is the last write
- Regenerate all slice files on resume from `slicing_in_progress` (idempotent — safe to overwrite)
- Each slice file format:
  ```markdown
  ---
  type: slice
  slice: {NN}
  project: {project_id}
  design: {path to design doc}
  status: draft
  ---

  # Slice {NN} — {Title}

  **Goal:** [1-2 sentences. Observable end state.]

  ## Happy path
  [3-5 bullets.]

  ## Edge cases
  [3-5 bullets.]
  ```
- Slice files saved to `.orchestration/projects/{id}/slices/{NN}-{slug}.md`
- Slice 01 (the next slice to implement) gets full detail. Subsequent slices are intentionally rough.
- Commit message: `"Slicing complete — {project_id} ({N} slices)"`
- Commit includes all slice files and `status.md` — no other files
- Push after commit

**Must not:**
- Advance status to `slicing_review` before all slice files are written
- Partially write slice files — write each atomically or regenerate all on resume
- Cache design doc content — always re-read from disk

**Preferences:**
- If slicing logic in `slice.md` needs updating to write to the new path format, update it minimally — path change only, logic unchanged
- Slicing review gate copy should note that slice 01 should be fully detailed and the rest are intentionally rough

**Escalation triggers:**
- Design doc (`design-01.md`) does not exist or is empty when slicing begins — stop and tell the user
- Slicing produces zero slices (design doc too vague to slice) — stop and ask the user to revisit the design

## Done definition

1. Running `/design` from `design_review` produces slice files in `.orchestration/projects/{id}/slices/`, advances to `slicing_review`, commits, and pushes
2. Each slice file matches the required format with correct frontmatter
3. Running `/design` from `slicing_review` shows the gate immediately with no file changes
4. Crash-resume from `slicing_in_progress` with partial files: re-run regenerates all files correctly
5. Crash-resume from `slicing_in_progress` with no files: re-run restarts slicing cleanly
6. Running `/implement` or `/review` at `slicing_in_progress` or `slicing_review` outputs the correct error

## Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Wire Phase 5 in design.md: status to `slicing_in_progress` + resume detection | Phase 5 writes `slicing_in_progress` before any slice files; detects partial state on resume | status shows `slicing_in_progress` before first slice file exists; partial state triggers full regeneration |
| 2 | Update slice.md output path and format | slice.md writes individual files to `.orchestration/projects/{id}/slices/{NN}-{slug}.md` with correct frontmatter | Slice files appear at correct paths with correct format after running |
| 3 | Wire Phase 5 completion: status to `slicing_review`, commit, push, gate | Status advances after all files written; commit contains only slice files + status.md; gate shown with education | `git show --stat HEAD` shows correct files; slicing gate displayed |
| 4 | Add wrong-command errors for slicing stages | `/implement` and `/review` output correct error at `slicing_in_progress` and `slicing_review` | Error messages include stage name and "run /design to continue" |
