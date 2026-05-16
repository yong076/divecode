# failure-modes — nosql

## Hot partition kills throughput
Partition key has low cardinality or concentrates writes on one physical partition. DynamoDB throttles; Cassandra latency spikes; Mongo shard saturates.

**Detection signal**: per-partition metrics show one partition at 100% while others idle.

## Eventually consistent reads break "read-your-writes"
User writes, immediately reads. Read hits a replica that hasn't replicated yet. Their write appears to disappear; they click again and create a duplicate.

**Detection signal**: "I clicked X and it's gone" reports; duplicate side effects within seconds.

## Cross-document atomicity nobody thought about
User profile and preferences are separate documents. Crash midway → profile updated, preferences not. Order placed in one doc, inventory decrement in another, payment crash → inventory off.

**Detection signal**: reconciliation jobs finding mismatches between related entities.

## Document size limit silently hit
Mongo: 16MB per document. DynamoDB: 400KB per item. Unbounded array grows over months. Suddenly writes fail.

**Detection signal**: `BSONObjectTooLarge` or `ValidationException: Item size has exceeded the maximum` in production logs.

## GSI eventual consistency surprises strong-read code
Code assumes secondary index reads are strongly consistent. They're not (DynamoDB GSI default). Stale reads via the index until propagation.

**Detection signal**: queries via secondary key inconsistent with primary key queries.

## Throttling burst capacity exhausted
On-demand mode handles burst, then throttles when credits run out. Or provisioned mode sized for average load gets hit by spike.

**Detection signal**: `ProvisionedThroughputExceededException` correlating with traffic peaks.

## Migration without access-pattern rethink
Team migrates to DynamoDB single-table but kept a relational mental model. Every page render needs 5 separate queries because access patterns weren't enumerated upfront.

**Detection signal**: latency worse than the SQL it replaced; cost much higher than projected.
