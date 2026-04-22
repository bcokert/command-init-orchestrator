**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

The `/status` command has two bugs and outdated state tables. First: it globs `projects/*/` with a trailing slash, which the Glob tool silently fails to match — all projects disappear from the multi-project view. Second: projects in the design phase (design doc exists, no `02-slices/` directory yet) show as blank headers or nothing at all. Third: the state abbreviation and bucket tables reference `reviewed` and `specced` but are missing `review`, `speccing`, and `breakdown` — states that exist in the system since the state machine redesign.

This task updates `defaults/commands/status.md` only. The local `.claude/commands/status.md` is installed separately via `/init-orchestrator` and must not be touched here.

---

### 2. Observable outcomes

**Glob fix**
```
Given a repo with two project directories in .orchestration/projects/
When /status is run with no arguments
Then both projects appear in the output
```

**Design-phase display**
```
Given a project with 01-design/design-01.md (status: review) but no 02-slices/ directory
When /status is run
Then the project shows: **{id}** · {MMM D} · design: review  →  **`/plan-project`**
```

```
Given a project with 01-design/design-01.md that has no status: field
When /status is run
Then the project shows design: in_progress (not an error)
```

**State table — new states display correctly**
```
Given a slice with status: speccing
When /status is run
Then the slice row shows abbrev `speccing` with no emoji prefix, routed to /plan-project
```

```
Given a slice with status: review
When /status is run
Then the slice row shows 👤 `reviewed→review`, routed to /plan-project
```

**Legacy alias handling**
```
Given a slice with status: reviewed (old value)
When /status is run
Then it renders identically to a slice with status: review — same bucket (👤), same routing (/plan-project)
```

```
Given a slice with status: specced (old value)
When /status is run
Then it renders in the ⏳ bucket, routed to /plan-project
```

**No-projects case unchanged**
```
Given no active projects (all archived under done/)
When /status is run
Then output is: "no active projects — run /plan-project to start one"
```

**Empty project directory**
```
Given a project directory with no 01-design/ and no 02-slices/
When /status is run
Then that directory is excluded from output entirely (no header, no row)
```

---

### 3. Constraints

**Must:**
- Change glob from `projects/*/` to `projects/*` in Phase 2 step 1.
- Filter glob results to directories only (or directories containing known subdirectories). A plain file in the projects/ dir must not be treated as a project.
- Add design-phase display: when a project has `01-design/design-01.md` but no `02-slices/` directory, show the design-phase row format (not the slice-based format).
- Design-phase row format: `**{id}** · {MMM D} · design: {design_status}  →  **\`/plan-project\`**`
- Missing `status:` in design doc → treat as `in_progress`.
- Design-phase projects sort by `date:` from design doc, consistent with the general sort order.
- Rewrite bucket table, abbreviation table, and routing table to the exact values in the design doc (reproduced below).
- Treat `reviewed` as an alias for `review` in all logic (bucket, emoji, routing, `prev→curr` derivation).
- Treat `specced` as routing to `/plan-project` in ⏳ bucket. It's a legacy value; handle it without error.
- Bump version: `3.3.0` → `3.4.0` (minor bump for behavior changes).

**Must not:**
- Touch `.claude/commands/status.md` (local installed copy — updated separately via `/init-orchestrator`).
- Touch any other file.
- Write, edit, or delete any non-target file.

**Preferences:**
- Keep existing prose and structure where unchanged. Only modify the sections that need updating.
- Inline the alias note (e.g. "`reviewed` treated as `review`") near the abbreviation table, not in a separate section.

**Escalation triggers:**
- The design doc specifies the exact table contents; if there is a conflict between the slice, design doc, and state-diagram.md, stop and report — do not guess.

---

### 4. Done definition

- Running `/status` on a repo with two projects (one design-phase, one with slices) shows both in the output. Verified by reading the command file and confirming the glob and design-phase logic are present.
- The three tables (bucket, abbreviation, routing) exactly match the values below. Verified by reading the saved file.
- `reviewed` appears as an alias note near the abbreviation table; `specced` is handled in routing.
- Version field in frontmatter reads `3.4.0`.
- No changes to any file other than `defaults/commands/status.md`.

**Target table values (from design doc):**

Bucket table:
| Emoji | Slice states |
|-------|-------------|
| ✅ | `done` |
| 🤖 | `implementing`, `qa_in_progress` |
| 👤 | `draft`, `review`, `signoff_review` |
| ⏳ | `speccing`, `breakdown`, `tasks_ready` |

State abbreviation table:
| Full state | Abbrev | Emoji prefix |
|------------|--------|--------------|
| `draft` | `draft` | 👤 |
| `review` | `review` | 👤 |
| `speccing` | `speccing` | *(none)* |
| `breakdown` | `bkdn` | *(none)* |
| `tasks_ready` | `ready` | *(none)* |
| `implementing` | `impl` | 🤖 |
| `qa_in_progress` | `qa` | 🤖 |
| `signoff_review` | `signoff` | 👤 |

Note: `reviewed` is a legacy alias for `review`. `specced` is a legacy value — routes to `/plan-project`, bucket ⏳.

Command routing table:
| State | Command |
|-------|---------|
| `draft` | `/plan-project` |
| `review` | `/plan-project` |
| `speccing` | `/plan-project` |
| `breakdown` | `/plan-project` |
| `tasks_ready` | `/implement` |
| `implementing` | `/implement` |
| `qa_in_progress` | `/implement` |
| `signoff_review` | `/review` |

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Fix Phase 2 glob and add design-phase display | `projects/*/` → `projects/*`; filter to dirs; add design-phase row logic with `in_progress` fallback | Read file: glob is `projects/*`, design-phase branch present, fallback present |
| 2 | Rewrite the three state tables | Bucket, abbreviation, and routing tables replaced in full with target values above | Read file: all three tables match target exactly, including emoji assignments |
| 3 | Add alias handling for `reviewed` and `specced` | Inline note near abbreviation table; routing logic handles both legacy values without error | Read file: alias note present; routing table or note handles `reviewed` → `review` and `specced` → ⏳ `/plan-project` |
| 4 | Bump version and coherence pass | Version `3.3.0` → `3.4.0`; full read-through for internal contradictions | Frontmatter reads `version: 3.4.0`; no section references removed states without alias note |
