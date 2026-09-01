# SAGA Design Pattern — System Design Interview Notes

## 1. Definition

**Saga Pattern** is a way to manage a **distributed transaction across multiple microservices**, where each service has its own database.

Instead of using one large distributed transaction such as **2-Phase Commit (2PC)**, we break the transaction into multiple **local transactions**.

If one step fails, we execute **compensating transactions** to undo the successful previous steps.

### Simple Definition

> **Saga = Sequence of local transactions + Compensation when something fails**

---

# 2. Why Do We Need Saga?

Suppose an e-commerce order involves:

```text
Order Service
      ↓
Payment Service
      ↓
Inventory Service
      ↓
Shipping Service
```

Each service owns a different database:

```text
Order DB
Payment DB
Inventory DB
Shipping DB
```

We cannot easily use one normal database transaction across all of them.

For example:

```text
Payment     → SUCCESS
Inventory   → SUCCESS
Shipping    → FAILED
```

Now what?

We cannot simply do:

```text
ROLLBACK EVERYTHING
```

because these are separate databases/services.

Saga solves this using **compensating actions**.

---

# 3. Main Idea

Normal transaction:

```text
BEGIN
   ↓
Step 1
   ↓
Step 2
   ↓
Step 3
   ↓
COMMIT
```

Saga:

```text
Step 1 → Step 2 → Step 3
   ↓
Failure
   ↓
Compensate previous successful steps
```

Example:

```text
Create Order
     ↓
Charge Payment
     ↓
Reserve Inventory
     ↓
Schedule Shipping
     ↓
      ❌ FAILED
     ↓
Release Inventory
     ↓
Refund Payment
     ↓
Cancel Order
```

---

# 4. Important Concepts

## 4.1 Local Transaction

A transaction performed inside one service/database.

Example:

```text
Payment Service

BEGIN
   Charge customer
COMMIT
```

This transaction is atomic inside the Payment Service.

---

## 4.2 Compensating Transaction

A business operation that reverses the effect of a previous successful operation.

Example:

```text
Original:

ChargePayment()

Compensation:

RefundPayment()
```

Another example:

```text
ReserveInventory()
        ↓
ReleaseInventory()
```

Another:

```text
CreateOrder()
        ↓
CancelOrder()
```

### Important

A compensation is **not a database rollback**.

It is a **business-level undo operation**.

---

# 5. Example — E-Commerce Order

Suppose the customer places an order.

We have:

```text
Order Service
Payment Service
Inventory Service
Shipping Service
```

Business flow:

```text
Create Order
     ↓
Charge Payment
     ↓
Reserve Inventory
     ↓
Schedule Shipping
```

---

# 6. Successful Saga

```text
Create Order
     ↓ SUCCESS
Charge Payment
     ↓ SUCCESS
Reserve Inventory
     ↓ SUCCESS
Schedule Shipping
     ↓ SUCCESS
Order COMPLETED
```

Everything succeeds.

No compensation is required.

---

# 7. Failed Saga Example

Suppose:

```text
Create Order      → SUCCESS
Charge Payment    → SUCCESS
Reserve Inventory → SUCCESS
Shipping          → FAILED
```

We now need compensation.

```text
Shipping FAILED
       ↓
Release Inventory
       ↓
Refund Payment
       ↓
Cancel Order
```

Final state:

```text
Order = CANCELLED
Payment = REFUNDED
Inventory = RELEASED
Shipping = NOT SCHEDULED
```

---

# 8. Compensation Table

| Step | Forward Action | Compensation |
|---|---|---|
| 1 | Create Order | Cancel Order |
| 2 | Charge Payment | Refund Payment |
| 3 | Reserve Inventory | Release Inventory |
| 4 | Schedule Shipping | Cancel Shipment |

Remember:

> **Compensation usually happens in reverse order.**

```text
A → B → C → D

If D fails:

C → compensate
B → compensate
A → compensate
```

---

# 9. Two Types of Saga

There are two major approaches:

```text
1. Choreography
2. Orchestration
```

---

# 10. Choreography

In **Choreography**, there is no central coordinator.

Services communicate using events.

Example:

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

Each service:

1. Performs its local transaction
2. Publishes an event
3. Other services listen to that event

---

# 11. Choreography Example

### Step 1 — Order Service

```text
Create Order
     ↓
OrderCreated event
```

### Step 2 — Payment Service

Receives:

```text
OrderCreated
```

Then:

```text
Charge Payment
     ↓
PaymentSucceeded
```

### Step 3 — Inventory Service

Receives:

```text
PaymentSucceeded
```

Then:

```text
Reserve Inventory
     ↓
InventoryReserved
```

### Step 4 — Shipping Service

Receives:

```text
InventoryReserved
```

Then:

```text
Schedule Shipping
     ↓
ShipmentScheduled
```

---

# 12. Choreography Failure

Suppose:

```text
OrderCreated
     ↓
PaymentSucceeded
     ↓
InventoryReserved
     ↓
ShippingFailed
```

Shipping publishes:

```text
ShippingFailed
```

Inventory Service listens:

```text
ShippingFailed
     ↓
Release Inventory
     ↓
InventoryReleased
```

Payment Service listens:

```text
InventoryReleased
     ↓
Refund Payment
```

Order Service listens:

```text
ShippingFailed
     ↓
Cancel Order
```

---

# 13. Choreography Architecture

```text
                 Event Bus
              Kafka / RabbitMQ
                    |
       +------------+------------+
       |            |            |
       ↓            ↓            ↓
    Order        Payment      Inventory
    Service      Service       Service
       |            |            |
       +------------+------------+
                    |
                    ↓
                Shipping
                 Service
```

---

# 14. Choreography Advantages

### Advantages

- No central coordinator
- Loosely coupled
- Highly scalable
- Services can independently react to events
- Good for simple workflows

### Disadvantages

- Difficult to understand when workflow becomes complex
- Harder debugging
- Event chains can become complicated
- Business workflow is distributed across services
- Difficult to know overall Saga state
- Circular event dependencies can occur

---

# 15. Orchestration

In **Orchestration**, we have a central **Saga Orchestrator**.

The orchestrator controls the workflow.

```text
             Saga Orchestrator
                    |
        +-----------+-----------+
        |           |           |
        ↓           ↓           ↓
     Order       Payment     Inventory
     Service     Service      Service
                                |
                                ↓
                            Shipping
```

The orchestrator says:

```text
"Charge Payment"

"Reserve Inventory"

"Schedule Shipping"
```

It also decides what to compensate when something fails.

---

# 16. Orchestration Example

```text
Client
  ↓
Saga Orchestrator
  ↓
Payment Service
  ↓ SUCCESS
Inventory Service
  ↓ SUCCESS
Shipping Service
  ↓ FAILURE
```

Orchestrator now executes:

```text
Inventory → Release
Payment   → Refund
Order     → Cancel
```

---

# 17. Orchestration Advantages

### Advantages

- Centralized workflow
- Easier to understand
- Easier debugging
- Easier to implement complex workflows
- Clear failure/compensation logic
- Saga state can be stored centrally

### Disadvantages

- Orchestrator adds complexity
- Additional service to maintain
- Orchestrator can become a bottleneck if poorly designed
- More coupling to workflow logic
- Must make orchestrator highly available

### Important

The orchestrator is **not necessarily a single point of failure**.

You can run multiple orchestrator instances and persist Saga state.

---

# 18. Choreography vs Orchestration

| Feature | Choreography | Orchestration |
|---|---|---|
| Coordinator | No | Yes |
| Communication | Events | Commands/API/events |
| Complexity | Good for simple flows | Good for complex flows |
| Debugging | Harder | Easier |
| Central control | No | Yes |
| Coupling | More distributed | More centralized |
| Workflow visibility | Lower | Higher |
| Scalability | High | High |
| Best for | Simple workflows | Complex workflows |

### Easy Memory Trick

```text
Choreography
= Everyone knows what to do

Orchestration
= One coordinator tells everyone what to do
```

---

# 19. Saga Consistency Model

Saga usually provides:

> **Eventual Consistency**

Example:

Initially:

```text
Payment = SUCCESS
Inventory = RESERVED
Shipping = FAILED
```

The system is temporarily inconsistent.

Then compensation happens:

```text
Refund Payment
Release Inventory
Cancel Order
```

Eventually:

```text
Payment = REFUNDED
Inventory = AVAILABLE
Order = CANCELLED
```

Therefore:

```text
Saga → Eventual Consistency
```

---

# 20. Saga vs 2PC

## 2PC

Two-Phase Commit uses a distributed transaction coordinator.

```text
Coordinator
   |
   +-- DB 1
   +-- DB 2
   +-- DB 3
```

All participants must agree before commit.

### 2PC Advantages

- Stronger atomicity
- Easier transactional semantics
- No business compensation required for normal rollback

### 2PC Disadvantages

- Blocking/coordinator dependency
- Higher latency
- Distributed locking/resource holding
- Poorer availability during failures
- Difficult to scale across independent microservices

---

# 21. Saga vs 2PC

| Feature | Saga | 2PC |
|---|---|---|
| Transaction type | Local transactions | Distributed transaction |
| Consistency | Eventual | Stronger atomicity |
| Locking | Usually no global lock | Can hold resources |
| Availability | Generally better | Can degrade during failures |
| Latency | Usually lower | Usually higher |
| Scalability | Better for microservices | More difficult |
| Rollback | Compensation | Transaction rollback |
| Complexity | Business compensation | Distributed transaction coordination |

### Easy Rule

> **2PC = rollback the transaction**

> **Saga = compensate the business operation**

---

# 22. Idempotency

This is one of the **most important Saga interview topics**.

A message can be delivered more than once.

Example:

```text
PaymentSucceeded
PaymentSucceeded
PaymentSucceeded
```

If Payment Service processes all three:

```text
$100
$100
$100
```

Customer could be charged multiple times.

Therefore operations should be **idempotent**.

---

# 23. What Is Idempotency?

An operation is idempotent when executing it multiple times produces the same final result as executing it once.

Example:

```text
Refund(paymentId)
```

If the same request arrives twice:

```text
Refund(payment123)
Refund(payment123)
```

The customer should still receive only one refund.

Use:

```text
paymentId
requestId
idempotencyKey
```

to detect duplicates.

---

# 24. Saga State

For orchestration, store Saga state durably.

Example:

```text
Saga ID: SAGA-1001

Status: IN_PROGRESS

Completed Steps:
- PAYMENT
- INVENTORY

Current Step:
- SHIPPING

Payment ID:
P123

Reservation ID:
R456
```

If the orchestrator crashes:

```text
Orchestrator ❌
      ↓
Restart
      ↓
Read Saga State
      ↓
Continue
```

Without persisted state, the system may lose track of what has already happened.

---

# 25. Saga ID / Correlation ID

Every request/event should contain a unique:

```text
sagaId
```

Example:

```text
sagaId = SAGA-1001
```

Events:

```text
OrderCreated
  sagaId=SAGA-1001

PaymentSucceeded
  sagaId=SAGA-1001

InventoryReserved
  sagaId=SAGA-1001
```

This allows us to trace one business transaction across multiple services.

---

# 26. Retry

Distributed systems have temporary failures.

Example:

```text
Payment Service
      ↓
Timeout
```

The operation may actually have succeeded, but the response was lost.

Therefore:

```text
Retry
```

But retrying without idempotency can cause duplicate operations.

Correct pattern:

```text
Retry
 +
Idempotency
```

---

# 27. Exponential Backoff

Instead of immediately retrying continuously:

```text
Retry 1 → 100ms
Retry 2 → 200ms
Retry 3 → 400ms
Retry 4 → 800ms
```

Usually add **jitter** so many clients don't retry at exactly the same time.

---

# 28. Timeout

Every Saga step should have a timeout.

Example:

```text
Shipping request
      ↓
Wait 5 seconds
      ↓
Timeout
      ↓
Retry / compensate / escalate
```

Never allow a Saga to remain indefinitely:

```text
IN_PROGRESS
```

---

# 29. Compensation Can Also Fail

Very important.

Suppose:

```text
Payment SUCCESS
Inventory SUCCESS
Shipping FAILED
```

We try:

```text
Refund Payment
```

But Refund Payment also fails.

Now:

```text
Payment = SUCCESS
Inventory = RESERVED
Shipping = FAILED
```

The system must retry compensation.

Possible solution:

```text
Retry
 ↓
Retry
 ↓
Retry
 ↓
Dead Letter Queue
 ↓
Manual Reconciliation
```

Saga does not magically guarantee that compensation always succeeds.

---

# 30. Transactional Outbox Pattern

A common problem:

```text
Update DB
   ↓
Publish Event
```

What if:

```text
DB update → SUCCESS
Event publish → FAILED
```

Now the database changed but other services don't know.

Use **Transactional Outbox**.

```text
Local Transaction
       |
       +---- Update business table
       |
       +---- Insert event into Outbox
                    ↓
                  COMMIT
                    ↓
              Outbox Publisher
                    ↓
                Event Bus
```

The DB update and outbox insert happen in the same local transaction.

This is commonly used with Saga/event-driven systems.

---

# 31. Dead Letter Queue

If an event repeatedly fails:

```text
Event
 ↓
Retry
 ↓
Retry
 ↓
Retry
 ↓
DLQ
```

DLQ = **Dead Letter Queue**

Operations teams can inspect and replay failed messages.

---

# 32. Observability

A production Saga needs:

### Logs

```text
sagaId
orderId
step
status
error
```

### Metrics

Track:

```text
Saga started
Saga completed
Saga failed
Compensation count
Retry count
Saga duration
```

### Distributed Tracing

Use:

```text
traceId
sagaId
```

to follow:

```text
Order
 ↓
Payment
 ↓
Inventory
 ↓
Shipping
```

---

# 33. When Should We Use Saga?

Use Saga when:

- You have microservices
- Each service owns its own database
- Business workflow spans multiple services
- Eventual consistency is acceptable
- You want to avoid distributed transactions
- Compensation is possible

Examples:

```text
E-commerce order
Travel booking
Hotel reservation
Flight booking
Subscription activation
Payment workflows
Resource provisioning
```

---

# 34. When Should We NOT Use Saga?

Saga may not be appropriate when:

- Strict atomicity is mandatory
- Eventual consistency is unacceptable
- There is no safe compensation
- Business operations cannot be reversed
- A single database transaction can solve the problem

Example:

```text
Some financial operations
```

If the business requires strict atomicity and cannot safely compensate, Saga may not be the right solution.

---

# 35. Important Saga Design Questions

In an interview, think about these:

```text
1. What are the steps?

2. What is the compensation for each step?

3. Choreography or orchestration?

4. Is eventual consistency acceptable?

5. How do we handle duplicate messages?

6. Are operations idempotent?

7. Where do we store Saga state?

8. What happens if a service crashes?

9. What happens if a message is lost?

10. What happens if compensation fails?

11. How do we retry?

12. How do we monitor failed Sagas?
```

---

# 36. Complete E-Commerce Saga

## Forward Flow

```text
             Start
               |
               v
         Create Order
               |
               v
        Charge Payment
               |
               v
       Reserve Inventory
               |
               v
       Schedule Shipping
               |
               v
        Order Completed
```

## Failure Flow

```text
Schedule Shipping
       |
       X FAILED
       |
       v
Release Inventory
       |
       v
Refund Payment
       |
       v
Cancel Order
```

---

# 37. Orchestrator State Machine

A Saga can be modeled as:

```text
CREATED
   ↓
PAYMENT_PENDING
   ↓
PAYMENT_COMPLETED
   ↓
INVENTORY_PENDING
   ↓
INVENTORY_RESERVED
   ↓
SHIPPING_PENDING
   ↓
COMPLETED
```

Failure:

```text
ANY STEP
   ↓
FAILED
   ↓
COMPENSATING
   ↓
COMPENSATED
   ↓
CANCELLED
```

This makes complex workflows easier to manage.

---

# 38. Example Pseudocode

```text
startSaga(order):

    createSaga(order)

    payment = chargePayment(order)

    if payment.failed:
        cancelOrder()
        return FAILED

    save(payment)

    inventory = reserveInventory(order)

    if inventory.failed:
        refundPayment(payment.id)
        cancelOrder()
        return FAILED

    save(inventory)

    shipping = scheduleShipping(order)

    if shipping.failed:
        releaseInventory(inventory.id)
        refundPayment(payment.id)
        cancelOrder()
        return FAILED

    markSagaCompleted()

    return SUCCESS
```

Important production improvements:

```text
Idempotency
Retries
Timeouts
Persistent Saga state
Transactional Outbox
DLQ
Monitoring
Distributed tracing
```

---

# 39. Choreography vs Orchestration — Interview Decision

### Choose Choreography when:

```text
Simple workflow
Few services
Event-driven architecture
Loose coupling is important
```

### Choose Orchestration when:

```text
Complex workflow
Many steps
Many failure/compensation paths
Need centralized visibility
Need explicit workflow state
```

### Easy Interview Answer

> "For a simple workflow I can use choreography, where services communicate through events. For a complex business workflow with many steps and compensations, I prefer orchestration because the workflow and failure handling are easier to manage."

---

# 40. Common Pitfalls

## Pitfall 1 — Non-idempotent operations

```text
Retry charge payment
→ Customer charged twice
```

Solution:

```text
Idempotency key
```

---

## Pitfall 2 — No persistent Saga state

```text
Orchestrator crashes
→ Doesn't know completed steps
```

Solution:

```text
Persist Saga state
```

---

## Pitfall 3 — Assuming compensation is guaranteed

```text
Refund fails
```

Solution:

```text
Retry + DLQ + reconciliation
```

---

## Pitfall 4 — Missing events

```text
DB updated
Event lost
```

Solution:

```text
Transactional Outbox
```

---

## Pitfall 5 — Infinite retries

```text
Retry forever
```

Solution:

```text
Bounded retries
+ exponential backoff
+ DLQ
+ manual recovery
```

---

## Pitfall 6 — Overusing Saga

Don't use Saga when:

```text
One database
+
One transaction
```

can solve the problem.

A simple local transaction is usually better.

---

# 41. Saga Advantages

### Advantages

- Works well with microservices
- Avoids distributed 2PC
- High scalability
- Better availability in many designs
- Each service owns its database
- Supports long-running workflows
- Failure recovery through compensation

---

# 42. Saga Disadvantages

### Disadvantages

- Eventual consistency
- More complex failure handling
- Compensation logic is difficult
- Compensation can itself fail
- Debugging can be challenging
- Requires idempotency
- Requires retries/timeouts
- Requires good observability
- Complex workflows can become difficult to manage

---

# 43. Real-World Example — Travel Booking

Suppose the user books:

```text
Flight
Hotel
Car
```

Flow:

```text
Book Flight
    ↓
Book Hotel
    ↓
Book Car
```

Suppose:

```text
Flight  → SUCCESS
Hotel   → SUCCESS
Car     → FAILED
```

Compensation:

```text
Cancel Hotel
    ↓
Cancel Flight
```

Final state:

```text
Flight = CANCELLED
Hotel = CANCELLED
Car = NOT BOOKED
```

This is a classic Saga use case.

---

# 44. Another Example — Subscription

```text
Create Account
      ↓
Charge Payment
      ↓
Create Subscription
      ↓
Provision Resources
```

If provisioning fails:

```text
Provisioning FAILED
      ↓
Cancel Subscription
      ↓
Refund Payment
      ↓
Disable Account
```

---

# 45. Saga + Event Bus

A common architecture:

```text
                         +----------------+
                         | Saga           |
                         | Orchestrator   |
                         +-------+--------+
                                 |
                          Commands / Events
                                 |
                                 v
                         +---------------+
                         | Event Bus     |
                         | Kafka         |
                         +-------+-------+
                                 |
             +-------------------+-------------------+
             |                   |                   |
             v                   v                   v
        Order Service       Payment Service    Inventory Service
             |                   |                   |
          Order DB            Payment DB         Inventory DB
```

For choreography, the orchestrator can be removed:

```text
Order Service
     |
     v
  Event Bus
     |
     +----> Payment Service
     |
     +----> Inventory Service
     |
     +----> Shipping Service
```

---

# 46. Saga Design Checklist

Before finalizing a Saga design, verify:

```text
[ ] Define business steps

[ ] Define compensation for every step

[ ] Choose choreography or orchestration

[ ] Make operations idempotent

[ ] Add Saga ID / correlation ID

[ ] Persist Saga state

[ ] Add retries

[ ] Add exponential backoff + jitter

[ ] Add timeouts

[ ] Handle duplicate messages

[ ] Use transactional outbox where needed

[ ] Add DLQ

[ ] Handle compensation failure

[ ] Add distributed tracing

[ ] Add metrics and logs

[ ] Provide reconciliation/manual recovery
```

---

# 🧠 FINAL RECALL

## Saga =

```text
Local Transaction
       +
Local Transaction
       +
Local Transaction
       +
Compensation on Failure
```

## Example

```text
Order
  ↓
Payment
  ↓
Inventory
  ↓
Shipping
```

If Shipping fails:

```text
Shipping ❌
   ↓
Release Inventory
   ↓
Refund Payment
   ↓
Cancel Order
```

---

## Choreography

```text
Service → Event → Service → Event → Service
```

**No central coordinator**

### Remember:

> **Services coordinate through events.**

---

## Orchestration

```text
              Orchestrator
              /    |    \
             ↓     ↓     ↓
         Payment Inventory Shipping
```

**Central coordinator**

### Remember:

> **Orchestrator tells services what to do.**

---

## Critical Concepts

```text
Saga
 ↓
Eventual Consistency
 ↓
Compensation
 ↓
Idempotency
 ↓
Retries
 ↓
Timeouts
 ↓
Persistent State
 ↓
Outbox
 ↓
DLQ
 ↓
Reconciliation
```

---

# ⭐ 30-Second Interview Answer

> **"Saga is a distributed transaction pattern used in microservices. Instead of using one distributed transaction across multiple databases, we break the workflow into local transactions. If a later step fails, we execute compensating transactions for the previously completed steps. Saga can be implemented using choreography or orchestration. Choreography uses events without a central coordinator, while orchestration uses a central Saga orchestrator. Since Saga provides eventual consistency, we need idempotency, retries, timeouts, persistent Saga state, observability, and a strategy for failed compensations."**

---

# 🔥 One-Line Memory Trick

> **Saga = Do local transactions → If failure → Compensate previous work → Eventually become consistent.**