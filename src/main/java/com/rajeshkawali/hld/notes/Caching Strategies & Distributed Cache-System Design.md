# Distributed Cache & Caching Strategies — System Design Interview Notes

## 1. What is Cache?

A **cache** is a fast storage layer used to temporarily store frequently accessed data.

The main purpose of caching is:

- Reduce database load
- Reduce response time
- Increase application throughput
- Improve scalability
- Improve user experience

### Without Cache

```text
Client
  |
  v
Application
  |
  v
Database
  |
  v
Response
```

Every request goes to the database.

### With Cache

```text
Client
  |
  v
Application
  |
  v
Cache
  |
  +---- HIT ----> Return Data
  |
  +---- MISS ---> Database
                    |
                    v
                  Cache
                    |
                    v
                 Response
```

---

# 2. Why Do We Need Distributed Cache?

A local cache exists inside one application server.

```text
App-1 → Local Cache
App-2 → Local Cache
App-3 → Local Cache
```

Problems:

- Data is duplicated
- Cache is not shared
- Application restart can lose cache
- Each server has limited memory
- Cache consistency becomes difficult

A **distributed cache** is shared by multiple application servers.

```text
                 Load Balancer
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
        App-1       App-2       App-3
          |           |           |
          +-----------+-----------+
                      |
                      v
             Distributed Cache
              /       |       \
             v        v        v
          Node-1   Node-2   Node-3
                      |
                      v
                   Database
```

### Common Technologies

- Redis
- Memcached
- Hazelcast
- Apache Ignite

---

# 3. Cache Hit vs Cache Miss

## Cache Hit

Requested data exists in cache.

```text
Application
    |
    v
  Cache
    |
    v
  Found
    |
    v
 Response
```

Example:

```text
GET user:100

Cache:
user:100 → John

Result → CACHE HIT
```

---

## Cache Miss

Requested data does not exist in cache.

```text
Application
    |
    v
  Cache
    |
    v
   MISS
    |
    v
 Database
    |
    v
 Cache
    |
    v
 Response
```

Example:

```text
GET user:100

Cache:
user:100 → NOT FOUND

Database:
user:100 → John

Store in Cache:
user:100 → John
```

---

# 4. Cache Hit Ratio

Cache hit ratio tells us how effective our cache is.

```text
Cache Hit Ratio = Cache Hits / Total Requests
```

Example:

```text
Total Requests = 1,000,000
Cache Hits     =   950,000

Hit Ratio = 950,000 / 1,000,000
          = 95%
```

Higher hit ratio generally means fewer requests reach the database.

---

# 5. Local Cache vs Distributed Cache

| Feature | Local Cache | Distributed Cache |
|---|---|---|
| Location | Application memory | Separate cache cluster |
| Speed | Very fast | Very fast, but network call |
| Shared | No | Yes |
| Scalability | Limited | Better |
| Memory | Per application | Shared cluster |
| Failure | Lost with application | Can survive app restart |
| Complexity | Low | Higher |
| Example | Caffeine, Guava | Redis, Memcached |

### Interview Answer

> I would use a local cache when extremely low latency is required and the data can safely be duplicated across instances. I would use a distributed cache when multiple application instances need shared cached data.

---

# 6. Cache-Aside Pattern

**Cache-Aside** is one of the most commonly used caching strategies.

The application manages the cache.

```text
Application
    |
    v
 Check Cache
    |
    +---- HIT ----> Return
    |
    +---- MISS
            |
            v
        Database
            |
            v
        Update Cache
            |
            v
          Return
```

### Example

```text
user = cache.get(userId)

if user exists:
    return user

user = database.get(userId)

cache.set(userId, user, TTL)

return user
```

### Advantages

- Simple
- Easy to implement
- Application controls what gets cached
- Cache only frequently accessed data

### Disadvantages

- Cache miss causes DB request
- Possible stale data
- Cache stampede is possible

### Interview Tip

> Cache-aside is usually a good default for read-heavy applications.

---

# 7. Read-Through Cache

In read-through caching, the application asks the cache for data.

If the cache misses, the cache itself loads the data from the database.

```text
Application
     |
     v
   Cache
     |
     +---- HIT ----> Return
     |
     +---- MISS
            |
            v
           DB
            |
            v
          Cache
            |
            v
         Application
```

### Advantages

- Application code is simpler
- Cache handles loading missing data

### Disadvantages

- More infrastructure complexity
- Cache must know how to access the database

---

# 8. Write-Through Cache

Data is written to cache and database as part of the write path.

```text
Application
     |
     v
   Cache
     |
     v
 Database
```

### Example

```text
UPDATE user:100

Cache → updated
DB    → updated
```

### Advantages

- Cache remains relatively fresh
- Lower chance of stale cached data

### Disadvantages

- Higher write latency
- Every write updates cache
- Data that is never read may still be cached

---

# 9. Write-Behind / Write-Back Cache

Application writes to cache first.

Database is updated asynchronously later.

```text
Application
     |
     v
   Cache
     |
     v
 Async Queue
     |
     v
 Database
```

### Advantages

- Very fast writes
- Database load can be reduced
- Writes can be batched

### Disadvantages

- Data loss risk if cache fails before persistence
- More complex
- Eventual consistency

---

# 10. Write-Around Cache

Writes go directly to the database.

Cache is populated only when the data is later read.

```text
WRITE:

Application → Database


READ:

Application → Cache
                 |
                MISS
                 |
                 v
              Database
                 |
                 v
               Cache
```

### Advantages

- Avoids caching data that may never be read
- Good for write-heavy workloads

### Disadvantages

- First read is slower
- More cache misses

---

# 11. Cache Strategy Comparison

| Strategy | Write Path | Read Path | Main Advantage |
|---|---|---|---|
| Cache-Aside | DB | App checks cache | Simple |
| Read-Through | DB through cache | Cache | Simple read logic |
| Write-Through | Cache + DB | Cache | Better freshness |
| Write-Behind | Cache → async DB | Cache | Fast writes |
| Write-Around | DB | Cache → DB on miss | Avoid unnecessary cache writes |

### Easy Recall

```text
Cache-Aside   → Application manages cache
Read-Through  → Cache manages read miss
Write-Through → Cache + DB
Write-Behind  → Cache first, DB later
Write-Around  → DB first, cache later on read
```

---

# 12. Cache Eviction

Cache memory is limited.

When cache becomes full, some existing data must be removed.

This is called **cache eviction**.

```text
Cache Capacity = 1 GB
Current Usage  = 1 GB

New Data
   |
   v
Cache Full
   |
   v
Eviction Algorithm
   |
   v
Remove Some Data
```

Common eviction algorithms:

- LRU
- LFU
- FIFO
- Random
- TTL-based expiration

---

# 13. LRU — Least Recently Used

Removes the item that has not been accessed for the longest time.

Example:

```text
A → recently used
B → recently used
C → old
D → very old
```

If cache is full:

```text
Remove D
```

### Advantages

- Simple
- Good general-purpose policy
- Frequently used in caching systems

### Disadvantages

- Does not consider frequency
- One-time large scans can pollute the cache

### Recall

```text
LRU = Least Recently Used
```

---

# 14. LFU — Least Frequently Used

Removes the item accessed the fewest times.

Example:

```text
A → 100 accesses
B → 50 accesses
C → 10 accesses
D → 1 access
```

Remove:

```text
D
```

### Advantages

- Keeps frequently accessed data
- Good when popular data remains popular

### Disadvantages

- More complex than LRU
- Old popular data can remain even after popularity changes

### Recall

```text
LFU = Least Frequently Used
```

---

# 15. FIFO — First In First Out

Removes the oldest inserted item.

```text
A → B → C → D

Oldest = A

Remove A
```

### Advantages

- Very simple
- Easy to implement

### Disadvantages

- Does not consider recent usage
- Does not consider frequency

### Recall

```text
FIFO = First In First Out
```

---

# 16. Random Eviction

Randomly chooses an item to remove.

```text
A B C D

Randomly choose B

Remove B
```

### Advantages

- Very simple
- Low overhead

### Disadvantages

- May remove an important/frequently used item

---

# 17. TTL — Time To Live

TTL defines how long an item should remain valid in the cache.

Example:

```text
user:100 → John
TTL = 10 minutes
```

After 10 minutes:

```text
Entry expires
```

### Examples

```text
Weather data      → TTL 5 minutes
Product catalog   → TTL 1 hour
Session data      → TTL based on session requirements
OTP               → TTL few minutes
```

### Why use TTL?

- Prevent stale data from remaining forever
- Automatically remove temporary data
- Control cache memory

---

# 18. TTL vs Eviction

They are different.

### TTL

Answers:

> When should this particular cache entry expire?

### Eviction

Answers:

> Which entry should be removed when cache resources are needed?

```text
TTL      → Expiration based on time
Eviction → Removal based on cache capacity/policy
```

They are often used together.

---

# 19. Cache Invalidation

Cache invalidation means removing or updating stale cache data.

Example:

```text
DB:
user:100 → John

Cache:
user:100 → John
```

User changes name:

```text
DB:
user:100 → David
```

But cache still contains:

```text
Cache:
user:100 → John
```

This creates stale data.

---

# 20. Cache Invalidation Strategies

## Strategy 1 — Delete Cache

```text
Update DB
   |
   v
Delete Cache
```

Next read:

```text
Cache MISS
   |
   v
DB
   |
   v
Update Cache
```

This is a very common approach.

---

## Strategy 2 — Update Cache

```text
Update DB
    |
    v
Update Cache
```

The cache immediately contains the new value.

---

## Strategy 3 — TTL

Allow the stale value to expire automatically.

```text
Cache
  |
  v
TTL expires
  |
  v
Next request → DB
```

Simple, but stale data may be served until expiration.

---

## Strategy 4 — Event-Based Invalidation

```text
Service
   |
   v
Update DB
   |
   v
Publish Event
   |
   v
Kafka
   |
   v
Cache Consumer
   |
   v
Invalidate Cache
```

Useful in distributed systems.

---

# 21. Cache Stampede

Cache stampede occurs when many requests try to load the same missing cache entry simultaneously.

Example:

```text
Popular Key = product:100
```

Cache expires:

```text
10,000 requests
      |
      v
Cache MISS
      |
      v
10,000 DB queries
      |
      v
Database overloaded
```

This is also called:

- Dogpile effect
- Thundering herd

---

# 22. How to Prevent Cache Stampede?

## 1. Locking

Only one request loads data from DB.

```text
Request 1 → DB
Request 2 → Wait
Request 3 → Wait
Request 4 → Wait
```

After Request 1 populates cache:

```text
All requests → Cache
```

---

## 2. Request Coalescing

Combine multiple requests for the same missing key into a single database request.

---

## 3. TTL Jitter

Instead of giving all keys exactly the same TTL:

```text
TTL = 60 seconds
```

use:

```text
TTL = 60 + random(0..10) seconds
```

This reduces simultaneous expiration.

---

## 4. Background Refresh

Refresh popular cache entries before they expire.

---

# 23. Cache Penetration

Cache penetration occurs when clients repeatedly request data that does not exist.

Example:

```text
GET user:999999999

Cache → MISS
DB    → NOT FOUND
```

Again:

```text
GET user:999999999

Cache → MISS
DB    → NOT FOUND
```

This can overload the database.

---

# 24. Prevent Cache Penetration

## Negative Caching

Store the fact that the data doesn't exist.

```text
user:999999999 → NULL
TTL = 1 minute
```

Next request:

```text
Request
  |
  v
Cache
  |
  v
NULL
  |
  v
Return NOT FOUND
```

No DB query is required.

---

# 25. Bloom Filter

A Bloom filter can help determine whether a key could exist.

```text
Request
   |
   v
Bloom Filter
   |
   +---- Definitely NOT exists
   |          |
   |          v
   |       Don't query DB
   |
   +---- Maybe exists
              |
              v
          Check Cache/DB
```

### Important

Bloom filters can have **false positives**.

```text
Bloom says:
"Maybe exists"

→ Continue checking
```

But a properly maintained Bloom filter does not produce false negatives.

### Advantages

- Memory efficient
- Very fast
- Useful for very large datasets

### Disadvantages

- Probabilistic
- Does not store actual data
- Requires maintenance

---

# 26. Cache Avalanche

Cache avalanche occurs when many cache entries expire at approximately the same time.

```text
Millions of cache entries
          |
          v
Expire together
          |
          v
Millions of DB requests
          |
          v
Database overloaded
```

### Solutions

- TTL jitter
- Staggered expiration
- Cache warming
- Background refresh
- Rate limiting
- Database protection

---

# 27. Stampede vs Penetration vs Avalanche

This is an important interview question.

| Problem | Meaning | Example | Solution |
|---|---|---|---|
| Stampede | Many requests miss the same key | Popular product expires | Lock, request coalescing |
| Penetration | Requests ask for nonexistent data | Random user IDs | Bloom filter, negative cache |
| Avalanche | Many keys expire together | Millions expire simultaneously | TTL jitter, warming |

### Easy Recall

```text
STAMPede
Same key
Many requests
      ↓
DB overload


PENETRATION
Invalid/nonexistent keys
      ↓
Repeated DB queries


AVALANCHE
Many keys expire together
      ↓
DB overload
```

---

# 28. Hot Key Problem

A **hot key** is a cache key receiving extremely high traffic.

Example:

```text
product:iphone
```

Suppose millions of users request the same product.

Even in a distributed cache:

```text
Millions requests
       |
       v
Same cache node
       |
       v
Hotspot
```

### Solutions

- Local cache
- Replicate hot keys
- CDN
- Request coalescing
- Rate limiting
- Key replication

---

# 29. Cache Sharding

A single cache node cannot store unlimited data.

We distribute keys across multiple nodes.

```text
user:1 → Cache Node 1
user:2 → Cache Node 3
user:3 → Cache Node 2
user:4 → Cache Node 1
```

A common technique is **consistent hashing**.

```text
Hash(key)
    |
    v
Determine Cache Node
```

### Advantages

- Horizontal scalability
- More total cache capacity
- Distributes traffic

### Problem

Adding/removing nodes can cause many keys to move.

### Solution

Use consistent hashing to minimize key redistribution.

---

# 30. Cache Replication

For high availability, cache data can be replicated.

```text
       Primary
          |
          v
       Replica
```

If primary fails:

```text
Primary DOWN
     |
     v
Replica/Fallback
```

### Advantages

- High availability
- Fault tolerance
- Can improve read scalability depending on architecture

### Disadvantages

- Extra memory
- Replication overhead
- Possible replication lag

---

# 31. Multi-Level Cache

Large systems can use multiple cache levels.

```text
Application
    |
    v
L1 Cache
(Local Memory)
    |
   MISS
    |
    v
L2 Cache
(Redis)
    |
   MISS
    |
    v
Database
```

Example:

```text
L1 → Caffeine
L2 → Redis
L3 → Database
```

### Advantages

- L1 provides extremely low latency
- L2 provides shared cache
- Reduces DB traffic

### Disadvantages

- More complex invalidation
- More complicated consistency management

---

# 32. Cache Warming

Cache warming means preloading frequently accessed data into the cache.

Example:

Before a flash sale:

```text
Top Products
     |
     v
Preload Cache
```

When the sale starts:

```text
Millions of requests
       |
       v
Cache HIT
```

Instead of:

```text
Millions of requests
       |
       v
Cache MISS
       |
       v
Database overload
```

---

# 33. Cache Failure

What happens if Redis goes down?

Bad architecture:

```text
Redis DOWN
    |
    v
All requests → DB
    |
    v
DB overloaded
    |
    v
Application failure
```

Better architecture:

```text
Redis DOWN
    |
    v
Fallback / Degraded Mode
    |
    v
Rate-limited DB access
```

Possible protections:

- Local cache
- Circuit breaker
- Rate limiting
- DB connection limits
- Cache replicas
- Graceful degradation
- Backpressure

---

# 34. Cache Consistency

Caching introduces a consistency tradeoff.

```text
Freshness
    vs
Performance
```

### Example: Banking Balance

```text
Strong consistency is important.
```

Avoid serving stale balance information where correctness matters.

### Example: Product Recommendations

```text
Eventual consistency is usually acceptable.
```

A recommendation being a few minutes old is usually not a critical problem.

### Interview Answer

> I would choose the cache consistency strategy based on business requirements rather than assuming every piece of data should be strongly consistent.

---

# 35. Cache Key Design

Good cache keys should be predictable and unique.

Examples:

```text
user:100
product:500
order:1000
```

Multiple parameters:

```text
product:100:region:IN
search:iphone:page:2
```

### Good Practices

- Use consistent naming
- Avoid collisions
- Keep keys reasonably short
- Include version when required
- Avoid unnecessary sensitive information

---

# 36. Redis vs Memcached

| Feature | Redis | Memcached |
|---|---|---|
| Data model | Rich data structures | Simple key-value |
| Persistence | Supported | Primarily memory-only |
| Replication | Supported | Simpler architecture |
| Pub/Sub | Supported | No native equivalent |
| Atomic operations | Supported | More limited |
| Complexity | Higher | Simpler |
| Use case | Advanced distributed cache | Simple cache |

### Interview Answer

> I would choose Redis when I need richer data structures, atomic operations, replication, persistence options, or advanced caching capabilities. For a simple ephemeral key-value cache, Memcached can be a simpler option.

---

# 37. Cache vs Database

| Cache | Database |
|---|---|
| Very fast | Relatively slower |
| Usually temporary | Persistent |
| Limited memory | Large storage |
| Frequently accessed data | Source of truth |
| Data can be evicted | Data should persist |
| Often eventually consistent | Can provide strong consistency |

### Important Interview Point

> In most architectures, the database is the source of truth and the cache is a performance layer.

---

# 38. E-Commerce Cache Design Example

## Requirement

```text
10M users
100K products
High read traffic
Products change occasionally
```

Architecture:

```text
Client
   |
   v
Load Balancer
   |
   v
Application
   |
   v
Redis
   |
   +---- HIT ----> Return
   |
   +---- MISS
          |
          v
       Product DB
          |
          v
        Redis
```

Use:

```text
Cache-Aside
TTL
Cache Invalidation
```

### Read Flow

```text
GET product:100

Redis HIT
    |
    v
Return product
```

### Cache Miss

```text
Redis MISS
    |
    v
Database
    |
    v
Redis SET
    |
    v
Return
```

### Update

```text
Update DB
    |
    v
Delete Cache
```

Next request reloads fresh data.

---

# 39. Flash Sale Scenario

### Interview Question

> Millions of users request the same product during a flash sale. How would you design the cache?

### Answer

I would use:

```text
CDN
 ↓
Local Cache
 ↓
Redis
 ↓
Database
```

And apply:

- Cache warming
- Hot-key replication
- Request coalescing
- Rate limiting
- TTL
- Database protection
- Inventory protection

Important:

> Cache should not be the only mechanism protecting inventory correctness. Inventory updates need proper concurrency and consistency controls.

---

# 40. Scenario: Millions of Keys Expire Together

### Interview Question

> What happens if millions of cache entries expire at the same time?

### Answer

This is a **cache avalanche**.

I would use:

- TTL jitter
- Staggered expiration
- Background refresh
- Cache warming
- Rate limiting
- Database protection

---

# 41. Scenario: Random User IDs

### Interview Question

> An attacker sends millions of requests for random user IDs. How do you protect the database?

### Answer

Use:

```text
Rate Limiting
      +
Bloom Filter
      +
Negative Cache
```

Flow:

```text
Request
   |
   v
Bloom Filter
   |
   +---- Definitely doesn't exist
   |             |
   |             v
   |          Return 404
   |
   +---- Maybe exists
                 |
                 v
             Cache/DB
```

---

# 42. Scenario: Cache and DB Have Different Values

### Interview Question

> The database contains new data but cache contains old data. What would you do?

Possible approach:

```text
Update DB
   |
   v
Invalidate Cache
```

For distributed systems:

```text
Update DB
   |
   v
Publish Event
   |
   v
Kafka
   |
   v
Invalidate/Update Cache
```

Use TTL as an additional safety mechanism.

---

# 43. Scenario: Redis Goes Down

### Interview Question

> What happens if your distributed cache goes down?

Bad design:

```text
Cache DOWN
   |
   v
All traffic → DB
   |
   v
DB overloaded
```

Better design:

```text
Cache DOWN
   |
   v
Circuit Breaker / Rate Limit
   |
   v
Controlled DB traffic
```

Possible solutions:

- Redis replication
- Automatic failover
- Local cache
- Circuit breaker
- Rate limiting
- DB connection pool limits
- Graceful degradation

---

# 44. Scenario: One Cache Key Is Extremely Popular

### Interview Question

> What if one cache key receives millions of requests?

This is a **hot key** problem.

Solutions:

```text
Hot Key
   |
   +--> Local Cache
   |
   +--> Replicate Key
   |
   +--> CDN
   |
   +--> Request Coalescing
```

---

# 45. Distributed Cache High-Level Design

```text
                         Clients
                            |
                            v
                     Load Balancer
                            |
                            v
                 +---------------------+
                 | Application Servers |
                 +---------------------+
                     |       |       |
                     +-------+-------+
                             |
                             v
                    Distributed Cache
                  +----------+----------+
                  |          |          |
                  v          v          v
               Redis-1    Redis-2    Redis-3
                  |          |          |
                  +----------+----------+
                             |
                             v
                         Database
```

For a large-scale system, add:

```text
- Cache sharding
- Consistent hashing
- Replication
- Failover
- TTL
- Eviction
- Cache warming
- Hot-key protection
- Monitoring
```

---

# 46. Important Cache Metrics

Monitor:

```text
Cache Hit Ratio
Cache Miss Ratio
Cache Latency
Memory Usage
Eviction Count
Expiration Count
Hot Keys
Error Rate
Connection Count
Throughput
Replication Lag
```

### Example

```text
Cache Hit Ratio ↓
       |
       v
Cache Misses ↑
       |
       v
DB Traffic ↑
       |
       v
DB Latency ↑
```

---

# 47. Advantages of Caching

## Advantages

- Lower latency
- Reduced database load
- Higher throughput
- Better scalability
- Better user experience
- Lower infrastructure pressure
- Useful for read-heavy workloads

---

# 48. Disadvantages of Caching

## Disadvantages

- Stale data
- Cache invalidation complexity
- Additional infrastructure
- Memory cost
- Cache failure scenarios
- Consistency problems
- Cache stampede
- Cache penetration
- Cache avalanche
- Hot-key problems

---

# 49. Most Asked Cache Interview Questions

## Q1. What is caching?

**Answer:**

> Caching stores frequently accessed data in a faster storage layer so that future requests can be served with lower latency and reduced database load.

---

## Q2. What is a distributed cache?

**Answer:**

> A distributed cache is a cache shared across multiple application servers, usually running as a cluster of cache nodes.

---

## Q3. What is Cache-Aside?

**Answer:**

> The application first checks the cache. On a miss, it reads from the database, stores the result in the cache, and returns it to the client.

---

## Q4. What is cache invalidation?

**Answer:**

> Cache invalidation removes or updates stale cache data when the underlying database data changes.

---

## Q5. What is LRU?

**Answer:**

> LRU removes the least recently used item when the cache needs space.

---

## Q6. What is LFU?

**Answer:**

> LFU removes the least frequently accessed item.

---

## Q7. What is TTL?

**Answer:**

> TTL defines how long a cache entry remains valid before it expires.

---

## Q8. What is cache stampede?

**Answer:**

> Cache stampede occurs when many requests simultaneously miss the same cache key and all query the database.

---

## Q9. How do you prevent cache stampede?

**Answer:**

> Use locking, request coalescing, background refresh, and TTL jitter.

---

## Q10. What is cache penetration?

**Answer:**

> Cache penetration occurs when repeated requests ask for nonexistent data, causing repeated database queries.

Solutions:

```text
Bloom Filter
Negative Cache
Rate Limiting
```

---

## Q11. What is cache avalanche?

**Answer:**

> Cache avalanche occurs when many cache entries expire at approximately the same time and generate a large DB load.

Solutions:

```text
TTL Jitter
Cache Warming
Background Refresh
Rate Limiting
```

---

## Q12. What is a hot key?

**Answer:**

> A hot key is a cache key receiving disproportionately high traffic.

Solutions:

```text
Local Cache
Replication
CDN
Request Coalescing
Rate Limiting
```

---

## Q13. Redis vs Memcached?

**Answer:**

> Redis provides richer data structures and advanced features such as persistence options, replication, and atomic operations. Memcached is simpler and works well for basic ephemeral key-value caching.

---

## Q14. What happens if cache goes down?

**Answer:**

> Requests may fall back to the database, so I would protect the database using circuit breakers, rate limiting, connection limits, local caching, and cache replication/failover.

---

## Q15. Should cache be the source of truth?

**Answer:**

> Usually no. The database should remain the source of truth, while the cache acts as a performance layer.

---

# 50. Cache Design Interview Checklist

When designing a cache, discuss:

```text
1. What data should be cached?
2. Is the workload read-heavy or write-heavy?
3. Cache-Aside or another strategy?
4. What TTL should be used?
5. Which eviction policy?
6. How will cache invalidation work?
7. What consistency is required?
8. How will cache be sharded?
9. How will cache be replicated?
10. How will hot keys be handled?
11. How will cache stampede be prevented?
12. How will cache penetration be prevented?
13. How will cache avalanche be prevented?
14. What happens if cache goes down?
15. How will cache be monitored?
```

---

# 51. ⭐ One-Page Cache Recall

```text
CACHE
=====

Purpose:
Reduce latency + DB load + increase throughput.

CACHE HIT:
Data found → return quickly.

CACHE MISS:
Cache miss → DB → Cache → Return.


CACHE STRATEGIES:
-----------------

Cache-Aside:
App → Cache
       ↓ MISS
      DB
       ↓
     Cache

Read-Through:
App → Cache → DB on miss

Write-Through:
Write → Cache → DB

Write-Behind:
Write → Cache → Async DB

Write-Around:
Write → DB
Read → Cache → DB on miss


EVICTION:
---------

LRU    → Least Recently Used
LFU    → Least Frequently Used
FIFO   → First In First Out
Random → Random item
TTL    → Time-based expiration


INVALIDATION:
-------------

Update DB
   ↓
Delete/Update Cache

Methods:
- TTL
- Explicit invalidation
- Event-based invalidation


CACHE PROBLEMS:
---------------

1. STAMPEDE
Same key expires
→ Many requests
→ Many DB calls

Fix:
Lock
Request coalescing
Background refresh


2. PENETRATION
Nonexistent keys
→ Cache MISS
→ DB repeatedly

Fix:
Bloom Filter
Negative Cache
Rate Limiting


3. AVALANCHE
Many keys expire together
→ DB overload

Fix:
TTL Jitter
Cache warming
Background refresh


4. HOT KEY
One key gets huge traffic

Fix:
Local cache
Replication
CDN
Request coalescing


SCALING:
--------

Application
    ↓
Distributed Cache
    ↓
Sharding
    ↓
Multiple Nodes

Use consistent hashing.


HIGH AVAILABILITY:
------------------

Primary
   ↓
Replica
   ↓
Failover


MULTI-LEVEL:
------------

L1 → Local Cache
L2 → Redis
L3 → Database


MONITOR:
--------

- Hit ratio
- Miss ratio
- Latency
- Memory
- Evictions
- Expiration
- Hot keys
- Errors
- Throughput
- Replication lag


MOST IMPORTANT:
---------------

Cache = Performance Layer
Database = Source of Truth

Caching gives:
Latency ↓
DB Load ↓
Throughput ↑
Scalability ↑

But introduces:
Stale Data
Invalidation Complexity
Consistency Problems
Failure Scenarios
```

---

# 52. ⭐ 10-Second Interview Recall

```text
CACHE
  ↓
HIT / MISS
  ↓
CACHE-ASIDE
  ↓
TTL + EVICTION
  ↓
INVALIDATION
  ↓
SHARDING + REPLICATION
  ↓
HOT KEY
  ↓
STAMPede / PENETRATION / AVALANCHE
  ↓
FAILURE HANDLING
  ↓
MONITORING
```

## Final Interview Statement

> **"For a typical read-heavy distributed system, I would use Redis as a distributed cache with the Cache-Aside pattern. I would use TTL and an appropriate eviction policy, invalidate or update cache entries when data changes, shard the cache for scalability, and use replication/failover for availability. I would also protect the system against cache stampede, penetration, avalanche, and hot keys. The database remains the source of truth."**


---
---
---
---
---
---
---
---


# Cache Read & Write Strategies

## 1. Why Do We Have Multiple Cache Strategies?

There is **no single best caching strategy**.

Different applications have different requirements:

```text
Read-heavy application  → Optimize READ performance
Write-heavy application → Optimize WRITE performance
Strong consistency      → Keep Cache + DB synchronized
High write throughput   → Reduce DB writes
Frequently changing data → Avoid stale cache
```

So, different cache strategies were introduced to solve different **performance, consistency, and scalability** problems.

---

# 2. Read Cache Strategies

Read strategies answer:

> **"When the application wants data, where should it look first and who should load the data on a cache miss?"**

---

## A. Cache-Aside / Lazy Loading

Most commonly used strategy.

### Flow

```text
Application
    |
    v
  Cache
    |
    +---- HIT ----> Return
    |
    +---- MISS
           |
           v
        Database
           |
           v
        Update Cache
           |
           v
         Return
```

### Example

```text
GET user:100

1. Check Redis
2. If found → return
3. If not found → query DB
4. Store result in Redis
5. Return result
```

### Advantages

* Simple
* Cache only frequently requested data
* Application controls cache
* Good for read-heavy systems

### Disadvantages

* First request is slower
* Cache miss increases DB load
* Possible stale data
* Cache stampede can happen

### Best for

```text
Product Catalog
User Profiles
News Feed
Recommendations
```

---

## B. Read-Through Cache

The application talks to the cache, and the **cache loads data from DB when there is a miss**.

```text
Application
     |
     v
   Cache
     |
     +---- HIT ----> Return
     |
     +---- MISS
            |
            v
           DB
            |
            v
          Cache
            |
            v
        Application
```

### Advantages

* Application code is simpler
* Cache handles cache-miss loading
* Centralizes caching logic

### Disadvantages

* Cache layer becomes more complex
* Cache needs knowledge/access to the DB
* Not supported natively by every cache technology

### Best for

Systems where you want caching logic separated from application business logic.

---

# 3. Write Cache Strategies

Write strategies answer:

> **"When data changes, how should we update the cache and database?"**

---

## A. Write-Through Cache

Write goes to cache, and cache synchronously writes to DB.

```text
Application
     |
     v
   Cache
     |
     v
 Database
```

### Example

```text
UPDATE user:100

Cache → update
DB    → update
```

The write is considered successful after both layers are updated.

### Advantages

* Cache is usually fresh
* Lower chance of stale data
* Simple read path

### Disadvantages

* Higher write latency
* Every write updates cache
* May cache data that is never read

### Best for

```text
Frequently read + frequently updated data
```

---

# 4. Write-Behind / Write-Back Cache

Application writes to cache first.

Database is updated **asynchronously**.

```text
Application
     |
     v
   Cache
     |
     v
 Message Queue
     |
     v
 Database
```

### Example

```text
UPDATE user:100

1. Write to Cache
2. Return quickly
3. Queue DB update
4. Worker updates DB
```

### Advantages

* Very fast writes
* Reduces immediate DB load
* Writes can be batched
* Good for very high write throughput

### Disadvantages

* Database may temporarily be stale
* Data can be lost if cache fails before DB persistence
* More complex
* Requires reliable queue/retry mechanisms

### Best for

```text
Analytics
Counters
High-volume writes
Systems where eventual consistency is acceptable
```

---

# 5. Write-Around Cache

Write directly to the database.

Cache is **not updated during the write**.

```text
WRITE:

Application
    |
    v
Database


READ:

Application
    |
    v
Cache
    |
   MISS
    |
    v
Database
    |
    v
Cache
```

### Example

```text
UPDATE product:100

DB updated

Later:

GET product:100
      ↓
Cache MISS
      ↓
DB
      ↓
Cache
```

### Advantages

* Avoids caching data that may never be read
* Reduces cache write operations
* Good for write-heavy systems

### Disadvantages

* First read after write is slower
* More cache misses
* Potential stale cache if old value already exists

### Important

If the key already exists in cache, you normally need an **invalidation/update strategy** to avoid serving old data.

---

# 6. Read + Write Strategy Comparison

| Strategy      | Read                     | Write                         | Main Benefit              | Main Problem               |
| ------------- | ------------------------ | ----------------------------- | ------------------------- | -------------------------- |
| Cache-Aside   | App → Cache → DB on miss | Usually DB + invalidate cache | Simple                    | Cache misses               |
| Read-Through  | Cache → DB on miss       | Depends on implementation     | Simple application code   | Complex cache layer        |
| Write-Through | Cache                    | Cache → DB synchronously      | Fresh cache               | Higher write latency       |
| Write-Behind  | Cache                    | Cache → DB asynchronously     | Very fast writes          | Data-loss/consistency risk |
| Write-Around  | Cache → DB on miss       | Directly DB                   | Avoid unnecessary caching | First read miss            |

---

# 7. Why Not Just Use One Strategy?

Because **read and write workloads are different**.

### Scenario 1 — Read Heavy

```text
1M reads
10K writes
```

Use:

```text
Cache-Aside
```

Because the priority is reducing DB reads.

---

### Scenario 2 — Write Heavy

```text
1M writes
100K reads
```

Consider:

```text
Write-Behind
```

if eventual consistency is acceptable.

---

### Scenario 3 — Need Fresh Cache

```text
Frequent reads
Frequent writes
Stale data is undesirable
```

Consider:

```text
Write-Through
```

---

### Scenario 4 — Data Is Written But Rarely Read

```text
1M writes
10K reads
```

Consider:

```text
Write-Around
```

There is little value in filling the cache with data that nobody reads.

---

# 8. Common Combination in Real Systems

Strategies are not necessarily alternatives.

They can be **combined**.

A common design is:

```text
READ:

Application
    |
    v
  Redis
    |
    +--- HIT ---> Return
    |
    +--- MISS
          |
          v
         DB
          |
          v
       Redis
          |
          v
        Return
```

This is:

```text
Cache-Aside
```

For writes:

```text
Application
    |
    v
   DB
    |
    v
Delete/Invalidate Cache
```

So the overall system uses:

```text
Read  → Cache-Aside
Write → DB + Cache Invalidation
```

This is a **very common practical design**.

---

# 9. Quick Decision Guide

```text
Need simple caching?
        ↓
Cache-Aside


Want cache to load DB automatically?
        ↓
Read-Through


Need cache and DB updated synchronously?
        ↓
Write-Through


Need extremely fast writes?
        ↓
Write-Behind


Data is written frequently but rarely read?
        ↓
Write-Around
```

---

# 10. Easy Interview Recall

```text
READ STRATEGIES
===============

Cache-Aside:
App checks Cache
MISS → DB → Cache

Read-Through:
App → Cache
Cache MISS → DB


WRITE STRATEGIES
================

Write-Through:
Write → Cache → DB
Synchronous

Write-Behind:
Write → Cache → DB later
Asynchronous

Write-Around:
Write → DB
Cache populated on later read


WHY MULTIPLE STRATEGIES?
========================

Different requirements:

Read-heavy      → Cache-Aside
Fresh cache     → Write-Through
Fast writes     → Write-Behind
Rarely-read data→ Write-Around


MOST COMMON:
============

READ:
Cache-Aside

WRITE:
DB → Invalidate Cache

Why?
Simple + reliable + good performance.
```

# 11. One-Line Interview Answer

> **"We have multiple cache strategies because systems have different read/write workloads and consistency requirements. Cache-Aside is a common choice for reads, while Write-Through favors consistency, Write-Behind favors write performance, and Write-Around avoids filling the cache with rarely-read data."**
