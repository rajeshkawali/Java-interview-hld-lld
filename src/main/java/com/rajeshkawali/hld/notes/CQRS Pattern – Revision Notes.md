# CQRS Pattern – Revision Notes

## What is CQRS?

CQRS = **Command Query Responsibility Segregation**

It separates **write operations (Commands)** from **read operations (Queries)**.

```text
Commands → Write Model → Write DB

Queries  → Read Model  → Read DB
```

### Command
A command changes the state of the system.

Examples:
```text
CreateOrder
UpdateOrder
CancelOrder
MakePayment
```

### Query
A query only reads data and should not modify state.

Examples:
```text
GetOrder
GetUser
SearchProducts
GetOrderHistory
```

---

## Why CQRS?

In some systems, reads and writes have very different requirements.

Example:

```text
100,000 writes/day
100,000,000 reads/day
```

CQRS allows the read and write sides to be optimized/scaled independently.

---

## Typical Architecture

```text
Client
  |
  +-------------------+
  |                   |
  ↓                   ↓
Command API        Query API
  ↓                   ↓
Command Handler    Query Handler
  ↓                   ↓
Write Model        Read Model
  ↓                   ↓
Write DB           Read DB
  |
  ↓
Event
  |
  ↓
Event Broker
  |
  ↓
Read Model Updater
```

---

## CQRS + Eventual Consistency

After a write:

```text
Write DB → Updated
     ↓
Event
     ↓
Read DB → Updated later
```

Therefore, the read model may temporarily contain stale data.

This is called **eventual consistency**.

---

## Does CQRS Require Two Databases?

**No.**

CQRS requires separation of command and query responsibilities/models.

Simple CQRS can use one database:

```text
Commands ──→ Same DB ←── Queries
```

Advanced CQRS may use separate databases:

```text
Commands → Write DB
Queries  → Read DB
```

---

## CQRS + Event Sourcing

CQRS and Event Sourcing are different patterns.

**CQRS:**
```text
Separate Commands and Queries
```

**Event Sourcing:**
```text
Store state changes as events
```

They can be used together, but CQRS does NOT require Event Sourcing.

---

## Advantages

1. Independent read/write scaling
2. Read models can be optimized for specific queries
3. Write side can focus on business rules
4. Can use different technologies for read/write sides
5. Useful for complex and high-scale systems

---

## Disadvantages

1. Increased architecture complexity
2. Eventual consistency
3. Read-model synchronization problems
4. More code and infrastructure
5. Usually unnecessary for simple CRUD applications

---

## When to Use CQRS?

Use CQRS when:
- Read and write workloads are very different
- Complex business logic exists
- Complex read requirements exist
- Multiple read models are needed
- Independent scaling is required
- Event-driven architecture is already being used

Avoid CQRS for simple CRUD applications where the additional complexity provides little benefit.

---

## CQRS vs Saga

**CQRS:**
```text
Separates READ and WRITE
```

**Saga:**
```text
Manages distributed transactions
```

---

## Interview Definition

"CQRS stands for Command Query Responsibility Segregation. It separates commands that modify system state from queries that only read data. The read and write models can be scaled and optimized independently, and in advanced systems they may use separate databases synchronized through events. The trade-off is increased complexity and possible eventual consistency."

### Key Line

**CQRS = Separate what changes data from what reads data.**