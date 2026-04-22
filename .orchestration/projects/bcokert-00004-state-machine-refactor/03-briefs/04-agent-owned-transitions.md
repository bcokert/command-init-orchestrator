**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

Operators currently have to manually edit `status: reviewed` in slice frontmatter to advance a slice to spec. The agent is supposed to own all state transitions; requiring human frontmatter editing is a leaky abstraction. This slice removes that requirement from two places: the `slice.md` slicing support file (which instructs the agent on how to produce slices), and `plan-project.md` (which currently tells the operator to set the field themselves at the slicing gate). After this change, the agent asks for approval in conversation and writes the status transition itself.

Files: `defaults/commands/slice.md`, `defaults/commands/plan-project.md`.

---

### 2. Observable outcomes

```
Given slice.md containing "The human sets status: reviewed when a slice is ready to spec"
When the update is applied
Then that instruction is removed; no instruction tells the human to edit frontmatter
```

```
Given plan-project.md slicing gate message telling the operator to "set status: reviewed"
When the update is applied
Then the gate message asks for approval in conversation; no mention of editing frontmatter
```

```
Given plan-project.md routing logic checking for status: reviewed
When a slice has status: review (new value)
Then it is treated as eligible for spec — same as reviewed
```

```
Given a slice file with status: reviewed (old value, existing project)
When plan-project.md routes on it
Then it is treated as equivalent to review — no failure, no migration needed
```

---

### 3. Constraints

**Must:**
- Remove "The human sets `status: reviewed` when a slice is ready to spec" from `defaults/commands/slice.md`. Replace with wording that the agent asks for approval and writes the status.
- Update `defaults/commands/slice.md` version: `1.0.0 → 1.1.0`.
- Update the slicing gate in `plan-project.md`: remove "set `status: reviewed`" instruction; replace with "run /plan-project when ready" (agent will confirm approval in conversation and write status).
- Update plan-project.md routing logic in Phase 0 Step 3: accept both `review` and `reviewed` as eligible for spec. Both route the same way.
- Update plan-project.md frontmatter description to remove any reference to human-set status fields.
- Bump plan-project.md version: `2.6.0 → 2.7.0`.

**Must not:**
- Touch any file outside `defaults/commands/slice.md` and `defaults/commands/plan-project.md`.
- Change the actual slicing output format — only the status-setting instruction changes.

**Escalation triggers:**
- If the routing logic in plan-project.md checks status values in more places than Phase 0 Step 3 (e.g., Phase 6 on entry): update all occurrences; report how many were found.

---

### 4. Done definition

- Read slice.md: no instruction telling the human to set frontmatter. Version `1.1.0`.
- Read plan-project.md: slicing gate message does not mention "set status: reviewed". Version `2.7.0`.
- Read plan-project.md: routing logic accepts both `review` and `reviewed` as spec-eligible.
- No other files changed.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Update slice.md: remove human-sets-status instruction, bump version | Instruction removed; version `1.1.0` | Read file: no "human sets" instruction; version `1.1.0` |
| 2 | Update plan-project.md: gate message and routing for review/reviewed | Gate message updated; routing accepts both values; version `2.7.0` | Read file: gate has no "set status" instruction; routing has both values; version `2.7.0` |
