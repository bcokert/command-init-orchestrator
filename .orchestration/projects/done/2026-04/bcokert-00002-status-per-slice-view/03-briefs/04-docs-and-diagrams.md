---
type: brief
slice: 04
project: bcokert-00002-status-per-slice-view
spec: .orchestration/projects/bcokert-00002-status-per-slice-view/02-slices/04-docs-and-diagrams.md
date: 2026-04-17
---

# Delegation brief — slice 04: docs and diagrams

**Type:** Task (AI agent)
**Date:** 2026-04-17

---

## 1. Intent

Slices 01–03 extend the slice state machine to 8 states and add `status_updated_at` to
slice frontmatter. The diagrams and READMEs that describe the system still show the old
6-state machine and don't mention `status_updated_at`. This slice updates them.

Two diagrams need changes. Two READMEs need updates. All SVGs must be re-rendered from
their `.d2` source — never edit SVGs directly.

---

## 2. Observable outcomes

**lifecycle.d2 — new qa_in_progress state**
```
Given   lifecycle.d2 currently shows: implementing → signoff_review → done/feedback
When    updated
Then    lifecycle.d2 shows: implementing → qa_in_progress → signoff_review → done/feedback
        qa_in_progress node uses the auto step style (fill: #f5f5f5, stroke: #9e9e9e)
        matching the other automated states in row 3
        SVG re-rendered and committed alongside the .d2 source
```

**artifacts.d2 — status_updated_at in slice frontmatter**
```
Given   the slices node in artifacts.d2 shows "02-slices/*.md" with no field detail
When    updated
Then    the slices node label or a note indicates status_updated_at is stored in
        slice frontmatter (e.g. label becomes "02-slices/*.md\n(+status_updated_at)")
        SVG re-rendered and committed alongside the .d2 source
```

**defaults/README.md — stage table**
```
Given   defaults/README.md stage table shows: implementing | tasks executing in worktree
        followed by: signoff_review | QA passed — run /review
When    updated
Then    a new row is added: qa_in_progress | QA running — run /implement to resume
        inserted between implementing and signoff_review
```

**README.md — no slate state machine prose**
```
Given   README.md does not contain prose describing the 6-state slice state machine
When    checked
Then    no change needed — don't add content just to add it
        (verify by grepping for "draft.*reviewed.*specced" — if no match, skip)
```

**Other diagrams — no impact**
```
Given   other diagrams (pause-resume.d2, concurrent-projects.d2, feedback-loop.d2,
        multi-slice-sequence.d2, legend.d2) describe project-level flow or artifact flow
When    checked for impact from the new slice states
Then    no changes needed — these diagrams don't show the slice state machine
        (verify by reading each; skip if no reference to implementing/signoff_review as
        slice states rather than project stages)
```

---

## 3. Constraints

**Must:**
- Edit `.d2` source files only. Never edit `.svg` files directly.
- Re-render SVGs after every `.d2` change using: `d2 docs/diagrams/{name}.d2 docs/diagrams/{name}.svg`
- `qa_in_progress` in `lifecycle.d2` must use the same auto-step style (grey fill/border)
  as the other automated states. It is NOT a human gate (no diamond shape).
- Check every diagram in `docs/diagrams/` for impact before deciding not to change it —
  don't skip without verifying.
- If `defaults/README.md` mentions `signoff_review` in the stage table, insert `qa_in_progress`
  immediately before it.
- Check `README.md` for any prose listing the slice state machine. If found: update it to
  include `qa_in_progress` and `signoff_review` in the sequence. If not found: no change.

**Must not:**
- Add prose to READMEs that wasn't there before — only update existing mentions.
- Change diagram layout, colors, or styles beyond what's needed for the new state.
- Edit SVG files.
- Change the legend.d2 — it describes node types, not state sequences.

**Preferences:**
- Keep the `qa_in_progress` node label consistent with the existing node naming convention
  in lifecycle.d2 (short node ID + display label matching the stage name).
- The connection label from `implementing → qa_in_progress` should read
  `/implement (QA start)` matching the style of the existing `/implement (QA pass)` label.
- The connection label from `qa_in_progress → signoff_review` should read
  `/implement (QA pass)`.

**Escalation triggers:**
- If `d2` is not installed or `d2` command fails: stop and report. Do not commit unrendered
  diagram changes.
- If any diagram other than lifecycle.d2 and artifacts.d2 contains a reference to the old
  6-state slice machine that would be misleading after this change: update it rather than
  skipping — this brief may have missed an impact. Report what you changed.

---

## 4. Done definition

Verify without reading the implementation:

1. `grep "qa_in_progress" docs/diagrams/lifecycle.d2` — returns a match showing the node
   definition and connections.

2. `d2 --dry-run docs/diagrams/lifecycle.d2` exits 0 (valid d2 syntax). If `--dry-run`
   isn't available, run `d2 docs/diagrams/lifecycle.d2 /tmp/lifecycle-check.svg` and
   check exit code.

3. `ls -la docs/diagrams/lifecycle.svg` — modified timestamp is newer than before this change.

4. `grep "status_updated_at" docs/diagrams/artifacts.d2` — returns a match.

5. `ls -la docs/diagrams/artifacts.svg` — modified timestamp is newer than before this change.

6. `grep "qa_in_progress" defaults/README.md` — returns a match in the stage table.

7. All `.d2` files pass d2 syntax check (run d2 on each, check exit code).

**Test vector — lifecycle.d2 row 3 expected connections:**
```d2
impl -> qa_ip: "/implement (QA start)" { style.font-size: 9 }
qa_ip -> sg_rv: "/implement (QA pass)" { style.font-size: 9 }
sg_rv -> done: "/review approve" { style.font-size: 9 }
sg_rv -> fb: "/review feedback" { style.font-size: 9 }
```
(Exact node IDs may differ — use whatever short IDs are consistent with the file.)

**Test vector — defaults/README.md stage table (relevant rows):**
```
| `implementing`   | Tasks executing in worktree           |
| `qa_in_progress` | QA running — run `/implement` to resume |
| `signoff_review` | QA passed — run `/review`             |
```

---

## 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Read all diagrams in `docs/diagrams/` — check each for references to `implementing`/`signoff_review` as slice states; note which need changes | Impact list | Decision made for each diagram (change or skip with reason) |
| 2 | Update `docs/diagrams/lifecycle.d2` — add `qa_in_progress` node (auto style) in row 3 between `implementing` and `signoff_review`; update connections with correct labels | lifecycle.d2 updated | `grep "qa_in_progress" docs/diagrams/lifecycle.d2` returns match |
| 3 | Re-render `docs/diagrams/lifecycle.svg` from updated source | lifecycle.svg updated | `d2` exits 0; `lifecycle.svg` modified timestamp newer |
| 4 | Update `docs/diagrams/artifacts.d2` — add `status_updated_at` indication to the slices node | artifacts.d2 updated | `grep "status_updated_at" docs/diagrams/artifacts.d2` returns match |
| 5 | Re-render `docs/diagrams/artifacts.svg` from updated source | artifacts.svg updated | `d2` exits 0; `artifacts.svg` modified timestamp newer |
| 6 | Update `defaults/README.md` stage table — insert `qa_in_progress` row between `implementing` and `signoff_review` | defaults/README.md updated | `grep "qa_in_progress" defaults/README.md` returns match |
| 7 | Check `README.md` for slice state machine prose — update if found, skip if absent | README.md checked | `grep` result + action taken documented in task output |
