# Deadlock in Distributed Systems & Java

## 1. What is Deadlock?

A **deadlock** occurs when two or more threads/processes are waiting for resources held by each other, so none of them can continue.

### Simple Example

Imagine:

```text
Thread A has Lock 1
Thread B has Lock 2

Thread A wants Lock 2
Thread B wants Lock 1
```

So:

```text
Thread A
   |
   | holds Lock 1
   |
   +---- waits for Lock 2
                 ↑
                 |
Thread B --------+
   |
   | holds Lock 2
   |
   +---- waits for Lock 1
```

Neither thread can continue.

```text
A → waiting for B
B → waiting for A
```

This is a **deadlock**.

---

# 2. Real-Life Example

Imagine two people:

```text
Person A:
Has Pen
Needs Notebook

Person B:
Has Notebook
Needs Pen
```

A waits for B.

B waits for A.

Nobody can continue.

This is exactly how a deadlock occurs in software.

---

# 3. Why Does Deadlock Matter?

Deadlocks can cause:

```text
Thread stuck
      ↓
Request stuck
      ↓
Thread pool exhausted
      ↓
More requests wait
      ↓
Application becomes slow
      ↓
Eventually service may become unavailable
```

In a production system, even a small number of deadlocks can cause significant problems when many requests share limited resources.

---

# 4. Four Necessary Conditions for Deadlock

A classic deadlock can occur only when all four conditions exist simultaneously.

These are called the **Coffman conditions**.

```text
1. Mutual Exclusion
2. Hold and Wait
3. No Preemption
4. Circular Wait
```

---

# 5. Condition 1 — Mutual Exclusion

A resource can be held by only one thread at a time.

Example:

```text
Lock A
```

Only one thread owns it.

```text
Thread A → Lock A
Thread B → WAIT
```

Without exclusive ownership, this particular lock-based deadlock pattern would not occur.

---

# 6. Condition 2 — Hold and Wait

A thread holds one resource while waiting for another.

Example:

```text
Thread A:

Holds Lock 1
    ↓
Waits for Lock 2
```

At the same time:

```text
Thread B:

Holds Lock 2
    ↓
Waits for Lock 1
```

This is dangerous.

---

# 7. Condition 3 — No Preemption

A resource cannot simply be taken away from the thread holding it.

Example:

```text
Thread A owns Lock 1
```

Thread B cannot normally forcefully take:

```text
Lock 1
```

away from A.

A must release it.

---

# 8. Condition 4 — Circular Wait

There is a circular dependency.

Example:

```text
A waits for B
B waits for C
C waits for A
```

Diagram:

```text
A → B
↑   ↓
C ←
```

Or the simplest case:

```text
A → B
B → A
```

---

# 9. Deadlock Formula to Remember

```text
Deadlock =
Mutual Exclusion
+
Hold and Wait
+
No Preemption
+
Circular Wait
```

### Interview Tip

A good answer is:

> Deadlock occurs when the four Coffman conditions hold: mutual exclusion, hold-and-wait, no preemption, and circular wait.

---

# 10. Types of Deadlock

There are several ways to classify deadlocks.

## 10.1 Resource Deadlock

Threads wait for resources such as:

```text
Lock
File
Database connection
Semaphore
Socket/resource permit
```

Example:

```text
T1 → Lock A
T2 → Lock B

T1 → waits for B
T2 → waits for A
```

---

# 11. 10.2 Lock/Monitor Deadlock in Java

This happens when Java threads wait indefinitely for synchronized monitors or explicit locks.

Example:

```java
synchronized(lockA) {
    synchronized(lockB) {
        // work
    }
}
```

Another thread may do:

```java
synchronized(lockB) {
    synchronized(lockA) {
        // work
    }
}
```

This creates lock-order inversion.

---

# 12. 10.3 Database Deadlock

Database transactions can deadlock too.

Example:

```text
Transaction T1:
Lock Row A
Wait for Row B

Transaction T2:
Lock Row B
Wait for Row A
```

Diagram:

```text
T1 → Row A → waits for Row B
T2 → Row B → waits for Row A
```

Databases usually have their own deadlock detection/recovery mechanisms.

---

# 13. 10.4 Distributed Deadlock

In distributed systems, different services/nodes may hold different resources.

Example:

```text
Server A
  ↓
Resource X
  ↓
Wait for Y

Server B
  ↓
Resource Y
  ↓
Wait for X
```

Detecting such deadlocks is harder because there may be no single machine with the complete dependency graph.

---

# 14. Deadlock vs Livelock vs Starvation

These are commonly confused in interviews.

## Deadlock

Threads are stuck waiting for each other.

```text
A waits for B
B waits for A
```

No progress.

---

## Livelock

Threads are active but keep reacting to each other without making useful progress.

Example:

```text
Thread A moves aside
Thread B moves aside
Thread A moves again
Thread B moves again
...
```

They are running, but nothing completes.

---

## Starvation

A thread waits for a resource for an extremely long time because other threads continuously get access first.

Example:

```text
Thread A → waiting
Thread B → repeatedly gets lock
Thread C → repeatedly gets lock
Thread D → repeatedly gets lock
```

A may never get the resource.

### Easy Recall

```text
Deadlock   → Nobody moves
Livelock   → Everyone moves, nobody progresses
Starvation → One waits too long
```

---

# 15. Basic Java Deadlock Example

```java
public class DeadlockExample {

    private static final Object lock1 = new Object();
    private static final Object lock2 = new Object();

    public static void main(String[] args) {

        Thread threadA = new Thread(() -> {
            synchronized (lock1) {
                System.out.println("Thread A acquired lock1");

                synchronized (lock2) {
                    System.out.println("Thread A acquired lock2");
                }
            }
        });

        Thread threadB = new Thread(() -> {
            synchronized (lock2) {
                System.out.println("Thread B acquired lock2");

                synchronized (lock1) {
                    System.out.println("Thread B acquired lock1");
                }
            }
        });

        threadA.start();
        threadB.start();
    }
}
```

Possible execution:

```text
Thread A:
lock1 ✓
waiting for lock2

Thread B:
lock2 ✓
waiting for lock1
```

Result:

```text
DEADLOCK
```

---

# 16. Why Does the Java Example Deadlock?

Thread A:

```text
lock1 → lock2
```

Thread B:

```text
lock2 → lock1
```

The lock acquisition order is different.

```text
A:
1 → 2

B:
2 → 1
```

This creates circular wait.

---

# 17. Solution 1 — Consistent Lock Ordering

This is one of the best ways to prevent deadlocks.

Always acquire locks in the same order.

For example:

```text
lock1 → lock2
```

Both threads must follow:

```text
Thread A:
lock1 → lock2

Thread B:
lock1 → lock2
```

Now:

```text
Thread A gets lock1
Thread B waits for lock1

A gets lock2
A completes
A releases
B gets lock1
B continues
```

No circular wait.

---

# 18. Fixed Java Example

```java
Object firstLock = lock1;
Object secondLock = lock2;

synchronized (firstLock) {
    synchronized (secondLock) {
        // critical section
    }
}
```

The important part is not the variable names.

The important rule is:

```text
ALL threads must acquire locks
in the same global order.
```

---

# 19. Lock Ordering with IDs

For dynamically chosen resources, define an ordering.

Example:

```text
Account 10
Account 20
```

Always lock:

```text
10 → 20
```

Even when transferring money from:

```text
20 → 10
```

the locks should still be acquired in:

```text
10 → 20
```

This prevents:

```text
T1:
Lock 10
Wait 20

T2:
Lock 20
Wait 10
```

---

# 20. Solution 2 — Keep Critical Sections Small

Bad:

```java
synchronized (lock) {

    databaseCall();

    externalApiCall();

    longCalculation();

    updateDatabase();
}
```

The lock is held for a long time.

Better:

```text
Do independent work
        ↓
Acquire lock
        ↓
Perform small critical section
        ↓
Release lock
```

### Why?

Shorter lock duration means:

```text
Less waiting
+
Less contention
+
Lower deadlock probability
+
Better throughput
```

---

# 21. Never Hold a Lock During External Calls

This is an important production rule.

Avoid:

```text
Acquire Lock
    ↓
Call Payment API
    ↓
Wait 5 seconds
    ↓
Call another service
    ↓
Release Lock
```

During those 5+ seconds:

```text
Other threads
      ↓
Waiting
```

A slow network call can make lock contention much worse.

### Better

```text
Do external work
      ↓
Acquire lock
      ↓
Perform small DB/state change
      ↓
Release lock
```

---

# 22. Solution 3 — Avoid Nested Locks When Possible

Bad:

```java
synchronized (lockA) {

    synchronized (lockB) {

        synchronized (lockC) {
            // work
        }
    }
}
```

The more locks you acquire, the more complicated the dependency graph becomes.

Better:

```text
Acquire fewer locks
+
Use atomic operations
+
Use higher-level coordination
```

---

# 23. Solution 4 — Use `tryLock()`

Java's `ReentrantLock` provides `tryLock()`.

Instead of waiting forever:

```java
lock.lock();
```

you can attempt:

```java
if (lock.tryLock()) {
    try {
        // critical section
    } finally {
        lock.unlock();
    }
} else {
    // could not acquire lock
}
```

The thread does not necessarily wait indefinitely.

---

# 24. `tryLock()` With Timeout

Even better:

```java
if (lock.tryLock(2, TimeUnit.SECONDS)) {
    try {
        // critical section
    } finally {
        lock.unlock();
    }
} else {
    // timeout
}
```

Flow:

```text
Try lock
   ↓
Acquired?
 /      \
YES      NO
 |       |
Work    Retry / Fail
 |
Unlock
```

---

# 25. Why `tryLock()` Helps

Suppose:

```text
Thread A holds Lock 1
Thread B holds Lock 2
```

A tries Lock 2.

B tries Lock 1.

With indefinite blocking:

```text
A → WAIT
B → WAIT
```

With timeout:

```text
A → waits → timeout → releases/aborts
B → continues
```

This can break a deadlock cycle.

---

# 26. Important `tryLock()` Rule

Always unlock in `finally`.

Correct:

```java
if (lock.tryLock()) {
    try {
        // critical section
    } finally {
        lock.unlock();
    }
}
```

Incorrect:

```java
if (lock.tryLock()) {
    // work
    lock.unlock();  // risky if exception occurs
}
```

If an exception occurs before `unlock()`:

```text
Lock may remain held
```

---

# 27. Solution 5 — Interruptible Lock Acquisition

With `ReentrantLock`:

```java
lock.lockInterruptibly();
```

A thread waiting for the lock can respond to interruption.

Example:

```java
try {
    lock.lockInterruptibly();

    try {
        // critical section
    } finally {
        lock.unlock();
    }

} catch (InterruptedException e) {
    Thread.currentThread().interrupt();
}
```

This is useful for cancellation and graceful shutdown.

---

# 28. Solution 6 — Timeout

A general strategy:

```text
Wait for resource
      ↓
Timeout
      ↓
Abort / release / retry
```

Timeout does not necessarily prove a deadlock exists.

The resource may simply be slow.

Therefore:

> Timeout is a practical recovery/prevention mechanism, not perfect deadlock detection.

---

# 29. Solution 7 — Reduce Shared Mutable State

A powerful design approach is:

> Avoid sharing mutable state whenever possible.

Bad:

```text
20 threads
   ↓
Same mutable object
```

Better:

```text
Immutable Data
+
Message Passing
+
Thread-safe structures
+
Partitioned state
```

Less shared mutable state means fewer locks.

---

# 30. Solution 8 — Use Higher-Level Concurrency Utilities

Instead of manually managing complex locking, use Java concurrency utilities when appropriate.

Examples:

```text
AtomicInteger
AtomicLong
ConcurrentHashMap
Semaphore
CountDownLatch
BlockingQueue
ReentrantLock
ReadWriteLock
StampedLock
ExecutorService
```

Example:

```java
AtomicInteger counter = new AtomicInteger();

counter.incrementAndGet();
```

Instead of:

```text
lock
 ↓
read
 ↓
increment
 ↓
write
 ↓
unlock
```

For simple atomic state changes, atomic classes can be much simpler.

---

# 31. Atomic Operations

If you only need:

```text
counter++
```

don't automatically use a lock.

Use:

```java
AtomicInteger counter = new AtomicInteger();

counter.incrementAndGet();
```

This can reduce lock contention.

However, atomic classes are not a universal replacement for transactions or multi-step invariants.

---

# 32. ReadWriteLock

If the workload has:

```text
Many Reads
Few Writes
```

you may consider:

```java
ReadWriteLock
```

Multiple readers can often read concurrently while writers get exclusive access.

Conceptually:

```text
Reader 1 ──┐
Reader 2 ──┼──> Read Lock
Reader 3 ──┘

Writer → waits
```

When writer gets access:

```text
Readers → wait
Writer → Exclusive
```

This can improve concurrency for read-heavy workloads, but can introduce fairness/starvation trade-offs depending on configuration.

---

# 33. `synchronized` vs `ReentrantLock`

| Feature | `synchronized` | `ReentrantLock` |
|---|---|---|
| Simple | Yes | More code |
| Automatic release | Yes | Must unlock |
| `tryLock()` | No | Yes |
| Timeout | No direct lock timeout | Yes |
| Interruptible acquisition | No direct equivalent | Yes |
| Fairness option | No | Yes |
| Condition variables | `wait/notify` | `Condition` |
| Good for | Simple locking | Advanced coordination |

### Interview Answer

> Use `synchronized` when simple mutual exclusion is enough. Use `ReentrantLock` when you need features such as timed acquisition, `tryLock`, interruptible locking, fairness, or multiple conditions.

---

# 34. Deadlock Detection

Deadlock detection means finding circular dependencies among waiting threads/resources.

Conceptually:

```text
Threads
   ↓
Build dependency graph
   ↓
Detect cycle
   ↓
Cycle?
 /    \
YES    NO
 |      |
Deadlock Continue
```

---

# 35. Wait-For Graph

A **Wait-For Graph (WFG)** represents which thread/transaction is waiting for another.

Example:

```text
T1 waits for T2
```

Graph:

```text
T1 → T2
```

Example:

```text
T1 → T2
T2 → T3
T3 → T1
```

There is a cycle:

```text
T1 → T2 → T3 → T1
```

Therefore:

```text
DEADLOCK
```

---

# 36. Deadlock Detection in Java

Java/JVM provides tools to detect thread deadlocks.

One commonly used approach is:

```java
ThreadMXBean
```

Example:

```java
ThreadMXBean bean =
    ManagementFactory.getThreadMXBean();

long[] deadlockedThreads =
    bean.findDeadlockedThreads();

if (deadlockedThreads != null) {
    System.out.println("Deadlock detected!");
}
```

This can help diagnose monitor/ownable synchronizer deadlocks in the JVM.

---

# 37. Thread Dump

A thread dump is one of the most important production-debugging tools.

It shows:

```text
Thread
State
Stack trace
Locks held
Locks waiting for
```

A deadlock can look conceptually like:

```text
"Thread-1":
    WAITING for Lock B
    owned by Thread-2

"Thread-2":
    WAITING for Lock A
    owned by Thread-1
```

This strongly indicates a deadlock cycle.

---

# 38. Common Java Tools for Deadlock Investigation

Useful tools include:

```text
jstack
Java Flight Recorder (JFR)
JConsole
VisualVM
ThreadMXBean
```

A production investigation often combines:

```text
Thread dump
+
Application logs
+
Metrics
+
Tracing
```

---

# 39. Deadlock Recovery

Once a deadlock is detected, the system needs a recovery strategy.

Common approaches:

```text
1. Abort one transaction/thread
2. Release its locks
3. Allow others to continue
4. Retry the failed operation
```

For database systems:

```text
Deadlock detected
      ↓
Choose victim transaction
      ↓
Rollback victim
      ↓
Release locks
      ↓
Other transaction continues
      ↓
Retry victim if appropriate
```

---

# 40. Why Not Just Kill a Java Thread?

Java thread interruption is not a magic solution for arbitrary deadlocks.

If code is blocked on:

```text
synchronized
```

you cannot simply use interruption to forcefully unlock another thread's monitor.

For explicit locks such as `ReentrantLock`, interruption-aware acquisition can help if the code was designed for it.

Therefore:

> Prevention is usually better than trying to recover from an already-created JVM monitor deadlock.

---

# 41. Database Deadlock Recovery

Databases generally have stronger deadlock handling mechanisms.

Example:

```text
T1 locks A
T2 locks B

T1 waits for B
T2 waits for A
```

Database detects the cycle:

```text
Deadlock
   ↓
Abort one transaction
   ↓
Rollback
   ↓
Release locks
   ↓
Other transaction continues
```

The application may need to retry the aborted transaction.

---

# 42. Database Deadlock Retry

Application logic can look conceptually like:

```text
try transaction
     |
     +---- success → Done
     |
     +---- deadlock error
                |
                v
             backoff
                |
                v
              retry
```

Use:

```text
Maximum retry count
+
Exponential backoff
+
Jitter
```

Do not retry forever.

---

# 43. Distributed Lock Deadlock

Suppose:

```text
Server A → owns Lock X
Server B → owns Lock Y
```

Then:

```text
A wants Y
B wants X
```

Same deadlock pattern exists across machines.

Solutions:

```text
Consistent lock ordering
Timeout
Lease expiration
Deadlock detection
Short lock duration
Fencing tokens
```

---

# 44. Distributed Lock + Lease

A distributed lease has an expiration time.

Example:

```text
Server A
   |
   | lease = 10 seconds
   v
Resource
```

If A stops renewing:

```text
Lease expires
      ↓
Another server may acquire it
```

This prevents a lock from remaining forever due to a crashed owner.

But:

> Lease expiration by itself does not completely solve stale-owner problems.

---

# 45. Fencing Tokens

Consider:

```text
Server A gets lease
token = 10
```

A pauses.

Lease expires.

Server B gets lease:

```text
token = 11
```

A wakes up and tries to write.

Without fencing:

```text
A → old write
B → new write
```

With fencing:

```text
A → token 10 → REJECT
B → token 11 → ACCEPT
```

The downstream resource accepts only sufficiently recent tokens.

This protects against stale lock holders.

---

# 46. Deadlock Prevention Checklist

Before using locks:

```text
1. Can I avoid the lock?
2. Can I use an atomic operation?
3. Can I use immutable state?
4. Can I use a queue?
5. Can I reduce the critical section?
6. Can I acquire locks in fixed order?
7. Can I use tryLock with timeout?
8. Can I avoid nested locks?
9. Can I avoid external calls while holding locks?
10. Do I need a distributed lock at all?
```

---

# 47. Best Java Deadlock Prevention Rules

## Rule 1 — Always Use a Lock Ordering

```text
Lock A → Lock B → Lock C
```

Every thread follows the same order.

---

## Rule 2 — Keep Locks Short

```text
Acquire
 ↓
Small critical section
 ↓
Release
```

---

## Rule 3 — Avoid External Calls

Never casually do:

```text
Lock
 ↓
HTTP call
 ↓
Database call
 ↓
Wait
```

---

## Rule 4 — Prefer Atomic Operations

Example:

```java
counter.incrementAndGet();
```

instead of:

```text
lock
read
increment
write
unlock
```

when a single atomic operation is sufficient.

---

## Rule 5 — Use `tryLock()` Where Appropriate

```java
if (lock.tryLock(timeout, unit)) {
    try {
        // work
    } finally {
        lock.unlock();
    }
}
```

---

## Rule 6 — Avoid Too Many Locks

Every additional lock increases the possible dependency combinations.

---

## Rule 7 — Keep Transactions Short

Especially for database locks.

---

# 48. Interview Scenario — Two Account Transfer

### Question

Two threads perform:

```text
Transfer A → B
Transfer B → A
```

How can deadlock happen?

### Answer

Bad ordering:

```text
Thread 1:
Lock A
Lock B

Thread 2:
Lock B
Lock A
```

This can produce:

```text
T1 holds A → waits B
T2 holds B → waits A
```

### Solution

Always lock accounts in ID order:

```text
min(accountA, accountB)
        ↓
max(accountA, accountB)
```

Both transfers follow the same locking order.

---

# 49. Interview Scenario — Java Service Becomes Hung

### Question

The service is running but requests are stuck. How would you investigate deadlock?

### Answer

I would:

```text
1. Check request/thread metrics
2. Capture a thread dump
3. Look for BLOCKED/WAITING threads
4. Check which locks threads own
5. Check which locks they are waiting for
6. Identify circular dependency
7. Use jstack/JVM monitoring tools
8. Inspect recent code/config changes
9. Fix lock ordering or lock scope
10. Add monitoring to detect recurrence
```

---

# 50. Interview Scenario — `synchronized` Deadlock

### Question

Why is this dangerous?

```java
synchronized (A) {
    synchronized (B) {
        // ...
    }
}
```

and elsewhere:

```java
synchronized (B) {
    synchronized (A) {
        // ...
    }
}
```

### Answer

Because the lock acquisition order is reversed.

```text
Code 1 → A → B
Code 2 → B → A
```

This can create circular wait.

Solution:

```text
Everywhere:
A → B
```

---

# 51. Interview Scenario — Can Timeout Prevent Deadlock?

### Answer

Timeout can help recover from a potential deadlock:

```text
Wait
 ↓
Timeout
 ↓
Abort/retry
```

But timeout is not proof of deadlock.

A slow operation can also trigger a timeout.

Therefore use:

```text
Timeout
+
Correct lock ordering
+
Deadlock detection where appropriate
```

---

# 52. Interview Scenario — Optimistic vs Deadlock

### Question

Can optimistic concurrency reduce deadlocks?

### Answer

Yes, because optimistic locking generally avoids long-held database locks during the business operation.

Instead:

```text
Read version
 ↓
Do work
 ↓
Conditional update
 ↓
Conflict?
```

This can reduce lock-related deadlocks.

But optimistic locking can introduce:

```text
Conflict retries
```

So it has a different trade-off.

---

# 53. Interview Scenario — Pessimistic Locking

### Question

Can pessimistic locking cause deadlocks?

### Answer

Yes.

Example:

```text
T1:
Lock A
Wait B

T2:
Lock B
Wait A
```

Pessimistic locking protects resources but can create lock cycles if lock ordering is not carefully designed.

---

# 54. Deadlock vs 2PL

Two-Phase Locking:

```text
Growing Phase
    ↓
Acquire locks
    ↓
Shrinking Phase
    ↓
Release locks
```

Basic 2PL guarantees conflict serializability, but it can still create:

```text
Deadlock
```

because transactions can hold some locks while waiting for others.

### Solutions

```text
Timeout
Wait-For Graph
Timestamp protocols
Conservative 2PL
Consistent lock ordering
```

---

# 55. Deadlock vs Strict 2PL

Strict 2PL:

```text
Hold X locks until commit/abort
```

This helps prevent:

```text
Cascading Abort
```

but:

> Strict 2PL does NOT automatically prevent deadlocks.

You still need:

```text
Deadlock Prevention
or
Deadlock Detection + Recovery
```

---

# 56. Prevention vs Detection vs Recovery

This distinction is very important in interviews.

## Prevention

Design the system so deadlock cannot happen or is much less likely.

Examples:

```text
Lock ordering
Conservative 2PL
Avoid nested locks
Short critical sections
```

---

## Detection

Allow potential deadlocks, then identify them.

Examples:

```text
Wait-For Graph
Thread dump analysis
JVM deadlock detection
Database deadlock detector
```

---

## Recovery

Once a deadlock is detected:

```text
Abort victim
Release resources
Retry operation
```

---

# 57. Comparison

| Approach | Idea | Example |
|---|---|---|
| Prevention | Make deadlock impossible/unlikely | Lock ordering |
| Detection | Find deadlock after it occurs | WFG |
| Recovery | Break deadlock | Abort + retry |
| Timeout | Stop waiting too long | `tryLock(timeout)` |

---

# 58. Production Design

A robust Java service should ideally use:

```text
                Concurrent Requests
                       |
                       v
                Application Layer
                       |
          +------------+------------+
          |                         |
      Atomic Ops                Locks
          |                         |
          |                  Fixed Lock Order
          |                         |
          +------------+------------+
                       |
                       v
                    Database
                       |
             Transactions / Locks
                       |
                       v
                Shared Resource
```

Supporting mechanisms:

```text
Timeout
+
Retries
+
Metrics
+
Thread Dumps
+
Tracing
+
Deadlock Detection
```

---

# 59. Final Interview Answer

If interviewer asks:

> "How do you prevent deadlocks in Java?"

Answer:

> "First, I try to avoid locking where possible by using immutable state, atomic operations, or higher-level concurrency primitives. If multiple locks are necessary, I define a consistent global lock order so every thread acquires locks in the same sequence. I keep critical sections and transactions short and avoid making external API or database calls while holding application locks. For explicit locks such as `ReentrantLock`, I can use `tryLock` with a timeout or interruptible acquisition rather than waiting indefinitely. I also use thread dumps and JVM tools such as ThreadMXBean or jstack to detect deadlocks in production. If a database or distributed lock can still deadlock, I use timeout/deadlock detection, abort a safe victim, and retry with backoff where appropriate."

---

# 60. ⭐ Quick Recall Cheat Sheet

```text
DEADLOCK
========

Definition:
Two or more threads/transactions wait for each other forever.


4 COFFMAN CONDITIONS:
=====================

1. Mutual Exclusion
   → Resource has exclusive owner.

2. Hold and Wait
   → Hold one resource, wait for another.

3. No Preemption
   → Resource cannot be forcibly taken.

4. Circular Wait
   → A waits B
     B waits A


TYPES:
======

Resource Deadlock
Java Lock/Monitor Deadlock
Database Deadlock
Distributed Deadlock


NOT THE SAME AS:
================

Deadlock:
→ Nobody progresses.

Livelock:
→ Threads keep running but make no progress.

Starvation:
→ One thread waits too long.


DEADLOCK PREVENTION:
====================

1. Consistent Lock Ordering
2. Avoid Nested Locks
3. Keep Critical Section Short
4. Avoid External Calls While Holding Lock
5. Use tryLock(timeout)
6. Reduce Shared Mutable State
7. Use Atomic Operations
8. Keep DB Transactions Short
9. Avoid Unnecessary Distributed Locks
10. Use Queue/Serialization for Hot Resources


DETECTION:
==========

Wait-For Graph
Thread Dump
ThreadMXBean
jstack
JFR
JConsole
VisualVM
Database Deadlock Detector


RECOVERY:
=========

Deadlock detected
      ↓
Choose victim
      ↓
Abort / Release resources
      ↓
Retry if safe
      ↓
Backoff + Jitter


JAVA:
=====

synchronized
→ Simple mutual exclusion

ReentrantLock
→ tryLock
→ timeout
→ interruptible locking
→ fairness option

AtomicInteger
→ Simple atomic state

ConcurrentHashMap
→ Concurrent data structure


DISTRIBUTED LOCK:
=================

Lock
 ↓
Lease/TTL
 ↓
Failure?
 ↓
Lease expires
 ↓
Another owner

Advanced:
Fencing Token
→ Prevent stale owner from writing


2PL:
====

Basic 2PL
→ Growing + Shrinking
→ Serializable
→ Deadlock possible

Strict 2PL
→ X locks until commit/abort
→ Prevents cascading abort

Rigorous 2PL
→ S + X locks until commit/abort


MOST IMPORTANT RULE:

Lock A → Lock B → Lock C

ALL threads must follow the SAME ORDER.


ONE-LINE MEMORY:

Prevent:
"Same lock order."

Detect:
"Find cycle."

Recover:
"Abort one + retry."

Java:
"Prefer short locks + tryLock + atomic operations."

Distributed:
"Think about lease expiry + fencing."
```

---

# 61. Final Mental Model

```text
               DEADLOCK
                   |
       +-----------+-----------+
       |           |           |
   Prevention   Detection   Recovery
       |           |           |
       v           v           v
 Lock Ordering   WFG       Abort Victim
 Short Locks     Thread    Release Locks
 tryLock         Dump      Retry
 Atomic Ops      JVM Tool  Backoff
```

The most important interview concept is:

> **Deadlock is a circular dependency between concurrent operations. In Java, the strongest practical prevention technique is consistent lock ordering, combined with short critical sections and avoiding unnecessary nested locks. In distributed systems, you must additionally think about timeouts, leases, stale lock holders, fencing tokens, and recovery.**