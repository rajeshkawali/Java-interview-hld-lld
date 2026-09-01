# CACHE & CACHE ALGORITHMS — SYSTEM DESIGN INTERVIEW NOTES

---

# 1. What is a Cache?

A **cache** is a fast storage layer used to keep frequently accessed data so that future requests can be served faster.

Usually:

```text
Application
    ↓
  Cache
    ↓
 Database
```

Instead of going to the database every time:

```text
Request → Cache → Data
```

This is much faster than:

```text
Request → Database → Data
```

---

# 2. Why Do We Need Cache?

Main reasons:

```text
1. Reduce latency
2. Reduce database load
3. Increase throughput
4. Improve application performance
5. Handle traffic spikes
6. Reduce expensive computations/database queries
```

### Example

Suppose:

```text
Database response = 100 ms
Cache response    = 2 ms
```

If the same product is requested 10,000 times:

Without cache:

```text
10,000 requests
       ↓
Database
```

With cache:

```text
10,000 requests
       ↓
Cache
       ↓
Most requests served from cache
       ↓
Database receives far fewer requests
```

---

# 3. Basic Cache Architecture

```text
              Client
                |
                ↓
           Application
                |
           ┌────┴────┐
           ↓         ↓
        Cache      Database
```

Typical request:

```text
1. Check Cache
2. If found → return data
3. If not found → query DB
4. Store result in Cache
5. Return result
```

---

# 4. Cache Hit vs Cache Miss

## Cache Hit

Requested data exists in cache.

```text
Application
    ↓
 Cache
    ↓
  FOUND
    ↓
 Return Data
```

Fast.

---

## Cache Miss

Requested data does not exist.

```text
Application
    ↓
 Cache
    ↓
 NOT FOUND
    ↓
 Database
    ↓
 Cache
    ↓
 Application
```

### Recall

> **Hit = data found in cache.**  
> **Miss = data not found in cache.**

---

# 5. Cache Hit Ratio

Cache performance is often measured using **cache hit ratio**.

```text
Cache Hit Ratio =
Cache Hits / Total Requests
```

Example:

```text
Total requests = 1,000
Cache hits     = 900
```

Therefore:

```text
Hit Ratio = 900 / 1000
          = 90%
```

A higher hit ratio generally means more requests are served from the cache.

---

# 6. Cache Miss Ratio

```text
Miss Ratio =
Cache Misses / Total Requests
```

Example:

```text
1,000 requests
100 misses
```

```text
Miss Ratio = 10%
```

And:

```text
Hit Ratio + Miss Ratio = 100%
```

---

# 7. Where Can We Cache?

Caching can happen at different layers.

```text
Client
  ↓
Browser Cache
  ↓
CDN
  ↓
Application Cache
  ↓
Distributed Cache
  ↓
Database
```

Examples:

```text
Browser Cache
CDN Cache
Redis
Memcached
In-memory cache
Database buffer/cache
```

---

# 8. Types of Cache

## 1. Local / In-Memory Cache

Cache lives inside the application process.

```text
Application
    |
    ↓
Local Memory
```

Examples:

```text
Caffeine
Guava Cache
ConcurrentHashMap-based cache
```

### Advantages

- Extremely fast
- No network call
- Simple
- Low latency

### Disadvantages

- Limited by application memory
- Each server has its own cache
- Data may become inconsistent between instances
- Cache disappears when instance restarts

---

# 9. Distributed Cache

Cache is stored in a separate distributed system.

```text
App 1 ─┐
App 2 ─┼──→ Redis
App 3 ─┘
```

Examples:

```text
Redis
Memcached
```

### Advantages

- Shared by multiple application instances
- Larger capacity
- Independent of application lifecycle
- Useful for distributed systems

### Disadvantages

- Network latency
- Additional infrastructure
- Cache cluster can fail
- Operational complexity

### Recall

```text
Local Cache
→ Fastest, but instance-local

Distributed Cache
→ Shared, scalable, but network dependency
```

---

# 10. Cache-Aside Pattern

This is one of the most common caching patterns.

Application manages the cache.

### Read

```text
Application
     |
     ↓
   Cache
     |
     | HIT
     ↓
   Return
```

On miss:

```text
Application
     |
     ↓
   Cache
     |
   MISS
     |
     ↓
  Database
     |
     ↓
   Cache
     |
     ↓
 Application
```

### Pseudocode

```text
getProduct(id):

    value = cache.get(id)

    if value exists:
        return value

    value = database.get(id)

    cache.set(id, value)

    return value
```

### Advantages

- Simple
- Application controls caching
- Database remains source of truth

### Disadvantages

- Cache miss causes DB request
- Possible stale data
- Cache warming may be required

### Recall

> **Cache-Aside = Application reads cache first; on miss, reads DB and populates cache.**

---

# 11. Read-Through Cache

Application asks the cache for data.

The cache itself loads data from the database when the data is missing.

```text
Application
    ↓
  Cache
    |
    | MISS
    ↓
 Database
```

Application does not directly load the data.

### Advantages

- Simplifies application code
- Cache manages loading

### Disadvantages

- Cache layer becomes more complex
- Database integration is required

### Difference

```text
Cache-Aside
→ Application loads DB data into cache

Read-Through
→ Cache loads DB data
```

---

# 12. Write-Through Cache

Data is written to cache and database together.

```text
Application
     |
     ↓
   Cache
     |
     ↓
 Database
```

The write is considered successful only after the configured write path completes.

### Advantages

- Cache remains relatively fresh
- Easier read consistency

### Disadvantages

- Higher write latency
- Every write involves cache + DB
- More complexity

### Recall

> **Write-Through = Write cache and DB together.**

---

# 13. Write-Behind / Write-Back Cache

Application writes to cache first.

Database update happens asynchronously later.

```text
Application
     |
     ↓
   Cache
     |
     | Async
     ↓
 Database
```

### Advantages

- Very fast writes
- Can batch database writes
- Reduces immediate DB load

### Disadvantages

- Data-loss risk if cache fails before persistence
- Eventual consistency
- More complex recovery

### Recall

> **Write-Back = Write cache now, DB later.**

---

# 14. Write-Around Cache

Write goes directly to the database.

Cache is populated only when data is subsequently read.

```text
Write:

Application
    ↓
Database

Read:

Application
    ↓
Cache
    ↓
Database on miss
```

Useful when:

```text
Data is written frequently
+
Rarely read immediately
```

### Advantages

- Avoids filling cache with rarely-read data
- Reduces cache pollution

### Disadvantages

- First read after write is a cache miss
- More DB reads initially

---

# 15. Cache Pattern Comparison

| Pattern | Write Path | Read Path | Main Benefit |
|---|---|---|---|
| Cache-Aside | DB usually | Cache → DB on miss | Simple |
| Read-Through | Cache manages load | Cache | Simple application |
| Write-Through | Cache + DB | Cache | Fresh cache |
| Write-Back | Cache → async DB | Cache | Fast writes |
| Write-Around | DB | Cache → DB | Avoid cache pollution |

---

# 16. Cache Eviction

Cache memory is limited.

Suppose cache can store:

```text
1 million items
```

but application wants to cache:

```text
10 million items
```

We need to decide:

> Which items should be removed?

This is called:

**Cache Eviction.**

---

# 17. LRU — Least Recently Used

Remove the item that has not been accessed for the longest time.

Example:

```text
Cache capacity = 3

A
B
C
```

Access:

```text
A
B
C
A
```

Now add:

```text
D
```

The least recently used item is:

```text
B
```

So:

```text
A
C
D
```

### Advantages

- Simple
- Very common
- Works well when recently accessed data is likely to be accessed again

### Disadvantages

- Requires tracking access order
- Can be expensive at very large scale if implemented poorly
- May not work well when access patterns are highly unusual

### Recall

> **LRU = Remove the item used longest ago.**

---

# 18. LFU — Least Frequently Used

Remove the item accessed the fewest times.

Example:

```text
A → 100 accesses
B → 20 accesses
C → 5 accesses
```

If eviction is required:

```text
Remove C
```

because it has the lowest frequency.

### Advantages

- Keeps frequently used data
- Useful when popularity matters

### Disadvantages

- More complex
- Requires frequency tracking
- Old popular items can remain too long without aging/decay

### Recall

> **LFU = Remove the least frequently accessed item.**

---

# 19. FIFO — First In, First Out

Remove the item that entered the cache first.

Example:

```text
A → first
B
C → latest
```

If D is added:

```text
Remove A
```

### Advantages

- Extremely simple
- Low bookkeeping

### Disadvantages

- Ignores popularity
- Ignores recent usage
- Can remove frequently used data

### Recall

> **FIFO = Remove the oldest inserted item.**

---

# 20. MRU — Most Recently Used

Opposite of LRU.

Remove the item accessed most recently.

```text
A
B
C
```

If:

```text
C = most recently used
```

then evict:

```text
C
```

This is useful only for certain access patterns.

### Recall

> **MRU = Remove the newest recently used item.**

---

# 21. Random Replacement

Choose an item randomly.

```text
A
B
C
D
```

Randomly select:

```text
B
```

and remove it.

### Advantages

- Very simple
- Low bookkeeping
- Can work surprisingly well in some workloads

### Disadvantages

- Can remove valuable/hot data
- No awareness of usage

### Recall

> **Random = Evict randomly.**

---

# 22. TTL — Time To Live

TTL means an item automatically expires after a specified duration.

Example:

```text
Cache:

User ID = 123
TTL = 10 minutes
```

After 10 minutes:

```text
Entry expires
```

### Good For

```text
OTP/session data
Temporary data
Frequently changing data
API responses
Configuration
```

### Advantages

- Prevents data from remaining indefinitely
- Simple freshness mechanism
- Automatically removes stale data

### Disadvantages

- Expiration can cause cache misses
- Choosing the right TTL is difficult
- TTL does not guarantee immediate invalidation when source data changes

### Recall

> **TTL = Automatically expire data after a time.**

---

# 23. LRU vs LFU vs FIFO vs TTL

| Algorithm | Evicts Based On | Best For |
|---|---|---|
| LRU | Least recent access | General-purpose caching |
| LFU | Lowest frequency | Popularity-based workloads |
| FIFO | Oldest insertion | Simple workloads |
| MRU | Most recent access | Special access patterns |
| Random | Random selection | Simplicity |
| TTL | Age/time | Freshness requirements |

---

# 24. Cache Invalidation

One of the hardest problems in caching is:

> **How do we remove/update stale data?**

Example:

Database:

```text
Product price = ₹100
```

Cache:

```text
Product price = ₹100
```

Database changes:

```text
₹100 → ₹120
```

But cache still contains:

```text
₹100
```

Now users receive stale data.

---

# 25. Cache Invalidation Strategies

## 1. TTL

Let the old value expire.

```text
Cache
 ↓
TTL expires
 ↓
New DB value
```

Simple but temporarily stale.

---

## 2. Explicit Invalidation

When database changes:

```text
Update DB
   ↓
Delete cache key
```

Example:

```text
UPDATE product
DELETE cache:product:123
```

Next request loads the latest value.

---

## 3. Update Cache

Instead of deleting:

```text
Update DB
   ↓
Update Cache
```

Useful when cache freshness is important.

---

## 4. Event-Based Invalidation

Database/service publishes an event:

```text
ProductUpdated
       ↓
Message Broker
       ↓
Cache Service
       ↓
Invalidate product:123
```

Useful in distributed systems.

---

# 26. Cache Stampede

Suppose a popular cache entry expires.

```text
Popular Product
       ↓
Cache expires
       ↓
10,000 requests arrive
       ↓
All miss cache
       ↓
10,000 DB queries
```

Database can become overloaded.

This is called:

> **Cache Stampede / Thundering Herd**

---

# 27. How to Prevent Cache Stampede?

Common techniques:

```text
1. Locking / Request Coalescing
2. Early Refresh
3. Randomized TTL / TTL Jitter
4. Background Refresh
5. Stale-While-Revalidate
6. Cache Warming
```

---

## Request Coalescing

Only one request loads the missing value.

```text
10,000 requests
       ↓
Cache MISS
       ↓
One request → DB
       ↓
Populate cache
       ↓
Other requests → Cache
```

---

# 28. Cache Penetration

Cache penetration occurs when requests repeatedly ask for data that does not exist.

Example:

```text
User ID = 999999999
```

Database has no such user.

Request flow:

```text
Request
 ↓
Cache MISS
 ↓
DB MISS
```

If repeated thousands of times:

```text
Cache MISS
Cache MISS
Cache MISS
...
```

Database receives unnecessary requests.

---

# 29. How to Prevent Cache Penetration?

## Negative Caching

Store "not found" temporarily.

```text
user:999
→ NOT_FOUND
TTL = 60 seconds
```

Next request:

```text
Cache → NOT_FOUND
```

No database request.

---

## Bloom Filter

Use a Bloom filter to quickly determine that a key definitely does not exist.

```text
Request
 ↓
Bloom Filter
 ↓
Definitely doesn't exist
 ↓
Reject without DB
```

Important:

> Bloom filters can have false positives, but no false negatives under normal operation.

---

# 30. Cache Avalanche

Cache avalanche occurs when a large number of cache entries expire around the same time.

Example:

```text
1 million keys
TTL = exactly 10 minutes
```

At 10 minutes:

```text
1 million entries expire
       ↓
Huge DB traffic
```

---

# 31. Prevent Cache Avalanche

Use:

```text
TTL Jitter
+
Staggered expiration
+
Background refresh
+
Cache warming
+
Rate limiting
```

Instead of:

```text
TTL = 10 min for everyone
```

use:

```text
TTL = 10 min + random(0-2 min)
```

This spreads expiration over time.

---

# 32. Cache Stampede vs Penetration vs Avalanche

| Problem | Meaning | Example |
|---|---|---|
| Stampede | Same popular key expires and many requests reload it | Hot product expires |
| Penetration | Requests repeatedly ask for nonexistent keys | user=999999 |
| Avalanche | Many cache keys expire together | 1M keys expire simultaneously |

### Memory Trick

```text
Stampede
→ Same key + many requests

Penetration
→ Data doesn't exist

Avalanche
→ Many keys disappear together
```

---

# 33. Hot Key Problem

A **hot key** is a cache key receiving extremely high traffic.

Example:

```text
product:iphone
```

receives:

```text
100,000 requests/sec
```

Even if Redis is healthy, one key can become a bottleneck.

---

# 34. How to Handle Hot Keys?

Techniques:

```text
1. Local caching
2. Replicate hot keys
3. Key sharding
4. CDN caching
5. Request coalescing
6. Rate limiting
```

Example:

```text
Application
   |
   ├── Local Cache
   |
   ↓
Redis
```

Frequently accessed data can be served locally before reaching Redis.

---

# 35. Cache Consistency

Cache introduces another copy of data.

```text
Database
    |
    | Copy
    ↓
 Cache
```

Now we have two states:

```text
DB    → ₹120
Cache → ₹100
```

This is why caching often introduces **staleness**.

We need to decide:

```text
Strong freshness?
OR
Eventual consistency acceptable?
```

---

# 36. Cache Consistency Strategies

### Stronger freshness

Use:

```text
Explicit invalidation
+
Synchronous cache update
+
Short TTL
```

### Eventual consistency

Use:

```text
Longer TTL
+
Async invalidation
+
Event-driven updates
```

The correct choice depends on the business.

---

# 37. Cache Serialization

Distributed caches store data in a serialized format.

Examples:

```text
JSON
Protocol Buffers
MessagePack
Binary formats
```

### JSON

Advantages:

- Human readable
- Easy debugging
- Broad support

Disadvantages:

- Larger payload
- Serialization overhead

### Binary formats

Advantages:

- Smaller
- Faster in many cases

Disadvantages:

- Less human-readable
- Schema/version management required

---

# 38. Cache Key Design

Good cache keys are important.

Example:

```text
user:123
product:456
order:789
```

Avoid unclear keys:

```text
123
456
789
```

Use namespaces:

```text
user:123
product:123
```

This prevents collisions.

---

# 39. Cache Key Versioning

Suppose cache format changes.

Old:

```text
user:123
```

New format:

```text
v2:user:123
```

This allows gradual migration.

Useful when:

```text
Schema changes
Serialization changes
Application versions coexist
```

---

# 40. Cache Size

Cache should not grow without limit.

Define:

```text
Maximum memory
Maximum entries
Eviction policy
TTL
```

Example:

```text
Redis
Memory = 16 GB
Policy = LRU
```

When memory reaches the configured threshold:

```text
Old/less valuable entries
       ↓
Evicted
```

---

# 41. Distributed Cache Architecture

Example using Redis-like distributed caching:

```text
                    Client
                      |
                      ↓
                Load Balancer
                      |
             ┌────────┼────────┐
             ↓        ↓        ↓
           App1     App2     App3
             \        |        /
              \       |       /
               └──────┼──────┘
                      ↓
                Distributed Cache
                      |
                      ↓
                  Database
```

---

# 42. Cache Sharding

A large cache can be divided across nodes.

```text
                 Cache Cluster
              /       |       \
             ↓        ↓        ↓
          Node A    Node B    Node C
```

Keys are distributed using hashing.

```text
hash(key)
   ↓
Node selection
```

For dynamic clusters, **consistent hashing** can reduce remapping.

---

# 43. Cache Replication

For availability:

```text
Primary Cache
     |
     ↓
Replica Cache
```

If primary fails:

```text
Replica
   ↓
Continue serving
```

Benefits:

```text
High availability
Read scaling
Fault tolerance
```

Tradeoff:

```text
More memory
Replication overhead
Potential replication lag
```

---

# 44. Cache Failure

What happens if cache goes down?

A resilient application should not automatically fail completely.

Example:

```text
Application
    ↓
Cache DOWN
    ↓
Database
```

But if traffic is huge:

```text
Cache DOWN
    ↓
All traffic → DB
    ↓
DB overload
```

This is sometimes called a **cache failure/fallback storm**.

Mitigation:

```text
Rate limiting
Circuit breakers
Database protection
Request coalescing
Local cache
Graceful degradation
```

---

# 45. Cache vs Database

| Feature | Cache | Database |
|---|---|---|
| Speed | Very fast | Slower |
| Purpose | Fast access | Persistent storage |
| Durability | Usually limited | Primary concern |
| Capacity | Usually smaller | Usually larger |
| Data | Often derived/copy | Source of truth |
| Cost | More expensive per GB | Usually cheaper per GB |
| Persistence | Optional | Usually required |

### Important

> Cache should generally not be treated as the only source of truth unless the system is explicitly designed around that model.

---

# 46. Cache vs CDN

## Cache

Usually stores application/data objects.

```text
App → Redis
```

## CDN

Caches content close to users geographically.

```text
User
 ↓
Nearest CDN Edge
 ↓
Origin
```

CDN is especially useful for:

```text
Images
Videos
CSS
JavaScript
Static files
Cacheable HTTP responses
```

---

# 47. Cache Algorithms — Quick Comparison

```text
LRU
→ Least Recently Used

LFU
→ Least Frequently Used

FIFO
→ First item inserted is removed first

MRU
→ Most Recently Used is removed

Random
→ Random item removed

TTL
→ Expire after time
```

---

# 48. Which Cache Algorithm Should I Choose?

## Use LRU when:

```text
Recent access predicts future access
```

General-purpose caching is a common use case.

## Use LFU when:

```text
Frequently accessed items should stay longer
```

Useful when popularity is stable and important.

## Use FIFO when:

```text
Simplicity is more important than access patterns
```

## Use TTL when:

```text
Freshness/time-based expiration matters
```

In real systems, TTL is often combined with another eviction policy.

Example:

```text
TTL + LRU
```

---

# 49. Interview Example — Product Catalog

Suppose:

```text
100 million products
```

but only:

```text
10% are frequently viewed
```

Database is expensive to query for every request.

Architecture:

```text
Client
  ↓
Load Balancer
  ↓
Product Service
  ↓
Redis Cache
  ↓
Product DB
```

Read:

```text
Request product:123
       ↓
Redis
       ↓
 HIT → Return
```

Miss:

```text
Redis MISS
     ↓
Product DB
     ↓
Store in Redis
     ↓
Return
```

Use:

```text
Cache-Aside
+
TTL
+
LRU
```

If product changes:

```text
Update DB
    ↓
Delete/update cache
```

---

# 50. Interview Example — User Session

For session data:

```text
Session ID
User ID
Expiration
```

Use distributed cache:

```text
App1 ─┐
App2 ─┼──→ Redis
App3 ─┘
```

Use TTL:

```text
Session TTL = 30 minutes
```

Advantages:

```text
Any application instance can handle the user
```

No sticky session is required.

---

# 51. Interview Example — News/Trending Content

Suppose:

```text
"Top News"
```

is requested millions of times.

Use:

```text
CDN
+
Distributed Cache
+
Local Cache
```

Architecture:

```text
Users
  ↓
CDN
  ↓
Load Balancer
  ↓
App
  ↓
Local Cache
  ↓
Redis
  ↓
DB
```

This reduces pressure on the database.

---

# 52. Common Interview Questions

## Q1. What is caching?

> Caching stores frequently accessed data in a faster storage layer so requests can be served with lower latency and reduced load on the primary data store.

---

## Q2. What is cache hit?

> Requested data exists in the cache.

---

## Q3. What is cache miss?

> Requested data is not present in the cache, so the application must obtain it from another source such as the database.

---

## Q4. What is cache eviction?

> Removing entries from cache when capacity is limited or entries expire.

---

## Q5. LRU vs LFU?

```text
LRU
→ Based on recency

LFU
→ Based on frequency
```

---

## Q6. What is cache invalidation?

> Removing or updating cached data when the underlying source data changes.

---

## Q7. What is cache stampede?

> Many requests simultaneously miss the same cache entry and hit the database, potentially overwhelming it.

---

## Q8. What is cache penetration?

> Repeated requests for nonexistent data bypass the cache and repeatedly hit the database.

---

## Q9. What is cache avalanche?

> Many cache entries expire at approximately the same time, causing a sudden spike in backend traffic.

---

## Q10. How do you prevent cache stampede?

Use:

```text
Request coalescing
Locks
Background refresh
TTL jitter
Stale-while-revalidate
```

---

## Q11. How do you handle cache failure?

> Fail gracefully to the database when possible, while protecting the database with rate limiting, circuit breakers, request coalescing, and appropriate capacity planning.

---

## Q12. How do you handle stale data?

Possible approaches:

```text
TTL
Explicit invalidation
Synchronous cache update
Event-driven invalidation
Versioned keys
```

---

# 53. ⭐ Most Important Cache Patterns

Remember these:

```text
Cache-Aside
→ App checks cache first

Read-Through
→ Cache loads missing data

Write-Through
→ Write cache + DB

Write-Back
→ Write cache, DB asynchronously

Write-Around
→ Write DB directly
```

---

# 54. ⭐ Cache Problems to Remember

```text
CACHE PROBLEMS

Cache Stampede
→ One key expires + many requests

Cache Penetration
→ Requested data doesn't exist

Cache Avalanche
→ Many keys expire together

Hot Key
→ One key gets huge traffic

Stale Data
→ Cache is older than DB

Cache Failure
→ Cache unavailable → DB overload
```

---

# 55. ⭐ 30-SECOND INTERVIEW ANSWER

If interviewer asks:

> "How would you design caching for a high-traffic application?"

Answer:

```text
I would first identify data that is frequently read and
relatively expensive to retrieve.

For a typical read-heavy application, I would use a
distributed cache such as Redis in front of the database
and use the cache-aside pattern.

The application would check the cache first. On a cache
miss, it would read from the database, populate the cache,
and return the result.

I would define TTLs to control staleness and use an
appropriate eviction policy such as LRU.

For data updates, I would use explicit cache invalidation
or update the cache depending on the consistency
requirements.

I would also protect the system against cache stampede,
cache penetration, hot keys, and cache failures using
request coalescing, negative caching, TTL jitter, local
caching, rate limiting, and graceful fallback.

Finally, I would monitor hit ratio, miss ratio, latency,
memory usage, eviction rate, hot keys, and backend load.
```

---

# 56. ⭐ FINAL CACHE MEMORY MAP

```text
                         CACHE
                           |
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
       Purpose          Location         Pattern
          |                |                |
     Reduce latency    Local Cache      Cache-Aside
     Reduce DB load    Redis            Read-Through
     Improve RPS       Memcached        Write-Through
                         CDN             Write-Back
                                         Write-Around
          |
          ↓
      Eviction
          |
   ┌──────┼──────┬──────┐
   ↓      ↓      ↓      ↓
  LRU    LFU    FIFO    TTL
   |
   ↓
 Problems
   |
   ├── Stampede
   ├── Penetration
   ├── Avalanche
   ├── Hot Key
   ├── Stale Data
   └── Cache Failure
```

# ⭐ ONE-LINE RECALL

```text
CACHE
→ Faster reads

CACHE-ASIDE
→ Cache first, DB on miss

LRU
→ Remove least recently used

LFU
→ Remove least frequently used

TTL
→ Expire after time

INVALIDATION
→ Remove/update stale data

STAMPede
→ Same key + many misses

PENETRATION
→ Nonexistent key

AVALANCHE
→ Many keys expire together

HOT KEY
→ One key gets huge traffic
```

# ⭐ FINAL TAKEAWAY

> **Caching improves performance by serving frequently accessed data from a faster layer, but it introduces challenges around eviction, consistency, invalidation, hot keys, stampedes, and cache failures. A good system-design solution chooses the cache pattern, eviction strategy, TTL, and invalidation mechanism according to the application's read/write pattern and consistency requirements.**