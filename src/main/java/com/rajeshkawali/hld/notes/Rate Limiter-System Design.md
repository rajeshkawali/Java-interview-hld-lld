# Rate Limiter — System Design Interview Notes

## 1. What is a Rate Limiter?

A **Rate Limiter** controls how many requests a client can make within a specific period.

### Example

Suppose:

```text
Limit = 100 requests/minute/user
```

If a user sends:

```text
Request 1  → ALLOW
Request 2  → ALLOW
...
Request 100 → ALLOW
Request 101 → REJECT
```

The rate limiter protects the system from:

- Too much traffic
- Abuse
- DDoS-like application-layer traffic
- Accidental traffic spikes
- Expensive API usage

---

# 2. Why Do We Need a Rate Limiter?

Without rate limiting:

```text
User
  ↓
100,000 requests/sec
  ↓
API Servers
  ↓
Database
  ↓
Database overload
  ↓
System failure
```

With rate limiting:

```text
User
  ↓
Rate Limiter
  ↓
100 requests/sec allowed
  ↓
API Servers
```

The rate limiter acts as a **traffic control mechanism**.

---

# 3. Requirements

## Functional Requirements

The rate limiter should:

1. Allow requests within the limit.
2. Reject requests above the limit.
3. Support different limits for different users/APIs.
4. Work across multiple servers.
5. Return useful information when requests are rejected.
6. Support different rate-limiting algorithms.

Example:

```text
Free User:
100 requests/min

Premium User:
1,000 requests/min

Admin:
10,000 requests/min
```

---

## Non-Functional Requirements

We want:

- Very low latency
- High availability
- Horizontal scalability
- Thread safety / atomic updates
- Accurate enough counting
- Fault tolerance
- Low memory usage

The rate limiter should normally add only a small amount of latency to each request.

---

# 4. High-Level Architecture

```text
                    Client
                       |
                       ↓
                Load Balancer
                       |
                       ↓
               ┌───────────────┐
               │ Rate Limiter  │
               └───────┬───────┘
                       |
              ┌────────┴────────┐
              ↓                 ↓
           ALLOW               REJECT
              |                 |
              ↓                 ↓
         API Servers         HTTP 429
              |
              ↓
          Database
```

For a distributed system:

```text
                     Clients
                        |
                        ↓
                  Load Balancer
                        |
          ┌─────────────┼─────────────┐
          ↓             ↓             ↓
       RL Node 1     RL Node 2     RL Node 3
          \             |             /
           \            |            /
            └───────────┼────────────┘
                        ↓
              Distributed Store
                (e.g. Redis)
```

The shared store allows multiple rate-limiter servers to coordinate.

---

# 5. Where Should Rate Limiting Happen?

There are several options.

## Option 1 — API Gateway

```text
Client
 ↓
API Gateway
 ↓
Rate Limiter
 ↓
Application
```

Examples:

- NGINX
- Kong
- Cloud API gateways
- Service mesh / proxy-based controls

### Advantages

- Centralized
- Easy to manage
- Protects backend services early

### Disadvantages

- Gateway can become a bottleneck if poorly designed
- More centralized infrastructure

---

## Option 2 — Application Level

```text
Client
 ↓
Application
 ↓
Rate Limiter
 ↓
Business Logic
```

### Advantages

- Business-specific rules
- Easy to customize

### Disadvantages

- Logic may be duplicated across services
- Application still receives the request before rejection

---

# 6. What Key Should We Rate Limit On?

Common choices:

```text
User ID
IP Address
API Key
Device ID
Endpoint
Tenant ID
```

Example:

```text
rate_limit_key = userId + endpoint
```

For example:

```text
user123:/api/payment
```

could have a different limit from:

```text
user123:/api/profile
```

---

# 7. Types of Rate-Limiting Algorithms

The most important algorithms are:

```text
1. Fixed Window Counter
2. Sliding Window Log
3. Sliding Window Counter
4. Token Bucket
5. Leaky Bucket
```

These are commonly discussed in interviews.

---

# 8. Fixed Window Counter

The easiest algorithm.

Suppose:

```text
Limit = 100 requests/minute
```

Divide time into fixed windows:

```text
12:00:00 - 12:00:59
12:01:00 - 12:01:59
12:02:00 - 12:02:59
```

Maintain a counter for each window.

Example:

```text
12:00 window
count = 100
```

Request 101:

```text
REJECT
```

At 12:01:

```text
counter resets to 0
```

---

## Example

```text
Window: 12:00 - 12:01

Request 1 → count = 1
Request 2 → count = 2
...
Request 100 → count = 100
Request 101 → REJECT
```

---

## Advantages

- Very simple
- Easy to implement
- Low memory usage
- Fast

## Disadvantages

### Boundary Problem

Suppose limit = 100/min.

User sends:

```text
12:00:59 → 100 requests
12:01:00 → 100 requests
```

Potentially:

```text
200 requests
within ~2 seconds
```

So fixed windows can allow bursts around boundaries.

### Recall

> **Fixed Window = Simple + Fast, but has boundary burst problem.**

---

# 9. Sliding Window Log

Instead of storing only a counter, store timestamps of requests.

Example:

```text
Limit = 3 requests/minute
```

Requests:

```text
10:00:01
10:00:10
10:00:30
```

Next request:

```text
10:00:40
```

Count requests from:

```text
09:59:40 → 10:00:40
```

If there are already 3:

```text
REJECT
```

---

## Advantages

- Very accurate
- No fixed-window boundary problem

## Disadvantages

- Stores many timestamps
- High memory usage
- More expensive at high traffic

### Recall

> **Sliding Log = Accurate, but memory-heavy.**

---

# 10. Sliding Window Counter

This is a compromise between:

```text
Fixed Window
+
Sliding Window Log
```

Instead of storing every timestamp, maintain counters for windows and estimate the current sliding-window count.

Example:

```text
Previous window:
80 requests

Current window:
20 requests
```

Suppose 50% of the current window has elapsed.

An approximate count can be calculated using the previous window's weighted contribution:

```text
estimated count
≈ previous_count × remaining_fraction
  + current_count
```

For example:

```text
Previous = 80
Remaining fraction = 0.5
Current = 20

Estimated =
80 × 0.5 + 20
= 60
```

If limit = 100:

```text
ALLOW
```

### Advantages

- Less memory than a full sliding log
- More accurate than fixed windows
- Good distributed-system trade-off

### Disadvantages

- Approximation
- More complex than fixed window

### Recall

> **Sliding Counter = Good balance between accuracy and memory.**

---

# 11. Token Bucket

One of the most important algorithms for interviews.

Imagine a bucket containing tokens.

Example:

```text
Bucket capacity = 10 tokens
Refill rate = 2 tokens/sec
```

Each request consumes one token.

```text
Request
   ↓
Token available?
 ├── YES → Consume token → ALLOW
 └── NO  → REJECT / WAIT
```

---

# 12. Token Bucket Example

Suppose:

```text
Capacity = 5
Refill = 1 token/sec
```

Initially:

```text
Bucket = 5 tokens
```

Five requests:

```text
Request 1 → 4
Request 2 → 3
Request 3 → 2
Request 4 → 1
Request 5 → 0
```

Request 6:

```text
No token
↓
REJECT
```

After 1 second:

```text
1 token added
```

Request 6:

```text
ALLOW
```

---

# 13. Why Token Bucket is Popular

It supports controlled bursts.

Example:

```text
Capacity = 100
Refill = 10/sec
```

A user can immediately send up to 100 requests if the bucket is full.

After that, requests are limited by the refill rate.

This gives us:

```text
Burst capacity
+
Average rate control
```

---

## Advantages

- Supports bursts
- Efficient
- Low memory
- Flexible
- Good for APIs

## Disadvantages

- More complex than fixed window
- Distributed implementation needs atomic state updates

### Recall

> **Token Bucket = Tokens + Refill Rate + Burst Capacity.**

---

# 14. Leaky Bucket

Imagine requests entering a bucket.

The bucket processes requests at a fixed rate.

```text
Requests
   ↓
┌─────────────┐
│    Queue    │
│             │
└──────┬──────┘
       ↓
Fixed processing rate
       ↓
     Server
```

Example:

```text
Incoming = 1000 requests/sec
Processing = 100 requests/sec
```

Requests are processed at approximately:

```text
100 requests/sec
```

until the queue fills.

---

## Advantages

- Smooth traffic
- Prevents sudden bursts from reaching backend
- Useful for traffic shaping

## Disadvantages

- Queue can introduce latency
- Requests can be dropped when queue is full
- Less flexible for burst-friendly APIs

### Recall

> **Leaky Bucket = Smooth, constant output rate.**

---

# 15. Token Bucket vs Leaky Bucket

| Token Bucket | Leaky Bucket |
|---|---|
| Allows controlled bursts | Smooths traffic |
| Uses tokens | Often uses a queue |
| Refill rate controls average rate | Processing rate controls output |
| Good for APIs | Good for traffic shaping |
| Burst-friendly | Burst-resistant |

### Easy Recall

```text
Token Bucket
→ "You can burst if you saved tokens."

Leaky Bucket
→ "I will process at a controlled rate."
```

---

# 16. Fixed Window vs Sliding Window vs Token Bucket

| Algorithm | Accuracy | Memory | Burst | Complexity |
|---|---|---|---|---|
| Fixed Window | Medium/Low | Low | Boundary bursts | Low |
| Sliding Log | High | High | Controlled | High |
| Sliding Counter | Medium/High | Low/Medium | Controlled | Medium |
| Token Bucket | Good | Low | Yes | Medium |
| Leaky Bucket | Good | Low/Medium | Limited | Medium |

---

# 17. Which Algorithm Should I Choose?

### Simple API

Use:

```text
Fixed Window
```

### Accurate limiting

Use:

```text
Sliding Window Log
```

### Balance between accuracy and memory

Use:

```text
Sliding Window Counter
```

### API rate limiting with bursts

Use:

```text
Token Bucket
```

### Smooth traffic processing

Use:

```text
Leaky Bucket
```

### Interview Default

> **For a general API rate limiter, Token Bucket is often a strong default because it supports controlled bursts while enforcing an average rate.**

---

# 18. Distributed Rate Limiter

This is the most important system-design part.

Suppose we have:

```text
Server A
Server B
Server C
```

A user sends requests across all three servers.

If each server keeps its own counter:

```text
Server A → 50
Server B → 50
Server C → 50
```

The user could effectively make:

```text
150 requests
```

even if the limit is:

```text
100
```

This is incorrect.

---

# 19. Solution — Shared Distributed Store

Use a shared fast data store:

```text
          API Servers
        /      |      \
       ↓       ↓       ↓
     RL-1    RL-2    RL-3
        \      |      /
         \     |     /
          ↓    ↓    ↓
       Redis Cluster
```

All rate-limiter instances access the same logical rate-limit state.

---

# 20. Why Redis?

Redis is commonly used because it provides:

- Very low latency
- Atomic operations
- TTL/expiration
- In-memory performance
- Distributed deployment options

Example state:

```text
key = rate:user123:/api/orders
```

Value might contain:

```text
tokens = 7
lastRefill = timestamp
```

For a fixed window:

```text
key = rate:user123:2026-08-31T20:46
count = 73
TTL = remaining window time
```

---

# 21. Atomicity Problem

Imagine two requests arrive simultaneously.

```text
Request A → read count = 99
Request B → read count = 99
```

Both increment:

```text
A → 100
B → 100
```

Both may be allowed incorrectly.

Therefore, we need an **atomic check-and-update** operation.

Possible solutions:

- Redis Lua script
- Atomic Redis commands where sufficient
- Server-side scripting/transactions depending on algorithm
- Database primitives designed for atomic conditional updates

---

# 22. Token Bucket in Distributed System

Store:

```text
key = user:123
```

Data:

```text
tokens
last_refill_time
```

For every request:

```text
1. Read current state atomically
2. Calculate elapsed time
3. Add refill tokens
4. Cap at bucket capacity
5. Check token availability
6. Consume token if available
7. Save updated state
```

All steps should happen atomically.

---

# 23. Token Bucket Formula

Let:

```text
capacity = C
refillRate = R tokens/sec
elapsed = time since last update
tokens = current tokens
```

Calculate:

```text
newTokens =
min(
    C,
    tokens + elapsed × R
)
```

Then:

```text
if newTokens >= 1:

    newTokens = newTokens - 1
    ALLOW

else:

    REJECT
```

---

# 24. HTTP Response

When rate limit is exceeded:

```http
HTTP 429 Too Many Requests
```

Example:

```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests"
}
```

Useful headers can include:

```text
Retry-After
```

and, where appropriate, limit/remaining information.

---

# 25. Retry-After

Example:

```http
HTTP/1.1 429 Too Many Requests
Retry-After: 5
```

Meaning:

> Try again after approximately 5 seconds.

This is especially useful when clients implement retries.

---

# 26. Multi-Level Rate Limiting

Real systems often use multiple limits.

Example:

```text
Per IP:
100 requests/min

Per User:
1,000 requests/min

Per API:
10,000 requests/sec

Global:
100,000 requests/sec
```

Request:

```text
Client
 ↓
IP limit
 ↓
User limit
 ↓
Endpoint limit
 ↓
Global limit
 ↓
API
```

Reject if any required limit is exceeded.

---

# 27. Rate Limit by Endpoint

Different APIs may have different costs.

Example:

```text
GET /profile
→ 1 request unit

POST /payment
→ 10 request units

POST /report
→ 50 request units
```

Instead of counting every request equally, use **weighted rate limiting**.

Example:

```text
Token cost:

profile → 1 token
payment → 10 tokens
report  → 50 tokens
```

This protects expensive APIs better.

---

# 28. Rate Limiting by User Tier

Example:

```text
Free:
100 req/min

Pro:
1,000 req/min

Enterprise:
10,000 req/min
```

The rate limiter checks:

```text
userId
   ↓
User plan
   ↓
Rate limit configuration
   ↓
Apply correct policy
```

Keep policy/configuration separate from the request counters.

---

# 29. Fail Open vs Fail Closed

What happens if Redis/rate-limit infrastructure is unavailable?

## Fail Open

Allow requests.

```text
Rate limiter unavailable
        ↓
Allow traffic
```

### Advantage

Application remains available.

### Disadvantage

Traffic may exceed intended limits.

---

## Fail Closed

Reject requests.

```text
Rate limiter unavailable
        ↓
Reject traffic
```

### Advantage

Protects backend.

### Disadvantage

Can cause an outage even when the application itself is healthy.

### Interview Answer

> The choice depends on the endpoint and business risk. For critical or expensive operations, fail-closed or a conservative fallback may be appropriate; for less critical APIs, fail-open may provide better availability.

---

# 30. What Happens if Redis Fails?

Possible strategies:

### Option 1

Fail open.

### Option 2

Use local fallback limits.

```text
Redis unavailable
 ↓
Local limiter
```

### Option 3

Use multiple Redis nodes / highly available distributed storage.

### Option 4

Fail closed for sensitive endpoints.

The correct choice depends on business requirements.

---

# 31. Hot Key Problem

Suppose one user becomes extremely active:

```text
user123
   ↓
1 million requests/sec
```

All requests access:

```text
rate:user123
```

This can create a hot key.

### Solutions

- Local pre-limiting
- Hierarchical rate limiting
- Distribute/shard state where semantics permit
- Cache configuration locally
- Protect especially hot tenants/users with dedicated limits

---

# 32. Hierarchical Rate Limiting

Use two levels:

```text
Client
 ↓
Local Limiter
 ↓
Distributed Limiter
 ↓
API
```

Example:

```text
Local:
10 requests/sec

Global:
100 requests/sec
```

Local limiter reduces unnecessary distributed-store traffic.

---

# 33. Local + Global Rate Limiting

Example:

```text
Server 1 → local limit
Server 2 → local limit
Server 3 → local limit

             ↓

        Global limiter
             ↓
          Backend
```

### Advantage

Reduces load on shared rate-limit storage.

### Trade-off

Local limits can make the global limit approximate unless carefully coordinated.

---

# 34. Rate Limiter Data Model

For token bucket:

```text
Key:
rate_limit:{userId}:{endpoint}

Value:
{
    tokens: 50,
    lastRefillTime: 1690000000
}
```

For fixed window:

```text
Key:
rate_limit:{userId}:{endpoint}:{window}

Value:
count = 72
TTL = remaining window duration
```

---

# 35. Scaling Rate Limiter

Suppose:

```text
1 million requests/sec
```

We need to avoid:

```text
One Rate Limiter Server
```

Use:

```text
                Load Balancer
                /     |     \
               ↓      ↓      ↓
             RL1    RL2     RL3
              |      |       |
              └──────┼───────┘
                     ↓
                Redis Cluster
```

Scale rate-limiter servers horizontally.

Redis/storage can also be distributed and sharded.

---

# 36. Rate Limiter vs Load Balancer

### Load Balancer

Distributes requests:

```text
Request
 ↓
Server 1 / Server 2 / Server 3
```

### Rate Limiter

Controls request volume:

```text
Request
 ↓
Allowed?
 ├── YES
 └── NO
```

### Recall

> **Load Balancer decides WHERE the request goes.**

> **Rate Limiter decides WHETHER the request should proceed.**

---

# 37. Rate Limiter vs Circuit Breaker

### Rate Limiter

Controls traffic entering a system.

```text
Too many requests
 ↓
Reject
```

### Circuit Breaker

Stops calls to an unhealthy downstream service.

```text
Downstream failing
 ↓
Open circuit
 ↓
Stop sending requests temporarily
```

They solve different problems and can be used together.

---

# 38. Rate Limiter vs Throttling

They are closely related but often used slightly differently.

### Rate Limiting

Defines how many requests are allowed.

```text
100 requests/min
```

### Throttling

Controls or slows traffic when limits are reached.

```text
Queue
Delay
Reject
```

Token bucket and leaky bucket can be used as throttling mechanisms.

---

# 39. Distributed Consistency

Rate limiting usually does not require the same consistency level as financial transactions.

A small amount of approximation may be acceptable.

For example:

```text
Configured limit = 1000/min
Actual effective limit = approximately 1000
```

depending on implementation.

But for expensive or security-sensitive APIs, stronger coordination may be necessary.

---

# 40. Clock Problem

Distributed rate limiters can run on different servers.

If servers have different clocks:

```text
Server A → 10:00:00
Server B → 10:00:03
```

time-window calculations can differ.

### Solutions

- Use a centralized timestamp/state operation
- Keep clocks synchronized
- Prefer algorithms that minimize dependence on exact local wall-clock boundaries
- Use monotonic time for local elapsed-duration calculations where appropriate

---

# 41. Monitoring

Important metrics:

```text
Allowed requests
Rejected requests
429 responses
Requests/sec
Rate-limit latency
Redis latency
Redis errors
Hot keys
Memory usage
Queue depth
```

Example dashboard:

```text
Requests/sec       = 100K
Allowed            = 95K
Rejected           = 5K
Redis latency      = 2 ms
429 rate           = 5%
```

---

# 42. Security Considerations

Don't rely only on IP-based rate limiting.

Attackers can use:

```text
Multiple IPs
Multiple accounts
Proxies
Bots
```

Use multiple dimensions:

```text
IP
+
User ID
+
API Key
+
Device
+
Endpoint
+
Tenant
```

For authentication endpoints, stronger controls may be needed.

Example:

```text
Login:
5 attempts/min/IP

+
5 attempts/min/account
```

---

# 43. Back-of-the-Envelope Example

Suppose:

```text
10 million users

Average:
10 requests/sec/user
```

Worst-case theoretical traffic:

```text
10M × 10
= 100M requests/sec
```

We don't necessarily need one rate limiter server.

Use:

```text
Multiple Rate Limiter instances
+
Distributed state
+
Sharded storage
```

The important interview point is:

> Estimate traffic first, then determine how many rate-limiter instances and storage capacity are required.

---

# 44. Example — Design Twitter/X-like API Rate Limiter

Suppose:

```text
User limit:
100 requests/min

Endpoint:
POST /tweet
```

Flow:

```text
Client
 ↓
API Gateway
 ↓
Rate Limiter
 ↓
Check:

rate:user123:/tweet
 ↓
Token available?
 ├── YES → consume token → Tweet Service
 └── NO  → HTTP 429
```

State:

```text
user123:/tweet

tokens = 97
lastRefill = T
```

---

# 45. Example — Payment API

Suppose:

```text
POST /payment
```

We might use:

```text
Per user:
10 requests/min

Per account:
20 requests/min

Global:
10,000 requests/sec
```

Why multiple limits?

Because a single attacker could otherwise distribute traffic across accounts or IPs.

For payment APIs, we may also use:

- Idempotency keys
- Authentication
- Fraud controls
- Stronger abuse protection

Rate limiting alone is not enough.

---

# 46. Common Interview Pitfalls

### Pitfall 1

> "I'll store the counter in application memory."

Problem:

```text
Server 1 → count = 50
Server 2 → count = 50
```

The global limit becomes incorrect.

Use shared/distributed state when a global limit is required.

---

### Pitfall 2

> "Redis solves everything."

Not automatically.

You must consider:

- Atomicity
- Hot keys
- Redis failure
- Replication
- Sharding
- Memory limits
- Latency

---

### Pitfall 3

> "We need exact global consistency."

Not always.

Rate limiting often tolerates small amounts of approximation.

---

### Pitfall 4

> "Use fixed window for everything."

Fixed window has boundary burst problems.

Choose the algorithm based on requirements.

---

# 47. How to Answer "Design a Rate Limiter" in an Interview

Follow this structure:

```text id="x2qj8n"
1. Clarify requirements
        ↓
2. Define rate-limit key
        ↓
3. Choose algorithm
        ↓
4. Design API flow
        ↓
5. Design distributed state
        ↓
6. Handle atomicity
        ↓
7. Handle failures
        ↓
8. Scale horizontally
        ↓
9. Handle hot keys
        ↓
10. Add monitoring
```

---

# 48. 1-Minute Interview Answer

> "I would put the rate limiter at the API Gateway or as a shared middleware layer before the application services. The limiter would identify the client using a user ID, API key, IP, or tenant ID and apply a configured policy per endpoint or user tier.
>
> For a general API, I would consider a Token Bucket because it allows controlled bursts while enforcing an average rate. The bucket state can be stored in a distributed low-latency store such as Redis so multiple rate-limiter instances share the same state.
>
> The token calculation and update must be atomic to avoid race conditions when multiple requests arrive simultaneously. The rate limiter would return HTTP 429 when the limit is exceeded, optionally including Retry-After information.
>
> To scale, I would horizontally scale rate-limiter instances and use a sharded/high-availability distributed store. I would also handle hot keys, retries, failures, monitoring, and decide explicitly whether the system should fail open or fail closed if the rate-limit store is unavailable."

---

# 🔥 49. TOP INTERVIEW QUESTIONS & SHORT ANSWERS

## Q1. What is a rate limiter?

> A component that controls how many requests a client can make within a defined period.

---

## Q2. Why do we need it?

> To protect services from abuse, traffic spikes, excessive usage, and resource exhaustion.

---

## Q3. What algorithms do you know?

> Fixed Window, Sliding Window Log, Sliding Window Counter, Token Bucket, and Leaky Bucket.

---

## Q4. Which algorithm would you choose?

> For a general API, Token Bucket is often a good choice because it supports controlled bursts and limits average request rate.

---

## Q5. Why Redis?

> Low latency, atomic operations, TTL support, and suitability for shared distributed state.

---

## Q6. Why can't we keep counters in application memory?

> Because requests can hit different servers, producing inconsistent global limits.

---

## Q7. How do you handle concurrent requests?

> Use atomic check-and-update operations, such as a Redis Lua script or suitable atomic database primitive.

---

## Q8. What status code should be returned?

> HTTP **429 Too Many Requests**.

---

## Q9. How do you scale it?

> Horizontally scale rate-limiter servers and distribute/shard the shared state store.

---

## Q10. What is a hot key?

> A key receiving extremely high traffic, potentially overloading one storage partition.

---

## Q11. Token Bucket vs Leaky Bucket?

> Token Bucket allows controlled bursts; Leaky Bucket smooths traffic to a more constant output rate.

---

## Q12. Fixed Window disadvantage?

> Boundary burst problem.

---

## Q13. Sliding Window Log disadvantage?

> Stores many request timestamps, increasing memory usage.

---

## Q14. What happens if Redis fails?

> Choose fail-open, fail-closed, or a local fallback based on the endpoint's availability and security requirements.

---

## Q15. Can rate limiting be approximate?

> Yes. Many distributed rate limiters accept small approximation errors to achieve better scalability and availability.

---

# 🧠 FINAL RECALL SHEET

```text
RATE LIMITER
     ↓
Controls Request Rate
     ↓
Protects Backend
     ↓
API Gateway / Middleware
     ↓
Choose Algorithm
     ↓
Token Bucket ⭐
     ↓
Shared Distributed State
     ↓
Redis
     ↓
Atomic Update
     ↓
ALLOW / HTTP 429
```

## Algorithms

```text
Fixed Window
→ Simple + Fast
→ Boundary burst

Sliding Log
→ Accurate
→ Memory heavy

Sliding Counter
→ Balanced
→ Approximate

Token Bucket ⭐
→ Burst + Average Rate
→ Great general API choice

Leaky Bucket
→ Smooth traffic
→ Queue/latency
```

## Distributed Design

```text
Many API Servers
       ↓
Many Rate Limiters
       ↓
Shared Distributed Store
       ↓
Atomic Check + Update
       ↓
ALLOW / REJECT
```

## Golden Rules

```text
Rate Limiter
= Protect the system

Token Bucket
= Tokens + Refill + Burst

Redis
= Shared fast state

Atomicity
= Prevent race conditions

HTTP 429
= Too Many Requests

Sharding
= Scale distributed state

Hot Key
= One key gets too much traffic

Fail Open
= Availability

Fail Closed
= Protection
```

### ⭐ One-Line Interview Summary

> **A scalable rate limiter controls request traffic using an algorithm such as Token Bucket, stores shared state in a low-latency distributed store such as Redis, performs atomic updates, returns 429 when limits are exceeded, and horizontally scales while handling hot keys, failures, and consistency trade-offs.**



