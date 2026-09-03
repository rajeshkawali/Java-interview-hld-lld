# Two-Phase Locking (2PL) | System Design

---

# 1. What is Two-Phase Locking (2PL)?

Two-Phase Locking (2PL) is a concurrency-control protocol used by databases to ensure that concurrent transactions produce a **serializable schedule**.

The key rule is:

> A transaction has two phases: a Growing Phase and a Shrinking Phase.

```text
Transaction
    |
    v
Growing Phase
    |
    | Acquire Locks
    | Upgrade Locks
    |
    v
Shrinking Phase
    |
    | Release Locks
    | No new locks allowed
    |
    v
Commit / Abort
```

The most important rule:

```text
Once a transaction releases its first lock,
it cannot acquire any new lock.
```

---

# 2. Why Do We Need 2PL?

Consider two transactions:

```text
T1:
Read A
A = A + 100
Write A

T2:
Read A
A = A - 50
Write A
```

If they execute concurrently without proper coordination, we can get a race condition or lost update.

2PL controls when transactions can acquire and release locks so that the resulting schedule is serializable.

---

# 3. Basic 2PL

Basic 2PL has two phases.

## Phase 1: Growing Phase

During the growing phase:

```text
Can acquire locks
Can upgrade locks
Cannot release locks
```

Example:

```text
T1:

Acquire S(A)
Acquire X(B)
Acquire X(C)
```

Locks are continuously being acquired.

---

## Phase 2: Shrinking Phase

Once the transaction releases a lock:

```text
Cannot acquire any new lock.
```

Example:

```text
Release A
Release B
Release C
```

After releasing the first lock, the transaction is in the shrinking phase.

---

# 4. Basic 2PL Diagram

```text
                Lock Acquisition
                     |
                     v
        +-------------------------+
        |     Growing Phase       |
        |                         |
        | Acquire S/X Locks       |
        | Upgrade Locks           |
        +-------------------------+
                     |
                     | First Unlock
                     v
        +-------------------------+
        |    Shrinking Phase      |
        |                         |
        | Release Locks           |
        | NO NEW LOCKS            |
        +-------------------------+
                     |
                     v
                  Finish
```

---

# 5. Example of Basic 2PL

Suppose:

```text
T1 needs A and B
```

A valid 2PL schedule:

```text
T1:
Lock A
Lock B
Read A
Read B
Update A
Update B
Unlock A
Unlock B
Commit
```

Diagram:

```text
Lock A
  ↓
Lock B
  ↓
Read/Write
  ↓
Unlock A
  ↓
Unlock B
  ↓
Commit
```

After:

```text
Unlock A
```

T1 cannot acquire another lock.

---

# 6. Invalid Basic 2PL Schedule

```text
Lock A
Lock B
Unlock A
Lock C    ❌
```

Why?

Because after:

```text
Unlock A
```

the transaction has entered the shrinking phase.

It cannot acquire:

```text
Lock C
```

Therefore this violates 2PL.

---

# 7. Lock Types Used in 2PL

2PL commonly works with:

```text
Shared Lock (S)
Exclusive Lock (X)
```

## Shared Lock

Used for reading.

```text
S(A)
```

Multiple transactions may generally hold compatible shared locks.

---

## Exclusive Lock

Used for writing.

```text
X(A)
```

An exclusive lock conflicts with other incompatible locks.

---

# 8. Lock Compatibility

Typical compatibility:

```text
             Existing Lock
             S       X

Request S    YES     NO

Request X    NO      NO
```

Therefore:

```text
S + S = Compatible
S + X = Conflict
X + S = Conflict
X + X = Conflict
```

---

# 9. Lock Upgrade

A transaction may initially acquire a shared lock and later upgrade it to an exclusive lock.

Example:

```text
S(A)
  |
  | Need to modify A
  v
X(A)
```

This is called:

> Lock Upgrade

However, upgrading can cause deadlocks.

Example:

```text
T1 → S(A)
T2 → S(A)

T1 → wants X(A)
T2 → wants X(A)
```

Both are waiting for the other shared lock to disappear.

---

# 10. Lock Downgrade

An exclusive lock can sometimes be downgraded to a shared lock.

```text
X(A)
 ↓
S(A)
```

This can allow other readers to proceed.

Whether/how lock conversion is supported depends on the database system.

---

# 11. What Does 2PL Guarantee?

The major property of Basic 2PL is:

> **Conflict serializability**

It means the concurrent schedule is equivalent, in terms of conflicting operations, to some serial execution order.

For example:

```text
Concurrent:

T1 → T2 → T1 → T2
```

may be equivalent to:

```text
T1 → T2
```

or:

```text
T2 → T1
```

depending on the conflicts.

---

# 12. Serial Schedule vs Concurrent Schedule

## Serial Schedule

Transactions execute one after another.

```text
T1
 ↓
T2
 ↓
T3
```

Safe but potentially inefficient.

---

## Concurrent Schedule

Operations overlap.

```text
T1 ──┐
     ├──> Database
T2 ──┤
     |
T3 ──┘
```

Better resource utilization, but concurrency control is required.

2PL allows concurrency while maintaining conflict serializability.

---

# 13. First Major Problem with Basic 2PL: Deadlock

Basic 2PL can cause deadlocks.

Example:

```text
T1:
Lock A
Wait for B

T2:
Lock B
Wait for A
```

Diagram:

```text
T1 owns A
   |
   | waiting for B
   v

T2 owns B
   |
   | waiting for A
   v

DEADLOCK
```

Neither transaction can continue.

---

# 14. Deadlock Example

Suppose:

```text
Initial:

A = 100
B = 200
```

Transaction T1:

```text
Lock A
```

Transaction T2:

```text
Lock B
```

Then:

```text
T1 → wants B
T2 → wants A
```

Result:

```text
T1 holds A → waits for B
T2 holds B → waits for A
```

Deadlock.

---

# 15. Why Does 2PL Allow Deadlocks?

2PL says:

```text
Acquire locks during Growing Phase
Release locks during Shrinking Phase
```

It does NOT require transactions to acquire all locks in advance.

Therefore:

```text
T1:
Lock A
...
Later → Lock B

T2:
Lock B
...
Later → Lock A
```

This creates circular waiting.

---

# 16. Deadlock Handling Strategies

Common approaches:

```text
1. Timeout
2. Wait-for Graph
3. Conservative 2PL
4. Timestamp-based prevention
5. Consistent lock ordering
```

---

# 17. Deadlock Strategy #1: Timeout

If a transaction waits for a lock for too long:

```text
WAIT
 ↓
Timeout
 ↓
Abort transaction
 ↓
Release locks
 ↓
Retry
```

Example:

```text
T1 waiting for B

Wait:
1 sec
2 sec
3 sec
...
10 sec

Timeout!
```

Then T1 is aborted.

---

# 18. Advantages of Timeout

Simple:

```text
Easy to implement
```

Works well in many practical systems.

---

# 19. Disadvantages of Timeout

A timeout does not necessarily mean there is a deadlock.

The lock holder may simply be slow.

Example:

```text
T1 holds lock
T2 waits

T1 takes 15 seconds
T2 timeout = 10 seconds
```

T2 aborts even though there was no deadlock.

Therefore timeout can cause unnecessary transaction aborts.

---

# 20. Deadlock Strategy #2: Wait-For Graph

WFG = Wait-For Graph.

It represents which transaction is waiting for which other transaction.

Example:

```text
T1 waits for T2
```

Graph:

```text
T1 ─────> T2
```

Meaning:

```text
T1 is waiting for a lock currently held by T2.
```

---

# 21. Wait-For Graph Deadlock

Suppose:

```text
T1 waits for T2
T2 waits for T3
T3 waits for T1
```

Graph:

```text
T1 ──> T2
↑       |
|       v
T3 <────
```

There is a cycle:

```text
T1 → T2 → T3 → T1
```

A cycle indicates a deadlock in a conventional wait-for graph model.

---

# 22. WFG Deadlock Detection

Process:

```text
Transactions
     |
     v
Build Wait-For Graph
     |
     v
Detect Cycle
     |
   /   \
 YES    NO
  |      |
  v      v
Deadlock Continue
```

If a cycle is detected:

```text
Choose victim
     ↓
Abort victim
     ↓
Release locks
     ↓
Other transactions continue
```

---

# 23. Choosing a Deadlock Victim

If multiple transactions are involved, the database needs to decide which transaction to abort.

Possible factors:

```text
Transaction age
Amount of work already performed
Number of locks held
Estimated rollback cost
Priority
Number of times transaction has already been aborted
```

Goal:

> Minimize the cost of recovery.

---

# 24. Deadlock Strategy #3: Conservative 2PL

Conservative 2PL is also called:

> Static 2PL

Idea:

> A transaction acquires all required locks before it starts executing.

Example:

```text
T1 needs:
A
B
C
```

Instead of:

```text
Lock A
...
Lock B
...
Lock C
```

it does:

```text
Lock A
Lock B
Lock C
```

before starting execution.

---

# 25. Conservative 2PL Diagram

```text
Transaction
     |
     v
Request ALL required locks
     |
     +------ Cannot get all ------> WAIT
     |
     v
Acquire ALL locks
     |
     v
Execute transaction
     |
     v
Release locks
```

---

# 26. Why Conservative 2PL Prevents Deadlock

Suppose:

```text
T1 needs A + B
T2 needs B + C
```

T1 either gets:

```text
A + B
```

together or waits.

T2 either gets:

```text
B + C
```

together or waits.

A transaction cannot hold:

```text
A
```

while waiting for:

```text
B
```

because it must acquire the entire lock set before execution.

Therefore, the classic hold-and-wait pattern is eliminated.

---

# 27. Disadvantages of Conservative 2PL

The main problem:

> The transaction must know all required locks in advance.

This can be difficult.

Example:

```text
Transaction starts
       ↓
Queries database
       ↓
Discovers another row is needed
       ↓
Needs another lock
```

Conservative 2PL is not convenient for such dynamic workloads.

It can also reduce concurrency because locks may be acquired earlier than necessary.

---

# 28. Deadlock Strategy #4: Timestamp-Based Prevention

Assign every transaction a timestamp.

Example:

```text
T1 → Timestamp 10
T2 → Timestamp 20
```

Therefore:

```text
T1 is older
T2 is younger
```

The system uses the timestamps to decide which transaction should wait, abort, or restart when there is a lock conflict.

Two well-known approaches are:

```text
Wait-Die
Wound-Wait
```

---

# 29. Wait-Die

Rule:

```text
Older transaction → can WAIT
Younger transaction → DIE / ABORT
```

Example:

```text
T1 = older
T2 = younger

T2 wants a lock held by T1
```

Since T2 is younger:

```text
T2 → ABORT
```

Another example:

```text
T1 wants lock held by T2
T1 is older
```

Then:

```text
T1 → WAIT
```

---

# 30. Wait-Die Example

```text
T1 timestamp = 10
T2 timestamp = 20
```

T1 is older.

Case 1:

```text
T1 wants resource held by T2
```

Older waits:

```text
T1 → WAIT
```

Case 2:

```text
T2 wants resource held by T1
```

Younger dies:

```text
T2 → ABORT
```

---

# 31. Wound-Wait

Rule:

```text
Older transaction → WOUND / ABORT younger
Younger transaction → WAIT for older
```

Example:

```text
T1 = older
T2 = younger
```

T1 wants a lock held by T2:

```text
T1 → ABORT T2
```

T2 wants a lock held by T1:

```text
T2 → WAIT
```

---

# 32. Wait-Die vs Wound-Wait

| Situation | Wait-Die | Wound-Wait |
|---|---|---|
| Older wants younger's lock | Older waits | Older aborts younger |
| Younger wants older's lock | Younger aborts | Younger waits |
| Approach | Non-preemptive | Preemptive |

Both use timestamps to maintain a consistent ordering.

---

# 33. Second Major Problem with Basic 2PL: Cascading Abort

Another problem with Basic 2PL is that it can allow:

> Cascading rollbacks / cascading aborts.

Example:

```text
T1 writes A
T2 reads A
T1 aborts
```

T2 read data produced by T1.

Since T1 aborted:

```text
T2's read is no longer valid.
```

T2 may also need to abort.

---

# 34. Cascading Abort Example

Initial:

```text
A = 100
```

T1:

```text
Write A = 200
```

T2:

```text
Read A
=> 200
```

But T1 later:

```text
ABORT
```

Therefore:

```text
A returns to 100
```

T2 had read:

```text
200
```

which was never committed.

Therefore T2 may need to abort.

```text
T1 ABORT
   |
   v
T2 ABORT
```

This is cascading abort.

---

# 35. Why Can Basic 2PL Cause Cascading Abort?

Basic 2PL does not require a transaction to hold its locks until commit.

A transaction can release a lock before committing.

Example:

```text
T1:
X(A)
Write A
Unlock A
...
COMMIT
```

After:

```text
Unlock A
```

another transaction can access A before T1 commits.

If T1 later aborts:

```text
T2's work may depend on invalid data.
```

---

# 36. Solution: Strict 2PL

Strict 2PL solves the cascading-abort problem by holding **exclusive/write locks until the transaction commits or aborts**.

Conceptually:

```text
T1:
X(A)
Write A
...
COMMIT
↓
Release X(A)
```

Other transactions cannot read/write the uncommitted value protected by the exclusive lock.

---

# 37. Strict 2PL

Rule:

> Hold all exclusive locks until commit or abort.

Example:

```text
BEGIN
  |
X(A)
  |
Write A
  |
X(B)
  |
Write B
  |
COMMIT
  |
Release X(A)
Release X(B)
```

This prevents other transactions from accessing data modified by T1 before T1 commits.

---

# 38. Rigorous 2PL

Rigorous 2PL is even stronger.

Rule:

> Hold both shared and exclusive locks until commit or abort.

So:

```text
S locks → held until commit
X locks → held until commit
```

Example:

```text
BEGIN
  |
S(A)
  |
Read A
  |
X(B)
  |
Write B
  |
COMMIT
  |
Release S(A)
Release X(B)
```

---

# 39. Strict vs Rigorous 2PL

| Feature | Strict 2PL | Rigorous 2PL |
|---|---|---|
| X locks held until commit | Yes | Yes |
| S locks held until commit | Not necessarily | Yes |
| Prevents cascading abort from uncommitted writes | Yes | Yes |
| Stronger guarantee | No | Yes |

A useful mental model:

```text
Strict 2PL
    ↓
Hold WRITE locks until commit

Rigorous 2PL
    ↓
Hold READ + WRITE locks until commit
```

---

# 40. Basic vs Strict vs Rigorous 2PL

```text
Basic 2PL
    ↓
Growing + Shrinking
    ↓
Can release locks before commit
    ↓
Can have cascading aborts

Strict 2PL
    ↓
X locks held until commit/abort
    ↓
Prevents cascading aborts from dirty writes

Rigorous 2PL
    ↓
S + X locks held until commit/abort
    ↓
Even stronger
```

---

# 41. Important: Strict 2PL vs Rigorous 2PL

Do not confuse:

```text
Strict 2PL
```

with:

```text
Rigorous 2PL
```

Strict:

```text
WRITE locks stay until commit
```

Rigorous:

```text
ALL locks stay until commit
```

Therefore:

```text
Rigorous 2PL ⊃ Strict 2PL
```

in terms of locking strength.

---

# 42. Example: Basic 2PL

Suppose:

```text
T1:
S(A)
Read A
Unlock A
X(B)
Write B
Unlock B
Commit
```

This is valid under Basic 2PL because:

```text
All lock acquisition happened before the first unlock.
```

After:

```text
Unlock A
```

T1 does not acquire another lock.

---

# 43. Example: Invalid Basic 2PL

```text
T1:
S(A)
Read A
Unlock A
X(B)       ❌
```

Why?

Because:

```text
Unlock A
```

started the shrinking phase.

Then:

```text
X(B)
```

tries to acquire a new lock.

Therefore invalid.

---

# 44. Example: Strict 2PL

```text
T1:

S(A)
Read A

X(B)
Write B

COMMIT

Release locks
```

The exclusive lock on B is retained until commit.

---

# 45. Example: Rigorous 2PL

```text
T1:

S(A)
Read A

X(B)
Write B

COMMIT

Release S(A)
Release X(B)
```

Both locks are held until commit.

---

# 46. 2PL and Serializability

The main purpose of 2PL is to guarantee conflict serializability.

Think:

```text
Concurrent Transactions
        |
        v
      2PL
        |
        v
Controlled Locking
        |
        v
Conflict Serializable Schedule
```

This is why 2PL is an important database concurrency-control protocol.

---

# 47. 2PL vs Transaction

These are not the same thing.

### Transaction

Defines:

```text
BEGIN
Operations
COMMIT / ROLLBACK
```

### 2PL

Defines:

```text
When locks can be acquired
When locks can be released
```

So:

```text
Transaction = Unit of Work

2PL = Concurrency-Control Protocol
```

A transaction can use locking-based concurrency control such as 2PL.

---

# 48. 2PL vs Isolation Level

Isolation level describes the desired visibility/interaction guarantees.

Examples:

```text
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

2PL is a concurrency-control protocol.

They are related, but not interchangeable.

For example:

```text
Isolation Level
      |
      v
Desired concurrency semantics
      |
      v
Database implementation
      |
      +--> Locking
      +--> MVCC
      +--> Other mechanisms
```

Exact implementation depends on the database.

---

# 49. 2PL vs MVCC

## 2PL

Uses locks.

```text
Transaction A
    |
    v
Lock Row
    |
    v
Access Row
```

Other conflicting transactions may wait.

---

## MVCC

Maintains multiple versions.

```text
Row
├── Version 1
├── Version 2
└── Version 3
```

Readers can often read an appropriate snapshot without blocking writers in the same way lock-based systems do.

---

# 50. 2PL vs Optimistic Locking

### 2PL

```text
Acquire lock
    ↓
Perform work
    ↓
Release lock
```

### Optimistic Locking

```text
Read version
    ↓
Perform work
    ↓
Compare version
    ↓
Update if unchanged
```

Optimistic locking generally detects conflicts rather than preventing them through long-held locks.

---

# 51. Practical Database Example

Suppose we have:

```text
accounts

id | balance
-----------
1  | 1000
2  | 500
```

Transfer:

```text
$200 from Account 1 → Account 2
```

Transaction:

```sql
BEGIN;

SELECT *
FROM accounts
WHERE id = 1
FOR UPDATE;

SELECT *
FROM accounts
WHERE id = 2
FOR UPDATE;

UPDATE accounts
SET balance = balance - 200
WHERE id = 1;

UPDATE accounts
SET balance = balance + 200
WHERE id = 2;

COMMIT;
```

The database obtains appropriate locks for the transaction.

---

# 52. Avoiding Deadlock in Transfers

Suppose two transfers happen:

```text
T1:
Account 1 → Account 2

T2:
Account 2 → Account 1
```

Bad locking order:

```text
T1:
Lock Account 1
Lock Account 2

T2:
Lock Account 2
Lock Account 1
```

Potential deadlock.

---

# 53. Consistent Lock Ordering

Better approach:

> Always acquire locks in the same deterministic order.

For example:

```text
Sort account IDs

Always lock smaller ID first.
```

Transfer:

```text
Account 1 → Account 2
```

locks:

```text
1 → 2
```

Reverse transfer:

```text
Account 2 → Account 1
```

also locks:

```text
1 → 2
```

Therefore:

```text
T1 → Lock 1 → Lock 2

T2 → Lock 1 → Lock 2
```

T2 waits instead of creating a circular wait.

This is one of the most practical deadlock-prevention techniques.

---

# 54. 2PL in Distributed Systems

Important distinction:

> 2PL is primarily a database concurrency-control protocol. It does not automatically solve every distributed locking problem.

Example:

```text
Server A
Server B
Server C
     |
     v
Distributed Database
```

If all servers modify the same database, the database can coordinate transactional locking.

But if the resource exists outside the database:

```text
Application
    |
    v
External Resource
```

you may need distributed coordination mechanisms.

Examples:

```text
Distributed lock
Lease
Fencing token
Consensus-based coordination
Queue
```

---

# 55. Distributed Deadlock

Distributed systems can have deadlocks across different database/resource managers.

Example:

```text
Service A
   |
   v
Database 1
   |
   | waits
   v
Database 2

Service B
   |
   v
Database 2
   |
   | waits
   v
Database 1
```

This can create distributed waiting cycles.

Distributed deadlock detection is harder because no single node may have the complete picture.

---

# 56. Basic 2PL Problems

Basic 2PL provides serializability but has important drawbacks.

```text
Basic 2PL
│
├── Deadlocks
│
├── Blocking
│
├── Cascading aborts
│
└── Reduced concurrency under contention
```

Solutions:

```text
Deadlock
    → Timeout
    → WFG
    → Timestamp
    → Conservative 2PL
    → Lock ordering

Cascading Abort
    → Strict 2PL
    → Rigorous 2PL
```

---

# 57. Lock Contention

Suppose:

```text
1000 transactions
       |
       v
Same database row
```

Only one transaction may hold a conflicting exclusive lock at a time.

Therefore:

```text
T1 → RUN
T2 → WAIT
T3 → WAIT
T4 → WAIT
...
```

This creates lock contention.

High contention can cause:

```text
Higher latency
Lower throughput
More timeouts
More deadlocks
```

---

# 58. Long-Running Transactions

Avoid keeping locks for a long time.

Bad:

```text
BEGIN
 ↓
Acquire Lock
 ↓
Call external API
 ↓
Wait 5 seconds
 ↓
Process data
 ↓
Commit
```

During this time:

```text
Other transactions may wait.
```

Better:

```text
Do external work first
        ↓
Start short transaction
        ↓
Acquire locks
        ↓
Update
        ↓
Commit
```

Keep the critical section as short as possible.

---

# 59. Interview Question: What is 2PL?

### Answer

> Two-Phase Locking is a database concurrency-control protocol where a transaction has a growing phase, during which it acquires locks, and a shrinking phase, during which it releases locks. Once the transaction releases its first lock, it cannot acquire any new locks. Basic 2PL guarantees conflict serializability but can suffer from deadlocks and cascading aborts.

---

# 60. Interview Question: Does 2PL prevent deadlocks?

### Answer

No.

Basic 2PL can still result in deadlocks because transactions can hold locks while waiting for other locks.

Example:

```text
T1 holds A → waits for B
T2 holds B → waits for A
```

Possible solutions include:

```text
Timeout
Wait-for Graph
Timestamp protocols
Conservative 2PL
Consistent lock ordering
```

---

# 61. Interview Question: How does Conservative 2PL prevent deadlock?

### Answer

Conservative 2PL requires a transaction to acquire all required locks before it begins execution.

Therefore a transaction does not hold some locks while waiting for additional locks.

This eliminates the classic hold-and-wait condition and therefore prevents deadlocks caused by that pattern.

---

# 62. Interview Question: What is Cascading Abort?

### Answer

A cascading abort happens when one transaction aborts and causes other transactions that read its uncommitted data to also abort.

Example:

```text
T1 writes A
T2 reads A
T1 aborts
    ↓
T2 may need to abort
```

Strict 2PL prevents this by keeping exclusive locks until commit or abort.

---

# 63. Interview Question: Strict vs Rigorous 2PL?

### Answer

> Strict 2PL holds all exclusive locks until commit or abort, while Rigorous 2PL holds both shared and exclusive locks until commit or abort. Rigorous 2PL is therefore stronger.

Remember:

```text
Strict:
X locks → until commit

Rigorous:
S + X locks → until commit
```

---

# 64. Interview Question: Basic 2PL vs Strict 2PL?

### Answer

Basic 2PL only enforces the growing and shrinking phases.

It can release locks before commit.

Strict 2PL additionally requires exclusive locks to remain held until commit or abort.

Therefore Strict 2PL prevents other transactions from reading/writing data modified by an uncommitted transaction, avoiding cascading aborts.

---

# 65. Interview Question: What is a Wait-For Graph?

### Answer

A Wait-For Graph represents dependencies between transactions.

If:

```text
T1 waits for a lock held by T2
```

we create:

```text
T1 → T2
```

A cycle indicates a deadlock.

Example:

```text
T1 → T2 → T3 → T1
```

Then the system can abort one transaction to break the cycle.

---

# 66. Interview Question: How would you prevent deadlocks?

A good interview answer:

> First, I would try to acquire locks in a deterministic order to prevent circular wait. If that is not possible, I could use deadlock detection with a wait-for graph, or use timeout-based recovery. Timestamp protocols such as wait-die or wound-wait are also options. For transactions where all required resources are known beforehand, Conservative 2PL can prevent deadlocks by acquiring all locks before execution.

---

# 67. Interview Question: Why not always use Conservative 2PL?

Because:

```text
All required locks
```

must be known before execution.

In many real applications:

```text
Query
 ↓
Discover data
 ↓
Need another row
 ↓
Discover more data
```

The complete lock set may not be known upfront.

It also may reduce concurrency because transactions acquire locks earlier than necessary.

---

# 68. Interview Question: Why not always use Strict 2PL?

Because holding locks until commit can cause:

```text
Blocking
Contention
Deadlocks
Lower concurrency
Higher latency
```

For some workloads, MVCC or optimistic concurrency can provide better read/write concurrency.

---

# 69. Scenario: Seat Booking

Suppose:

```text
Seat A1 = AVAILABLE
```

Two users:

```text
User A → Book A1
User B → Book A1
```

With pessimistic locking:

```sql
BEGIN;

SELECT *
FROM seats
WHERE seat_id = 'A1'
FOR UPDATE;

UPDATE seats
SET status = 'BOOKED'
WHERE seat_id = 'A1';

COMMIT;
```

Conceptually:

```text
User A
   |
   v
Lock A1
   |
   v
Book A1
   |
   v
Commit
   |
   v
Unlock

User B
   |
   v
Wait
```

Then User B sees:

```text
BOOKED
```

and fails.

---

# 70. Scenario: Inventory

Initial:

```text
quantity = 1
```

Two requests arrive simultaneously.

Prefer a database-level atomic operation when possible:

```sql
UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 100
  AND quantity > 0;
```

Then:

```text
affected rows = 1
    ↓
Success

affected rows = 0
    ↓
Out of stock
```

This can be simpler than holding a lock across a long application workflow.

---

# 71. Scenario: Bank Transfer

Requirements:

```text
Debit A
Credit B
```

Use:

```text
Transaction
+
Appropriate locking/isolation
+
Consistent lock ordering
```

Example lock order:

```text
min(accountA, accountB)
        ↓
max(accountA, accountB)
```

This greatly reduces deadlock risk.

---

# 72. Scenario: High-Contention Product

Suppose:

```text
Product X
Inventory = 1

100,000 concurrent requests
```

Using a lock may cause:

```text
1 request → execute
99,999 → wait
```

Possible architecture:

```text
Requests
    |
    v
Queue
    |
    v
Inventory Worker
    |
    v
Database
```

Or use an atomic conditional update.

The correct solution depends on:

```text
Traffic
Contention
Latency requirement
Consistency requirement
Failure model
```

---

# 73. Common Mistakes in Interviews

### Mistake 1

Saying:

```text
2PL = Two transactions execute one after another
```

Wrong.

2PL allows concurrent transactions.

It controls lock acquisition/release.

---

### Mistake 2

Saying:

```text
2PL prevents deadlocks.
```

Wrong.

Basic 2PL can cause deadlocks.

---

### Mistake 3

Confusing:

```text
Strict 2PL
```

with:

```text
Rigorous 2PL
```

Remember:

```text
Strict → X locks until commit

Rigorous → S + X locks until commit
```

---

### Mistake 4

Thinking:

```text
Transaction = Lock
```

Wrong.

Transaction is a unit of work.

Lock is a concurrency-control mechanism.

---

### Mistake 5

Ignoring lock ordering.

For example:

```text
T1: A → B
T2: B → A
```

can cause deadlock.

---

### Mistake 6

Holding locks during external API calls.

Avoid:

```text
DB Lock
 ↓
HTTP API
 ↓
5 seconds
 ↓
DB Commit
```

Keep lock duration short.

---

# 74. 2PL Comparison Table

| Protocol | Lock Acquisition | Lock Release | Deadlock | Cascading Abort |
|---|---|---|---|---|
| Basic 2PL | Growing phase | Shrinking phase | Possible | Possible |
| Conservative 2PL | All locks before execution | After execution | Prevents classic hold-and-wait | Depends on release/commit behavior |
| Strict 2PL | Growing phase | X locks at commit/abort | Possible | Prevented |
| Rigorous 2PL | Growing phase | All locks at commit/abort | Possible | Prevented |

---

# 75. Complete 2PL Mental Model

```text
                  2PL
                   |
          +--------+--------+
          |                 |
      Growing           Shrinking
          |                 |
     Acquire locks      Release locks
     Upgrade locks      NO new locks
          |                 |
          +--------+--------+
                   |
                   v
             Serializable
               Schedule
```

But:

```text
Basic 2PL
   |
   +--> Deadlocks
   |
   +--> Cascading Abort
```

Solutions:

```text
Deadlock
   |
   +--> Timeout
   +--> WFG
   +--> Timestamp
   +--> Conservative 2PL
   +--> Lock Ordering

Cascading Abort
   |
   +--> Strict 2PL
   +--> Rigorous 2PL
```

---

# 76. Quick Revision

```text
2PL
↓
Two-Phase Locking

Growing Phase
↓
Acquire locks
↓
No lock release

Shrinking Phase
↓
Release locks
↓
No new locks

Basic 2PL
↓
Conflict Serializable
↓
But Deadlock possible
↓
Cascading Abort possible

Conservative 2PL
↓
Acquire ALL locks before execution
↓
Prevents classic deadlock

Strict 2PL
↓
Hold X locks until Commit/Abort
↓
Prevents Cascading Abort

Rigorous 2PL
↓
Hold S + X locks until Commit/Abort

WFG
↓
Wait-For Graph
↓
Cycle = Deadlock

Timeout
↓
Abort transaction after waiting too long

Timestamp
↓
Wait-Die / Wound-Wait

Lock Ordering
↓
Acquire resources in deterministic order
↓
Avoid circular wait
```

---

# 77. One-Minute Interview Answer

> Two-Phase Locking, or 2PL, is a database concurrency-control protocol used to guarantee conflict serializability. A transaction has a growing phase where it acquires locks and a shrinking phase where it releases locks. Once it releases its first lock, it cannot acquire any new lock.
>
> Basic 2PL guarantees conflict serializability but can suffer from deadlocks and cascading aborts.
>
> Deadlocks can be handled using timeout, wait-for graphs, timestamp-based protocols such as wait-die and wound-wait, consistent lock ordering, or Conservative 2PL.
>
> Conservative 2PL acquires all required locks before execution, which prevents the classic hold-and-wait deadlock pattern.
>
> For cascading aborts, Strict 2PL holds exclusive locks until commit or abort, while Rigorous 2PL holds both shared and exclusive locks until commit or abort.
>
> In system design, I would also consider whether locking is really necessary. For simple state transitions, an atomic conditional database update may be simpler. For low-contention workloads, optimistic concurrency can be preferable, while highly contended resources may require pessimistic locking or serialization.

---

# 78. Final Cheat Sheet

```text
                    2PL
                     |
          +----------+----------+
          |                     |
       Growing               Shrinking
          |                     |
     Acquire locks         Release locks
     Upgrade locks         No new locks
          |
          v
   Conflict Serializable
          |
          +----------------------------+
          |                            |
       Problems                    Variants
          |                            |
     +----+----+              +--------+--------+
     |         |              |        |        |
 Deadlock   Cascading      Basic   Strict   Rigorous
             Abort          |        |        |
     |         |             |        |        |
 Timeout    Strict          X locks  X locks  S+X locks
 WFG        Rigorous        flexible until   until
 Timestamp                  release commit  commit
 Conservative
 Lock Ordering
```

---

# 79. Golden Rules

```text
1. 2PL = Growing + Shrinking phases.

2. After the first unlock, no new lock can be acquired.

3. Basic 2PL guarantees conflict serializability.

4. Basic 2PL does NOT prevent deadlocks.

5. Timeout can recover from long waits but may abort non-deadlocked transactions.

6. Wait-For Graph detects cycles representing deadlocks.

7. Conservative 2PL acquires all required locks before execution.

8. Strict 2PL keeps X locks until commit/abort.

9. Rigorous 2PL keeps S + X locks until commit/abort.

10. Strict 2PL prevents cascading aborts caused by uncommitted writes.

11. Consistent lock ordering is one of the simplest practical deadlock-prevention techniques.

12. Keep transactions and lock durations short.

13. Never casually hold database locks while waiting for external services.

14. For simple operations, prefer atomic database conditions when possible.

15. In distributed systems, always consider crashes, retries, timeouts,
    stale ownership, and network failures.
```

---

# 80. Final Mental Model for System Design Interviews

When asked about concurrency:

```text
Multiple Requests
       |
       v
Shared Resource
       |
       v
Race Condition?
       |
       v
Need Concurrency Control
       |
       +-----------------------------+
       |                             |
       v                             v
 Database-level                  Application-level
       |                             |
       +--> Transaction              +--> Optimistic Lock
       +--> Lock                    +--> Idempotency
       +--> Isolation               +--> Atomic Operation
       +--> MVCC
       +--> 2PL
       |
       v
If Locking
       |
       +--> Basic 2PL
       |
       +--> Strict 2PL
       |
       +--> Rigorous 2PL
       |
       v
Check Failure Modes
       |
       +--> Deadlock
       +--> Cascading Abort
       +--> Timeout
       +--> Retry
       +--> Server Crash
       +--> Network Failure
```

The key interview takeaway:

> **2PL controls concurrent database access through lock acquisition and release rules. Basic 2PL gives conflict serializability, but it can have deadlocks and cascading aborts. Conservative 2PL addresses deadlocks by acquiring all locks upfront, while Strict and Rigorous 2PL address cascading-abort problems by holding locks until commit.**