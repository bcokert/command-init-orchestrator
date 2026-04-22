**Type:** Task (AI agent)
**Date:** 2026-04-21

---

### 1. Intent

There's a required re-run between spec and breakdown with no quality benefit — the slicing review already caught the major issues, and the spec is generated directly from the slice. The gate adds friction and a potential confusion point (operators sometimes re-run and expect to see output, but only get a "spec complete" gate). Removing the gate makes spec → breakdown a single uninterrupted flow. Both remain crash-resumable via slice frontmatter status fields (`speccing` and `breakdown`).

Only `defaults/commands/plan-project.md` changes. Version `2.9.0 → 2.10.0`.

---

### 2. Observable outcomes

**Atomic flow**
```
Given plan-project advancing from slice approval to speccing
When spec writing completes
Then breakdown runs immediately in the same run — no gate shown, no re-run needed
```

**No spec gate message shown**
```
Given plan-project writing a spec
When spec completes
Then the spec_review gate message is not shown
And breakdown begins without waiting for operator input
```

**Crash recovery — speccing**
```
Given a crash mid-spec (slice status: speccing, no brief file exists)
When plan-project re-runs
Then it re-runs spec idempotently (brief written from scratch), then proceeds to breakdown
```

**Crash recovery — breakdown**
```
Given a crash mid-breakdown (slice status: breakdown, partial task files exist)
When plan-project re-runs
Then it deletes all partial task files and regenerates from the breakdown table
```

**Status sequence preserved**
```
Given a slice progressing through spec + breakdown
When both complete successfully
Then slice status transitions: review → speccing → breakdown → tasks_ready
Each intermediate status is written to disk (crash recovery points)
```

---

### 3. Constraints

**Must:**
- Remove the spec gate ("Wait here") from Phase 6 — after spec is written, flow continues directly to Phase 7 breakdown.
- Remove the spec_review gate message entirely. Do not show it.
- Phase 7 (breakdown) still runs as before — it just gets called immediately after Phase 6 instead of on the next plan-project run.
- Crash resume for `speccing` status: if slice is `speccing` and brief file is missing → re-run spec from scratch, then continue to breakdown. If brief file exists → skip spec, go straight to breakdown.
- Crash resume for `breakdown` status: if slice is `breakdown` and task files exist → delete all and regenerate. If no task files → run breakdown from scratch.
- Slice status transitions still happen at each phase: `speccing` written when spec starts, `breakdown` written when breakdown starts, `tasks_ready` written when breakdown completes.
- Bump version: `2.9.0 → 2.10.0`.

**Must not:**
- Remove Phase 7 or the breakdown logic — only the gate between Phase 6 and Phase 7.
- Skip writing intermediate status values (`speccing`, `breakdown`) — they exist for crash recovery.
- Touch any file outside `defaults/commands/plan-project.md`.

**Escalation triggers:**
- If removing the spec gate changes the Phase 6 "On entry" commit behavior: the commit for "Spec approved" must still happen at the correct point. Report if the commit sequence needs adjustment.

---

### 4. Done definition

- Read plan-project.md: no spec_review gate message. No "Wait here" after Phase 6.
- Read plan-project.md: Phase 6 flows directly into Phase 7 in the same run.
- Read plan-project.md: crash resume paths for `speccing` and `breakdown` statuses are present.
- Read plan-project.md: `speccing`, `breakdown`, `tasks_ready` are still written to slice frontmatter at the correct points.
- Version reads `2.10.0`.

---

### 5. Breakdown

| # | Step | Deliverable | Done signal |
|---|------|-------------|-------------|
| 1 | Remove spec gate from Phase 6 | Gate message and "Wait here" removed; Phase 6 flows into Phase 7 | Read file: no spec_review gate, no Wait here after Phase 6 |
| 2 | Verify crash resume paths for speccing and breakdown | Both crash paths present and correct | Read file: speccing crash path (re-run spec) and breakdown crash path (delete+regenerate) both explicit |
| 3 | Version bump and coherence pass | Version `2.10.0`; status sequence correct; no contradictions | Frontmatter reads `2.10.0`; speccing/breakdown/tasks_ready all written in sequence |
