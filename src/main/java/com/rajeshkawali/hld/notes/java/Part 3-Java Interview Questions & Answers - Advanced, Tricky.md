# JAVA INTERVIEW Q&A — PART 3
## Advanced, Tricky, Output-Based & Senior-Level Java Questions

> **Continuation of Part 1 and Part 2**
>
> Part 1 ended at **Q155**.  
> Part 2 should continue from **Q156**.  
> This supplement contains additional questions that should be added after Part 2.

---

# SECTION 43 — JAVA LANGUAGE TRICKY QUESTIONS

## Q1. Is Java pass-by-value or pass-by-reference?

Java is **always pass-by-value**.

For primitives, the actual value is copied.

For objects, the **reference value is copied**.

Example:

```java
class Person {
    String name;
}

public class Test {

    static void change(Person p) {
        p.name = "John";
    }

    public static void main(String[] args) {

        Person person = new Person();
        person.name = "Alice";

        change(person);

        System.out.println(person.name);
    }
}
```

Output:

```text
John
```

Why?

The copied reference still points to the same object.

But:

```java
static void change(Person p) {
    p = new Person();
    p.name = "John";
}
```

does not change the caller's reference.

### Interview answer

> "Java is always pass-by-value. When an object is passed, Java copies the reference value, not the object itself. Therefore the method can modify the object's state through that copied reference, but it cannot replace the caller's reference."

---

## Q2. What is the difference between `==` and `equals()`?

`==` compares:

- primitive values for primitives
- references for objects

`equals()` compares logical equality if the class overrides it.

Example:

```java
String a = new String("Java");
String b = new String("Java");

System.out.println(a == b);
System.out.println(a.equals(b));
```

Output:

```text
false
true
```

`==` checks whether both references point to the same object.

`equals()` checks whether the objects are logically equal.

---

## Q3. What is Integer caching?

Java caches certain `Integer` values.

Commonly, values from:

```text
-128 to 127
```

are cached.

Example:

```java
Integer a = 127;
Integer b = 127;

System.out.println(a == b);
```

Usually:

```text
true
```

But:

```java
Integer a = 128;
Integer b = 128;

System.out.println(a == b);
```

Usually:

```text
false
```

The important interview point is:

> Never use `==` to compare wrapper objects when logical equality is intended. Use `equals()`.

---

## Q4. What is autoboxing?

Autoboxing automatically converts a primitive into its wrapper type.

```java
int x = 10;

Integer y = x;
```

Conceptually:

```java
Integer y = Integer.valueOf(x);
```

---

## Q5. What is unboxing?

Unboxing converts a wrapper object into a primitive.

```java
Integer x = 10;

int y = x;
```

Conceptually:

```java
int y = x.intValue();
```

---

## Q6. What is a NullPointerException caused by unboxing?

Example:

```java
Integer value = null;

int x = value;
```

This causes:

```text
NullPointerException
```

because Java attempts to unbox `null`.

### Interview trap

```java
Integer x = null;

if (x > 0) {
    System.out.println("Positive");
}
```

The comparison causes unboxing and therefore throws `NullPointerException`.

---

## Q7. What is method overloading with `null`?

Consider:

```java
void test(String value) {
    System.out.println("String");
}

void test(Integer value) {
    System.out.println("Integer");
}

test(null);
```

This results in a compilation error because `null` can match both `String` and `Integer`, and neither is more specific than the other.

---

## Q8. What happens if one overloaded parameter type is more specific?

Example:

```java
void test(Object value) {
    System.out.println("Object");
}

void test(String value) {
    System.out.println("String");
}

test(null);
```

Output:

```text
String
```

Because `String` is more specific than `Object`.

---

# SECTION 44 — OBJECT CLASS & METHOD BEHAVIOR

## Q9. What methods are important from Object?

Important methods include:

```java
equals()
hashCode()
toString()
getClass()
clone()
wait()
notify()
notifyAll()
```

`Object` is the root class of Java's class hierarchy.

---

## Q10. What is `getClass()`?

It returns the runtime class of an object.

Example:

```java
String value = "Java";

System.out.println(value.getClass());
```

Output is conceptually:

```text
class java.lang.String
```

It is commonly used in reflection and type inspection.

---

## Q11. Can static methods be overridden?

No.

Static methods are **hidden**, not overridden.

Example:

```java
class Parent {

    static void show() {
        System.out.println("Parent");
    }
}

class Child extends Parent {

    static void show() {
        System.out.println("Child");
    }
}
```

Now:

```java
Parent p = new Child();

p.show();
```

Output:

```text
Parent
```

Because static method resolution is based on the reference type.

---

## Q12. Can private methods be overridden?

No.

A private method is not inherited by subclasses in the normal overriding sense.

Example:

```java
class Parent {

    private void show() {
        System.out.println("Parent");
    }
}

class Child extends Parent {

    private void show() {
        System.out.println("Child");
    }
}
```

These are separate methods.

---

## Q13. What is a covariant return type?

A subclass overriding method can return a subtype of the original return type.

Example:

```java
class Animal {
}

class Dog extends Animal {
}

class Parent {

    Animal getAnimal() {
        return new Animal();
    }
}

class Child extends Parent {

    @Override
    Dog getAnimal() {
        return new Dog();
    }
}
```

`Dog` is a subtype of `Animal`.

---

# SECTION 45 — INITIALIZATION ORDER

## Q14. What is the initialization order of a Java class?

A simplified order is:

1. Static fields
2. Static initialization blocks
3. Instance fields
4. Instance initialization blocks
5. Constructor

Static initialization occurs when the class is initialized.

Instance initialization occurs when an object is created.

---

## Q15. Which executes first: static block or constructor?

Static initialization happens before the constructor.

Example:

```java
class Test {

    static {
        System.out.println("Static");
    }

    {
        System.out.println("Instance");
    }

    Test() {
        System.out.println("Constructor");
    }
}
```

Creating:

```java
new Test();
```

produces:

```text
Static
Instance
Constructor
```

The static block executes when the class is initialized, typically before the first active use that requires initialization.

---

## Q16. What happens with parent and child initialization?

For:

```java
class Parent {
    static {
        System.out.println("Parent static");
    }

    {
        System.out.println("Parent instance");
    }

    Parent() {
        System.out.println("Parent constructor");
    }
}

class Child extends Parent {
    static {
        System.out.println("Child static");
    }

    {
        System.out.println("Child instance");
    }

    Child() {
        System.out.println("Child constructor");
    }
}
```

Creating:

```java
new Child();
```

gives the conceptual order:

```text
Parent static
Child static
Parent instance
Parent constructor
Child instance
Child constructor
```

---

# SECTION 46 — STRING TRAPS

## Q17. What is the String pool?

The String pool is a JVM-managed pool of canonical string instances.

String literals can be reused.

Example:

```java
String a = "Java";
String b = "Java";

System.out.println(a == b);
```

Usually:

```text
true
```

because both references point to the same pooled string.

---

## Q18. What is the difference between String literal and `new String()`?

```java
String a = "Java";
String b = new String("Java");
```

`a` refers to the pooled string.

`b` explicitly creates a new String object.

Therefore:

```java
a == b
```

is:

```text
false
```

while:

```java
a.equals(b)
```

is:

```text
true
```

---

## Q19. What does `intern()` do?

`intern()` returns the canonical representation of a string from the string pool.

Example:

```java
String a = new String("Java");

String b = a.intern();

String c = "Java";

System.out.println(b == c);
```

Output:

```text
true
```

---

## Q20. Why is String immutable?

String immutability provides several benefits:

- security
- thread safety
- string pooling
- stable hash codes
- safe use as HashMap keys
- easier caching

Example:

```java
String s = "Java";

s.concat(" Programming");

System.out.println(s);
```

Output:

```text
Java
```

because `concat()` creates a new String.

---

## Q21. Why is String a good HashMap key?

String is immutable.

Therefore, once used as a key, its equality-relevant state does not unexpectedly change.

This makes it suitable for hash-based collections.

---

# SECTION 47 — HASHMAP INTERNALS & COLLECTION TRAPS

## Q22. What is the difference between capacity and size in HashMap?

**Size** means the number of mappings currently stored.

**Capacity** represents the number of buckets available before resize thresholds are reached.

Example:

```java
Map<String, Integer> map = new HashMap<>();
```

Initially, the internal table is lazily initialized in modern implementations; capacity concepts become relevant when the table is allocated.

---

## Q23. What is load factor?

Load factor controls when a HashMap should resize based on the amount of data relative to its capacity.

The default load factor is commonly:

```text
0.75
```

Conceptually:

```text
resize threshold ≈ capacity × load factor
```

---

## Q24. What happens when HashMap exceeds its resize threshold?

The map grows its internal table and redistributes entries according to the new capacity.

Resizing can be expensive, which is why choosing a reasonable initial capacity can improve performance when the approximate number of entries is known.

---

## Q25. What happens when two keys have the same hash code?

They can map to the same bucket.

HashMap then uses equality checks to determine whether the keys are actually equal.

Therefore:

```text
hashCode()
```

helps locate candidates, while:

```text
equals()
```

helps identify the matching key.

---

## Q26. Can two unequal objects have the same hashCode?

Yes.

This is called a collision.

The hashCode contract does **not** require unequal objects to have different hash codes.

---

## Q27. Can two equal objects have different hashCodes?

No.

If:

```java
a.equals(b)
```

is true, then:

```java
a.hashCode() == b.hashCode()
```

must be true.

---

## Q28. What happens if a mutable HashMap key changes after insertion?

This is a major interview trap.

Example:

```java
class Employee {

    String id;

    Employee(String id) {
        this.id = id;
    }

    @Override
    public boolean equals(Object o) {
        // equality based on id
        return true; // simplified
    }

    @Override
    public int hashCode() {
        return id.hashCode();
    }
}
```

If `id` changes after the object is inserted into a HashMap, its hash code may change.

The map may no longer be able to find the key using the new state.

### Interview answer

> "Keys used in hash-based collections should preferably be immutable with respect to the fields used by equals and hashCode."

---

## Q29. What is LinkedHashMap?

`LinkedHashMap` maintains a predictable iteration order.

It can maintain:

- insertion order
- access order

Access-order mode is useful for implementing LRU-style caches.

---

## Q30. What is TreeMap?

`TreeMap` is a sorted map.

It is typically implemented using a Red-Black tree.

Operations such as lookup, insertion and removal are generally:

```text
O(log n)
```

It maintains ordering according to natural ordering or a supplied Comparator.

---

## Q31. What is PriorityQueue?

`PriorityQueue` is a heap-based priority queue.

The head represents the highest-priority element according to its ordering.

By default, the smallest element has priority.

Example:

```java
PriorityQueue<Integer> queue = new PriorityQueue<>();

queue.add(30);
queue.add(10);
queue.add(20);

System.out.println(queue.poll());
```

Output:

```text
10
```

Important:

> Iterating over a PriorityQueue does not guarantee sorted order. `poll()` repeatedly retrieves elements according to priority.

---

# SECTION 48 — ITERATORS & MODIFICATION

## Q32. What is ConcurrentModificationException?

It commonly occurs when a collection is structurally modified while being iterated using an iterator that detects such modification.

Example:

```java
List<String> names =
        new ArrayList<>(List.of("A", "B", "C"));

for (String name : names) {

    if (name.equals("B")) {
        names.remove(name);
    }
}
```

This can cause:

```text
ConcurrentModificationException
```

---

## Q33. How can you safely remove elements while iterating?

Use the iterator:

```java
Iterator<String> iterator = names.iterator();

while (iterator.hasNext()) {

    String name = iterator.next();

    if (name.equals("B")) {
        iterator.remove();
    }
}
```

Alternatively, use:

```java
names.removeIf(name -> name.equals("B"));
```

---

## Q34. What does fail-fast mean?

A fail-fast iterator attempts to detect structural modification and may throw `ConcurrentModificationException`.

Important:

> Fail-fast behavior is a bug-detection mechanism, not a thread-safety guarantee.

---

## Q35. What is the difference between fail-fast and weakly consistent iterators?

Fail-fast iterators may throw `ConcurrentModificationException` when structural modification is detected.

Concurrent collections such as `ConcurrentHashMap` provide weakly consistent iterators.

They do not generally throw `ConcurrentModificationException` merely because another thread modifies the collection.

---

# SECTION 49 — GENERICS DEEP DIVE

## Q36. What is type erasure?

Java generics are primarily implemented through type erasure.

Generic type information is largely removed or transformed at runtime.

Example:

```java
List<String> names;
```

and:

```java
List<Integer> numbers;
```

are both represented as `List` at runtime for many reflective/runtime purposes.

---

## Q37. Why can't we write `new T()`?

Because the runtime generally does not know the actual type represented by `T` due to type erasure.

Instead, a factory or `Class<T>` token can be used when appropriate.

---

## Q38. Why can't we create a generic array like this?

```java
T[] array = new T[10];
```

Because arrays are reified at runtime while generic type parameters are erased.

---

## Q39. What is a raw type?

Using a generic type without specifying its type parameter:

```java
List list = new ArrayList();
```

instead of:

```java
List<String> list = new ArrayList<>();
```

Raw types reduce type safety and should generally be avoided in new code.

---

## Q40. What is heap pollution?

Heap pollution occurs when a variable of a parameterized type refers to an object that is not of the expected parameterized type.

Raw types and unchecked operations can cause it.

Example:

```java
List<String> names = new ArrayList<>();

List raw = names;

raw.add(100);

String value = names.get(0);
```

The final operation can cause:

```text
ClassCastException
```

---

# SECTION 50 — EXCEPTION HANDLING DEEP DIVE

## Q41. What is try-with-resources?

It automatically closes resources that implement `AutoCloseable`.

Example:

```java
try (BufferedReader reader =
         new BufferedReader(new FileReader("data.txt"))) {

    System.out.println(reader.readLine());

}
```

The resource is automatically closed.

---

## Q42. What is AutoCloseable?

`AutoCloseable` defines:

```java
void close() throws Exception;
```

It allows an object to be used with try-with-resources.

`Closeable` extends `AutoCloseable` and is commonly used for I/O resources.

---

## Q43. What are suppressed exceptions?

Suppose an exception occurs inside the try block and another exception occurs while closing the resource.

The close exception can become a **suppressed exception** attached to the primary exception.

You can inspect them with:

```java
exception.getSuppressed();
```

---

## Q44. What is exception chaining?

Exception chaining preserves the original cause.

Example:

```java
try {
    // operation
} catch (SQLException e) {
    throw new RuntimeException("Database operation failed", e);
}
```

The second argument preserves the original exception as the cause.

---

## Q45. When should you create a custom exception?

Create a custom exception when the application has a meaningful domain-specific failure condition.

Example:

```java
class InsufficientBalanceException
        extends RuntimeException {

    public InsufficientBalanceException(String message) {
        super(message);
    }
}
```

---

# SECTION 51 — MULTITHREADING TRAPS

## Q46. What is the difference between `start()` and `run()`?

This is one of the most common interview questions.

```java
Thread thread = new Thread(() -> {
    System.out.println("Running");
});

thread.start();
```

`start()` asks the JVM to start a new thread.

Calling:

```java
thread.run();
```

is just a normal method call and does not start a new thread.

---

## Q47. What is the difference between sleep and wait?

### `Thread.sleep()`

- belongs to Thread
- pauses the current thread
- does not release an intrinsic monitor lock held by the thread

### `Object.wait()`

- belongs to Object
- must be called while owning that object's monitor
- releases that monitor while waiting
- resumes after notification/interruption and reacquiring the monitor

---

## Q48. What is `join()`?

`join()` allows one thread to wait for another thread to terminate.

Example:

```java
Thread worker = new Thread(() -> {
    // work
});

worker.start();

worker.join();
```

The current thread waits until `worker` completes.

---

## Q49. What is a race condition?

A race condition occurs when multiple threads access shared state and the result depends on timing/interleaving.

Example:

```java
count++;
```

is not automatically atomic.

It involves conceptually:

```text
read
modify
write
```

Multiple threads can interfere with each other.

---

## Q50. Is volatile enough for `count++`?

No.

```java
volatile int count;
```

provides visibility and ordering guarantees, but:

```java
count++;
```

is still a compound read-modify-write operation.

Use synchronization or an atomic class when atomicity is required.

---

## Q51. What is AtomicInteger?

`AtomicInteger` supports atomic operations on an integer using concurrency primitives such as CAS.

Example:

```java
AtomicInteger counter = new AtomicInteger();

counter.incrementAndGet();
```

This avoids explicit locking for supported atomic operations.

---

## Q52. What is CAS?

CAS means:

**Compare-And-Set**

Conceptually:

```text
if current value == expected value
    replace it with new value
else
    fail/retry
```

It is a fundamental technique behind many lock-free/low-lock concurrent data structures.

---

# SECTION 52 — LOCKS & SYNCHRONIZATION

## Q53. What is `ReentrantLock`?

`ReentrantLock` is an explicit locking mechanism.

Example:

```java
Lock lock = new ReentrantLock();

lock.lock();

try {
    // critical section
} finally {
    lock.unlock();
}
```

Always release the lock in `finally`.

---

## Q54. Why use ReentrantLock instead of synchronized?

`ReentrantLock` provides additional features such as:

- `tryLock()`
- timed lock acquisition
- interruptible lock acquisition
- optional fairness configuration
- multiple condition objects

`synchronized` is simpler and often preferable when these features are unnecessary.

---

## Q55. What is ReadWriteLock?

It separates:

- read lock
- write lock

Multiple readers can often proceed concurrently, while writing requires exclusive access.

Useful when:

```text
reads >> writes
```

and the workload benefits from concurrent reads.

---

## Q56. What is Semaphore?

A Semaphore controls access to a limited number of permits.

Example:

```java
Semaphore semaphore = new Semaphore(10);
```

It can allow at most 10 concurrent operations to acquire permits.

Useful for limiting access to:

- external services
- scarce resources
- connection-like resources

---

## Q57. What is CountDownLatch?

A `CountDownLatch` allows one or more threads to wait until a count reaches zero.

Example:

```java
CountDownLatch latch = new CountDownLatch(3);
```

Workers call:

```java
latch.countDown();
```

Waiting thread calls:

```java
latch.await();
```

A latch is generally one-shot.

---

## Q58. What is CyclicBarrier?

A `CyclicBarrier` allows a group of threads to wait for each other at a common synchronization point.

Unlike a CountDownLatch, a barrier can be reused.

---

## Q59. What is ThreadLocal?

`ThreadLocal` provides thread-confined storage.

Each thread gets its own value.

Example:

```java
ThreadLocal<String> context =
        new ThreadLocal<>();

context.set("request-id");
```

Important production concern:

> With thread pools, ThreadLocal values can remain attached to reused worker threads if not cleaned up appropriately.

---

# SECTION 53 — EXECUTORS & THREAD POOLS

## Q60. Why use ExecutorService?

Instead of manually creating a new thread for every task, an `ExecutorService` manages task execution using reusable worker threads or other execution strategies.

Example:

```java
ExecutorService executor =
        Executors.newFixedThreadPool(5);

executor.submit(() -> {
    System.out.println("Task");
});

executor.shutdown();
```

---

## Q61. Why are unbounded thread pools dangerous?

Creating too many threads can cause:

- memory pressure
- context switching
- CPU overhead
- resource exhaustion
- poor latency

Thread pools should be designed based on workload.

---

## Q62. What is the difference between CPU-bound and I/O-bound tasks?

### CPU-bound

Examples:

- calculations
- compression
- encryption

Performance is primarily limited by CPU.

### I/O-bound

Examples:

- database calls
- HTTP calls
- file operations

Threads can spend significant time waiting.

Thread-pool sizing should consider the workload rather than blindly choosing a large number.

---

## Q63. What is ExecutorService shutdown?

```java
executor.shutdown();
```

prevents new tasks from being submitted while allowing already submitted tasks to finish.

```java
executor.shutdownNow();
```

attempts to stop execution by interrupting worker threads.

It does not guarantee immediate termination.

---

## Q64. What is a rejected execution?

A task can be rejected when an executor cannot accept it—for example, after shutdown or when a bounded executor queue is full and its rejection policy requires rejection.

`ThreadPoolExecutor` supports policies such as:

- AbortPolicy
- CallerRunsPolicy
- DiscardPolicy
- DiscardOldestPolicy

---

# SECTION 54 — COMPLETABLEFUTURE

## Q65. What is CompletableFuture?

`CompletableFuture` supports asynchronous computation and composition.

Example:

```java
CompletableFuture
    .supplyAsync(() -> "Java")
    .thenApply(value -> value + " Programming")
    .thenAccept(System.out::println);
```

---

## Q66. What is the difference between thenApply and thenCompose?

`thenApply()` transforms a result.

```java
future.thenApply(value -> transform(value));
```

If `transform()` itself returns a `CompletableFuture`, you can end up with nested futures.

`thenCompose()` flattens asynchronous operations.

Conceptually:

```text
thenApply:
T -> U

thenCompose:
T -> CompletableFuture<U>
```

---

## Q67. What is thenCombine?

It combines two independent CompletableFutures.

Example:

```java
CompletableFuture<String> user =
        CompletableFuture.supplyAsync(() -> "User");

CompletableFuture<String> order =
        CompletableFuture.supplyAsync(() -> "Order");

CompletableFuture<String> result =
        user.thenCombine(
            order,
            (u, o) -> u + " " + o
        );
```

---

## Q68. How do you handle CompletableFuture exceptions?

Common mechanisms include:

```java
exceptionally()
```

```java
handle()
```

```java
whenComplete()
```

Example:

```java
future
    .thenApply(this::process)
    .exceptionally(ex -> {
        return "fallback";
    });
```

---

# SECTION 55 — DEADLOCK, LIVELOCK & STARVATION

## Q69. What is deadlock?

Deadlock occurs when threads wait indefinitely for resources held by each other.

Example:

```text
Thread A holds Lock 1
Thread A waits for Lock 2

Thread B holds Lock 2
Thread B waits for Lock 1
```

Neither can proceed.

---

## Q70. How can you prevent deadlocks?

Common techniques:

- consistent lock ordering
- reduce lock scope
- avoid unnecessary nested locking
- use timed `tryLock()`
- avoid calling external code while holding locks

---

## Q71. What is livelock?

Threads remain active but continuously respond to each other without making progress.

Unlike deadlock, threads are not necessarily blocked.

---

## Q72. What is starvation?

Starvation occurs when a thread repeatedly fails to obtain CPU time or required resources because other threads dominate access.

---

# SECTION 56 — JVM MEMORY

## Q73. What is the difference between heap and stack?

### Heap

Generally contains objects and arrays.

Shared across threads.

### Stack

Each thread has its own stack containing stack frames for method invocations, local variables, operand stacks, and related execution state.

---

## Q74. What causes StackOverflowError?

Usually excessive or infinite recursion.

Example:

```java
void test() {
    test();
}
```

Eventually:

```text
StackOverflowError
```

---

## Q75. What causes OutOfMemoryError?

Possible causes include:

- heap exhaustion
- excessive object retention
- oversized allocations
- class metadata exhaustion
- native memory exhaustion
- thread/resource exhaustion

The exact message and subsystem matter when diagnosing it.

---

## Q76. What is a Java memory leak?

Java has garbage collection, but memory leaks are still possible.

A leak occurs when objects are no longer logically needed but remain reachable from GC roots.

Common causes:

- static collections
- unbounded caches
- listeners not removed
- ThreadLocal misuse
- long-lived objects retaining large object graphs

---

## Q77. What are GC roots?

Objects reachable from GC roots are considered candidates for retention.

Common GC roots include:

- active thread stacks
- static references
- JNI references
- certain JVM/runtime structures

If an object is reachable from a GC root, it generally cannot be reclaimed.

---

## Q78. Does `System.gc()` force garbage collection?

No.

```java
System.gc();
```

is a request/suggestion to the JVM.

The JVM is not required to perform a collection because of that call.

---

# SECTION 57 — GARBAGE COLLECTION

## Q79. What is garbage collection?

Garbage collection automatically identifies objects that are no longer reachable and reclaims their memory.

The JVM provides several collectors and configurations.

---

## Q80. What is generational garbage collection?

The generational hypothesis assumes that many objects die young.

Therefore, heaps are commonly organized conceptually around younger and older objects.

The exact layout and implementation depend on the collector and JVM version.

---

## Q81. What is G1 GC?

G1, or Garbage-First Garbage Collector, divides the heap into regions and aims to provide predictable pause-time characteristics while collecting regions with high amounts of reclaimable garbage.

It is designed for large heaps and modern server workloads.

---

# SECTION 58 — JAVA MEMORY MODEL

## Q82. What is the Java Memory Model?

The Java Memory Model defines rules for:

- visibility
- ordering
- atomicity interactions
- synchronization between threads

It determines when one thread's actions become visible to another.

---

## Q83. What is happens-before?

A happens-before relationship establishes ordering and visibility guarantees between actions.

Examples include:

- unlocking a monitor happens-before a subsequent lock on that monitor
- writing to a volatile variable happens-before a subsequent read of that variable
- actions before `Thread.start()` happen-before actions in the started thread
- actions in a thread happen-before another thread successfully returns from `join()`

---

## Q84. What is safe publication?

Safe publication means making an object visible to other threads in a way that guarantees they observe a properly constructed state.

Techniques include:

- synchronization
- volatile references in appropriate designs
- static initialization
- concurrent collections
- immutable objects with proper construction/publication

---

# SECTION 59 — IMMUTABILITY & THREAD SAFETY

## Q85. How do you design an immutable class?

Typical rules:

1. Make the class final when appropriate.
2. Make fields private.
3. Make fields final.
4. Initialize fields through the constructor.
5. Do not provide setters.
6. Defensively copy mutable inputs.
7. Do not expose mutable internal state.

Example:

```java
public final class Employee {

    private final String name;
    private final List<String> skills;

    public Employee(
            String name,
            List<String> skills) {

        this.name = name;
        this.skills =
            List.copyOf(skills);
    }

    public String getName() {
        return name;
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

---

# SECTION 60 — SOLID DEEP DIVE

## Q86. What is SOLID?

SOLID represents five design principles:

```text
S - Single Responsibility Principle
O - Open/Closed Principle
L - Liskov Substitution Principle
I - Interface Segregation Principle
D - Dependency Inversion Principle
```

---

## Q87. What is Single Responsibility Principle?

A class should have one primary responsibility and one reason to change.

Bad:

```java
class EmployeeService {

    void calculateSalary() {}

    void saveToDatabase() {}

    void sendEmail() {}

    void generatePdf() {}
}
```

These responsibilities can often be separated.

---

## Q88. What is Open/Closed Principle?

Software entities should generally be:

```text
open for extension
closed for modification
```

Strategy and polymorphism are common ways to achieve this.

---

## Q89. What is Liskov Substitution Principle?

Subtypes should be usable wherever their base types are expected without breaking the correctness of the program.

Classic example:

```text
Square extends Rectangle
```

can create conceptual problems if Rectangle assumes independently mutable width and height.

The key is behavioral substitutability, not merely inheritance syntax.

---

## Q90. What is Interface Segregation Principle?

Clients should not be forced to depend on methods they do not need.

Prefer smaller focused interfaces over large "god interfaces."

---

## Q91. What is Dependency Inversion Principle?

High-level modules should not depend directly on low-level implementation details.

Both should depend on abstractions where appropriate.

---

# SECTION 61 — DESIGN PATTERNS

## Q92. What is Singleton?

Singleton ensures that a class has a controlled single instance within the relevant scope.

A robust Java implementation can use an enum:

```java
enum Singleton {
    INSTANCE
}
```

However, singleton should not be used automatically. It introduces global state and can complicate testing.

---

## Q93. What is Builder pattern?

Builder separates construction of a complex object from its representation.

Example:

```java
Employee employee =
    new Employee.Builder()
        .name("John")
        .department("IT")
        .salary(50000)
        .build();
```

Useful when:

- many optional parameters
- readable object creation
- immutable objects

---

## Q94. What is Strategy pattern?

Strategy encapsulates interchangeable algorithms behind a common abstraction.

Example:

```java
interface PaymentStrategy {
    void pay();
}
```

Implementations:

```text
CreditCardPayment
PaypalPayment
UPIPayment
```

The caller can select the strategy without changing the calling code.

---

## Q95. What is Factory pattern?

Factory centralizes object creation.

Instead of:

```java
new PdfReport()
new ExcelReport()
new CsvReport()
```

the caller can use:

```java
Report report =
    ReportFactory.create(type);
```

This separates creation logic from usage.

---

## Q96. What is Adapter pattern?

Adapter allows incompatible interfaces to work together.

It wraps an existing implementation and exposes the interface expected by the client.

---

## Q97. What is Decorator pattern?

Decorator dynamically adds behavior to an object without modifying the original class.

It is based on composition and wrapping.

---

## Q98. What is Proxy pattern?

A proxy provides a substitute or intermediary around another object.

Common uses include:

- lazy loading
- access control
- logging
- transactions
- remote calls

Frameworks frequently use proxies.

---

# SECTION 62 — MODERN JAVA

## Q99. What is a record?

A record is a concise way to model data-oriented classes.

Example:

```java
public record Employee(
        Long id,
        String name,
        String department) {
}
```

The compiler provides implementations for methods such as:

- accessors
- `equals()`
- `hashCode()`
- `toString()`

based on record components.

Important:

> A record is not automatically deeply immutable. If a component refers to a mutable object, that object can still be mutable.

---

## Q100. What is a sealed class?

A sealed class restricts which classes can extend it.

Example:

```java
public sealed class Payment
        permits CardPayment, CashPayment {
}
```

This is useful when the domain has a controlled hierarchy.

---

## Q101. What is pattern matching for instanceof?

Instead of:

```java
if (obj instanceof String) {
    String value = (String) obj;
}
```

modern Java can use:

```java
if (obj instanceof String value) {
    System.out.println(value.length());
}
```

The pattern performs the type test and introduces a correctly typed variable.

---

## Q102. What is a switch expression?

Modern Java supports switch expressions.

Example:

```java
String result = switch (status) {
    case NEW -> "New";
    case COMPLETED -> "Done";
    case FAILED -> "Failed";
    default -> "Unknown";
};
```

Unlike the traditional statement form, a switch expression produces a value.

---

## Q103. What are virtual threads?

Virtual threads are lightweight Java threads managed by the JVM rather than being permanently tied one-to-one with operating-system threads.

They are particularly useful for applications with very large numbers of concurrent tasks that spend substantial time blocked on I/O.

Example:

```java
Thread.startVirtualThread(() -> {
    System.out.println("Running");
});
```

Important interview point:

> Virtual threads improve scalability for many blocking/concurrent workloads; they do not magically make CPU-bound work faster.

---

# SECTION 63 — FUNCTIONAL INTERFACES

## Q104. What is Predicate?

`Predicate<T>` represents a boolean-valued function.

```java
Predicate<Integer> positive =
    n -> n > 0;
```

---

## Q105. What is Function?

`Function<T, R>` transforms one type into another.

```java
Function<String, Integer> length =
    String::length;
```

---

## Q106. What is Consumer?

`Consumer<T>` accepts a value and returns nothing.

```java
Consumer<String> printer =
    System.out::println;
```

---

## Q107. What is Supplier?

`Supplier<T>` produces a value without accepting an input.

```java
Supplier<Double> random =
    Math::random;
```

---

## Q108. What is a method reference?

A method reference is a shorter syntax for certain lambdas.

Instead of:

```java
names.forEach(name ->
    System.out.println(name));
```

we can write:

```java
names.forEach(System.out::println);
```

---

# SECTION 64 — STREAM TRAPS

## Q109. What is lazy evaluation in Streams?

Intermediate operations are generally lazy.

Example:

```java
stream
    .filter(...)
    .map(...)
```

does not necessarily execute immediately.

Execution generally begins when a terminal operation is invoked.

---

## Q110. Can a Stream be reused?

No.

Once a terminal operation has consumed a Stream, it cannot normally be reused.

Example:

```java
Stream<String> stream =
    names.stream();

stream.count();

stream.forEach(System.out::println);
```

The second operation throws:

```text
IllegalStateException
```

---

## Q111. What is the difference between map and flatMap?

`map()` transforms each element.

```java
List<String> names =
    List.of("A", "B");

names.stream()
     .map(String::toLowerCase);
```

`flatMap()` transforms and flattens nested structures.

Example:

```java
List<List<Integer>> values =
    List.of(
        List.of(1, 2),
        List.of(3, 4)
    );

List<Integer> result =
    values.stream()
          .flatMap(List::stream)
          .toList();
```

Result:

```text
[1, 2, 3, 4]
```

---

## Q112. What is the difference between findFirst and findAny?

`findFirst()` respects encounter order when the stream has one.

`findAny()` may return any matching element and can provide more flexibility in parallel execution.

---

## Q113. What is peek()?

`peek()` allows observing elements as they flow through a stream.

Example:

```java
stream
    .peek(System.out::println)
    .map(...)
    .toList();
```

It is primarily intended for debugging/observation, not for essential business side effects.

---

## Q114. What is reduce()?

`reduce()` combines stream elements into a single result.

Example:

```java
int sum =
    numbers.stream()
           .reduce(0, Integer::sum);
```

---

## Q115. What is groupingBy?

It groups stream elements by a classifier.

Example:

```java
Map<String, List<Employee>> employeesByDept =
    employees.stream()
        .collect(
            Collectors.groupingBy(
                Employee::getDepartment
            )
        );
```

---

# SECTION 65 — OPTIONAL

## Q116. What is Optional?

`Optional<T>` represents a value that may or may not be present.

Example:

```java
Optional<String> name =
    Optional.ofNullable(value);
```

It can make absence explicit in certain APIs.

---

## Q117. What is the difference between orElse and orElseGet?

```java
optional.orElse(createDefault());
```

The default expression is evaluated even when the Optional contains a value.

Whereas:

```java
optional.orElseGet(() -> createDefault());
```

computes the fallback lazily when needed.

This distinction matters when fallback creation is expensive or has side effects.

---

# SECTION 66 — EQUALS, HASHCODE & TOSTRING: ADVANCED INTERVIEW

## Q118. How would you implement equals(), hashCode(), and toString() in a live interview?

Before writing code, say:

> "First I'll identify which fields define the logical identity of this object. I'll use those same identity fields consistently in equals and hashCode. Then I'll create a readable toString that helps debugging without exposing sensitive information."

Example:

```java
import java.util.Objects;

public class Employee {

    private Long id;
    private String name;
    private String department;

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof Employee)) {
            return false;
        }

        Employee employee = (Employee) o;

        return Objects.equals(id, employee.id)
                && Objects.equals(name, employee.name)
                && Objects.equals(
                    department,
                    employee.department
                );
    }

    @Override
    public int hashCode() {
        return Objects.hash(
            id,
            name,
            department
        );
    }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", department='" +
                department + '\'' +
                '}';
    }
}
```

### Interview explanation

> "`equals()` determines logical equality. `hashCode()` must use the same equality fields because equal objects must have equal hash codes. `toString()` provides a readable debugging representation."

---

## Q119. Should every field be included in equals()?

No.

Only fields that define the object's logical identity should generally participate.

For example, if employee salary changes but employee identity does not, salary may not belong in equality.

---

## Q120. Why is using mutable fields in hashCode dangerous?

Suppose:

```java
Set<Employee> employees =
    new HashSet<>();

employees.add(employee);
```

If a field used by `hashCode()` changes afterward, the object can effectively become located in the wrong logical bucket.

The set may fail to find or remove the object.

---

## Q121. What is the difference between getClass() and instanceof in equals()?

Option 1:

```java
if (o == null ||
    getClass() != o.getClass()) {
    return false;
}
```

This requires exact runtime class equality.

Option 2:

```java
if (!(o instanceof Employee)) {
    return false;
}
```

This permits compatible subtype comparisons.

There is no universal answer.

The correct choice depends on the class hierarchy and equality design.

### Senior interview answer

> "I choose getClass() or instanceof based on the equality semantics I want. With inheritance, I have to be especially careful about symmetry and transitivity."

---

## Q122. How do arrays behave in equals()?

Arrays do not use deep content equality through normal `Object.equals()`.

Use:

```java
Arrays.equals(array1, array2);
```

For nested arrays:

```java
Arrays.deepEquals(...)
```

Likewise:

```java
Arrays.hashCode(...)
```

or:

```java
Arrays.deepHashCode(...)
```

may be required.

---

## Q123. What is the BigDecimal equals() trap?

```java
BigDecimal a =
    new BigDecimal("10.0");

BigDecimal b =
    new BigDecimal("10.00");
```

Then:

```java
a.equals(b)
```

is:

```text
false
```

because scale matters for `equals()`.

But:

```java
a.compareTo(b) == 0
```

is:

```text
true
```

because numerical value comparison ignores scale.

This is a very good senior-level interview question.

---

## Q124. Should passwords be included in toString()?

Absolutely not.

Avoid:

```java
password='secret'
```

in logs or `toString()`.

The same applies to:

- access tokens
- API keys
- authentication credentials
- sensitive personal information

---

## Q125. Can toString() cause StackOverflowError?

Yes.

Circular object relationships can cause recursive `toString()` calls.

Example:

```text
Employee -> Department -> Employee
```

If each object's `toString()` prints the other object completely, recursion can occur.

---

# SECTION 67 — JPA EQUALS/HASHCODE INTERVIEW

## Q126. Why is equals/hashCode difficult for JPA entities?

Entity identity can change during the lifecycle.

For example, an ID may be generated only after persistence.

Also, Hibernate may use proxy classes.

Therefore there is no single universal equals/hashCode implementation that is correct for every JPA model.

### Interview answer

> "For JPA entities, I would first understand whether identity is based on a natural business key or database-generated ID, how the entity lifecycle works, and whether proxies are involved. I would avoid blindly generating equals/hashCode without considering those semantics."

---

# SECTION 68 — REFLECTION

## Q127. What is reflection?

Reflection allows Java code to inspect and interact with classes, fields, methods, constructors and annotations at runtime.

Example:

```java
Class<?> clazz =
    Employee.class;

System.out.println(clazz.getName());
```

Frameworks such as dependency injection and ORM frameworks use reflection extensively, although modern frameworks may combine it with generated code and other mechanisms.

---

## Q128. What are disadvantages of reflection?

Potential disadvantages include:

- reduced compile-time safety
- more complex code
- harder debugging
- accessibility concerns
- possible performance overhead
- stronger coupling to implementation details

Use reflection when it solves a real framework/dynamic-programming requirement.

---

# SECTION 69 — ANNOTATION DEEP DIVE

## Q129. What is @Retention?

`@Retention` specifies how long an annotation should be retained.

Common policies:

```text
SOURCE
CLASS
RUNTIME
```

`RUNTIME` annotations are available through reflection at runtime.

---

## Q130. What is @Target?

`@Target` specifies where an annotation may be used.

For example:

```java
@Target(ElementType.METHOD)
```

restricts the annotation to methods.

---

## Q131. How do you create a custom annotation?

Example:

```java
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.METHOD)
public @interface Auditable {

    String value();
}
```

---

# SECTION 70 — DATE & TIME API

## Q132. Why should modern Java use java.time?

The `java.time` API is generally preferred over legacy date/time classes because it provides clearer, more robust APIs and immutable types.

Important classes include:

```text
LocalDate
LocalTime
LocalDateTime
Instant
ZonedDateTime
Duration
Period
ZoneId
```

---

## Q133. Difference between LocalDateTime and Instant?

`LocalDateTime` has no timezone or UTC offset.

```java
LocalDateTime.now();
```

`Instant` represents a point on the global UTC timeline.

```java
Instant.now();
```

For distributed systems, an `Instant` is often useful when representing an absolute timestamp.

---

## Q134. What is a common timezone mistake?

Using:

```java
LocalDateTime
```

as if it represented an absolute moment in time.

For example, "10:00" without a timezone is ambiguous.

When timezone meaning matters, use an appropriate type such as:

```java
ZonedDateTime
```

or:

```java
Instant
```

with a separately defined timezone when presenting to users.

---

# SECTION 71 — JAVA I/O & NIO

## Q135. Difference between InputStream and Reader?

`InputStream` works with bytes.

`Reader` works with characters.

Therefore:

```text
InputStream -> binary data
Reader      -> character data
```

Examples:

```java
FileInputStream
```

and:

```java
FileReader
```

---

## Q136. What is buffering?

Buffering reduces the number of expensive underlying I/O operations by accumulating data and processing it in larger chunks.

Example:

```java
BufferedReader reader =
    new BufferedReader(
        new FileReader("file.txt"));
```

---

## Q137. What is Path and Files?

Modern Java NIO provides:

```java
Path
Files
```

Example:

```java
Path path = Path.of("data.txt");

String content =
    Files.readString(path);
```

This is generally more convenient than many older `File` APIs.

---

# SECTION 72 — JAVA HTTP CLIENT

## Q138. How can Java make HTTP calls?

Modern Java provides:

```java
java.net.http.HttpClient
```

Example:

```java
HttpClient client =
    HttpClient.newHttpClient();

HttpRequest request =
    HttpRequest.newBuilder()
        .uri(URI.create("https://example.com"))
        .GET()
        .build();

HttpResponse<String> response =
    client.send(
        request,
        HttpResponse.BodyHandlers.ofString()
    );
```

In production systems, frameworks or dedicated HTTP clients may also be used depending on requirements.

---

# SECTION 73 — TESTING

## Q139. What is unit testing?

A unit test verifies a small unit of behavior, usually in isolation.

Example:

```java
@Test
void shouldCalculateTotal() {
    assertEquals(
        100,
        calculator.calculate(50, 50)
    );
}
```

---

## Q140. What is mocking?

Mocking creates a test double that allows you to control or verify interactions with dependencies.

For example:

```text
OrderService
    |
    +--> PaymentService
```

A test can mock `PaymentService` to isolate `OrderService`.

---

## Q141. Mock vs stub?

A **stub** primarily provides predefined responses.

A **mock** is commonly used to verify interactions as well as provide behavior.

---

# SECTION 74 — PERFORMANCE INTERVIEW QUESTIONS

## Q142. How do you investigate a slow Java application?

Do not immediately start changing code.

A strong process is:

1. Confirm the symptom.
2. Measure latency.
3. Check CPU.
4. Check memory.
5. Check GC.
6. Check thread activity.
7. Check database latency.
8. Check external API latency.
9. Profile if necessary.
10. Identify the bottleneck.
11. Fix the bottleneck.
12. Measure again.

### Senior interview answer

> "I prefer evidence-driven optimization. First I identify whether the bottleneck is CPU, memory, GC, locking, database, network, or external dependency latency. Then I profile or inspect the relevant metrics before changing the implementation."

---

## Q143. What causes high CPU in Java?

Possible causes include:

- infinite loops
- excessive computation
- inefficient algorithms
- excessive serialization
- excessive logging
- lock contention/spinning
- too many runnable threads
- GC overhead

A thread dump and CPU profile can help identify the source.

---

## Q144. What would you do if production has OutOfMemoryError?

A strong approach:

1. Identify which memory area is exhausted.
2. Check application logs.
3. Inspect GC behavior.
4. Capture/analyze heap dump when appropriate.
5. Identify dominant retained objects.
6. Look for unbounded caches or collections.
7. Check ThreadLocal usage.
8. Check traffic changes.
9. Fix the retention/allocation problem.
10. Validate under realistic load.

Do not simply increase heap size without understanding the cause.

---

# SECTION 75 — THREAD DUMP & HEAP DUMP

## Q145. What is a thread dump?

A thread dump provides information about JVM threads, including:

- thread state
- stack traces
- locks
- blocked/waiting threads

It is useful for diagnosing:

- deadlocks
- thread pool problems
- blocked threads
- stuck requests
- CPU issues

---

## Q146. What is a heap dump?

A heap dump is a snapshot of heap objects and their relationships.

It can help investigate:

- memory leaks
- retained objects
- large collections
- unexpected object growth

---

## Q147. What is Java Flight Recorder?

Java Flight Recorder, or JFR, provides low-overhead runtime diagnostics and profiling information.

It can help analyze:

- CPU
- allocations
- GC
- threads
- locks
- I/O
- application behavior

---

# SECTION 76 — CACHE DESIGN

## Q148. What is caching?

Caching stores frequently accessed data closer to the application to reduce expensive operations.

Benefits:

- lower latency
- reduced database load
- improved throughput

Risks:

- stale data
- invalidation complexity
- memory consumption
- cache stampede

---

## Q149. What is cache stampede?

A cache stampede occurs when a popular cached entry expires and many requests simultaneously attempt to rebuild it.

Possible solutions include:

- locking
- request coalescing
- early refresh
- randomized expiration
- stale-while-revalidate strategies

---

# SECTION 77 — RETRY & RESILIENCE

## Q150. Should every failed request be retried?

No.

Retry only when the failure is potentially transient and the operation is safe to repeat.

Examples:

```text
connection timeout
temporary network failure
temporary service unavailable
```

Do not blindly retry permanent validation failures.

---

## Q151. Why use exponential backoff?

Instead of retrying immediately:

```text
1s
2s
4s
8s
```

the client progressively waits longer.

This prevents many clients from repeatedly hammering an unhealthy service.

---

## Q152. Why add jitter?

If every client retries at exactly:

```text
1s
2s
4s
8s
```

they can synchronize and create another traffic spike.

Random jitter spreads retries over time.

---

# SECTION 78 — MICROSERVICE JAVA INTERVIEW

## Q153. What is idempotency?

An operation is idempotent if performing it multiple times has the same intended final effect as performing it once.

For example:

```text
PUT /users/10
```

can be designed to be idempotent.

For payments, idempotency keys are commonly used to prevent duplicate processing.

---

## Q154. What is a circuit breaker?

A circuit breaker prevents repeated calls to an unhealthy downstream service.

Typical states:

```text
CLOSED
OPEN
HALF_OPEN
```

When failures exceed a threshold, the circuit can open and fail fast.

---

## Q155. What is graceful degradation?

When a dependency fails, instead of making the entire system fail, the application provides a reduced but useful experience.

Example:

```text
Recommendation service unavailable
        ↓
Return product details without recommendations
```

---

# SECTION 79 — CONNECTION POOLS

## Q156. Why use a database connection pool?

Creating database connections repeatedly is expensive.

A connection pool:

1. creates a controlled number of connections
2. reuses them
3. limits concurrent database access
4. reduces connection establishment overhead

---

## Q157. What happens if the connection pool is exhausted?

Requests may wait for an available connection.

If waiting exceeds the configured timeout, the application may fail with a connection acquisition timeout.

Symptoms can include:

- increased latency
- request timeouts
- thread pool growth/blocking
- cascading failures

---

# SECTION 80 — SENIOR PRODUCTION SCENARIOS

## Q158. API latency suddenly increased. How would you debug it?

I would break the request into components:

```text
Client
  ↓
Application
  ↓
Database
  ↓
External services
  ↓
Cache
```

Then compare current metrics with the normal baseline.

I would investigate:

- CPU
- GC
- thread pools
- connection pools
- database query latency
- external service latency
- cache hit ratio
- recent deployments
- traffic volume

The key is:

> "I would measure first and isolate the bottleneck before making changes."

---

## Q159. Application has many threads but low throughput. Why?

Possible reasons:

- threads blocked on I/O
- lock contention
- database connection pool exhaustion
- external service latency
- excessive context switching
- oversized thread pool
- CPU saturation
- queue contention

More threads do not automatically mean more throughput.

---

## Q160. Database is slow. Should you increase the Java thread pool?

Usually no.

If all threads are waiting on the database, adding more application threads may increase database pressure and make the situation worse.

First investigate:

- slow queries
- indexes
- connection pool
- database CPU
- locks
- query plans
- transaction duration

---

## Q161. Production is returning intermittent HTTP 500 errors. How do you investigate?

I would:

1. correlate timestamps
2. inspect application logs
3. inspect stack traces
4. correlate request IDs
5. check downstream failures
6. check database errors
7. check thread/connection pool metrics
8. check recent deployments
9. reproduce if possible
10. inspect distributed traces

Intermittent failures often require correlation across services rather than looking at one log line.

---

# SECTION 81 — JAVA TRICKY OUTPUT QUESTIONS

## Q162. What is the output?

```java
String a = "Java";
String b = "Java";

System.out.println(a == b);
System.out.println(a.equals(b));
```

Answer:

```text
true
true
```

Because both literals can refer to the same pooled String.

---

## Q163. What is the output?

```java
String a = new String("Java");
String b = new String("Java");

System.out.println(a == b);
System.out.println(a.equals(b));
```

Answer:

```text
false
true
```

---

## Q164. What is the output?

```java
Integer a = 100;
Integer b = 100;

System.out.println(a == b);
```

Typically:

```text
true
```

because of Integer caching.

But do not depend on wrapper identity.

Use:

```java
a.equals(b)
```

for value comparison.

---

## Q165. What is the output?

```java
List<Integer> list =
    new ArrayList<>();

list.add(1);
list.add(2);
list.add(3);

list.remove(1);

System.out.println(list);
```

Output:

```text
[1, 3]
```

Why?

The literal `1` is interpreted as an `int`, so Java selects:

```java
remove(int index)
```

Therefore index `1` is removed.

---

## Q166. How would you remove the Integer value 1?

Use:

```java
list.remove(Integer.valueOf(1));
```

Now Java selects:

```java
remove(Object)
```

and removes the value `1`.

---

## Q167. What is the output?

```java
try {
    System.out.println("try");
} finally {
    System.out.println("finally");
}
```

Output:

```text
try
finally
```

---

## Q168. What is the dangerous output question?

```java
static int test() {

    try {
        return 10;
    } finally {
        return 20;
    }
}
```

The result is:

```text
20
```

The `finally` return overrides the earlier return.

### Interview warning

Never use `return` inside `finally` in normal application code.

It can suppress exceptions and make control flow difficult to understand.

---

## Q169. What happens here?

```java
static int test() {

    try {
        return 10;
    } finally {
        System.out.println("cleanup");
    }
}
```

The method returns:

```text
10
```

but before returning, the `finally` block executes.

Output:

```text
cleanup
```

and return value:

```text
10
```

---

# SECTION 82 — COMMON JAVA INTERVIEW TRAPS

## Q170. Is HashMap thread-safe?

No.

If multiple threads concurrently modify a HashMap without proper synchronization, behavior is not safe.

For concurrent use, consider:

```java
ConcurrentHashMap
```

or appropriate external synchronization/design.

---

## Q171. Is ConcurrentHashMap completely lock-free?

No.

`ConcurrentHashMap` uses highly concurrent techniques, including CAS and synchronization in parts of its implementation depending on the operation/state.

Do not describe it simply as "lock-free."

---

## Q172. Does synchronized make everything thread-safe?

No.

Synchronization only protects the critical sections where it is correctly applied.

Thread safety is a property of the overall design.

---

## Q173. Is volatile a replacement for synchronized?

No.

`volatile` provides visibility and ordering guarantees for a variable, but it does not provide mutual exclusion or atomicity for compound operations.

---

## Q174. Is ArrayList thread-safe?

No.

For concurrent access, choose an appropriate concurrent design such as:

```java
CopyOnWriteArrayList
```

for suitable read-heavy workloads, or use synchronization/other concurrency mechanisms depending on the access pattern.

---

## Q175. Is CopyOnWriteArrayList good for frequent writes?

Usually no.

Every structural write can require copying the underlying array.

It is most suitable when:

```text
reads >> writes
```

and iteration consistency characteristics are acceptable.

---

# SECTION 83 — JAVA MODULE SYSTEM

## Q176. What is the Java Module System?

The Java Platform Module System allows applications to organize code into explicit modules with controlled dependencies and exported packages.

A module can declare:

```java
module com.example.app {

    requires java.sql;

    exports com.example.api;
}
```

---

## Q177. What is the difference between exports and opens?

`exports` makes packages accessible to other modules through normal Java access.

`opens` permits deep reflection access to the package.

This distinction is important for frameworks that use reflection.

---

# SECTION 84 — MAVEN & DEPENDENCY MANAGEMENT

## Q178. What is Maven?

Maven is a build and dependency-management tool.

It can handle:

- compilation
- testing
- packaging
- dependency management
- plugins
- lifecycle phases

Configuration is commonly stored in:

```text
pom.xml
```

---

## Q179. What is a transitive dependency?

If:

```text
Application
   ↓
Library A
   ↓
Library B
```

and Library A depends on Library B, the application may receive Library B transitively.

Dependency management determines which version is ultimately selected when conflicts occur.

---

## Q180. What is a dependency conflict?

Suppose:

```text
Library A -> Jackson 2.x
Library B -> Jackson 3.x
```

The application may need dependency management to resolve the resulting version conflict.

Senior engineers should understand dependency trees and version alignment.

---

# SECTION 85 — SECURITY

## Q181. Why should secrets not be logged?

Logs often have broad access and long retention.

Logging:

```text
password
API key
access token
session secret
```

can create a serious security problem.

Never assume `toString()` is private just because it is called for debugging.

---

## Q182. Encryption vs hashing?

### Encryption

Designed to be reversible with a key.

Used when data needs to be recovered.

### Hashing

Designed as a one-way transformation.

Used for integrity and, with appropriate password-hashing algorithms, password storage.

Passwords should generally be processed using dedicated password hashing algorithms rather than reversible encryption.

---

# SECTION 86 — LIVE CODING APPROACH

## Q183. How should I approach a Java live-coding problem?

Use this sequence:

### Step 1 — Clarify

Ask:

```text
What is the input?
What is the output?
Can input be null?
Can the collection be empty?
Are duplicates allowed?
What constraints should I consider?
```

### Step 2 — Explain approach

Say:

> "I'll first explain the approach before coding so we can confirm the direction."

### Step 3 — Start with a simple solution

Do not immediately jump into the most complicated algorithm.

### Step 4 — Code

Use readable variable names.

### Step 5 — Test

Test:

- normal case
- empty input
- null if relevant
- one element
- duplicates
- boundary cases

### Step 6 — Complexity

Explain:

```text
Time: O(...)
Space: O(...)
```

### Step 7 — Discuss improvements

Mention alternatives and trade-offs.

---

# SECTION 87 — LIVE EQUALS/HASHCODE/TOSTRING SCRIPT

## Q184. What should I say while coding equals/hashCode/toString?

A strong interview explanation:

> "First, I need to determine what defines logical identity for this class."

Then:

> "I'll use those same fields in equals and hashCode so the contract is preserved."

Then:

> "I'll make equals null-safe and handle the type appropriately."

Then:

> "For toString, I'll include useful debugging fields but exclude sensitive information such as passwords or tokens."

Then code:

```java
@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Employee)) {
        return false;
    }

    Employee other = (Employee) o;

    return Objects.equals(id, other.id)
        && Objects.equals(name, other.name);
}

@Override
public int hashCode() {
    return Objects.hash(id, name);
}

@Override
public String toString() {
    return "Employee{" +
        "id=" + id +
        ", name='" + name + '\'' +
        '}';
}
```

Then test:

```java
Employee e1 =
    new Employee(1L, "John");

Employee e2 =
    new Employee(1L, "John");

System.out.println(e1.equals(e2));
System.out.println(e1.hashCode() == e2.hashCode());
System.out.println(e1);
```

Finally say:

> "The important contract is that equal objects must have equal hash codes. The reverse is not required."

That sentence is especially valuable in an interview.

---

# SECTION 88 — CODING QUESTIONS TO PRACTICE

## Q185. Reverse a String

```java
String reverse(String value) {
    return new StringBuilder(value)
            .reverse()
            .toString();
}
```

---

## Q186. Check palindrome

```java
boolean isPalindrome(String value) {

    String reversed =
        new StringBuilder(value)
            .reverse()
            .toString();

    return value.equals(reversed);
}
```

For a senior interview, discuss whether you can solve it in O(1) extra space using two pointers.

---

## Q187. Find duplicate elements

```java
Set<Integer> seen =
    new HashSet<>();

Set<Integer> duplicates =
    new HashSet<>();

for (Integer value : numbers) {

    if (!seen.add(value)) {
        duplicates.add(value);
    }
}
```

Expected complexity:

```text
Time: O(n) average
Space: O(n)
```

---

## Q188. Find first non-repeated character

A common approach:

1. Count frequencies using LinkedHashMap.
2. Iterate in insertion order.
3. Find frequency equal to one.

Example:

```java
Map<Character, Integer> count =
    new LinkedHashMap<>();

for (char c : value.toCharArray()) {
    count.merge(c, 1, Integer::sum);
}

for (Map.Entry<Character, Integer> entry
        : count.entrySet()) {

    if (entry.getValue() == 1) {
        return entry.getKey();
    }
}
```

---

## Q189. Find second-highest number

Stream approach:

```java
Optional<Integer> secondHighest =
    numbers.stream()
        .distinct()
        .sorted(Comparator.reverseOrder())
        .skip(1)
        .findFirst();
```

Interview discussion:

> "This is concise, but sorting makes the complexity O(n log n). If performance matters, I can solve it in O(n) using a single pass."

---

## Q190. Find maximum without sorting

```java
int max =
    numbers.stream()
           .max(Integer::compareTo)
           .orElseThrow();
```

This is generally O(n).

---

# SECTION 89 — SENIOR SCENARIO QUESTIONS

## Q191. How would you design a thread-safe counter?

Possible approaches:

```java
AtomicInteger counter =
    new AtomicInteger();

counter.incrementAndGet();
```

For larger counters under high contention, consider whether:

```java
LongAdder
```

better matches the workload.

---

## Q192. How would you design an LRU cache?

A simple Java approach can use:

```java
LinkedHashMap
```

with access-order enabled and eviction logic.

For production systems, consider:

- concurrency
- memory limits
- expiration
- distributed caching
- eviction policy
- observability

---

## Q193. How would you design a rate limiter?

Clarify:

```text
Requests per second?
Per user?
Per API?
Distributed?
Burst allowed?
What happens when limit is exceeded?
```

Possible algorithms:

- fixed window
- sliding window
- token bucket
- leaky bucket

---

## Q194. What is backpressure?

Backpressure means slowing producers when consumers cannot keep up.

Without backpressure:

```text
Producer
   ↓
Producer
   ↓
Producer
   ↓
Huge queue
   ↓
Memory exhaustion
```

A bounded queue can help prevent unlimited accumulation.

---

## Q195. Why are bounded queues often safer than unbounded queues?

An unbounded queue can keep accepting work until memory becomes exhausted.

A bounded queue forces the system to define what happens when capacity is reached:

- block
- reject
- run in caller
- drop
- degrade

This makes overload behavior explicit.

---

# SECTION 90 — HOW TO ANSWER "I DON'T KNOW"

## Q196. What should I say if I don't know an interview answer?

Do not invent an answer.

Say:

> "I haven't worked with that directly, so I don't want to guess. My understanding is X. If needed, I would verify the exact behavior from the documentation or by creating a small reproduction."

This demonstrates:

- honesty
- engineering maturity
- reasoning ability
- willingness to verify

---

# SECTION 91 — RAPID-FIRE ADVANCED JAVA

## Q197. Is Java purely object-oriented?

No.

Java includes primitives and therefore is not purely object-oriented.

---

## Q198. Is String mutable?

No.

String is immutable.

---

## Q199. Is StringBuilder thread-safe?

No.

---

## Q200. Is StringBuffer synchronized?

Yes, its methods are synchronized, although that does not automatically make every compound operation on a StringBuffer reference safe.

---

## Q201. Does HashSet allow duplicates?

No, according to its equality semantics.

---

## Q202. Does HashMap allow duplicate keys?

No.

Putting a value under an existing key replaces the previous mapping.

---

## Q203. Can HashMap contain null?

Yes.

It permits a null key and null values, subject to its implementation contract.

---

## Q204. Can ConcurrentHashMap contain null?

No.

It does not permit null keys or null values.

---

## Q205. Is ArrayList faster than LinkedList?

Not universally.

ArrayList generally provides fast random access and good cache locality.

LinkedList has cheap insertion/removal when you already have the relevant node/position, but locating that position can be expensive.

For many normal workloads, ArrayList is the better default.

---

## Q206. Comparable vs Comparator?

`Comparable` defines natural ordering inside the type.

```java
class Employee
        implements Comparable<Employee>
```

`Comparator` defines an external/custom ordering.

```java
Comparator<Employee> bySalary =
    Comparator.comparing(Employee::getSalary);
```

---

## Q207. What is immutable?

An immutable object cannot have its observable state changed after construction.

---

## Q208. What is volatile?

A field modifier providing visibility and ordering guarantees between threads; it does not make arbitrary compound operations atomic.

---

## Q209. What is synchronized?

It provides mutual exclusion and establishes memory-visibility/happens-before relationships around monitor operations.

---

## Q210. What is a deadlock?

Threads wait indefinitely for resources held by each other.

---

## Q211. What is a memory leak in Java?

Unneeded objects remain reachable and therefore cannot be garbage-collected.

---

## Q212. What is JIT?

Just-In-Time compilation converts frequently executed bytecode into optimized native machine code at runtime.

---

## Q213. What is a record?

A concise syntax for data-carrier classes with generated members based on record components.

---

## Q214. What is a virtual thread?

A lightweight JVM-managed thread designed to support very high concurrency, particularly for blocking workloads.

---

# SECTION 92 — FINAL SENIOR JAVA CHECKLIST

Before a senior Java interview, make sure you can explain:

### Core Java

- OOP
- abstraction
- inheritance
- polymorphism
- encapsulation
- overloading
- overriding
- static hiding
- final
- abstract
- interfaces
- pass-by-value
- wrappers
- autoboxing
- String immutability
- String pool

### Object methods

- `==`
- `equals()`
- `hashCode()`
- `toString()`
- `getClass()`
- `wait()`
- `notify()`
- `notifyAll()`

### Collections

- ArrayList
- LinkedList
- HashSet
- LinkedHashSet
- TreeSet
- HashMap
- LinkedHashMap
- TreeMap
- ConcurrentHashMap
- PriorityQueue
- CopyOnWriteArrayList
- Queue
- Deque
- BlockingQueue

### Generics

- generic classes
- generic methods
- wildcards
- bounded wildcards
- PECS
- type erasure
- raw types
- heap pollution

### Exceptions

- checked
- unchecked
- Error
- try/catch/finally
- try-with-resources
- AutoCloseable
- suppressed exceptions
- custom exceptions
- exception chaining

### Streams

- map
- filter
- flatMap
- reduce
- collect
- groupingBy
- partitioningBy
- map vs flatMap
- lazy evaluation
- parallel streams
- Optional

### Concurrency

- Thread
- Runnable
- Callable
- Future
- ExecutorService
- ThreadPoolExecutor
- synchronized
- volatile
- AtomicInteger
- CAS
- Lock
- ReentrantLock
- Semaphore
- CountDownLatch
- CyclicBarrier
- ThreadLocal
- CompletableFuture
- deadlock
- livelock
- starvation
- virtual threads

### JVM

- heap
- stack
- Metaspace
- class loading
- class loaders
- JIT
- GC
- GC roots
- memory leak
- OOM
- StackOverflowError
- thread dump
- heap dump
- JFR

### Design

- SOLID
- Singleton
- Factory
- Builder
- Strategy
- Adapter
- Decorator
- Proxy
- composition vs inheritance
- dependency injection

### Modern Java

- records
- sealed classes
- pattern matching
- switch expressions
- lambdas
- method references
- virtual threads
- modern date/time API

### Production

- slow API
- high CPU
- high memory
- OOM
- deadlock
- database bottleneck
- connection pool exhaustion
- thread pool exhaustion
- cache stampede
- retry
- backoff
- jitter
- circuit breaker
- rate limiting
- backpressure
- graceful degradation
- observability

---

# SECTION 93 — FINAL LIVE-CODING CHECKLIST

When the interviewer gives you a coding problem:

```text
1. Understand the requirement
        ↓
2. Ask about constraints
        ↓
3. Identify edge cases
        ↓
4. Explain approach
        ↓
5. Start with simple solution
        ↓
6. Write clean code
        ↓
7. Test with examples
        ↓
8. Test edge cases
        ↓
9. Explain time complexity
        ↓
10. Explain space complexity
        ↓
11. Discuss alternatives
        ↓
12. Improve if necessary
```

For object-method questions:

```text
Identify logical identity
        ↓
Implement equals()
        ↓
Use same fields in hashCode()
        ↓
Implement readable toString()
        ↓
Test equal objects
        ↓
Test unequal objects
        ↓
Test HashSet/HashMap behavior
        ↓
Discuss mutability
```

---

# SECTION 94 — THE MOST IMPORTANT SENIOR INTERVIEW MINDSET

Do not try to prove that you remember every Java API.

A senior engineer should demonstrate:

```text
Understanding
    +
Reasoning
    +
Trade-offs
    +
Debugging ability
    +
Communication
```

When asked:

> "Which collection would you use?"

Do not simply say:

> "ArrayList."

Say:

> "I'd use ArrayList if I need frequent indexed access and mostly append/read operations. If I need sorted keys I'd consider TreeMap, if I need insertion/access ordering I'd consider LinkedHashMap, and if multiple threads concurrently access the map I'd consider ConcurrentHashMap. The choice depends on the workload."

That is a much stronger senior-level answer.

---

# SECTION 95 — FINAL INTERVIEW ANSWER FORMULA

For most Java questions, use:

### 1. Definition

What is it?

### 2. Why

Why does it exist?

### 3. Example

Show a small example.

### 4. Internal behavior

Explain what Java/JVM does when relevant.

### 5. Trade-off

When should you use or avoid it?

### 6. Interview trap

Mention the common mistake.

Example:

> **Question:** Why does HashMap need both hashCode() and equals()?

Strong answer:

> "HashMap uses hashCode() to determine the likely bucket for a key and equals() to identify the matching key within the candidates. Two equal objects must have the same hash code. A collision is allowed between unequal objects, so hashCode alone cannot establish equality."

That answer demonstrates both **knowledge and reasoning**.

---

# SECTION 96 — FINAL JAVA PREPARATION STRATEGY

Do not memorize all questions word-for-word.

Instead, prepare in layers.

### Level 1 — Must know

```text
OOP
String
equals/hashCode
Collections
Exceptions
Java 8
Streams
Generics
```

### Level 2 — Strong Java Developer

```text
Concurrency
ExecutorService
CompletableFuture
JVM
GC
Memory
SOLID
Design patterns
JPA
Spring
```

### Level 3 — Senior

```text
JMM
happens-before
thread dumps
heap dumps
performance
connection pools
cache
resilience
production debugging
system design
```

### Level 4 — Interview Differentiators

```text
Tricky output questions
HashMap internals
equals/hashCode edge cases
JPA equality
Generics/type erasure
Concurrency traps
Virtual threads
GC troubleshooting
Performance reasoning
Live coding communication
```

---

# FINAL REMINDER

The strongest Java interview candidate is not the person who says:

> "I know HashMap."

It is the person who can explain:

> "I know how HashMap works, why hashCode and equals are both required, what happens during collisions and resizing, why mutable keys are dangerous, when ConcurrentHashMap is appropriate, and how I would diagnose a production problem involving excessive map usage."

That is the difference between **memorizing Java interview answers** and demonstrating **real Java engineering knowledge**.

# END OF PART 3

### Coverage added in this supplement

- Java language traps
- Pass-by-value
- Wrapper caching
- Autoboxing/unboxing
- Object methods
- Static method hiding
- Initialization order
- String pool
- `intern()`
- HashMap internals
- HashMap key mutability
- LinkedHashMap
- TreeMap
- PriorityQueue
- Iterators
- ConcurrentModificationException
- Generics/type erasure
- Heap pollution
- Try-with-resources
- Suppressed exceptions
- Deep concurrency
- Locks
- ThreadLocal
- Executors
- CompletableFuture
- Deadlock/livelock/starvation
- JVM memory
- GC
- JMM
- Happens-before
- Safe publication
- Immutability
- SOLID
- Design patterns
- Records
- Sealed classes
- Pattern matching
- Virtual threads
- Functional interfaces
- Advanced Streams
- Optional
- Advanced equals/hashCode/toString
- JPA equality
- Reflection
- Custom annotations
- Date/time
- NIO
- HTTP client
- Testing
- Performance
- Thread dumps
- Heap dumps
- JFR
- Caching
- Resilience
- Microservices scenarios
- Connection pools
- Production troubleshooting
- Tricky output questions
- Security
- Maven/dependencies
- Live coding
- Senior scenarios
- Final revision strategy

# END OF SUPPLEMENT