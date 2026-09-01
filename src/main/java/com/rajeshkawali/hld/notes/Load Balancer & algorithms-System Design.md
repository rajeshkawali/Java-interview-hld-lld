# LOAD BALANCER & LOAD BALANCING ALGORITHMS
## System Design Interview Notes

---

# 1. What is a Load Balancer?

A **Load Balancer (LB)** distributes incoming client requests across multiple servers/instances.

### Without Load Balancer

```text
Clients
   |
   ↓
Server 1
```

If Server 1 gets overloaded:

```text
Server 1 → CPU 100%
Server 1 → Requests slow
Server 1 → May crash
```

### With Load Balancer

```text
                Load Balancer
               /      |      \
              ↓       ↓       ↓
          Server 1  Server 2  Server 3
```

The load balancer distributes traffic among healthy servers.

### Simple Definition

> **Load Balancer = A component that distributes incoming traffic across multiple backend servers to improve availability, scalability, and performance.**

---

# 2. Why Do We Need Load Balancing?

Main reasons:

```text
1. Scalability
2. High Availability
3. Fault Tolerance
4. Better Performance
5. Health Checking
6. Traffic Distribution
```

---

# 3. Example

Suppose we have:

```text
1,000 requests/second
```

and one server can handle:

```text
300 requests/second
```

One server is not enough.

Use 4 servers:

```text
              Load Balancer
                    |
        ┌───────────┼───────────┐
        ↓           ↓           ↓
     Server 1    Server 2    Server 3
      300 RPS     300 RPS     300 RPS
                    +
                 Server 4
```

Now the system can handle much more traffic.

---

# 4. Where Does Load Balancer Sit?

Typical architecture:

```text
                    Internet
                       |
                       ↓
                 DNS / CDN
                       |
                       ↓
                Load Balancer
                       |
          ┌────────────┼────────────┐
          ↓            ↓            ↓
      App Server    App Server    App Server
          |            |            |
          ↓            ↓            ↓
        DB/Cache/Other Services
```

For large systems:

```text
Client
  ↓
DNS
  ↓
CDN
  ↓
Load Balancer
  ↓
API Gateway
  ↓
Service Load Balancer
  ↓
Microservices
```

---

# 5. Types of Load Balancers

There are two common ways to classify load balancers.

## A. Layer 4 Load Balancer

Works at the **transport layer**.

Usually uses:

```text
IP Address
Port
TCP/UDP connection information
```

Example:

```text
Client
  ↓
L4 LB
  ↓
Server 1 / Server 2 / Server 3
```

It does not need to understand the HTTP request content.

### Advantages

- Very fast
- Low overhead
- Good for high throughput
- Works well for TCP/UDP

### Disadvantages

- Less application awareness
- Limited routing decisions
- Cannot easily route based on URL/path/header

### Example

```text
TCP :443
     ↓
L4 Load Balancer
     ↓
HTTPS servers
```

---

# 6. Layer 7 Load Balancer

Works at the **application layer**.

For HTTP/HTTPS, it can understand:

```text
URL
HTTP method
Headers
Cookies
Host
Path
```

Example:

```text
Client
  ↓
L7 Load Balancer
       |
       ├── /users/*   → User Service
       ├── /orders/*  → Order Service
       └── /payment/* → Payment Service
```

### Advantages

- Application-aware routing
- URL/path-based routing
- Header-based routing
- Cookie-based routing
- Can support advanced traffic policies

### Disadvantages

- More CPU overhead
- More complex
- Higher latency than a simple L4 forwarding path

---

# 7. L4 vs L7

| Feature | L4 | L7 |
|---|---|---|
| Layer | Transport | Application |
| Understands HTTP | No/limited | Yes |
| Uses IP/Port | Yes | Yes |
| URL routing | No | Yes |
| Header routing | No | Yes |
| Cookie routing | No | Yes |
| Performance | Usually higher | Usually lower |
| Flexibility | Lower | Higher |
| Common use | TCP/UDP traffic | HTTP APIs/web apps |

### Interview Recall

> **L4 = Fast transport-level routing.**  
> **L7 = Application-aware routing.**

---

# 8. Load Balancing Algorithms

The load balancer needs a strategy to decide:

> "Which backend server should receive this request?"

Common algorithms:

```text
1. Round Robin
2. Weighted Round Robin
3. Least Connections
4. Weighted Least Connections
5. IP Hash
6. Consistent Hashing
7. Random
8. Least Response Time
9. Resource-based / Adaptive
```

---

# 9. Round Robin

Requests are distributed sequentially.

Suppose:

```text
Server A
Server B
Server C
```

Requests:

```text
Request 1 → A
Request 2 → B
Request 3 → C
Request 4 → A
Request 5 → B
Request 6 → C
```

Pattern:

```text
A → B → C → A → B → C
```

### Advantages

- Very simple
- Easy to implement
- Good when servers have similar capacity
- No complex state required

### Disadvantages

- Does not consider server load
- Does not consider request cost
- Poor if servers have different capacities
- Poor when some requests are much more expensive than others

### Best Use

When:

```text
Servers are similar
+
Requests are roughly similar
```

### Recall

> **Round Robin = Take turns.**

---

# 10. Weighted Round Robin

Some servers are more powerful than others.

Example:

```text
Server A → Weight 3
Server B → Weight 2
Server C → Weight 1
```

Traffic distribution is approximately:

```text
A → 50%
B → 33%
C → 17%
```

Example sequence could be:

```text
A A A B B C
```

### Advantages

- Supports servers with different capacities
- Simple
- More flexible than normal Round Robin

### Disadvantages

- Weight must be configured correctly
- Does not dynamically understand current load
- Can become inefficient if workload changes significantly

### Recall

> **Weighted Round Robin = Powerful server gets more requests.**

---

# 11. Least Connections

Send the request to the server with the fewest active connections.

Example:

```text
Server A → 20 connections
Server B → 10 connections
Server C → 15 connections
```

New request:

```text
            New Request
                 ↓
               L.B.
                 ↓
              Server B
```

because B has the fewest connections.

### Advantages

- Considers current load
- Better than Round Robin when requests have different durations
- Useful for long-lived connections

### Disadvantages

- Requires connection tracking
- More state
- Connection count does not always equal CPU/load
- A few long requests can distort the metric

### Good For

```text
WebSocket
Long-lived TCP connections
Variable request duration
```

### Recall

> **Least Connections = Send to the server with the fewest active connections.**

---

# 12. Weighted Least Connections

Combines:

```text
Server capacity
+
Current connections
```

Example:

```text
Server A
Weight = 2
Connections = 20

Server B
Weight = 1
Connections = 15
```

The LB considers both weight and connection count.

### Advantages

- Handles different server capacities
- Considers current load

### Disadvantages

- More complex
- Requires configuration/tuning
- Connection count still isn't a perfect measure of actual resource usage

---

# 13. IP Hash

The client's IP address is used to determine the server.

Conceptually:

```text
hash(clientIP) % numberOfServers
```

Example:

```text
Client A → hash(IP A) → Server 1

Client B → hash(IP B) → Server 2
```

The same client tends to reach the same backend while the server set remains stable.

### Advantages

- Provides a form of session affinity
- Simple
- Useful when application state is tied to a backend

### Disadvantages

- Uneven distribution is possible
- NAT can cause many users to appear under one public IP
- Adding/removing servers can remap many clients
- Not ideal for large-scale dynamic clusters

### Recall

> **IP Hash = Same client IP tends to go to the same server.**

---

# 14. Consistent Hashing

Consistent hashing maps both:

```text
Clients/keys
```

and:

```text
Servers
```

onto a logical hash ring.

```text
             Server A
                ●
          /             \
      Client            Server B
         ●                 ●
          \             /
             Server C
                ●
```

A key is assigned to the next server on the ring according to the hashing scheme.

### Main Benefit

When a server is added or removed, only a relatively small portion of keys need to move compared with naive modulo hashing.

### Example

With:

```text
hash(key) % N
```

changing N can remap many keys.

With consistent hashing:

```text
Add Server D
```

only affected portions of the ring are remapped.

### Advantages

- Minimal remapping
- Good for distributed caches
- Useful for sharded systems
- Supports dynamic nodes

### Disadvantages

- More complex
- Requires careful distribution
- Virtual nodes may be needed to avoid imbalance

### Recall

> **Consistent Hashing = Minimize data/request remapping when servers change.**

---

# 15. Round Robin vs Consistent Hashing

These solve different problems.

### Round Robin

```text
Request
 ↓
A → B → C → A → B → C
```

Focus:

> **Distribute traffic evenly.**

### Consistent Hashing

```text
Key
 ↓
Hash Ring
 ↓
Specific server
```

Focus:

> **Stable mapping and minimal remapping when nodes change.**

---

# 16. Random Load Balancing

Choose a backend randomly.

```text
Request 1 → A
Request 2 → C
Request 3 → B
Request 4 → A
```

### Advantages

- Very simple
- Little state
- Can work reasonably well with many requests

### Disadvantages

- Short-term imbalance
- Doesn't consider server load
- No awareness of request cost

### Recall

> **Random = Pick a server randomly.**

---

# 17. Least Response Time

Choose a server based on response latency and sometimes active connections/load.

Example:

```text
Server A → 50 ms
Server B → 120 ms
Server C → 80 ms
```

New request:

```text
→ Server A
```

### Advantages

- Can improve latency
- Reacts to performance differences

### Disadvantages

- Requires measurements
- Metrics can fluctuate
- More complex
- May overload a temporarily fast server

### Recall

> **Least Response Time = Prefer the server responding fastest.**

---

# 18. Health Checks

Load balancing is not only about algorithms.

The LB must know:

> "Is this server healthy?"

Example:

```text
             Load Balancer
              /    |    \
             ↓     ↓     ↓
           A       B      C
         Healthy Healthy  DOWN
```

Traffic:

```text
Requests
   ↓
A / B
```

Server C receives no traffic.

---

# 19. Types of Health Checks

## Liveness Check

Checks whether the application/process is alive.

Example:

```text
GET /health
```

Response:

```text
200 OK
```

---

## Readiness Check

Checks whether the application is ready to serve real traffic.

For example, an application may be alive but:

```text
Database unavailable
```

So:

```text
Liveness = Healthy
Readiness = Not Ready
```

The LB should avoid sending traffic to it.

### Recall

> **Liveness = Is it alive?**  
> **Readiness = Can it serve traffic?**

---

# 20. Active vs Passive Health Checks

## Active

LB periodically sends health-check requests.

```text
LB
 ↓
GET /health
 ↓
Server
```

## Passive

LB observes real traffic.

Example:

```text
Server returns
many 5xx errors
        ↓
LB detects failure
        ↓
Reduce/remove traffic
```

Both approaches can be combined.

---

# 21. Session Stickiness / Session Affinity

Sometimes a user's requests need to go to the same server.

```text
User A
  ↓
Server 1

User A
  ↓
Server 1

User A
  ↓
Server 1
```

This is called:

> **Sticky Session**

Common mechanisms:

```text
Cookie-based affinity
IP-based affinity
```

---

## Problem With Sticky Sessions

Suppose:

```text
Server 1 → 10,000 users
Server 2 → 2,000 users
Server 3 → 2,000 users
```

Server 1 can become overloaded.

Also, if Server 1 fails, session continuity becomes harder unless session state is externalized.

---

# 22. Better Alternative — Stateless Services

Instead of storing session state in the application server:

```text
Server 1
   ↓
Local Session
```

use:

```text
Server 1 ─┐
Server 2 ─┼──→ Redis / Shared Session Store
Server 3 ─┘
```

Now any server can handle the request.

### Recall

> **Prefer stateless services + external/shared state when practical.**

---

# 23. Connection Draining

Suppose Server 2 needs maintenance.

Do not immediately kill it.

Instead:

```text
Remove Server 2 from new traffic
             ↓
Existing requests/connections finish
             ↓
Server 2 shuts down
```

This is called:

> **Connection Draining / Graceful Drain**

Very useful during deployments.

---

# 24. Load Balancer High Availability

A load balancer itself should not become a single point of failure.

Bad:

```text
             LB
              |
        ┌─────┼─────┐
        ↓     ↓     ↓
       App   App   App
```

If LB fails:

```text
Everything fails
```

Better:

```text
                 DNS
                  |
          ┌───────┴───────┐
          ↓               ↓
       LB-Primary      LB-Secondary
          |               |
          └───────┬───────┘
                  ↓
             App Servers
```

Cloud-managed load balancers generally provide highly available infrastructure.

---

# 25. Load Balancer Scaling

A large system may receive millions of requests.

A single LB instance may become insufficient.

Solutions:

```text
Horizontal Scaling
+
Anycast/DNS-based distribution
+
Cloud-managed LB
+
Multiple LB nodes
```

Example:

```text
                    DNS
                     |
          ┌──────────┼──────────┐
          ↓          ↓          ↓
        LB-1       LB-2       LB-3
          |          |          |
          └──────────┼──────────┘
                     ↓
                App Servers
```

---

# 26. Layered Load Balancing

Large systems may have multiple levels.

```text
                     DNS
                      |
                      ↓
                Global LB
                /        \
               ↓          ↓
           Region A     Region B
               |            |
               ↓            ↓
            Regional LB  Regional LB
               |            |
               ↓            ↓
          App Servers   App Servers
```

This provides:

- Geographic routing
- Regional failover
- Scalability
- Disaster recovery

---

# 27. Global Load Balancing

Suppose users are located in:

```text
India
USA
Europe
```

Route them to nearby regions:

```text
India User → Mumbai Region

USA User → US Region

Europe User → Europe Region
```

Benefits:

```text
Lower latency
Regional isolation
Disaster recovery
```

---

# 28. Load Balancer vs API Gateway

These are not exactly the same.

## Load Balancer

Primary goal:

> Distribute traffic across instances.

```text
LB
 ↓
App1
App2
App3
```

## API Gateway

Primary goal:

> Provide an API entry point and apply API-level policies.

```text
Gateway
 ├── Authentication
 ├── Rate Limiting
 ├── Routing
 ├── Request Transformation
 └── Aggregation
```

They can be used together.

```text
Client
 ↓
API Gateway
 ↓
Load Balancer
 ↓
Service Instances
```

---

# 29. Load Balancer vs Reverse Proxy

A reverse proxy receives client requests on behalf of backend servers.

```text
Client
  ↓
Reverse Proxy
  ↓
Backend
```

A load balancer is commonly a reverse proxy when operating at L7, but reverse proxies can also perform other functions such as caching, TLS termination, compression, or routing.

### Recall

> **Load Balancer = Traffic distribution.**  
> **Reverse Proxy = Backend-facing intermediary with broader proxy responsibilities.**

---

# 30. TLS Termination

The load balancer can terminate HTTPS.

```text
Client
  |
 HTTPS
  ↓
Load Balancer
  |
 HTTP or HTTPS
  ↓
Backend
```

This is called:

> **TLS termination**

Advantages:

- Centralized certificate management
- Reduces TLS work on application servers
- Simplifies backend configuration

For sensitive environments, traffic from LB to backend may also remain encrypted.

---

# 31. Example: E-Commerce System

Suppose we have:

```text
10 million users
100,000 requests/second
```

Architecture:

```text
                    Users
                      |
                      ↓
                     DNS
                      |
                      ↓
                     CDN
                      |
                      ↓
                Load Balancer
                      |
          ┌───────────┼───────────┐
          ↓           ↓           ↓
       App-1       App-2       App-3
          |           |           |
          └───────────┼───────────┘
                      ↓
                 API Gateway
                      |
       ┌──────────────┼──────────────┐
       ↓              ↓              ↓
    User Service   Order Service  Payment
       |              |              |
      DB             DB             DB
```

Use:

```text
L7 Load Balancer
+
Health Checks
+
Least Connections / suitable algorithm
+
Horizontal Scaling
```

For services where stable key-to-node mapping matters:

```text
Consistent Hashing
```

may be used internally.

---

# 32. Which Algorithm Should I Choose?

| Scenario | Suitable Choice |
|---|---|
| Similar servers + similar requests | Round Robin |
| Different server capacities | Weighted Round Robin |
| Long-lived connections | Least Connections |
| Different server capacities + varying connections | Weighted Least Connections |
| Need client affinity | IP Hash / Cookie Affinity |
| Distributed cache/sharding | Consistent Hashing |
| Need latency-aware routing | Least Response Time |
| Very simple distribution | Random |

### Important Interview Point

There is **no universally best algorithm**.

Choice depends on:

```text
Request pattern
+
Server capacity
+
Connection duration
+
Statefulness
+
Latency requirements
+
Failure behavior
```

---

# 33. Algorithm Comparison

| Algorithm | Main Idea | Advantage | Disadvantage |
|---|---|---|---|
| Round Robin | Take turns | Simple | Ignores load |
| Weighted RR | Take turns based on weight | Handles different capacities | Static |
| Least Connections | Fewest connections | Handles varying connection counts | Requires state |
| Weighted Least Connections | Connections + capacity | More adaptive | More complex |
| IP Hash | Hash client IP | Session affinity | Uneven distribution |
| Consistent Hashing | Hash ring | Minimal remapping | More complex |
| Random | Random server | Simple | Can temporarily imbalance |
| Least Response Time | Fastest response | Low latency | Needs measurements |

---

# 34. Common Interview Question

## Q: How does a Load Balancer improve scalability?

### Answer

> A load balancer distributes requests across multiple instances, allowing us to horizontally scale the application. When traffic increases, we can add more instances and have the load balancer distribute traffic among them.

Example:

```text
10K RPS
  ↓
LB
  ↓
App1 + App2
```

Traffic increases:

```text
100K RPS
  ↓
LB
  ↓
App1 + App2 + App3 + App4 + App5
```

---

# 35. Common Interview Question

## Q: What happens if one server goes down?

### Answer

The load balancer detects the unhealthy instance through health checks and stops routing new traffic to it.

```text
Before:

LB → A
   → B
   → C

C DOWN

After:

LB → A
   → B
```

When C becomes healthy again:

```text
LB → A
   → B
   → C
```

---

# 36. Common Interview Question

## Q: Round Robin vs Least Connections?

### Round Robin

Use when:

```text
Servers are similar
+
Requests have similar processing cost
```

### Least Connections

Use when:

```text
Requests have different durations
+
Connections can remain open
```

Example:

```text
WebSocket
Long polling
Long-running requests
```

---

# 37. Common Interview Question

## Q: Why not always use Least Connections?

Because **connection count is only a proxy for load**.

Example:

```text
Server A → 10 connections
Each request is CPU-heavy

Server B → 20 connections
Each request is very light
```

Least Connections chooses A, even though A may actually be more heavily loaded.

For some systems, CPU, latency, queue depth, or application-specific metrics may be better signals.

---

# 38. Common Interview Question

## Q: Why is Consistent Hashing useful?

### Answer

Normal hashing:

```text
hash(key) % N
```

If:

```text
N = 3
```

becomes:

```text
N = 4
```

many keys can map to different servers.

Consistent hashing reduces the amount of remapping.

Useful for:

```text
Distributed Cache
Database Sharding
Distributed Storage
Request Routing
```

---

# 39. Common Interview Question

## Q: How do you avoid Load Balancer becoming a Single Point of Failure?

Use:

```text
Multiple LB instances
+
Health checks
+
Failover
+
Highly available infrastructure
+
Multiple availability zones
```

Example:

```text
              DNS
               |
        ┌──────┴──────┐
        ↓             ↓
      LB-1           LB-2
        |             |
        └──────┬──────┘
               ↓
          App Cluster
```

---

# 40. Common Interview Question

## Q: What if all backend servers are overloaded?

The LB cannot create capacity by itself.

We need:

```text
Autoscaling
+
Queueing
+
Caching
+
Rate Limiting
+
Load Shedding
+
Backpressure
```

Example:

```text
Traffic Spike
     ↓
Load Balancer
     ↓
Autoscaling
     ↓
More Instances
```

---

# 41. Load Balancer + Auto Scaling

Typical cloud architecture:

```text
             Users
               |
               ↓
         Load Balancer
               |
       ┌───────┼───────┐
       ↓       ↓       ↓
      App     App     App
       ↑       ↑       ↑
       └── Autoscaler ─┘
```

If traffic increases:

```text
3 instances
     ↓
6 instances
     ↓
10 instances
```

If traffic decreases:

```text
10 instances
     ↓
5 instances
```

This reduces cost while maintaining capacity.

---

# 42. Important Failure Cases

A good system-design answer should mention:

### Backend failure

```text
Health check
→ Remove instance
```

### LB failure

```text
HA / multiple LB nodes
```

### Traffic spike

```text
Autoscaling
+
Rate limiting
+
Caching
```

### Slow backend

```text
Timeout
+
Circuit breaker
+
Load-aware routing
```

### Deployment

```text
Connection draining
+
Graceful shutdown
```

### Region failure

```text
Global routing
+
Multi-region failover
```

---

# 43. ⭐ Best Interview Answer — Load Balancer

If interviewer asks:

> "How would you design a load balancing layer?"

Say:

```text
I would place a highly available load balancer in front
of multiple stateless application instances.

The load balancer would perform health checks and route
traffic only to healthy instances.

For HTTP APIs, I would typically consider an L7 load
balancer because it supports application-aware routing.

For the balancing algorithm, I would choose based on the
workload. Round Robin is suitable for homogeneous servers
and similar requests, while Least Connections can be
better for variable-duration or long-lived connections.

If servers have different capacities, I can use weighted
algorithms.

For workloads requiring stable key-to-node mapping, such
as distributed caches, I would consider consistent hashing.

I would also use autoscaling, connection draining,
timeouts, observability, and multiple load-balancer nodes
or managed HA infrastructure to avoid a single point of
failure.
```

---

# 44. ⭐ QUICK RECALL

```text
LOAD BALANCER
│
├── Purpose
│   ├── Scalability
│   ├── Availability
│   └── Fault Tolerance
│
├── Types
│   ├── L4 → TCP/UDP/IP/Port
│   └── L7 → HTTP/URL/Header/Cookie
│
├── Algorithms
│   ├── Round Robin
│   ├── Weighted Round Robin
│   ├── Least Connections
│   ├── Weighted Least Connections
│   ├── IP Hash
│   ├── Consistent Hashing
│   ├── Random
│   └── Least Response Time
│
├── Reliability
│   ├── Health Checks
│   ├── Failover
│   ├── Connection Draining
│   └── Graceful Shutdown
│
├── Scaling
│   ├── Horizontal Scaling
│   ├── Autoscaling
│   └── Multi-Region
│
└── Security
    ├── TLS Termination
    └── Authentication/Policy integration
```

---

# ⭐ ONE-LINE MEMORY TRICK

```text
Round Robin
→ Take turns

Weighted RR
→ Powerful server gets more

Least Connections
→ Fewest active connections

IP Hash
→ Same client tends toward same server

Consistent Hashing
→ Minimize remapping when nodes change

L4
→ Transport-level

L7
→ Application-level

Health Check
→ Send traffic only to healthy servers

Sticky Session
→ Same user → same server

Connection Draining
→ Finish existing work before shutdown

Autoscaling
→ Add/remove instances based on demand
```

# FINAL TAKEAWAY

> **Load Balancer distributes traffic, health checks remove unhealthy instances, algorithms decide where requests go, autoscaling adds capacity, and high availability prevents the load-balancing layer itself from becoming a single point of failure.**