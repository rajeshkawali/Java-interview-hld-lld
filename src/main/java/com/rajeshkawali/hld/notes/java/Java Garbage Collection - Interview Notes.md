# Java Garbage Collection

## 1. What is Garbage Collection?

Garbage Collection (GC) is the **automatic memory management mechanism of the JVM**.

In Java, objects are created using the `new` keyword and are generally allocated on the heap.

```java
Employee emp = new Employee();
```

When an object is no longer reachable by the application, it becomes **eligible for garbage collection**.

```java
Employee emp = new Employee();

emp = null;
```

The object is not immediately destroyed. It only becomes **eligible for GC**. The JVM decides when and how that memory will be reclaimed.

### Why do we need GC?

In languages such as C/C++, developers often have to explicitly manage memory.

Java avoids most of these problems by automatically managing heap memory.

GC helps:

- reclaim memory occupied by unreachable objects
- reduce manual memory-management errors
- prevent many types of dangling-pointer problems
- make object allocation easier for developers

However, GC does **not** mean Java applications can never have memory leaks.

A Java memory leak can happen when objects are no longer logically required but are still reachable.

---

# 2. Java Heap and Generations

The **heap** is the main memory area managed by the JVM for Java objects.

A traditional generational heap can be represented as:

```text
                 Heap
                   |
          +--------+--------+
          |                 |
        Young              Old
       Generation       Generation
          |
     +----+----+
     |         |
   Eden    Survivor
            S0/S1
```

The exact implementation depends on the garbage collector.

The important idea behind generational GC is:

> **Most newly created objects become unreachable relatively quickly.**

Therefore, instead of treating every object in the heap equally, the JVM can organize collection around object age.

---

# 3. Object Life Cycle

A simplified object lifecycle is:

```text
Object Created
      |
      v
    Eden
      |
      v
   Young GC
      |
      v
  Survivor
      |
      v
Survives more GCs
      |
      v
Old Generation
      |
      v
Object becomes unreachable
      |
      v
Garbage Collection
      |
      v
Memory Reclaimed
```

For example:

```java
public void process() {
    Employee emp = new Employee();
}
```

After `process()` finishes, assuming there are no other references to the `Employee`, the object may become unreachable.

It can then eventually be reclaimed by GC.

---

# 4. How Does GC Know an Object Is Garbage?

This is one of the **most important interview questions**.

GC does not simply check:

```java
object == null
```

Instead, the JVM uses **reachability analysis**.

The GC starts from special objects called **GC Roots** and follows references.

Example:

```text
GC Root
   |
   v
 Object A
   |
   v
 Object B
   |
   v
 Object C
```

A, B and C are reachable.

Now suppose:

```text
GC Root

Object X → Object Y
```

If there is no path from any GC Root to X or Y, those objects are unreachable and eligible for collection.

### Important interview statement

> An object is eligible for garbage collection when it is no longer reachable from any GC Root.

---

# 5. GC Roots

GC Roots are starting points used by the JVM for reachability analysis.

Common examples include:

- local variables/references in active Java threads
- active thread objects
- static references
- JVM internal references
- JNI/native references

Example:

```java
public void test() {
    Employee employee = new Employee();
}
```

While `test()` is executing, `employee` can act as a root-related reference through the executing thread's stack.

After the method finishes, if there are no other references:

```text
GC Root
   |
   X

Employee
```

The `Employee` object may become unreachable.

---

# 6. Mark, Sweep and Compact

Three fundamental GC concepts are:

```text
Mark
  ↓
Sweep
  ↓
Compact
```

These are concepts rather than a description of every modern collector's exact algorithm.

## Mark

The GC identifies live objects by traversing from GC Roots.

```text
Root → A → B

C → D

E
```

After marking:

```text
Root → A → B
       ✓   ✓

C → D
✓   ✓

E
X
```

The reachable objects are considered live.

---

## Sweep

Unreachable objects are reclaimed.

```text
[A][B][X][C][X][D][X]
```

After sweeping:

```text
[A][B][ ][C][ ][D][ ]
```

The problem is that free memory can become fragmented.

---

## Compact

Live objects are moved together.

```text
Before:

[A][B][ ][C][ ][D][ ]

After:

[A][B][C][D][ ][ ][ ]
```

Compaction reduces fragmentation.

Moving objects requires the JVM to correctly handle references to those objects.

---

# 7. Copying / Evacuation

Another important GC technique is **copying** or **evacuation**.

Suppose:

```text
[A][X][B][X][C][X]
```

where:

```text
A, B, C = live
X       = garbage
```

GC can copy/evacuate the live objects:

```text
[A][B][C]
```

and reuse the original memory.

Modern collectors such as G1 use evacuation heavily.

### Why is evacuation useful?

It can:

- reclaim memory
- reduce fragmentation
- compact objects
- create larger contiguous free areas

---

# 8. Young GC

A Young GC primarily processes the young generation.

New objects are commonly allocated in Eden.

For example:

```text
Eden
 |
 | many temporary objects
 |
 v
Young GC
 |
 +----> Dead objects → reclaimed
 |
 +----> Live objects → Survivor
```

Young collections are generally designed to be relatively inexpensive because the young generation contains many short-lived objects.

---

# 9. Object Promotion

Objects that survive multiple young collections may eventually be promoted to the old generation.

Simplified:

```text
Eden
  |
  v
Survivor
  |
  v
Survivor
  |
  v
Old Generation
```

The JVM maintains information about object age and uses collector-specific policies to decide when objects should be promoted.

### Interview question

**Why do we have an Old Generation?**

Because some objects survive for a long time.

Instead of repeatedly processing long-lived objects during young collections, the JVM can move them toward old-generation treatment.

---

# 10. Stop-The-World (STW)

**Stop-The-World** means application threads are temporarily stopped while the JVM performs a particular operation.

Conceptually:

```text
Application Threads
████████████████

        STOP

       GC work

       RESUME

Application Threads
████████████████
```

STW does not necessarily mean that the entire garbage collection process always happens while the application is stopped.

Modern collectors perform significant work **concurrently** with application threads.

For example, G1, ZGC and Shenandoah perform substantial GC work concurrently.

### Interview answer

> Stop-The-World means application threads are paused temporarily so the JVM can safely perform certain operations.

---

# 11. Safepoint

A **safepoint** is a point at which a Java thread is in a state where the JVM can safely perform certain operations.

GC may require application threads to reach an appropriate safepoint before a pause operation can proceed.

A simplified view:

```text
Thread A → Safepoint
Thread B → Safepoint
Thread C → Safepoint

             ↓

       JVM performs
       required work
```

Do not confuse:

```text
Safepoint ≠ Garbage Collection
```

Safepoints are a broader JVM mechanism.

---

# 12. Concurrent vs Parallel GC

This is another common interview question.

## Parallel

Multiple GC threads perform work simultaneously.

```text
GC Thread 1 ─┐
GC Thread 2 ─┤
GC Thread 3 ─┤ → GC work
GC Thread 4 ─┘
```

The application may be paused during this work.

## Concurrent

GC performs work while application threads continue running.

```text
Application: ███████████████████

GC:          ███████████████████
```

### Important

**Parallel and concurrent are not opposites.**

A collector can perform some work:

- in parallel
- concurrently
- or using both approaches at different phases.

---

# 13. Garbage Collectors in Java

The important collectors to know for interviews are:

1. Serial GC
2. Parallel GC
3. CMS
4. G1 GC
5. ZGC
6. Shenandoah

Epsilon can also be mentioned as a special-purpose collector.

For modern HotSpot interviews, focus especially on:

```text
G1
ZGC
Parallel
Serial
```

And know CMS mainly as a **historical/deprecated collector**.

---

# 14. Serial GC

Serial GC uses a single GC thread for its collection work.

```text
Application
     |
   STOP
     |
Single GC Thread
     |
   Collect
     |
  RESUME
```

Enable with:

```bash
-XX:+UseSerialGC
```

### Advantages

- Simple
- Low overhead
- Good for small heaps
- Good for small applications
- Works well when CPU resources are limited

### Disadvantages

- Uses a single GC thread
- Does not scale well for large heaps
- Can produce longer pauses

### When to use?

Mainly:

```text
Small application
Small heap
Limited CPU
```

---

# 15. Parallel GC

Parallel GC uses multiple GC threads.

It is primarily designed for **high throughput**.

```text
GC Thread 1 ─┐
GC Thread 2 ─┤
GC Thread 3 ─┤ → GC
GC Thread 4 ─┘
```

Enable:

```bash
-XX:+UseParallelGC
```

### Why was it introduced?

As machines started providing multiple CPUs/cores, using only one GC thread was inefficient.

Parallel GC can use multiple processors to perform GC work.

### Advantages

- High throughput
- Uses multiple CPUs
- Good for batch processing
- Good when long pauses are acceptable

### Disadvantages

- Can produce longer STW pauses
- Not ideal for latency-sensitive applications
- GC can consume significant CPU during collection

### Interview statement

> Parallel GC prioritizes application throughput rather than extremely low pause times.

---

# 16. CMS GC

CMS means:

**Concurrent Mark Sweep**

CMS was designed to reduce long GC pauses by performing much of its work concurrently with the application.

A simplified CMS cycle:

```text
Initial Mark
     ↓
Concurrent Mark
     ↓
Remark
     ↓
Concurrent Sweep
```

### Advantages

- Lower pause times than traditional stop-the-world collectors
- Performs substantial work concurrently

### Disadvantages

- CPU overhead
- Memory overhead
- Fragmentation
- More tuning complexity
- Can experience concurrent-mode failures

### What happened to CMS?

CMS was:

```text
Deprecated → JDK 9
Removed    → JDK 14
```

Therefore, you should know CMS for historical/interview purposes but should not choose it for a modern JDK.

### Interview answer

> CMS was designed for low-pause collection using concurrent marking and sweeping, but it suffered from fragmentation and tuning complexity. It was deprecated in JDK 9 and removed in JDK 14.

---

# 17. G1 Garbage Collector

G1 means:

**Garbage-First Garbage Collector**

G1 is one of the most important collectors for Java interviews.

It became the default GC in **JDK 9**.

Enable:

```bash
-XX:+UseG1GC
```

### Why was G1 introduced?

Traditional collectors divide the heap into large generations.

For large heaps, collecting large areas at once can result in long pauses.

G1 instead divides the heap into many **regions**.

```text
+----+----+----+----+
| R1 | R2 | R3 | R4 |
+----+----+----+----+
| R5 | R6 | R7 | R8 |
+----+----+----+----+
| R9 |R10 |R11 |R12 |
+----+----+----+----+
```

Regions can have different roles over time.

This allows G1 to select particular regions for collection instead of always treating the heap as a few large contiguous areas.

---

# 18. Why Is It Called Garbage-First?

Suppose:

```text
Region A → 10% garbage
Region B → 80% garbage
Region C → 20% garbage
Region D → 90% garbage
```

G1 can prioritize regions that provide more reclaimable memory.

Conceptually:

```text
D → collect first
B → collect next
C
A
```

This is the idea behind the name **Garbage-First**.

---

# 19. G1 Internal Working

A simplified G1 process:

```text
Application
     |
     v
Object allocation
     |
     v
Young collections
     |
     v
Concurrent marking
     |
     v
Identify regions with reclaimable garbage
     |
     v
Select Collection Set
     |
     v
Evacuate live objects
     |
     v
Reclaim regions
```

G1 maintains information about regions and references between regions.

Two important concepts are:

```text
Remembered Sets
Collection Set
```

---

# 20. G1 Collection Set

A **Collection Set (CSet)** is the group of regions selected for collection during a GC pause.

Example:

```text
R1 R2 R3 R4
R5 R6 R7 R8
R9 R10 R11 R12
```

Suppose:

```text
CSet = R2, R5, R8
```

G1 processes those selected regions.

Live objects are evacuated into other regions.

The selected regions can then be reclaimed.

---

# 21. G1 Remembered Set

Consider:

```text
Old Region
    |
    +------> Young Region
```

Suppose G1 wants to collect the young region.

It needs to know whether references from other regions point into that region.

A **Remembered Set (RSet)** helps maintain this information.

This avoids scanning the entire heap every time.

### Interview answer

> A remembered set is GC bookkeeping that helps a collector identify references from outside a region into that region.

---

# 22. G1 Advantages

- Good balance between throughput and latency
- Suitable for large heaps
- Region-based design
- Concurrent marking
- Evacuation-based compaction
- Can work toward pause-time goals
- General-purpose server collector

---

# 23. G1 Disadvantages

- More complex than Serial/Parallel GC
- Uses CPU for concurrent GC work
- Requires additional bookkeeping
- Can have higher overhead in some workloads
- Pause-time targets are goals, not hard guarantees

### Interview statement

> G1 is generally a good default choice for many server applications, but the correct collector should ultimately be selected based on workload measurements.

---

# 24. ZGC

ZGC means:

**Z Garbage Collector**

ZGC is designed primarily for **very low pause times**, especially on large heaps.

It was introduced experimentally in **JDK 11** and became production-ready in **JDK 15**.

Enable:

```bash
-XX:+UseZGC
```

### Main goal

The primary goal is:

```text
Very low GC pause times
```

ZGC performs most of its expensive work concurrently with application threads.

---

# 25. ZGC Internal Idea

A simplified model:

```text
Application
████████████████████████

ZGC
  ██████████████████████
  Concurrent GC work
```

ZGC uses advanced mechanisms including:

- concurrent marking
- concurrent relocation
- load barriers
- colored pointers
- region-based heap management

The important interview point is:

> ZGC performs much of the GC work concurrently, allowing very low pause times even with large heaps.

---

# 26. ZGC Advantages

- Extremely low pause times
- Suitable for large heaps
- Concurrent marking
- Concurrent relocation
- Excellent for latency-sensitive applications

### Disadvantages

- Can consume additional CPU
- More complex than simpler collectors
- May trade some throughput for lower latency
- Not necessary for every application

---

# 27. Shenandoah GC

Shenandoah is another low-pause garbage collector.

It was integrated into upstream OpenJDK in JDK 12 as an experimental collector and became a product feature in JDK 15.

Its main goal is:

```text
Low pause time
+
Concurrent GC
+
Concurrent evacuation/compaction
```

It is conceptually similar to ZGC in that it focuses heavily on keeping pauses low, although its implementation techniques differ.

---

# 28. ZGC vs G1

This is a very common interview comparison.

| Feature | G1 | ZGC |
|---|---|---|
| Main goal | Balance throughput/latency | Very low latency |
| Heap organization | Regions | Regions |
| Concurrent work | Yes | Yes |
| Evacuation/relocation | Yes | Yes |
| Typical use | General server workloads | Latency-sensitive workloads |
| Pause target | Yes | Extremely low pause design |

### Simple answer

```text
G1 → General-purpose balance

ZGC → Very low latency
```

Do not say:

> "ZGC is always faster than G1."

The correct collector depends on the workload.

---

# 29. Important GC Comparison

| Collector | Main Goal | Important Characteristic |
|---|---|---|
| Serial | Simplicity | Single GC thread |
| Parallel | Throughput | Multiple GC threads |
| CMS | Low pauses | Historical concurrent collector |
| G1 | Balance | Region-based + evacuation |
| ZGC | Very low latency | Highly concurrent |
| Shenandoah | Very low latency | Concurrent evacuation |
| Epsilon | No reclamation | Testing/benchmarking |

---

# 30. GC History — Interview Perspective

You don't need to memorize every release detail, but remember this progression:

```text
Serial
  ↓
Parallel
  ↓
CMS
  ↓
G1
  ↓
ZGC / Shenandoah
```

The overall evolution was driven by changing requirements:

```text
Simple memory management
        ↓
Higher throughput
        ↓
Lower pauses
        ↓
Large heaps
        ↓
Very low latency
```

### Important dates

```text
G1  → JDK 7u4 support
G1  → Default in JDK 9

CMS → Deprecated JDK 9
CMS → Removed JDK 14

ZGC → Experimental JDK 11
ZGC → Production JDK 15

Epsilon → Experimental JDK 11

Shenandoah → Experimental upstream OpenJDK 12
Shenandoah → Product feature JDK 15
```

---

# 31. Memory Leak in Java

A common misconception is:

> Java doesn't have memory leaks because it has GC.

This is false.

GC can only reclaim objects that are unreachable.

Example:

```java
static List<Employee> employees = new ArrayList<>();

public void addEmployee() {
    employees.add(new Employee());
}
```

Suppose the application no longer needs old employees.

However:

```text
GC Root
   |
static employees
   |
Employee
Employee
Employee
...
```

The objects are still reachable.

Therefore GC cannot reclaim them.

### Key interview statement

> GC removes unreachable objects, not objects that the application no longer logically needs.

---

# 32. OutOfMemoryError vs Memory Leak

## OutOfMemoryError

Means the JVM cannot satisfy a memory requirement.

Example:

```text
java.lang.OutOfMemoryError: Java heap space
```

## Memory Leak

Objects continue to be reachable even though they are no longer logically required.

A memory leak can eventually cause:

```text
Memory Leak
    ↓
Heap usage increases
    ↓
GC becomes more frequent
    ↓
GC spends more CPU
    ↓
Application performance degrades
    ↓
OutOfMemoryError
```

But a memory leak is not the only possible cause of `OutOfMemoryError`.

---

# 33. System.gc()

Java provides:

```java
System.gc();
```

This is a request to the JVM to perform garbage collection.

It does **not** guarantee immediate collection.

Therefore:

```java
System.gc();
```

should not normally be used as an application-level memory-management strategy.

### Interview answer

> `System.gc()` is only a request/hint to the JVM. It does not guarantee that GC will immediately occur.

---

# 34. GC Logs

GC logs are extremely important when debugging GC problems.

Modern JVMs commonly use:

```bash
-Xlog:gc*
```

Example:

```bash
java -Xlog:gc* -jar application.jar
```

GC logs can help determine:

- how frequently GC happens
- how long pauses last
- how much memory is reclaimed
- heap occupancy before/after GC
- whether Full GC is occurring
- allocation pressure
- promotion behavior
- concurrent GC activity

---

# 35. Important GC Performance Metrics

When investigating GC, focus on:

### 1. Allocation Rate

How quickly the application creates objects.

```text
GB allocated / second
```

### 2. Live Set

How much memory is occupied by objects that remain reachable.

### 3. GC Frequency

How often collections occur.

### 4. Pause Time

How long application threads are stopped.

### 5. GC CPU Usage

How much CPU is consumed by GC.

### 6. Promotion Rate

How quickly objects move toward old-generation treatment.

---

# 36. How to Troubleshoot High GC

If an application has high GC activity, don't immediately change GC flags.

Follow this approach:

```text
1. Check GC logs
        ↓
2. Check GC pause times
        ↓
3. Check allocation rate
        ↓
4. Check heap occupancy
        ↓
5. Check live objects
        ↓
6. Check promotion
        ↓
7. Check for memory leaks
        ↓
8. Tune only after understanding the problem
```

Useful tools include:

```text
jstat
jcmd
JFR
JConsole
VisualVM
Heap Dump
Eclipse MAT
```

---

# 37. Most Important Interview Questions

## Basic

### What is GC?

Automatic JVM memory management that reclaims memory from unreachable objects.

### When is an object eligible for GC?

When it is no longer reachable from any GC Root.

### Does `obj = null` immediately delete the object?

No. It can make the object unreachable, but GC timing is controlled by the JVM.

### Can Java have memory leaks?

Yes. Objects can remain reachable even though they are no longer logically needed.

---

## Intermediate

### What is Young GC?

A collection focused primarily on young-generation objects.

### What is Stop-The-World?

A period during which application threads are paused for a JVM operation.

### What is object promotion?

Moving surviving objects toward old-generation/old-region treatment.

### What is compaction?

Moving live objects together to reduce fragmentation.

### What is the difference between parallel and concurrent?

Parallel means multiple GC threads work simultaneously.

Concurrent means GC work can happen while application threads continue running.

---

## Advanced

### Why was G1 introduced?

To provide a better balance between throughput and pause-time behavior, especially for large heaps.

### What is G1's Collection Set?

The regions selected for processing during a particular G1 collection pause.

### What is a Remembered Set?

Bookkeeping that tracks relevant references into a region from outside that region.

### Why was CMS removed?

Because of fragmentation, tuning complexity and limitations compared with newer collectors.

### G1 vs ZGC?

```text
G1 → General-purpose balance

ZGC → Extremely low latency
```

### Why does GC consume CPU?

Because GC needs CPU cycles for marking, scanning, copying, evacuation, compaction, reference processing and bookkeeping.

### Can increasing heap size fix GC problems?

Not always.

A larger heap may reduce GC frequency, but if the application has a large live set, a memory leak, excessive allocation, or an unsuitable collector, simply increasing the heap may not solve the problem.

---

# 38. Final Interview Cheat Sheet

```text
GC
==
Automatic JVM memory management.

Garbage
========
Object unreachable from GC Roots.

GC Roots
========
Starting points for reachability analysis.

Heap
====
Memory where Java objects are normally allocated.

Young Generation
================
Mostly short-lived objects.

Old Generation
==============
Long-lived objects.

Young GC
========
Collection focused on young objects.

STW
===
Application threads temporarily stop.

Safepoint
=========
A state where JVM can safely perform certain operations.

Mark
====
Find live objects.

Sweep
=====
Reclaim unreachable objects.

Compact
=======
Move live objects together.

Evacuation
==========
Move live objects from one area to another.

Parallel
========
Multiple GC threads.

Concurrent
==========
GC works while application continues.

Serial
======
Simple, single-threaded collector.

Parallel GC
===========
Throughput-oriented collector.

CMS
===
Historical low-pause collector.
Deprecated JDK 9.
Removed JDK 14.

G1
==
Region-based general-purpose collector.
Default from JDK 9.

ZGC
===
Very-low-latency collector.
Experimental JDK 11.
Production JDK 15.

Shenandoah
==========
Low-pause concurrent collector.
Upstream OpenJDK experimental JDK 12.
Product feature JDK 15.

Memory Leak
===========
Objects are still reachable but no longer needed.

System.gc()
============
Request/hint, not a guarantee.

GC Logs
=======
-Xlog:gc*

Important Metrics
=================
Allocation rate
Live set
GC frequency
Pause time
GC CPU
Promotion rate
```

## Best way to prepare for an interview

Don't try to memorize every GC flag. Be able to explain this flow naturally:

```text
Object allocation
      ↓
Young Generation
      ↓
Object becomes unreachable
      ↓
GC Roots / Reachability Analysis
      ↓
Live vs Garbage
      ↓
Mark / Sweep / Evacuation / Compaction
      ↓
Young GC / Old GC
      ↓
STW vs Concurrent
      ↓
Choose collector
      ↓
Monitor GC logs
      ↓
Tune based on measurements
```

If you can explain **GC Roots → reachability → Young/Old → promotion → STW → Mark/Sweep/Compact → Serial/Parallel/CMS/G1/ZGC → memory leak → GC logs**, you have covered most of the Java GC theory asked in typical backend/Spring/Java interviews.