# Singleton Design Pattern

## 1. Definition

The **Singleton Design Pattern** is a **creational design pattern** that ensures:

1. **Only one instance of a class is created**, and
2. A **global access point** is provided to that instance.

### In simple words

> **Singleton Pattern = Create only one object of a class and provide a way to access that same object everywhere.**

---

# 2. Real-Life Example

Imagine a **Configuration Manager** in an application.

There is usually no need to create multiple configuration managers:

```text
Application
     |
     ↓
Configuration Manager
     |
     ├── Database URL
     ├── API URL
     ├── Environment
     └── Application settings
```

We want:

```text
ConfigManager → Object 1
ConfigManager → Object 1
ConfigManager → Object 1
```

Not:

```text
ConfigManager → Object 1
ConfigManager → Object 2
ConfigManager → Object 3
```

---

# 3. How Singleton Works

A Singleton class generally has three important things:

### 1. Private constructor

Prevents other classes from creating objects using `new`.

```java
private Singleton() {
}
```

### 2. Private static instance

Stores the single object.

```java
private static Singleton instance;
```

### 3. Public static method

Provides access to that single object.

```java
public static Singleton getInstance() {
    return instance;
}
```

So the structure is:

```text
             Singleton
                 |
        ┌────────┴────────┐
        |                 |
 private constructor   static instance
        |                 |
        └────────┬────────┘
                 ↓
           getInstance()
                 ↓
          Same Object
```

---

# 4. Basic Singleton Example

```java
class Singleton {

    private static Singleton instance;

    private Singleton() {
        // Private constructor
    }

    public static Singleton getInstance() {

        if (instance == null) {
            instance = new Singleton();
        }

        return instance;
    }
}
```

Usage:

```java
public class Main {

    public static void main(String[] args) {

        Singleton obj1 = Singleton.getInstance();

        Singleton obj2 = Singleton.getInstance();

        System.out.println(obj1 == obj2);
    }
}
```

Output:

```text
true
```

Both variables point to the **same object**.

```text
obj1 ─────┐
          ↓
       Singleton
          ↑
obj2 ─────┘
```

---

# 5. Why Is the Constructor Private?

Consider a normal class:

```java
class Database {

    public Database() {
    }
}
```

We can create:

```java
Database db1 = new Database();
Database db2 = new Database();
Database db3 = new Database();
```

So there are multiple objects.

But Singleton wants only one object.

Therefore:

```java
private Database() {
}
```

Now this is not allowed:

```java
Database db = new Database(); // Compile error
```

Instead, we use:

```java
Database db = Database.getInstance();
```

---

# 6. Lazy Initialization

The previous implementation uses **lazy initialization**.

```java
private static Singleton instance;

public static Singleton getInstance() {

    if (instance == null) {
        instance = new Singleton();
    }

    return instance;
}
```

The object is created **only when it is needed for the first time**.

```text
Application starts
       ↓
instance = null
       ↓
getInstance()
       ↓
Create object
       ↓
Store object
       ↓
Return same object
```

### Advantage

The object is not created unnecessarily.

---

# 7. Problem with the Basic Singleton — Multithreading

The basic implementation is **not thread-safe**.

Suppose two threads call:

```java
Singleton.getInstance();
```

at almost the same time.

Both might see:

```text
instance == null
```

Then:

```text
Thread 1 → creates Object A
Thread 2 → creates Object B
```

Now we have two objects.

```text
Thread 1 ──→ Object A

Thread 2 ──→ Object B
```

That violates the Singleton requirement.

---

# 8. Thread-Safe Singleton — Synchronized Method

One simple solution is:

```java
class Singleton {

    private static Singleton instance;

    private Singleton() {
    }

    public static synchronized Singleton getInstance() {

        if (instance == null) {
            instance = new Singleton();
        }

        return instance;
    }
}
```

The `synchronized` keyword ensures that only one thread can execute `getInstance()` at a time.

### Advantage

Thread-safe and easy to understand.

### Disadvantage

Every call to `getInstance()` requires synchronization, even after the object has already been created.

---

# 9. Double-Checked Locking

A more optimized approach is **Double-Checked Locking**.

```java
class Singleton {

    private static volatile Singleton instance;

    private Singleton() {
    }

    public static Singleton getInstance() {

        if (instance == null) {

            synchronized (Singleton.class) {

                if (instance == null) {
                    instance = new Singleton();
                }
            }
        }

        return instance;
    }
}
```

There are two checks:

```java
if (instance == null) {       // First check

    synchronized (...) {

        if (instance == null) { // Second check
            instance = new Singleton();
        }
    }
}
```

### Why two checks?

The first check avoids synchronization after the object has already been created.

The second check prevents two threads from creating two objects while competing for the lock.

---

# 10. Why `volatile`?

This is an important interview question.

```java
private static volatile Singleton instance;
```

`volatile` ensures proper **visibility and ordering guarantees** for the shared instance between threads and prevents unsafe publication caused by instruction reordering.

For a standard interview answer:

> **`volatile` is used with double-checked locking to ensure that other threads see a correctly initialized Singleton instance.**

---

# 11. Eager Initialization

Another approach is to create the object when the class is loaded.

```java
class Singleton {

    private static final Singleton INSTANCE =
            new Singleton();

    private Singleton() {
    }

    public static Singleton getInstance() {
        return INSTANCE;
    }
}
```

Usage:

```java
Singleton obj1 = Singleton.getInstance();
Singleton obj2 = Singleton.getInstance();

System.out.println(obj1 == obj2);
```

Output:

```text
true
```

### Advantage

- Simple
- Thread-safe because class initialization is handled safely by the JVM
- No synchronization required in `getInstance()`

### Disadvantage

The object is created even if nobody actually needs it.

---

# 12. Best Simple Java Approach — Holder Pattern

A very clean approach in Java is the **Initialization-on-Demand Holder Idiom**.

```java
class Singleton {

    private Singleton() {
    }

    private static class Holder {

        private static final Singleton INSTANCE =
                new Singleton();
    }

    public static Singleton getInstance() {
        return Holder.INSTANCE;
    }
}
```

Why does this work?

The `Holder` class is not initialized until `getInstance()` accesses it.

The JVM handles class initialization safely.

So we get:

```text
Lazy initialization
        +
Thread safety
        +
No explicit synchronization
```

This is often a very good choice for a traditional Java Singleton.

---

# 13. Enum Singleton

Java also provides a very strong Singleton approach using `enum`.

```java
enum Singleton {

    INSTANCE;

    public void doSomething() {
        System.out.println("Doing something...");
    }
}
```

Usage:

```java
Singleton.INSTANCE.doSomething();
```

There is only one enum constant:

```text
Singleton.INSTANCE
```

### Why is Enum Singleton useful?

Java's enum mechanism provides strong guarantees around:

- Single instance
- Thread safety
- Serialization

It also avoids some common reflection/serialization problems that ordinary Singleton implementations need to handle explicitly.

---

# 14. Real LLD Example — Logger

A common LLD example is a **Logger**.

Suppose our application has:

```text
Service A
Service B
Service C
Service D
```

We want all of them to use the same Logger.

```text
Service A ──┐
Service B ──┤
Service C ──┼──→ Logger
Service D ──┘
```

We don't want:

```text
Service A → Logger 1
Service B → Logger 2
Service C → Logger 3
```

Instead:

```text
Service A ──┐
Service B ──┤
Service C ──┼──→ Same Logger
Service D ──┘
```

Implementation:

```java
class Logger {

    private static Logger instance;

    private Logger() {
    }

    public static synchronized Logger getInstance() {

        if (instance == null) {
            instance = new Logger();
        }

        return instance;
    }

    public void log(String message) {

        System.out.println(
            "[LOG] " + message
        );
    }
}
```

Usage:

```java
class PaymentService {

    private Logger logger =
            Logger.getInstance();

    public void processPayment() {

        logger.log("Payment started");

        // Payment logic...
    }
}
```

Another service:

```java
class OrderService {

    private Logger logger =
            Logger.getInstance();

    public void createOrder() {

        logger.log("Order created");

        // Order logic...
    }
}
```

Both services use the same Logger:

```text
PaymentService ──┐
                 │
OrderService ────┼──→ Logger Instance
                 │
UserService ─────┘
```

---

# 15. LLD Example — Database Connection Manager

Suppose an application needs a centralized database connection manager.

```java
class DatabaseConnectionManager {

    private static DatabaseConnectionManager instance;

    private DatabaseConnectionManager() {
    }

    public static synchronized
    DatabaseConnectionManager getInstance() {

        if (instance == null) {
            instance = new DatabaseConnectionManager();
        }

        return instance;
    }

    public void connect() {
        System.out.println("Connecting to database...");
    }
}
```

Usage:

```java
DatabaseConnectionManager db1 =
        DatabaseConnectionManager.getInstance();

DatabaseConnectionManager db2 =
        DatabaseConnectionManager.getInstance();

System.out.println(db1 == db2);
```

Output:

```text
true
```

---

# 16. Advantages

### 1. Only one instance

Ensures that only one instance of the class is created.

### 2. Controlled access

Object creation is controlled by the class itself.

### 3. Shared resource

Useful when multiple parts of an application need access to the same resource.

### 4. Saves resources

If creating multiple instances is expensive, Singleton can prevent unnecessary instances.

---

# 17. Disadvantages

### 1. Global state

Singleton can behave like global state, which can make dependencies less obvious.

### 2. Difficult to test

If many classes directly call:

```java
Logger.getInstance()
```

unit testing can become harder because the dependency is hidden inside the class.

Dependency Injection is often preferable when you simply need to share a service.

### 3. Multithreading concerns

A poorly implemented Singleton can create multiple instances in a concurrent environment.

### 4. Can become a God Object

If too much functionality is put into a Singleton, it can become difficult to maintain.

---

# 18. When Should You Use Singleton?

Use Singleton when you genuinely need:

- Exactly one instance
- A shared resource
- Centralized coordination
- Controlled object creation

Examples can include:

```text
Configuration Manager
Logger
Application-wide registry
Some resource managers
Some caches
```

But don't make every utility class a Singleton just because it is convenient.

---

# 19. Singleton vs Static Class

This is a common interview question.

### Static Class

You access methods directly:

```java
Logger.log("Hello");
```

There is no normal object instance.

### Singleton

You have one actual object:

```java
Logger logger =
        Logger.getInstance();

logger.log("Hello");
```

So:

```text
Static
   ↓
No instance required

Singleton
   ↓
Exactly one instance
```

A Singleton can also implement interfaces and participate in dependency injection more naturally than a purely static utility class.

---

# 20. Singleton vs Factory

### Singleton

Answers:

> **How many instances should exist?**

```text
Exactly one
```

### Factory

Answers:

> **Which object should I create?**

```text
Circle
Square
Rectangle
```

They can also be combined.

For example:

```text
Singleton Factory
      ↓
One factory object
      ↓
Creates many different objects
```

---

# 21. Interview Questions

### Q1. Why is the constructor private?

> To prevent external classes from directly creating objects using `new`.

### Q2. How do you make Singleton thread-safe?

Possible approaches include:

```text
synchronized method
Double-checked locking
Holder pattern
Enum
```

### Q3. What is lazy initialization?

> Creating the Singleton instance only when it is first requested.

### Q4. What is eager initialization?

> Creating the Singleton instance when the class is initialized, before `getInstance()` is called.

### Q5. Why use `volatile` in double-checked locking?

> To ensure proper visibility and prevent unsafe instruction reordering during publication of the Singleton instance.

### Q6. Can Singleton be broken?

A traditional Singleton can potentially be bypassed through mechanisms such as:

```text
Reflection
Serialization
Cloning
Multiple class loaders
```

These need to be considered if you require a very strict Singleton guarantee.

---

# 22. Interview Answer

If the interviewer asks:

### "What is Singleton Design Pattern?"

You can say:

> **Singleton is a creational design pattern that ensures a class has only one instance and provides a global access point to that instance. We typically achieve this using a private constructor, a static instance, and a static `getInstance()` method. In a multithreaded environment, the implementation must also ensure thread-safe initialization.**

### One-line answer

> **Singleton Pattern = Only one instance of a class + global access to that instance.**

---

# 23. Easy Way to Remember

Think about a **printer manager** in an application.

We don't want every part of the application creating its own manager:

```text
Service A → PrinterManager 1
Service B → PrinterManager 2
Service C → PrinterManager 3
```

Instead:

```text
Service A ──┐
Service B ──┤
Service C ──┼──→ PrinterManager
Service D ──┘
```

There is only **one shared instance**.

### Final memory trick

```text
private constructor
       +
one static instance
       +
getInstance()
       ↓
Singleton
```

> **Singleton = "One class, one object, shared access."**