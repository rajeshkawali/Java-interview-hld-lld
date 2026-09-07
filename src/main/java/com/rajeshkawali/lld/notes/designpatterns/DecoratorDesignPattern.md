# Decorator Design Pattern

## 1. Definition

The **Decorator Design Pattern** is a **structural design pattern** that allows us to **dynamically add new functionality or behavior to an existing object without modifying its original class**.

### In simple words

> **Decorator Pattern = Wrap an object with another object to add extra behavior.**

Instead of changing the original class or creating many subclasses, we can add functionality by **wrapping objects at runtime**.

---

# 2. Real-Life Example — Coffee

Imagine we have a basic coffee.

```text
Simple Coffee
    ↓
Add Milk
    ↓
Add Sugar
    ↓
Add Whipped Cream
```

We don't want to create classes like:

```text
CoffeeWithMilk
CoffeeWithSugar
CoffeeWithMilkAndSugar
CoffeeWithMilkSugarAndCream
CoffeeWithMilkAndCream
...
```

There can be a huge number of combinations.

Instead, we use decorators:

```text
SimpleCoffee
     ↓
MilkDecorator
     ↓
SugarDecorator
     ↓
CreamDecorator
```

Each decorator adds one additional feature.

---

# 3. Problem Without Decorator

Suppose we have:

```java
class Coffee {

    public double getCost() {
        return 50;
    }

    public String getDescription() {
        return "Simple Coffee";
    }
}
```

Now we want:

```text
Coffee
Coffee + Milk
Coffee + Sugar
Coffee + Milk + Sugar
Coffee + Milk + Sugar + Cream
```

One approach is inheritance:

```text
Coffee
 ├── CoffeeWithMilk
 ├── CoffeeWithSugar
 ├── CoffeeWithMilkAndSugar
 ├── CoffeeWithMilkAndCream
 └── ...
```

As combinations increase, the number of classes can become difficult to manage.

This is sometimes called **class explosion**.

---

# 4. Decorator Solution

We create a common interface:

```java
interface Coffee {

    double getCost();

    String getDescription();
}
```

Both the original coffee and decorators implement this interface.

```text
                 Coffee
                   ↑
          ┌────────┴────────┐
          │                 │
   SimpleCoffee       CoffeeDecorator
                              ↑
                     ┌────────┴────────┐
                     │                 │
               MilkDecorator    SugarDecorator
```

The decorator also contains a reference to a `Coffee`.

This is the important part:

```java
class CoffeeDecorator implements Coffee {

    protected Coffee coffee;
}
```

So the decorator **wraps** another coffee object.

---

# 5. Step-by-Step Java Example

## Step 1: Create the common interface

```java
interface Coffee {

    double getCost();

    String getDescription();
}
```

This is the common contract.

---

## Step 2: Create the basic object

```java
class SimpleCoffee implements Coffee {

    @Override
    public double getCost() {
        return 50;
    }

    @Override
    public String getDescription() {
        return "Simple Coffee";
    }
}
```

Our basic coffee costs ₹50.

---

# 6. Step 3: Create the Base Decorator

```java
abstract class CoffeeDecorator implements Coffee {

    protected Coffee coffee;

    public CoffeeDecorator(Coffee coffee) {
        this.coffee = coffee;
    }
}
```

The decorator stores a reference to another `Coffee`.

This allows us to wrap objects.

---

# 7. Step 4: Create Concrete Decorators

### Milk Decorator

```java
class MilkDecorator extends CoffeeDecorator {

    public MilkDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public double getCost() {
        return coffee.getCost() + 10;
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Milk";
    }
}
```

Milk adds ₹10.

---

### Sugar Decorator

```java
class SugarDecorator extends CoffeeDecorator {

    public SugarDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public double getCost() {
        return coffee.getCost() + 5;
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Sugar";
    }
}
```

Sugar adds ₹5.

---

# 8. Creating the Object

Now we can dynamically add features.

```java
Coffee coffee = new SimpleCoffee();

coffee = new MilkDecorator(coffee);

coffee = new SugarDecorator(coffee);
```

Think of it like this:

```text
SimpleCoffee
     ↓
MilkDecorator
     ↓
SugarDecorator
```

The final object is effectively:

```text
Sugar
  ↓
Milk
  ↓
Coffee
```

Now:

```java
System.out.println(coffee.getDescription());
System.out.println(coffee.getCost());
```

Output:

```text
Simple Coffee, Milk, Sugar
65.0
```

---

# 9. What Actually Happens?

This line:

```java
Coffee coffee = new SimpleCoffee();
```

gives:

```text
SimpleCoffee
Cost = 50
```

Then:

```java
coffee = new MilkDecorator(coffee);
```

gives:

```text
MilkDecorator
     ↓
SimpleCoffee
```

Cost:

```text
50 + 10 = 60
```

Then:

```java
coffee = new SugarDecorator(coffee);
```

gives:

```text
SugarDecorator
      ↓
MilkDecorator
      ↓
SimpleCoffee
```

Cost:

```text
50 + 10 + 5 = 65
```

So the decorators **delegate to the wrapped object and add their own behavior**.

---

# 10. Complete Example

```java
interface Coffee {

    double getCost();

    String getDescription();
}


class SimpleCoffee implements Coffee {

    @Override
    public double getCost() {
        return 50;
    }

    @Override
    public String getDescription() {
        return "Simple Coffee";
    }
}


abstract class CoffeeDecorator implements Coffee {

    protected Coffee coffee;

    public CoffeeDecorator(Coffee coffee) {
        this.coffee = coffee;
    }
}


class MilkDecorator extends CoffeeDecorator {

    public MilkDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public double getCost() {
        return coffee.getCost() + 10;
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Milk";
    }
}


class SugarDecorator extends CoffeeDecorator {

    public SugarDecorator(Coffee coffee) {
        super(coffee);
    }

    @Override
    public double getCost() {
        return coffee.getCost() + 5;
    }

    @Override
    public String getDescription() {
        return coffee.getDescription() + ", Sugar";
    }
}


public class Main {

    public static void main(String[] args) {

        Coffee coffee = new SimpleCoffee();

        coffee = new MilkDecorator(coffee);

        coffee = new SugarDecorator(coffee);

        System.out.println(
            coffee.getDescription()
        );

        System.out.println(
            coffee.getCost()
        );
    }
}
```

Output:

```text
Simple Coffee, Milk, Sugar
65.0
```

---

# 11. The Most Important Concept — Composition

A common confusion is:

> "Does Decorator use inheritance or composition?"

The answer is:

**It uses both, but composition is the key idea.**

The decorator implements the same interface:

```java
class MilkDecorator implements Coffee
```

That's inheritance of the interface/contract.

But it also contains:

```java
private Coffee coffee;
```

That's **composition**.

The composition is what allows decorators to wrap one another.

```text
MilkDecorator
      |
      | contains
      ↓
    Coffee
      |
      ↓
SimpleCoffee
```

This is why we can dynamically stack decorators.

---

# 12. Why Not Just Use Inheritance?

Suppose we use inheritance.

```text
Coffee
 ├── CoffeeWithMilk
 ├── CoffeeWithSugar
 └── CoffeeWithMilkAndSugar
```

Now add:

```text
Cream
Chocolate
Caramel
Ice
```

The combinations can grow rapidly.

With Decorator:

```text
Coffee
 ↓
Milk
 ↓
Sugar
 ↓
Cream
 ↓
Chocolate
```

We can combine features dynamically.

This is much more flexible.

---

# 13. Another Real-World Example — Java I/O

Java I/O is a classic example of the Decorator Pattern.

For example:

```java
InputStream input =
    new BufferedInputStream(
        new FileInputStream("file.txt")
    );
```

Think about the structure:

```text
BufferedInputStream
        ↓
FileInputStream
        ↓
File
```

`FileInputStream` provides basic file input.

`BufferedInputStream` wraps it and adds buffering functionality.

We can add another wrapper as well.

The important idea is:

> **Each wrapper implements the same general interface and adds additional behavior.**

---

# 14. LLD Example — Notification System

Suppose we have:

```text
Notification
```

We want to send a basic notification.

```java
interface Notification {

    void send(String message);
}
```

Basic implementation:

```java
class BasicNotification implements Notification {

    @Override
    public void send(String message) {
        System.out.println(
            "Sending notification: " + message
        );
    }
}
```

Now suppose we want additional features:

```text
Basic Notification
       +
Logging
       +
Encryption
       +
Retry
```

Instead of modifying `BasicNotification`, we can create decorators.

```java
class LoggingDecorator implements Notification {

    private Notification notification;

    public LoggingDecorator(Notification notification) {
        this.notification = notification;
    }

    @Override
    public void send(String message) {

        System.out.println("Logging notification");

        notification.send(message);
    }
}
```

Another decorator:

```java
class EncryptionDecorator implements Notification {

    private Notification notification;

    public EncryptionDecorator(Notification notification) {
        this.notification = notification;
    }

    @Override
    public void send(String message) {

        String encryptedMessage =
                "ENCRYPTED(" + message + ")";

        notification.send(encryptedMessage);
    }
}
```

Now:

```java
Notification notification =
        new BasicNotification();

notification =
        new LoggingDecorator(notification);

notification =
        new EncryptionDecorator(notification);

notification.send("Hello");
```

Structure:

```text
EncryptionDecorator
        ↓
LoggingDecorator
        ↓
BasicNotification
```

This is a very useful LLD pattern when functionality needs to be combined dynamically.

---

# 15. Advantages

### 1. Add functionality at runtime

We can dynamically wrap an object with additional behavior.

### 2. Avoids subclass explosion

We don't need a separate class for every combination of features.

### 3. Follows Open/Closed Principle

We can add new decorators without modifying the existing class.

### 4. Flexible

Decorators can be combined in different ways.

For example:

```text
Coffee
 ↓
Milk
 ↓
Sugar
```

or:

```text
Coffee
 ↓
Sugar
 ↓
Milk
```

The client can choose the combination.

---

# 16. Disadvantages

### 1. Many small classes

Every new feature may require a new decorator.

```text
MilkDecorator
SugarDecorator
CreamDecorator
ChocolateDecorator
...
```

### 2. Can become difficult to debug

If many decorators are stacked:

```text
A
 ↓
B
 ↓
C
 ↓
D
 ↓
E
```

it can be difficult to understand where a particular behavior came from.

### 3. Order can matter

For some decorators:

```text
A → B
```

may behave differently from:

```text
B → A
```

---

# 17. Decorator vs Inheritance

This is an important interview question.

### Inheritance

Behavior is added by creating a subclass.

```text
Coffee
   ↓
CoffeeWithMilk
```

The behavior is determined by the class hierarchy.

### Decorator

Behavior is added by wrapping an object.

```text
MilkDecorator
      ↓
    Coffee
```

The behavior can be combined dynamically.

### Easy way to remember

> **Inheritance = "is-a"**

> **Decorator = "wraps-a" / "has-a"**

---

# 18. Decorator vs Facade

Another common interview question.

### Decorator

**Adds functionality.**

```text
Object
  ↓
Decorator
  ↓
Extra Behavior
```

### Facade

**Hides complexity.**

```text
Client
  ↓
Facade
  ↓
Multiple Subsystems
```

Easy memory trick:

> **Decorator → Add**

> **Facade → Simplify**

---

# 19. Decorator vs Adapter

### Decorator

Adds behavior while keeping the same interface.

```text
Coffee
  ↓
MilkDecorator
  ↓
Coffee
```

### Adapter

Converts one interface into another interface.

```text
Client
  ↓
Adapter
  ↓
Existing Class
```

Easy memory trick:

> **Decorator → Add functionality**

> **Adapter → Make interfaces compatible**

---

# 20. When Should You Use Decorator?

Use the Decorator Pattern when:

- You want to add functionality dynamically.
- You want to avoid creating many subclasses.
- You have multiple optional features.
- Features can be combined in different ways.
- You want to follow the Open/Closed Principle.
- You don't want to modify the original class.

Common examples:

```text
Coffee customization
Java I/O streams
Logging
Caching
Encryption
Compression
Authentication
Request processing
Notification systems
```

---

# 21. Interview Answer

If the interviewer asks:

### "What is Decorator Design Pattern?"

You can say:

> **Decorator is a structural design pattern that allows us to dynamically add additional behavior or functionality to an object without modifying its original class. It works by wrapping the object with one or more decorator objects that implement the same interface. This provides more flexibility than inheritance when we have multiple optional features or combinations of behavior.**

### One-line answer

> **Decorator Pattern = Wrap an object to dynamically add extra behavior without changing the original object.**

---

# 22. Easy Way to Remember

Think about **ordering a pizza**:

```text
Basic Pizza
     ↓
+ Cheese
     ↓
+ Mushroom
     ↓
+ Olives
```

Each layer adds something:

```text
OlivesDecorator
       ↓
MushroomDecorator
       ↓
CheeseDecorator
       ↓
BasicPizza
```

So remember:

> **Decorator = Wrap + Add Behavior + Runtime Flexibility**

And the key LLD relationship is:

```text
Decorator
    |
    | HAS-A
    ↓
Component
    |
    | IS-A
    ↓
Same Interface
```