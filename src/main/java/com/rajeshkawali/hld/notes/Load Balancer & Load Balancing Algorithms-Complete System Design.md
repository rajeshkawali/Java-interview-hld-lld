# Load Balancer & Load Balancing Algorithms — Complete System Design Notes

> **Interview Goal:** Understand what a Load Balancer is, why we need it, L4 vs L7, static vs dynamic algorithms, algorithm trade-offs, health checks, session affinity, high availability, scaling, and common interview scenarios.

---

# 1. What is a Load Balancer?

A **Load Balancer (LB)** distributes incoming traffic across multiple backend servers.

### Without Load Balancer

```text
Clients
   |
   v
Single Server
   |
   v
Overloaded
```

Problems:

- Server can become overloaded.
- Single Point of Failure.
- Difficult to scale.
- Higher latency.
- No automatic failover.

### With Load Balancer

```text
                    Clients
                       |
                       v
                 Load Balancer
                /      |      \
               v       v       v
            Server1 Server2 Server3
```

The Load Balancer decides:

> **Which backend server should handle this request/connection?**

---

# 2. Why Do We Need a Load Balancer?

Main responsibilities:

```text
1. Traffic distribution
2. High availability
3. Horizontal scalability
4. Failover
5. Health checking
6. Connection management
7. SSL/TLS termination
8. Routing
9. Session affinity
10. Traffic management
11. DDoS/abuse protection in some architectures
12. Monitoring and observability
```

---

# 3. Basic Architecture

```text
                         Internet
                            |
                            v
                          DNS
                            |
                            v
                     Load Balancer
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
           App-Server1  App-Server2  App-Server3
              |             |             |
              +-------------+-------------+
                            |
                         Cache
                            |
                            v
                         Database
```

The application servers can be scaled horizontally:

```text
App1 + App2 + App3 + ... + AppN
```

---

# 4. Load Balancer vs Reverse Proxy

These concepts overlap.

## Load Balancer

Primary responsibility:

```text
Distribute traffic
```

## Reverse Proxy

Can provide:

```text
Routing
TLS termination
Caching
Authentication
Rate limiting
Compression
Load balancing
Request filtering
```

Therefore:

> A reverse proxy can perform load balancing, and many modern load-balancing products also behave as reverse proxies.

### Easy Memory

```text
Load Balancer
→ "Where should this traffic go?"

Reverse Proxy
→ "I stand in front of the backend and manage traffic."
```

---

# 5. Load Balancing Architecture

A production system normally should NOT have only one load balancer.

### Bad

```text
Clients
   |
   v
Single LB
   |
   +----> App1
   +----> App2
   +----> App3
```

If LB fails:

```text
Clients
   |
   X
 LB DOWN
```

### Better

```text
                    Clients
                       |
                       v
                 DNS / Edge
                  /       \
                 v         v
               LB-1      LB-2
                 |         |
                 +----+----+
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
        App1        App2        App3
```

This provides **Load Balancer High Availability**.

---

# 6. Types of Load Balancers

The most important classification is:

```text
Load Balancer
     |
     +------------------+
     |                  |
    L4                 L7
```

---

# 7. L4 Load Balancer

L4 operates primarily at the **Transport Layer** of the OSI model.

Common protocols:

```text
TCP
UDP
```

It makes decisions using information such as:

```text
Source IP
Destination IP
Source Port
Destination Port
Protocol
Connection information
```

### Architecture

```text
Client
   |
   | TCP / UDP
   v
L4 Load Balancer
   |
   +----> Server 1
   +----> Server 2
   +----> Server 3
```

L4 generally does not need to understand HTTP URLs or application payloads.

---

# 8. L4 Example

Suppose:

```text
Client → 10.10.1.20:443
```

The L4 LB can route the connection to:

```text
Server1:443
```

It doesn't need to understand:

```text
GET /users/123

Authorization: Bearer xxx
Host: example.com
```

---

# 9. Advantages of L4

```text
+ Very fast
+ Low processing overhead
+ High throughput
+ Low latency
+ Supports TCP/UDP
+ Works with non-HTTP protocols
+ Application protocol independent
```

# Disadvantages of L4

```text
- Limited application awareness
- Cannot easily route based on URL
- Cannot inspect HTTP headers in the usual L4 model
- Limited content-based routing
- Less flexible for API routing
```

---

# 10. L7 Load Balancer

L7 operates at the **Application Layer**.

For web systems, it understands protocols such as:

```text
HTTP
HTTPS
```

It can inspect:

```text
HTTP Method
URL
Path
Host
Headers
Cookies
Query parameters
Other application-level information
```

### Architecture

```text
Client
   |
 HTTPS
   v
L7 Load Balancer
   |
   +---- /users  → User Service
   |
   +---- /orders → Order Service
   |
   +---- /pay    → Payment Service
```

---

# 11. L7 Example

Request:

```text
GET /users/123
```

Can be routed to:

```text
User Service
```

Request:

```text
POST /orders
```

Can be routed to:

```text
Order Service
```

Request:

```text
GET /products
```

Can be routed to:

```text
Product Service
```

This is called:

> **Application-aware or content-based routing.**

---

# 12. L7 Advantages

```text
+ URL/path-based routing
+ Header-based routing
+ Cookie-based routing
+ TLS termination
+ Authentication integration
+ Request transformation
+ API routing
+ Can perform application-level traffic policies
+ Useful for microservices
```

# L7 Disadvantages

```text
- More CPU processing
- More latency than simple L4 forwarding
- More complex
- Requires understanding of application protocols
- Not appropriate for every non-HTTP workload
```

---

# 13. L4 vs L7

| Feature | L4 | L7 |
|---|---|---|
| OSI layer | Transport | Application |
| Common protocols | TCP, UDP | HTTP, HTTPS |
| Sees IP/Port | Yes | Yes |
| URL routing | No | Yes |
| Header routing | No | Yes |
| Cookie routing | No | Yes |
| Application awareness | Low | High |
| Processing overhead | Lower | Higher |
| Flexibility | Lower | Higher |
| Typical use | TCP/UDP, high throughput | APIs/Web/Microservices |

### Interview Memory Trick

```text
L4 → "Which connection?"

L7 → "Which application request?"
```

---

# 14. Static vs Dynamic Load Balancing

Load balancing algorithms can broadly be classified as:

```text
                  Algorithms
                      |
             +--------+--------+
             |                 |
          Static             Dynamic
             |                 |
       Fixed rules        Current state
```

---

# 15. Static Load Balancing

Static algorithms generally use a predefined rule.

They normally do not consider real-time server CPU, memory, connection count, or response time.

Examples:

```text
Round Robin
Weighted Round Robin
IP Hash
Static Hashing
Random
```

### Advantages

```text
+ Simple
+ Predictable
+ Low overhead
+ Easy to implement
+ Easy to debug
```

### Disadvantages

```text
- Doesn't react to changing server load
- Can produce uneven distribution
- Doesn't know whether a server is overloaded
```

---

# 16. Dynamic Load Balancing

Dynamic algorithms use current server state.

They can consider:

```text
Active connections
CPU
Memory
Response time
Queue length
Server health
Current load
```

Examples:

```text
Least Connections
Weighted Least Connections
Least Response Time
Resource-Based Routing
```

### Advantages

```text
+ Adapts to current conditions
+ Better for uneven workloads
+ Can avoid overloaded servers
```

### Disadvantages

```text
- More complex
- More monitoring required
- More overhead
- Metrics can become stale
```

---

# 17. Static vs Dynamic

| Feature | Static | Dynamic |
|---|---|---|
| Decision | Fixed rule | Current server state |
| CPU considered | Usually no | Can be |
| Connections considered | Usually no | Yes |
| Response time | No | Can be |
| Complexity | Low | Higher |
| Adaptability | Low | High |
| Example | Round Robin | Least Connections |

### Easy Memory

```text
Static
→ "I already know the rule."

Dynamic
→ "Let me check the current state."
```

---

# 18. Round Robin

The Load Balancer sends requests sequentially to each server.

Suppose:

```text
A
B
C
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

### Example

```text
                 Load Balancer
                      |
          +-----------+-----------+
          |           |           |
          v           v           v
          A           B           C

Requests:

1 → A
2 → B
3 → C
4 → A
5 → B
6 → C
```

## Advantages

```text
+ Very simple
+ Low overhead
+ Predictable
+ Easy to implement
+ Good for identical servers
```

## Disadvantages

```text
- Doesn't consider server load
- Doesn't consider CPU
- Doesn't consider request complexity
- Doesn't consider active connections
- A slow server still receives traffic
```

### Best Use

When:

```text
Servers are similar
AND
Requests have similar cost
```

---

# 19. Weighted Round Robin

Each server receives a weight.

Example:

```text
Server A → Weight 3
Server B → Weight 2
Server C → Weight 1
```

Approximately:

```text
A → 50%
B → 33%
C → 17%
```

The exact sequence depends on the implementation.

### Example

```text
1 → A
2 → A
3 → B
4 → A
5 → B
6 → C
```

## Best Use

When servers have different capacities.

Example:

```text
A → 16 CPU
B → 8 CPU
C → 4 CPU
```

A should receive more traffic.

## Advantages

```text
+ Simple
+ Better for heterogeneous servers
+ Low overhead
```

## Disadvantages

```text
- Weight can become outdated
- Doesn't react to current CPU/load
- Requires capacity estimation
```

---

# 20. IP Hash

The Load Balancer hashes the client's IP to determine the backend.

Conceptually:

```text
Server = hash(clientIP) % N
```

Example:

```text
Client IP
   |
   v
Hash
   |
   v
Server B
```

The same client IP will generally map to the same server while the backend set remains stable.

---

# 21. Why Use IP Hash?

It can provide **session affinity**.

Example:

```text
User A
   |
   v
Load Balancer
   |
   v
Server 1
```

Later:

```text
User A
   |
   v
Load Balancer
   |
   v
Server 1
```

This is useful when session state is stored locally.

---

# 22. IP Hash Problems

Suppose:

```text
Server A
Server B
Server C
```

Server C fails.

```text
A → Healthy
B → Healthy
C → Failed
```

Changing the server set can cause many clients to map to different servers.

Also, many users can share the same public IP because of NAT.

Example:

```text
100 users
    |
    v
Corporate NAT
    |
    v
One Public IP
    |
    v
Same hash input
```

This can create uneven distribution.

### Better Alternative in Some Cases

```text
Consistent Hashing
```

when the problem requires minimizing remapping after membership changes.

---

# 23. Least Connections

The Load Balancer sends a new request/connection to the server with the fewest active connections.

Example:

```text
Server A → 20 connections
Server B → 5 connections
Server C → 12 connections
```

New connection:

```text
→ Server B
```

because B has the fewest connections.

## Advantages

```text
+ Considers current connections
+ Better for long-lived connections
+ Better when request duration varies
```

## Disadvantages

```text
- Requires connection tracking
- More overhead
- Connection count doesn't always equal CPU load
```

---

# 24. Weighted Least Connections

Combines:

```text
Least Connections
+
Server Capacity
```

Example:

```text
Server A → Weight 3
Server B → Weight 1
```

The LB considers both:

```text
Current connections
+
Server capacity
```

Useful when:

```text
Servers have different capacities
AND
Connection duration varies
```

---

# 25. Least Response Time

The Load Balancer prefers servers with lower response latency.

Example:

```text
Server A → 100 ms
Server B → 50 ms
Server C → 200 ms
```

New request:

```text
→ Server B
```

## Advantages

```text
+ Uses actual performance
+ Can avoid slower servers
+ Useful when backend performance varies
```

## Disadvantages

```text
- Requires monitoring
- More complex
- Latency fluctuates
- Measurement must be tuned
```

---

# 26. Resource-Based Load Balancing

The LB uses server resource information.

Example:

```text
Server A → CPU 30%
Server B → CPU 85%
Server C → CPU 40%
```

The LB may prefer:

```text
A or C
```

Possible metrics:

```text
CPU
Memory
Queue length
Active connections
Latency
Disk I/O
Custom application metrics
```

## Advantages

```text
+ Highly adaptive
+ Good for heterogeneous servers
+ Useful for resource-intensive workloads
```

## Disadvantages

```text
- Complex
- Requires monitoring
- Metrics may be stale
- More coordination overhead
```

---

# 27. Random Load Balancing

The LB randomly selects a server.

Example:

```text
Request 1 → A
Request 2 → C
Request 3 → B
Request 4 → A
```

## Advantages

```text
+ Extremely simple
+ Low decision overhead
```

## Disadvantages

```text
- Temporary imbalance
- No awareness of server load
```

---

# 28. Power of Two Choices

Instead of checking every server:

```text
1. Randomly select two servers.
2. Compare their load.
3. Choose the less-loaded server.
```

Example:

```text
Randomly select:

Server A → 80 connections
Server C → 20 connections

Choose Server C
```

This can provide good distribution without needing to examine every server for each decision.

---

# 29. Consistent Hashing

Consistent hashing is useful when routing needs to remain relatively stable as servers are added/removed.

Imagine a hash ring:

```text
             Server A
                *
          *             *
      Server D         Server B
          *             *
             Server C
```

Clients/keys are mapped onto the ring.

When a server is removed, ideally only a portion of mappings need to move.

### Important

Consistent hashing is not simply another general-purpose replacement for Round Robin.

It is particularly useful when:

```text
Same key/client → same backend
```

and minimizing remapping during topology changes matters.

### Common Uses

```text
Distributed caches
Partitioned data
Session affinity
Sharded systems
```

---

# 30. Algorithm Comparison

| Algorithm | Static/Dynamic | Main Idea | Good For |
|---|---|---|---|
| Round Robin | Static | Take turns | Similar servers |
| Weighted Round Robin | Static | Capacity-based weights | Different server capacities |
| IP Hash | Static | Hash client IP | Affinity |
| Random | Static | Random server | Simple distribution |
| Least Connections | Dynamic | Fewest connections | Long connections |
| Weighted Least Connections | Dynamic | Connections + capacity | Different capacities |
| Least Response Time | Dynamic | Lowest latency | Variable performance |
| Resource Based | Dynamic | CPU/memory/etc. | Resource-heavy systems |
| Power of Two Choices | Dynamic-ish | Compare two candidates | Large server pools |
| Consistent Hashing | Hash-based | Minimize remapping | Affinity/sharding |

---

# 31. How to Choose an Algorithm

Use this interview decision tree.

```text
Are all servers similar?
       |
      YES
       |
       v
Are request costs similar?
       |
      YES
       |
       v
   Round Robin
```

Different server capacity?

```text
Different capacities
       |
       v
Weighted Round Robin
```

Long-lived or variable-duration connections?

```text
Variable connection duration
       |
       v
Least Connections
```

Different backend latency?

```text
Latency differs
       |
       v
Least Response Time
```

Need client/session affinity?

```text
Need affinity
       |
       v
IP Hash / Cookie Affinity / Consistent Hashing
```

Need application-level routing?

```text
Path / Header / Cookie routing
       |
       v
L7 Load Balancer
```

Need TCP/UDP and very high throughput?

```text
TCP / UDP
       |
       v
L4 Load Balancer
```

---

# 32. Health Checks

A Load Balancer must know whether backend servers are healthy.

Example:

```text
LB → Server 1 → 200 OK
LB → Server 2 → 200 OK
LB → Server 3 → 500 ERROR
```

Server 3 should be removed from the active pool.

```text
Server 1 ✓
Server 2 ✓
Server 3 ✗
```

---

# 33. Types of Health Checks

### 1. TCP Health Check

Checks whether a TCP connection can be established.

```text
LB → Server:443
Connection successful → Healthy
```

### 2. HTTP Health Check

```text
GET /health
```

Expected:

```text
200 OK
```

### 3. Application Health Check

Checks deeper dependencies.

Example:

```text
GET /ready

Database ✓
Cache ✓
Dependencies ✓

→ Ready
```

Important distinction:

```text
Liveness
→ Is the process alive?

Readiness
→ Can the server safely receive traffic?
```

---

# 34. Health Check Failure

Suppose:

```text
Server 1 → Healthy
Server 2 → Healthy
Server 3 → Unhealthy
```

Traffic becomes:

```text
             Load Balancer
               /       \
              v         v
           Server 1   Server 2

           Server 3
              X
```

When Server 3 becomes healthy again:

```text
Server 3 → Active
```

Traffic can gradually return.

---

# 35. Slow Start

A recovered server may not be ready to immediately receive 50% of traffic.

Example:

```text
Server 3 recovered
```

Instead:

```text
1% traffic
   ↓
5%
   ↓
10%
   ↓
25%
   ↓
Normal traffic
```

This is commonly called:

> **Slow Start / Warm-up**

It helps prevent a newly recovered server from being overwhelmed.

---

# 36. Connection Draining

Suppose Server 2 is being removed for deployment.

Existing connections:

```text
Client A → Server 2
Client B → Server 2
Client C → Server 2
```

Don't immediately kill them.

Instead:

```text
New requests → Other servers
Existing connections → Finish on Server 2
```

This is called:

> **Connection Draining / Deregistration Delay**

Useful for:

```text
Zero-downtime deployment
Graceful shutdown
Autoscaling
Server maintenance
```

---

# 37. Sticky Sessions / Session Affinity

Sticky sessions attempt to route a client to the same backend.

Example:

```text
User A
   |
   v
LB
   |
   v
Server 1
```

Future requests:

```text
User A → Server 1
User A → Server 1
User A → Server 1
```

Possible mechanisms:

```text
Cookie-based affinity
Source-IP affinity
LB-specific session affinity
```

---

# 38. Problem with Sticky Sessions

Suppose:

```text
User A → Server 1
```

Server 1 crashes.

```text
Server 1 → DOWN
```

The user's local session may disappear.

Other problems:

```text
Uneven load
Harder scaling
Poor failover behavior
State tied to a specific server
```

### Better Modern Approach

Keep application servers stateless:

```text
              Load Balancer
              /     |     \
             v      v      v
           App1   App2   App3
             \      |      /
              \     |     /
                Redis
```

Store shared session state in:

```text
Redis
Database
Distributed session store
```

Then any application server can handle the request.

---

# 39. SSL/TLS Termination

The Load Balancer can terminate TLS.

```text
Client
   |
 HTTPS
   |
   v
Load Balancer
   |
   | HTTP/HTTPS
   v
Backend
```

Benefits:

```text
+ Centralized certificate management
+ Easier certificate renewal
+ Reduces TLS work on application servers
+ Simplifies backend configuration
```

For environments requiring encryption internally:

```text
Client
   |
 HTTPS
   v
LB
   |
 HTTPS / mTLS
   v
Backend
```

---

# 40. Load Balancer and Caching

Some L7 load balancers/reverse proxies can cache responses.

```text
Client
   |
   v
LB / Reverse Proxy
   |
   +---- Cache HIT → Response
   |
   +---- Cache MISS → Backend
```

This reduces:

```text
Backend traffic
Database load
Latency
```

For global static content, a **CDN** is usually a better specialized solution.

---

# 41. Load Balancer and Rate Limiting

A Load Balancer/API Gateway can reject excessive traffic before it reaches backend servers.

Example:

```text
100 requests/min/user
```

Architecture:

```text
Client
   |
   v
LB / API Gateway
   |
   +---- Allowed → Backend
   |
   +---- Too many → 429
```

In a multi-instance architecture, rate-limit state may need to be shared:

```text
LB1 ──┐
LB2 ──┼──> Redis / Distributed Counter
LB3 ──┘
```

---

# 42. Load Balancer and Microservices

For microservices:

```text
                    Client
                       |
                       v
               L7 LB / API Gateway
                       |
       +---------------+---------------+
       |               |               |
       v               v               v
   User Service   Order Service   Payment Service
```

Routing:

```text
/users/*  → User Service
/orders/* → Order Service
/pay/*    → Payment Service
```

This is a major reason L7 load balancing is useful in API architectures.

---

# 43. Load Balancer and WebSockets

WebSocket connections are long-lived.

```text
Client
   |
   v
Load Balancer
   |
   +----> WS Server 1
   +----> WS Server 2
```

Important considerations:

```text
Long-lived connections
Connection timeout
Upgrade handling
Health checks
Reconnection
Session affinity if required
Shared state/pub-sub
```

Example:

```text
User A → WS Server 1
User B → WS Server 2
```

If they need to exchange messages:

```text
WS Server 1
     |
     v
Redis Pub/Sub / Kafka
     |
     v
WS Server 2
```

---

# 44. Load Balancer and WebSocket Sticky Sessions

A WebSocket connection normally remains attached to the backend for its lifetime.

The important issue is often not "send every WebSocket message through the same algorithm", but:

> **How do clients reconnect after disconnection, and how is shared state/message delivery handled across servers?**

Use:

```text
LB
+
Shared state
+
Pub/Sub
+
Reconnection
```

rather than relying entirely on sticky sessions.

---

# 45. Global Load Balancing

For users across multiple regions:

```text
                         Global Users
                              |
                              v
                     Global DNS / Anycast
                       /       |       \
                      v        v        v
                    India     USA     Europe
                      |        |        |
                     LB       LB       LB
                      |        |        |
                    Apps     Apps     Apps
```

Traffic can be routed based on:

```text
Latency
Geography
Region health
Availability
Capacity
```

---

# 46. Local vs Global Load Balancing

### Local Load Balancing

Distributes traffic inside a region/data center.

```text
India
 |
 v
Regional LB
 |
 +----> App1
 +----> App2
 +----> App3
```

### Global Load Balancing

Chooses the appropriate region first.

```text
User
 |
 v
Global LB
 |
 +----> India
 +----> USA
 +----> Europe
```

Then regional LB distributes traffic within that region.

---

# 47. Layered Load Balancing

Large systems may use multiple levels.

```text
                         Users
                           |
                           v
                    Global Traffic Manager
                    /        |        \
                   v         v         v
                India       USA      Europe
                  |           |          |
                 L4/L7       L4/L7      L4/L7
                  |           |          |
               Apps        Apps       Apps
```

Benefits:

```text
Global availability
Regional failover
Lower latency
Independent scaling
```

---

# 48. Load Balancer Scaling

The Load Balancer can itself become a bottleneck.

Bad:

```text
Millions of requests
        |
        v
Single LB
        |
        v
Backend
```

Better:

```text
                    Edge / Global LB
                  /       |       \
                 v        v        v
               LB-1     LB-2     LB-3
                 |        |        |
                 +--------+--------+
                          |
                       Backend
```

Possible techniques:

```text
Horizontal scaling
Multiple LB instances
L4 load balancing
Regional distribution
CDN caching
Connection reuse
Autoscaling
```

---

# 49. What if Load Balancer Fails?

### Question

> What happens if the Load Balancer goes down?

Answer:

A single LB is a Single Point of Failure.

Use:

```text
Multiple LB instances
+
Health checks
+
Failover
+
Redundant infrastructure
```

Architecture:

```text
                 DNS / Edge
                /          \
               v            v
             LB-1         LB-2
               |            |
               +-----+------+
                     |
                  Backend
```

---

# 50. What if Backend Server Fails?

```text
LB
 |
 +----> App1 ✓
 |
 +----> App2 ✗
 |
 +----> App3 ✓
```

The LB detects App2 failure and stops sending new traffic to it.

---

# 51. What if All Servers Are Unhealthy?

This is an important interview scenario.

```text
LB
 |
 +----> App1 ✗
 +----> App2 ✗
 +----> App3 ✗
```

Possible behavior:

```text
Return 503
Fail over to another region
Serve cached/static response where appropriate
Trigger alerts
Apply circuit-breaking/degradation
```

Do not simply keep retrying indefinitely.

---

# 52. Retry Problem

Suppose:

```text
Client
  |
  v
LB
  |
  v
Server 1 → Slow
```

LB retries:

```text
Server 1 → Slow
Server 2 → Retry
Server 3 → Retry
```

Retries can amplify traffic.

This is called:

> **Retry Storm / Load Amplification**

Use:

```text
Timeouts
Bounded retries
Exponential backoff
Jitter
Circuit breakers
```

---

# 53. Load Balancer and Timeouts

Always define timeouts.

Important timeout categories can include:

```text
Connection timeout
Idle timeout
Request timeout
Backend response timeout
Keep-alive timeout
```

Without appropriate timeouts:

```text
Dead connections
Resource exhaustion
Thread/connection pool exhaustion
Poor recovery
```

---

# 54. Connection Pooling

For L7 proxies/load balancers, backend connection reuse can reduce overhead.

Instead of:

```text
Request
 → New TCP connection
 → Backend
 → Close
```

Reuse connections where appropriate:

```text
Client Requests
       |
       v
L7 LB
       |
   Connection Pool
       |
       v
Backend
```

Benefits:

```text
Lower connection overhead
Lower latency
Better throughput
```

---

# 55. Load Balancer and Autoscaling

Suppose traffic increases:

```text
1000 RPS
   ↓
10000 RPS
```

Autoscaling adds:

```text
App1
App2
App3
App4
App5
```

The LB discovers/registers healthy instances and starts sending traffic to them.

When traffic decreases:

```text
App5
App4
```

can be removed after connection draining.

---

# 56. Load Balancer and Service Discovery

In dynamic environments, backend servers can change frequently.

```text
Service Registry
      |
      v
Available Instances
      |
      v
Load Balancer
```

The LB needs an up-to-date backend pool.

Common approaches:

```text
Service discovery
DNS-based discovery
Cloud-native service discovery
Kubernetes service mechanisms
Control-plane configuration
```

---

# 57. DNS Load Balancing vs Load Balancer

DNS can distribute users across IPs:

```text
example.com
     |
     +----> IP1
     +----> IP2
     +----> IP3
```

But DNS is not a complete replacement for a load balancer.

Problems include:

```text
DNS caching
TTL behavior
Limited per-request control
Health/failover complexity
Client resolver behavior
```

DNS is often used for:

```text
Global traffic distribution
Region selection
Basic failover
```

while a Load Balancer handles traffic distribution within the selected infrastructure.

---

# 58. Client-Side vs Server-Side Load Balancing

## Server-Side Load Balancing

```text
Client
   |
   v
Load Balancer
   |
   +----> Server A
   +----> Server B
```

The client doesn't choose the backend.

Advantages:

```text
Centralized
Easy for clients
Centralized policies
```

---

## Client-Side Load Balancing

The client/service discovers backend instances and chooses one.

```text
Client
  |
  +----> Server A
  +----> Server B
  +----> Server C
```

Common in some microservice/gRPC architectures.

Advantages:

```text
No centralized LB for every request
Can make service-aware decisions
```

Disadvantages:

```text
More client complexity
Service discovery required
Different clients may implement different logic
```

---

# 59. Health Check vs Circuit Breaker

These are different.

### Health Check

Answers:

> "Is this server currently ready to receive traffic?"

### Circuit Breaker

Answers:

> "Are calls to this dependency failing enough that I should temporarily stop calling it?"

Example:

```text
Load Balancer
→ Health check
→ Backend availability
```

while:

```text
Application
→ Circuit breaker
→ Downstream Service
```

They solve related but different failure problems.

---

# 60. Important Scenario: Uneven Request Cost

Suppose:

```text
Request A → 5 ms
Request B → 10 seconds
```

Round Robin:

```text
A → Server1
B → Server2
C → Server3
D → Server1
```

It does not know that B is expensive.

Possible alternatives:

```text
Least Connections
Least Response Time
Resource-based routing
Separate workloads/queues
```

For extremely expensive asynchronous work, a queue-based architecture may be better than trying to solve everything through LB algorithms.

---

# 61. Important Scenario: Different Server Capacity

```text
Server A → 16 CPU
Server B → 8 CPU
Server C → 4 CPU
```

Normal Round Robin:

```text
A → 33%
B → 33%
C → 33%
```

Potentially inefficient.

Better:

```text
Weighted Round Robin
```

Example:

```text
A → Weight 4
B → Weight 2
C → Weight 1
```

---

# 62. Important Scenario: Long-Lived Connections

Examples:

```text
WebSocket
Streaming
Long polling
Large downloads
```

Round Robin may produce poor balance because one connection may last much longer than another.

Possible approach:

```text
Least Connections
```

along with appropriate connection management.

---

# 63. Important Scenario: Legacy Stateful Application

Problem:

```text
Session stored in Server memory
```

Possible short-term solution:

```text
Sticky Sessions
```

Better long-term solution:

```text
Move session state to shared storage
+
Make application servers stateless
```

---

# 64. Important Scenario: Microservices

Question:

> `/orders` should go to Order Service and `/payments` to Payment Service. Which LB?

Answer:

```text
L7 Load Balancer / API Gateway
```

because it understands HTTP-level routing.

---

# 65. Important Scenario: UDP

Question:

> Application uses UDP. Which type of LB is appropriate?

Answer:

```text
L4 / UDP-capable Load Balancer
```

because UDP is a transport-layer protocol.

---

# 66. Important Scenario: Millions of Requests

Question:

> What if one LB cannot handle the traffic?

Answer:

```text
1. Scale LB horizontally
2. Use multiple LB instances
3. Distribute traffic globally
4. Use CDN for cacheable content
5. Use L4 where L7 inspection isn't required
6. Reduce unnecessary processing
7. Increase network capacity
```

---

# 67. Important Scenario: Zero-Downtime Deployment

Current:

```text
v1 → 100%
```

Deploy v2:

```text
v1 → 90%
v2 → 10%
```

Monitor:

```text
Error rate
Latency
CPU
Memory
Business metrics
```

Then:

```text
v1 → 50%
v2 → 50%
```

Finally:

```text
v1 → 0%
v2 → 100%
```

This is commonly called:

> **Canary Deployment**

---

# 68. Blue-Green Deployment

Architecture:

```text
                 Load Balancer
                      |
             +--------+--------+
             |                 |
             v                 v
          Blue v1          Green v2
```

Initially:

```text
100% → Blue
```

After validation:

```text
100% → Green
```

If Green fails:

```text
100% → Blue
```

Advantages:

```text
Fast rollback
Simple traffic switching
Easy testing
```

Disadvantage:

```text
Can require duplicate infrastructure
```

---

# 69. Load Balancer Security

A Load Balancer can participate in security controls such as:

```text
TLS termination
Rate limiting
IP filtering
Request size limits
Header filtering
Authentication integration
WAF integration
DDoS protection at edge
```

But:

> The Load Balancer should not be the only security layer.

Typical architecture:

```text
Internet
   |
   v
WAF / Edge
   |
   v
Load Balancer
   |
   v
Application
   |
   v
Database
```

Use defense in depth.

---

# 70. Observability

Monitor the Load Balancer.

Important metrics:

```text
Requests/sec
Connections
Active connections
Latency
p50
p95
p99
4xx rate
5xx rate
Backend errors
Backend health
Connection failures
TLS errors
Bandwidth
Queue length
```

Important question:

> Don't only monitor whether the LB is alive. Monitor whether traffic is being successfully served.

---

# 71. Load Balancer Logging

Useful fields:

```text
Timestamp
Client IP
Request ID
Host
Path
HTTP method
Selected backend
Response status
Latency
Bytes sent
TLS information
```

A request ID helps trace:

```text
Client
 ↓
Load Balancer
 ↓
Application
 ↓
Database
```

---

# 72. Common Load Balancer Problems

### Problem 1: Single Point of Failure

Solution:

```text
Multiple LB instances
```

### Problem 2: Backend Overload

Solution:

```text
Better algorithm
Autoscaling
Caching
Queueing
Capacity planning
```

### Problem 3: Sticky Sessions

Solution:

```text
Stateless application
+
Shared session store
```

### Problem 4: Retry Storm

Solution:

```text
Timeouts
Backoff
Jitter
Circuit breaker
Bounded retries
```

### Problem 5: Uneven Server Capacity

Solution:

```text
Weighted algorithms
```

### Problem 6: Slow Backend

Solution:

```text
Least response time
Resource-aware routing
Caching
Database optimization
```

---

# 73. Most Asked Interview Questions

## Q1. What is a Load Balancer?

> A Load Balancer distributes incoming traffic across multiple backend servers to improve scalability, availability, and reliability.

---

## Q2. Why do we need a Load Balancer?

> To distribute traffic, prevent individual servers from becoming overloaded, provide failover, and enable horizontal scaling.

---

## Q3. What is Round Robin?

> Round Robin distributes requests sequentially across backend servers.

---

## Q4. What is Weighted Round Robin?

> Weighted Round Robin assigns different traffic proportions to servers based on their capacity or importance.

---

## Q5. What is Least Connections?

> It sends a new connection/request to the backend with the fewest active connections.

---

## Q6. What is IP Hash?

> It hashes the client IP to select a backend, which can provide session affinity.

---

## Q7. What is the difference between L4 and L7?

> L4 operates primarily using transport-layer information such as TCP/UDP and IP/port information, while L7 understands application-level protocols such as HTTP and can route based on paths, headers, cookies, and other request attributes.

---

## Q8. Which is faster, L4 or L7?

> Generally L4 has lower processing overhead because it doesn't need full application-layer inspection.

---

## Q9. Which is better for REST APIs?

> L7 is usually more suitable because APIs commonly need HTTP-aware routing, TLS termination, header handling, and application-level policies.

---

## Q10. Which is better for UDP?

> An L4/UDP-capable load balancer.

---

## Q11. What happens if a backend server fails?

> Health checks detect the failure and the LB removes the server from the active pool so new traffic goes to healthy servers.

---

## Q12. What happens if the Load Balancer itself fails?

> A single LB would be a Single Point of Failure. Use multiple LB instances and a highly available edge/failover mechanism.

---

## Q13. What is sticky session?

> Sticky session keeps a client associated with the same backend server.

---

## Q14. Why avoid sticky sessions?

> They can create uneven load and make failover and scaling harder. Stateless services with shared session storage are usually more scalable.

---

## Q15. What is health checking?

> Health checking determines whether a backend server is healthy and ready to receive traffic.

---

## Q16. What is connection draining?

> It stops new traffic from going to a server being removed while allowing existing connections to finish gracefully.

---

## Q17. What is slow start?

> Slow start gradually increases traffic to a newly added or recovered backend instead of sending it full traffic immediately.

---

## Q18. Can a Load Balancer cache data?

> Some L7 load balancers/reverse proxies can cache responses, but CDNs and dedicated caches are generally used for specialized caching workloads.

---

## Q19. Can a Load Balancer terminate HTTPS?

> Yes. TLS can terminate at the LB, although HTTPS/mTLS can also continue to backend services when required.

---

## Q20. Can a Load Balancer perform rate limiting?

> Yes, depending on the product. Rate limiting is commonly implemented at the LB/API Gateway/edge layer.

---

# 74. Interview Scenario Questions

## Scenario 1

> Server A has 90% CPU and Server B has 20%. Round Robin is distributing traffic equally. What would you do?

Answer:

```text
Investigate the actual bottleneck first.

Potential solutions:
- Dynamic load balancing
- Least Connections
- Least Response Time
- Resource-based routing
- Autoscaling
- Application optimization
```

---

## Scenario 2

> Server A has 16 CPU cores and Server B has 4. Which algorithm?

Answer:

```text
Weighted Round Robin
```

because server capacities are different.

---

## Scenario 3

> Requests have very different processing times. Which algorithm?

Answer:

```text
Least Connections
or
Least Response Time
```

depending on the workload and what metric best represents actual load.

---

## Scenario 4

> User sessions are stored in application memory. What do you do?

Short-term:

```text
Sticky Sessions
```

Better long-term:

```text
Stateless application
+
Redis/shared session storage
```

---

## Scenario 5

> `/payment/*` must go to Payment Service and `/order/*` to Order Service.

Answer:

```text
L7 Load Balancer / API Gateway
```

because it can inspect HTTP paths.

---

## Scenario 6

> Application uses UDP.

Answer:

```text
L4 / UDP-capable Load Balancer
```

---

## Scenario 7

> One Load Balancer cannot handle millions of requests.

Answer:

```text
Horizontal LB scaling
+
Multiple LB instances
+
Global distribution
+
CDN for cacheable traffic
+
L4 where appropriate
```

---

## Scenario 8

> A backend server is being deployed. How can you avoid dropping active users?

Answer:

```text
Connection draining
+
Graceful shutdown
+
Health checks
```

---

## Scenario 9

> A new server has just recovered. Should you immediately send 33% traffic to it?

Not necessarily.

Use:

```text
Slow Start / Warm-up
```

to gradually increase traffic.

---

## Scenario 10

> What if every backend server is unhealthy?

Possible actions:

```text
Return 503
Fail over to another region
Serve cached/static content where appropriate
Trigger alerts
Use graceful degradation
```

Avoid infinite retries.

---

# 75. Important Interview Tradeoffs

## Round Robin vs Least Connections

```text
Round Robin
→ Simpler
→ Lower overhead
→ Good for similar workloads

Least Connections
→ More adaptive
→ Better for long-lived connections
→ More overhead
```

---

## L4 vs L7

```text
L4
→ Faster
→ Lower overhead
→ TCP/UDP
→ Less application awareness

L7
→ More flexible
→ HTTP-aware
→ Path/header/cookie routing
→ More processing
```

---

## Sticky Session vs Stateless

```text
Sticky
→ Easy for legacy stateful applications
→ Less flexible
→ Can cause uneven load

Stateless
→ Better scalability
→ Better failover
→ Requires shared/external state where needed
```

---

## Static vs Dynamic

```text
Static
→ Simple
→ Predictable
→ Doesn't react to current load

Dynamic
→ Adaptive
→ More complex
→ Requires current server metrics
```

---

# 76. Complete Production Architecture

A large-scale system may look like:

```text
                         USERS
                           |
                           v
                    DNS / Global Routing
                           |
                           v
                      CDN / Edge
                           |
                           v
                          WAF
                           |
                           v
                 Global Load Balancer
                    /             \
                   v               v
                Region A         Region B
                   |               |
                   v               v
                 L7 LB            L7 LB
                   |               |
          +--------+--------+      +--------+
          |        |        |      |        |
          v        v        v      v        v
        App-1    App-2    App-3   App-4   App-5
          |        |        |      |        |
          +--------+--------+------+--------+
                           |
                       Redis/Cache
                           |
                           v
                        Database
```

For very high-throughput/non-HTTP traffic:

```text
Client
  |
  v
L4 Load Balancer
  |
  +----> Service 1
  +----> Service 2
  +----> Service 3
```

---

# 77. ⭐ Final Recall Cheat Sheet

```text
LOAD BALANCER
→ Distributes traffic across backend servers.

WHY?
→ Scalability
→ High availability
→ Failover
→ Prevent overload
→ Better traffic management

L4
→ Transport Layer
→ TCP / UDP
→ IP + Port + connection information
→ Fast
→ Low overhead
→ Less application-aware

L7
→ Application Layer
→ HTTP / HTTPS
→ URL / path / header / cookie aware
→ Flexible
→ More processing

STATIC
→ Fixed rules

DYNAMIC
→ Current server state

ROUND ROBIN
→ Take turns
→ A → B → C → A

WEIGHTED ROUND ROBIN
→ Stronger server gets more traffic

IP HASH
→ Client IP → Hash → Backend
→ Useful for affinity
→ NAT/backend changes can cause imbalance/remapping

LEAST CONNECTIONS
→ Choose server with fewest active connections

WEIGHTED LEAST CONNECTIONS
→ Connections + server capacity

LEAST RESPONSE TIME
→ Prefer faster backend

RESOURCE BASED
→ CPU / memory / queue / custom metrics

RANDOM
→ Random server

POWER OF TWO
→ Pick two → choose less loaded

CONSISTENT HASHING
→ Stable key-to-server mapping
→ Minimize remapping when servers change
→ Useful for caching/sharding/affinity

HEALTH CHECK
→ Detect unhealthy backend

LIVENESS
→ Is process alive?

READINESS
→ Can it receive traffic?

CONNECTION DRAINING
→ Existing connections finish
→ New requests go elsewhere

SLOW START
→ Gradually increase traffic to recovered/new server

STICKY SESSION
→ Same client → same server
→ Useful for legacy stateful apps
→ Stateless + shared state is generally better

TLS TERMINATION
→ Client HTTPS → LB → Backend

GLOBAL LB
→ Choose region

REGIONAL LB
→ Choose server inside region

HIGH AVAILABILITY
→ Multiple LB instances
→ Failover
→ Health checks

AUTOSCALING
→ Add/remove backend instances based on demand

ONE-LINE MEMORY:

L4 = "Which connection?"
L7 = "Which request?"

Round Robin = "Take turns."
Weighted RR = "Give stronger servers more."
IP Hash = "Same client tends toward same server."
Least Connections = "Choose least busy by connections."
Least Response Time = "Choose faster server."
Resource Based = "Choose server with available resources."
Consistent Hashing = "Keep mapping stable when servers change."
Health Check = "Don't send traffic to unhealthy servers."
Connection Draining = "Let existing traffic finish."
Slow Start = "Warm up recovered servers."
```

---

# 78. ⭐ Best Interview Answer Structure

When asked:

> **"Design a Load Balancer"**

Answer in this order:

```text
1. Define the problem
   ↓
2. Functional requirements
   ↓
3. Traffic assumptions / scale
   ↓
4. L4 or L7?
   ↓
5. Backend server pool
   ↓
6. Load balancing algorithm
   ↓
7. Health checks
   ↓
8. Failure handling
   ↓
9. High availability of LB
   ↓
10. Session management
   ↓
11. TLS termination
   ↓
12. Scaling / autoscaling
   ↓
13. Observability
   ↓
14. Security
   ↓
15. Tradeoffs
```

### Example Short Interview Answer

> "I would place a highly available Load Balancer in front of multiple stateless application servers. If the system is HTTP-based and requires path/header-based routing, I would use an L7 LB. Otherwise, for high-throughput TCP/UDP traffic, I would consider L4. For identical servers and uniform workloads, Round Robin is simple; for different server capacities, Weighted Round Robin is better; for long-lived connections, Least Connections can be more appropriate. I would add health checks, connection draining, slow start, TLS termination where appropriate, autoscaling, monitoring, and multiple LB instances to avoid a single point of failure. For stateful applications, I would prefer externalizing session state rather than relying on sticky sessions."