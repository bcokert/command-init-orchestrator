# Decision log
<!-- Format: ## YYYY-MM-DD HH:MM — Decision. Why. Rejected: alternatives. -->

## 2026-04-27 — Server is fully deterministic — no LLM, no SDK, no tokens. Why: clean separation, reliable/fast/testable/cheap, agents already handle LLM work. Rejected: hybrid server-LLM.

## 2026-04-27 — Go server, sqlite for state/logs, filesystem (later S3) for documents. Why: matches stack; sqlite ports to Postgres; filesystem migrates to S3. Rejected: pure-DB blob storage; pure-filesystem state.

## 2026-04-27 — Action-focused API with REST elements. POST /transition/{action}, GET /projects/{id}, GET /slices/{id}, GET /graph/state. Why: maps to edges-as-actions; agent always knows next legal actions. Rejected: pure-REST resource model; pure-action without GETs.

## 2026-04-27 — Install at ~/.orchestrator/ (configurable); per-repo gitignored .orchestration.env for connection. Why: single folder, agent agnostic to local-vs-remote. Rejected: scattered paths; hardcoded URL.

## 2026-04-27 — Optimistic concurrency via preconditions; 409 on stale transitions. Why: simpler than leases; no timeouts. Rejected: pessimistic locks; first-writer-wins.

## 2026-04-27 — Server-managed queue; agents poll for next task; async-hardened task locks. Why: one source of truth; prevents double-execution. Rejected: client-side queue logic; file-based locks.

## 2026-04-27 — Slice plan: status → artifacts → /status + UI → observability. Why: status is smallest valuable thing; observability lands on stable surface. Rejected: walking skeleton; full design phase first.

## 2026-04-27 — Fail loud on server unreachable; no retries/buffering for now. Why: silent buffering hides bugs. Rejected: client-side cache + replay.

## 2026-04-27 — Existing done/ archives stay file-based. Why: migration cost dwarfs value. Rejected: full migration; auto-conversion.

## 2026-04-27 — Same repo for now; rename later when it's the whole system. Why: avoids early naming churn. Rejected: split into separate repos now.

## 2026-04-27 — This repo dogfoods existing orchestrator until new system is stable. Why: use the working system to build the next one. Rejected: hard cutover mid-build.
