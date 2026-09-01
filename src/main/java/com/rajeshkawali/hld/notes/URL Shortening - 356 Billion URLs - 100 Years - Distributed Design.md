# TinyURL — 356 Billion URLs / 100 Years — Distributed Design

## Requirement

Need to support approximately:

**356 billion URLs over 100 years**

Average creation rate:

**356B / 100 years ≈ 113 URLs/sec**

So the average write rate is actually manageable.

But design for **peak traffic**, not just average traffic.

---

## 1. Recommended Architecture

```text
                    Users
                      |
                      v
                Load Balancer
                      |
             +--------+--------+
             |        |        |
            App      App      App
             |        |        |
             +--------+--------+
                      |
              Distributed ID Generator
                      |
                   Base62
                      |
                +-----+-----+
                |           |
              Cache        DB
             (Redis)    Distributed DB
```

---

## 2. ID Generation — Recommended

### Use Distributed ID + Base62

```text
App Server
    ↓
Distributed ID Generator
    ↓
Unique 64-bit ID
    ↓
Base62 Encoding
    ↓
Short Code
```

Example:

```text
ID = 123456789
       ↓
Base62
       ↓
8M0k9
```

### Why?

Avoid depending on:

```text
Single DB Auto Increment
```

because multiple application servers would depend on one central database sequence.

Instead, use a distributed ID generator such as a **Snowflake-style ID**.

---

# 3. Snowflake-Style ID

A typical distributed ID can contain:

```text
Timestamp | Machine/Worker ID | Sequence
```

Example:

```text
+------------+-------------+----------+
| Timestamp  | Worker ID   | Sequence |
+------------+-------------+----------+
```

This allows many servers to generate IDs independently.

### Advantages

- Distributed
- High throughput
- No central DB call for every ID
- Very low collision risk
- Works well with many application servers

### Disadvantages

- More complex
- Requires worker-ID management
- Clock synchronization/clock rollback must be handled

---

# 4. How Many IDs Do We Need?

356 billion:

```text
356,000,000,000
```

A 39-bit number can represent up to approximately:

```text
2^39 ≈ 549 billion
```

So 39 bits are theoretically enough for 356 billion sequential IDs.

But don't design around the exact minimum.

### Recommended

Use a **64-bit distributed ID**.

This gives huge future capacity.

```text
64-bit ID
    ↓
Base62
    ↓
Short code
```

---

# 5. Base62 Length

Base62 gives:

```text
0-9
a-z
A-Z
```

Total:

```text
62 characters
```

Capacity:

```text
62^6 ≈ 56.8 billion
62^7 ≈ 3.52 trillion
```

Therefore:

### 6 characters ❌

Not enough for 356 billion URLs.

### 7 characters ✅

Enough for 356 billion URLs.

```text
62^7 ≈ 3.5 trillion
```

So **7 Base62 characters are theoretically enough** for 356 billion unique codes.

---

# 6. Important: Don't Reserve 7 Characters Forever

You can allow the short URL length to grow gradually.

For example:

```text
1-6 characters → earlier IDs
7 characters   → later IDs
8 characters   → future expansion
```

You don't need to change the database or architecture when you cross a length boundary.

The Base62 encoder naturally produces longer strings as the ID grows.

---

# 7. Database Design

Core table:

```text
URL_MAPPING

id
short_code
long_url
created_at
expires_at
```

Important:

```text
PRIMARY KEY / UNIQUE → short_code
```

Main lookup:

```text
short_code → long_url
```

---

# 8. Don't Put All 356 Billion URLs in One Database

This is the key distributed-system decision.

Instead, partition the data.

```text
                 URL Data
                    |
          +---------+---------+
          |         |         |
        Shard 1   Shard 2   Shard 3
          |         |         |
         ...       ...       ...
```

As the data grows:

```text
Year 1
 ↓
Few shards

Year 20
 ↓
More shards

Year 50
 ↓
More shards

Year 100
 ↓
Many shards
```

---

# 9. How to Choose the Shard?

Use the ID or short code.

For example:

```text
shard = hash(short_code) % N
```

or use a range:

```text
ID range
    ↓
Shard
```

### Hash-based sharding

```text
hash(short_code) % 10

0 → Shard 0
1 → Shard 1
...
9 → Shard 9
```

### Advantage

Good distribution.

### Disadvantage

Adding/removing shards can require data movement.

---

# 10. Better: Consistent Hashing / Virtual Nodes

For a system where the number of nodes grows gradually:

```text
Hash Ring
   |
   +-- DB1
   +-- DB2
   +-- DB3
   +-- DB4
```

Use **consistent hashing with virtual nodes**.

When adding a DB node:

```text
Old:

DB1 DB2 DB3

Add DB4:

DB1 DB2 DB3 DB4
```

Only part of the data needs to move.

### Recall

> **Consistent hashing minimizes data movement when nodes are added or removed.**

---

# 11. But There Is an Important Alternative

For this particular problem, because you already have a **monotonically increasing distributed ID**, you can also use **range-based partitioning**.

Example:

```text
ID 0 - 10B       → Shard 1
ID 10B - 20B     → Shard 2
ID 20B - 30B     → Shard 3
...
```

When the current shard becomes full:

```text
Shard 1
   ↓
Full
   ↓
Create Shard 2
```

This is very simple operationally.

### Problem

New writes concentrate on the newest shard.

So you need to ensure the active shard has enough capacity and replicas.

---

# 12. Which Sharding Strategy?

### Hash sharding

```text
hash(short_code) → shard
```

**Pros:**
- Good distribution
- No hot newest shard

**Cons:**
- Resharding is harder

### Range sharding

```text
ID range → shard
```

**Pros:**
- Simple
- Easy to understand
- Easy to manage by time/ID range

**Cons:**
- Newest shard receives most writes
- Need to manage shard capacity

### Interview choice

> For a URL shortener, I would start with hash-based partitioning for even distribution, or range-based/time-based partitioning if operational simplicity and predictable capacity are more important.

---

# 13. Redis Cache

Redirects are read-heavy.

Use:

```text
short_code
    ↓
Redis
    ↓
long_url
```

Flow:

```text
Request
   ↓
Redis
   |
   +-- HIT → Return URL
   |
   +-- MISS
          ↓
        Database
          ↓
        Redis
          ↓
       Return URL
```

Database remains the source of truth.

---

# 14. Cache Does NOT Need 356 Billion URLs

Very important.

Don't try to put all URLs in Redis.

Instead:

```text
356B URLs → Database

Popular URLs → Redis
```

Redis should contain the **hot subset**.

Use TTL and eviction policies.

---

# 15. Gradual Scaling

You don't need infrastructure for 356 billion URLs on day one.

### Stage 1

```text
Few users
 ↓
App
 ↓
DB
```

### Stage 2

```text
More users
 ↓
Load Balancer
 ↓
Multiple Apps
 ↓
DB + Redis
```

### Stage 3

```text
Large traffic
 ↓
Multiple App Servers
 ↓
Distributed ID Generator
 ↓
Redis Cluster
 ↓
DB Shards
```

### Stage 4

```text
Huge scale
 ↓
Multiple regions
 ↓
DB partitions/shards
 ↓
Replicas
 ↓
CDN
```

---

# 16. Multi-Region Design

If the service becomes global:

```text
                  Global Users
                       |
                Global Load Balancer
                  /            \
                 /              \
             US Region       India Region
                |                |
             App Cluster       App Cluster
                |                |
              Redis            Redis
                |                |
              DB               DB
```

But don't immediately create independent databases in every region if you don't need them.

Multi-region introduces:

- Replication
- Consistency issues
- Conflict handling
- Failover complexity

Start with one region and add regions when availability/latency requirements justify it.

---

# 17. ID Generator Scaling

Suppose you have:

```text
App 1 → ID Worker 1
App 2 → ID Worker 2
App 3 → ID Worker 3
```

Each worker gets a unique worker ID.

```text
Worker 1 → IDs
Worker 2 → IDs
Worker 3 → IDs
```

No collision because worker IDs are different.

```text
Timestamp + Worker ID + Sequence
```

This allows very high ID generation throughput.

---

# 18. Final Design

```text
                         Users
                           |
                           v
                    Global LB / DNS
                           |
                    Load Balancer
                           |
             +-------------+-------------+
             |             |             |
           App 1         App 2         App 3
             |             |             |
             +-------------+-------------+
                           |
                           v
                Distributed ID Generator
                           |
                           v
                        Base62
                           |
                           v
                    URL Short Code
                           |
                +----------+----------+
                |                     |
                v                     v
             Redis                 DB Cluster
             Cache                /    |    \
                                DB1   DB2   DB3
                                 |     |     |
                              Replicas / Partitions
```

---

# 🧠 FINAL RECALL

## Requirement

```text
356 Billion URLs
100 Years
≈ 113 URLs/sec average
```

## ID

```text
Distributed ID
      ↓
   Base62
      ↓
Short Code
```

## Base62

```text
62^6 ≈ 56.8B      ❌
62^7 ≈ 3.52T      ✅
```

## Storage

```text
Database = Source of Truth
Redis    = Hot URL Cache
```

## Scaling

```text
Load Balancer
      ↓
Stateless Apps
      ↓
Distributed ID Generator
      ↓
Redis
      ↓
Sharded Database
      ↓
Replicas / Multi-Region when required
```

## Sharding

```text
Hash(short_code) → Shard
```

or

```text
ID Range → Shard
```

## Most Important Interview Point

> **Don't design for 356 billion URLs immediately. Design the system so storage and application capacity can grow gradually as the number of URLs grows.**

## ⭐ One-Line Recall

**Distributed ID → Base62 → Stateless Apps → Redis → Sharded DB → Replicas → Multi-Region**