# Proxy Servers in System Design
## Forward Proxy vs Reverse Proxy + VPN vs Load Balancer vs Firewall

---

# 1. What is a Proxy Server?

A **proxy server** is an intermediary between two systems that receives a request from one side and forwards it to another side.

Simple flow:

```text
Client → Proxy → Server
```

The proxy can inspect, modify, filter, cache, route, or control traffic depending on its purpose.

### Fundamental Role of a Proxy

A proxy is commonly used for:

- Traffic control
- Security
- Hiding network details
- Routing
- Caching
- Authentication
- Rate limiting
- Logging and monitoring
- TLS termination
- Access control

---

# 2. Two Main Types of Proxy

There are two important types for system design interviews:

```text
1. Forward Proxy
2. Reverse Proxy
```

The easiest way to remember them:

```text
Forward Proxy  → represents the CLIENT

Reverse Proxy  → represents the SERVER
```

---

# 3. Forward Proxy

A **forward proxy** is placed between clients and external servers.

```text
Client
   |
   v
Forward Proxy
   |
   v
Internet
   |
   v
Destination Server
```

The client sends the request to the proxy, and the proxy sends it to the destination.

### Example

A company wants all employee internet traffic to pass through a corporate proxy.

```text
Employee
   |
   v
Corporate Proxy
   |
   +----> Google
   +----> GitHub
   +----> Other Websites
```

The company can use the proxy to:

- Block websites
- Monitor traffic
- Apply access policies
- Cache content
- Control outbound traffic

---

# 4. Forward Proxy Example

Suppose:

```text
Employee → Proxy → example.com
```

The employee does not directly communicate with the destination in the normal architecture.

The proxy can check:

```text
Who is making the request?
Where are they going?
Is the destination allowed?
Should the request be logged?
Is cached data available?
```

If the request is allowed:

```text
Client
  |
  v
Proxy
  |
  v
example.com
```

If blocked:

```text
Client
  |
  v
Proxy
  |
  X
Blocked
```

---

# 5. Reverse Proxy

A **reverse proxy** is placed in front of backend servers.

```text
Client
   |
   v
Reverse Proxy
   |
   +----> Server 1
   +----> Server 2
   +----> Server 3
```

The client communicates with the reverse proxy rather than directly selecting a backend server.

The reverse proxy decides where the request should go.

---

# 6. Why Use a Reverse Proxy?

Suppose you have:

```text
100 Application Servers
```

You don't want clients to know:

```text
Server 1 IP
Server 2 IP
Server 3 IP
...
Server 100 IP
```

Instead:

```text
Client
   |
   v
api.example.com
   |
   v
Reverse Proxy
   |
   +----> App 1
   +----> App 2
   +----> App 3
```

The client only knows:

```text
api.example.com
```

The backend infrastructure remains hidden.

---

# 7. Responsibilities of a Reverse Proxy

A reverse proxy can perform many system-design functions.

### 1. Routing

```text
/api/users  → User Service

/api/orders → Order Service

/api/payment → Payment Service
```

### 2. Load Balancing

```text
Request
   |
   v
Reverse Proxy
   |
   +----> Server 1
   +----> Server 2
   +----> Server 3
```

### 3. TLS Termination

```text
Client
  |
 HTTPS
  |
  v
Reverse Proxy
  |
 HTTP/HTTPS
  |
  v
Backend
```

### 4. Caching

```text
Client
  |
  v
Reverse Proxy
  |
  +---- Cache HIT → Response
  |
  +---- Cache MISS → Backend
```

### 5. Rate Limiting

```text
Client
  |
  v
Reverse Proxy
  |
  +---- Allowed → Backend
  |
  +---- Too many requests → 429
```

### 6. Authentication

The proxy/gateway can validate authentication tokens before forwarding requests.

### 7. Health Checks

```text
Server 1 → Healthy
Server 2 → Healthy
Server 3 → Unhealthy
```

Traffic is sent only to healthy servers.

---

# 8. Proxy vs Reverse Proxy

| Feature | Forward Proxy | Reverse Proxy |
|---|---|---|
| Represents | Client | Server |
| Position | Client side | Server side |
| Main direction | Outbound | Inbound |
| Hides | Client details | Backend details |
| Common use | Corporate internet | Web applications |
| Load balancing | Not primary | Common |
| Caching | Possible | Common |
| TLS termination | Possible | Very common |
| Routing | Possible | Common |
| Backend protection | Limited | Important role |

### Memory Trick

```text
Forward:
Client → Proxy → Internet

Reverse:
Internet → Proxy → Server
```

---

# 9. Proxy vs VPN

Proxy and VPN are often confused.

## Proxy

```text
Application
    |
    v
Proxy
    |
    v
Internet
```

A proxy forwards traffic through an intermediary.

A proxy is **not inherently encrypted**.

---

## VPN

A VPN creates a secure tunnel between the client/network and the VPN endpoint.

```text
Client
   |
   | Encrypted Tunnel
   |
   v
VPN Gateway
   |
   v
Private Network / Internet
```

### Main Difference

```text
Proxy
→ Traffic intermediary

VPN
→ Secure network tunnel
```

---

# 10. Proxy vs VPN Comparison

| Feature | Proxy | VPN |
|---|---|---|
| Main purpose | Forward traffic | Secure network connectivity |
| Encryption | Not inherent | Secure encrypted tunnel is a core feature |
| Scope | Often application/protocol specific | Network/device level depending on setup |
| Hide client IP | Usually for proxied traffic | Usually |
| Corporate use | Filtering/access control | Remote access |
| Performance overhead | Usually lower | Usually higher |
| Security | Depends on configuration | Designed for secure tunneling |

### Example

Company website filtering:

```text
Employee
   ↓
Forward Proxy
   ↓
Internet
```

Remote employee accessing internal systems:

```text
Employee
   ↓
VPN
   ↓
Company Network
```

---

# 11. Proxy vs Load Balancer

These are related but not identical.

## Load Balancer

The primary responsibility is:

> **Distribute traffic across multiple servers.**

```text
Client
  |
  v
Load Balancer
  |
  +----> Server 1
  +----> Server 2
  +----> Server 3
```

Typical algorithms:

```text
Round Robin
Weighted Round Robin
Least Connections
IP Hash
Consistent Hashing
```

---

## Reverse Proxy

A reverse proxy has broader responsibilities:

```text
Routing
TLS
Caching
Authentication
Rate limiting
Load balancing
Security
Compression
Health checks
```

### Important Interview Statement

> A load balancer can distribute traffic, while a reverse proxy can perform load balancing plus several other application/network-level functions.

There is significant overlap, and modern products can perform both roles.

---

# 12. Reverse Proxy + Load Balancer

Very common system design architecture:

```text
                    Internet
                       |
                       v
              Load Balancer / Edge
                       |
             +---------+---------+
             |                   |
             v                   v
        Reverse Proxy 1     Reverse Proxy 2
             |                   |
             +---------+---------+
                       |
              +--------+--------+
              |        |        |
              v        v        v
            App 1    App 2    App 3
```

This gives:

- High availability
- Horizontal scaling
- Backend protection
- Traffic distribution
- Failover

---

# 13. Proxy vs Firewall

A **firewall** controls whether network traffic is allowed or denied according to security rules.

```text
Internet
   |
   v
Firewall
   |
   v
Internal Network
```

Example:

```text
Allow TCP 443
Allow TCP 80
Block everything else
```

A firewall is primarily about:

> **Network security and traffic filtering.**

---

# 14. Firewall vs Proxy

| Feature | Firewall | Proxy |
|---|---|---|
| Primary purpose | Security/filtering | Intermediary traffic handling |
| Traffic filtering | Yes | Yes |
| Routing | Limited/different role | Yes |
| Caching | No/rarely primary | Common |
| Application-level inspection | Some firewalls can | Common for proxies |
| Hides backend | Not necessarily | Reverse proxy does |
| Load balancing | Not primary | Can |
| Authentication | Sometimes | Common in gateways/proxies |

Modern firewalls can include advanced application-layer functionality, so boundaries can overlap.

---

# 15. Four Technologies — Easy Comparison

```text
FORWARD PROXY
================

Client
  |
  v
Proxy
  |
  v
Internet

Purpose:
Represents CLIENT
```

```text
REVERSE PROXY
================

Client
  |
  v
Reverse Proxy
  |
  v
Backend

Purpose:
Represents SERVER
```

```text
LOAD BALANCER
================

Client
  |
  v
Load Balancer
  |
  +----> Server 1
  +----> Server 2
  +----> Server 3

Purpose:
DISTRIBUTE TRAFFIC
```

```text
FIREWALL
================

Internet
   |
   v
Firewall
   |
   +----> Allow
   |
   +----> Block

Purpose:
CONTROL TRAFFIC ACCESS
```

```text
VPN
================

Client
   |
   | Encrypted Tunnel
   |
   v
VPN Gateway
   |
   v
Private Network

Purpose:
SECURE NETWORK CONNECTIVITY
```

---

# 16. Caching with Proxy

Caching is one of the important benefits of a proxy.

Suppose:

```text
1000 users
```

request:

```text
GET /products/1
```

Without caching:

```text
1000 requests
      ↓
Application
      ↓
Database
```

With proxy cache:

```text
1000 requests
      ↓
Reverse Proxy
      |
      +---- 999 requests → Cache
      |
      +---- 1 request → Backend
```

This can reduce:

- Backend load
- Database load
- Network traffic
- Response latency

---

# 17. Cache HIT vs Cache MISS

## Cache HIT

```text
Client
  |
  v
Proxy
  |
  v
Cache HIT
  |
  v
Response
```

Backend is not contacted.

---

## Cache MISS

```text
Client
  |
  v
Proxy
  |
  v
Cache MISS
  |
  v
Backend
  |
  v
Response
```

The response can potentially be cached for future requests if it is cacheable.

---

# 18. Proxy in Microservices

Suppose we have:

```text
User Service
Order Service
Payment Service
Inventory Service
```

Instead of exposing every service:

```text
                    Internet
                       |
                       v
               API Gateway /
               Reverse Proxy
                       |
        +--------------+--------------+
        |              |              |
        v              v              v
      User           Order         Payment
     Service         Service        Service
```

The gateway/reverse proxy can provide:

```text
Authentication
Authorization
Routing
Rate limiting
TLS
Logging
Metrics
Request transformation
```

---

# 19. Scenario: Backend Server Failure

### Interview Question

> What happens if one backend server crashes?

Answer:

Use health checks.

```text
Reverse Proxy / LB

Server 1 → ✓
Server 2 → ✓
Server 3 → ✗
```

Remove Server 3 from the traffic pool.

```text
Requests
   |
   +----> Server 1
   |
   +----> Server 2
   |
   X----> Server 3
```

When Server 3 becomes healthy again, it can be added back.

---

# 20. Scenario: Proxy Failure

### Interview Question

> What if your reverse proxy fails?

A single proxy creates a single point of failure:

```text
Client
  |
  v
Proxy ← DOWN
  |
  X
Backend
```

Use multiple proxy instances:

```text
              Edge / LB
             /         \
            v           v
        Proxy 1       Proxy 2
            |           |
            +-----+-----+
                  |
              Backend
```

Important:

> The proxy layer itself must be highly available.

---

# 21. Scenario: Traffic Increases 10x

### Interview Question

> Traffic increases from 10K to 100K requests/sec. What would you do?

First identify the bottleneck.

Check:

```text
Proxy CPU
Proxy memory
Network bandwidth
Backend CPU
Database
Cache
Connection pools
Downstream services
```

Then scale horizontally:

```text
              Load Balancer
             /      |      \
            v       v       v
         Proxy 1 Proxy 2 Proxy 3
            |       |       |
            +-------+-------+
                    |
              App Servers
```

Do not assume that adding application servers alone solves the problem.

---

# 22. Scenario: Rate Limiting

### Question

> How can a proxy protect the backend from excessive requests?

Use rate limiting.

Example:

```text
100 requests/minute/user
```

Architecture:

```text
Client
  |
  v
Reverse Proxy
  |
  +---- Under limit → Backend
  |
  +---- Over limit → 429
```

For multiple proxy instances, rate-limit state may need a shared/distributed store:

```text
Proxy 1 ──┐
Proxy 2 ──┼──> Redis / Distributed Counter
Proxy 3 ──┘
```

Common algorithms:

```text
Token Bucket
Leaky Bucket
Fixed Window
Sliding Window
```

---

# 23. Scenario: HTTPS

### Question

> We have 100 backend servers. Where should TLS certificates be managed?

One common design:

```text
Client
  |
  | HTTPS
  v
Reverse Proxy
  |
  | HTTP/HTTPS
  v
Backend
```

TLS terminates at the reverse proxy.

Benefits:

```text
Centralized certificate management
Easy certificate renewal
Simpler backend configuration
```

If security requires encryption inside the infrastructure:

```text
Client
  |
 HTTPS
  v
Proxy
  |
 HTTPS / mTLS
  v
Backend
```

---

# 24. Scenario: Zero-Downtime Deployment

Suppose:

```text
v1 → Current production
v2 → New version
```

Traffic can be gradually moved:

```text
90% → v1
10% → v2
```

Then:

```text
50% → v1
50% → v2
```

Finally:

```text
0% → v1
100% → v2
```

This is commonly used with **canary deployments**.

A proxy/load balancer can help control traffic routing.

---

# 25. Scenario: Blue-Green Deployment

Architecture:

```text
             Reverse Proxy
                   |
          +--------+--------+
          |                 |
          v                 v
       Blue v1           Green v2
```

Initially:

```text
100% → Blue
```

After testing:

```text
100% → Green
```

If v2 fails:

```text
100% → Blue
```

This provides a fast rollback mechanism.

---

# 26. Scenario: WebSocket

A reverse proxy can proxy WebSocket connections.

```text
Client
  |
  | WebSocket
  v
Reverse Proxy
  |
  +----> WS Server 1
  |
  +----> WS Server 2
```

Important considerations:

```text
Long-lived connections
Connection timeout
Upgrade headers
Health checks
Reconnection
Sticky sessions if required
Shared state/pub-sub
```

For example:

```text
User A → WS Server 1
User B → WS Server 2
```

If they need cross-server communication:

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

# 27. Scenario: Static Files

Suppose application servers serve:

```text
Images
CSS
JavaScript
Videos
```

This can consume application bandwidth.

Better:

```text
Client
  |
  v
CDN / Edge Cache
  |
  +---- Cache HIT → Response
  |
  +---- Cache MISS
           |
           v
         Origin
```

For globally distributed static content, a CDN is generally preferred.

---

# 28. Scenario: Large File Upload

Suppose users upload 1 GB files.

Don't necessarily route the entire file through the application:

```text
Client
  |
  v
API
  |
  v
Application
  |
  v
Object Storage
```

A better architecture can be:

```text
Client
  |
  v
API
  |
  v
Pre-signed Upload URL
  |
  v
Object Storage
```

The application handles authorization/metadata while the client uploads directly to storage.

Benefits:

```text
Lower application bandwidth
Lower CPU/memory usage
Better scalability
```

---

# 29. Proxy Security Model

A reverse proxy can be used as a security boundary:

```text
Internet
   |
   v
WAF / Edge
   |
   v
Reverse Proxy
   |
   v
Private Network
   |
   +----> App
```

Possible controls:

```text
TLS
Rate limiting
Request validation
Authentication
IP filtering
Request-size limits
Header filtering
Connection limits
```

However:

> A reverse proxy should not be treated as the only security layer.

Use defense in depth:

```text
WAF
+
Firewall
+
Reverse Proxy
+
Application Authentication
+
Authorization
+
Network Security
```

---

# 30. Reverse Proxy vs API Gateway

They overlap heavily, but their primary focus differs.

### Reverse Proxy

Usually focuses on:

```text
Routing
TLS
Load balancing
Caching
Traffic management
```

### API Gateway

Usually focuses more on API-level concerns:

```text
Authentication
Authorization
Rate limiting
API versioning
Request transformation
Request aggregation
API analytics
```

In modern systems, one component may perform both roles.

---

# 31. Important Tradeoffs of Reverse Proxy

## Advantages

```text
+ Hides backend servers
+ Centralized TLS
+ Load balancing
+ Routing
+ Caching
+ Rate limiting
+ Authentication
+ Health checks
+ Easier traffic management
+ Backend scalability
```

## Disadvantages

```text
- Adds network hop
- Can become bottleneck
- Configuration complexity
- Potential single point of failure
- Requires high availability
- Can add latency
- Centralized component requires careful scaling
```

### Solution to Bottleneck

```text
Horizontal scaling
+
Multiple proxy instances
+
Load balancing
+
Health checks
+
Autoscaling
```

---

# 32. Important Tradeoffs of Forward Proxy

## Advantages

```text
+ Centralized outbound control
+ Access filtering
+ Logging
+ Monitoring
+ Caching
+ Policy enforcement
```

## Disadvantages

```text
- Additional latency
- Additional infrastructure
- Proxy failure can affect users
- Configuration complexity
- Privacy/security concerns if improperly configured
```

---

# 33. Interview Questions

## Q1. What is a proxy?

> A proxy is an intermediary that receives traffic from one side and forwards it to another system while potentially applying policies such as routing, filtering, caching, or security controls.

---

## Q2. What is the difference between forward and reverse proxy?

> A forward proxy represents the client and controls outbound traffic. A reverse proxy represents backend servers and manages incoming traffic before forwarding it to the appropriate backend.

---

## Q3. Is a reverse proxy a load balancer?

> Not exactly. A reverse proxy is an intermediary component that can provide many functions. Load balancing is one of the functions a reverse proxy can perform.

---

## Q4. Is a VPN the same as a proxy?

> No. A proxy forwards traffic through an intermediary, while a VPN provides a secure network tunnel according to its VPN protocol and configuration.

---

## Q5. What is the difference between a firewall and proxy?

> A firewall primarily controls whether traffic is allowed or blocked according to security rules. A proxy intermediates traffic and can additionally perform routing, caching, authentication, and other traffic-management functions.

---

## Q6. Why put a reverse proxy in front of application servers?

> To hide backend infrastructure and centralize routing, load balancing, TLS termination, caching, rate limiting, security controls, and health checks.

---

## Q7. What happens if the reverse proxy goes down?

> If there is only one proxy, it becomes a single point of failure. Deploy multiple proxy instances behind a highly available edge/load-balancing layer and use health checks and automatic failover.

---

## Q8. Can a proxy cache responses?

> Yes. A proxy can cache cacheable responses and serve subsequent requests without contacting the backend, reducing latency and backend load.

---

## Q9. Where should rate limiting happen?

> A common location is the API gateway or reverse-proxy layer because it can reject excessive traffic before it reaches expensive backend resources.

---

## Q10. Can a reverse proxy terminate TLS?

> Yes. TLS can terminate at the reverse proxy, centralizing certificate management. HTTPS or mTLS can continue to backend services when required.

---

# 34. Most Important Interview Scenarios

```text
Employee internet control
→ Forward Proxy

Remote secure network access
→ VPN

Multiple backend servers
→ Load Balancer

Hide backend infrastructure
→ Reverse Proxy

API routing
→ Reverse Proxy / API Gateway

Rate limiting
→ Reverse Proxy / API Gateway

Backend response caching
→ Reverse Proxy / Cache

Global static content
→ CDN

Network traffic filtering
→ Firewall

HTTPS certificate centralization
→ Reverse Proxy / Load Balancer

Zero-downtime traffic migration
→ Load Balancer / Reverse Proxy

Backend health checks
→ Load Balancer / Reverse Proxy

Backend high availability
→ Multiple instances + Load Balancer

Proxy high availability
→ Multiple proxy instances + HA edge

Large file upload
→ Object Storage + direct/pre-signed upload

Microservice entry point
→ API Gateway / Reverse Proxy
```

---

# 35. ⭐ Final Recall Cheat Sheet

```text
PROXY
→ Intermediary between two systems.

FORWARD PROXY
→ Represents CLIENT.
→ Controls outbound traffic.

REVERSE PROXY
→ Represents SERVER.
→ Controls inbound traffic.

LOAD BALANCER
→ Distributes traffic across servers.

FIREWALL
→ Allows or blocks network traffic.

VPN
→ Creates secure network connectivity/tunnel.

CDN
→ Delivers cached content close to users.
```

### One-Line Memory Trick

```text
Forward Proxy = Client side
Reverse Proxy = Server side
Load Balancer = Distribute
Firewall = Allow / Block
VPN = Secure Tunnel
CDN = Cache / Deliver Content
```

### Typical Production Architecture

```text
                         INTERNET
                            |
                            v
                       DNS / CDN
                            |
                            v
                       WAF / Edge
                            |
                            v
                 Load Balancer / Proxy
                            |
              +-------------+-------------+
              |             |             |
              v             v             v
           App 1          App 2          App N
              |             |             |
              +-------------+-------------+
                            |
                          Cache
                            |
                         Database
```

### Core Interview Principle

> **Always start with the requirement. Use a forward proxy when you need to control client-side outbound traffic, a reverse proxy when you need to manage/protect backend services, a load balancer when traffic must be distributed, a firewall when access must be allowed/blocked, a VPN when secure network connectivity is required, and a CDN when content should be cached and delivered close to users.**