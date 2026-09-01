# Back-of-the-Envelope Estimation — System Design Interview

## 1. What is Back-of-the-Envelope Estimation?

Back-of-the-envelope estimation means making **quick approximate calculations** to understand the scale of a system.

We estimate things like:

- Number of users
- Requests per second (QPS/RPS)
- Read/write ratio
- Storage required
- Bandwidth
- Cache size
- Number of servers

We do NOT need exact numbers.

The goal is to answer:

> "How big does my system need to be?"

---

# 2. Basic Interview Approach

Use this order:

```text
1. Clarify assumptions
       ↓
2. Estimate users
       ↓
3. Estimate requests
       ↓
4. Estimate QPS
       ↓
5. Estimate storage
       ↓
6. Estimate bandwidth
       ↓
7. Estimate cache
       ↓
8. Decide scaling strategy
```

---

# 3. Important Units to Remember

```text
1 Thousand  = 10^3
1 Million   = 10^6
1 Billion   = 10^9
1 Trillion  = 10^12
```

Storage:

```text
1 KB ≈ 10^3 bytes
1 MB ≈ 10^6 bytes
1 GB ≈ 10^9 bytes
1 TB ≈ 10^12 bytes
1 PB ≈ 10^15 bytes
```

For interview estimation, use approximate decimal values.

---

# 4. Most Important Conversion

## Seconds in a Day

```text
60 × 60 × 24
= 86,400 seconds
≈ 100,000 seconds
```

### Interview shortcut:

> **1 day ≈ 100K seconds**

Therefore:

```text
1 Million requests/day
≈ 10 requests/sec
```

Because:

```text
1,000,000 / 100,000
≈ 10 QPS
```

---

# 5. Seconds in a Year

```text
365 × 24 × 60 × 60

= 31,536,000

≈ 31.5 million seconds
```

Interview shortcut:

> **1 year ≈ 31.5M seconds**

---

# 6. QPS / RPS Calculation

QPS = Queries Per Second

RPS = Requests Per Second

Both are commonly used for request rate.

Formula:

```text
QPS = Requests per day / 86,400
```

Approximation:

```text
QPS ≈ Requests per day / 100,000
```

---

# 7. Example — TinyURL

Assume:

```text
100 million new URLs/day
```

Calculate average write QPS:

```text
100,000,000 / 86,400

≈ 1,157 requests/sec
```

Approximate:

```text
≈ 1.2K writes/sec
```

So the system needs to support roughly:

```text
1.2K URL creations/sec average
```

---

# 8. Read vs Write Estimation

Suppose every URL receives an average of 100 redirects.

Then:

```text
Writes = 1.2K/sec

Reads = 1.2K × 100

     ≈ 120K reads/sec
```

So:

```text
Write QPS ≈ 1.2K
Read QPS  ≈ 120K
```

This tells us:

> TinyURL is a **read-heavy system**.

Therefore Redis/cache becomes very important.

---

# 9. Peak Traffic

Never design only for average traffic.

Suppose:

```text
Average QPS = 120K
```

Assume peak traffic is 5× average.

```text
Peak QPS = 120K × 5

         = 600K QPS
```

So I would design the system to handle approximately:

```text
600K requests/sec
```

depending on the required safety margin.

---

# 10. Storage Estimation

Suppose every URL record contains:

```text
short_code     = 8 bytes
long_url       = 500 bytes
metadata       = 100 bytes
timestamps     = 50 bytes
DB overhead    = 100 bytes
```

Approximate:

```text
Total ≈ 758 bytes
```

Round it to:

```text
≈ 1 KB / URL
```

This rounding makes interview calculations easier.

---

# 11. Storage for 1 Billion URLs

If:

```text
1 URL ≈ 1 KB
```

Then:

```text
1 Billion × 1 KB

= 1 TB
```

Therefore:

```text
1B URLs ≈ 1 TB
```

Ignoring replication and additional indexes.

---

# 12. Storage for 356 Billion URLs

Your previous TinyURL requirement was:

```text
356 Billion URLs
```

Assume:

```text
1 KB / URL
```

Then:

```text
356B × 1 KB

≈ 356 TB
```

So raw data is approximately:

```text
356 TB
```

But this is NOT the final storage requirement.

We also need:

- Indexes
- Database overhead
- Replicas
- Backups
- Metadata

---

# 13. Replication

Suppose we use 3 replicas.

```text
Raw storage = 356 TB

Replication factor = 3

356 × 3
= 1,068 TB
≈ 1.1 PB
```

So:

```text
356 TB raw
≈ 1.1 PB with 3 replicas
```

Then add indexes/backups/overhead.

The actual requirement could be higher.

---

# 14. Storage Growth Per Year

Suppose:

```text
356 Billion URLs
over 100 years
```

Average:

```text
356B / 100

= 3.56B URLs/year
```

If each URL is approximately 1 KB:

```text
3.56B × 1 KB

≈ 3.56 TB/year
```

With 3 replicas:

```text
3.56 × 3

≈ 10.7 TB/year
```

This tells us something important:

> We can provision storage gradually instead of buying capacity for 100 years on day one.

---

# 15. Bandwidth Estimation

Suppose every redirect response/request transfers approximately:

```text
2 KB
```

And peak traffic is:

```text
600K requests/sec
```

Then:

```text
600,000 × 2 KB

= 1,200,000 KB/sec
```

Approximately:

```text
= 1.2 GB/sec
```

Therefore:

```text
Bandwidth ≈ 1.2 GB/sec
```

In bits:

```text
1.2 GB × 8
≈ 9.6 Gbps
```

So we need roughly:

```text
≈ 10 Gbps
```

of network capacity for that traffic assumption.

---

# 16. Cache Estimation

Suppose:

```text
Total URLs = 356B
```

We don't need to cache all of them.

Assume:

```text
Top 1% URLs
```

are responsible for most traffic.

If:

```text
1% × 356B
= 3.56B URLs
```

That's still too large for Redis.

So instead estimate the number of **hot URLs** we actually want to cache.

Suppose:

```text
100 million hot URLs
```

and each cached entry requires approximately:

```text
1 KB
```

Then:

```text
100M × 1 KB
≈ 100 GB
```

Add Redis/object overhead and replication.

So perhaps:

```text
100 GB raw cache
→ 200–300 GB+ practical cluster capacity
```

depending on the Redis configuration.

---

# 17. Server Estimation

Suppose one application server can handle:

```text
10K requests/sec
```

Peak traffic:

```text
600K requests/sec
```

Servers required:

```text
600K / 10K
= 60 servers
```

Add 50% capacity for headroom:

```text
60 × 1.5
= 90 servers
```

So approximately:

```text
90 application servers
```

This is only an example.

In a real interview, say:

> "I'd benchmark the actual application because server capacity depends heavily on CPU, memory, request complexity, language/runtime, and network usage."

---

# 18. Database QPS

Suppose:

```text
Read traffic = 120K QPS
```

Redis cache hit rate:

```text
99%
```

Then only:

```text
1% × 120K

= 1,200 QPS
```

reaches the database.

This is a huge difference.

```text
Without cache:

120K QPS → DB

With 99% cache hit:

120K QPS
    ↓
Redis
    ↓
1% misses
    ↓
1.2K QPS → DB
```

This is why caching is so valuable.

---

# 19. Cache Hit Rate

Formula:

```text
Cache Hit Rate =
Cache Hits / Total Requests
```

Example:

```text
Total requests = 100,000
Cache hits     = 99,000

Hit rate = 99%
```

Cache misses:

```text
1%
```

Database traffic:

```text
100,000 × 1%

= 1,000 QPS
```

---

# 20. Capacity Planning

Suppose current traffic is:

```text
100K QPS
```

Expected growth:

```text
20% per year
```

After 3 years:

```text
100K × 1.2 × 1.2 × 1.2

≈ 173K QPS
```

So don't provision exactly for today's traffic.

Keep capacity for:

- Growth
- Traffic spikes
- Failures
- Maintenance
- Rebalancing

---

# 21. Back-of-the-Envelope Example — Twitter/X Style

Assume:

```text
100M daily active users
```

Each user creates:

```text
2 posts/day
```

Total posts:

```text
100M × 2
= 200M posts/day
```

Write QPS:

```text
200M / 100K
≈ 2K writes/sec
```

Suppose each post is viewed 100 times:

```text
200M × 100
= 20B reads/day
```

Read QPS:

```text
20B / 100K
≈ 200K reads/sec
```

So:

```text
Writes ≈ 2K/sec
Reads  ≈ 200K/sec
```

This tells us:

> The system is heavily read-oriented, so caching and read scaling are important.

---

# 22. Quick Estimation Rules

Memorize these:

```text
1 day      ≈ 100K seconds
1 month    ≈ 2.5M seconds
1 year     ≈ 31.5M seconds
```

Therefore:

```text
1M/day     ≈ 10 QPS
10M/day    ≈ 100 QPS
100M/day   ≈ 1K QPS
1B/day     ≈ 10K QPS
10B/day    ≈ 100K QPS
```

---

# 23. Storage Quick Rules

If:

```text
1 KB / record
```

Then:

```text
1M records    ≈ 1 GB
1B records    ≈ 1 TB
100B records  ≈ 100 TB
356B records  ≈ 356 TB
```

If:

```text
10 KB / record
```

Then:

```text
1B records = 10 TB
```

---

# 24. Peak Traffic Rule

If average traffic is:

```text
100K QPS
```

and we assume 5× peak:

```text
Peak = 500K QPS
```

Common interview assumption:

```text
Peak QPS = Average QPS × 2 to 5
```

But always state your assumption.

---

# 25. Read/Write Ratio

Always calculate:

```text
Read QPS
Write QPS
```

Example:

```text
Write = 2K/sec
Read  = 200K/sec
```

Ratio:

```text
200K / 2K
= 100:1
```

So:

```text
Read : Write = 100 : 1
```

This strongly influences architecture.

---

# 26. What Estimation Tells You

### High QPS

Need:

```text
Load Balancer
Horizontal Scaling
Caching
CDN
```

### High Storage

Need:

```text
Partitioning
Sharding
Distributed Database
Object Storage
```

### High Read Traffic

Need:

```text
Redis
Read Replicas
CDN
```

### High Write Traffic

Need:

```text
Distributed ID Generator
Write Scaling
Queues
Partitioning
```

### High Growth

Need:

```text
Auto Scaling
Capacity Planning
Elastic Storage
```

---

# 27. How to Present Estimation in an Interview

Don't silently calculate.

Say:

> "Let me make a few assumptions first."

Then:

```text
Users = 100M/day
Actions/user = 2/day

Writes:
100M × 2 = 200M/day

QPS:
200M / 100K ≈ 2K/sec

Assume 100 reads per write:

Reads:
2K × 100 = 200K/sec

Assume 5× peak:

Peak:
200K × 5 = 1M/sec
```

Then conclude:

> "So I need roughly 2K writes/sec and 200K average reads/sec, with capacity for around 1M peak requests/sec. This suggests a horizontally scalable application tier with heavy caching and a distributed storage layer."

---

# 28. Common Mistakes

### Mistake 1: Trying to be exact

Don't waste time calculating:

```text
86,400 exactly
```

Use:

```text
≈ 100K
```

---

### Mistake 2: Forgetting peak traffic

Don't design for average only.

```text
Average → Peak
```

---

### Mistake 3: Forgetting replication

Raw storage:

```text
100 TB
```

does NOT mean you only need 100 TB.

With 3 replicas:

```text
100 × 3 = 300 TB
```

---

### Mistake 4: Forgetting indexes

Database storage includes:

```text
Data
+
Indexes
+
Metadata
+
Replication
+
Backups
```

---

### Mistake 5: Saying "one server can handle X" without qualification

Always say:

> "Assuming one server can handle X QPS; this should be validated with benchmarking."

---

# 29. TinyURL Final Estimation Example

Given:

```text
356B URLs
100 years
```

Average URL creation:

```text
356B / 100 years
≈ 113 URLs/sec
```

Assume:

```text
100 redirects per URL
```

Average redirect rate:

```text
113 × 100
≈ 11.3K reads/sec
```

Assume:

```text
1 KB / URL
```

Storage:

```text
356B × 1 KB
≈ 356 TB raw
```

With 3 replicas:

```text
≈ 1.1 PB
```

This is before additional indexes, backups, and operational overhead.

### Important conclusion

The **356 billion total URLs sounds huge**, but the average creation rate is only about **113 URLs/sec** over 100 years.

The real scaling challenge is likely to be:

```text
Redirect QPS
+
Peak traffic
+
Database size
+
Availability
```

rather than URL creation itself.

---

# 🧠 FINAL RECALL SHEET

## Estimation Formula

```text
DAU
 ↓
Actions/User/Day
 ↓
Requests/Day
 ↓
QPS
 ↓
Peak QPS
 ↓
Storage
 ↓
Bandwidth
 ↓
Servers
```

## Must-Know Formulas

```text
QPS = Requests/day ÷ 86,400

Approx:
QPS ≈ Requests/day ÷ 100K

Storage =
Number of records × Size per record

Bandwidth =
QPS × Request/Response size

Servers =
Peak QPS ÷ QPS per server

DB QPS =
Total QPS × (1 - Cache Hit Rate)
```

## Must-Remember Numbers

```text
1 day  ≈ 100K seconds
1 year ≈ 31.5M seconds

1M/day   ≈ 10 QPS
100M/day ≈ 1K QPS
1B/day   ≈ 10K QPS

1B records × 1KB
≈ 1TB
```

## Interview Mindset

**Don't chase exact numbers.**

Use:

```text
Assumption
   ↓
Approximation
   ↓
Calculation
   ↓
Scale
   ↓
Architecture Decision
```

### ⭐ One-Line Recall

> **"Estimate users → requests → QPS → peak QPS → storage → bandwidth → servers, then use these numbers to justify caching, replication, sharding, and horizontal scaling."**