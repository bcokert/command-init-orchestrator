---
type: slice
slice: 02
project: project-sequencing-and-status
design: specs/design/project-sequencing-and-status.md
status: draft
---

# Slice 02 — Slicing step

**Goal:** After design approval, `/design` continues into slicing, produces individual slice files (one per slice) in `slices/`, advances to `slicing_review`, and commits + pushes.

## Happy path

- Approve design, re-run `/design` → slice files written to `.orchestration/projects/{id}/slices/`, status advances to `slicing_review`, commit + push, review gate shown
- Slicing logic internal — may live in `slice.md` as an implementation file; `/design` is the only user-facing entrypoint
- Resume at `slicing_review`: shows gate, no re-slicing

## Edge cases

- Slicing crashes mid-way: status shows `slicing_in_progress`, no slice files → re-run restarts slicing (design doc re-read from disk)
- Slicing crashes, some files written: status still `slicing_in_progress` → re-run detects partial output, regenerates all slice files
- Design doc manually edited since approval: slicing re-reads from disk, uses latest version
- Slicing surfaces a gap in design: ask user to resolve before writing any slice files
