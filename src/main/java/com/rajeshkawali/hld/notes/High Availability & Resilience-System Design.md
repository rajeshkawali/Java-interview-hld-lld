# High Availability & Resilience — HLD System Design

> **Interview Topic:** Design High Availability & Resilience System  
> **Key Concepts:** Active-Passive, Active-Active, Failover, Multi-AZ, Multi-Region, Replication, Disaster Recovery, Resilience Patterns

---

## 1. What is High Availability?

### Definition

**High Availability (HA)** means designing a system so that it remains available even when some components fail.

```text
HA = Redundancy + Failover + Health Checks + Recovery
```

### Example

Without HA:

```text
User
  |
  v
Server
  |
  X
Server Down
  |
  v
Application Down
```

With HA:

```text
              Load Balancer
              /           \
             v             v
         Server A       Server B
            X              |
         Failed            |
                           v
                       Response
```

If Server A fails, Server B continues serving requests.

---

# 2. What is Resilience?

### Definition

**Resilience** is the ability of a system to:

1. Detect failures
2. Tolerate failures
3. Recover from failures
4. Continue providing acceptable service

```text
Failure
   |
   v
Detect
   |
   v
Isolate
   |
   v
Recover
   |
   v
Continue Service
```

### Simple Difference

| Concept | Meaning |
|---|---|
| Availability | Is the system available? |
| Resilience | Can the system survive and recover from failures? |

### Example

If the payment service goes down but users can still browse products and add items to the cart:

> The system is showing **resilience** through graceful degradation.

---

# 3. Why Do We Need High Availability?

Failures can happen at every layer:

```text
Application Server
Database
Cache
Message Queue
Network
Disk
Availability Zone
Data Center
Cloud Region
Deployment
Traffic Spike
```

The goal is:

> **No Single Point of Failure (SPOF).**

---

# 4. Single Point of Failure (SPOF)

A **Single Point of Failure** is a component whose failure can bring down the entire system.

### Bad Architecture

```text
                Load Balancer
                     |
                     v
                 App Server
                     |
                     v
                  DB Server
```

If the DB fails:

```text
DB Down
   |
   v
Application Down
```

### Better Architecture

```text
                 Load Balancer
                /      |      \
               v       v       v
             App1    App2    App3
               \       |      /
                \      |     /
                 v     v    v
                  DB Cluster
                 /         \
                v           v
            Primary       Replica
```

Now individual application servers can fail without taking down the entire application.

---

# 5. Core HA Strategies

## 5.1 Redundancy

Run multiple instances.

```text
App1
App2
App3
```

If one fails:

```text
App1 -> DOWN
App2 -> UP
App3 -> UP
```

---

## 5.2 Failover

Move traffic/workload from a failed component to a healthy component.

```text
Primary
   |
   X
Failure
   |
   v
Replica
   |
   v
Become Primary
```

---

## 5.3 Health Checks

Load balancer continuously checks instances.

```text
Load Balancer
     |
     +---- App1 -> Healthy
     |
     +---- App2 -> Healthy
     |
     +---- App3 -> Unhealthy
```

App3 is removed from the traffic pool.

---

## 5.4 Replication

Maintain multiple copies of data.

```text
Primary DB
   |
   +------> Replica 1
   |
   +------> Replica 2
```

Replication improves availability and can also improve read scalability.

---

# 6. Active-Passive Architecture

## Definition

In **Active-Passive**, one instance handles traffic while another remains available as a standby.

```text
                  Load Balancer
                       |
             +---------+---------+
             |                   |
             v                   v
        ACTIVE SERVER       PASSIVE SERVER
             |                   |
          Traffic              Standby
             |                   |
             v                   X
```

Normally:

```text
Active   -> Handles requests
Passive  -> Waits
```

If Active fails:

```text
Active
  |
  X
Failure
  |
  v
Failover
  |
  v
Passive
  |
  v
Now Active
```

---

# 7. Active-Passive Example — Database

```text
              Application
                   |
                   v
              Primary DB
                   |
                   v
              Standby DB
```

Normal:

```text
Primary DB -> READ/WRITE
Standby DB -> Replication
```

If Primary fails:

```text
Primary DB
    X
    |
    v
Failover
    |
    v
Standby DB
    |
    v
New Primary
```

---

# 8. Advantages of Active-Passive

```text
+ Simple architecture
+ Easier consistency management
+ Easier to reason about
+ Good for critical systems
+ Easier database failover model
```

# 9. Disadvantages of Active-Passive

```text
- Standby resources may be underutilized
- Failover takes time
- Possible temporary downtime
- Standby can have replication lag
- Failover process must be tested
```

---

# 10. Active-Active Architecture

## Definition

In **Active-Active**, multiple instances serve traffic simultaneously.

```text
                 Load Balancer
                /      |      \
               v       v       v
             App1    App2    App3
              |       |       |
              +-------+-------+
                      |
                      v
                  Database
```

All instances are active.

If App1 fails:

```text
App1 -> DOWN

App2 -> Continue
App3 -> Continue
```

The load balancer sends traffic to the remaining healthy instances.

---

# 11. Active-Active Example

Suppose:

```text
Traffic = 3,000 requests/sec
```

Three servers:

```text
App1 -> 1,000 req/sec
App2 -> 1,000 req/sec
App3 -> 1,000 req/sec
```

If App1 fails:

```text
App2 -> 1,500 req/sec
App3 -> 1,500 req/sec
```

assuming the remaining servers have enough capacity.

---

# 12. Advantages of Active-Active

```text
+ Better resource utilization
+ Better availability
+ Easy horizontal scaling
+ No dedicated idle standby
+ Good for high traffic
+ Useful for multi-region systems
```

# 13. Disadvantages of Active-Active

```text
- More complex
- Data consistency becomes harder
- Conflict resolution may be required
- Session management becomes important
- Cross-region latency can increase
- More operational complexity
```

---

# 14. Active-Active vs Active-Passive

| Feature | Active-Passive | Active-Active |
|---|---|---|
| Traffic | One active | Multiple active |
| Standby | Yes | No dedicated standby |
| Resource utilization | Lower | Higher |
| Complexity | Lower | Higher |
| Failover | Required | Traffic redistributed |
| Consistency | Easier | More difficult |
| Scalability | Good | Excellent |
| Cost efficiency | Lower utilization | Better utilization |
| Multi-region | Possible | Common |
| Best for | Simplicity | High scale/availability |

### Interview Memory

```text
Active-Passive
= One works + one waits

Active-Active
= Both/all work
```

---

# 15. Multi-AZ Architecture

Never put all application instances in a single Availability Zone if high availability is required.

### Bad

```text
             Region
                |
               AZ1
          /     |     \
        App1   App2   DB
```

If AZ1 fails:

```text
Entire application -> DOWN
```

### Better

```text
                    Region
                 /          \
                v            v
              AZ1            AZ2
           /       \       /      \
         App1     App2   App3    App4
```

If AZ1 fails:

```text
AZ1 -> DOWN

AZ2 -> Continue Serving
```

---

# 16. Multi-Region Architecture

For disaster-level protection, deploy the system in multiple regions.

```text
                  Global Load Balancer
                    /             \
                   v               v
              Region A         Region B
                 |                 |
             App1 App2          App3 App4
                 |                 |
                 v                 v
                DB                DB
```

If Region A fails:

```text
Region A -> DOWN

Traffic
   |
   v
Region B
```

---

# 17. Active-Passive Multi-Region

```text
                 Global DNS/LB
                       |
                       v
                  Region A
                    ACTIVE
                       |
                       X
                   Failure
                       |
                       v
                  Region B
                   PASSIVE
                       |
                       v
                   ACTIVE
```

### Advantage

Simpler than active-active.

### Disadvantage

Some capacity is reserved for failover and recovery may take time.

---

# 18. Active-Active Multi-Region

```text
                 Global Load Balancer
                  /               \
                 v                 v
             Region A          Region B
             /      \           /      \
           App      App       App      App
             \      /           \      /
              \    /             \    /
               DB                 DB
                 \               /
                  \-------------/
                    Replication
```

Both regions serve traffic.

### Benefits

```text
+ Very high availability
+ Lower latency for global users
+ Better resource utilization
+ Region-level failure tolerance
```

### Problems

```text
- Cross-region replication
- Data conflicts
- Consistency issues
- Network partitions
- Higher complexity
- Higher cost
```

---

# 19. Database HA

Database is usually one of the most important HA components.

Basic architecture:

```text
              Application
                   |
                   v
              Primary DB
              /         \
             v           v
        Replica 1     Replica 2
```

If Primary fails:

```text
Primary
   X
   |
   v
Replica 1
   |
   v
Promoted to Primary
```

---

# 20. Synchronous Replication

Data is replicated before the write is considered complete.

```text
Client
  |
  v
Primary
  |
  v
Replica
  |
 ACK
  |
  v
Commit
```

### Advantages

```text
+ Stronger consistency
+ Less data loss during failover
```

### Disadvantages

```text
- Higher latency
- Network failure can affect writes
- Lower write availability in some designs
```

---

# 21. Asynchronous Replication

Primary commits first and replication happens later.

```text
Client
  |
  v
Primary
  |
  +----> Commit
  |
  +----> Replica later
```

### Advantages

```text
+ Lower write latency
+ Better availability
+ Better performance
```

### Disadvantages

```text
- Replication lag
- Recent writes may not exist on replica
- Possible data loss during failover
```

---

# 22. Stateless Application Design

For HA, application servers should preferably be **stateless**.

### Bad

```text
User
 |
 v
Server A
 |
 Session stored only in memory
```

If Server A fails:

```text
Session -> Lost
```

### Better

```text
              Load Balancer
              /     |     \
             v      v      v
           App1   App2   App3
              \     |     /
               \    |    /
                  Redis
```

Session/state is stored externally.

Now any application server can handle the request.

---

# 23. Resilience Patterns

High availability alone is not enough.

Use:

```text
Timeout
Retry
Circuit Breaker
Bulkhead
Rate Limiting
Backpressure
Load Shedding
Graceful Degradation
Health Checks
Failover
```

---

# 24. Timeout

Never wait indefinitely for a downstream service.

```text
Service A
   |
   v
Service B
   |
   X
No response
```

Without timeout:

```text
Service A waits forever
Threads get exhausted
System becomes unhealthy
```

With timeout:

```text
Service A
   |
   v
Service B
   |
   X
2 sec timeout
   |
   v
Fallback / Error
```

---

# 25. Retry

Retry temporary failures.

```text
Request
   |
   v
Failure
   |
   v
Retry
   |
   v
Failure
   |
   v
Retry
   |
   v
Success
```

Use:

```text
Exponential Backoff
+
Jitter
```

### Important

Do not blindly retry every request.

For example:

```text
POST /payment
```

Retrying without idempotency protection could potentially charge a customer more than once.

---

# 26. Circuit Breaker

Prevents cascading failures.

```text
Service A
   |
   v
Circuit Breaker
   |
   v
Service B
```

If Service B repeatedly fails:

```text
CLOSED
   |
   | failures
   v
OPEN
   |
   | wait
   v
HALF-OPEN
   |
   | test
   v
CLOSED / OPEN
```

### Purpose

> Stop sending requests to a service that is already failing.

---

# 27. Bulkhead Pattern

Isolate resources so one failure does not consume everything.

```text
Application
 |
 +---- Payment Thread Pool
 |
 +---- Search Thread Pool
 |
 +---- Notification Thread Pool
```

If Search becomes overloaded:

```text
Search Pool -> Exhausted

Payment Pool -> Still Available
```

This prevents one dependency from taking down the entire application.

---

# 28. Rate Limiting

Protect the system from excessive traffic.

```text
Client
   |
   v
Rate Limiter
   |
   +---- Within limit -> Allow
   |
   +---- Exceeded -> Reject/Throttle
```

Example:

```text
100 requests/minute/user
```

---

# 29. Graceful Degradation

If a non-critical component fails, keep the core functionality working.

Example:

```text
E-commerce

Order       -> Critical
Payment     -> Critical
Search      -> Important
Recommendation -> Optional
```

If recommendation service fails:

```text
Recommendation -> DOWN

User can still:
- Browse
- Add to cart
- Purchase
```

This is graceful degradation.

---

# 30. Health Checks

Two important concepts:

### Liveness

> Is the application process alive?

```text
GET /health/live
```

### Readiness

> Can this instance safely receive traffic?

```text
GET /health/ready
```

Example:

```text
App process -> Alive
Database -> DOWN

Liveness  -> PASS
Readiness -> FAIL
```

The load balancer should stop sending normal traffic to that instance.

---

# 31. Disaster Recovery

HA handles many component failures.

**Disaster Recovery (DR)** handles large-scale failures.

Examples:

```text
Region failure
Data center failure
Major database corruption
Large infrastructure failure
Security incident
```

---

# 32. RTO — Recovery Time Objective

**RTO = How quickly do we need to recover?**

Example:

```text
RTO = 30 minutes
```

The system should be restored within approximately 30 minutes.

---

# 33. RPO — Recovery Point Objective

**RPO = How much data loss is acceptable?**

Example:

```text
RPO = 5 minutes
```

The disaster recovery design should aim to limit recoverable data loss to about 5 minutes.

---

# 34. HA vs DR

| HA | DR |
|---|---|
| Handles component failures | Handles major disasters |
| Usually automatic | May involve recovery procedures |
| Multiple instances | Backups/replication/secondary region |
| Multi-AZ | Multi-region commonly used |
| Focus: availability | Focus: recovery |

### Easy Memory

```text
Server crashes
→ HA

Entire region crashes
→ DR
```

---

# 35. Interview Scenario 1 — "One Application Server Goes Down"

### Question

> What happens if one application server suddenly crashes?

### Answer

```text
Load Balancer
   |
   +---- App1 -> DOWN
   |
   +---- App2 -> HEALTHY
   |
   +---- App3 -> HEALTHY
```

The load balancer detects the failed health check and removes App1 from the pool.

Traffic goes to App2 and App3.

### Important Points

```text
+ Multiple instances
+ Health checks
+ Load balancer
+ Stateless application
+ Autoscaling/replacement
```

---

# 36. Interview Scenario 2 — "Database Primary Goes Down"

### Question

> What happens if your primary database fails?

### Answer

```text
Primary DB
    X
    |
    v
Replica
    |
    v
Promote Replica
    |
    v
New Primary
```

Need:

```text
+ Database replication
+ Health monitoring
+ Automatic/manual failover
+ Connection retry/reconnect
+ Replication monitoring
+ Backup
```

Also discuss:

```text
Synchronous vs asynchronous replication
```

because it determines consistency, latency, and possible data loss.

---

# 37. Interview Scenario 3 — "Entire Availability Zone Goes Down"

### Question

> How would you handle an AZ failure?

### Answer

Deploy application instances across multiple AZs.

```text
              Load Balancer
              /           \
             v             v
            AZ1           AZ2
          App1 App2      App3 App4
```

If AZ1 fails:

```text
AZ1 -> DOWN

AZ2 -> Continue Serving
```

Important:

> Do not place all replicas in the same AZ.

---

# 38. Interview Scenario 4 — "Entire Region Goes Down"

### Question

> What happens if an entire AWS region goes down?

### Answer

Use a multi-region architecture.

```text
              Global DNS/LB
                /       \
               v         v
          Region A    Region B
```

Then choose:

```text
Active-Passive
OR
Active-Active
```

depending on:

```text
Availability requirement
RTO
RPO
Consistency
Latency
Cost
```

---

# 39. Interview Scenario 5 — "Traffic Suddenly Increases 10x"

### Question

> How would your HA system handle a sudden traffic spike?

### Answer

Use:

```text
Load Balancer
+
Horizontal Scaling
+
Autoscaling
+
Caching
+
Rate Limiting
+
Queue
+
Load Shedding
```

Example:

```text
                Load Balancer
                     |
          +----------+----------+
          v          v          v
        App1       App2       App3
          |
          v
        Cache
          |
          v
        Queue
          |
          v
      Background Workers
```

Don't allow the database to become the bottleneck.

---

# 40. Interview Scenario 6 — "Payment Service Is Down"

### Question

> Your payment service is unavailable. Should the entire application go down?

### Answer

No.

Use:

```text
Timeout
Circuit Breaker
Retry
Queue
Graceful Degradation
```

For example:

```text
Order Service
     |
     v
Payment Service
     X
     |
Circuit Breaker
     |
     v
Payment Pending
```

The order can remain:

```text
PAYMENT_PENDING
```

and payment can be retried asynchronously if the business process allows it.

---

# 41. Interview Scenario 7 — "Cache Goes Down"

### Question

> What happens if Redis/cache goes down?

A resilient system should not necessarily go down.

```text
Application
    |
    v
Cache
    X
    |
    v
Fallback → Database
```

But be careful:

If millions of requests suddenly hit the DB, you can get a:

> **Cache Stampede / Thundering Herd**

Mitigations:

```text
Request coalescing
TTL jitter
Cache warming
Rate limiting
Circuit breaker
Load shedding
```

---

# 42. Interview Scenario 8 — "Message Queue Goes Down"

### Question

> What happens if Kafka/RabbitMQ becomes unavailable?

Possible strategy:

```text
Producer
   |
   X
Message Broker
```

Use:

```text
Retries
+
Durable producer/outbox
+
Replication
+
Dead Letter Queue
+
Monitoring
```

For critical events, the **Transactional Outbox Pattern** is often useful.

```text
Application
   |
   +---- DB Transaction
   |       |
   |       +---- Business Data
   |       +---- Outbox Event
   |
   v
Outbox Publisher
   |
   v
Message Broker
```

---

# 43. Interview Scenario 9 — "One Service Is Extremely Slow"

### Question

> What if one downstream service starts taking 30 seconds instead of 100 ms?

Without protection:

```text
Service A
   |
   v
Slow Service B
   |
   v
Threads waiting
   |
   v
Thread Pool Exhausted
   |
   v
Service A DOWN
```

Use:

```text
Timeout
Circuit Breaker
Bulkhead
Limited Retries
Async Processing
```

This prevents cascading failure.

---

# 44. Interview Scenario 10 — "How Do You Avoid Duplicate Processing During Failover?"

This is a very common distributed-systems problem.

Example:

```text
Client
  |
  v
POST /payment
  |
  v
Server processes payment
  |
  X
Response lost
```

Client retries:

```text
POST /payment
```

Potential result:

```text
Payment #1
Payment #2  <-- BAD
```

Use:

```text
Idempotency Key
+
Idempotent API
+
Unique Constraint
+
Durable State
```

Example:

```text
Idempotency-Key: ABC123
```

The server remembers that `ABC123` was already processed.

---

# 45. Interview Scenario 11 — "What If Both Regions Accept Writes?"

This is an **Active-Active data consistency problem**.

```text
Region A
   |
   v
User updates:
balance = 100

Region B
   |
   v
User updates:
balance = 200
```

Replication may produce conflicting writes.

Possible approaches:

```text
Single-writer per entity
Conflict resolution
Version numbers
Logical timestamps
Quorum
Consensus
Application-level reconciliation
```

The correct solution depends heavily on the business domain.

For financial data, blindly using last-write-wins may be unsafe.

---

# 46. Interview Scenario 12 — "How Do You Deploy Without Downtime?"

Use:

```text
Rolling Deployment
Blue-Green Deployment
Canary Deployment
```

### Blue-Green

```text
              Load Balancer
                 |
        +--------+--------+
        |                 |
      BLUE              GREEN
    Version 1          Version 2
```

Test Green.

Then gradually/safely move traffic:

```text
BLUE  -> old
GREEN -> new
```

If Green fails:

```text
Traffic -> BLUE
```

---

# 47. High Availability Reference Architecture

```text
                         USERS
                           |
                           v
                    Global DNS / LB
                           |
              +------------+------------+
              |                         |
              v                         v
          REGION A                  REGION B
              |                         |
        +-----+-----+             +-----+-----+
        |           |             |           |
       AZ1         AZ2           AZ1         AZ2
        |           |             |           |
      App1        App2          App3        App4
        |           |             |           |
        +-----+-----+             +-----+-----+
              |                         |
              +-----------+-------------+
                          |
                     Cache Cluster
                          |
                          v
                    Database Cluster
                     /            \
                    v              v
                 Primary        Replica
                          |
                          v
                     Message Queue
                          |
                          v
                    Worker Cluster
```

Cross-cutting components:

```text
Monitoring
Logging
Tracing
Rate Limiting
Circuit Breaker
Authentication
Alerting
Backup
Disaster Recovery
```

---

# 48. How to Answer an HA HLD Interview Question

Use this sequence:

```text
1. Clarify Requirements
        ↓
2. Define Availability Target
        ↓
3. Identify SPOFs
        ↓
4. Add Redundancy
        ↓
5. Load Balancer
        ↓
6. Health Checks
        ↓
7. Stateless Application
        ↓
8. Database Replication
        ↓
9. Multi-AZ
        ↓
10. Multi-Region if required
        ↓
11. Failover Strategy
        ↓
12. Resilience Patterns
        ↓
13. Monitoring
        ↓
14. RTO / RPO
        ↓
15. Discuss Trade-offs
```

---

# 49. Questions Interviewer May Ask

## Basic

### Q1. What is High Availability?

**Answer:**  
High Availability means keeping a system available despite failures using redundancy, health checks, and failover.

### Q2. What is resilience?

**Answer:**  
Resilience is the ability to tolerate failures, recover from them, and continue operating.

### Q3. What is SPOF?

**Answer:**  
A Single Point of Failure is a component whose failure can bring down the entire system.

### Q4. What is Active-Passive?

**Answer:**  
One instance handles traffic while another stays ready as a standby and takes over after failure.

### Q5. What is Active-Active?

**Answer:**  
Multiple instances actively serve traffic simultaneously. If one fails, traffic is distributed to the remaining instances.

---

# 50. Intermediate Interview Questions

### Q6. Active-active vs active-passive?

Discuss:

```text
Availability
Cost
Complexity
Resource utilization
Consistency
Failover
Scalability
```

### Q7. How do you make an application highly available?

Answer:

```text
Multiple instances
+
Load Balancer
+
Health Checks
+
Stateless Design
+
Multi-AZ
+
Database Replication
+
Failover
+
Monitoring
```

### Q8. How do you handle database failure?

Answer:

```text
Replication
+
Health Checks
+
Automatic Failover
+
Replica Promotion
+
Backups
```

### Q9. How do you handle region failure?

Answer:

```text
Multi-Region
+
Global Traffic Routing
+
Data Replication
+
Active-Active OR Active-Passive
+
DR Plan
```

### Q10. How do you prevent cascading failures?

Answer:

```text
Timeout
+
Circuit Breaker
+
Bulkhead
+
Rate Limiting
+
Load Shedding
```

---

# 51. Advanced Interview Questions

### Q11. Why is active-active harder than active-passive?

Because multiple systems can process operations simultaneously, creating:

```text
Data conflicts
Consistency issues
Replication problems
Network partition problems
Duplicate processing
Conflict resolution requirements
```

---

### Q12. What happens if the load balancer itself fails?

The load balancer becomes a SPOF.

Solution:

```text
             DNS / Global LB
               /        \
              v          v
             LB1        LB2
```

Use redundant load balancers or a managed highly available load-balancing service.

---

### Q13. What happens if Redis fails?

Possible design:

```text
Application
    |
    v
Redis Cluster
   / \
  v   v
Node Node
```

If caching is non-critical:

```text
Cache failure
    |
    v
Fallback to DB
```

But protect DB from a cache stampede.

---

### Q14. Does replication automatically guarantee HA?

**No.**

Replication alone is not enough.

You also need:

```text
Failure Detection
+
Failover
+
Client Reconnection
+
Health Checks
+
Capacity
+
Monitoring
+
Tested Recovery
```

---

### Q15. Does HA mean zero downtime?

**No.**

HA means minimizing downtime and designing for continued service during failures.

There may still be:

```text
Failover delay
Network issues
Deployment failures
Large-scale disasters
```

---

# 52. Availability vs Scalability

Do not confuse them.

### Scalability

> Can the system handle increasing workload?

```text
1 server
   ↓
10 servers
   ↓
100 servers
```

### Availability

> Does the system remain available when components fail?

```text
Server 1 -> DOWN
Server 2 -> Continue
```

A system can be:

```text
Highly scalable but not highly available
```

or:

```text
Highly available but poorly scalable
```

Good systems address both.

---

# 53. Availability vs Reliability

### Availability

```text
System is accessible when requested.
```

### Reliability

```text
System performs correctly over time.
```

Example:

A system that is always online but frequently returns incorrect results:

```text
High availability
Low reliability
```

---

# 54. Important HA Metrics

## Availability

```text
Availability =
Uptime / Total Time
```

Common targets:

```text
99%
99.9%
99.99%
99.999%
```

More `9`s means less allowed downtime.

---

## MTBF

**Mean Time Between Failures**

> Average time between failures.

Higher is generally better.

---

## MTTR

**Mean Time To Recovery/Repair**

> Average time required to recover from a failure.

Lower is generally better.

---

# 55. HA Interview Trade-offs

Always mention trade-offs.

```text
Higher Availability
        |
        +---- More infrastructure
        +---- Higher cost
        +---- More complexity
        +---- More replication
        +---- More monitoring
        +---- Possible consistency trade-offs
```

The interviewer wants to know:

> **Why did you choose this architecture?**

not just:

> "I will use active-active."

---

# 56. ⭐ Final Interview Answer

If the interviewer asks:

> **"Design a highly available and resilient system."**

You can answer:

> "First, I would identify all potential single points of failure. I would deploy multiple stateless application instances behind a highly available load balancer and spread them across multiple availability zones. I would add health checks so failed instances are automatically removed from traffic. For the database, I would use replication and an appropriate failover strategy. For critical workloads, I would consider multi-region deployment with either active-passive or active-active architecture depending on consistency, RTO, RPO, latency, and cost requirements. At the service-to-service level, I would use timeouts, retries with exponential backoff and jitter, circuit breakers, bulkheads, and rate limiting to prevent cascading failures. Finally, I would add monitoring, logging, tracing, automated recovery, backups, and a tested disaster-recovery plan."

---

# 57. ⭐ Quick Recall Cheat Sheet

```text
HIGH AVAILABILITY
=================

HA
→ System stays available during failures.

RESILIENCE
→ System tolerates + recovers from failures.

SPOF
→ One failure can bring down system.
→ Remove using redundancy.

ACTIVE-PASSIVE
→ One active
→ One standby
→ Failure → standby becomes active
→ Simple
→ Lower utilization

ACTIVE-ACTIVE
→ Multiple active
→ All serve traffic
→ Failure → redistribute traffic
→ Better utilization
→ More complexity

APP HA
→ Stateless servers
→ Load Balancer
→ Health Checks
→ Multiple AZs

DATABASE HA
→ Primary + Replicas
→ Replication
→ Failover
→ Backup
→ Monitor replication lag

MULTI-AZ
→ Protect against AZ failure

MULTI-REGION
→ Protect against region failure

RESILIENCE
→ Timeout
→ Retry + Backoff + Jitter
→ Circuit Breaker
→ Bulkhead
→ Rate Limiting
→ Backpressure
→ Load Shedding
→ Graceful Degradation

DR
→ RTO = How fast can we recover?
→ RPO = How much data loss is acceptable?

FAILURE SCENARIOS
→ Server down
→ DB down
→ Cache down
→ Queue down
→ AZ down
→ Region down
→ Traffic spike
→ Slow dependency
→ Duplicate request
→ Deployment failure

INTERVIEW FLOW
→ Requirements
→ Availability target
→ Find SPOFs
→ Redundancy
→ Load Balancer
→ Health Checks
→ Stateless Apps
→ DB Replication
→ Multi-AZ
→ Multi-Region
→ Failover
→ Resilience Patterns
→ Monitoring
→ RTO/RPO
→ Trade-offs
```

## ⭐ One-Line Memory

> **HA keeps the system running, resilience helps it survive failures, Active-Passive keeps a backup, and Active-Active keeps multiple systems serving traffic.**