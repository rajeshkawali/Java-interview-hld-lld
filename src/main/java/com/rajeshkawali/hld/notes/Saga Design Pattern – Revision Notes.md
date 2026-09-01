# Saga Design Pattern – Revision Notes

## What is Saga?

Saga is a **distributed transaction pattern** used in microservices to manage a business transaction that involves multiple services/databases.

Instead of one distributed transaction, Saga divides the operation into multiple **local transactions**.

If a later step fails, **compensating transactions** are executed for previously successful steps.

### Example

```text
Create Order
     ↓
Payment
     ↓
Reserve Inventory
```

If inventory fails:

```text
Inventory → FAILED
     ↓
Refund Payment
     ↓
Cancel Order
```

---

## Why Saga is Needed?

In microservices, each service may have its own database:

```text
Order Service     → Order DB
Payment Service   → Payment DB
Inventory Service → Inventory DB
```

A normal database transaction cannot easily span all these independent databases.

Saga helps maintain **business consistency** without requiring one global transaction.

---

## Important Terms

### Local Transaction
A transaction performed inside one service/database.

### Saga Step
One local transaction in the overall business workflow.

### Compensating Transaction
A business operation that reverses the effect of a previous successful operation.

Examples:

```text
Charge Payment       → Refund Payment
Reserve Inventory    → Release Inventory
Create Order         → Cancel Order
```

Compensation is NOT the same as database rollback. It is a new business operation.

---

# Types of Saga

## 1. Choreography

There is no central coordinator.

Services communicate using events.

```text
Order Service
     ↓
OrderCreated
     ↓
Kafka
     ↓
Payment Service
     ↓
PaymentCompleted
     ↓
Kafka
     ↓
Inventory Service
```

### Advantages
- No central coordinator
- Loosely coupled
- Good for simple workflows
- Good with event-driven architecture

### Disadvantages
- Difficult to understand when workflow becomes large
- Difficult debugging
- Harder to track the complete business flow

---

## 2. Orchestration

A central **Saga Orchestrator** controls the workflow.

```text
             Saga Orchestrator
             /       |       \
            ↓        ↓        ↓
         Order    Payment   Inventory
```

The orchestrator tells each service what to do.

Example:

```text
Create Order
     ↓
Process Payment
     ↓
Reserve Inventory
     ↓
Confirm Order
```

If inventory fails:

```text
Inventory FAILED
     ↓
Refund Payment
     ↓
Cancel Order
```

### Advantages
- Centralized workflow
- Easier debugging
- Easy to understand complex workflows
- Better visibility of Saga state

### Disadvantages
- Orchestrator becomes an important component
- Can become complex if it manages too much business logic
- Requires reliable/persistent Saga state

---

# Choreography vs Orchestration

| Choreography | Orchestration |
|---|---|
| No central coordinator | Central orchestrator |
| Event-driven | Commands/API + events |
| Simple workflows | Complex workflows |
| Harder debugging | Easier debugging |
| Can become difficult with many services | Better workflow visibility |

---

## Important Concepts

### Idempotency

A Saga operation should ideally be safe to execute multiple times.

Example:

```text
RefundPayment(P123)
```

If the same request arrives twice, customer should receive only one refund.

```text
P123 already refunded
     ↓
Do not refund again
```

### Retry

Failed operations may be retried.

```text
Refund
  ↓
Failed
  ↓
Retry
  ↓
Retry
  ↓
Success
```

### Eventual Consistency

Saga does not provide the same atomicity as one ACID transaction.

The system may be temporarily inconsistent while the Saga is executing or compensating.

---

## Saga vs Normal Transaction

Normal transaction:

```text
ALL SUCCESS
     OR
ALL ROLLBACK
```

Saga:

```text
Step 1 → SUCCESS
Step 2 → SUCCESS
Step 3 → FAILED
          ↓
   Compensation
          ↓
Business-consistent state
```

---

## Key Interview Point

Saga does NOT provide traditional ACID atomicity across all microservices.

It manages distributed business transactions using:

**Local Transactions + Events/Commands + Compensating Transactions + Retry + Idempotency**

### Interview Definition

"Saga is a distributed transaction pattern where a business transaction is broken into a sequence of local transactions. If a step fails, compensating transactions are executed to undo the business effects of previous successful steps. Saga can be implemented using choreography or orchestration."