# NoSQL checklist

Surface when DynamoDB / Cassandra / Mongo / Firestore / any non-relational store is mentioned.

## Pick the right store for the question
- [ ] Why NoSQL here? ("scale" alone is not an answer — what specifically about SQL doesn't fit?)
- [ ] Read pattern fits the store's data model? (DynamoDB: PK access only; Mongo: rich queries; Cassandra: time-series; ...)

## Partition / shard key
- [ ] **Partition key chosen for read patterns first.** What queries are common?
- [ ] Hot partitions — is any key going to receive disproportionate traffic?
- [ ] Cardinality of partition key high enough? (low cardinality = hot partition)
- [ ] If partition key changes — how do you migrate? (usually: you can't easily)

## Consistency
- [ ] Strong vs eventual consistency for each read path?
- [ ] Quorum settings? (Cassandra: R + W > N for strong; DynamoDB: ConsistentRead flag)
- [ ] Read-your-writes guarantee needed? (often surprisingly hard with eventual consistency)

## Secondary indexes
- [ ] GSI / LSI strategy (DynamoDB)?
- [ ] Eventually consistent secondary indexes — does that matter?
- [ ] Write amplification from index updates considered?

## Document modeling (Mongo / DynamoDB single-table)
- [ ] Embed vs reference — based on access pattern, not "what feels right"
- [ ] Document size limit awareness (16MB Mongo, 400KB DynamoDB item)
- [ ] Unbounded arrays inside documents? (slow query, hits size limit eventually)
- [ ] Single-table design (DynamoDB) — access patterns enumerated upfront?

## TTL / expiry
- [ ] TTL field configured? Eventual expiry latency tolerated?
- [ ] What if the item expires mid-read? (DynamoDB: still readable for ~48h after TTL)

## Backup / restore
- [ ] Point-in-time recovery enabled?
- [ ] Cross-region replication?
- [ ] Backup of GSIs / indexes?

## Capacity
- [ ] Provisioned vs on-demand?
- [ ] Throttling behavior — auto-retry with backoff in SDK? Surfaced to user?
- [ ] Burst capacity assumptions?

## Multi-document atomicity
- [ ] Is there any operation that needs atomicity across documents?
- [ ] Transactions (Mongo 4+, DynamoDB) understood — including their cost (2x WCU)?
- [ ] Saga / compensating transactions instead?

## Schema evolution
- [ ] Mixed-version documents in collection — handler tolerant?
- [ ] Migration strategy for renaming/restructuring fields?
- [ ] Backward-compatible writes during rolling deploy?
