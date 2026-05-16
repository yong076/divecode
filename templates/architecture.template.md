# Architecture

> Generated and updated by `/divecode-arch`. Every section is the result of explicit decision, not default. Drift accepted during `/divecode-implement` must be recorded back here.

## Phase A — Module / package structure

**Top-level modules**
- 

**Dependency direction**
```
<draw it — e.g. UI → service → repo → DB>
```

**Public surfaces per module**
- 

**Cross-cutting concerns location**
- Logging: 
- Metrics: 
- Auth context: 

---

## Phase B — Domain model & DTOs

### Entity: `<name>`
- **Domain type**: 
- **Persistence type**: (same / different — reason: )
- **Wire DTO**: (same / different — reason: )
- **PK strategy**: 
- **Concurrency control**: (none / optimistic via `version` / pessimistic)
- **Soft-delete**: (yes / no — reason: )
- **Indexed columns**: 
- **Evolution policy**: 

---

## Phase C — Transaction boundaries

### Write path: `<name>`
- **Starts at**: 
- **Ends at**: 
- **Isolation level**: 
- **Lock granularity**: 
- **Outside the tx**: (emails, notifications, ...)
- **Retry policy on serialization failure**: 

---

## Phase D — Cache strategy

**What is cached**
- 

**Per cache entry**
- Key: 
- TTL: 
- Invalidated by: 
- Stampede mitigation: 

**Cache outage behavior**
- 

---

## Phase E — Error model

**Error categories**
- 

**User-visible vs logged-only**
- 

**Retry policy by category**
- 

**Circuit breakers / bulkheads**
- 

**Idempotency keys**
- 

---

## Phase F — Observability

**Trace ID propagation**
- 

**Metrics**
- 

**Log levels per category**
- 

**Structured log fields** (always present)
- 

**Alerts**
- 

---

## Accepted drift (recorded during implementation)

<each entry: where, what was changed vs original arch, why, when>
