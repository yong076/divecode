# Performance checklist

Surface whenever the user mentions latency, throughput, "fast", "real-time", or any request/response system.

## Targets — be concrete
- [ ] p50 latency target? p99? p99.9?
- [ ] Throughput peak (req/s)? Average?
- [ ] Acceptable error rate?
- [ ] Cold-start budget? (serverless / lambda)

## N+1 and fanout
- [ ] Every list endpoint loads related data in a single query / batch?
- [ ] ORM lazy-load disabled or audited?
- [ ] GraphQL: DataLoader / batching configured?
- [ ] Microservices: any endpoint that fans out to >5 downstream calls? (latency = max of those + serialization overhead)

## Caching layers — explicit
- [ ] Browser cache (Cache-Control headers)?
- [ ] CDN cache?
- [ ] App-level cache (Redis/Memcached)?
- [ ] Query cache?
- [ ] Each layer: TTL, invalidation, stampede mitigation (see redis.md)

## Pagination
- [ ] Cursor-based for anything > 1000 items?
- [ ] Default page size sane (not 10000)?
- [ ] Total count expensive — needed at all?

## Compression
- [ ] Gzip/brotli on HTTP responses?
- [ ] DB-level compression for cold data?
- [ ] Wire protocol compression (gRPC)?

## Connection management
- [ ] HTTP keepalive enabled both sides?
- [ ] Connection pool sized correctly?
- [ ] DNS lookups cached?
- [ ] TLS session resumption?

## Async / backpressure
- [ ] Long-running work moved to background queue?
- [ ] Queue depth bounded? Reject-on-full vs block?
- [ ] Backpressure signaled to upstream?
- [ ] Timeout cascade — each layer has shorter timeout than its caller?

## Database
- [ ] Slow query log monitored?
- [ ] Query timeout per request?
- [ ] Read replicas for read-heavy workload?
- [ ] Indexes covering hot queries? (verified with EXPLAIN)

## Hot path optimizations
- [ ] Allocation-free on hot path? (profiled, not assumed)
- [ ] String concatenation in loops avoided?
- [ ] JSON parsing — is the same payload parsed twice anywhere?

## Memory
- [ ] Bounded buffers everywhere? (no `read_all` of arbitrary user input)
- [ ] Memory limit per request?
- [ ] GC tuning if relevant?

## Observability for perf
- [ ] Latency histogram per endpoint (not just average)?
- [ ] Tail latency tracked (p99, p99.9)?
- [ ] Tracing for cross-service latency?
- [ ] Apdex or similar SLO metric?

## Frontend (if applicable)
- [ ] Bundle size budget? (and CI gate)
- [ ] Code splitting per route?
- [ ] Image optimization (WebP/AVIF, responsive `srcset`)?
- [ ] Core Web Vitals targets — LCP, INP, CLS?
- [ ] Critical CSS inline?

## Load testing
- [ ] Load test exists for hot endpoints?
- [ ] Run at 2× projected peak?
- [ ] Failure modes characterized (what breaks first)?
