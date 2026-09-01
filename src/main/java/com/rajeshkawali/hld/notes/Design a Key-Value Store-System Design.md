# Design a Key-Value Store — System Design Interview Notes

## 1. Problem

Design a distributed Key-Value Store like:

```text
key → value
```

Example:

```text
user:1001 → {"name":"John","age":30}

session:abc123 → user:1001

product:123 → {"name":"Laptop","price":1000}
```

Main operations:

```text
PUT(key, value)
GET(key)
DELETE(key)
```

---

# 2. Requirements

### Functional

- PUT
- GET
- DELETE
- Update existing value
- Optional TTL/expiration

### Non-Functional

- Low latency
- High availability
- Horizontal scalability
- Durability
- Fault tolerance
- Handle very large data

---

# 3. Basic Architecture

```text
                 Client
                   |
                   v
              Load Balancer
                   |
             +-----+-----+
             |     |     |
            Node  Node  Node
             |     |     |
             +-----+-----+
                   |
             Distributed Storage
```

Each node stores a portion of the keys.

---

# 4. How Do We Decide Which Node Stores a Key?

Use **consistent hashing**.

```text
hash(key)
    ↓
Hash Ring
    ↓
Responsible Node
```

Example:

```text
user:1001
    ↓
hash()
    ↓
Node 2
```

So:

```text
user:1001 → Node 2
```

### Why Consistent Hashing?

If a node is added/removed, only a portion of keys need to move.

```text
Add Node
   ↓
Small amount of data movement
```

---

# 5. Virtual Nodes

One physical node can have multiple positions on the hash ring.

```text
Node A → A1, A2, A3
Node B → B1, B2, B3
Node C → C1, C2, C3
```

### Advantages

- Better load distribution
- Reduces hot spots
- Easier node addition/removal

---

# 6. Replication

Don't store data on only one node.

Example:

```text
Key = user:1001

Primary → Node A
Replica → Node B
Replica → Node C
```

If Node A fails:

```text
Node A ❌
   ↓
Node B / Node C
```

can serve the data.

### Replication Factor

For example:

```text
RF = 3
```

means each key has 3 copies.

---

# 7. Write Flow

```text
PUT(user:1001, value)
          |
          v
     Hash the key
          |
          v
    Find primary node
          |
          v
       Node A
       /     \
      v       v
   Node B   Node C
   Replica  Replica
```

After successful replication:

```text
PUT → Success
```

---

# 8. Read Flow

```text
GET(user:1001)
       |
       v
   Hash key
       |
       v
   Node A
       |
       v
   Return value
```

If Node A is unavailable:

```text
Node A ❌
   ↓
Replica Node B
   ↓
Return value
```

---

# 9. Consistency

Important interview question:

> What happens if replicas don't have the same value?

There are two common approaches.

### Strong Consistency

Read always returns the latest successful write.

**Adv:**
- Correct/latest data

**Disadv:**
- Higher latency
- Lower availability during failures

### Eventual Consistency

Replicas become consistent eventually.

**Adv:**
- High availability
- Lower latency

**Disadv:**
- A read may temporarily return an older value

---

# 10. Quorum

For replication factor:

```text
N = 3
```

We can use:

```text
W = Write quorum
R = Read quorum
```

If:

```text
W + R > N
```

then read and write quorums overlap.

Example:

```text
N = 3
W = 2
R = 2

2 + 2 > 3
```

So at least one node participating in the read should have seen the latest write, assuming the system's quorum/consistency model is implemented appropriately.

### Trade-off

```text
Higher W/R
   ↓
Stronger consistency
   ↓
Higher latency / lower availability
```

---

# 11. Storage Engine

How should each node store the data?

A common approach:

```text
Client
  ↓
MemTable
  ↓
WAL
  ↓
SSTables
  ↓
Disk
```

---

# 12. Write-Ahead Log (WAL)

Before writing data to the main storage:

```text
PUT
 ↓
WAL
 ↓
Memory
```

WAL provides durability.

If the server crashes:

```text
Crash
 ↓
Read WAL
 ↓
Recover recent writes
```

### Advantage

Prevents losing acknowledged writes because of a process/server crash, assuming the WAL is durably persisted before acknowledgement.

---

# 13. MemTable

Recent writes are stored in memory.

```text
PUT
 ↓
WAL
 ↓
MemTable
```

When MemTable becomes full:

```text
MemTable
   ↓
Flush
   ↓
SSTable on Disk
```

---

# 14. SSTable

SSTable = Sorted String Table.

Data is stored sorted by key:

```text
apple
banana
cat
dog
user:1001
user:1002
```

This makes disk-based lookup efficient.

---

# 15. Compaction

Over time we have many SSTables:

```text
SSTable 1
SSTable 2
SSTable 3
SSTable 4
```

We periodically merge them:

```text
SSTable 1 + 2 + 3
        ↓
   Compaction
        ↓
   SSTable New
```

### Benefits

- Removes obsolete versions
- Removes deleted/tombstone entries
- Reduces number of files
- Improves read performance

---

# 16. Bloom Filter

Before searching an SSTable:

```text
GET(key)
   ↓
Bloom Filter
   ↓
Definitely not present → Skip SSTable
Possibly present       → Search SSTable
```

### Important

Bloom filter can have **false positives**, but should not have false negatives in a correctly implemented standard Bloom filter.

### Advantage

Reduces unnecessary disk reads.

---

# 17. DELETE Operation

In many LSM-tree based systems, we don't immediately remove the key from disk.

Instead:

```text
DELETE(user:1001)
       ↓
Tombstone
```

Example:

```text
user:1001 → TOMBSTONE
```

During compaction, old data and the tombstone can eventually be removed when safe.

---

# 18. TTL

Support expiration:

```text
SET session:123 value TTL=3600
```

After 1 hour:

```text
session:123 → expired
```

Can use:

- TTL metadata
- Lazy deletion
- Background cleanup

---

# 19. Failure Handling

### Node failure

```text
Node A ❌
   ↓
Replica B/C
```

### Network failure

Use:

- Timeouts
- Retries
- Idempotency where appropriate
- Quorum handling

### Data corruption

Use:

- Checksums
- Replication
- Backups

---

# 20. Rebalancing

Suppose:

```text
Node A
Node B
Node C
```

Add:

```text
Node D
```

Consistent hashing determines which key ranges should move to D.

```text
Before:

A B C

After:

A B C D
```

Only the affected ranges move.

Virtual nodes make this more balanced.

---

# 21. Hot Key Problem

Suppose:

```text
celebrity:123
```

receives millions of requests.

All requests may go to the same node:

```text
          celebrity:123
                |
                v
             Node A
                ↑
          Millions requests
```

This creates a hot spot.

Solutions:

- Cache hot keys
- Replicate hot keys
- Request routing
- Key splitting where application semantics allow
- Local memory cache

---

# 22. Caching

Add cache:

```text
Client
  ↓
Cache
  ↓
Key-Value Store
```

For frequently accessed data:

```text
GET user:1001
       ↓
Cache HIT
       ↓
Return immediately
```

This reduces storage-node load and latency.

---

# 23. Partitioning vs Replication

### Partitioning

Splits different keys across nodes.

```text
Node A → Keys A-F
Node B → Keys G-M
Node C → Keys N-Z
```

Goal:

> Scale storage and throughput.

### Replication

Copies the same data to multiple nodes.

```text
Node A → Key X
Node B → Key X
Node C → Key X
```

Goal:

> Fault tolerance and availability.

---

# 24. Final Architecture

```text
                         Client
                           |
                           v
                    Load Balancer
                           |
                           v
                    Request Router
                           |
                     Hash(key)
                           |
                    Consistent Hash
                           |
          +----------------+----------------+
          |                |                |
          v                v                v
       Node A           Node B           Node C
       Primary          Primary          Primary
        /  \             /  \             /  \
       v    v           v    v           v    v
     Rep   Rep        Rep   Rep        Rep   Rep
          |
       Storage Engine
          |
     +----+----+
     |         |
    WAL     MemTable
                |
                v
             SSTables
                |
                v
            Compaction
```

---

# 25. Key Design Decisions

| Problem | Solution |
|---|---|
| Distribute keys | Consistent hashing |
| Balance nodes | Virtual nodes |
| Fault tolerance | Replication |
| Durable writes | WAL |
| Fast writes | MemTable |
| Disk storage | SSTables |
| Reduce disk reads | Bloom filters |
| Clean old data | Compaction |
| Delete | Tombstones |
| Expiration | TTL |
| Hot keys | Cache/replication |
| Node failure | Replicas + failover |

---

# 🧠 FINAL RECALL

## Key-Value Store =

```text
Hash Key
   ↓
Consistent Hash Ring
   ↓
Primary + Replicas
   ↓
WAL
   ↓
MemTable
   ↓
SSTables
   ↓
Compaction
```

### Remember these 7 words:

**Partition → Replicate → WAL → MemTable → SSTable → Bloom Filter → Compaction**

### One-Line Interview Answer

> "I would partition keys using consistent hashing with virtual nodes, replicate each key for fault tolerance, use a WAL and MemTable for durable fast writes, persist data as SSTables, use Bloom filters for efficient reads, and use compaction to merge files and remove obsolete data."