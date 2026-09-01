# Application Performance & Response Time — System Design Interview Notes

## Interview Question

**How can you improve the performance and response time of an existing or new application?**

---

## 1. Start With the Most Important Principle

> **Don't optimize blindly. First measure, identify the bottleneck, fix it, and measure again.**

Typical bottlenecks can be:

- Slow database queries
- Too many database calls
- High network latency
- Slow external APIs
- Heavy application processing
- Large response payloads
- Too much traffic on one server
- Expensive background tasks

### Basic process

```text
Measure
   ↓
Find bottleneck
   ↓
Optimize
   ↓
Measure again
   ↓
Repeat
```

---

# 2. Database Optimization

The database is often one of the biggest performance bottlenecks.

### Things to do:

- Add proper indexes
- Optimize slow queries
- Avoid unnecessary queries
- Avoid `SELECT *`
- Use pagination
- Use connection pooling
- Avoid N+1 queries
- Use read replicas for heavy read traffic

### Example

Without an index:

```text
Request
   ↓
Application
   ↓
Database scans millions of rows
   ↓
Slow response
```

With an index:

```text
Request
   ↓
Application
   ↓
Indexed DB query
   ↓
Fast response
```

### Recall

> **First optimize the database before jumping to complicated solutions like sharding.**

---

# 3. Caching

Use caching when the same data is requested frequently.

Common technology:

**Redis**

### Without cache

```text
User
 ↓
Application
 ↓
Database
 ↓
Response
```

### With cache

```text
User
 ↓
Application
 ↓
Redis
 ↓
Cache HIT → Response
```

If cache misses:

```text
Redis → MISS
   ↓
Database
   ↓
Redis
   ↓
Response
```

### Good candidates for caching

- User profiles
- Product information
- Popular posts
- Configuration
- Frequently accessed data
- Sessions

### Recall

> **Cache frequently read data to reduce database load and improve latency.**

---

# 4. Reduce Network Calls

Too many API calls increase response time.

### Example

Bad:

```text
GET /user
GET /profile
GET /posts
GET /followers
GET /notifications
```

Five separate requests can increase network overhead.

If appropriate, combine related data:

```text
GET /dashboard
```

### Also consider:

- Keep responses small
- Compress responses
- Use HTTP/2 or HTTP/3 where appropriate
- Avoid unnecessary API calls

### Recall

> **Fewer unnecessary network round trips = better response time.**

---

# 5. Reduce Response Size

Don't send unnecessary data to the client.

### Bad

```json
{
  "id": 123,
  "name": "John",
  "profile": "...",
  "100 other unused fields": "..."
}
```

### Better

Return only what the client needs:

```json
{
  "id": 123,
  "name": "John"
}
```

Use:

- Pagination
- Compression
- Field selection
- Smaller JSON responses

### Recall

> **Less data to process and transfer = faster response.**

---

# 6. Asynchronous Processing

Some operations don't need to happen while the user is waiting.

### Example

User uploads an image.

Bad:

```text
Upload
  ↓
Resize image
  ↓
Generate thumbnail
  ↓
Send notification
  ↓
Update analytics
  ↓
Response
```

The user waits for everything.

Better:

```text
Upload
  ↓
Store image
  ↓
Put job in Queue
  ↓
Return response quickly
```

Background workers process the jobs:

```text
                 Queue
              /    |     \
             ↓     ↓      ↓
          Worker Worker  Worker
             ↓     ↓      ↓
          Resize  Email  Analytics
```

Technologies:

- Kafka
- RabbitMQ
- AWS SQS

### Recall

> **Move non-critical and long-running work out of the request path.**

---

# 7. Connection Pooling

Creating a new database connection for every request is expensive.

### Bad

```text
Request
 ↓
Create DB connection
 ↓
Query
 ↓
Close connection
```

### Better

Use a connection pool:

```text
             Connection Pool
            /    |    |    \
           ↓     ↓    ↓     ↓
          DB    DB    DB    DB
```

Applications reuse existing connections.

### Benefit

- Less connection overhead
- Better throughput
- Lower latency

### Recall

> **Reuse connections instead of creating them for every request.**

---

# 8. Load Balancer + Horizontal Scaling

One server eventually becomes a bottleneck.

### Before

```text
Users
  ↓
Server
  ↓
Database
```

### After

```text
              Load Balancer
             /      |      \
            ↓       ↓       ↓
          App 1   App 2   App 3
```

The load balancer distributes requests.

Benefits:

- Higher throughput
- Better availability
- Easy horizontal scaling
- No single application server dependency

### Important

Application servers should preferably be **stateless**.

Don't keep important session state only inside one server's memory.

### Recall

> **Add more servers instead of making one server handle everything.**

---

# 9. CDN

For static content such as:

- Images
- Videos
- JavaScript
- CSS
- Fonts

use a CDN.

### Without CDN

```text
User
 ↓
Application
 ↓
Storage
 ↓
Response
```

### With CDN

```text
User
 ↓
CDN
 ↓
Cached content
```

The CDN serves content from an edge location closer to the user.

### Recall

> **CDN reduces latency and application-server load for static content.**

---

# 10. Database Read Replicas

Suppose the application has:

```text
90% Reads
10% Writes
```

A single database may struggle with the read workload.

Use:

```text
             Application
              /       \
             ↓         ↓
         Primary     Replica
             ↓         ↓
           Writes     Reads
```

The primary handles writes.

Read replicas handle read traffic.

### Recall

> **Use read replicas when database reads become the bottleneck.**

---

# 11. Database Partitioning / Sharding

Only consider this when a single database can no longer handle the scale.

Example:

```text
Users 1 - 1M       → Shard 1
Users 1M - 2M      → Shard 2
Users 2M - 3M      → Shard 3
```

Or:

```text
user_id % number_of_shards
```

### Why not use sharding immediately?

Because it introduces complexity:

- Cross-shard queries
- Data rebalancing
- Transactions
- Hot partitions
- Operational complexity

### Recall

> **Sharding is a last-level scaling technique, not the first optimization.**

---

# 12. Frontend Performance

Backend optimization isn't enough.

For web applications:

### Optimize images

Use modern formats such as:

- WebP
- AVIF

### Lazy loading

Load content only when needed.

```text
Open page
   ↓
Load visible content
   ↓
User scrolls
   ↓
Load more content
```

### Reduce JavaScript

Don't send unnecessary JavaScript to the browser.

### Compress assets

Use:

- Brotli
- Gzip

### Recall

> **Optimize both backend and frontend.**

---

# 13. Rate Limiting

A sudden traffic spike or abusive client can slow down the entire system.

Example:

```text
Client
  ↓
100,000 requests/sec
  ↓
Application overloaded
```

Use rate limiting:

```text
Client
  ↓
Rate Limiter
  ↓
Allowed → Application
Rejected → 429 Too Many Requests
```

### Recall

> **Rate limiting protects the application from excessive traffic.**

---

# 14. Monitoring

You need monitoring to know whether the system is actually improving.

### Application metrics

- CPU
- Memory
- Request rate
- Error rate
- Response latency

### Database metrics

- Query latency
- CPU
- Connections
- Slow queries
- Replication lag

### Cache metrics

- Cache hit ratio
- Memory usage
- Evictions

### Important latency metrics

```text
P50 → Typical request
P95 → Slow requests
P99 → Very slow requests
```

Example:

```text
Before optimization:
P95 = 800 ms

After optimization:
P95 = 250 ms
```

Now we know the optimization improved performance.

---

# 15. Complete Performance Architecture

A scalable application may eventually look like this:

```text
                         Users
                           |
                           ↓
                          CDN
                           |
                           ↓
                    Load Balancer
                           |
              +------------+------------+
              |            |            |
              ↓            ↓            ↓
            App 1        App 2        App 3
              |            |            |
              +------------+------------+
                           |
                 +---------+---------+
                 |                   |
                 ↓                   ↓
               Redis               Database
                                   /       \
                                  ↓         ↓
                              Primary     Replica
                                  |
                                  ↓
                                Queue
                                  |
                                  ↓
                               Workers
                                  |
                                  ↓
                            Object Storage
```

---

# 16. Optimization Order

A good practical order is:

```text
1. Measure
      ↓
2. Find bottleneck
      ↓
3. Optimize code / queries
      ↓
4. Add database indexes
      ↓
5. Add caching
      ↓
6. Reduce network calls / payload
      ↓
7. Async processing
      ↓
8. Load balancing
      ↓
9. Horizontal scaling
      ↓
10. Read replicas
      ↓
11. CDN
      ↓
12. Partitioning / Sharding
```

Don't blindly follow this order. The actual bottleneck determines what you do next.

---

# 17. Existing Application vs New Application

## Existing Application

Don't immediately rewrite the whole application.

Follow:

```text
Measure
  ↓
Find bottleneck
  ↓
Fix bottleneck
  ↓
Measure
  ↓
Repeat
```

### Example

API takes 2 seconds.

Investigation shows:

```text
Application = 200 ms
Database = 1.5 sec
Network = 300 ms
```

Database is the bottleneck.

So:

```text
Optimize query
     ↓
Add index
     ↓
Measure
     ↓
Add cache if necessary
```

---

## New Application

Start simple but design with future scalability in mind.

Initial architecture:

```text
Users
  ↓
Load Balancer
  ↓
Stateless Application
  ↓
Database
  ↓
Cache
```

Then introduce more components only when required.

### Principle

> **Don't build a million-user architecture for ten users.**

---

# 18. Example Interview Scenario

### Interviewer:

> Your API currently takes 2 seconds. How would you improve it?

### Answer:

First, I would measure where the 2 seconds are being spent.

Suppose I discover:

```text
DB query       = 1.2 sec
External API   = 500 ms
Application    = 200 ms
Network        = 100 ms
```

The database is the biggest bottleneck.

I would:

1. Analyze the query.
2. Add or improve indexes.
3. Check for N+1 queries.
4. Reduce unnecessary data.
5. Add caching if the data is frequently accessed.
6. Consider a read replica if read traffic is high.

Then I would measure again.

If the external API remains slow, I might use:

- Caching
- Timeout
- Retry with backoff
- Async processing
- A fallback if appropriate

The key is to optimize based on measurement rather than assumptions.

---

# 19. Quick Interview Q&A

### Q: What is the first thing you do when an application is slow?

> **Measure and identify the bottleneck.**

### Q: Database is slow. What do you do?

> Check slow queries, indexes, query plans, N+1 queries, connection pooling, and caching. If reads are the problem, consider read replicas.

### Q: Redis is full. What do you do?

> Review the cache strategy, TTLs, eviction policy, cached data size, and whether we're caching the right things.

### Q: One application server is overloaded. What do you do?

> Put a load balancer in front and horizontally scale with multiple stateless application servers.

### Q: Image loading is slow. What do you do?

> Optimize image size, use object storage and a CDN, and use lazy loading where appropriate.

### Q: API performs a slow operation taking 10 seconds. What do you do?

> Move the operation to a background worker using a queue if it doesn't need to block the user's request.

### Q: When do you use sharding?

> When a single database can no longer handle the required scale and simpler optimizations are insufficient.

---

# 🧠 FINAL SHORT NOTE — RECALL BEFORE INTERVIEW

## Performance = **M-C-D-A-S**

### **M — Measure**
Find the bottleneck first.

### **C — Cache**
Use Redis for frequently accessed data.

### **D — Database**
Indexes → Query optimization → Connection pooling → Read replicas.

### **A — Async**
Queue + workers for slow background tasks.

### **S — Scale**
Load balancer → Multiple servers → CDN → Partition/Sharding.

---

## ⭐ 10-Second Recall

> **Measure → Find Bottleneck → Optimize DB → Cache → Reduce Network → Async → Scale → Monitor**

## ⭐ Golden Interview Statement

> **"I would not introduce infrastructure just because it is popular. I would first measure the system, identify the actual bottleneck, apply the simplest solution, and measure again."**

That statement shows **practical system-design thinking**, not just knowledge of technologies.