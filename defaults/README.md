# Orchestration system — reference

Quick orientation for what ships in `defaults/`. The canonical state, schema, and vocabulary tables live in [`.root-context/state-diagram.md`](../.root-context/state-diagram.md) — link there rather than duplicating.

---

## Commands

| Command | What it does |
|---------|-------------|
| `/plan-project` | Full planning pipeline: design interview → slicing → spec → breakdown. Commits at each user approval gate. |
| `/implement` | Pulls next slices from the queue, runs tasks sequentially, runs QA automatically. One team gate per batch. |
| `/review` | One project at a time. Iterates every signoff slice. Approve commits per slice; feedback creates dot-notation drafts; archive on full completion. |
| `/status` | Every active project at a glance — stage, next action, time in stage. |

---

## Stages and slice statuses

See [`state-diagram.md` — Slice status values](../.root-context/state-diagram.md). The same file holds the design-doc status enum and full frontmatter schemas.

---

## Vocabulary

See [`state-diagram.md` — Vocabulary](../.root-context/state-diagram.md). Locked terms: `user`, `active project`, `queue`, `transition`, `action`, `agent_type`.

---

## Folder layout

```
.claude/
  commands/
    plan-project.md     ← /plan-project
    implement.md        ← /implement
    review.md           ← /review
    status.md           ← /status
  agents/
    _common-preamble.md ← floor read-order, completion protocol, baseline exclusions
    architect.md        ← structural decisions and design review
    client-dev.md       ← frontend implementation
    quality.md          ← testing, QA, verification
    server-dev.md       ← backend implementation
    standards.md        ← code quality and convention enforcement

.orchestration/
  projects/
    {project-id}/
      01-design/        ← design doc
      02-slices/        ← slice files
      03-briefs/        ← delegation briefs (one per spec)
      04-tasks/         ← task files (slice-NN/ subdirs)
      05-qa/            ← QA reports
      observability/    ← questions, iterations, decisions logs
    done/YYYY-MM/{id}/  ← archived after /review approve
  support/
    slice.md            ← slicing instructions (called by /plan-project)
    spec.md             ← brief writing instructions
    qa.md               ← QA instructions (called by /implement)
    next-actions.md     ← shared scope reader
    status-write.md     ← shared frontmatter helper
    bdonize.md          ← voice patterns
```

---

## How files install

`/init-orchestrator` ships everything under `defaults/` to the right path in `.claude/` and `.orchestration/`. See [`init-orchestrator.md`](../init-orchestrator.md) for the canonical install inventory and version-check behavior.
