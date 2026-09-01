# MICROSERVICES DESIGN PATTERNS — SYSTEM DESIGN / HLD INTERVIEW NOTES

---

# 1. What is Microservices Architecture?

**Microservices architecture** is an architecture where an application is divided into small, independently deployable services.

Each service:

- Owns a specific business capability
- Usually owns its own database/data
- Can be developed independently
- Can be deployed independently
- Can be scaled independently

### Example — E-commerce

Instead of one large application:

```text
E-Commerce Monolith
       |
       ├── User
       ├── Order
       ├── Payment
       ├── Inventory
       └── Notification
```

Use microservices:

```text
                    API Gateway
                        |
        ┌───────────────┼────────────────┐
        ↓               ↓                ↓
   User Service    Order Service    Payment Service
        |               |                |
      User DB         Order DB        Payment DB
                        |
                        ↓
                 Inventory Service
                        |
                   Inventory DB
```

---

# 2. Why Microservices?

## Advantages

### 1. Independent Deployment

Payment service can be deployed without deploying Order Service.

### 2. Independent Scaling

If Payment Service receives heavy traffic:

```text
Payment Service
Instance 1
Instance 2
Instance 3
Instance 4
```

while User Service may need only two instances.

### 3. Fault Isolation

A failure in Notification Service should not necessarily bring down Order Service.

### 4. Technology Flexibility

Different services can use different technologies/databases when justified.

### 5. Team Independence

Different teams can own different business capabilities.

---

# 3. Microservices Disadvantages

Microservices are not automatically better than a monolith.

Major disadvantages:

- Network communication
- Distributed transactions
- Eventual consistency
- More deployments
- More infrastructure
- Harder debugging
- Distributed tracing required
- Service discovery
- Monitoring complexity
- Operational overhead

### Interview Point

> Microservices solve organizational and scaling problems, but introduce distributed-system complexity.

---

# 4. Core Microservices Principles

## 1. Single Responsibility

A service should own one cohesive business capability.

Example:

```text
Payment Service
→ Payment-related functionality
```

Avoid:

```text
Payment Service
→ Payment
→ Inventory
→ User
→ Shipping
```

---

## 2. Loose Coupling

Services should depend on well-defined APIs/events rather than internal implementation details.

---

## 3. High Cohesion

Related functionality should stay together.

Example:

```text
Order Service
├── Create Order
├── Cancel Order
├── Get Order
└── Update Order Status
```

---

## 4. Independent Deployability

A service should ideally be deployable without requiring coordinated deployment of unrelated services.

---

## 5. Data Ownership

Each service should own its data.

```text
Order Service → Order DB

Payment Service → Payment DB

Inventory Service → Inventory DB
```

Avoid:

```text
Multiple services
       ↓
Same database tables
```

because it creates tight coupling.

---

# 5. API Gateway Pattern

## Definition

API Gateway provides a common entry point for clients.

```text
                 Mobile/Web
                     |
                     ↓
                API Gateway
              /      |      \
             ↓       ↓       ↓
          User     Order   Payment
        Service   Service  Service
```

The gateway can handle:

- Routing
- Authentication
- Authorization
- Rate limiting
- Request validation
- TLS termination
- Request aggregation
- Protocol translation

---

## Example

Client:

```http
GET /api/orders/123
```

Gateway:

```text
/api/orders/*
       ↓
Order Service
```

---

## Advantages

- Centralized authentication
- Centralized rate limiting
- Simplifies clients
- Hides internal service topology
- Can aggregate multiple service calls

## Disadvantages

- Additional network hop
- Can become bottleneck if poorly designed
- Must be highly available
- Can become too complex if business logic is added

### Recall

> **API Gateway = Single entry point + Routing + Cross-cutting concerns**

---

# 6. Service Discovery Pattern

In dynamic environments, service instances may change frequently.

Example:

```text
Order Service

Instance A → 10.0.0.10
Instance B → 10.0.0.11
Instance C → 10.0.0.12
```

Instead of hardcoding IPs, services use service discovery.

```text
Order Service
      |
      ↓
Service Registry
      |
      ├── Payment-1
      ├── Payment-2
      └── Payment-3
```

Examples of service discovery systems include:

```text
Consul
Eureka
Kubernetes Service/DNS
```

---

## Advantages

- Dynamic discovery
- Supports autoscaling
- Removes hardcoded addresses
- Helps load balancing

## Disadvantages

- Additional infrastructure
- Registry availability matters
- More operational complexity

### Recall

> **Service Discovery = Find healthy service instances dynamically.**

---

# 7. Database Per Service Pattern

Each service owns its database.

```text
User Service
    ↓
User DB

Order Service
    ↓
Order DB

Payment Service
    ↓
Payment DB
```

---

## Why?

If Order Service directly accesses Payment DB:

```text
Order Service
      |
      ↓
Payment DB
```

Order Service becomes coupled to Payment's database schema.

Instead:

```text
Order Service
      |
      ↓
Payment API
      ↓
Payment DB
```

---

## Advantages

- Loose coupling
- Independent schema
- Independent scaling
- Service ownership
- Technology flexibility

## Disadvantages

- Cross-service queries become harder
- Distributed transactions become harder
- Data duplication may be necessary
- Eventual consistency may be required

### Recall

> **Each service owns its data. Other services access it through APIs/events.**

---

# 8. Circuit Breaker Pattern

## Problem

Suppose:

```text
Order Service
     |
     ↓
Payment Service
```

Payment Service becomes slow.

Order Service keeps sending requests.

```text
Order
 ↓
Payment
 ↓
Timeout
 ↓
Retry
 ↓
Timeout
 ↓
Retry
```

Eventually Order Service's threads/connections are exhausted.

This can cause a **cascading failure**.

---

# 9. Circuit Breaker States

Circuit breaker usually has three states:

```text
CLOSED
  ↓
OPEN
  ↓
HALF-OPEN
```

## CLOSED

Requests flow normally.

```text
Request → Payment Service
```

Failures are monitored.

---

## OPEN

If failures cross a threshold:

```text
Circuit OPEN
```

Requests are immediately rejected/fail-fast instead of calling the unhealthy service.

```text
Order
  X
Payment
```

---

## HALF-OPEN

After a recovery period, allow limited test requests.

```text
Test request
     ↓
Payment Service
```

If successful:

```text
HALF-OPEN → CLOSED
```

If unsuccessful:

```text
HALF-OPEN → OPEN
```

---

## Advantages

- Prevents cascading failures
- Fail-fast behavior
- Protects resources

## Disadvantages

- Incorrect thresholds can reject healthy traffic
- Requires tuning
- Doesn't fix the underlying failure

### Recall

> **Circuit Breaker = Stop calling a failing dependency temporarily.**

---

# 10. Retry Pattern

Network failures can be temporary.

Example:

```text
Service A → Service B
             ↓
          Timeout
```

Instead of immediately failing, retry when appropriate.

Use:

```text
Exponential Backoff + Jitter
```

Example:

```text
Attempt 1 → 100 ms
Attempt 2 → 200 ms
Attempt 3 → 400 ms
Attempt 4 → 800 ms
```

Add random jitter to avoid synchronized retries.

---

## Advantages

- Handles transient failures
- Improves reliability

## Disadvantages

Retries can make a failure worse.

Example:

```text
1000 requests
     ↓
1000 retries
     ↓
2000 requests
     ↓
Overloaded service
```

This is called a **retry storm**.

### Important

Retries should generally be used for **transient and retry-safe operations**.

For non-idempotent operations such as charging a payment, use idempotency keys and carefully designed semantics.

### Recall

> **Retry = Recover from temporary failure.**
>
> **Circuit Breaker = Stop repeatedly calling a failing service.**

---

# 11. Bulkhead Pattern

The name comes from ships.

A ship has separate compartments so that one damaged section does not sink the entire ship.

Same concept in software.

---

## Problem

Suppose one application has:

```text
100 threads
```

Payment calls consume all 100 threads.

Now:

```text
User API
Order API
Search API
```

may also stop working.

---

## Solution

Separate resources:

```text
Payment
→ 30 threads

Order
→ 30 threads

Search
→ 20 threads

Other
→ 20 threads
```

Payment failure cannot consume all resources.

---

## Advantages

- Failure isolation
- Prevents resource exhaustion
- Improves resilience

## Disadvantages

- Resource fragmentation
- More configuration
- Poor partitioning can reduce utilization

### Recall

> **Bulkhead = Isolate resources so one failure doesn't take down everything.**

---

# 12. Saga Pattern

## Problem

In microservices, each service may have its own database.

Example:

```text
Order
Payment
Inventory
Shipping
```

One business transaction may involve all four.

A traditional database transaction cannot easily span independent databases.

---

## Saga Solution

Break the transaction into local transactions.

```text
Create Order
     ↓
Charge Payment
     ↓
Reserve Inventory
     ↓
Create Shipment
```

If something fails, execute compensating actions.

Example:

```text
Order Created
      ↓
Payment Successful
      ↓
Inventory Failed
      ↓
Refund Payment
      ↓
Cancel Order
```

---

# 13. Saga — Choreography

Services communicate using events.

```text
Order Service
     |
     | OrderCreated
     ↓
Payment Service
     |
     | PaymentSucceeded
     ↓
Inventory Service
     |
     | InventoryReserved
     ↓
Shipping Service
```

No central coordinator.

---

## Advantages

- Loosely coupled
- Event-driven
- No central orchestrator

## Disadvantages

- Hard to understand complex workflows
- Debugging is harder
- Event chains can become complicated

### Recall

> **Choreography = Services coordinate through events.**

---

# 14. Saga — Orchestration

A central orchestrator controls the workflow.

```text
              Saga Orchestrator
               /      |      \
              ↓       ↓       ↓
          Payment  Inventory Shipping
```

Example:

```text
Orchestrator
     ↓
Charge Payment
     ↓
Reserve Inventory
     ↓
Create Shipment
```

If Inventory fails:

```text
Orchestrator
     ↓
Refund Payment
     ↓
Cancel Order
```

---

## Advantages

- Centralized workflow
- Easier to understand
- Easier to monitor
- Good for complex workflows

## Disadvantages

- Orchestrator adds complexity
- Can become a bottleneck if poorly designed
- More centralized coordination

### Recall

```text
Choreography
→ Events coordinate services

Orchestration
→ Central coordinator controls workflow
```

---

# 15. Event-Driven Architecture

Instead of synchronous calls:

```text
Order → Payment → Inventory
```

services can publish events.

```text
Order Service
     |
     ↓
Kafka/Event Bus
     |
     ├── Payment Service
     ├── Analytics
     └── Notification
```

Example:

```text
OrderCreated
```

Multiple services can consume the event.

---

## Advantages

- Loose coupling
- Asynchronous processing
- High throughput
- Easy to add new consumers

## Disadvantages

- Eventual consistency
- Debugging is harder
- Duplicate events/messages must be handled
- Event ordering may matter
- Schema evolution is important

### Recall

> **Event-driven = Publish what happened; consumers react independently.**

---

# 16. Synchronous vs Asynchronous Communication

## Synchronous

```text
Service A
   |
   | HTTP/gRPC
   ↓
Service B
   |
   ↓
Response
```

Service A waits.

### Advantages

- Simple request/response
- Immediate result
- Easy to understand

### Disadvantages

- Tight runtime dependency
- Higher latency
- Failure propagation

---

## Asynchronous

```text
Service A
   |
   ↓
Message Broker
   |
   ↓
Service B
```

Service A does not need to wait for B to finish processing.

### Advantages

- Loose coupling
- Better resilience
- Better throughput
- Handles traffic spikes

### Disadvantages

- Eventual consistency
- More complex debugging
- Message duplication/order issues

### Recall

```text
Sync
→ Need immediate answer

Async
→ Can process later
```

---

# 17. CQRS

**CQRS = Command Query Responsibility Segregation**

Separate:

```text
Write Model
```

from:

```text
Read Model
```

---

## Traditional

```text
Application
    |
    ↓
One Database
    ↑
Read + Write
```

---

## CQRS

```text
             Application
              /       \
             ↓         ↓
          Command     Query
             ↓         ↓
        Write DB     Read DB
```

Read model can be optimized for queries.

---

## Example

E-commerce:

```text
Order Write DB
      ↓
Events
      ↓
Order Read Model
```

Read model could be optimized for:

```text
Customer Order History
```

---

## Advantages

- Optimize reads independently
- Optimize writes independently
- Useful for complex domains
- Can scale read/write workloads separately

## Disadvantages

- More complexity
- Eventual consistency
- Data synchronization required

### Recall

> **CQRS = Separate reads from writes.**

---

# 18. Event Sourcing

Traditional system stores current state:

```text
Account Balance = $500
```

Event sourcing stores the events that produced the state:

```text
AccountCreated
Deposited $1000
Withdrawn $300
Deposited $200
Withdrawn $400
```

Current balance:

```text
1000 - 300 + 200 - 400 = $500
```

---

## Advantages

- Complete history
- Excellent auditability
- Can rebuild state
- Useful for event-driven systems

## Disadvantages

- More storage
- Event schema evolution
- Replay complexity
- More difficult querying

### Recall

> **Event Sourcing = Events are the source of truth.**

---

# 19. CQRS vs Event Sourcing

They are different concepts.

### CQRS

```text
Separate read and write models
```

### Event Sourcing

```text
Store events as source of truth
```

They can be used together, but neither requires the other.

```text
Command
  ↓
Event Store
  ↓
Events
  ↓
Read Model
```

### Recall

> **CQRS = How you separate reads/writes.**
>
> **Event Sourcing = How you store state/history.**

---

# 20. Strangler Fig Pattern

Used to migrate a monolith to microservices gradually.

Instead of:

```text
MONOLITH
```

being replaced all at once:

```text
Old Monolith
     ↓
Gradually extract functionality
```

Example:

### Step 1

```text
Client
  ↓
Monolith
```

### Step 2

Extract Payment:

```text
Client
  ↓
Gateway
  ├── Payment → Payment Service
  └── Other   → Monolith
```

### Step 3

Extract Order:

```text
Gateway
 ├── Payment → Microservice
 ├── Order   → Microservice
 └── Other   → Monolith
```

Eventually:

```text
Monolith
   ↓
Removed
```

---

## Advantages

- Low migration risk
- Incremental migration
- Allows continuous delivery

## Disadvantages

- Temporary hybrid architecture
- Data synchronization complexity
- Routing complexity

### Recall

> **Strangler Fig = Gradually replace a monolith with services.**

---

# 21. Sidecar Pattern

A sidecar is a helper process/container deployed alongside an application.

```text
Pod
┌────────────────────────┐
│ Application            │
│                        │
│ Sidecar                │
└────────────────────────┘
```

The sidecar can handle:

- Logging
- Proxying
- Metrics
- Security
- Configuration-related functionality

---

## Example

```text
Order Service
     |
     ↓
Sidecar Proxy
     |
     ↓
Payment Service
```

The application does not need to implement all networking concerns itself.

---

## Advantages

- Separates cross-cutting concerns
- Can standardize networking/security
- Reduces duplicate infrastructure code

## Disadvantages

- Extra resource usage
- More operational complexity
- More components to debug

### Recall

> **Sidecar = Helper deployed next to the service.**

---

# 22. Service Mesh

A service mesh manages service-to-service communication.

Example:

```text
Service A
   |
Sidecar
   |
   ↓
Sidecar
   |
Service B
```

It can provide:

- Service-to-service security
- Traffic management
- Retries
- Timeouts
- Observability
- Load balancing
- mTLS

Examples:

```text
Istio
Linkerd
```

---

## Advantages

- Centralized traffic policies
- Better observability
- mTLS support
- Advanced routing

## Disadvantages

- Significant operational complexity
- Resource overhead
- Learning curve

### Recall

> **Service Mesh = Infrastructure layer for managing service-to-service communication.**

---

# 23. Adapter Pattern

Adapter converts one interface into another expected interface.

Example:

```text
Our Application
      ↓
Adapter
      ↓
Legacy Payment API
```

Suppose our application expects:

```text
pay(amount)
```

but legacy system provides:

```text
processPayment(amount, currency, customerId)
```

The adapter translates between them.

---

## Advantages

- Isolates legacy/external systems
- Reduces changes to business code

## Disadvantages

- Additional layer
- Added latency
- Another component to maintain

---

# 24. Ambassador Pattern

An Ambassador acts as a proxy between the application and external service.

```text
Application
    |
    ↓
Ambassador
    |
    ↓
External Service
```

It can handle:

- Connection management
- Authentication
- Retries
- Monitoring
- Protocol conversion

### Recall

```text
Adapter
→ Converts interfaces

Ambassador
→ Proxy/helper for external communication
```

---

# 25. API Composition / Aggregator Pattern

Sometimes one client request requires multiple services.

Example:

```text
GET /customer-dashboard
```

Data required:

```text
User Service
Order Service
Recommendation Service
```

Instead of the mobile client calling all three:

```text
Mobile
 ├── User
 ├── Order
 └── Recommendation
```

use an aggregator:

```text
Mobile
   ↓
API Gateway / Aggregator
   ├── User
   ├── Order
   └── Recommendation
```

Then return one combined response.

---

## Advantages

- Simplifies clients
- Reduces client-side orchestration
- Centralizes aggregation

## Disadvantages

- Additional service/network hop
- Aggregator can become complex
- Parallel calls may still be limited by slowest dependency

---

# 26. Backend for Frontend — BFF

Different clients may have different requirements.

```text
Mobile
   ↓
Mobile BFF

Web
   ↓
Web BFF
```

Each BFF communicates with backend microservices.

Example:

```text
              Microservices
             /      |      \
            /       |       \
Mobile → Mobile BFF |       \
Web    → Web BFF    |        \
```

---

## Advantages

- Client-specific APIs
- Reduces over-fetching/under-fetching
- Allows independent client optimization

## Disadvantages

- More services
- Duplicate logic risk
- More deployment/maintenance

### Recall

> **BFF = Backend customized for a specific frontend/client.**

---

# 27. Rate Limiting

Rate limiting controls how many requests a client can make.

Example:

```text
User
 ↓
API Gateway
 ↓
100 requests/minute
```

If exceeded:

```text
HTTP 429 Too Many Requests
```

Common algorithms:

```text
Token Bucket
Leaky Bucket
Fixed Window
Sliding Window
```

---

## Why?

- Prevent abuse
- Protect services
- Fair resource usage
- Prevent overload

---

# 28. Load Balancing

Multiple instances:

```text
             Load Balancer
              /    |    \
             ↓     ↓     ↓
          App-1  App-2  App-3
```

Load balancing strategies include:

```text
Round Robin
Least Connections
Weighted Routing
Consistent Hashing
```

### Goal

Distribute traffic and avoid overloading one instance.

---

# 29. Configuration Management

Microservices require configuration such as:

```text
Database URL
Timeout
Feature Flag
API Endpoint
Environment settings
```

Avoid hardcoding.

Use:

```text
Configuration Service
Environment variables
Secret manager
```

---

## Important

Separate:

```text
Configuration
```

from:

```text
Secrets
```

Passwords/API keys should be stored using appropriate secret-management systems.

---

# 30. Centralized Logging

In microservices:

```text
Service A → Logs
Service B → Logs
Service C → Logs
```

Centralize them:

```text
Services
   ↓
Log Collector
   ↓
Central Log System
```

Use structured logs.

Example:

```json
{
  "traceId": "abc123",
  "service": "order-service",
  "orderId": "123",
  "status": "FAILED"
}
```

---

# 31. Distributed Tracing

One request can travel through multiple services.

```text
Client
 ↓
Gateway
 ↓
Order Service
 ↓
Payment Service
 ↓
Inventory Service
```

Use:

```text
Trace ID
Span ID
```

Example:

```text
Trace ID: ABC123

Gateway     → 20ms
Order       → 50ms
Payment     → 400ms
Inventory   → 30ms
```

Now we can identify:

> Payment Service is causing most of the latency.

---

# 32. Health Checks

Services should expose health information.

### Liveness

> Is the process alive?

### Readiness

> Is the service ready to receive traffic?

Example:

```text
Load Balancer
      |
      ↓
Readiness Check
      |
      ↓
Healthy instances only
```

---

# 33. Graceful Shutdown

During deployment:

```text
Old Instance
```

should not immediately terminate active requests.

Better:

```text
Remove from load balancer
        ↓
Stop accepting new requests
        ↓
Finish active requests
        ↓
Shutdown
```

This reduces failed requests during deployments.

---

# 34. Deployment Patterns

## Blue-Green Deployment

Two environments:

```text
Blue → Current
Green → New
```

Traffic initially:

```text
Users → Blue
```

After validation:

```text
Users → Green
```

### Advantage

Fast rollback.

### Disadvantage

Requires additional infrastructure.

---

# 35. Canary Deployment

Release to a small percentage first.

```text
Users
 |
 ├── 95% → Old version
 |
 └── 5%  → New version
```

If healthy:

```text
5%
 ↓
20%
 ↓
50%
 ↓
100%
```

### Advantage

Reduces deployment risk.

### Disadvantage

Requires traffic control and strong monitoring.

### Recall

```text
Blue-Green
→ Switch environments

Canary
→ Gradually increase traffic
```

---

# 36. Resilience Pattern Combination

In real systems, patterns are combined.

Example:

```text
Client
  ↓
API Gateway
  ↓
Load Balancer
  ↓
Order Service
  |
  | Timeout
  | Retry + Backoff
  | Circuit Breaker
  ↓
Payment Service
```

Resource isolation:

```text
Bulkhead
```

Async:

```text
Kafka
```

Observability:

```text
Logs + Metrics + Traces
```

---

# 37. Complete Microservices HLD Example

## E-Commerce System

```text
                         Clients
                            |
                            ↓
                       API Gateway
                            |
             ┌──────────────┼──────────────┐
             ↓              ↓              ↓
        User Service   Order Service   Product Service
             |              |              |
          User DB        Order DB       Product DB
                            |
                            ↓
                     Payment Service
                            |
                        Payment DB
                            |
                            ↓
                   Inventory Service
                            |
                       Inventory DB

                     Event Bus/Kafka
                         /    |    \
                        ↓     ↓     ↓
                  Notification Analytics Audit
```

Communication:

```text
Client → Gateway
HTTPS

Gateway → Services
HTTP/gRPC

Order → Payment
gRPC/HTTP when immediate response is required

Order → Event Bus
Async events

Services → Their DB
Database protocol
```

---

# 38. Order Processing Example

User creates an order:

```text
1. Client
     ↓
2. API Gateway
     ↓
3. Order Service
     ↓
4. Create Order
     ↓
5. Payment
     ↓
6. Inventory
     ↓
7. Shipping
     ↓
8. Order Completed
```

If Inventory fails:

```text
Payment Successful
        ↓
Inventory Failed
        ↓
Refund Payment
        ↓
Cancel Order
```

This is a **Saga**.

---

# 39. Failure Scenario

Suppose Payment Service is down.

Without resilience:

```text
Order Service
     ↓
Payment
     ↓
Timeout
     ↓
Retry
     ↓
Timeout
     ↓
Threads exhausted
```

With resilience:

```text
Order Service
     |
     ├── Timeout
     |
     ├── Limited Retry
     |
     ├── Circuit Breaker
     |
     └── Fallback / Async processing
```

Bulkhead prevents Payment calls from consuming all application resources.

---

# 40. Synchronous vs Asynchronous — Interview Decision

Use **synchronous** when:

```text
User needs immediate result
```

Example:

```text
Get Product Details
Check Account Balance
Authenticate User
```

Use **asynchronous** when:

```text
Processing can happen later
```

Example:

```text
Send Email
Generate Report
Analytics
Notifications
Order Events
```

---

# 41. When NOT to Use Microservices

Microservices may be a poor choice when:

- Application is small
- Team is very small
- Domain boundaries are unclear
- Deployment infrastructure is immature
- Distributed complexity provides little benefit

A modular monolith can be a better starting point.

### Interview Answer

> I would not introduce microservices just because they are popular. I would first identify scaling, team ownership, deployment, and domain-boundary requirements.

---

# 42. Common Interview Questions

## Q1. Why database per service?

> To maintain service ownership and reduce coupling between services. Each service controls its schema and persistence model.

---

## Q2. How do microservices communicate?

> They can communicate synchronously using HTTP/gRPC or asynchronously using message brokers and event streams such as Kafka.

---

## Q3. How do you handle distributed transactions?

> Prefer a Saga with local transactions and compensating actions when business semantics allow. Avoid distributed 2PC unless strong atomicity is truly required and the infrastructure supports it appropriately.

---

## Q4. What is a circuit breaker?

> It temporarily stops calls to a failing dependency so the failure does not cascade to other services.

---

## Q5. What is bulkhead?

> It isolates resources such as thread pools or connection pools so one overloaded dependency cannot consume all resources.

---

## Q6. Retry vs Circuit Breaker?

```text
Retry
→ Temporary failure
→ Try again

Circuit Breaker
→ Repeated dependency failure
→ Stop calling temporarily
```

They are often used together.

---

## Q7. What is Saga?

> Saga breaks a distributed business transaction into local transactions and uses compensating actions when later steps fail.

---

## Q8. Choreography vs Orchestration?

```text
Choreography
→ Events
→ No central coordinator

Orchestration
→ Central coordinator
→ Explicit workflow
```

---

## Q9. What is CQRS?

> CQRS separates command/write models from query/read models so each can be optimized independently.

---

## Q10. What is Event Sourcing?

> Event Sourcing stores immutable domain events as the source of truth and derives current state from them.

---

## Q11. What is Strangler Fig?

> It is an incremental migration strategy where functionality is gradually moved from a monolith to microservices until the old system can be removed.

---

## Q12. What is API Gateway?

> A single client-facing entry point that handles routing and cross-cutting concerns such as authentication and rate limiting.

---

## Q13. How do you prevent cascading failures?

Use:

```text
Timeout
+
Retry with Backoff
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

## Q14. How do you debug microservices?

Use:

```text
Centralized Logs
+
Metrics
+
Distributed Tracing
+
Correlation/Trace IDs
```

---

## Q15. How do you scale microservices?

Prefer stateless services and horizontal scaling:

```text
Load Balancer
      |
 ┌────┼────┐
 ↓    ↓    ↓
App1 App2 App3
```

Use autoscaling based on appropriate metrics.

---

# 43. Important Pattern Differences

## Circuit Breaker vs Retry

```text
Retry
→ Try again

Circuit Breaker
→ Stop calling failing service
```

---

## Bulkhead vs Circuit Breaker

```text
Bulkhead
→ Isolate resources

Circuit Breaker
→ Stop requests to unhealthy dependency
```

---

## Saga vs 2PC

```text
Saga
→ Local transactions
→ Compensation
→ Eventual consistency
→ More available/non-blocking approach

2PC
→ Distributed transaction coordinator
→ Stronger atomic commit semantics
→ Blocking/coordination overhead
```

---

## CQRS vs Event Sourcing

```text
CQRS
→ Separate read/write models

Event Sourcing
→ Events are source of truth
```

---

## API Gateway vs Load Balancer

```text
API Gateway
→ Application/API-level routing and policies

Load Balancer
→ Distributes traffic across instances
```

---

## Service Discovery vs Load Balancer

```text
Service Discovery
→ Find service instances

Load Balancer
→ Choose an instance to receive traffic
```

---

## Sidecar vs Service Mesh

```text
Sidecar
→ Helper component beside a service

Service Mesh
→ System-wide service-to-service communication layer
→ Often implemented using proxies/sidecars
```

---

# 44. Microservices HLD Interview Flow

When asked:

> "Design a microservices architecture."

Follow this order:

```text
1. Clarify Requirements
        ↓
2. Identify Business Domains
        ↓
3. Define Services
        ↓
4. Define APIs
        ↓
5. Define Data Ownership
        ↓
6. Choose Sync vs Async
        ↓
7. Add API Gateway
        ↓
8. Add Service Discovery
        ↓
9. Add Load Balancing
        ↓
10. Add Caching
        ↓
11. Add Message Broker
        ↓
12. Handle Distributed Transactions
        ↓
13. Add Resilience
        ↓
14. Add Security
        ↓
15. Add Observability
        ↓
16. Discuss Scaling
        ↓
17. Discuss Failure Scenarios
        ↓
18. Explain Tradeoffs
```

---

# 45. Microservices Design Checklist

Before finishing an interview design, check:

### Architecture

```text
[ ] API Gateway
[ ] Services
[ ] Load Balancer
[ ] Service Discovery
```

### Data

```text
[ ] Database per service
[ ] Data ownership
[ ] Consistency model
[ ] Distributed transaction strategy
```

### Communication

```text
[ ] REST/HTTP
[ ] gRPC
[ ] Message Queue/Event Bus
[ ] Sync vs Async
```

### Resilience

```text
[ ] Timeout
[ ] Retry
[ ] Circuit Breaker
[ ] Bulkhead
[ ] Rate Limiting
```

### Operations

```text
[ ] Logging
[ ] Metrics
[ ] Distributed tracing
[ ] Health checks
[ ] Alerting
```

### Deployment

```text
[ ] Horizontal scaling
[ ] Autoscaling
[ ] Canary/Blue-Green
[ ] Graceful shutdown
```

### Security

```text
[ ] Authentication
[ ] Authorization
[ ] TLS/mTLS where appropriate
[ ] Secrets management
[ ] Least privilege
```

---

# 46. QUICK RECALL — MOST IMPORTANT PATTERNS

```text
API Gateway
→ Single entry point

Service Discovery
→ Find service instances

Database per Service
→ Service owns its data

Circuit Breaker
→ Stop calling failing dependency

Retry
→ Recover from transient failure

Bulkhead
→ Isolate resources

Saga
→ Distributed transaction using compensation

Choreography
→ Events coordinate workflow

Orchestration
→ Coordinator controls workflow

CQRS
→ Separate reads and writes

Event Sourcing
→ Events are source of truth

Strangler Fig
→ Gradually replace monolith

Sidecar
→ Helper next to service

Service Mesh
→ Manage service-to-service communication

BFF
→ Backend customized for frontend

Adapter
→ Convert one interface to another

API Aggregator
→ Combine multiple service responses

Rate Limiter
→ Control request rate

Load Balancer
→ Distribute traffic
```

---

# 47. ⭐ 30-SECOND INTERVIEW RECALL

If the interviewer asks:

> "How would you make a microservices system reliable and scalable?"

Answer:

```text
I would start with clear service boundaries and database
ownership.

For client access, I would use an API Gateway with
authentication, rate limiting and routing.

For service communication, I would use HTTP/gRPC for
synchronous operations and Kafka/message queues for
asynchronous workflows.

Each service would own its database.

For distributed transactions, I would use Saga with
compensating actions where appropriate.

For resilience, I would use timeouts, limited retries with
exponential backoff and jitter, circuit breakers and
bulkheads.

For scalability, I would keep services stateless where
possible and horizontally scale them behind load balancers.

Finally, I would add centralized logging, metrics,
distributed tracing, health checks and safe deployment
strategies such as canary releases.
```

---

# ⭐ FINAL MEMORY MAP

```text
                 MICROSERVICES
                      |
       ┌──────────────┼───────────────┐
       ↓              ↓               ↓
   API Gateway     Services        Service Discovery
       |              |
       |              ↓
       |         DB per Service
       |              |
       ↓              ↓
   Security      Sync / Async
                      |
                ┌─────┴─────┐
                ↓           ↓
               gRPC       Kafka
                |
                ↓
          Resilience Layer
                |
       ┌────────┼────────┐
       ↓        ↓        ↓
    Timeout   Retry   Circuit Breaker
                         |
                     Bulkhead
                         |
                         ↓
                  Distributed Tx
                         |
                       Saga
                         |
                 ┌───────┴───────┐
                 ↓               ↓
          Choreography      Orchestration
                 |
                 ↓
            Observability
                 |
       ┌─────────┼─────────┐
       ↓         ↓         ↓
     Logs      Metrics    Tracing
```

# ⭐ ONE-LINE TAKEAWAY

> **Microservices = independently deployable business services + independent data ownership + appropriate synchronous/asynchronous communication + resilience + observability + independent scaling.**