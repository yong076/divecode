# Requirements

> Generated and updated by `/divecode-spec`. Every section gets filled by interrogation, not by guessing. `TODO(decision-needed)` markers are explicit pending decisions — they must be resolved before implementation.

## Phase 1 — What & Why

**What is this?**
<one paragraph>

**Who is the user?** (be specific)
<paragraph>

**Success criteria** (concrete, measurable)
- 
- 

**Out of scope** (explicit)
- 

---

## Phase 2 — Users & Access

**Scale**
- Today: 
- 1 year: 
- 3 years: 

**Auth model**
- 

**Roles & permissions**
- 

**Geographic distribution**
- 

**Surfaces** (mobile / desktop / API / Watch / ...)
- 

---

## Phase 3 — Data shape & lifecycle

**Entities**
- 

**Read:write ratio**
- 

**Data volume**
- 

**Source of truth per entity**
- 

**Retention / deletion**
- 

**Audit trail policy**
- 

---

## Phase 4 — Access patterns & performance

**Latency budget per endpoint**
- 

**Throughput** (peak / average req/s)
- 

**Hot keys / hot partitions identified**
- 

**Caching strategy** (or "no caching, with reason")
- 

---

## Phase 5 — Failure modes & consistency

**Dependency failure behavior**
- DB down: 
- Cache down: 
- External service down: 

**Consistency per write path**
- 

**Idempotency**
- 

**Concurrent edit handling**
- 

**Backup RPO / RTO**
- 

---

## Phase 6 — Security & compliance

**PII fields**
- 

**Encryption** (at rest / in transit)
- 

**Rate limiting / abuse prevention**
- 

**Audit log requirements**
- 

**Compliance regimes**
- 

---

## Phase 7 — Operations & observability

**On-call ownership**
- 

**Key metrics**
- 

**Log levels & cardinality**
- 

**Tracing**
- 

**Deployment strategy**
- 

**Migration path** (if replacing existing)
- 

---

## UX decisions (populated by `/divecode-design`)

<one section per screen>

---

## Pending decisions

<list every `TODO(decision-needed)` here for visibility>
