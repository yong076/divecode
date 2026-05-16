# example-patterns — nosql

## Partition key with built-in spread

```python
# Bad: timestamp prefix concentrates writes on one partition per hour
def order_pk(order_id):
    return f"{datetime.utcnow().strftime('%Y%m%dT%H')}#{order_id}"

# Better: random shard prefix spreads writes across partitions
import hashlib
def order_pk(order_id, shard_count=10):
    shard = int(hashlib.md5(order_id.encode()).hexdigest(), 16) % shard_count
    return f"shard{shard:02d}#{order_id}"
```

## DynamoDB single-table — access patterns documented FIRST

```text
# Before any schema work, write out:
Access pattern 1: get user by id           → PK=USER#{id}    SK=PROFILE
Access pattern 2: list user's orders       → PK=USER#{id}    SK begins_with ORDER#
Access pattern 3: get order by id          → PK=ORDER#{id}   SK=METADATA
Access pattern 4: list orders by status    → GSI1PK=STATUS#{status}  GSI1SK={created_at}
```

If you can't list all access patterns upfront, single-table design is the wrong choice.

## Transactional write across documents (DynamoDB)

```python
client.transact_write_items(TransactItems=[
    {'Update': {'TableName': 'inventory', 'Key': {'sku': sku},
                'UpdateExpression': 'SET stock = stock - :n',
                'ConditionExpression': 'stock >= :n',
                'ExpressionAttributeValues': {':n': qty}}},
    {'Put': {'TableName': 'orders', 'Item': order_item,
             'ConditionExpression': 'attribute_not_exists(order_id)'}},
])
# Either both succeed atomically or both fail. Costs 2x writes.
```

## Read-your-writes with strong consistency flag

```python
# DynamoDB
response = table.get_item(Key={'user_id': uid}, ConsistentRead=True)
# Costs 2x and only works on primary key, not GSI.
```
