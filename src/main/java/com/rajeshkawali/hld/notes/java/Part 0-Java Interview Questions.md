# Java Interview Questions — Senior Engineer Answers

## 1. What is Java?

Java is a **high-level, class-based, object-oriented programming language** designed to be portable, robust, secure, and suitable for building large-scale applications.

Java source code is compiled into **bytecode**, which runs on the **JVM (Java Virtual Machine)**.

```java
public class Hello {
    public static void main(String[] args) {
        System.out.println("Hello Java");
    }
}
```

The key idea is:

```text
Java Source Code
       ↓
     javac
       ↓
   Bytecode (.class)
       ↓
      JVM
       ↓
Operating System
```

Java follows the principle:

> Write Once, Run Anywhere.

---

# 2. Why is Java so popular?

Java became popular because of several characteristics:

- Platform independence
- Strong ecosystem and libraries
- Object-oriented design
- Automatic garbage collection
- Multithreading support
- Strong backward compatibility
- Excellent tooling
- Large developer community
- Enterprise adoption
- Good performance through JIT compilation
- Strong frameworks such as Spring and Hibernate

Java is particularly common in:

- Enterprise applications
- Banking
- E-commerce
- Distributed systems
- Backend APIs
- Cloud services
- Android legacy/current ecosystem
- Big-data technologies

---

# 3. What types of applications can you build using Java?

Java can be used for:

- REST APIs
- Microservices
- Enterprise applications
- Banking systems
- E-commerce applications
- Desktop applications
- Distributed systems
- Cloud applications
- Big-data applications
- Messaging systems
- Batch-processing systems
- Android applications

Popular Java technologies include:

```text
Spring Boot
Spring MVC
Spring Security
Hibernate / JPA
Kafka
Maven / Gradle
JUnit
Jakarta EE
```

---

# 4. Why is Java a platform-independent language?

Java source code is compiled into **platform-independent bytecode**, rather than native machine code.

```text
Java Code
   ↓
Java Compiler
   ↓
Bytecode
   ↓
JVM for Windows
JVM for Linux
JVM for macOS
```

The JVM translates bytecode into machine-specific instructions.

Therefore:

> The bytecode is platform-independent, while the JVM implementation is platform-dependent.

This distinction is important in senior-level interviews.

---

# 5. Why are pointers not used in Java?

Java does not expose explicit pointers because direct pointer manipulation can introduce:

- Memory corruption
- Dangling pointers
- Buffer overflows
- Complex memory management
- Security vulnerabilities

Instead, Java uses **references** to access objects.

```java
Person person = new Person();
```

`person` is a reference to a `Person` object.

Java still internally uses memory addresses, but those addresses are **not directly exposed to the programmer**.

---

# 6. Why is Java not a purely object-oriented language?

Java is not considered purely object-oriented because it supports **primitive data types**.

Examples:

```java
int
long
double
float
boolean
char
byte
short
```

For example:

```java
int age = 30;
```

`age` is a primitive value, not an object.

Java provides wrapper classes when an object representation is required:

```java
Integer age = 30;
```

Therefore:

> Java is strongly object-oriented, but not a purely object-oriented language.

---

# 7. Explain JDK, JRE, and JVM

### JVM

JVM executes Java bytecode.

```text
.class → JVM → Machine Code
```

### JRE

JRE provides the environment required to **run** Java applications.

Conceptually:

```text
JRE = JVM + Runtime Libraries
```

### JDK

JDK provides tools required to **develop and run** Java applications.

Conceptually:

```text
JDK = JRE + Development Tools
```

Examples of JDK tools:

```text
javac
java
javadoc
jar
jdb
jcmd
jstack
jmap
```

Modern JDK distributions generally don't package a separate JRE product, but the conceptual distinction remains useful for interviews.

---

# 8. How does JVM work internally?

At a high level:

```text
.java
  ↓
Java Compiler
  ↓
.class bytecode
  ↓
Class Loader
  ↓
Bytecode Verification
  ↓
Runtime Data Areas
  ↓
Execution Engine
  ↓
Native Machine Instructions
```

Important JVM components:

### Class Loader

Loads classes into memory.

### Runtime Data Areas

Include:

- Heap
- JVM stacks
- Method area
- PC register
- Native method stacks

### Execution Engine

Executes bytecode using:

- Interpreter
- JIT compiler

### JIT Compiler

Frequently executed code is compiled into optimized native machine code.

### Garbage Collector

Automatically identifies and reclaims unreachable objects.

---

# 9. What is String Constant Pool?

The String Constant Pool is a special area associated with the JVM's string handling where canonical string instances can be reused.

Example:

```java
String a = "hello";
String b = "hello";

System.out.println(a == b); // true
```

Both references can point to the same pooled String object.

But:

```java
String a = new String("hello");
String b = new String("hello");

System.out.println(a == b); // false
System.out.println(a.equals(b)); // true
```

`intern()` can be used to obtain the canonical pooled representation:

```java
String s = new String("hello");
String pooled = s.intern();
```

---

# 10. Difference between == and equals() for Strings

`==` compares **object references**.

`equals()` compares **logical content**, assuming the class implements it appropriately.

```java
String a = new String("Java");
String b = new String("Java");

System.out.println(a == b);       // false
System.out.println(a.equals(b));  // true
```

Interview answer:

> Use `==` when you intentionally want to compare references. Use `equals()` when you want to compare String content.

---

# 11. Why are Strings immutable?

A String cannot be changed after creation.

```java
String s = "Java";
s.concat(" Programming");

System.out.println(s); // Java
```

Important reasons include:

### 1. Security

Strings are frequently used for:

- File paths
- URLs
- Class names
- Credentials
- Database connections

### 2. String Pooling

Immutable strings can safely be shared.

### 3. Thread Safety

Immutable objects can be safely shared between threads.

### 4. Hashing

Strings are commonly used as HashMap keys.

Their hash value can safely be cached because the content cannot change.

---

# 12. String vs StringBuilder vs StringBuffer

| Type | Mutable | Thread Safe | Typical Use |
|---|---|---|---|
| String | No | Yes | Fixed text |
| StringBuilder | Yes | No | Single-threaded string manipulation |
| StringBuffer | Yes | Yes | Legacy synchronized string manipulation |

Example:

```java
StringBuilder sb = new StringBuilder();

sb.append("Java");
sb.append(" ");
sb.append("Programming");

System.out.println(sb);
```

For most modern application code:

> Prefer `StringBuilder` when repeatedly modifying strings in a single thread.

---

# 13. What is Object-Oriented Programming?

OOP is a programming paradigm where software is modeled using **objects containing state and behavior**.

The four major concepts are:

```text
Encapsulation
Inheritance
Polymorphism
Abstraction
```

---

# 14. What is a class and what is an object?

A **class** is a blueprint.

An **object** is an instance of a class.

```java
class Car {
    String color;

    void drive() {
        System.out.println("Driving");
    }
}

Car car = new Car();
```

`Car` is the class.

`car` is an object/reference to an instance.

---

# 15. What is encapsulation?

Encapsulation means **bundling state and behavior together while controlling access to internal state**.

Example:

```java
class BankAccount {

    private double balance;

    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }

    public double getBalance() {
        return balance;
    }
}
```

The caller cannot directly manipulate:

```java
balance
```

This protects invariants.

---

# 16. What is inheritance?

Inheritance allows one class to reuse and specialize behavior from another class.

```java
class Animal {
    void eat() {
        System.out.println("Eating");
    }
}

class Dog extends Animal {
    void bark() {
        System.out.println("Barking");
    }
}
```

`Dog` has an **is-a** relationship with `Animal`.

Java supports:

- Single inheritance between classes
- Multiple inheritance through interfaces

---

# 17. What is polymorphism?

Polymorphism means:

> One interface/type can represent multiple implementations.

Example:

```java
Animal animal = new Dog();
animal.sound();
```

The actual implementation can be selected at runtime.

Types commonly discussed:

```text
Compile-time polymorphism → method overloading
Runtime polymorphism      → method overriding
```

---

# 18. What is abstraction?

Abstraction means exposing **what an object does** while hiding unnecessary implementation details.

Example:

```java
interface PaymentService {
    void pay(double amount);
}
```

Implementations:

```java
class CardPayment implements PaymentService {
    public void pay(double amount) {
        // Card implementation
    }
}

class UpiPayment implements PaymentService {
    public void pay(double amount) {
        // UPI implementation
    }
}
```

The caller depends on the abstraction:

```java
PaymentService paymentService;
```

rather than a concrete implementation.

---

# 19. What is method overloading?

Method overloading means having multiple methods with the same name but **different parameter lists**.

```java
void calculate(int a) {}

void calculate(int a, int b) {}

void calculate(double a, double b) {}
```

Return type alone cannot differentiate overloaded methods.

This is compile-time polymorphism.

---

# 20. What is method overriding?

Method overriding occurs when a subclass provides a new implementation of an inherited instance method.

```java
class Animal {
    void sound() {
        System.out.println("Animal sound");
    }
}

class Dog extends Animal {

    @Override
    void sound() {
        System.out.println("Bark");
    }
}
```

Runtime dispatch determines which implementation executes.

---

# 21. Overloading vs overriding

| Overloading | Overriding |
|---|---|
| Same method name | Same method signature |
| Different parameters | Same parameters |
| Usually same class | Parent-child relationship |
| Compile-time | Runtime |
| Return type alone insufficient | Covariant return allowed |
| Static methods can be overloaded | Static methods are hidden, not overridden |

---

# 22. What is the `this` keyword?

`this` refers to the **current object**.

Example:

```java
class User {

    private String name;

    User(String name) {
        this.name = name;
    }
}
```

It can also invoke:

```java
this();
```

or:

```java
this.someMethod();
```

---

# 23. What is the `super` keyword?

`super` refers to the immediate parent-class portion of the current object.

It can be used to:

```java
super.method();
super.field;
super();
```

Example:

```java
class Dog extends Animal {

    Dog() {
        super();
    }

    void print() {
        super.sound();
    }
}
```

---

# 24. What are constructors in Java?

A constructor initializes an object when it is created.

```java
class User {

    String name;

    User(String name) {
        this.name = name;
    }
}
```

Constructors:

- Have the same name as the class
- Do not have a return type
- Are invoked during object creation
- Can be overloaded
- Are not inherited

---

# 25. What is constructor overloading?

Having multiple constructors with different parameter lists.

```java
class User {

    User() {}

    User(String name) {}

    User(String name, int age) {}
}
```

This allows objects to be initialized in different ways.

---

# 26. What is an abstract class?

An abstract class is a class declared using `abstract`.

It may contain:

- Abstract methods
- Concrete methods
- Fields
- Constructors
- Static methods

Example:

```java
abstract class Animal {

    abstract void sound();

    void eat() {
        System.out.println("Eating");
    }
}
```

You cannot directly instantiate it:

```java
// new Animal(); // invalid
```

---

# 27. What is an interface in Java?

An interface defines a contract that classes can implement.

```java
interface Payment {
    void pay();
}

class CardPayment implements Payment {

    @Override
    public void pay() {
        System.out.println("Paying by card");
    }
}
```

Modern Java interfaces can also contain:

- `default` methods
- `static` methods
- `private` methods

Interfaces are particularly important for:

- Abstraction
- Loose coupling
- Dependency inversion
- Multiple type inheritance

---

# 28. What is a JavaBean?

A JavaBean is a class that traditionally follows conventions such as:

- Public no-argument constructor
- Private properties
- Public getters/setters
- Serializable in the classic specification

Example:

```java
public class Employee {

    private String name;

    public Employee() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

---

# 29. JavaBean vs POJO

A **POJO** is simply a Plain Old Java Object without requiring special framework inheritance or interfaces.

A JavaBean follows additional conventions.

```text
POJO
 └── General simple Java object

JavaBean
 └── POJO following bean conventions
```

Not every POJO is a JavaBean.

---

# 30. What is composition in OOP?

Composition represents a strong **has-a** relationship where the contained object's lifecycle is generally owned by the containing object.

```java
class Engine {}

class Car {
    private final Engine engine = new Engine();
}
```

If the `Car` is destroyed, its owned `Engine` is typically no longer meaningful independently.

Composition is often preferred over inheritance for flexibility.

---

# 31. What is aggregation?

Aggregation is a weaker **has-a** relationship.

The contained object can exist independently.

```java
class Employee {}

class Department {

    private List<Employee> employees;
}
```

An Employee can exist independently of a particular Department.

---

# 32. What is association?

Association represents a general relationship between objects.

Example:

```java
class Doctor {}

class Patient {}
```

A Doctor may be associated with a Patient.

Association does not necessarily imply ownership.

---

# 33. What is coupling?

Coupling measures how strongly one component depends on another.

### High coupling

```java
class OrderService {
    private MySqlRepository repository = new MySqlRepository();
}
```

The service is tightly coupled to a concrete implementation.

### Lower coupling

```java
class OrderService {

    private final OrderRepository repository;

    OrderService(OrderRepository repository) {
        this.repository = repository;
    }
}
```

Now the dependency can be replaced.

Low coupling generally improves:

- Testing
- Maintainability
- Flexibility
- Extensibility

---

# 34. What is cohesion?

Cohesion describes how closely related the responsibilities within a component are.

High cohesion:

```java
class InvoiceCalculator {
    // Only invoice calculation responsibilities
}
```

Low cohesion:

```java
class Utility {
    // Database logic
    // Email logic
    // Payment logic
    // File processing
}
```

Good design generally aims for:

> High cohesion + low coupling.

---

# 35. What is runtime polymorphism?

Runtime polymorphism occurs when a method implementation is selected based on the **actual object type at runtime**.

```java
Animal animal = new Dog();

animal.sound();
```

If `Dog` overrides `sound()`, the JVM invokes:

```text
Dog.sound()
```

This is also called **dynamic method dispatch**.

---

# 36. Shallow copy vs deep copy

### Shallow copy

Copies the object but references the same nested objects.

```text
Object A
  └── Address X

Shallow Copy
  └── Address X
```

### Deep copy

Copies the nested objects as well.

```text
Object A
  └── Address X

Deep Copy
  └── Address Y
```

Deep copies provide stronger independence but may cost more memory and processing.

---

# 37. What is object cloning in Java?

Java provides cloning through `Object.clone()` and the `Cloneable` marker interface.

Example:

```java
class User implements Cloneable {

    String name;

    @Override
    protected User clone() throws CloneNotSupportedException {
        return (User) super.clone();
    }
}
```

However, `Cloneable` is widely considered awkward API design.

In modern code, prefer:

- Copy constructors
- Factory methods
- Explicit copy methods

when practical.

---

# 38. Difference between is-a and has-a

### IS-A

Represents inheritance/subtyping.

```java
Dog IS-A Animal
```

```java
class Dog extends Animal {}
```

### HAS-A

Represents composition/aggregation.

```text
Car HAS-A Engine
```

```java
class Car {
    private Engine engine;
}
```

---

# 39. What does "favor composition over inheritance" mean?

It means prefer assembling objects through dependencies rather than creating deep inheritance hierarchies when inheritance does not represent a strong subtype relationship.

Instead of:

```java
class Car extends Engine {}
```

use:

```java
class Car {
    private Engine engine;
}
```

Composition generally provides better:

- Flexibility
- Testability
- Maintainability
- Runtime configurability

Inheritance is still appropriate when there is a genuine **is-a** relationship.

---

# 40. Object identity vs object equality

### Identity

Whether two references refer to the **same object**.

```java
a == b
```

### Equality

Whether two objects should be considered logically equivalent.

```java
a.equals(b)
```

Example:

```java
User a = new User("John");
User b = new User("John");
```

They may be different objects but logically equal.

---

# 41. Immutable vs mutable objects

### Immutable

State cannot change after construction.

Examples:

```text
String
Integer
LocalDate
BigInteger
```

### Mutable

State can change.

Examples:

```text
StringBuilder
ArrayList
HashMap
```

Immutable objects are generally easier to reason about and safely share between threads.

---

# 42. What is method hiding in Java?

Static methods are **hidden**, not overridden.

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

Then:

```java
Parent p = new Child();
p.show();
```

prints:

```text
Parent
```

because static method resolution is based on the reference type.

---

# 43. What is object association and why is it important?

Association represents relationships between objects.

For example:

```text
Customer → Orders
Doctor   → Patients
Teacher  → Students
```

It helps model real-world domain relationships.

Good association design is important because it affects:

- Coupling
- Navigation
- Object lifecycle
- Memory usage
- Maintainability

---

# MULTITHREADING

# 44. What is a thread in Java?

A thread is an independent execution path within a process.

Example:

```java
Thread thread = new Thread(() -> {
    System.out.println("Running");
});

thread.start();
```

Modern Java applications typically prefer executors and structured concurrency APIs over manually creating large numbers of raw threads.

---

# 45. Process vs Thread

| Process | Thread |
|---|---|
| Independent program execution | Execution unit inside process |
| Own address space | Shares process memory |
| More expensive | Generally cheaper |
| Stronger isolation | Less isolation |
| IPC required for communication | Shared memory can be used |

---

# 46. What is context switching?

Context switching occurs when the CPU switches from one executing thread/task to another.

The system must save and restore execution state.

Excessive context switching can hurt performance because switching itself has overhead.

---

# 47. What is the Java thread lifecycle?

Java exposes states through `Thread.State`:

```text
NEW
RUNNABLE
BLOCKED
WAITING
TIMED_WAITING
TERMINATED
```

A simplified flow:

```text
NEW
 ↓
start()
 ↓
RUNNABLE
 ↓
Executing / Waiting / Blocked
 ↓
TERMINATED
```

Note that Java's `RUNNABLE` includes threads that are ready to run and threads actually running; the JVM does not expose a separate `RUNNING` state.

---

# 48. What is synchronization and why is it needed?

Synchronization controls concurrent access to shared mutable state.

Example:

```java
public synchronized void increment() {
    count++;
}
```

Without proper synchronization, multiple threads may observe or modify shared state inconsistently.

Synchronization provides important **memory-visibility and ordering guarantees**, not just mutual exclusion.

---

# 49. What is deadlock?

Deadlock occurs when threads wait indefinitely for resources held by each other.

Example:

```text
Thread A holds Lock 1
Thread A waits for Lock 2

Thread B holds Lock 2
Thread B waits for Lock 1
```

Neither can continue.

Common prevention techniques:

- Consistent lock ordering
- Avoid unnecessary nested locks
- Use timed locking where appropriate
- Reduce lock scope

---

# 50. What is a race condition?

A race condition occurs when program correctness depends on the unpredictable timing of concurrent operations.

Example:

```java
count++;
```

is not one indivisible operation.

Conceptually:

```text
read count
add 1
write count
```

Two threads can interleave these operations and lose updates.

---

# 51. synchronized method vs synchronized block

### Method

```java
public synchronized void update() {
}
```

Locks the monitor associated with the object (`this`) for an instance method.

### Block

```java
public void update() {

    synchronized (lock) {
        // critical section
    }
}
```

Blocks allow:

- Smaller critical sections
- Specific lock objects
- Better control over concurrency

---

# 52. wait vs sleep vs yield

### `wait()`

- Releases the object's monitor
- Must be called while owning that monitor
- Used for coordination

### `sleep()`

- Pauses the current thread for a duration
- Does not release monitors it already holds

### `yield()`

- Gives the scheduler a hint that the thread is willing to let another runnable thread execute
- No guarantee is made

Example:

```java
Thread.sleep(1000);
```

---

# 53. What is a thread pool?

A thread pool maintains reusable worker threads.

Instead of:

```text
Request → Create Thread
Request → Create Thread
Request → Create Thread
```

we use:

```text
Tasks → Thread Pool → Worker Threads
```

Benefits:

- Reduces thread-creation overhead
- Controls concurrency
- Prevents uncontrolled thread creation
- Improves resource management

Example:

```java
ExecutorService executor =
        Executors.newFixedThreadPool(10);

executor.submit(() -> process());

executor.shutdown();
```

In production, pool sizing should be based on workload characteristics rather than arbitrary numbers.

---

# 54. Callable and Future

`Callable` is similar to `Runnable`, but it can:

- Return a value
- Throw checked exceptions

```java
Callable<Integer> task = () -> 10;
```

`Future` represents the result of an asynchronous computation.

```java
Future<Integer> future = executor.submit(task);

Integer result = future.get();
```

`get()` can block until the computation finishes.

---

# 55. volatile vs synchronized

`volatile` provides **visibility and ordering guarantees** for a variable.

```java
private volatile boolean running = true;
```

If one thread changes it, other threads can observe the updated value.

However:

```java
count++;
```

is still not atomic even when `count` is volatile.

`synchronized` provides:

- Mutual exclusion
- Visibility
- Ordering

Use `volatile` for appropriate state-publication/visibility scenarios, not as a general replacement for locking.

---

# EXCEPTIONS

# 56. What is an exception?

An exception is an event representing an abnormal condition during program execution.

Examples:

```text
IOException
SQLException
NullPointerException
IllegalArgumentException
```

Java uses:

```java
try
catch
finally
throw
throws
```

to handle exceptions.

---

# 57. Checked vs unchecked exceptions

### Checked

Compiler requires them to be handled or declared.

Examples:

```text
IOException
SQLException
```

### Unchecked

Subclasses of `RuntimeException`.

Examples:

```text
NullPointerException
IllegalArgumentException
IllegalStateException
```

Unchecked exceptions usually indicate programming errors or invalid runtime state.

---

# 58. Explain try-catch-finally

```java
try {
    riskyOperation();
} catch (Exception e) {
    handle(e);
} finally {
    cleanup();
}
```

`finally` generally executes whether the operation succeeds or fails, although there are exceptional JVM termination scenarios where it may not execute.

For resource management, prefer try-with-resources.

---

# 59. throw vs throws

### `throw`

Actually throws an exception.

```java
throw new IllegalArgumentException("Invalid age");
```

### `throws`

Declares that a method may propagate checked exceptions.

```java
void readFile() throws IOException {
}
```

---

# 60. Exception vs Error

Both extend `Throwable`.

### Exception

Usually represents conditions an application may reasonably handle.

Examples:

```text
IOException
SQLException
```

### Error

Generally represents serious JVM/system-level problems.

Examples:

```text
OutOfMemoryError
StackOverflowError
```

Applications generally should not attempt to recover from arbitrary `Error`s.

---

# 61. What is exception chaining?

Exception chaining preserves the original cause while throwing a higher-level exception.

```java
try {
    databaseCall();
} catch (SQLException e) {
    throw new OrderServiceException(
        "Unable to create order", e);
}
```

Now the higher-level exception contains the original cause.

This is important for debugging while maintaining abstraction boundaries.

---

# 62. final vs finally vs finalize

### final

Used for:

- Variables
- Methods
- Classes

```java
final int x = 10;
```

### finally

Block used for cleanup after exception handling.

```java
finally {
    cleanup();
}
```

### finalize

A legacy Object method historically associated with GC-based cleanup.

It is **deprecated and should not be used**.

Modern Java applications should use:

- try-with-resources
- `AutoCloseable`
- `Cleaner` only for specialized cases

---

# 63. What is try-with-resources?

Try-with-resources automatically closes resources implementing `AutoCloseable`.

```java
try (BufferedReader reader =
         new BufferedReader(new FileReader("data.txt"))) {

    System.out.println(reader.readLine());

} catch (IOException e) {
    // handle exception
}
```

It is preferred because it:

- Automatically closes resources
- Handles exceptions during close
- Reduces boilerplate
- Makes resource ownership clearer

---

# 64. `throw new RuntimeException` vs `throw new Exception`

```java
throw new RuntimeException("Failure");
```

creates an unchecked exception.

```java
throw new Exception("Failure");
```

creates a checked exception.

A checked exception forces callers to either:

```java
catch
```

or:

```java
throws
```

The choice should communicate whether callers are expected to reasonably recover from the condition.

---

# 65. What happens if an exception occurs inside a catch block?

The new exception is not automatically handled by the same `catch` block.

Example:

```java
try {
    risky();
} catch (Exception e) {
    throw new RuntimeException(e);
}
```

The new exception propagates outward and can be handled by an enclosing caller.

If it remains uncaught, it eventually reaches the thread's uncaught-exception handling mechanism.

---

# COLLECTIONS

# 66. Comparable vs Comparator

### Comparable

Defines the object's **natural ordering**.

```java
class Employee implements Comparable<Employee> {

    public int compareTo(Employee other) {
        return this.id - other.id;
    }
}
```

Used with:

```java
Collections.sort(list);
```

### Comparator

Defines an external/custom ordering.

```java
Comparator<Employee> byName =
    Comparator.comparing(Employee::getName);
```

Useful when an object needs multiple possible sorting strategies.

---

# 67. Fail-Fast vs Fail-Safe Iterators

### Fail-fast

Typically detects structural modification and throws:

```text
ConcurrentModificationException
```

Example:

```java
ArrayList
HashMap
HashSet
```

### Fail-safe

"Fail-safe" is informal terminology rather than a formal Java collection category.

Some concurrent collections use weakly consistent or snapshot-style iteration instead.

Examples:

```text
ConcurrentHashMap
CopyOnWriteArrayList
```

They do not necessarily throw `ConcurrentModificationException` when concurrently modified.

---

# 68. Collection vs Collections

### Collection

`Collection` is an interface.

```java
List
Set
Queue
```

extend it.

### Collections

`Collections` is a utility class containing static methods.

```java
Collections.sort(list);
Collections.reverse(list);
Collections.unmodifiableList(list);
```

---

# 69. Java Collections Framework and hierarchy

Simplified hierarchy:

```text
Iterable
   |
Collection
   |
   +── List
   |    +── ArrayList
   |    +── LinkedList
   |    +── Vector
   |
   +── Set
   |    +── HashSet
   |    +── LinkedHashSet
   |    +── SortedSet
   |         +── TreeSet
   |
   +── Queue
        +── PriorityQueue
        +── Deque
             +── ArrayDeque
```

`Map` is part of the Collections Framework but **does not extend Collection**.

```text
Map
 ├── HashMap
 ├── LinkedHashMap
 ├── TreeMap
 └── ConcurrentHashMap
```

---

# 70. HashSet vs LinkedHashSet vs TreeSet

| Set | Ordering | Typical Complexity |
|---|---|---|
| HashSet | No guaranteed order | O(1) average |
| LinkedHashSet | Insertion order | O(1) average |
| TreeSet | Sorted order | O(log n) |

Use:

```text
HashSet        → uniqueness
LinkedHashSet  → uniqueness + insertion order
TreeSet        → uniqueness + sorted order
```

---

# 71. HashMap vs ConcurrentHashMap

### HashMap

- Not thread-safe
- Allows one null key
- Allows null values
- Good for single-threaded/external synchronization scenarios

### ConcurrentHashMap

- Designed for concurrent access
- Does not allow null keys or null values
- Supports concurrent reads/writes
- Uses fine-grained synchronization/CAS-based techniques internally depending on operation

Use `ConcurrentHashMap` when multiple threads need safe concurrent access to a mutable map.

---

# 72. HashMap vs LinkedHashMap

`HashMap` does not guarantee iteration order.

`LinkedHashMap` maintains predictable ordering, usually:

```text
Insertion order
```

or optionally:

```text
Access order
```

Example:

```java
LinkedHashMap<String, Integer> map =
    new LinkedHashMap<>(16, 0.75f, true);
```

Access-order mode is useful for implementing LRU-style caches.

---

# 73. Intermediate vs Terminal Stream Operations

### Intermediate

Return another Stream.

Examples:

```java
filter()
map()
flatMap()
sorted()
distinct()
limit()
```

They are generally lazy.

### Terminal

Produce a final result or side effect.

Examples:

```java
collect()
reduce()
forEach()
count()
findFirst()
anyMatch()
```

After a terminal operation, the stream is consumed.

---

# 74. Collections vs Streams

Collections are primarily about:

> Storing and managing data.

Streams are primarily about:

> Processing data declaratively.

Example:

```java
List<String> names = List.of("John", "Alex", "Bob");

List<String> result =
    names.stream()
         .filter(name -> name.length() > 3)
         .map(String::toUpperCase)
         .toList();
```

A collection stores the elements.

A stream describes a processing pipeline.

---

# 75. What is functional programming in Java?

Functional programming emphasizes:

- Functions
- Immutability
- Declarative operations
- Avoiding shared mutable state
- Higher-order functions

Java supports functional programming through:

```text
Lambda expressions
Streams
Functional interfaces
Method references
Optional
```

Java is not a purely functional language.

---

# 76. What is a lambda expression?

A lambda is a concise way of representing behavior.

```java
(a, b) -> a + b
```

Example:

```java
List<String> names = List.of("John", "Alex");

names.forEach(name ->
    System.out.println(name));
```

Lambdas work with functional interfaces.

---

# 77. What is a functional interface?

An interface with exactly **one abstract method**.

Example:

```java
@FunctionalInterface
interface Calculator {
    int calculate(int a, int b);
}
```

It can be implemented using a lambda:

```java
Calculator c = (a, b) -> a + b;
```

Examples from Java:

```text
Predicate
Function
Consumer
Supplier
Runnable
Callable
Comparator
```

Default/static methods do not count as abstract methods.

---

# 78. What is the Stream API?

The Stream API provides a declarative way to process sequences of data.

Example:

```java
List<Integer> result =
    numbers.stream()
           .filter(n -> n % 2 == 0)
           .map(n -> n * 2)
           .toList();
```

Streams support:

- Filtering
- Mapping
- Sorting
- Grouping
- Reduction
- Aggregation
- Short-circuiting

---

# 79. map vs flatMap

`map()` transforms each element into another element.

```java
List<String> names =
    users.stream()
         .map(User::getName)
         .toList();
```

`flatMap()` transforms each element into a stream and then flattens the result.

```java
List<String> allItems =
    orders.stream()
          .flatMap(order -> order.getItems().stream())
          .toList();
```

Think:

```text
map:
A → B

flatMap:
A → Stream<B> → B
```

---

# 80. What is a method reference?

A method reference is shorthand for certain lambda expressions.

Instead of:

```java
names.forEach(name -> System.out.println(name));
```

use:

```java
names.forEach(System.out::println);
```

Types include:

```text
Class::staticMethod
object::instanceMethod
Class::instanceMethod
Class::new
```

---

# 81. What is immutability in functional programming?

Immutability means data is not modified after creation.

Instead of:

```java
user.setName("John");
```

an immutable design might create a new object:

```java
user.withName("John");
```

Benefits include:

- Easier reasoning
- Safer concurrency
- Fewer side effects
- Better composability

---

# 82. What is Predicate?

`Predicate<T>` represents a function that accepts a value and returns boolean.

```java
Predicate<Integer> even =
    n -> n % 2 == 0;
```

Usage:

```java
numbers.stream()
       .filter(even)
       .toList();
```

---

# 83. What is Optional?

`Optional<T>` represents the presence or absence of a value.

```java
Optional<String> name =
    Optional.ofNullable(user.getName());
```

Example:

```java
String result =
    name.orElse("Unknown");
```

It is useful for explicitly modeling potentially absent return values.

It should not generally be used indiscriminately for every field, parameter, or local variable.

---

# 84. How do you handle exceptions inside lambda expressions?

Standard functional interfaces don't declare checked exceptions.

For example:

```java
list.forEach(item -> {
    try {
        process(item);
    } catch (IOException e) {
        throw new RuntimeException(e);
    }
});
```

Other approaches include:

- Handling the exception inside the lambda
- Creating a wrapper utility
- Designing a custom functional interface that allows checked exceptions

Do not blindly swallow exceptions.

---

# 85. What is lazy evaluation in streams?

Intermediate stream operations are generally not executed immediately.

```java
stream.filter(...)
      .map(...);
```

Nothing necessarily executes until a terminal operation occurs.

```java
stream.filter(...)
      .map(...)
      .collect(...);
```

Benefits:

- Avoids unnecessary work
- Enables operation fusion
- Enables short-circuiting
- Can improve efficiency

---

# 86. What is Supplier?

`Supplier<T>` takes no arguments and returns a value.

```java
Supplier<String> supplier =
    () -> "Hello";
```

Example:

```java
String value = supplier.get();
```

Useful for lazy value generation.

---

# 87. What is Consumer?

`Consumer<T>` accepts a value and returns nothing.

```java
Consumer<String> printer =
    value -> System.out.println(value);
```

Used commonly with:

```java
list.forEach(printer);
```

---

# 88. What is BiFunction?

`BiFunction<T, U, R>` accepts two arguments and returns a result.

```java
BiFunction<Integer, Integer, Integer> add =
    (a, b) -> a + b;
```

Useful when a function requires two inputs.

---

# 89. What is short-circuiting in streams?

Short-circuiting means a stream operation can stop processing once the result is known.

Examples:

```java
anyMatch()
allMatch()
noneMatch()
findFirst()
findAny()
limit()
```

Example:

```java
boolean found =
    numbers.stream()
           .anyMatch(n -> n > 100);
```

The stream can stop as soon as a matching value is found.

---

# 90. What is parallel stream processing?

A parallel stream divides processing across multiple threads, typically using the common ForkJoinPool.

```java
numbers.parallelStream()
       .map(this::process)
       .toList();
```

It can help for:

- Large datasets
- CPU-bound independent operations
- Expensive computations

It can hurt performance for:

- Small datasets
- Blocking I/O
- Operations with shared mutable state
- Order-sensitive processing
- Poorly splittable workloads

Never assume parallel streams automatically make code faster.

---

# 91. What is reduction in streams?

Reduction combines multiple elements into a single result.

Example:

```java
int sum =
    numbers.stream()
           .reduce(0, Integer::sum);
```

Other examples:

```text
sum
product
min
max
combined result
```

Reduction is particularly important in parallel processing because the reduction operation should have suitable associativity properties.

---

# 92. What is a higher-order function in Java?

A higher-order function is a function that:

- Accepts another function as an argument, or
- Returns a function

Java supports this using functional interfaces.

Example:

```java
Function<Integer, Integer> square =
    x -> x * x;
```

Passing behavior:

```java
list.stream()
    .map(square);
```

---

# COLLECTIONS — DEEP DIVE

# 93. What is the Java Collections Framework?

It is a standardized set of interfaces, implementations, and algorithms for storing and manipulating groups of objects.

Major interfaces:

```text
List
Set
Queue
Deque
Map
```

Common implementations:

```text
ArrayList
LinkedList
HashSet
TreeSet
HashMap
LinkedHashMap
TreeMap
PriorityQueue
ArrayDeque
ConcurrentHashMap
```

---

# 94. List vs Set vs Map

### List

Ordered collection allowing duplicates.

```java
List<String>
```

### Set

Collection that does not allow duplicate elements according to its equality/ordering semantics.

```java
Set<String>
```

### Map

Key-value structure.

```java
Map<String, Integer>
```

Maps are not subtypes of `Collection`.

---

# 95. ArrayList vs LinkedList

### ArrayList

Backed by a dynamically resized array.

Excellent for:

```text
Random access → O(1)
Appending → O(1) amortized
```

### LinkedList

Doubly linked list.

Insertion/removal can be O(1) **when you already have the relevant node/iterator position**, but locating an arbitrary position is O(n).

In practice:

> `ArrayList` is usually the better default.

LinkedList's theoretical insertion advantage often does not translate into better real-world performance because of pointer chasing and poor cache locality.

---

# 96. HashSet vs TreeSet

### HashSet

Uses hashing.

```text
Average add/search/remove → O(1)
```

No sorted ordering guarantee.

### TreeSet

Typically backed by a balanced search tree.

```text
add/search/remove → O(log n)
```

Maintains sorted order.

Use TreeSet when ordering is part of the requirement.

---

# 97. What is an Iterator?

An Iterator provides a standard way to traverse a collection.

```java
Iterator<String> iterator =
    list.iterator();

while (iterator.hasNext()) {
    String value = iterator.next();
}
```

It can safely remove elements through:

```java
iterator.remove();
```

when supported.

---

# 98. Iterator vs ListIterator

`Iterator`:

- Forward traversal
- Works with many collection types
- Supports remove

`ListIterator`:

- Only for Lists
- Forward and backward traversal
- Supports add
- Supports set
- Supports indexed positioning

Example:

```java
ListIterator<String> it =
    list.listIterator();
```

---

# 99. What is Fail-Fast in Java Collections?

A fail-fast iterator attempts to detect structural modification of a collection outside the iterator's supported modification mechanism.

Example:

```java
List<Integer> list =
    new ArrayList<>(List.of(1, 2, 3));

for (Integer value : list) {
    list.add(4); // may throw ConcurrentModificationException
}
```

Important:

> Fail-fast behavior is a best-effort implementation behavior, not a concurrency guarantee.

It should not be relied upon for program correctness.

---

# 100. HashMap vs Hashtable

Assuming "Hashable" means **Hashtable**:

### HashMap

- Not synchronized
- Allows one null key
- Allows null values
- Modern general-purpose map

### Hashtable

- Legacy class
- Synchronized methods
- Does not allow null keys or values
- Usually not preferred for new code

For concurrent applications, prefer modern concurrency utilities such as:

```java
ConcurrentHashMap
```

rather than `Hashtable`.

---

# 101. What is ConcurrentHashMap and how does it work internally?

`ConcurrentHashMap` is a thread-safe hash-based map optimized for concurrent access.

Modern implementations use techniques such as:

- CAS (Compare-And-Set)
- Volatile operations
- Fine-grained synchronization
- Per-bin synchronization when needed

It does not use one global lock around the entire map for every operation.

This allows multiple threads to operate concurrently in many situations.

Example:

```java
ConcurrentHashMap<String, Integer> map =
    new ConcurrentHashMap<>();

map.put("A", 1);
```

It also provides atomic compound operations:

```java
map.computeIfAbsent(key, k -> createValue(k));
```

This is often safer than:

```java
if (!map.containsKey(key)) {
    map.put(key, value);
}
```

because the latter is not atomic.

---

# 102. How does HashMap work internally?

Conceptually, a HashMap stores entries in an array of buckets.

```text
HashMap
   |
   +-- Bucket 0
   +-- Bucket 1
   +-- Bucket 2
   +-- Bucket 3
```

When inserting:

```java
map.put(key, value);
```

Java:

1. Calculates the key's hash.
2. Spreads the hash.
3. Calculates a bucket index.
4. Searches entries in that bucket.
5. Uses `equals()` to determine key equality.
6. Inserts or updates the entry.

Modern Java HashMap can convert heavily-colliding buckets into balanced tree structures under suitable conditions.

Average lookup is approximately:

```text
O(1)
```

while pathological/collision-heavy behavior is improved by treeification.

---

# 103. What is LinkedHashMap?

`LinkedHashMap` extends HashMap behavior by maintaining predictable iteration order using a linked structure between entries.

It can maintain:

```text
Insertion order
```

or:

```text
Access order
```

Example:

```java
Map<String, Integer> cache =
    new LinkedHashMap<>(16, 0.75f, true);
```

Useful for:

- LRU-style caches
- Predictable iteration
- Ordered maps

---

# 104. What is TreeMap?

`TreeMap` stores keys in sorted order.

It is typically implemented using a Red-Black tree.

Typical operations:

```text
get     → O(log n)
put     → O(log n)
remove  → O(log n)
```

Compared with HashMap:

```text
HashMap  → fast lookup, no sorted ordering
TreeMap  → sorted keys, O(log n)
```

TreeMap is useful when you need:

- Sorted keys
- Range queries
- `floorKey`
- `ceilingKey`
- `subMap`

---

# 105. What is CopyOnWriteArrayList?

`CopyOnWriteArrayList` is a thread-safe list where mutations create a new underlying array.

Example:

```java
CopyOnWriteArrayList<String> list =
    new CopyOnWriteArrayList<>();
```

Best suited for:

> Many reads + very few writes.

Typical use cases:

- Listener lists
- Configuration snapshots
- Observer registries

Avoid it for write-heavy workloads because every mutation can involve copying the array.

Its iterators operate over a snapshot and do not reflect subsequent modifications.

---

# 106. Fail-Fast vs Fail-Safe Iterators

In practical interview terms:

| Fail-Fast | "Fail-Safe"/Concurrent |
|---|---|
| Attempts to detect structural changes | Designed for concurrent modification |
| May throw ConcurrentModificationException | Generally does not |
| ArrayList / HashMap examples | ConcurrentHashMap / CopyOnWriteArrayList |
| Not a concurrency guarantee | Provides defined concurrent semantics |

More precisely, "fail-safe" is informal terminology. Java's APIs instead describe behaviors such as **weakly consistent** or **snapshot** iterators.

---

# 107. Comparable vs Comparator

`Comparable`:

```java
class Employee
        implements Comparable<Employee> {

    @Override
    public int compareTo(Employee other) {
        return Integer.compare(id, other.id);
    }
}
```

Defines natural ordering.

`Comparator`:

```java
Comparator<Employee> bySalary =
    Comparator.comparing(Employee::getSalary);
```

Defines external ordering.

Use Comparator when you need multiple sorting strategies.

---

# 108. Why are equals() and hashCode() important in HashSet/HashMap?

Hash-based collections rely on both hashing and equality.

The contract is:

> If `a.equals(b)` is true, then `a.hashCode() == b.hashCode()` must also be true.

Example:

```java
class User {

    private final int id;

    @Override
    public boolean equals(Object o) {
        // compare id
    }

    @Override
    public int hashCode() {
        return Integer.hashCode(id);
    }
}
```

If `equals()` and `hashCode()` are inconsistent, HashMap/HashSet behavior can become incorrect.

For example, a logically equal key may not be found because it hashes to a different bucket.

---

# 109. What is PriorityQueue?

`PriorityQueue` is a queue where elements are ordered according to their priority rather than insertion order.

It is typically implemented using a binary heap.

```java
PriorityQueue<Integer> queue =
    new PriorityQueue<>();

queue.offer(30);
queue.offer(10);
queue.offer(20);

System.out.println(queue.poll()); // 10
```

Typical complexity:

```text
offer → O(log n)
poll  → O(log n)
peek  → O(1)
```

Important:

> Iterating over a PriorityQueue does not produce fully sorted order.

---

# 110. What is WeakHashMap?

`WeakHashMap` uses weak references for its keys.

If a key is no longer strongly reachable elsewhere, it may be garbage-collected and the corresponding mapping can disappear.

Example use cases:

- Metadata associated with externally owned objects
- Certain cache-like structures

It should not be treated as a general-purpose cache.

Garbage collection behavior makes its contents inherently non-deterministic.

---

# 111. What is IdentityHashMap?

`IdentityHashMap` uses **reference identity** rather than normal `equals()` equality for keys.

It effectively uses:

```java
== 
```

rather than:

```java
equals()
```

Example:

```java
String a = new String("Java");
String b = new String("Java");
```

Normally:

```java
a.equals(b) == true
```

But identity-based mapping treats:

```java
a != b
```

as different keys.

`IdentityHashMap` is useful for specialized cases such as:

- Object graph traversal
- Graph algorithms
- Serialization/cycle detection
- Tracking object identity

It should not be used as a normal replacement for `HashMap`.

---

# SENIOR-LEVEL QUICK REVISION

## Java Fundamentals

```text
Java
 ├── Platform independent through bytecode + JVM
 ├── Object-oriented
 ├── Garbage collected
 ├── Strongly typed
 ├── Multithreaded
 └── JIT optimized
```

## JVM

```text
Class Loader
     ↓
Bytecode Verification
     ↓
Runtime Data Areas
     ↓
Execution Engine
     ├── Interpreter
     └── JIT Compiler
     ↓
Native Code
```

## OOP

```text
Encapsulation → Protect internal state
Inheritance   → Reuse/specialize through is-a
Polymorphism  → One abstraction, multiple implementations
Abstraction   → Hide implementation details
```

## Relationships

```text
IS-A     → Inheritance
HAS-A    → Composition / Aggregation
USES-A   → Association / Dependency
```

## Collections

```text
List
 ├── ArrayList
 └── LinkedList

Set
 ├── HashSet
 ├── LinkedHashSet
 └── TreeSet

Queue
 └── PriorityQueue

Map
 ├── HashMap
 ├── LinkedHashMap
 ├── TreeMap
 └── ConcurrentHashMap
```

## Big-O Cheat Sheet

```text
ArrayList
get             O(1)
append          O(1) amortized
insert/remove   O(n)

HashMap
get             O(1) average
put             O(1) average
remove          O(1) average

TreeMap
get             O(log n)
put             O(log n)
remove          O(log n)

HashSet
contains        O(1) average

TreeSet
contains        O(log n)

PriorityQueue
peek            O(1)
offer           O(log n)
poll            O(log n)
```

## Threading

```text
volatile
→ visibility + ordering
→ NOT general atomicity

synchronized
→ mutual exclusion + visibility + ordering

AtomicInteger
→ atomic operations without explicit locking

ConcurrentHashMap
→ concurrent map access

ExecutorService
→ thread/task management
```

## Streams

```text
Source
  ↓
Intermediate Operations
  ↓
Intermediate Operations
  ↓
Terminal Operation
```

Example:

```java
List<String> result =
    users.stream()
         .filter(User::isActive)
         .map(User::getName)
         .sorted()
         .toList();
```

The senior-engineer mindset is:

> Don't just know what an API does. Know its contract, complexity, concurrency behavior, memory implications, failure modes, and when NOT to use it.