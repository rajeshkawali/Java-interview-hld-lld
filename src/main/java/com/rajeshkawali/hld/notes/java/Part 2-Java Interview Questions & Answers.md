# Java Interview Questions & Answers — Part 2
## Advanced Java → Senior-Level Interview Preparation

> **How to use this part:** Don't memorize every answer word-for-word. In an interview, first give the short answer, then explain the reasoning and give an example if the interviewer asks for more detail.

---

# 1. MULTITHREADING & CONCURRENCY

## Q1. What is a thread?

A thread is the smallest unit of execution within a process.

A Java application can have multiple threads executing tasks concurrently.

Example:

```java
public class Demo {
    public static void main(String[] args) {

        Thread thread = new Thread(() -> {
            System.out.println("Running in another thread");
        });

        thread.start();

        System.out.println("Main thread");
    }
}
```

Important:

```java
thread.start();
```

creates/schedules a new thread.

Whereas:

```java
thread.run();
```

is just a normal method call and does not start a new thread.

### Interview answer

> A thread is an independent path of execution within a process. Java supports multithreading so multiple tasks can execute concurrently.

---

# 2. Process vs Thread

| Process | Thread |
|---|---|
| Independent program execution | Execution unit inside process |
| Has its own memory space | Shares process memory |
| More expensive | Less expensive |
| Communication is relatively expensive | Communication is easier |
| Process isolation is stronger | Threads share heap |

Example:

A running Java application is a process.

Inside that application, you may have:

```text
Main Thread
   |
   +-- Worker Thread 1
   +-- Worker Thread 2
   +-- GC Thread
   +-- HTTP Worker Thread
```

---

# 3. How do you create a thread?

Common approaches:

### Option 1 — Extend Thread

```java
class MyThread extends Thread {

    @Override
    public void run() {
        System.out.println("Running");
    }
}

public class Demo {
    public static void main(String[] args) {
        MyThread thread = new MyThread();
        thread.start();
    }
}
```

### Option 2 — Implement Runnable

```java
Runnable task = () -> {
    System.out.println("Running");
};

Thread thread = new Thread(task);
thread.start();
```

### Option 3 — ExecutorService

Usually preferred in production code.

```java
ExecutorService executor = Executors.newFixedThreadPool(5);

executor.submit(() -> {
    System.out.println("Task running");
});

executor.shutdown();
```

### Interview answer

> We can create threads by extending Thread or implementing Runnable, but in production applications I generally prefer ExecutorService because it manages thread creation and reuse through thread pools.

---

# 4. What is the thread lifecycle?

A Java thread can move through states such as:

```text
NEW
 |
 | start()
 v
RUNNABLE
 |
 +---- BLOCKED
 |
 +---- WAITING
 |
 +---- TIMED_WAITING
 |
 v
TERMINATED
```

Java officially exposes:

```java
Thread.State
```

with:

```text
NEW
RUNNABLE
BLOCKED
WAITING
TIMED_WAITING
TERMINATED
```

---

# 5. What is the difference between start() and run()?

### `start()`

Creates a new execution path.

```java
thread.start();
```

### `run()`

Executes synchronously in the current thread.

```java
thread.run();
```

Example:

```java
Thread t = new Thread(() -> {
    System.out.println(Thread.currentThread().getName());
});

t.run();
```

This runs on the calling thread.

But:

```java
t.start();
```

allows the JVM to execute it as a separate thread.

### Interview trap

If interviewer asks:

> Does calling `run()` create a new thread?

Answer:

> No. `run()` is an ordinary method call. `start()` is what initiates a new thread of execution.

---

# 6. What is synchronization?

Synchronization controls access to shared mutable data when multiple threads can access it.

Example:

```java
class Counter {

    private int count;

    public synchronized void increment() {
        count++;
    }

    public synchronized int getCount() {
        return count;
    }
}
```

Without synchronization, multiple threads can interfere with each other's updates.

---

# 7. What is a race condition?

A race condition occurs when the result depends on the timing/interleaving of multiple threads accessing shared state.

Example:

```java
count++;
```

looks like one operation but conceptually involves:

```text
read count
add 1
write count
```

Two threads can both read the same value.

For example:

```text
Initial count = 0

Thread A reads 0
Thread B reads 0

Thread A writes 1
Thread B writes 1
```

Expected:

```text
2
```

Actual:

```text
1
```

---

# 8. What does synchronized do?

`synchronized` provides mutual exclusion and also establishes important memory-visibility guarantees.

Example:

```java
public synchronized void withdraw(double amount) {
    balance -= amount;
}
```

Only one thread at a time can execute synchronized code protected by the same monitor.

---

# 9. Synchronized method vs synchronized block

### Method

```java
public synchronized void update() {
    // code
}
```

Locks the object's monitor for an instance method.

### Block

```java
public void update() {

    synchronized (this) {
        // critical section
    }
}
```

A block lets you control exactly what is protected.

You can also synchronize on a dedicated lock:

```java
private final Object lock = new Object();

public void update() {

    synchronized (lock) {
        // critical section
    }
}
```

This is often preferable to exposing `this` as a lock.

---

# 10. What is volatile?

`volatile` is primarily about **visibility and ordering**, not compound-operation atomicity.

Example:

```java
private volatile boolean running = true;
```

If one thread changes:

```java
running = false;
```

other threads reading `running` can observe the update without relying on a stale cached value.

But:

```java
volatile int count;

count++;
```

is still not atomic.

### Interview answer

> Volatile guarantees visibility of writes to other threads and provides ordering guarantees, but it does not make compound operations such as increment atomic.

---

# 11. synchronized vs volatile

| synchronized | volatile |
|---|---|
| Mutual exclusion | No mutual exclusion |
| Visibility | Visibility |
| Protects critical sections | Suitable for simple state/flags |
| Can make compound operations safe | Does not make `count++` atomic |
| Uses locking | No lock acquisition for volatile access |

Example:

```java
volatile boolean running;
```

is reasonable for a simple flag.

For:

```java
balance += amount;
```

you generally need stronger synchronization/atomicity.

---

# 12. What is AtomicInteger?

`AtomicInteger` provides atomic operations without requiring explicit synchronization for those operations.

```java
AtomicInteger counter = new AtomicInteger();

counter.incrementAndGet();

System.out.println(counter.get());
```

Other useful methods:

```java
counter.incrementAndGet();
counter.getAndIncrement();

counter.decrementAndGet();

counter.compareAndSet(10, 20);
```

It is based on atomic CPU-level primitives such as compare-and-set.

---

# 13. What is CAS?

CAS means:

**Compare And Set / Compare And Swap**

Conceptually:

```text
If current value == expected value
    update it
else
    fail
```

Example:

```java
AtomicInteger value = new AtomicInteger(10);

boolean updated = value.compareAndSet(10, 20);
```

If another thread changes the value before the CAS operation, the update may fail.

---

# 14. What is a deadlock?

Deadlock occurs when threads wait indefinitely for locks held by each other.

Example:

```text
Thread A:
locks Resource 1
waits for Resource 2

Thread B:
locks Resource 2
waits for Resource 1
```

Neither can continue.

### How to prevent deadlocks

1. Maintain consistent lock ordering.
2. Avoid unnecessary nested locks.
3. Keep synchronized sections small.
4. Use timed lock acquisition where appropriate.
5. Consider higher-level concurrency utilities.

---

# 15. What is livelock?

In livelock, threads are active but make no useful progress.

Example:

```text
Thread A sees B and moves aside.
Thread B sees A and moves aside.
Thread A moves again.
Thread B moves again.
...
```

The threads are not blocked, but the work never progresses.

---

# 16. What is starvation?

Starvation occurs when a thread cannot get sufficient CPU time or access to a required resource because other threads continually take precedence.

Possible causes:

- unfair locking
- excessive priority differences
- poorly designed thread pools
- long-running tasks occupying limited workers

---

# 17. What is ExecutorService?

`ExecutorService` separates task submission from thread management.

Instead of:

```java
new Thread(task).start();
```

you can do:

```java
ExecutorService executor =
        Executors.newFixedThreadPool(10);

executor.submit(task);

executor.shutdown();
```

Advantages:

- thread reuse
- controlled concurrency
- task queues
- lifecycle management
- easier error handling
- avoids creating unlimited threads

---

# 18. What is a thread pool?

A thread pool maintains reusable worker threads.

Example:

```java
ExecutorService executor =
        Executors.newFixedThreadPool(5);
```

If you submit 100 tasks, you don't necessarily create 100 threads.

Conceptually:

```text
100 tasks
    |
    v
Task Queue
    |
    +--> Worker 1
    +--> Worker 2
    +--> Worker 3
    +--> Worker 4
    +--> Worker 5
```

---

# 19. FixedThreadPool vs CachedThreadPool

### Fixed

```java
Executors.newFixedThreadPool(10);
```

Uses a fixed number of worker threads.

Useful when you want controlled concurrency.

### Cached

```java
Executors.newCachedThreadPool();
```

Can create threads as needed and reuse idle ones.

Be careful with unbounded workloads because thread creation can grow significantly.

---

# 20. Why should we be careful with Executors factory methods?

Some convenience factory methods can hide important queueing or thread-creation behavior.

In production systems, many teams prefer explicitly configuring:

```java
ThreadPoolExecutor
```

with:

- core pool size
- maximum pool size
- queue capacity
- keep-alive time
- rejection policy
- thread factory

Example:

```java
ExecutorService executor =
    new ThreadPoolExecutor(
        5,
        10,
        60,
        TimeUnit.SECONDS,
        new ArrayBlockingQueue<>(100)
    );
```

---

# 21. What is Callable?

`Runnable` does not return a result.

`Callable` can return a result and throw checked exceptions.

```java
Callable<Integer> task = () -> {
    return 10 + 20;
};
```

Submit:

```java
Future<Integer> future = executor.submit(task);
```

Get:

```java
Integer result = future.get();
```

---

# 22. What is Future?

`Future` represents the result of an asynchronous computation.

```java
Future<Integer> future = executor.submit(() -> 100);

Integer result = future.get();
```

Potential issue:

```java
future.get();
```

can block until the computation completes.

Useful methods:

```java
future.get();
future.get(5, TimeUnit.SECONDS);
future.isDone();
future.cancel(true);
```

---

# 23. What is CompletableFuture?

`CompletableFuture` supports asynchronous programming and composition.

Example:

```java
CompletableFuture<String> future =
        CompletableFuture.supplyAsync(() -> "Hello");

future.thenApply(String::toUpperCase)
      .thenAccept(System.out::println);
```

You can compose multiple operations:

```java
CompletableFuture
    .supplyAsync(() -> getUser())
    .thenApply(user -> getOrders(user))
    .thenAccept(orders -> System.out.println(orders));
```

### Important methods

```java
thenApply()
thenAccept()
thenRun()

thenCompose()
thenCombine()

exceptionally()
handle()
whenComplete()

allOf()
anyOf()
```

---

# 24. thenApply vs thenCompose

### thenApply

Used for transforming a result.

```java
future.thenApply(user -> user.getName());
```

### thenCompose

Used when the next operation itself returns a `CompletableFuture`.

```java
future.thenCompose(user ->
    getOrdersAsync(user)
);
```

Think:

```text
thenApply:
A -> B

thenCompose:
A -> Future<B>
```

---

# 25. thenCombine

Used to combine independent asynchronous operations.

```java
CompletableFuture<User> userFuture =
    getUserAsync();

CompletableFuture<Account> accountFuture =
    getAccountAsync();

CompletableFuture<Result> result =
    userFuture.thenCombine(
        accountFuture,
        (user, account) -> new Result(user, account)
    );
```

---

# 26. What are virtual threads?

Virtual threads are lightweight Java threads designed for large numbers of concurrent tasks, particularly blocking I/O workloads.

Example:

```java
Thread.startVirtualThread(() -> {
    System.out.println("Hello");
});
```

Or with an executor:

```java
try (ExecutorService executor =
         Executors.newVirtualThreadPerTaskExecutor()) {

    executor.submit(() -> {
        callRemoteService();
    });
}
```

Virtual threads make it practical to represent many concurrent tasks as threads without requiring one expensive OS thread per task.

### Important interview point

Virtual threads are not automatically faster for CPU-intensive work.

They are especially useful for high-concurrency, blocking I/O workloads.

---

# 27. What is ConcurrentHashMap?

`ConcurrentHashMap` is designed for concurrent access.

```java
ConcurrentHashMap<String, Integer> map =
        new ConcurrentHashMap<>();
```

It supports concurrent reads and updates without synchronizing the entire map for every operation.

Example:

```java
map.computeIfAbsent(
    "Java",
    key -> calculateValue(key)
);
```

This can be safer than manually doing:

```java
if (!map.containsKey(key)) {
    map.put(key, calculateValue(key));
}
```

because the check-and-update sequence is not safely atomic in the latter form.

---

# 28. SynchronizedMap vs ConcurrentHashMap

`Collections.synchronizedMap()` wraps a map with synchronized access.

```java
Map<String, String> map =
    Collections.synchronizedMap(new HashMap<>());
```

`ConcurrentHashMap` is specifically designed for concurrent use and generally provides better scalability for concurrent workloads.

---

# 29. What is CopyOnWriteArrayList?

Useful when:

- reads are frequent
- writes are rare

Example:

```java
CopyOnWriteArrayList<String> list =
    new CopyOnWriteArrayList<>();
```

Each modification creates a new underlying array.

Therefore, it can be expensive for write-heavy workloads.

---

# 30. What is BlockingQueue?

A `BlockingQueue` supports producer-consumer patterns.

```java
BlockingQueue<String> queue =
    new ArrayBlockingQueue<>(100);
```

Producer:

```java
queue.put("task");
```

Consumer:

```java
String task = queue.take();
```

If the queue is full/empty, operations can block according to the API semantics.

---

# 31. JVM INTERNALS

# Q31. What is JVM?

JVM executes Java bytecode.

Typical flow:

```text
Java Source
    |
    | javac
    v
Bytecode (.class)
    |
    v
JVM
    |
    +--> Class Loader
    +--> Runtime Data Areas
    +--> Execution Engine
    +--> Garbage Collector
```

---

# 32. What is JIT?

JIT means:

**Just-In-Time Compiler**

The JVM can identify frequently executed code and compile it into optimized native machine code at runtime.

Conceptually:

```text
Bytecode
   |
   v
Interpreter
   |
Frequently executed code
   |
   v
JIT compilation
   |
   v
Optimized machine code
```

This is one reason long-running Java applications can achieve strong performance.

---

# 33. What is class loading?

Java classes are loaded dynamically.

The JVM class-loading process includes concepts such as:

```text
Loading
Linking
Initialization
```

Linking involves:

```text
Verification
Preparation
Resolution
```

A simplified flow:

```text
Loading
   ↓
Verification
   ↓
Preparation
   ↓
Resolution
   ↓
Initialization
```

---

# 34. What are class loaders?

Common class-loader categories include:

- Bootstrap Class Loader
- Platform Class Loader
- Application/System Class Loader

Class loaders allow classes to be loaded dynamically and support isolation mechanisms such as application/plugin class-loader hierarchies.

---

# 35. What is parent delegation?

When a class loader is asked to load a class, it generally delegates to its parent first.

Conceptually:

```text
Application ClassLoader
        |
        v
Platform ClassLoader
        |
        v
Bootstrap ClassLoader
```

This helps prevent application code from replacing core Java classes unexpectedly.

---

# 36. What is Metaspace?

Metaspace stores JVM metadata associated with classes.

Modern Java uses native memory for Metaspace rather than the old PermGen area.

A common issue is:

```text
OutOfMemoryError: Metaspace
```

which can occur when class metadata usage grows excessively, for example due to problematic dynamic class generation/class-loader retention.

---

# 37. Heap vs Stack

### Heap

Contains objects and arrays.

```java
Employee e = new Employee();
```

The object is allocated on the heap.

### Stack

Each thread has its own stack containing stack frames for method execution.

Conceptually:

```text
Thread 1
  Stack
    main()
    methodA()
    methodB()

Thread 2
  Stack
    run()
    process()
```

The heap is shared among threads.

Each thread has its own stack.

---

# 38. What causes StackOverflowError?

Usually excessive or infinite recursion.

Example:

```java
public void test() {
    test();
}
```

Eventually:

```text
StackOverflowError
```

---

# 39. What causes OutOfMemoryError?

Possible causes include:

- excessive object allocation
- objects remaining reachable unintentionally
- insufficient heap
- huge collections
- class metadata growth
- native memory exhaustion
- other JVM resource constraints

Example:

```java
List<byte[]> list = new ArrayList<>();

while (true) {
    list.add(new byte[1024 * 1024]);
}
```

This can eventually exhaust available heap.

---

# 40. What is a memory leak in Java?

Java has garbage collection, but memory leaks are still possible.

A memory leak occurs when objects are no longer logically needed but remain reachable.

Example:

```java
static List<Object> cache = new ArrayList<>();
```

If objects are continually added and never removed, they remain reachable through the static field.

The GC cannot collect them.

### Interview answer

> In Java, a memory leak usually means objects that are no longer needed are still strongly reachable, so garbage collection cannot reclaim them.

---

# 41. How does Garbage Collection work?

At a high level, GC identifies objects that are no longer reachable from GC roots and reclaims their memory.

Conceptually:

```text
GC Roots
   |
   +--> Object A
   |      |
   |      +--> Object B
   |
   +--> Object C

Object D ---> unreachable
Object E ---> unreachable
```

Objects D and E can potentially be reclaimed.

GC algorithms and collectors vary by Java version and workload.

---

# 42. What are GC roots?

Examples include references from:

- active thread stacks
- static fields
- JNI/native references
- other JVM-managed root structures

An object reachable from a GC root is generally considered reachable.

---

# 43. What is System.gc()?

```java
System.gc();
```

requests that the JVM perform garbage collection.

It is only a request, not a guarantee.

You should generally not rely on it for application correctness or normal memory management.

---

# 44. What are strong, weak, soft and phantom references?

Java provides different reference strengths.

### Strong

Normal reference:

```java
Object obj = new Object();
```

Object normally remains reachable while strongly referenced.

### WeakReference

```java
WeakReference<Object> ref =
    new WeakReference<>(obj);
```

Useful for certain caches/maps where objects should not be kept alive solely by the cache.

### SoftReference

Historically associated with memory-sensitive caches, but modern caching designs generally should not rely heavily on soft references for predictable behavior.

### PhantomReference

Used for advanced lifecycle/cleanup tracking and works with `ReferenceQueue`.

---

# 45. What is the Java Memory Model?

The Java Memory Model defines rules around:

- visibility
- ordering
- atomicity
- interactions between threads

It helps answer:

> When one thread changes data, under what conditions can another thread reliably observe that change?

Important concepts:

```text
happens-before
volatile
synchronized
locks
final-field semantics
```

---

# 46. What is happens-before?

A happens-before relationship establishes ordering and visibility guarantees between actions.

Examples include:

- unlocking a monitor happens-before a subsequent lock of that monitor
- a write to a volatile variable happens-before a subsequent read of that variable
- actions in a thread happen-before another thread successfully returns from `join()`

This is an important concept for advanced concurrency interviews.

---

# 47. DESIGN PRINCIPLES

# Q47. What is SOLID?

SOLID is a collection of object-oriented design principles.

```text
S - Single Responsibility Principle
O - Open/Closed Principle
L - Liskov Substitution Principle
I - Interface Segregation Principle
D - Dependency Inversion Principle
```

---

# 48. Single Responsibility Principle

A class should have one primary responsibility and one reason to change.

Bad:

```java
class EmployeeService {

    void saveEmployee() {}

    void generatePdf() {}

    void sendEmail() {}
}
```

Better:

```text
EmployeeService
PdfService
EmailService
```

---

# 49. Open/Closed Principle

Software entities should generally be:

> Open for extension, closed for modification.

Instead of constantly modifying existing logic, design abstractions that allow new implementations.

Example:

```java
interface PaymentProcessor {
    void pay();
}
```

Implementations:

```java
class CardPayment implements PaymentProcessor {
    public void pay() {}
}

class UpiPayment implements PaymentProcessor {
    public void pay() {}
}
```

Adding another payment mechanism doesn't require changing the existing implementations.

---

# 50. Liskov Substitution Principle

A subtype should be usable wherever its base type is expected without breaking correctness.

Classic problematic example:

```text
Rectangle
   ↑
Square
```

If `Rectangle` exposes independent width/height mutation, treating `Square` as a normal rectangle can violate expected behavior.

### Interview answer

> A subclass should honor the behavioral contract of its parent rather than merely satisfy the inheritance relationship syntactically.

---

# 51. Interface Segregation Principle

Clients should not be forced to depend on methods they don't use.

Bad:

```java
interface Worker {
    void work();
    void eat();
    void sleep();
}
```

A specialized abstraction may be better:

```java
interface Workable {
    void work();
}

interface Eatable {
    void eat();
}
```

---

# 52. Dependency Inversion Principle

High-level modules should depend on abstractions rather than concrete implementations.

Bad:

```java
class OrderService {
    private MySqlRepository repository =
        new MySqlRepository();
}
```

Better:

```java
interface OrderRepository {
    void save(Order order);
}
```

Then:

```java
class OrderService {

    private final OrderRepository repository;

    OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
```

This also makes testing easier.

---

# 53. What is Dependency Injection?

Dependency Injection means dependencies are provided to an object rather than the object constructing them itself.

Example:

```java
class UserService {

    private final UserRepository repository;

    public UserService(UserRepository repository) {
        this.repository = repository;
    }
}
```

This is constructor injection.

Advantages:

- loose coupling
- easier testing
- easier replacement of implementations
- clearer dependencies

---

# 54. Why is constructor injection preferred?

Because:

1. Dependencies are explicit.
2. Fields can be `final`.
3. Object cannot easily exist in an invalid partially initialized state.
4. Unit testing is straightforward.
5. Dependencies are immutable after construction.

---

# 55. Common Design Patterns

Important patterns for Java interviews:

```text
Singleton
Factory
Abstract Factory
Builder
Strategy
Observer
Adapter
Decorator
Template Method
Proxy
Facade
Chain of Responsibility
Command
```

---

# 56. Singleton Pattern

Example:

```java
public final class Singleton {

    private static final Singleton INSTANCE =
        new Singleton();

    private Singleton() {}

    public static Singleton getInstance() {
        return INSTANCE;
    }
}
```

But in modern Java applications, dependency injection containers often manage singleton scope for you.

---

# 57. Builder Pattern

Useful when an object has many optional parameters.

```java
User user = new User.Builder()
        .name("John")
        .age(30)
        .email("john@example.com")
        .build();
```

It improves readability compared with constructors having many parameters.

---

# 58. Strategy Pattern

Use when behavior varies and should be interchangeable.

```java
interface DiscountStrategy {
    double calculate(double amount);
}
```

Implementations:

```java
class RegularDiscount implements DiscountStrategy {
    public double calculate(double amount) {
        return amount * 0.05;
    }
}

class PremiumDiscount implements DiscountStrategy {
    public double calculate(double amount) {
        return amount * 0.20;
    }
}
```

Then:

```java
class CheckoutService {

    private final DiscountStrategy strategy;

    CheckoutService(DiscountStrategy strategy) {
        this.strategy = strategy;
    }
}
```

---

# 59. Factory Pattern

Factory encapsulates object creation.

```java
interface Notification {
    void send();
}
```

Factory:

```java
class NotificationFactory {

    static Notification create(String type) {

        if ("EMAIL".equals(type)) {
            return new EmailNotification();
        }

        if ("SMS".equals(type)) {
            return new SmsNotification();
        }

        throw new IllegalArgumentException(
            "Unknown type"
        );
    }
}
```

---

# 60. MODERN JAVA

# Q60. What is a record?

Records provide a concise way to model data carriers.

Example:

```java
public record Employee(
    Long id,
    String name,
    String email
) {}
```

The compiler provides implementations for things such as:

- accessors
- `equals()`
- `hashCode()`
- `toString()`

based on the record components.

### Important

A record is not automatically deeply immutable.

If a component itself references a mutable object, that object can still be mutable.

---

# 61. Why are records useful?

Instead of:

```java
class Employee {

    private final Long id;
    private final String name;

    // constructor
    // getters
    // equals
    // hashCode
    // toString
}
```

you can write:

```java
record Employee(Long id, String name) {}
```

Excellent for DTO-like immutable data carriers.

---

# 62. What are sealed classes?

Sealed classes restrict which classes can extend or implement a type.

Example:

```java
public sealed interface Payment
    permits CardPayment, CashPayment {
}
```

Then only permitted types can implement it.

This is useful when the domain has a controlled set of variants.

---

# 63. What is pattern matching?

Modern Java has introduced pattern matching features that make type checks and extraction more concise.

Example:

```java
if (obj instanceof String s) {
    System.out.println(s.length());
}
```

Instead of:

```java
if (obj instanceof String) {
    String s = (String) obj;
    System.out.println(s.length());
}
```

---

# 64. Advanced Generics

## What is PECS?

PECS means:

> Producer Extends, Consumer Super.

Example:

```java
List<? extends Number>
```

The list produces values.

You can safely read them as `Number`.

For consuming values:

```java
List<? super Integer>
```

You can add `Integer` values.

---

# 65. Explain `? extends`

```java
List<? extends Number> list;
```

This means the list contains some unknown subtype of `Number`.

You can read:

```java
Number n = list.get(0);
```

But generally cannot safely add an arbitrary `Number`.

---

# 66. Explain `? super`

```java
List<? super Integer> list;
```

The actual list could be:

```text
List<Integer>
List<Number>
List<Object>
```

You can safely add:

```java
list.add(10);
```

---

# 67. Why is `List<Integer>` not a `List<Number>`?

Generics in Java are invariant.

Even though:

```text
Integer extends Number
```

this does not mean:

```text
List<Integer> extends List<Number>
```

Otherwise this would be unsafe:

```java
List<Number> numbers = integerList;

numbers.add(3.14);
```

Now the original integer list contains a `Double`.

---

# 68. What is type erasure?

Java generics are primarily implemented through type erasure.

For example:

```java
List<String>
```

and:

```java
List<Integer>
```

do not remain as distinct parameterized runtime classes in the way a beginner might expect.

This explains limitations such as:

```java
new T()
```

being impossible directly in ordinary generic code.

---

# 69. Why can't we create generic arrays easily?

This is problematic:

```java
T[] array = new T[10];
```

because the runtime does not have enough information about `T` due to type erasure.

Often alternatives include:

```java
Object[]
```

with appropriate casting, or using collections.

---

# 70. STREAMS — ADVANCED

# What is a stream pipeline?

Typical structure:

```text
Source
  ↓
Intermediate operations
  ↓
Terminal operation
```

Example:

```java
List<String> result =
    employees.stream()
        .filter(Employee::isActive)
        .map(Employee::getName)
        .sorted()
        .toList();
```

---

# 71. Are streams collections?

No.

A collection stores data.

A stream represents a pipeline for processing data.

Think:

```text
Collection = data
Stream = computation
```

---

# 72. What is lazy evaluation?

Intermediate stream operations are generally lazy.

Example:

```java
employees.stream()
    .filter(e -> {
        System.out.println(e.getName());
        return e.isActive();
    });
```

Nothing necessarily happens until a terminal operation is invoked.

For example:

```java
.toList();
```

---

# 73. What are short-circuiting stream operations?

Examples include:

```java
findFirst()
findAny()
anyMatch()
allMatch()
noneMatch()
limit()
```

Example:

```java
boolean exists =
    employees.stream()
        .anyMatch(Employee::isActive);
```

The stream can stop once the answer is known.

---

# 74. map vs flatMap

### map

Transforms one element into another.

```java
List<String> names =
    employees.stream()
        .map(Employee::getName)
        .toList();
```

### flatMap

Flattens nested structures.

Suppose:

```java
List<Employee>
```

and each employee has:

```java
List<String> skills
```

Then:

```java
List<String> skills =
    employees.stream()
        .flatMap(e -> e.getSkills().stream())
        .distinct()
        .toList();
```

---

# 75. What is reduce?

Used to combine stream elements into a single result.

Example:

```java
int sum =
    numbers.stream()
        .reduce(0, Integer::sum);
```

Another example:

```java
Optional<Integer> max =
    numbers.stream()
        .reduce(Integer::max);
```

---

# 76. What is groupingBy?

```java
Map<String, List<Employee>> employeesByDepartment =
    employees.stream()
        .collect(Collectors.groupingBy(
            Employee::getDepartment
        ));
```

This is a very common interview question.

---

# 77. Count employees by department

```java
Map<String, Long> countByDepartment =
    employees.stream()
        .collect(Collectors.groupingBy(
            Employee::getDepartment,
            Collectors.counting()
        ));
```

---

# 78. Find highest-paid employee

```java
Optional<Employee> highest =
    employees.stream()
        .max(Comparator.comparing(Employee::getSalary));
```

Then:

```java
highest.ifPresent(System.out::println);
```

---

# 79. Find second-highest salary

One approach:

```java
Optional<Double> secondHighest =
    employees.stream()
        .map(Employee::getSalary)
        .distinct()
        .sorted(Comparator.reverseOrder())
        .skip(1)
        .findFirst();
```

Important interview question:

> What if fewer than two distinct salaries exist?

Answer:

`Optional` will be empty.

---

# 80. Difference between findFirst() and findAny()

`findFirst()` respects encounter order when one exists.

`findAny()` is allowed to return any matching element and can provide more flexibility for parallel processing.

---

# 81. What is a parallel stream?

```java
numbers.parallelStream()
```

allows stream operations to be executed in parallel.

But:

> Parallel does not automatically mean faster.

It can be harmful when:

- dataset is small
- work is cheap
- operations block
- shared state exists
- ordering matters
- common pool contention occurs

---

# 82. What is Optional?

`Optional<T>` represents the presence or absence of a value.

Example:

```java
Optional<String> name =
    Optional.ofNullable(employee.getName());
```

Then:

```java
name.ifPresent(System.out::println);
```

or:

```java
String result =
    name.orElse("Unknown");
```

---

# 83. orElse vs orElseGet

This is a common interview trap.

```java
optional.orElse(expensiveOperation());
```

The argument may be evaluated even if the Optional already contains a value.

With:

```java
optional.orElseGet(() -> expensiveOperation());
```

the supplier is evaluated only when needed.

---

# 84. What should Optional not be used for?

Avoid blindly using `Optional` everywhere.

In particular, using it as:

- every field type
- every method parameter
- entity field
- collection element

may make code unnecessarily complicated.

It is most commonly useful as a return type when absence is a meaningful result.

---

# 85. EQUALS, HASHCODE AND TOSTRING — LIVE CODING

This is one of the most important sections for your interview.

If the interviewer says:

> "Write equals, hashCode and toString for this class."

**Do not immediately start typing.**

First explain your approach.

Say:

> "First I'll identify which fields define the logical identity of the object. I'll use the same identity fields in equals and hashCode, and I'll make toString readable without exposing sensitive information."

This shows that you understand the design rather than just memorizing generated code.

---

# 86. Example class

Suppose interviewer gives:

```java
class Employee {

    private Long id;
    private String name;
    private String email;
}
```

You might decide:

```text
id + email
```

define identity.

Then:

```java
import java.util.Objects;

class Employee {

    private Long id;
    private String name;
    private String email;

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof Employee other)) {
            return false;
        }

        return Objects.equals(id, other.id)
            && Objects.equals(email, other.email);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, email);
    }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", email='" + email + '\'' +
                '}';
    }
}
```

---

# 87. What should you say while coding?

A very strong interview explanation is:

> "I'm first checking reference equality because if both references point to the same object, they are obviously equal."

Then:

> "Next I'm checking the type so I don't compare unrelated objects."

Then:

> "I'm using Objects.equals because it handles null values safely."

Then:

> "I'm using exactly the same identity fields in hashCode because objects that are equal must return the same hash code."

Finally:

> "For toString, I'll include useful debugging fields but avoid passwords, tokens or other sensitive information."

This is much better than silently writing code.

---

# 88. equals() contract

The `equals()` contract includes:

### Reflexive

```text
x.equals(x) == true
```

### Symmetric

```text
x.equals(y) == y.equals(x)
```

### Transitive

If:

```text
x == y
y == z
```

then:

```text
x == z
```

### Consistent

Repeated calls should produce consistent results while relevant state remains unchanged.

### Null

```text
x.equals(null) == false
```

for a non-null `x`.

---

# 89. hashCode contract

If:

```java
a.equals(b)
```

is true, then:

```java
a.hashCode() == b.hashCode()
```

must also be true.

The reverse is not required.

Two unequal objects may have the same hash code.

That's called a collision.

---

# 90. Why does HashMap need both equals and hashCode?

Conceptually:

```text
key
 |
 v
hashCode()
 |
 v
bucket
 |
 v
equals()
 |
 v
exact matching key
```

Hash code helps locate the candidate bucket.

`equals()` determines whether a candidate key is actually equal.

---

# 91. What happens if you override equals but not hashCode?

You can violate the hash-based collection contract.

Example:

```java
Set<Employee> employees =
    new HashSet<>();

Employee e1 = new Employee(1L, "A", "a@test.com");
Employee e2 = new Employee(1L, "B", "a@test.com");

employees.add(e1);

System.out.println(employees.contains(e2));
```

If equality says they are logically equal but hash codes differ, lookup behavior can be incorrect.

### Interview answer

> Whenever I override equals, I should also override hashCode so equal objects have equal hash codes.

---

# 92. Should every field be included in equals?

No.

Only fields that define the object's logical identity should normally be included.

For example:

```text
Employee:
id
name
email
salary
createdAt
```

If identity is defined by:

```text
id
```

then using `salary` in equals can be dangerous because salary changes.

---

# 93. Why are mutable fields dangerous in hashCode?

Suppose:

```java
Set<Employee> set = new HashSet<>();

Employee employee = ...;

set.add(employee);

employee.setEmail("new@email.com");
```

If email participates in `hashCode()`, the object may now hash to a different bucket.

The set can effectively lose track of where it expects the object to be.

### Interview answer

> Fields used in hashCode should ideally be stable while the object is stored in a hash-based collection.

---

# 94. getClass() vs instanceof in equals()

Two common styles:

### Strict class equality

```java
if (o == null || getClass() != o.getClass()) {
    return false;
}
```

### instanceof

```java
if (!(o instanceof Employee other)) {
    return false;
}
```

Neither is universally correct.

The choice depends on the equality model and inheritance design.

Inheritance can make `equals()` surprisingly difficult because symmetry and transitivity can be violated if parent and child classes define identity differently.

### Interview answer

> I choose the equality strategy based on whether equality should work across a type hierarchy. For value-like classes, strict class equality is often safer when subclasses should not compare equal.

---

# 95. Arrays in equals/hashCode

Do not use:

```java
Objects.equals(array1, array2)
```

if you intend content-based array comparison.

Use:

```java
Arrays.equals(array1, array2);
```

and:

```java
Arrays.hashCode(array);
```

For nested arrays:

```java
Arrays.deepEquals(...)
Arrays.deepHashCode(...)
```

---

# 96. Floating-point fields

For `double`/`float` fields, blindly using `==` can have edge cases.

A common approach is:

```java
Double.compare(this.value, other.value) == 0
```

and corresponding hash-code handling.

Generated IDE code often handles these details for you.

---

# 97. BigDecimal trap

This is a famous Java interview question.

```java
new BigDecimal("10.0")
    .equals(new BigDecimal("10.00"))
```

is:

```text
false
```

because `equals()` considers scale.

But:

```java
new BigDecimal("10.0")
    .compareTo(new BigDecimal("10.00"))
```

returns:

```text
0
```

because numerically they represent the same value.

### Interview lesson

> `equals()` and `compareTo()` do not always define identical notions of equality.

---

# 98. Should toString contain passwords?

No.

Avoid:

```java
return "User{username='" + username +
       "', password='" + password + "'}";
```

because logs may expose credentials.

Also be careful with:

- authentication tokens
- API keys
- payment information
- personal secrets

---

# 99. toString and circular references

Suppose:

```text
Employee -> Department
Department -> Employees
```

A naive `toString()` implementation can recursively traverse the relationship and cause excessive output or recursion problems.

Prefer concise representations.

---

# 100. JPA entities and equals/hashCode

This is an advanced topic.

For ORM entities, equality design can be complicated because:

- IDs may be generated later
- entities can be proxied
- objects can transition from transient to persistent state
- mutable business fields can change

Do not blindly copy a simple POJO equals/hashCode implementation into every JPA entity.

### Interview answer

> For JPA entities, I would design equals/hashCode according to the entity identity strategy and proxy lifecycle rather than blindly using all fields.

---

# 101. Record vs manually implementing equals/hashCode

Record:

```java
record Employee(Long id, String name) {}
```

automatically provides value-based implementations based on its components.

For ordinary classes, you decide which fields define logical identity.

---

# 102. SPRING / SPRING BOOT

# What is Spring?

Spring is a framework/ecosystem for building Java applications.

Core concepts include:

- Dependency Injection
- IoC
- AOP
- transaction management
- web development
- data access
- testing

---

# 103. What is IoC?

IoC means:

**Inversion of Control**

Instead of your application manually constructing and wiring every dependency, the framework/container manages object creation and dependency wiring.

---

# 104. What is a Spring Bean?

A bean is an object managed by the Spring IoC container.

Example:

```java
@Service
public class UserService {
}
```

Spring can create and manage the `UserService` instance.

---

# 105. @Component vs @Service vs @Repository

All are stereotype annotations used for component scanning, but communicate different roles.

```java
@Component
```

generic component.

```java
@Service
```

service/business layer.

```java
@Repository
```

persistence/data-access layer.

`@Repository` also participates in Spring's exception translation mechanism for supported persistence technologies.

---

# 106. @Controller vs @RestController

`@Controller` is typically used for MVC controllers.

`@RestController` effectively combines:

```java
@Controller
@ResponseBody
```

and is commonly used for REST APIs.

Example:

```java
@RestController
@RequestMapping("/employees")
class EmployeeController {

    @GetMapping("/{id}")
    public Employee getEmployee(
            @PathVariable Long id) {

        return service.findById(id);
    }
}
```

---

# 107. Why constructor injection?

Example:

```java
@Service
class EmployeeService {

    private final EmployeeRepository repository;

    EmployeeService(EmployeeRepository repository) {
        this.repository = repository;
    }
}
```

Benefits:

- explicit dependencies
- easier unit tests
- supports final fields
- avoids partially initialized objects

---

# 108. What is Spring Boot?

Spring Boot simplifies Spring application development by providing:

- auto-configuration
- starter dependencies
- embedded servers
- production-oriented features
- convention over configuration

Example:

```java
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
        SpringApplication.run(
            Application.class,
            args
        );
    }
}
```

---

# 109. What does @SpringBootApplication do?

It combines several important capabilities, notably:

```text
@Configuration
@EnableAutoConfiguration
@ComponentScan
```

Conceptually:

```text
configuration
+
auto configuration
+
component scanning
```

---

# 110. What is auto-configuration?

Spring Boot examines the application's classpath and configuration and conditionally configures components.

For example, if relevant web dependencies are present, Boot can configure a web application infrastructure automatically.

---

# 111. What is @Autowired?

It tells Spring to inject a dependency.

Constructor injection can often omit `@Autowired` when the class has a single constructor.

Example:

```java
@Service
class OrderService {

    private final PaymentService paymentService;

    OrderService(PaymentService paymentService) {
        this.paymentService = paymentService;
    }
}
```

---

# 112. What is @Qualifier?

Used when multiple beans implement the same interface.

```java
@Service
class PaymentService {

    private final PaymentProcessor processor;

    PaymentService(
        @Qualifier("upiProcessor")
        PaymentProcessor processor
    ) {
        this.processor = processor;
    }
}
```

---

# 113. What is @Primary?

If multiple beans match and one should be the default:

```java
@Primary
@Component
class DefaultPaymentProcessor
    implements PaymentProcessor {
}
```

---

# 114. What are Spring bean scopes?

Common scopes include:

```text
singleton
prototype
request
session
application
websocket
```

The default is singleton scope within the Spring application context.

---

# 115. What is @Transactional?

It defines transaction boundaries.

Example:

```java
@Transactional
public void transferMoney(...) {

    debit();

    credit();
}
```

If an appropriate runtime exception causes transaction rollback according to the configured transaction semantics, the transaction can be rolled back.

### Important interview point

`@Transactional` is commonly implemented through proxies/AOP, so self-invocation can prevent the expected proxy interception.

---

# 116. What is the self-invocation problem?

Suppose:

```java
class Service {

    public void methodA() {
        methodB();
    }

    @Transactional
    public void methodB() {
    }
}
```

If `methodA()` calls `methodB()` directly on `this`, the call can bypass the Spring proxy.

Therefore the transactional interception may not occur as expected.

### Interview answer

> Spring's declarative transaction behavior is commonly proxy-based, so internal self-invocation may bypass the proxy.

---

# 117. JPA / HIBERNATE

# What is JPA?

JPA is a Java specification for persistence/ORM.

Hibernate is a popular implementation of JPA.

Think:

```text
JPA = specification
Hibernate = implementation
```

---

# 118. What is ORM?

ORM means:

**Object Relational Mapping**

It maps Java objects to relational database tables.

Example:

```java
@Entity
class Employee {

    @Id
    private Long id;

    private String name;
}
```

Conceptually:

```text
Employee object
      |
      v
employee table
```

---

# 119. Entity lifecycle

A JPA entity can conceptually move through states such as:

```text
Transient
   |
 persist
   v
Managed
   |
 detach
   v
Detached
```

It may also become removed through the persistence context.

---

# 120. What is persistence context?

The persistence context is a managed set of entity instances associated with an `EntityManager`.

It provides identity management and change tracking among other behaviors.

If an entity is managed:

```java
employee.setName("New Name");
```

the ORM can detect the change and synchronize it with the database during flush/transaction completion according to the configured behavior.

---

# 121. What is dirty checking?

Hibernate/JPA can detect changes to managed entities.

Example:

```java
@Transactional
public void updateEmployee(Long id) {

    Employee employee =
        repository.findById(id).orElseThrow();

    employee.setName("New Name");
}
```

You may not need an explicit:

```java
repository.save(employee);
```

for an already managed entity in a transactional persistence context.

Dirty checking can detect the changed state and generate SQL during flush.

---

# 122. Lazy vs Eager loading

### Lazy

Related data is loaded when accessed.

### Eager

Related data is loaded immediately according to the mapping/provider behavior.

Lazy loading can avoid unnecessary data retrieval.

But it can cause issues such as:

```text
LazyInitializationException
```

when lazy data is accessed outside the appropriate persistence context.

---

# 123. What is the N+1 query problem?

Suppose:

```text
1 query gets 100 employees
```

Then application accesses each employee's department separately:

```text
+100 queries
```

Total:

```text
101 queries
```

This is the N+1 problem.

Possible solutions include:

- fetch joins
- entity graphs
- batch fetching
- projections
- carefully designed queries

---

# 124. What is a database index?

An index helps the database find rows more efficiently for supported query patterns.

Example:

```sql
CREATE INDEX idx_employee_email
ON employee(email);
```

But indexes have costs:

- additional storage
- write/update overhead
- maintenance
- not every query benefits

---

# 125. What is optimistic locking?

Optimistic locking assumes conflicts are relatively uncommon.

A version field can be used:

```java
@Version
private Long version;
```

Conceptually:

```text
Read version = 5

User A updates
version becomes 6

User B tries update using version 5

Update fails because version changed
```

This helps detect concurrent modifications.

---

# 126. What is pessimistic locking?

Pessimistic locking obtains database-level locks to prevent conflicting operations.

Useful when contention is high and stronger serialization is required.

However, excessive pessimistic locking can reduce concurrency and increase deadlock risk.

---

# 127. MICROservices / PRODUCTION JAVA

# What is a microservice?

A microservice is a relatively small, independently deployable service organized around a business capability.

Typical architecture:

```text
Client
  |
  v
API Gateway
  |
  +--> User Service
  |
  +--> Order Service
  |
  +--> Payment Service
  |
  +--> Notification Service
```

---

# 128. Monolith vs microservices

### Monolith

```text
One application
   |
   +-- Users
   +-- Orders
   +-- Payments
   +-- Reports
```

### Microservices

```text
User Service
Order Service
Payment Service
Reporting Service
```

Microservices can provide independent deployment and scaling, but add operational complexity.

### Strong interview answer

> Microservices are not automatically better. They can improve independent deployment and scaling, but introduce distributed-system problems such as network failures, consistency challenges, observability complexity, and operational overhead.

---

# 129. What is an API Gateway?

A gateway can provide a common entry point for clients.

Responsibilities can include:

- routing
- authentication integration
- rate limiting
- request transformation
- observability
- aggregation

---

# 130. What is service-to-service communication?

Common approaches include:

```text
REST
gRPC
Messaging
Events
```

Choice depends on:

- latency
- coupling
- reliability
- data format
- operational requirements

---

# 131. What is idempotency?

An operation is idempotent if repeating the same request produces the same intended final effect.

Example:

```text
PUT /users/123
```

setting:

```text
name = John
```

can be designed to be idempotent.

Payments are trickier.

If:

```text
POST /payment
```

is retried due to a network timeout, we don't want to charge the customer twice.

A common solution is an idempotency key.

```text
Idempotency-Key: abc123
```

The server remembers the outcome for that key according to its retention policy.

---

# 132. What is a circuit breaker?

A circuit breaker prevents repeatedly calling an unhealthy dependency.

Conceptually:

```text
CLOSED
  |
  | failures
  v
OPEN
  |
  | after wait
  v
HALF_OPEN
  |
  +--> success --> CLOSED
  |
  +--> failure --> OPEN
```

Benefits:

- fail fast
- reduce pressure on failing dependencies
- improve resilience

---

# 133. What is retry?

Retry means attempting a failed operation again.

But don't blindly retry everything.

Retries are appropriate mainly for transient failures.

Use:

- limited attempts
- exponential backoff
- jitter
- timeout
- idempotency where needed

Bad:

```text
retry forever
```

Good:

```text
attempt 1
wait
attempt 2
wait longer
attempt 3
fail
```

---

# 134. What is timeout?

A timeout prevents an application from waiting indefinitely for another system.

Example:

```text
Service A
   |
   | timeout = 2 sec
   v
Service B
```

If B doesn't respond within the allowed time, A stops waiting and handles the failure.

Every remote call should have carefully chosen timeout behavior.

---

# 135. What is observability?

Three major pillars:

```text
Logs
Metrics
Traces
```

### Logs

Detailed events.

### Metrics

Numerical measurements.

Examples:

```text
request_count
error_rate
latency
CPU
memory
queue_size
```

### Traces

Follow a request across distributed services.

```text
Gateway
   |
   v
Order Service
   |
   v
Payment Service
   |
   v
Database
```

---

# 136. What would you do if production API suddenly becomes slow?

A strong answer:

> "First I would determine whether the problem is application-wide or isolated to a particular endpoint or dependency. I'd check latency, error rate, traffic, CPU, memory, thread pools, GC behavior, database latency, external dependencies, and recent deployments. Then I'd use logs and distributed traces to identify where time is being spent. I would mitigate the impact first if necessary, then investigate the root cause."

Avoid saying:

> "I will restart the server."

Restarting may hide the symptom without fixing the cause.

---

# 137. API has high CPU — what do you check?

Check:

```text
CPU utilization
thread dumps
hot methods
GC activity
request rate
recent deployment
infinite loops
expensive algorithms
serialization/deserialization
regex
database result processing
parallelism
```

Profilers and JVM diagnostic tools can help identify hot code.

---

# 138. API has high memory usage — what do you check?

Check:

```text
heap usage
GC frequency
heap dump
object allocation
large collections
caches
static references
thread count
class-loader growth
native memory
```

Look for:

```text
objects allocated faster than GC can reclaim
```

or:

```text
objects remain reachable unnecessarily
```

---

# 139. What is a thread dump?

A thread dump shows information about JVM threads at a point in time.

It can help identify:

- deadlocks
- blocked threads
- thread pool exhaustion
- long-running operations
- waiting threads

For example, Java tooling such as:

```text
jstack
```

can produce thread dumps.

---

# 140. What is a heap dump?

A heap dump captures information about objects in the JVM heap.

It can help investigate:

- memory leaks
- unexpectedly large collections
- retained objects
- suspicious object graphs

Tools such as:

```text
jmap
```

and heap-analysis tools can help.

---

# 141. What would you do if an application has OutOfMemoryError?

Interview answer:

> "I would first identify which memory area is exhausted rather than immediately increasing heap size."

Then investigate:

```text
heap dump
GC logs
memory metrics
object retention
large collections
caches
class loaders
native memory
recent deployment
```

Increasing:

```text
-Xmx
```

may temporarily postpone the problem but can hide an underlying leak.

---

# 142. What would you do if API returns intermittent 500 errors?

Approach:

```text
1. Check error rate and timing.
2. Correlate with logs/traces.
3. Identify affected endpoints.
4. Check downstream services.
5. Check database errors/timeouts.
6. Check recent deployment/configuration changes.
7. Look for concurrency/race conditions.
8. Reproduce if possible.
9. Mitigate.
10. Fix root cause.
```

This demonstrates production thinking.

---

# 143. CODING QUESTIONS YOU SHOULD PRACTICE

## Reverse a String

```java
String input = "hello";

String reversed =
    new StringBuilder(input)
        .reverse()
        .toString();
```

---

# 144. Reverse without StringBuilder

```java
String input = "hello";
String result = "";

for (int i = input.length() - 1; i >= 0; i--) {
    result += input.charAt(i);
}
```

Interview note:

For many concatenations, this can be inefficient because String is immutable.

Prefer:

```java
StringBuilder
```

for iterative concatenation.

---

# 145. Check palindrome

```java
String input = "madam";

String reversed =
    new StringBuilder(input)
        .reverse()
        .toString();

boolean palindrome =
    input.equals(reversed);
```

---

# 146. Find duplicate elements

```java
Set<Integer> seen = new HashSet<>();
Set<Integer> duplicates = new HashSet<>();

for (Integer number : numbers) {

    if (!seen.add(number)) {
        duplicates.add(number);
    }
}
```

Why does this work?

`Set.add()` returns:

```text
true  -> element was newly added
false -> element already existed
```

---

# 147. Find frequency of characters

```java
Map<Character, Integer> frequency =
    new HashMap<>();

for (char c : input.toCharArray()) {
    frequency.merge(c, 1, Integer::sum);
}
```

---

# 148. First non-repeated character

```java
Map<Character, Long> frequency =
    input.chars()
        .mapToObj(c -> (char) c)
        .collect(Collectors.groupingBy(
            c -> c,
            LinkedHashMap::new,
            Collectors.counting()
        ));

Character result =
    frequency.entrySet()
        .stream()
        .filter(e -> e.getValue() == 1)
        .map(Map.Entry::getKey)
        .findFirst()
        .orElse(null);
```

The `LinkedHashMap` preserves encounter order.

---

# 149. Find max number

```java
int max =
    numbers.stream()
        .max(Integer::compareTo)
        .orElseThrow();
```

---

# 150. Sort employees by salary

```java
employees.stream()
    .sorted(
        Comparator.comparing(Employee::getSalary)
    )
    .toList();
```

Descending:

```java
employees.stream()
    .sorted(
        Comparator.comparing(
            Employee::getSalary
        ).reversed()
    )
    .toList();
```

---

# 151. Sort by salary then name

```java
employees.stream()
    .sorted(
        Comparator.comparing(Employee::getSalary)
            .thenComparing(Employee::getName)
    )
    .toList();
```

---

# 152. Remove duplicates

```java
List<Integer> unique =
    numbers.stream()
        .distinct()
        .toList();
```

---

# 153. Partition numbers into even and odd

```java
Map<Boolean, List<Integer>> result =
    numbers.stream()
        .collect(
            Collectors.partitioningBy(
                n -> n % 2 == 0
            )
        );
```

Then:

```java
result.get(true);  // even
result.get(false); // odd
```

---

# 154. Count duplicate words

```java
Map<String, Long> frequency =
    words.stream()
        .collect(
            Collectors.groupingBy(
                word -> word,
                Collectors.counting()
            )
        );
```

---

# 155. What is the time complexity of HashMap?

Average-case lookup:

```text
O(1)
```

Average-case insertion:

```text
O(1)
```

But collisions and resizing affect practical behavior.

Modern Java HashMap implementations can transform heavily collided bins into tree structures under certain conditions, improving worst-case behavior for those bins.

Don't simply say:

> "HashMap is always O(1)."

Say:

> "HashMap provides expected constant-time basic operations under typical well-distributed hashing, while pathological collision behavior and resizing affect performance."

---

# 156. What is Big-O of ArrayList operations?

Typical:

```text
get(index)        O(1)
set(index)        O(1)
add(end)          amortized O(1)
insert(beginning) O(n)
remove(beginning) O(n)
search            O(n)
```

---

# 157. ArrayList vs LinkedList — interview answer

> ArrayList is backed by a dynamically resized array and provides efficient random access. LinkedList is node-based and provides efficient insertion/removal only when the target node/position is already known; locating an arbitrary position is still O(n). In most normal application code, ArrayList is the better default.

This is a stronger answer than:

> "LinkedList is faster for insertion."

because insertion position lookup itself can be expensive.

---

# 158. Why is String immutable?

Benefits include:

- string pooling
- thread safety
- security
- stable hash codes
- safe sharing
- suitability as map keys

Example:

```java
String username = "john";
```

Strings can safely be shared across many parts of an application.

---

# 159. Why is String a good HashMap key?

Because String is immutable.

If the key's state could change after insertion, its hash code could change and lookup could fail.

---

# 160. What happens here?

```java
String a = "hello";
String b = "hello";

System.out.println(a == b);
```

Typically:

```text
true
```

because both literals can refer to the same interned string.

But:

```java
String a = new String("hello");
String b = new String("hello");

System.out.println(a == b);
```

prints:

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

# 161. What happens here?

```java
Integer a = 100;
Integer b = 100;

System.out.println(a == b);
```

Typically:

```text
true
```

because of Integer caching for commonly cached values.

But don't rely on `==` for wrapper-value equality.

Use:

```java
a.equals(b)
```

---

# 162. What about Integer 1000?

```java
Integer a = 1000;
Integer b = 1000;

System.out.println(a == b);
```

Do not assume `true`.

Wrapper caching behavior means `==` is not a value-comparison mechanism.

Use:

```java
Objects.equals(a, b)
```

or:

```java
a.equals(b)
```

when non-null is guaranteed.

---

# 163. What is pass-by-value in Java?

Java is **always pass-by-value**.

For objects, the value being passed is the reference value.

Example:

```java
void change(Employee e) {
    e.setName("John");
}
```

The method receives a copy of the reference pointing to the same object.

Therefore it can modify the object's state.

But:

```java
void change(Employee e) {
    e = new Employee();
}
```

does not replace the caller's reference.

### Interview answer

> Java is always pass-by-value. For object arguments, the value passed is a copy of the object reference.

---

# 164. Can Java have multiple inheritance?

Java does not support multiple inheritance of classes.

This is invalid:

```java
class C extends A, B {
}
```

But Java supports multiple interfaces:

```java
class C implements A, B {
}
```

---

# 165. What if two interfaces have the same default method?

Example:

```java
interface A {
    default void test() {
        System.out.println("A");
    }
}

interface B {
    default void test() {
        System.out.println("B");
    }
}
```

Then:

```java
class C implements A, B {
}
```

must resolve the conflict, for example:

```java
@Override
public void test() {
    A.super.test();
}
```

---

# 166. Can static methods be overridden?

No.

Static methods belong to the class rather than an object instance.

They can be hidden when a subclass declares a static method with the same signature.

---

# 167. Can private methods be overridden?

No.

Private methods are not inherited in the normal polymorphic sense.

A child can declare a method with the same name/signature, but that is not overriding the parent's private method.

---

# 168. Can final methods be overridden?

No.

```java
final void test() {
}
```

cannot be overridden by subclasses.

---

# 169. Can final classes be extended?

No.

```java
final class Employee {
}
```

cannot be subclassed.

Example:

```java
public final class String
```

String cannot be extended.

---

# 170. Can constructors be inherited?

No.

Constructors belong to the class being constructed.

A subclass constructor can invoke a superclass constructor using:

```java
super();
```

---

# 171. What is constructor chaining?

Within a class:

```java
this(...)
```

calls another constructor in the same class.

To call a parent constructor:

```java
super(...)
```

Example:

```java
class Employee {

    Employee() {
        this(0);
    }

    Employee(int id) {
        System.out.println(id);
    }
}
```

---

# 172. What happens first when an object is created?

A simplified conceptual order is:

```text
Class initialization if required
        ↓
Memory/object initialization
        ↓
Superclass constructor
        ↓
Instance field/initializer processing as applicable
        ↓
Subclass constructor body
```

For detailed initialization-order questions, carefully account for static initialization, instance initialization blocks, field initializers, and constructor chaining.

---

# 173. Tricky output question

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

    public static void main(String[] args) {
        System.out.println("Main");
        new Test();
        new Test();
    }
}
```

Typical output:

```text
Static
Main
Instance
Constructor
Instance
Constructor
```

Static initialization occurs once when the class is initialized.

Instance initialization occurs for each object.

---

# 174. What is try-with-resources?

It automatically closes resources implementing `AutoCloseable`.

Example:

```java
try (BufferedReader reader =
         new BufferedReader(
             new FileReader("file.txt"))) {

    System.out.println(reader.readLine());

}
```

The resource is closed automatically.

---

# 175. What are suppressed exceptions?

If an exception occurs in the try block and another occurs while closing a resource, the close exception can be attached as a suppressed exception.

You can inspect them with:

```java
exception.getSuppressed();
```

This is a useful advanced exception-handling question.

---

# 176. throw vs throws

### throw

Actually throws an exception:

```java
throw new IllegalArgumentException("Invalid");
```

### throws

Declares possible checked exceptions:

```java
void readFile() throws IOException {
}
```

---

# 177. Can finally be skipped?

Yes, in abnormal JVM termination scenarios.

For example:

```java
System.exit(0);
```

can terminate the JVM without normal execution of `finally`.

Also catastrophic process/JVM termination can prevent normal cleanup.

Therefore don't say:

> "finally always executes."

Better:

> "`finally` normally executes when control leaves the try/catch construct, except in cases such as abrupt JVM termination."

---

# 178. What is an immutable class?

Typical properties:

- state cannot change after construction
- fields are private/final where appropriate
- no setters
- defensive copies for mutable components
- don't expose mutable internal state
- class may be final to prevent problematic subclassing

Example:

```java
public final class Employee {

    private final String name;

    public Employee(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }
}
```

---

# 179. Defensive copy example

Bad:

```java
class Team {

    private final List<String> members;

    Team(List<String> members) {
        this.members = members;
    }

    List<String> getMembers() {
        return members;
    }
}
```

Caller can mutate internal state.

Better:

```java
class Team {

    private final List<String> members;

    Team(List<String> members) {
        this.members =
            List.copyOf(members);
    }

    List<String> getMembers() {
        return members;
    }
}
```

Now the internal list cannot be structurally modified through the returned reference.

---

# 180. What is an unmodifiable collection?

Example:

```java
List<String> list =
    Collections.unmodifiableList(original);
```

This creates an unmodifiable view.

Changes to `original` can still be visible through the view.

Compare with:

```java
List.copyOf(original)
```

which creates an unmodifiable copy.

### Interview distinction

```text
unmodifiable view != immutable snapshot
```

---

# 181. SENIOR-LEVEL SCENARIO QUESTIONS

# Q181. "Your API is receiving 10,000 requests per second. What do you consider?"

Talk about:

```text
CPU
memory
GC
thread pools
connection pools
database capacity
cache
load balancing
horizontal scaling
rate limiting
timeouts
backpressure
queueing
network bandwidth
downstream dependencies
observability
```

Don't simply say:

> "Add more servers."

---

# 182. "Database is slow. Should I increase the connection pool?"

Not automatically.

If database capacity is the bottleneck, increasing the pool can make things worse.

You should inspect:

```text
query latency
slow queries
indexes
DB CPU
DB locks
connection utilization
transaction duration
pool saturation
application concurrency
```

A larger connection pool can increase contention.

---

# 183. "How would you improve a slow API?"

Use a structured approach:

```text
1. Measure.
2. Identify bottleneck.
3. Fix the bottleneck.
4. Measure again.
```

Potential areas:

```text
algorithm
database
network
serialization
GC
locking
remote service
caching
I/O
thread pools
```

Never optimize blindly.

---

# 184. "How would you design a cache?"

Consider:

```text
cache key
TTL
eviction policy
maximum size
consistency
cache stampede
cache penetration
serialization
memory usage
distributed vs local cache
failure behavior
metrics
```

---

# 185. What is cache stampede?

Suppose a popular cached item expires.

Thousands of requests simultaneously miss the cache and all hit the database.

```text
Cache expires
      |
      v
10,000 requests
      |
      v
10,000 DB queries
```

Possible approaches:

- locking/coalescing
- request deduplication
- jittered TTL
- refresh-ahead
- stale-while-revalidate strategies

---

# 186. What is backpressure?

Backpressure means slowing producers when consumers cannot keep up.

Example:

```text
Producer
   |
   v
Queue
   |
   v
Consumer
```

If consumer capacity is limited, an unbounded producer can cause memory problems.

Backpressure mechanisms include:

- bounded queues
- rate limiting
- rejection
- flow control
- reactive streams

---

# 187. What is graceful shutdown?

When an application shuts down:

```text
Stop accepting new work
        ↓
Finish/stop existing work safely
        ↓
Close resources
        ↓
Exit
```

For example:

- stop new requests
- allow in-flight requests to complete
- stop accepting tasks
- shut down executors
- close DB connections/resources

---

# 188. What is connection pooling?

Creating database/network connections repeatedly can be expensive.

A connection pool maintains reusable connections.

Conceptually:

```text
Application
    |
    v
Connection Pool
    |
    +--> DB connection
    +--> DB connection
    +--> DB connection
```

This improves reuse but requires careful sizing and timeout configuration.

---

# 189. Why shouldn't we create a new HTTP client for every request?

Creating a new client repeatedly may prevent connection reuse and add unnecessary overhead.

Prefer a properly configured reusable client that supports:

- connection pooling
- timeouts
- TLS/session reuse where applicable
- observability
- controlled concurrency

---

# 190. What is thread pool exhaustion?

Suppose:

```text
Thread pool = 10 threads
```

and all 10 are blocked waiting for slow downstream calls.

New requests may queue.

Eventually:

```text
Queue full
   ↓
rejection / timeout
```

Possible solutions:

- correct timeout configuration
- separate pools for different workloads
- async/non-blocking designs where appropriate
- virtual threads for suitable blocking workloads
- reduce downstream latency
- bounded queues
- backpressure

---

# 191. What is a bounded queue and why is it important?

A bounded queue has a maximum capacity.

Example:

```java
new ArrayBlockingQueue<>(100);
```

It prevents unlimited task accumulation.

An unbounded queue can cause:

```text
traffic spike
   ↓
tasks accumulate
   ↓
memory increases
   ↓
latency increases
   ↓
OutOfMemoryError
```

---

# 192. What is graceful degradation?

When a dependency fails, the system continues providing reduced functionality rather than completely failing.

Example:

```text
Recommendation service unavailable
        ↓
Show product without recommendations
```

This can be better than returning a complete 500 response.

---

# 193. What is bulkhead isolation?

Bulkhead isolation separates resources so failure in one area doesn't consume everything.

Example:

```text
Pool A -> Payment calls
Pool B -> Reporting calls
Pool C -> Notification calls
```

If reporting becomes slow, it doesn't necessarily consume all worker capacity required by payments.

---

# 194. What is rate limiting?

Rate limiting controls how many requests a client/system can make within a period.

Example:

```text
100 requests / second
```

Benefits:

- prevents abuse
- protects services
- manages traffic spikes
- protects downstream dependencies

---

# 195. What is horizontal vs vertical scaling?

### Vertical scaling

Increase machine capacity:

```text
4 CPU -> 16 CPU
8 GB -> 32 GB
```

### Horizontal scaling

Add instances:

```text
Instance 1
Instance 2
Instance 3
Instance 4
```

Distributed systems often use horizontal scaling for application tiers.

---

# 196. How do you make a Java service thread-safe?

Don't automatically synchronize everything.

First identify shared mutable state.

Possible approaches:

```text
immutability
local variables
thread confinement
synchronized
Lock
Atomic classes
concurrent collections
message passing
stateless design
```

A very strong answer is:

> "My first choice is often to reduce shared mutable state rather than add locks everywhere."

---

# 197. How would you review Java code?

Check:

### Correctness

- null handling
- exception handling
- edge cases
- concurrency

### Design

- SRP
- coupling
- cohesion
- abstractions

### Performance

- algorithmic complexity
- database queries
- unnecessary allocations
- I/O
- caching

### Maintainability

- naming
- duplication
- testability
- readability

### Security

- secrets in logs
- validation
- authorization
- unsafe deserialization
- injection risks

---

# 198. How do you answer "I don't know"?

Never bluff.

A strong response:

> "I haven't worked with that directly, so I don't want to guess. My understanding is X. If I had to investigate it, I'd start by checking Y and Z."

This demonstrates honesty and engineering judgment.

---

# 199. How do you handle an unfamiliar production bug?

Answer:

> "I would first reproduce or isolate the issue if possible, collect evidence from logs, metrics and traces, identify the scope and impact, check recent changes, then form and test hypotheses. If customer impact is high, I'd prioritize mitigation before deeper root-cause analysis."

This is a strong senior-level response.

---

# 200. HOW TO HANDLE LIVE CODING IN FRONT OF THE INTERVIEWER

This is extremely important.

When asked:

> "Write a method to find duplicates."

Don't immediately type.

Use this sequence.

## Step 1 — Clarify requirements

Ask:

> "Should I return duplicates once each or preserve every duplicate occurrence?"

Then:

> "Can the input be null?"

Then:

> "What should happen for an empty list?"

You don't need to ask 20 questions.

Ask only questions that change the solution.

---

## Step 2 — State your approach

Example:

> "I'll use a HashSet to track values I've already seen. If add() returns false, the value is a duplicate."

Now the interviewer knows your plan.

---

## Step 3 — Write the simplest correct solution

```java
Set<Integer> seen = new HashSet<>();
Set<Integer> duplicates = new HashSet<>();

for (Integer value : numbers) {

    if (!seen.add(value)) {
        duplicates.add(value);
    }
}

return duplicates;
```

---

## Step 4 — State complexity

```text
Time: O(n) expected
Space: O(n)
```

---

## Step 5 — Discuss edge cases

```text
null input
empty input
one element
all duplicates
no duplicates
```

---

# 201. LIVE equals/hashCode INTERVIEW SCRIPT

If the interviewer gives:

```java
class Employee {
    Long id;
    String name;
    String email;
}
```

Say:

> "Before implementing equals, I want to clarify what defines Employee identity. Should it be the database ID, email, or some combination?"

If interviewer says:

```text
id
```

Say:

> "Okay. I'll use id consistently in both equals and hashCode. I'll also make equals null-safe."

Then write:

```java
@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Employee other)) {
        return false;
    }

    return Objects.equals(id, other.id);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}
```

Then:

```java
@Override
public String toString() {
    return "Employee{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", email='" + email + '\'' +
            '}';
}
```

Then explain:

> "The important part is that the fields used by equals and hashCode are consistent."

That one sentence demonstrates the core concept.

---

# 202. If interviewer asks "Why Objects.equals?"

Answer:

> "`Objects.equals(a, b)` safely handles null values. It returns true when both are null, false when only one is null, and otherwise delegates to equals."

Conceptually:

```text
null + null       -> true
null + non-null   -> false
non-null + equal  -> true
```

---

# 203. If interviewer asks "Why Objects.hash?"

Answer:

> "`Objects.hash` provides a convenient way to generate a hash code from multiple fields while handling null values."

Example:

```java
return Objects.hash(id, email);
```

---

# 204. If interviewer says "Don't use Objects.hash"

You can manually implement it:

```java
int result = 17;

result = 31 * result +
         (id == null ? 0 : id.hashCode());

result = 31 * result +
         (email == null ? 0 : email.hashCode());

return result;
```

The important thing is consistency with equals.

---

# 205. If interviewer asks "Can hashCode be unique?"

Answer:

> "No. Different objects can have the same hash code. Hash collisions are allowed. The requirement is that equal objects must have equal hash codes."

---

# 206. If interviewer asks "Can two objects have same hashCode but not be equal?"

Yes.

Example:

```text
Object A -> hash 100
Object B -> hash 100
```

They may still be unequal.

This is called a collision.

---

# 207. If interviewer asks "Can equal objects have different hashCodes?"

No.

That violates the contract.

---

# 208. If interviewer asks "What happens if a HashMap key is mutable?"

Explain:

> "If fields used to calculate hashCode change after insertion, the key can effectively become unreachable through normal lookup because the map may search a different bucket."

Example:

```java
Map<Employee, String> map =
    new HashMap<>();

Employee employee = ...;

map.put(employee, "data");

employee.setEmail("changed");

map.get(employee);
```

If email participates in hashCode, this is dangerous.

---

# 209. Common interview mistakes

Avoid these statements:

### Mistake 1

> "HashMap is always O(1)."

Better:

> "Expected O(1) for basic operations under normal hashing assumptions."

### Mistake 2

> "Java passes objects by reference."

Wrong.

Say:

> "Java is pass-by-value; the value passed for an object is a copy of its reference."

### Mistake 3

> "volatile makes variables thread-safe."

Incomplete.

Better:

> "volatile provides visibility and ordering guarantees, but doesn't make compound operations atomic."

### Mistake 4

> "LinkedList is faster for insertion."

Incomplete.

The location often needs to be found first.

### Mistake 5

> "finally always runs."

Not absolutely.

### Mistake 6

> "Parallel streams are faster."

Not necessarily.

### Mistake 7

> "Microservices are better than monoliths."

Not universally.

---

# 210. RAPID-FIRE QUESTIONS

## What is the difference between == and equals()?

```text
==       -> reference identity for objects
equals() -> logical equality according to implementation
```

---

## Can equals return true while hashCode differs?

No.

---

## Can hashCode be same while equals is false?

Yes.

---

## Is Java pass-by-reference?

No.

Java is pass-by-value.

---

## Is String mutable?

No.

String is immutable.

---

## Is StringBuilder thread-safe?

No.

---

## Is StringBuffer thread-safe?

Its methods are synchronized, so it provides thread-safety at that level, though that doesn't automatically make compound sequences of operations atomic.

---

## Can an interface have fields?

Interface fields are implicitly:

```text
public static final
```

---

## Can an abstract class have a constructor?

Yes.

---

## Can an abstract class be instantiated?

No.

---

## Can an interface have a constructor?

No.

---

## Can an abstract class have static methods?

Yes.

---

## Can an interface have static methods?

Yes.

---

## Can a constructor be final?

No.

---

## Can a constructor be static?

No.

---

## Can a constructor be private?

Yes.

Useful for patterns such as controlled construction/factories.

---

## Can we overload constructors?

Yes.

---

## Can we override constructors?

No.

---

## Can we overload static methods?

Yes.

---

## Can static methods be overridden?

No; they are hidden.

---

## Can private methods be overridden?

No.

---

## Can final methods be overridden?

No.

---

## Can final objects be modified?

The reference cannot be reassigned, but the object itself may be mutable.

```java
final List<String> list =
    new ArrayList<>();

list.add("Java"); // allowed
```

But:

```java
list = new ArrayList<>();
```

is not allowed.

---

# 211. TOP 30 QUESTIONS TO PRACTICE OUT LOUD

Practice answering these without reading your notes:

```text
1. Explain JVM, JDK and JRE.

2. Explain stack vs heap.

3. Explain String immutability.

4. Why is String a good HashMap key?

5. == vs equals()?

6. equals() and hashCode() contract?

7. What happens inside HashMap?

8. ArrayList vs LinkedList?

9. HashMap vs ConcurrentHashMap?

10. HashSet internally uses what?

11. What is immutability?

12. How do you create an immutable class?

13. Checked vs unchecked exception?

14. throw vs throws?

15. What is try-with-resources?

16. What is synchronization?

17. synchronized vs volatile?

18. What is a race condition?

19. What is deadlock?

20. What is ExecutorService?

21. Future vs CompletableFuture?

22. What is AtomicInteger?

23. What is CAS?

24. What is garbage collection?

25. What is a memory leak in Java?

26. What is JIT?

27. Explain SOLID.

28. Explain dependency injection.

29. Explain equals/hashCode/toString live coding.

30. How would you debug a slow production API?
```

---

# 212. SENIOR INTERVIEW ANSWER STRUCTURE

For architecture/scenario questions, use:

```text
1. Clarify
2. State assumptions
3. Explain approach
4. Discuss trade-offs
5. Mention failure cases
6. Mention monitoring
7. Explain how you would validate
```

Example:

### Interviewer:

> "How would you design a payment service?"

Don't immediately start drawing classes.

Start:

> "Before designing it, I'd clarify expected transaction volume, consistency requirements, payment providers, retry behavior, failure scenarios, and whether duplicate payment prevention is required."

Then discuss:

```text
API
  ↓
Validation
  ↓
Idempotency
  ↓
Payment processing
  ↓
Persistence
  ↓
Events
  ↓
Notification
```

Then discuss:

```text
timeouts
retries
idempotency
transaction boundaries
security
observability
reconciliation
failure recovery
```

This demonstrates senior-level thinking.

---

# 213. THE BEST WAY TO ANSWER JAVA INTERVIEW QUESTIONS

Use this pattern:

### Level 1 — Definition

> "HashMap is a hash-table-based Map implementation."

### Level 2 — How it works

> "It uses hash codes to locate candidate buckets and equality checks to identify the matching key."

### Level 3 — Example

```java
Map<String, Integer> map =
    new HashMap<>();

map.put("Java", 1);
```

### Level 4 — Trade-off

> "It provides expected constant-time basic operations, but performance depends on hashing, collisions, resizing and workload."

That structure makes your answer sound much stronger.

---

# 214. FINAL JAVA INTERVIEW CHEAT SHEET

## Core Java

```text
JDK
JRE
JVM
Bytecode
Primitive types
Wrapper classes
Autoboxing
OOP
Inheritance
Polymorphism
Encapsulation
Abstraction
Constructors
this
super
static
final
Access modifiers
```

## Strings

```text
String immutable
String pool
==
equals()
StringBuilder
StringBuffer
```

## Collections

```text
List
Set
Map
Queue
Deque

ArrayList
LinkedList
HashSet
LinkedHashSet
TreeSet
HashMap
LinkedHashMap
TreeMap
ConcurrentHashMap
```

## equals/hashCode

```text
equals contract
hashCode contract
HashMap
HashSet
mutable keys
identity fields
Objects.equals
Objects.hash
toString
```

## Exceptions

```text
checked
unchecked
Error
Exception
throw
throws
try/catch/finally
try-with-resources
suppressed exceptions
```

## Concurrency

```text
Thread
Runnable
Callable
ExecutorService
Future
CompletableFuture
synchronized
volatile
AtomicInteger
CAS
Lock
deadlock
race condition
starvation
livelock
BlockingQueue
ConcurrentHashMap
virtual threads
```

## JVM

```text
Heap
Stack
Metaspace
ClassLoader
JIT
GC
GC roots
memory leak
OOM
StackOverflowError
thread dump
heap dump
```

## Modern Java

```text
Lambda
Functional Interface
Streams
Optional
Method References
Records
Sealed Classes
Pattern Matching
```

## Design

```text
SOLID
Dependency Injection
Factory
Builder
Strategy
Observer
Adapter
Decorator
Proxy
Facade
```

## Spring

```text
IoC
DI
Beans
@Component
@Service
@Repository
@Controller
@RestController
@Autowired
@Qualifier
@Primary
@Transactional
Spring Boot
Auto Configuration
```

## JPA/Hibernate

```text
Entity
Persistence Context
Managed
Detached
Dirty Checking
Lazy Loading
Eager Loading
N+1
Optimistic Locking
Pessimistic Locking
```

## Production

```text
Caching
Timeouts
Retries
Circuit Breaker
Rate Limiting
Backpressure
Bulkhead
Idempotency
Observability
Logs
Metrics
Traces
Thread Dumps
Heap Dumps
```

---

# 215. YOUR LIVE-CODING CHECKLIST

Before submitting code during an interview:

```text
[ ] Did I clarify the requirement?
[ ] Did I explain my approach?
[ ] Is the code readable?
[ ] Did I handle null/empty input where relevant?
[ ] Did I consider edge cases?
[ ] Did I explain time complexity?
[ ] Did I explain space complexity?
[ ] Did I test mentally with an example?
[ ] Did I avoid unnecessary complexity?
[ ] Did I explain trade-offs?
```

For `equals/hashCode/toString` specifically:

```text
[ ] What defines identity?
[ ] Same fields in equals/hashCode?
[ ] Null-safe?
[ ] Correct type check?
[ ] Mutable fields considered?
[ ] Inheritance considered?
[ ] Sensitive data excluded from toString?
[ ] Arrays handled correctly if present?
[ ] JPA/entity identity considered if relevant?
```

---


# End of Part 2