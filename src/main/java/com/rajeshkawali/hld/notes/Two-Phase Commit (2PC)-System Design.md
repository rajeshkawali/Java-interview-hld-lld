# 2-PHASE COMMIT (2PC) — SYSTEM DESIGN

## 1. What is 2-Phase Commit?

**2-Phase Commit (2PC)** is a distributed transaction protocol used to make sure that **multiple services/databases either all commit a transaction or all roll it back.**

### Simple Definition

> **2PC = All participants commit, or all participants rollback.**

It provides **strong consistency/atomicity** across multiple databases, but it can reduce availability and increase latency because participants may need to wait for the coordinator.

---

# 2. Why Do We Need 2PC?

Consider an online shopping system:

```text
Order Service
      ↓
Order DB

Payment Service
      ↓
Payment DB
```

Suppose we need to:

```text
1. Create Order
2. Deduct Payment
```

What if:

```text
Order DB → SUCCESS
Payment DB → FAILURE
```

Now the system is inconsistent:

```text
Order exists
BUT
Payment failed
```

2PC tries to make the distributed operation atomic:

```text
Either:

Order DB     → COMMIT
Payment DB   → COMMIT

OR

Order DB     → ROLLBACK
Payment DB   → ROLLBACK
```

---

# 3. Main Components of 2PC

2PC has two main roles:

```text
1. Coordinator
2. Participants
```

### Coordinator

The coordinator controls the distributed transaction.

Example:

```text
Transaction Coordinator
       |
       ├── Order DB
       └── Payment DB
```

### Participants

Participants are the databases/services involved in the transaction.

Example:

```text
Order DB
Payment DB
Inventory DB
```

---

# 4. The Two Phases

2PC has:

```text
Phase 1 → Prepare
Phase 2 → Commit / Rollback
```

---

# 5. Phase 1 — PREPARE

The coordinator asks every participant:

> "Can you commit this transaction?"

```text
             Coordinator
              /       \
             ↓         ↓
        Order DB    Payment DB
             ↓         ↓
           PREPARE   PREPARE
```

Each participant:

```text
1. Executes the transaction locally.
2. Validates constraints.
3. Acquires required locks/resources.
4. Writes required information to durable storage/log.
5. Responds:
   YES → Ready to commit
   NO  → Cannot commit
```

Example:

```text
Coordinator → Order DB: PREPARE?

Order DB → Coordinator: YES

Coordinator → Payment DB: PREPARE?

Payment DB → Coordinator: YES
```

Now everyone is ready.

---

# 6. Phase 2 — COMMIT

If **ALL participants said YES**, the coordinator sends:

```text
COMMIT
```

to everyone.

```text
             Coordinator
              /       \
             ↓         ↓
        Order DB    Payment DB
             ↓         ↓
          COMMIT     COMMIT
```

Transaction is completed.

---

# 7. What If One Participant Says NO?

Suppose:

```text
Order DB    → YES
Payment DB  → NO
```

Coordinator sends:

```text
ROLLBACK
```

to all participants.

```text
             Coordinator
              /       \
             ↓         ↓
        Order DB    Payment DB
             ↓         ↓
         ROLLBACK   ROLLBACK
```

The transaction is aborted.

---

# 8. Complete 2PC Flow

```text
                 CLIENT
                    |
                    ↓
              COORDINATOR
                    |
              Phase 1: PREPARE
                    |
             ┌──────┴──────┐
             ↓             ↓
         Order DB      Payment DB
             |             |
            YES           YES
             └──────┬──────┘
                    ↓
            All participants
                 READY?
                    |
                   YES
                    |
                    ↓
             Phase 2: COMMIT
                    |
             ┌──────┴──────┐
             ↓             ↓
         Order DB      Payment DB
             ↓             ↓
          COMMIT        COMMIT
```

If any participant responds `NO`:

```text
             Coordinator
                    |
              PREPARE
              /     \
             ↓       ↓
         Order DB  Payment DB
            YES       NO
             \         /
              \       /
               ↓     ↓
               ROLLBACK
```

---

# 9. Real-Life Example — Bank Transfer

Suppose we transfer:

```text
₹1,000
```

from:

```text
Account A
```

to:

```text
Account B
```

Databases:

```text
Account DB A
Account DB B
```

We want:

```text
A = A - ₹1,000
B = B + ₹1,000
```

Both operations must succeed together.

### Phase 1

```text
Coordinator
   |
   ├── Account DB A → PREPARE?
   |                     ↓
   |                    YES
   |
   └── Account DB B → PREPARE?
                         ↓
                        YES
```

### Phase 2

```text
Coordinator
   |
   ├── Account DB A → COMMIT
   |
   └── Account DB B → COMMIT
```

Final:

```text
A → -₹1,000
B → +₹1,000
```

---

# 10. Example Where Transaction Fails

Suppose:

```text
Account A → YES
Account B → NO
```

Coordinator:

```text
ROLLBACK
```

Therefore:

```text
Account A → Original balance
Account B → Original balance
```

No partial transaction should remain.

---

# 11. Why Is It Called "2-Phase"?

Because the protocol has exactly two major phases:

```text
PHASE 1
Prepare
↓
"Can everyone commit?"

PHASE 2
Commit / Abort
↓
"Everyone commit or rollback."
```

### Easy Memory Trick

```text
2PC

1 → ASK
2 → DECIDE
```

Or:

```text
Prepare
   ↓
Commit/Rollback
```

---

# 12. Important Concept — PREPARED State

During Phase 1, a participant may enter a:

```text
PREPARED
```

state.

Example:

```text
Payment DB

Transaction:
Deduct ₹100

Status:
PREPARED
```

It has prepared the transaction but has not permanently committed it yet.

The participant may hold locks/resources while waiting for the coordinator's final decision.

---

# 13. What Happens If Coordinator Crashes?

This is one of the biggest problems with 2PC.

Suppose:

```text
Phase 1:

Order DB    → YES
Payment DB  → YES
```

Then:

```text
Coordinator crashes
```

before sending the final decision.

Participants may be stuck:

```text
Order DB
   ↓
PREPARED
   ↓
WAITING
```

```text
Payment DB
   ↓
PREPARED
   ↓
WAITING
```

They may have to hold locks/resources while waiting to learn whether the transaction should commit or abort.

This is why 2PC is considered a **blocking protocol**.

---

# 14. Main Problem — Blocking

Suppose:

```text
Coordinator
     X
   CRASHED
```

Participants:

```text
DB1 → PREPARED
DB2 → PREPARED
```

They don't necessarily know the final global decision.

Therefore:

```text
PREPARED
   ↓
WAIT
   ↓
Coordinator recovery
```

This can increase:

```text
Latency
Lock duration
Resource usage
Availability problems
```

---

# 15. Advantages of 2PC

## 1. Strong Atomicity

All participants commit or rollback.

```text
ALL SUCCESS
OR
ALL FAIL
```

---

## 2. Strong Consistency

Useful when partial completion is unacceptable.

Example:

```text
Financial transaction
```

---

## 3. Simple Concept

The protocol is conceptually straightforward:

```text
Prepare
↓
Commit / Rollback
```

---

## 4. Automatic Coordination

The coordinator manages the global transaction.

Applications don't have to manually implement every compensation path.

---

# 16. Disadvantages of 2PC

## 1. Blocking

Participants can remain in the prepared state if the coordinator fails.

---

## 2. Higher Latency

There are multiple network round trips.

```text
Client
 ↓
Coordinator
 ↓
Prepare
 ↓
Participants
 ↓
Commit
 ↓
Participants
```

---

## 3. Coordinator Dependency

Coordinator is critical to transaction progress.

If it fails:

```text
Progress may be delayed
```

A production implementation therefore needs coordinator recovery/failover.

---

## 4. Reduced Availability

Participants may hold locks/resources while waiting.

This can hurt availability under failures or network partitions.

---

## 5. Poor Fit for Microservices

Microservices often have:

```text
Different databases
Different services
Independent deployments
Independent scaling
```

2PC tightly couples them into one distributed transaction.

---

## 6. Network Dependency

2PC requires reliable communication between:

```text
Coordinator
     ↕
Participants
```

Network failures can delay the transaction.

---

# 17. 2PC vs Normal Database Transaction

### Normal Transaction

One database:

```text
Application
    ↓
Database
    ↓
BEGIN
UPDATE
COMMIT
```

Database itself controls the transaction.

### 2PC

Multiple databases:

```text
             Coordinator
             /         \
            ↓           ↓
         DB1           DB2
```

A coordinator manages the distributed transaction.

---

# 18. 2PC vs Saga

This is a **very common system-design interview question**.

| Feature | 2PC | Saga |
|---|---|---|
| Consistency | Stronger atomicity | Eventual consistency |
| Approach | Distributed commit | Local transactions |
| Rollback | DB rollback/abort | Compensation |
| Blocking | Yes, can block | Generally non-blocking workflow |
| Availability | Lower under failures | Usually better |
| Latency | Higher | Usually lower |
| Coupling | High | Lower |
| Microservices | Often avoided | Common choice |
| Failure handling | Coordinator protocol | Retry + compensation |
| Complexity | Infrastructure/protocol complexity | Business/workflow complexity |

---

# 19. 2PC vs Saga — Example

Suppose an e-commerce order requires:

```text
1. Create Order
2. Charge Payment
3. Reserve Inventory
4. Schedule Shipping
```

### 2PC

Try to make all participants part of one distributed transaction:

```text
             Coordinator
                  |
       ┌──────────┼──────────┐
       ↓          ↓          ↓
    Order      Payment    Inventory
      DB          DB          DB
```

All prepare.

Then:

```text
All YES → COMMIT
Any NO  → ROLLBACK
```

This can be difficult across independent microservices.

---

### Saga

Each service commits its own local transaction:

```text
Create Order
     ↓
Charge Payment
     ↓
Reserve Inventory
     ↓
Schedule Shipping
```

If inventory fails:

```text
Inventory FAILED
      ↓
Refund Payment
      ↓
Cancel Order
```

The undo operations are **compensating transactions**.

---

# 20. When Should We Use 2PC?

Use 2PC when:

```text
✓ Strong atomicity is required
✓ Participants support distributed transactions
✓ Transaction duration is short
✓ Blocking is acceptable
✓ Infrastructure is controlled
✓ Cross-database consistency is more important than availability
```

Examples may include tightly controlled enterprise systems where multiple transactional resources must coordinate.

---

# 21. When Should We Avoid 2PC?

Avoid or carefully evaluate 2PC when:

```text
✗ Large-scale microservices
✗ Long-running workflows
✗ High availability is critical
✗ Services use independent databases
✗ Network failures are common
✗ Compensation is possible
✗ Services need independent scaling/deployment
```

In these cases, **Saga** is often a better fit.

---

# 22. 2PC Failure Scenarios

### Case 1 — Participant says NO

```text
DB1 → YES
DB2 → NO

Coordinator
    ↓
ROLLBACK
```

Transaction aborts.

---

### Case 2 — Participant crashes before PREPARE

```text
DB1 → YES
DB2 → CRASH
```

Coordinator cannot complete preparation.

Usually:

```text
ABORT
```

---

### Case 3 — Coordinator crashes before decision

```text
DB1 → PREPARED
DB2 → PREPARED

Coordinator → CRASH
```

Participants may wait.

This is the classic blocking problem.

---

### Case 4 — Network failure

```text
Coordinator
     |
     X
 Network
     X
     |
Participant
```

Coordinator may not know whether the participant received the message.

The protocol must rely on durable logs/recovery to resolve the transaction safely.

---

# 23. Logging in 2PC

Durable logs are important.

Participants typically persist enough information to recover their transaction state after a crash.

Example:

```text
Transaction ID: TX123

State:
PREPARED
```

After recovery:

```text
Read transaction log
        ↓
Determine previous state
        ↓
Recover transaction
```

The coordinator also needs durable transaction state.

---

# 24. 2PC Interview Question

### Q: Explain 2PC in simple terms.

### Answer:

> 2-Phase Commit is a distributed transaction protocol that coordinates multiple participants so that a transaction either commits everywhere or aborts everywhere. In Phase 1, the coordinator asks all participants to prepare and each participant responds whether it can commit. In Phase 2, if everyone agrees, the coordinator sends commit; otherwise it sends rollback. The main drawback is that it can block when the coordinator fails and it introduces latency and tight coupling.

---

# 25. 2PC Interview Question

### Q: Why is 2PC called a blocking protocol?

### Answer:

> Because after participants enter the prepared state, they may need to wait for the coordinator's final commit or rollback decision. If the coordinator fails at the wrong time, participants can hold locks/resources while waiting for recovery.

---

# 26. 2PC Interview Question

### Q: Why is Saga preferred over 2PC in microservices?

### Answer:

> Saga breaks a distributed transaction into independent local transactions and uses compensating actions when later steps fail. This avoids a long-running global transaction and generally provides better availability and scalability, but it gives up immediate global atomicity and requires more business-level failure handling.

---

# 27. 2PC vs Saga — Easy Memory Trick

```text
2PC
→ "All or Nothing"

Saga
→ "Do step by step and compensate if something fails"
```

Example:

```text
2PC:

Payment + Inventory
      ↓
All commit
OR
All rollback
```

```text
Saga:

Payment SUCCESS
      ↓
Inventory FAILED
      ↓
Refund Payment
```

---

# 28. 2PC — Interview Architecture

```text
                    Client
                      |
                      ↓
              Transaction Coordinator
                      |
             ┌────────┼────────┐
             ↓        ↓        ↓
           DB 1      DB 2      DB 3
             |         |         |
             |<-- PREPARE ------>|
             |         |         |
             |------ YES --------|
                      |
                Decision
               /         \
              ↓           ↓
           COMMIT       ROLLBACK
              |           |
              ↓           ↓
           DB 1/2/3    DB 1/2/3
```

---

# 29. ⭐ QUICK RECALL NOTES

```text
2PC = Two-Phase Commit

Purpose:
→ Make distributed transaction atomic.

Components:
→ Coordinator
→ Participants

Phase 1:
→ PREPARE
→ "Can you commit?"

Phase 2:
→ COMMIT if ALL say YES
→ ROLLBACK if ANY says NO

Main Benefit:
→ Strong atomicity / all-or-nothing behavior

Main Problems:
→ Blocking
→ Higher latency
→ Coordinator dependency
→ Reduced availability
→ Tight coupling

Coordinator failure:
→ Participants may remain PREPARED/WAITING

2PC:
→ Strong consistency
→ Distributed transaction

Saga:
→ Local transactions
→ Compensation
→ Eventual consistency
→ Usually better fit for microservices
```

# ⭐ ONE-LINE INTERVIEW RECALL

> **2PC = Coordinator asks everyone to PREPARE; if everyone says YES → COMMIT, otherwise → ROLLBACK. Its biggest weakness is blocking and reduced availability when failures occur.**