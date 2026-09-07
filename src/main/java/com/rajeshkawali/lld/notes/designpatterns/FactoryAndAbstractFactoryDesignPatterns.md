# Factory Design Pattern

## 1. Definition

The **Factory Design Pattern** is a **creational design pattern** that provides a way to create objects without exposing the object-creation logic directly to the client.

Instead of the client directly using `new`, it asks a **Factory** to create the required object.

### Simple definition

> **Factory Pattern = Let a separate class decide which object to create.**

---

# 2. Problem Without Factory

Suppose we have different notification types:

- Email
- SMS
- Push Notification

Without Factory:

```java
Notification notification;

if (type.equals("EMAIL")) {
    notification = new EmailNotification();

} else if (type.equals("SMS")) {
    notification = new SMSNotification();

} else if (type.equals("PUSH")) {
    notification = new PushNotification();
}
```

Now the client knows about all the concrete classes.

If we add:

```text
WhatsAppNotification
SlackNotification
```

we need to modify the existing code.

This can become difficult to maintain.

---

# 3. Solution — Factory Pattern

We create a common interface:

```java
interface Notification {
    void send(String message);
}
```

Then create implementations:

```java
class EmailNotification implements Notification {

    @Override
    public void send(String message) {
        System.out.println("Sending Email: " + message);
    }
}
```

```java
class SMSNotification implements Notification {

    @Override
    public void send(String message) {
        System.out.println("Sending SMS: " + message);
    }
}
```

```java
class PushNotification implements Notification {

    @Override
    public void send(String message) {
        System.out.println("Sending Push Notification: " + message);
    }
}
```

Now we create a Factory.

```java
class NotificationFactory {

    public static Notification createNotification(String type) {

        if (type.equalsIgnoreCase("EMAIL")) {
            return new EmailNotification();

        } else if (type.equalsIgnoreCase("SMS")) {
            return new SMSNotification();

        } else if (type.equalsIgnoreCase("PUSH")) {
            return new PushNotification();
        }

        throw new IllegalArgumentException(
            "Unknown notification type"
        );
    }
}
```

The client now does:

```java
Notification notification =
        NotificationFactory.createNotification("EMAIL");

notification.send("Hello!");
```

Output:

```text
Sending Email: Hello!
```

The client doesn't need to write:

```java
new EmailNotification();
```

The Factory handles object creation.

---

# 4. Factory Structure

```text
                 Notification
                      ↑
          -------------------------
          |           |           |
        Email        SMS         Push
          ↑           ↑           ↑
          -------- Factory --------
                    ↑
                  Client
```

The important relationship is:

```text
Client
   |
   ↓
Factory
   |
   ↓
Concrete Object
```

---

# 5. Why Use Factory?

Suppose tomorrow we add:

```java
class WhatsAppNotification implements Notification {
    ...
}
```

The client still doesn't need to know how it is created.

It can simply do:

```java
Notification notification =
    NotificationFactory.createNotification("WHATSAPP");
```

The creation logic is centralized.

---

# 6. Real-Life Example

Imagine ordering food from an application.

You say:

```text
"I want Pizza"
```

You don't care about:

- Which kitchen creates it
- Which ingredients are used
- How the pizza object is constructed

The system decides what object to create.

Similarly:

```text
Client
  |
  | "I need a Pizza"
  ↓
FoodFactory
  |
  ↓
Pizza
```

The Factory hides the object-creation details.

---

# 7. Another LLD Example — Vehicle Factory

Suppose our system supports:

```text
Car
Bike
Truck
```

Common interface:

```java
interface Vehicle {

    void drive();
}
```

Implementations:

```java
class Car implements Vehicle {

    public void drive() {
        System.out.println("Driving Car");
    }
}
```

```java
class Bike implements Vehicle {

    public void drive() {
        System.out.println("Riding Bike");
    }
```

```java
class Truck implements Vehicle {

    public void drive() {
        System.out.println("Driving Truck");
    }
}
```

Factory:

```java
class VehicleFactory {

    public static Vehicle createVehicle(String type) {

        switch (type.toUpperCase()) {

            case "CAR":
                return new Car();

            case "BIKE":
                return new Bike();

            case "TRUCK":
                return new Truck();

            default:
                throw new IllegalArgumentException(
                    "Unknown vehicle type"
                );
        }
    }
}
```

Client:

```java
public class Main {

    public static void main(String[] args) {

        Vehicle vehicle =
            VehicleFactory.createVehicle("CAR");

        vehicle.drive();
    }
}
```

Output:

```text
Driving Car
```

---

# 8. Key Idea of Factory

The client knows:

```java
Vehicle vehicle
```

but doesn't need to know:

```java
new Car()
new Bike()
new Truck()
```

The Factory knows how to create them.

So:

> **Factory separates object creation from object usage.**

---

# 9. Advantages of Factory

### 1. Hides object creation

The client doesn't need to know how an object is created.

### 2. Reduces coupling

Client depends on the interface:

```java
Vehicle
```

rather than:

```java
Car
Bike
Truck
```

### 3. Centralized creation logic

Object creation happens in one place.

### 4. Easy to extend

We can add new implementations.

### 5. Cleaner client code

Instead of:

```java
if (...)
    new Car();
else if (...)
    new Bike();
```

we use:

```java
VehicleFactory.createVehicle(type);
```

---

# 10. Disadvantages of Factory

### 1. Factory can become large

If there are many object types:

```java
if (...)
else if (...)
else if (...)
else if (...)
```

the Factory itself can become difficult to maintain.

### 2. Adding a new product may require modifying the Factory

In a simple Factory implementation, adding a new type means changing the Factory.

This is one reason other Factory variants are useful.

---

# 11. Important Terminology

In Factory Pattern, you will commonly see:

### Product

The common interface.

```java
interface Vehicle
```

### Concrete Product

Actual implementations.

```text
Car
Bike
Truck
```

### Factory

Responsible for creating the appropriate product.

```text
VehicleFactory
```

### Client

Uses the product.

```text
Main / VehicleService
```

---

# Abstract Factory Design Pattern

Now let's move to **Abstract Factory**.

This is slightly more advanced.

---

# 12. Definition

The **Abstract Factory Design Pattern** is a creational pattern that provides an interface for creating **families of related objects** without specifying their concrete classes.

### Simple definition

> **Abstract Factory = A factory that creates multiple related objects that are designed to work together.**

This is the most important difference from Factory.

---

# 13. Factory vs Abstract Factory

Suppose we have a UI application.

We want to support two themes:

```text
Windows Theme
Mac Theme
```

Each theme has multiple UI components:

```text
Button
Checkbox
Textbox
```

For Windows:

```text
WindowsButton
WindowsCheckbox
WindowsTextbox
```

For Mac:

```text
MacButton
MacCheckbox
MacTextbox
```

Now we don't just need one object.

We need a **family of related objects**.

That's where Abstract Factory is useful.

---

# 14. Abstract Factory Structure

```text
                    GUIFactory
                       |
              -------------------
              |                 |
       WindowsFactory        MacFactory
              |                 |
       ---------------     ---------------
       |      |      |     |      |      |
    Button Checkbox Text  Button Checkbox Text
```

The factory creates a complete family of related products.

---

# 15. Step-by-Step Implementation

## Step 1 — Create Product Interfaces

### Button

```java
interface Button {
    void paint();
}
```

### Checkbox

```java
interface Checkbox {
    void paint();
}
```

These are our abstract products.

---

# 16. Step 2 — Create Windows Products

```java
class WindowsButton implements Button {

    @Override
    public void paint() {
        System.out.println("Windows Button");
    }
}
```

```java
class WindowsCheckbox implements Checkbox {

    @Override
    public void paint() {
        System.out.println("Windows Checkbox");
    }
}
```

---

# 17. Step 3 — Create Mac Products

```java
class MacButton implements Button {

    @Override
    public void paint() {
        System.out.println("Mac Button");
    }
}
```

```java
class MacCheckbox implements Checkbox {

    @Override
    public void paint() {
        System.out.println("Mac Checkbox");
    }
}
```

---

# 18. Step 4 — Create Abstract Factory

```java
interface GUIFactory {

    Button createButton();

    Checkbox createCheckbox();
}
```

This factory knows how to create a **family of products**.

---

# 19. Step 5 — Windows Factory

```java
class WindowsFactory implements GUIFactory {

    @Override
    public Button createButton() {
        return new WindowsButton();
    }

    @Override
    public Checkbox createCheckbox() {
        return new WindowsCheckbox();
    }
}
```

---

# 20. Step 6 — Mac Factory

```java
class MacFactory implements GUIFactory {

    @Override
    public Button createButton() {
        return new MacButton();
    }

    @Override
    public Checkbox createCheckbox() {
        return new MacCheckbox();
    }
}
```

---

# 21. Step 7 — Client

The client doesn't care whether it's Windows or Mac.

```java
class Application {

    private Button button;
    private Checkbox checkbox;

    public Application(GUIFactory factory) {

        button = factory.createButton();
        checkbox = factory.createCheckbox();
    }

    public void render() {

        button.paint();
        checkbox.paint();
    }
}
```

---

# 22. Main

```java
public class Main {

    public static void main(String[] args) {

        GUIFactory factory =
            new WindowsFactory();

        Application app =
            new Application(factory);

        app.render();
    }
}
```

Output:

```text
Windows Button
Windows Checkbox
```

If we change:

```java
GUIFactory factory =
    new MacFactory();
```

Output becomes:

```text
Mac Button
Mac Checkbox
```

Notice something important:

**The Application class did not change.**

Only the factory changed.

---

# 23. Why Is This Useful?

Imagine your application supports:

```text
Windows
Mac
Linux
```

And each operating system has:

```text
Button
Checkbox
Textbox
Menu
ScrollBar
```

Without Abstract Factory, the client could become full of conditions:

```java
if (os.equals("WINDOWS")) {
    new WindowsButton();
    new WindowsCheckbox();
    new WindowsTextbox();
}
else if (os.equals("MAC")) {
    new MacButton();
    new MacCheckbox();
    new MacTextbox();
}
```

This becomes messy.

With Abstract Factory:

```java
GUIFactory factory;

if (os.equals("WINDOWS")) {
    factory = new WindowsFactory();
} else {
    factory = new MacFactory();
}
```

Then:

```java
Application app =
    new Application(factory);
```

The application simply asks:

```java
factory.createButton();
factory.createCheckbox();
```

---

# 24. The Most Important Concept — Family of Objects

This is the key to understanding Abstract Factory.

### Factory

Creates **one type of product**.

```text
VehicleFactory
       |
       +-- Car
       +-- Bike
       +-- Truck
```

### Abstract Factory

Creates **multiple related products**.

```text
WindowsFactory
       |
       +-- WindowsButton
       +-- WindowsCheckbox
       +-- WindowsTextbox
```

and:

```text
MacFactory
       |
       +-- MacButton
       +-- MacCheckbox
       +-- MacTextbox
```

The products belonging to the same factory are designed to work together.

---

# 25. Factory vs Abstract Factory

| Factory | Abstract Factory |
|---|---|
| Creates one product/type | Creates a family of related products |
| Usually one creation method | Multiple creation methods |
| Example: VehicleFactory | Example: GUIFactory |
| Car/Bike/Truck | Button/Checkbox/Textbox |
| Simpler | More complex |
| Focuses on one product hierarchy | Focuses on multiple related product hierarchies |

### Easy memory trick

> **Factory → One product**

> **Abstract Factory → Family of products**

---

# 26. Real-World Example

Think about a **Furniture Factory**.

Suppose we support:

```text
Modern Furniture
Victorian Furniture
```

Each furniture style has:

```text
Chair
Sofa
Table
```

### Factory 1

```text
ModernFurnitureFactory
       |
       +-- ModernChair
       +-- ModernSofa
       +-- ModernTable
```

### Factory 2

```text
VictorianFurnitureFactory
       |
       +-- VictorianChair
       +-- VictorianSofa
       +-- VictorianTable
```

This is a perfect Abstract Factory example.

Why?

Because each factory creates a **family of related furniture products**.

---

# 27. Abstract Factory LLD Example — Database

Suppose an application supports:

```text
MySQL
PostgreSQL
```

Each database requires:

```text
Connection
Query
Transaction
```

We could have:

```text
DatabaseFactory
       |
       |-------------------------
       |                        |
 MySQLFactory            PostgreSQLFactory
       |                        |
   Connection                Connection
   Query                     Query
   Transaction               Transaction
```

This ensures that all objects belong to the same database family.

For example:

```text
MySQLFactory
   ↓
MySQLConnection
MySQLQuery
MySQLTransaction
```

instead of accidentally mixing:

```text
MySQLConnection
PostgreSQLQuery
```

This concept of keeping related objects consistent is one of the major benefits of Abstract Factory.

---

# 28. Factory + Abstract Factory Relationship

You can think of Abstract Factory as a **higher-level factory**.

### Normal Factory

```text
Factory
   ↓
One Product
```

### Abstract Factory

```text
Abstract Factory
   ↓
Product A
Product B
Product C
```

So:

```text
Factory
  → "Give me a Button"

Abstract Factory
  → "Give me the complete Windows UI family"
```

---

# 29. When Should We Use Factory?

Use Factory when:

- You need to create different implementations of the same interface.
- Object creation is complex.
- You want to hide `new` from the client.
- The exact object type depends on input/configuration.
- You want centralized creation logic.

Examples:

```text
Payment
Notification
Vehicle
Document
Logger
Parser
Shape
```

---

# 30. When Should We Use Abstract Factory?

Use Abstract Factory when:

- You have multiple **families of related objects**.
- Objects in the same family should work together.
- The client should not depend on concrete implementations.
- You need to switch between complete product families.

Examples:

```text
Windows UI / Mac UI

MySQL / PostgreSQL database components

AWS / Azure cloud components

Modern / Victorian furniture

Regular / Premium product families
```

---

# 31. Factory Pattern Interview Answer

If the interviewer asks:

> **What is Factory Pattern?**

You can say:

> **Factory is a creational design pattern that encapsulates object creation and provides a common way to create different implementations of a product without exposing the creation logic to the client.**

Example:

> In a notification system, `NotificationFactory` can create `EmailNotification`, `SMSNotification`, or `PushNotification` based on the requested type.

---

# 32. Abstract Factory Interview Answer

If the interviewer asks:

> **What is Abstract Factory Pattern?**

You can say:

> **Abstract Factory is a creational design pattern that provides an interface for creating families of related objects without exposing their concrete implementations.**

Example:

> In a cross-platform UI system, `WindowsFactory` creates `WindowsButton` and `WindowsCheckbox`, while `MacFactory` creates `MacButton` and `MacCheckbox`. This ensures that related UI components belong to the same family.

---

# 33. Factory vs Abstract Factory — Interview Shortcut

If the interviewer asks:

> "What's the difference?"

Say:

> **Factory creates a single type of product, whereas Abstract Factory creates a family of related products.**

For example:

```text
Factory:

VehicleFactory
     ↓
    Car


Abstract Factory:

GUIFactory
     ↓
--------------------------
|                        |
WindowsFactory       MacFactory
     ↓                   ↓
WindowsButton        MacButton
WindowsCheckbox      MacCheckbox
```

---

# 34. Factory vs Strategy

Since Strategy is another pattern you just learned, this distinction is important.

### Factory

Answers:

> **Which object should I create?**

```java
PaymentStrategy strategy =
    PaymentFactory.create("UPI");
```

### Strategy

Answers:

> **How should I perform the operation?**

```java
strategy.pay(1000);
```

They can be used together:

```text
                Factory
                   |
                   ↓
            Creates Strategy
                   |
                   ↓
                Strategy
                   |
                   ↓
            Performs behavior
```

For example:

```java
PaymentStrategy strategy =
    PaymentFactory.create("UPI");

strategy.pay(1000);
```

Factory creates the strategy; Strategy performs the behavior.

---

# 35. Simple Mental Model

Remember these three patterns like this:

### Singleton

```text
"Only ONE object."
```

### Factory

```text
"Which object should I create?"
```

### Abstract Factory

```text
"Which FAMILY of related objects should I create?"
```

### Strategy

```text
"Which way should I perform this operation?"
```

---

# 36. Final Cheat Sheet

```text
Factory
   ↓
Creates one type of product
   ↓
Example: Car / Bike / Truck


Abstract Factory
   ↓
Creates family of related products
   ↓
Example:
Windows → Button + Checkbox + Textbox
Mac     → Button + Checkbox + Textbox


Strategy
   ↓
Chooses an algorithm/behavior
   ↓
Example:
Payment → UPI / Card / PayPal


Singleton
   ↓
Only one instance
   ↓
Example:
Logger / Configuration
```

### One-line memory trick

> **Factory = One product**

> **Abstract Factory = Family of products**

> **Strategy = Different ways to do the same thing**

> **Singleton = Only one instance**

These four are particularly useful to understand together because they solve **different problems** even though they can appear together in an LLD design.