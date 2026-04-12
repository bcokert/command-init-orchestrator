---
spec: specs/briefs/project-sequencing-and-status/09-metrics-quality.md
slice: 09
step: 5
title: Add partial-timestamp variant to fixture
status: todo
depends_on: [04-write-checklist.md]
agent_type: architect
assigned_at: null
completed_at: null
---

## Work

Add a partial-timestamp scenario to the fixture: remove one transition timestamp from `status.md` (e.g. remove the `timestamp` field from the `implementing` transition).

Then verify that `/status` run against the fixture handles it gracefully:
- The metric that depends on that timestamp shows "unknown" (or equivalent) rather than crashing
- All other metrics still display correctly

This is a manual check — run `/status fixture-00001-metrics-test` and observe the output. Document the result in the checklist under a new "Resilience" section:

```markdown
## Resilience

| Scenario | Expected | Actual | Result |
|----------|----------|--------|--------|
| Missing transition timestamp | elapsed: unknown | ... | pass/fail |
```

If it crashes: fix `/status` Phase 2 scan to handle missing timestamps gracefully, then re-verify.

## Done signal

Fixture has a partial-timestamp variant. `/status` against it shows "unknown" for the affected metric without crashing. Resilience section present in checklist.
