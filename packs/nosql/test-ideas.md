# test-ideas — nosql

## Hot partition simulation
Load-test with traffic concentrated on one partition value (e.g., a tenant with 10x more activity). Assert latency stays within budget; assert no throttling errors leak to user.

## Read-your-writes guarantee
Write to a document, immediately read it from the same client. Assert read returns the just-written value (use strong-consistency flag where applicable; document the choice).

## Document size guard
Insert a document near the size limit + 1KB. Assert it's rejected at the API layer (your validation) before hitting the store's hard limit.

## GSI consistency expectation
Read via secondary index immediately after write. Assert either (a) you accept eventual consistency in this path and the UI shows "syncing…", or (b) you read primary first then GSI.

## Throttling fallback
Mock the store to return throttling errors for 30s. Assert app degrades gracefully (queue retries, surface "try again", don't 500).

## Migration replay (when porting from SQL)
For each enumerated access pattern, write a test that performs it against the new store. Assert latency ≤ SQL baseline × N (your tolerance).
