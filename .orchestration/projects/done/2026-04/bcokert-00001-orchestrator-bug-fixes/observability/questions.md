# Questions log
<!-- Format: ## YYYY-MM-DD HH:MM — [open|answered] Question text -->

## 2026-04-23 10:00 — [answered] What other bugs are in scope beyond the agent path issues?
- Full list from Bdon: plan-project commit-before-confirmation, implement multi-slice behavior, review.md git add -A footgun, plan-project Phase 5 crash resume gap, review.md feedback path deadlock.

## 2026-04-23 10:00 — [answered] What should be done with lead.md?
- Remove it. System orchestrates agents directly via implement.md. Evolve later.

## 2026-04-23 10:00 — [answered] What should be done with learn.md and the lessons/ concept?
- Clean it up. Remove from defaults. Add learning features to TODO.md. Strip the reference from standards.md.

## 2026-04-23 10:00 — [answered] What is the CLAUDE.md sync rule intent?
- Broader than agents only: any change to any orchestration artifact should trigger a cohesion pass over all related artifacts.

## 2026-04-23 10:30 — [answered] implement.md — behavior change or docs fix?
- Both. Run all tasks_ready slices in sequence. User controls scope by how many slices they break down before running /implement. Docs and behavior must align.

## 2026-04-23 10:30 — [answered] review.md git staging scope?
- Auto-stage known paths (.orchestration/ + source/test files), ask if really unsure. Show what's being staged.
