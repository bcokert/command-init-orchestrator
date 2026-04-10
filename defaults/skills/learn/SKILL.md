---
name: learn
version: 1.0.0
description: |
  Reviews completed task files and QA reports, extracts lessons worth keeping, and writes them to .orchestration/root-context/lessons/. Always proposes before writing.
triggers:
  - /learn
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - AskUserQuestion
---

# Learn — Extract and Record Lessons

Your job is to review completed work, find what's worth remembering, and write it into the lessons layer — separate from the user-curated root context.

---

## Phase 0 — Load inputs

If a spec-id was passed as argument, focus on that spec. If not, check `.orchestration/dashboard/summary.md` for recently completed specs and ask which one to review.

Read:
- All task files with `status: done` in `.orchestration/specs/tasks/{spec-id}/`
- QA report at `.orchestration/dashboard/{spec-id}-qa.md` if it exists
- The spec itself at `.orchestration/specs/briefs/` for what was originally intended

---

## Phase 1 — Extract lessons

Look for things that weren't obvious from the spec but became clear during execution:

**Patterns that worked** — something done well that should be repeated on future specs
**Patterns to avoid** — something that caused friction, rework, or was wrong
**Decisions made during execution** — architectural or implementation choices not in the original spec
**Spec gaps** — things the spec should have specified but didn't
**Surprises** — anything not anticipated

Don't duplicate what's already in the spec, DECISIONS.md, or previous lesson files.

Group your findings and propose them to Bdon before writing:

> "Found N lessons from {spec-id}. Here's what I'd record: [list with rationale]. Anything to add, drop, or change?"

Wait for confirmation before writing.

---

## Phase 2 — Write lessons

After Bdon approves, write:

Path: `.orchestration/root-context/lessons/YYYY-MM-DD-{spec-id}.md`

```markdown
---
date: YYYY-MM-DD
spec: {spec-id}
type: lessons
---

# Lessons — {Spec Title}

## Patterns to follow

- **{pattern name}:** {what it is and why it works — specific enough to apply next time}

## Patterns to avoid

- **{pattern name}:** {what went wrong and why — specific enough to recognize next time}

## Decisions made during execution

### {Decision title}
**What:** {what was decided}
**Why:** {the constraint or discovery that drove it}
**Apply when:** {conditions under which this applies}

## Spec gaps

- {what was missing}: {what it meant in practice and how to write it better next time}

## Surprises

- {what happened}: {why it matters for future work}
```

Omit sections where there's nothing to say.

---

## Phase 3 — Update dashboard

Add a row to the "Learning" section in `.orchestration/dashboard/summary.md` (create the section if absent):

```markdown
## Learning

| Date | Spec | Lessons |
|------|------|---------|
| {date} | {spec-id} | `.orchestration/root-context/lessons/{filename}` |
```

---

## Behavior rules

- Always propose before writing. Bdon curates what gets kept.
- Lessons in `.orchestration/root-context/lessons/` are agent-facing. Don't touch `.root-context/` at the project root.
- Only record what was discovered during execution. Not what was in the spec. Not what's already in DECISIONS.md.
- One lesson file per spec review. Update it if /learn is run again on the same spec.
