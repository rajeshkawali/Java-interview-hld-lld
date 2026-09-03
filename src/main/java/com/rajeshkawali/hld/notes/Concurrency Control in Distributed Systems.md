# System Design: Concurrency Control in Distributed Systems
## Optimistic & Pessimistic Concurrency Control

---

# 1. Introduction

## What is Concurrency?

Concurrency means multiple requests/threads/processes are executing at the same time or overlapping in execution.

Example:

```text
User A ──> Update Account
User B ──> Update Account
User C ──> Read Account
```

All three operations may happen concurrently.

In a distributed system:

```text
Request 1 ──> Server A ──> DB
Request 2 ──> Server B ──> DB
Request 3 ──> Server C ──> DB
```

The challenge is:

> How do we make sure concurrent operations do not corrupt data?

---

# 2. Problem Statement

Consider a bank account:

```text
Balance = $100
```

Two users withdraw money simultaneously.

```text
User A wants to withdraw $80
User B wants to withdraw $50
```

Both servers read:

```text
Balance = $100
```

Then:

```text
Server A:
100 - 80 = 20

Server B:
100 - 50 = 50
```

If both updates are allowed:

```text
Final Balance = $50
```

But logically:

```text
$80 + $50 = $130
```

The account only had:

```text
$100
```

Therefore, the system must control concurrent operations.

---

# 3. Race Condition

A race condition occurs when the result depends on the timing/order of concurrent operations.

Example:

```text
Initial value = 100

Thread A:
read 100

Thread B:
read 100

Thread A:
write 120

Thread B:
write 150
```

Final value:

```text
150
```

But if both updates were supposed to be preserved:

```text
170
```

This is a concurrency problem.

---

# 4. Lost Update

One of the most common concurrency problems is the **Lost Update**.

Example:

```text
Initial balance = 100
```

Two requests:

```text
Request A: +20
Request B: +50
```

Execution:

```text
A reads 100
B reads 100

A calculates 120
B calculates 150

A writes 120
B writes 150
```

Final:

```text
150
```

A's update was lost.

Expected:

```text
170
```

---

# 5. Synchronized Keyword

In Java, `synchronized` can protect a critical section.

Example:

```java
public synchronized void withdraw(int amount) {
    balance = balance - amount;
}
```

Only one thread can execute the synchronized method on the same object monitor at a time.

Conceptually:

```text
Thread A
   |
   | acquire lock
   v
[ Critical Section ]
   |
   | release lock
   v

Thread B
   |
   | acquire lock
   v
[ Critical Section ]
```

## Why is this useful?

It prevents multiple threads inside the same JVM from modifying shared state simultaneously.

---

# 6. Why synchronized is NOT enough in Distributed Systems

Suppose we have:

```text
Server A
Server B
Server C
```

Each server has its own JVM.

If we use:

```java
synchronized
```

the lock exists only inside that JVM/process.

Therefore:

```text
Server A
    synchronized lock A

Server B
    synchronized lock B

Server C
    synchronized lock C
```

They do NOT share the same lock.

Two requests can still execute concurrently:

```text
Request 1 ──> Server A ──> Lock A
Request 2 ──> Server B ──> Lock B
```

Both can access the same database record.

Therefore distributed systems need mechanisms such as:

- Database locks
- Transactions
- Optimistic concurrency control
- Pessimistic concurrency control
- Distributed locks
- Atomic operations
- Compare-and-set
- Versioning
- Idempotency
- Fencing tokens

---

# 7. What is a Transaction?

A transaction is a logical unit of work consisting of one or more database operations.

Example:

```text
Transfer $100 from A to B
```

We need:

```text
A = A - 100
B = B + 100
```

Both operations should succeed together.

Or neither should happen.

```text
BEGIN TRANSACTION

A = A - 100
B = B + 100

COMMIT
```

If something fails:

```text
ROLLBACK
```

---

# 8. ACID Properties

Transactions generally provide ACID properties.

## A - Atomicity

All operations succeed or all fail.

```text
A - $100
B + $100
```

Cannot have:

```text
A - $100
B unchanged
```

---

## C - Consistency

The transaction should move the database from one valid state to another valid state.

Example:

```text
Balance cannot become negative
```

if the business rule prohibits negative balances.

---

## I - Isolation

Concurrent transactions should not interfere with each other in an unsafe way.

---

## D - Durability

Once committed, the data should survive crashes.

---

# 9. DB Locking

Database locking prevents conflicting transactions from modifying/accessing data incorrectly.

Example:

```text
Transaction A
      |
      | acquire lock
      v
  Row X
      |
      | update
      |
      | commit
      v
release lock
```

Transaction B must wait if it needs an incompatible lock.

---

# 10. Shared Lock

A shared lock is generally used for reading.

Notation:

```text
S = Shared Lock
```

Multiple transactions can usually hold shared locks simultaneously.

Example:

```text
Transaction A ──> READ Row X
Transaction B ──> READ Row X
```

Both can read.

```text
       Row X
       /   \
      /     \
    S Lock  S Lock
      A       B
```

But an exclusive modification normally cannot proceed while conflicting shared locks are held.

---

# 11. Exclusive Lock

An exclusive lock is generally used when modifying data.

Notation:

```text
X = Exclusive Lock
```

Example:

```text
Transaction A ──> UPDATE Row X
```

Transaction A obtains:

```text
X Lock
```

Other conflicting operations must wait.

```text
Transaction A
      |
      v
  X Lock
      |
      v
    Row X

Transaction B
      |
      v
    WAIT
```

---

# 12. Shared vs Exclusive Lock

| Lock | Purpose | Multiple holders? |
|---|---|---|
| Shared (S) | Read | Usually yes |
| Exclusive (X) | Write | No conflicting holders |

Compatibility concept:

```text
          Existing
         S       X

New S    YES     NO
New X    NO      NO
```

Exact locking behavior depends on the database engine and isolation level.

---

# 13. Lock Granularity

Locks can exist at different levels.

Common levels:

```text
Database
   ↓
Table
   ↓
Page
   ↓
Row
```

## Row Lock

Locks a specific row.

```text
User A ──> Row 101
```

Other rows can still be accessed.

Good concurrency.

---

## Table Lock

Locks a whole table.

```text
Table Users
[Row1]
[Row2]
[Row3]
[Row4]
```

Potentially blocks more operations.

---

## Trade-off

Fine-grained lock:

```text
More concurrency
More lock-management overhead
```

Coarse-grained lock:

```text
Less concurrency
Simpler lock management
```

---

# 14. Isolation Property

Isolation determines how much one transaction is protected from concurrent transactions.

Main SQL isolation levels:

```text
READ UNCOMMITTED
       ↓
READ COMMITTED
       ↓
REPEATABLE READ
       ↓
SERIALIZABLE
```

Generally, moving upward gives stronger isolation but can reduce concurrency/performance.

---

# 15. Dirty Read

A dirty read happens when a transaction reads data written by another transaction that has not committed.

Example:

```text
Initial balance = 100

Transaction A:
UPDATE balance = 50
(not committed)

Transaction B:
READ balance
=> 50

Transaction A:
ROLLBACK
```

Actual final balance:

```text
100
```

But B temporarily read:

```text
50
```

That is a dirty read.

---

# 16. Non-Repeatable Read

A transaction reads the same row twice and gets different values.

Example:

```text
Initial balance = 100
```

Transaction A:

```text
READ balance
=> 100
```

Transaction B:

```text
UPDATE balance = 200
COMMIT
```

Transaction A:

```text
READ balance again
=> 200
```

Same transaction, same row, different value.

This is a non-repeatable read.

---

# 17. Phantom Read

A phantom read occurs when repeating a range query returns a different set of rows because another transaction inserted/deleted matching rows.

Example:

Transaction A:

```sql
SELECT *
FROM orders
WHERE amount > 100;
```

Result:

```text
5 rows
```

Transaction B inserts another matching order:

```text
INSERT order(amount = 200);
COMMIT;
```

Transaction A runs the same query again:

```sql
SELECT *
FROM orders
WHERE amount > 100;
```

Now:

```text
6 rows
```

The new row is a phantom row.

---

# 18. READ UNCOMMITTED

Lowest isolation level.

Transactions may observe uncommitted changes.

Potential problems:

```text
Dirty Read
Non-repeatable Read
Phantom Read
```

Advantage:

```text
High concurrency
Potentially fewer blocking effects
```

Disadvantage:

```text
Weak consistency
```

Use carefully.

---

# 19. READ COMMITTED

A transaction generally sees only committed data.

Prevents:

```text
Dirty Read
```

But depending on database behavior, the same query/row can change between reads.

Potentially allows:

```text
Non-repeatable Read
Phantom Read
```

This is a common practical default in many systems.

---

# 20. REPEATABLE READ

Provides stronger guarantees for repeated reads than READ COMMITTED.

A transaction generally gets a stable view of rows it has read, though exact phantom-read behavior depends on the database implementation.

Many databases implement this using:

```text
MVCC
```

or a combination of locking/versioning.

---

# 21. SERIALIZABLE

Strongest standard SQL isolation level.

Goal:

> Concurrent transactions should behave as if executed serially.

Example:

```text
Transaction A
Transaction B
```

Conceptually equivalent to:

```text
A
↓
B
```

or:

```text
B
↓
A
```

instead of unsafe interleaving.

Advantage:

```text
Strong correctness
```

Disadvantage:

```text
More blocking/conflicts
Lower concurrency
Potentially lower throughput
```

---

# 22. Isolation Level Summary

| Isolation | Dirty Read | Non-repeatable Read | Phantom Read* |
|---|---|---|---|
| READ UNCOMMITTED | Possible | Possible | Possible |
| READ COMMITTED | Prevented | Possible | Possible |
| REPEATABLE READ | Prevented | Prevented | Depends on DB |
| SERIALIZABLE | Prevented | Prevented | Prevented |

`*` Exact behavior can vary by database implementation.

---

# 23. MVCC

MVCC = Multi-Version Concurrency Control.

Instead of making readers always wait for writers, the database maintains multiple versions of data.

Conceptually:

```text
Row X

Version 1
value = 100

Version 2
value = 150
```

A transaction can read the appropriate version based on its snapshot.

This can improve read/write concurrency.

Commonly associated with databases such as:

```text
PostgreSQL
MySQL/InnoDB
Oracle
```

Implementation details differ.

---

# 24. Optimistic Concurrency Control

Optimistic concurrency assumes:

> Conflicts are relatively rare.

Instead of locking the data for the entire operation, we allow concurrent work and check for conflicts before committing.

Basic flow:

```text
READ
  ↓
DO WORK
  ↓
CHECK VERSION
  ↓
IF SAME → UPDATE
IF CHANGED → CONFLICT
```

---

# 25. Optimistic Locking Using Version Number

Suppose:

```text
Product ID = 101
Price = 100
Version = 5
```

User A reads:

```text
Price = 100
Version = 5
```

User B also reads:

```text
Price = 100
Version = 5
```

User A updates:

```sql
UPDATE product
SET price = 120,
    version = version + 1
WHERE id = 101
  AND version = 5;
```

Success.

Now:

```text
Price = 120
Version = 6
```

User B tries:

```sql
UPDATE product
SET price = 130,
    version = version + 1
WHERE id = 101
  AND version = 5;
```

No row is updated because:

```text
Current version = 6
Expected version = 5
```

Therefore:

```text
CONFLICT
```

---

# 26. Compare-and-Set (CAS)

CAS means:

```text
Update value
ONLY IF
current value == expected value
```

Conceptually:

```text
if version == expectedVersion:
    update()
else:
    conflict
```

Database example:

```sql
UPDATE inventory
SET quantity = quantity - 1,
    version = version + 1
WHERE product_id = 101
  AND version = 10
  AND quantity > 0;
```

If affected rows = 1:

```text
SUCCESS
```

If affected rows = 0:

```text
CONFLICT / OUT OF STOCK / VERSION CHANGED
```

---

# 27. Advantages of Optimistic Concurrency

Good when:

```text
Conflicts are rare
Reads are frequent
Long processing time exists
```

Advantages:

- Less locking
- Better concurrency
- No long-held database lock
- Good for read-heavy systems
- Can scale well

---

# 28. Disadvantages of Optimistic Concurrency

If conflicts are frequent:

```text
Request
   ↓
Read
   ↓
Long processing
   ↓
Conflict
   ↓
Retry
```

Repeated retries waste work.

Problems can include:

- High retry rate
- Increased latency
- Starvation under heavy contention
- More application complexity

---

# 29. Pessimistic Concurrency Control

Pessimistic concurrency assumes:

> Conflicts are likely.

Therefore, acquire a lock before performing the critical operation.

Flow:

```text
Acquire Lock
     ↓
Read Data
     ↓
Modify Data
     ↓
Commit
     ↓
Release Lock
```

Example:

```sql
SELECT *
FROM account
WHERE id = 101
FOR UPDATE;
```

The transaction can then update the row while holding the appropriate lock.

---

# 30. Optimistic vs Pessimistic

| Feature | Optimistic | Pessimistic |
|---|---|---|
| Assumption | Conflicts are rare | Conflicts are likely |
| Lock before work | Usually no | Usually yes |
| Conflict detection | At commit/update | Prevented/serialized by locking |
| Throughput | Good when conflicts are low | Good when contention is controlled |
| Retries | More likely | Usually fewer |
| Blocking | Low | Higher |
| Best for | Read-heavy, low contention | High contention |
| Complexity | Conflict handling | Lock management |

---

# 31. Example: Ticket Booking

Suppose:

```text
Ticket ID = 100
Available = YES
```

Two users click:

```text
User A → Book
User B → Book
```

We cannot allow:

```text
A → SUCCESS
B → SUCCESS
```

for the same single ticket.

---

## Option 1: Pessimistic Lock

```sql
BEGIN;

SELECT *
FROM tickets
WHERE id = 100
FOR UPDATE;

UPDATE tickets
SET status = 'BOOKED'
WHERE id = 100;

COMMIT;
```

Second transaction waits for the lock.

---

## Option 2: Optimistic Lock

```text
Ticket:
status = AVAILABLE
version = 5
```

Update:

```sql
UPDATE tickets
SET status = 'BOOKED',
    version = version + 1
WHERE id = 100
  AND status = 'AVAILABLE'
  AND version = 5;
```

Only one request succeeds.

---

# 32. Inventory Example

Initial:

```text
Inventory = 1
```

Two users purchase simultaneously.

Bad approach:

```text
A reads 1
B reads 1

A → 0
B → 0
```

Both think they successfully purchased.

Correct approach:

```sql
UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 101
  AND quantity > 0;
```

Then check:

```text
affected rows = 1
```

Success.

```text
affected rows = 0
```

Out of stock / conflict.

This is often better than implementing locking entirely in application code.

---

# 33. Atomic Database Operations

Whenever possible, use an atomic database operation.

Instead of:

```text
READ quantity
↓
Application calculates quantity - 1
↓
WRITE quantity
```

Prefer:

```sql
UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 101
  AND quantity > 0;
```

The database can perform the check and update as one atomic operation.

---

# 34. Distributed Concurrency Control

In a distributed system:

```text
Client
  |
Load Balancer
  |
  +-------- Server A
  |
  +-------- Server B
  |
  +-------- Server C
             |
             v
           Database
```

The same resource can be accessed through different servers.

Therefore:

```text
Application-level synchronized
```

is not sufficient.

Common techniques:

1. Database transactions
2. Database locks
3. Optimistic locking
4. MVCC
5. Atomic conditional updates
6. Distributed locks
7. Leases
8. Fencing tokens
9. Idempotency
10. Unique constraints
11. Queue-based serialization

---

# 35. Distributed Lock

A distributed lock allows multiple servers/processes to coordinate access to a shared resource.

Conceptually:

```text
Server A ──┐
           |
Server B ──┼──> Distributed Lock
           |
Server C ──┘
```

Only one owner should hold the lock for a given resource at a time.

Common technologies/patterns include:

```text
Redis
ZooKeeper
etcd
Database-based locks
```

---

# 36. Important Problem With Distributed Locks

Consider:

```text
Server A gets lock
```

Then:

```text
Server A becomes slow
```

or:

```text
Server A loses network connectivity
```

The lock may expire.

Now:

```text
Server B gets the lock
```

But Server A may still continue executing because it did not realize its lease expired.

Now:

```text
A thinks it owns resource
B thinks it owns resource
```

This is dangerous.

---

# 37. Lease

A lease is a lock granted only for a limited period.

Example:

```text
Server A
   |
   | acquire lease
   | TTL = 10 sec
   v
Resource
```

If A does not renew:

```text
Lease expires
```

Another server may acquire it.

But lease expiration alone does not completely solve stale-owner problems.

---

# 38. Fencing Token

Fencing tokens protect against stale lock holders.

Suppose:

```text
Server A gets token = 10
```

Then its lease expires.

Server B gets:

```text
token = 11
```

Now the downstream resource accepts only operations with the latest valid token.

```text
A → token 10 → REJECT
B → token 11 → ACCEPT
```

This prevents an old/stale process from continuing to modify the resource.

This is an important advanced distributed-systems interview concept.

---

# 39. Idempotency

Concurrency and retries are closely related.

Suppose:

```text
Client → POST /payment
```

Server processes payment successfully.

But response is lost:

```text
Server → X → Client
```

Client retries.

Now we may have:

```text
Payment #1
Payment #2
```

Use an idempotency key:

```text
Idempotency-Key = abc123
```

Server stores the result associated with that key.

Retry:

```text
abc123
```

returns the existing result instead of creating another payment.

---

# 40. Concurrency vs Idempotency

These solve different problems.

## Concurrency Control

Prevents simultaneous operations from producing invalid state.

```text
A + B execute at same time
```

## Idempotency

Prevents repeated requests from producing duplicate effects.

```text
Same request sent multiple times
```

Real systems often need both.

---

# 41. Unique Constraints

Database constraints can also provide concurrency protection.

Example:

```sql
CREATE UNIQUE INDEX unique_booking
ON bookings(user_id, event_id);
```

Two concurrent requests attempt:

```text
User 10 → Event 100
User 10 → Event 100
```

Only one can succeed.

The database enforces the invariant.

---

# 42. Deadlock

A deadlock occurs when transactions wait for each other forever.

Example:

```text
Transaction A:
Lock Row 1
WAIT for Row 2

Transaction B:
Lock Row 2
WAIT for Row 1
```

Diagram:

```text
A owns Row 1
A waits for Row 2
        ↑
        |
        |
B owns Row 2
B waits for Row 1
```

Neither can continue.

---

# 43. Deadlock Prevention

Common strategies:

### 1. Consistent Lock Ordering

Always lock:

```text
Row 1 → Row 2
```

Never:

```text
Transaction A: Row 1 → Row 2
Transaction B: Row 2 → Row 1
```

---

### 2. Short Transactions

Keep transactions short.

Avoid:

```text
BEGIN
↓
Long API call
↓
Complex computation
↓
UPDATE
↓
COMMIT
```

Prefer:

```text
BEGIN
↓
Small DB operations
↓
COMMIT
```

---

### 3. Timeout

If waiting too long:

```text
Abort transaction
```

and retry if appropriate.

---

### 4. Deadlock Detection

Some databases detect deadlocks and abort one transaction.

---

# 44. Hot Resource / Hot Key

Concurrency becomes especially difficult when many requests target the same resource.

Example:

```text
100,000 users
      |
      v
Same product
      |
      v
Inventory = 1
```

This creates high contention.

Possible approaches:

- Atomic DB update
- Optimistic locking
- Pessimistic locking
- Queue-based serialization
- Partitioning workload
- Sharding where applicable
- Caching for reads
- Rate limiting
- Specialized inventory reservation design

---

# 45. Queue-Based Serialization

Instead of allowing thousands of requests to update the same resource concurrently:

```text
Requests
   |
   v
Queue
   |
   v
Single/controlled consumers
   |
   v
Database
```

For highly contended operations, serialization can simplify correctness.

Trade-off:

```text
Less concurrency
More predictable correctness
```

---

# 46. Retry Strategy

Optimistic concurrency often requires retries.

Example:

```text
Read version 10
      ↓
Update
      ↓
Conflict
      ↓
Read version 11
      ↓
Retry
```

Use:

```text
Exponential Backoff
+
Jitter
+
Maximum Retry Limit
```

Avoid infinite retries.

Otherwise:

```text
Conflict
 ↓
Retry
 ↓
Conflict
 ↓
Retry
 ↓
Huge traffic
 ↓
System overload
```

---

# 47. Where Should Concurrency Control Live?

A robust system can have multiple layers.

```text
Client
  |
  v
API
  |
  +--> Idempotency
  |
  v
Application
  |
  +--> Validation
  |
  v
Database
  |
  +--> Transaction
  +--> Lock
  +--> Constraint
  +--> Atomic Update
  |
  v
Storage
```

Do not depend on only one layer for critical correctness.

---

# 48. Choosing the Right Technique

## Use Optimistic Concurrency when:

```text
Conflicts are rare
Reads are frequent
```

Example:

```text
Profile editing
Document editing
Product metadata
```

---

## Use Pessimistic Locking when:

```text
Conflicts are frequent
Resource is highly contended
Incorrect concurrent updates are expensive
```

Example:

```text
Limited inventory
Financial balance
Single-seat booking
```

---

## Use Atomic DB Update when:

The operation can be expressed as one conditional database operation.

Example:

```sql
UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 10
  AND quantity > 0;
```

---

## Use Distributed Lock when:

Multiple independent processes must coordinate around a resource and the database cannot naturally enforce the required coordination.

Be careful about:

```text
Expiration
Network partitions
Process pauses
Stale owners
Fencing
```

---

# 49. Optimistic vs Pessimistic vs Distributed Lock

| Technique | Best For |
|---|---|
| Optimistic Lock | Low-conflict updates |
| Pessimistic Lock | High-conflict updates |
| Atomic DB Update | Simple conditional state changes |
| Distributed Lock | Cross-process coordination |
| Queue | High-contention serialized workflows |
| Idempotency | Duplicate/retry protection |

---

# 50. Important Interview Scenario

## Question

Two users try to buy the last product simultaneously. How will you prevent overselling?

### Good Answer

I would first try to enforce the invariant at the database level.

For example:

```sql
UPDATE inventory
SET quantity = quantity - 1
WHERE product_id = 101
  AND quantity > 0;
```

Then check the affected row count.

```text
1 row updated → purchase can proceed
0 rows updated → out of stock/conflict
```

For more complex workflows, I may use:

```text
Transaction
+
Optimistic/Pessimistic Lock
+
Idempotency
```

If the resource is extremely hot, I may consider queue-based serialization.

---

# 51. Important Interview Scenario

## Question

Why can't we simply use Java synchronized?

### Answer

`synchronized` protects a critical section only within the same JVM/process.

In a distributed system:

```text
Server A → Lock A
Server B → Lock B
```

These are different locks.

Therefore multiple servers can still modify the same database record concurrently.

For distributed concurrency, coordination should happen through shared infrastructure such as:

```text
Database
Distributed lock service
Queue
Atomic storage operation
```

---

# 52. Important Interview Scenario

## Question

Optimistic vs pessimistic locking?

### Answer

Optimistic locking assumes conflicts are rare.

We don't hold a lock during the entire operation. Instead, we use a version number or timestamp and verify it during update.

Pessimistic locking assumes conflicts are likely, so we acquire a lock before modifying the resource.

Optimistic locking gives better concurrency when conflicts are rare, while pessimistic locking can be better for highly contended resources.

---

# 53. Important Interview Scenario

## Question

What is the difference between transaction and lock?

### Answer

A transaction defines a logical unit of database work.

A lock is one mechanism used to control concurrent access to data.

For example:

```text
Transaction
    |
    +--> SELECT
    |
    +--> UPDATE
    |
    +--> COMMIT
```

The database may use locks, MVCC, or other mechanisms internally depending on the database and isolation level.

---

# 54. Important Interview Scenario

## Question

What is the difference between isolation and locking?

### Answer

Isolation is a transaction-level correctness guarantee describing what one transaction can observe from concurrent transactions.

Locking is one implementation/control mechanism used to achieve certain concurrency guarantees.

Isolation levels:

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

Locking:

```text
Shared Lock
Exclusive Lock
```

They are related but not the same thing.

---

# 55. Important Interview Scenario

## Question

Why not always use SERIALIZABLE?

### Answer

Because stronger isolation usually comes with a concurrency/performance cost.

With high traffic:

```text
More serialization
      ↓
More blocking/conflicts
      ↓
Lower throughput
      ↓
Higher latency
```

Therefore we should choose the weakest isolation level that still satisfies the application's correctness requirements.

---

# 56. Important Interview Scenario

## Question

Why not always use pessimistic locking?

### Answer

Locks can create:

```text
Blocking
Deadlocks
Long wait times
Reduced throughput
```

If conflicts are rare, optimistic concurrency can provide better performance because most requests don't need to wait for locks.

---

# 57. Important Interview Scenario

## Question

Why not always use optimistic locking?

### Answer

If contention is extremely high:

```text
Request
 ↓
Read
 ↓
Work
 ↓
Conflict
 ↓
Retry
```

Many requests may repeatedly conflict.

This causes:

```text
Retries
CPU usage
DB load
Latency
```

For highly contended resources, pessimistic locking, atomic operations, or serialization may be more appropriate.

---

# 58. End-to-End Example

Consider:

```text
E-commerce checkout
```

Architecture:

```text
Client
   |
   v
Load Balancer
   |
   v
Order Service
   |
   +----> Idempotency Store
   |
   +----> Inventory Service
   |
   v
Database
```

Request:

```text
POST /orders
Idempotency-Key: abc123
```

Flow:

```text
1. Validate request
       ↓
2. Check idempotency key
       ↓
3. Start transaction
       ↓
4. Atomically reserve/decrement inventory
       ↓
5. Create order
       ↓
6. Commit
       ↓
7. Store/return result
```

If two users attempt to buy the last item:

```text
User A ──┐
         ├──> Atomic inventory update
User B ──┘
```

Only one should successfully decrement the inventory.

---

# 59. Failure Cases You Should Think About

In distributed concurrency questions, always consider:

### Server crash

```text
Server owns operation
↓
Server crashes
```

What happens to the lock/transaction?

---

### Network timeout

```text
Client → Server
       X
    timeout
```

Did the operation succeed or fail?

This is where idempotency becomes important.

---

### Retry

```text
Request
 ↓
Timeout
 ↓
Retry
```

Can the operation safely execute twice?

---

### Lock expiration

```text
Server A gets lock
↓
A pauses
↓
Lock expires
↓
Server B gets lock
↓
A resumes
```

Can A still modify the resource?

Fencing tokens can help.

---

### Deadlock

```text
A → Lock X → Wait Y
B → Lock Y → Wait X
```

How does the system recover?

---

# 60. Concurrency Control Mental Model

Think in this order:

```text
Multiple requests
       ↓
Shared resource
       ↓
Possible race condition
       ↓
What invariant must remain true?
       ↓
Can DB enforce it atomically?
       ↓
If not, optimistic or pessimistic?
       ↓
If cross-process coordination is needed?
       ↓
Distributed lock / queue / coordination service
       ↓
What happens during failure?
       ↓
Retry + idempotency + fencing
```

---

# 61. Quick Revision Cheat Sheet

```text
Concurrency
    ↓
Multiple operations overlap

Race Condition
    ↓
Result depends on execution timing

Lost Update
    ↓
One concurrent update overwrites another

synchronized
    ↓
Protects threads within one JVM

Transaction
    ↓
Logical unit of database work

ACID
    ↓
Atomicity
Consistency
Isolation
Durability

Shared Lock
    ↓
Read-oriented lock

Exclusive Lock
    ↓
Write-oriented lock

Isolation Levels
    ↓
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE

Dirty Read
    ↓
Read uncommitted data

Non-repeatable Read
    ↓
Same row gives different values

Phantom Read
    ↓
Same range query gives different rows

MVCC
    ↓
Multiple versions of data

Optimistic Lock
    ↓
Check version before update

Pessimistic Lock
    ↓
Lock before modifying

CAS
    ↓
Update only if expected value/version matches

Distributed Lock
    ↓
Coordinate multiple processes

Lease
    ↓
Lock with expiration

Fencing Token
    ↓
Protect against stale lock holders

Idempotency
    ↓
Protect against duplicate requests

Deadlock
    ↓
Transactions wait for each other

Atomic Update
    ↓
Let database enforce simple invariants

Queue
    ↓
Serialize highly contended operations
```

---

# 62. One-Minute Interview Answer

> Concurrency control is used to ensure that multiple concurrent requests do not corrupt shared data or violate business invariants.
>
> In a single JVM, we can use mechanisms such as `synchronized`, but that is not sufficient in a distributed system because different servers have different JVM locks.
>
> At the database level, we can use transactions, locking, isolation levels, MVCC, and atomic conditional updates.
>
> There are two major approaches: optimistic and pessimistic concurrency control.
>
> Optimistic concurrency assumes conflicts are rare and usually uses version numbers or compare-and-set. We read a version and update only if the version has not changed.
>
> Pessimistic concurrency assumes conflicts are likely, so we acquire a lock before modifying the resource.
>
> For distributed coordination, we may also use distributed locks, leases, fencing tokens, or queues.
>
> Finally, real distributed systems must also handle retries, duplicate requests, deadlocks, crashes, and network failures, so idempotency and failure handling are important parts of concurrency control.

---

# 63. Golden Rules

### Rule 1

```text
Do not rely on synchronized for distributed concurrency.
```

### Rule 2

```text
Prefer database-enforced invariants whenever possible.
```

### Rule 3

```text
Use optimistic locking when conflicts are rare.
```

### Rule 4

```text
Use pessimistic locking when contention is high.
```

### Rule 5

```text
Use atomic conditional updates for simple state transitions.
```

### Rule 6

```text
Distributed locks require failure-aware design.
```

### Rule 7

```text
Lock expiration alone does not eliminate stale-owner problems.
```

### Rule 8

```text
Use fencing tokens when stale lock holders can cause damage.
```

### Rule 9

```text
Concurrency control and idempotency solve different problems.
```

### Rule 10

```text
Always think about crashes, retries, timeouts, deadlocks,
and network failures in distributed-system interviews.
```

---

# 64. Final Interview Decision Tree

```text
             Concurrent Requests
                    |
                    v
          Shared Resource / State
                    |
                    v
        Can DB enforce atomically?
              /           \
            YES            NO
             |              |
             v              v
      Atomic UPDATE     Need coordination?
                            |
                      +-----+-----+
                      |           |
                    YES           NO
                      |           |
                      v           v
              High contention?   Optimistic
                  /     \
                YES      NO
                 |        |
                 v        v
             Pessimistic Optimistic
                Lock       Lock
                 |
                 v
       Multiple processes involved?
                 |
                YES
                 |
                 v
       Distributed coordination
                 |
                 +--> Lock
                 +--> Lease
                 +--> Fencing Token
                 +--> Queue
                 |
                 v
          Handle failures
                 |
                 +--> Retry
                 +--> Idempotency
                 +--> Timeout
                 +--> Deadlock recovery
```

---

# 65. Final Mental Model

```text
Concurrency Control
│
├── Thread Level
│   └── synchronized
│
├── Transaction Level
│   └── ACID
│
├── Database Level
│   ├── Locks
│   │   ├── Shared
│   │   └── Exclusive
│   │
│   ├── Isolation
│   │   ├── Read Uncommitted
│   │   ├── Read Committed
│   │   ├── Repeatable Read
│   │   └── Serializable
│   │
│   ├── MVCC
│   └── Atomic Updates
│
├── Application Level
│   ├── Optimistic Locking
│   ├── Versioning
│   ├── CAS
│   └── Idempotency
│
└── Distributed Level
    ├── Distributed Lock
    ├── Lease
    ├── Fencing Token
    ├── Queue
    └── Coordination Service
```

The most important interview idea is:

> **Concurrency control is not just about acquiring a lock. It is about preserving correctness when multiple operations access the same state concurrently — including what happens when requests retry, servers crash, locks expire, networks fail, or transactions conflict.**