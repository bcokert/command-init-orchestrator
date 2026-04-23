# Decision log
<!-- Format: ## YYYY-MM-DD HH:MM — Decision. Why. Rejected: alternatives. -->

## 2026-04-23 11:00 — Remove lead.md rather than update it. The current system drives execution via implement.md without a lead agent; rewriting it would be speculative. Rejected: update lead.md to describe the current flow.

## 2026-04-23 11:00 — Remove commit.md, learn.md, migrate.md from defaults. Dead files in defaults are noise. Rejected: leave them with status: deferred comment.

## 2026-04-23 11:00 — implement.md runs ALL tasks_ready slices, not just one. User controls scope by how many slices they break down before running /implement. Rejected: keep one-slice-per-run.

## 2026-04-23 11:00 — review.md smart staging: auto-stage known paths (.orchestration/projects/{id}/ + source/test files), prompt for anything else. Rejected: always require explicit confirmation; continue using git add -A.

## 2026-04-23 11:00 — Plan-project Phase 5 crash resume: check design doc status on entry, run approveAndCommit if status: review. Minimal fix, no Phase 4/5 reorganization. Rejected: move approveAndCommit into Phase 0 routing.
