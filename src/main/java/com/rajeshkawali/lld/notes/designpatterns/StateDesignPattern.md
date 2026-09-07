# State Design Pattern

## 1. Definition

The **State Design Pattern** is a **behavioral design pattern** that allows an object to change its behavior when its **internal state changes**.

Instead of putting many `if-else` or `switch` statements inside one class, we create a separate class for each state.

### Simple definition

> **State Pattern = Change the object's behavior based on its current state.**

---

# 2. Real-Life Example

Think about an **ATM machine**.

An ATM can be in different states:

```text
No Card
   ↓
Card Inserted
   ↓
PIN Verified
   ↓
Transaction
   ↓
Card Ejected
```

The behavior of the ATM depends on its current state.

For example:

### No Card

```text
Insert card → Allowed
Withdraw money → Not allowed
Enter PIN → Not allowed
```

### Card Inserted

```text
Insert card → Not allowed
Enter PIN → Allowed
Withdraw money → Not allowed
```

### PIN Verified

```text
Withdraw money → Allowed
Check balance → Allowed
```

The same operation can behave differently depending on the current state.

That's exactly what the **State Pattern** solves.

---

# 3. Problem Without State Pattern

Suppose we implement an order system.

An order can have:

```text
CREATED
PAID
SHIPPED
DELIVERED
CANCELLED
```

Without State Pattern, we might write:

```java
class Order {

    private String status;

    public void cancel() {

        if (status.equals("CREATED")) {
            // cancel order

        } else if (status.equals("PAID")) {
            // cancel order

        } else if (status.equals("SHIPPED")) {
            // cannot cancel

        } else if (status.equals("DELIVERED")) {
            // cannot cancel
        }
    }
}
```

Now imagine we have:

```text
pay()
cancel()
ship()
deliver()
refund()
```

Every method may contain:

```text
if CREATED
else if PAID
else if SHIPPED
else if DELIVERED
else if CANCELLED
```

The class becomes very complicated.

---

# 4. Solution Using State Pattern

Instead of putting all state-specific logic inside `Order`, we create separate classes:

```text
OrderState
    |
    |-------------------------------
    |          |        |          |
 Created     Paid    Shipped   Delivered
```

Each state knows what operations are allowed in that state.

---

# 5. Structure of State Pattern

There are usually three main components.

### 1. State

Defines operations that can behave differently depending on the state.

```java
interface OrderState {
    void pay();
    void ship();
    void deliver();
    void cancel();
}
```

### 2. Concrete States

Implement behavior for each state.

```text
CreatedState
PaidState
ShippedState
DeliveredState
CancelledState
```

### 3. Context

The main object whose behavior changes.

```text
Order
```

The `Order` contains the current `OrderState`.

```text
Order
  |
  | has-a
  ↓
OrderState
  |
  +-- CreatedState
  +-- PaidState
  +-- ShippedState
  +-- DeliveredState
```

---

# 6. Java Example — Order System

Let's build it step by step.

## Step 1 — State Interface

```java
interface OrderState {

    void pay(Order order);

    void ship(Order order);

    void deliver(Order order);

    void cancel(Order order);
}
```

This interface defines the operations that can change depending on the current state.

---

# 7. Created State

Initially, the order is created.

```java
class CreatedState implements OrderState {

    @Override
    public void pay(Order order) {

        System.out.println(
            "Payment successful"
        );

        order.setState(new PaidState());
    }

    @Override
    public void ship(Order order) {

        System.out.println(
            "Cannot ship. Payment required."
        );
    }

    @Override
    public void deliver(Order order) {

        System.out.println(
            "Cannot deliver. Order not shipped."
        );
    }

    @Override
    public void cancel(Order order) {

        System.out.println(
            "Order cancelled"
        );

        order.setState(new CancelledState());
    }
}
```

Notice something important:

After payment:

```java
order.setState(new PaidState());
```

The order changes its state.

---

# 8. Paid State

```java
class PaidState implements OrderState {

    @Override
    public void pay(Order order) {

        System.out.println(
            "Order is already paid"
        );
    }

    @Override
    public void ship(Order order) {

        System.out.println(
            "Order shipped"
        );

        order.setState(new ShippedState());
    }

    @Override
    public void deliver(Order order) {

        System.out.println(
            "Cannot deliver. Order not shipped."
        );
    }

    @Override
    public void cancel(Order order) {

        System.out.println(
            "Order cancelled and payment refunded"
        );

        order.setState(new CancelledState());
    }
}
```

---

# 9. Shipped State

```java
class ShippedState implements OrderState {

    @Override
    public void pay(Order order) {

        System.out.println(
            "Order is already paid"
        );
    }

    @Override
    public void ship(Order order) {

        System.out.println(
            "Order is already shipped"
        );
    }

    @Override
    public void deliver(Order order) {

        System.out.println(
            "Order delivered"
        );

        order.setState(new DeliveredState());
    }

    @Override
    public void cancel(Order order) {

        System.out.println(
            "Cannot cancel shipped order"
        );
    }
}
```

---

# 10. Delivered State

```java
class DeliveredState implements OrderState {

    @Override
    public void pay(Order order) {

        System.out.println(
            "Order is already paid"
        );
    }

    @Override
    public void ship(Order order) {

        System.out.println(
            "Order is already delivered"
        );
    }

    @Override
    public void deliver(Order order) {

        System.out.println(
            "Order is already delivered"
        );
    }

    @Override
    public void cancel(Order order) {

        System.out.println(
            "Cannot cancel delivered order"
        );
    }
}
```

---

# 11. Cancelled State

```java
class CancelledState implements OrderState {

    @Override
    public void pay(Order order) {

        System.out.println(
            "Cannot pay. Order is cancelled."
        );
    }

    @Override
    public void ship(Order order) {

        System.out.println(
            "Cannot ship. Order is cancelled."
        );
    }

    @Override
    public void deliver(Order order) {

        System.out.println(
            "Cannot deliver. Order is cancelled."
        );
    }

    @Override
    public void cancel(Order order) {

        System.out.println(
            "Order is already cancelled"
        );
    }
}
```

---

# 12. Context — Order

Now we create the `Order` class.

```java
class Order {

    private OrderState state;

    public Order() {
        state = new CreatedState();
    }

    public void setState(OrderState state) {
        this.state = state;
    }

    public void pay() {
        state.pay(this);
    }

    public void ship() {
        state.ship(this);
    }

    public void deliver() {
        state.deliver(this);
    }

    public void cancel() {
        state.cancel(this);
    }
}
```

`Order` is the **Context**.

It doesn't contain all the state-specific logic.

Instead, it delegates the operation to the current state.

---

# 13. Main

```java
public class Main {

    public static void main(String[] args) {

        Order order = new Order();

        order.ship();

        order.pay();

        order.ship();

        order.deliver();

        order.cancel();
    }
}
```

Output:

```text
Cannot ship. Payment required.
Payment successful
Order shipped
Order delivered
Cannot cancel delivered order
```

---

# 14. Understand the Flow

Initially:

```text
Order
  |
  ↓
CreatedState
```

When we call:

```java
order.pay();
```

the current state handles it:

```text
CreatedState
     |
     | pay()
     ↓
PaidState
```

Then:

```java
order.ship();
```

causes:

```text
PaidState
     |
     | ship()
     ↓
ShippedState
```

Then:

```java
order.deliver();
```

causes:

```text
ShippedState
     |
     | deliver()
     ↓
DeliveredState
```

So the state transition is:

```text
Created
   ↓ pay()
Paid
   ↓ ship()
Shipped
   ↓ deliver()
Delivered
```

---

# 15. The Most Important Concept

The key idea is:

> **The object delegates behavior to its current state.**

Instead of:

```java
if (state == CREATED) {
    ...
}
else if (state == PAID) {
    ...
}
else if (state == SHIPPED) {
    ...
}
```

we do:

```java
state.pay(this);
```

The current state decides what should happen.

This is the main reason State Pattern reduces complex conditional logic.

---

# 16. Another Simple Example — Vending Machine

A vending machine can have states:

```text
No Coin
   ↓
Coin Inserted
   ↓
Item Selected
   ↓
Dispensing
```

Behavior changes depending on state.

For example:

### No Coin

```text
Insert Coin → Allowed
Select Item → Not allowed
Dispense → Not allowed
```

### Coin Inserted

```text
Insert Coin → Allowed
Select Item → Allowed
Dispense → Not allowed
```

### Item Selected

```text
Dispense → Allowed
```

Instead of writing:

```java
if (state == NO_COIN) {
    ...
}
else if (state == COIN_INSERTED) {
    ...
}
else if (state == ITEM_SELECTED) {
    ...
}
```

we create:

```text
VendingMachineState
       |
       |-----------------------
       |          |           |
   NoCoin     CoinInserted  ItemSelected
```

This is State Pattern.

---

# 17. Another LLD Example — Traffic Light

A traffic light is another classic example.

States:

```text
RED
 ↓
GREEN
 ↓
YELLOW
 ↓
RED
```

Each state determines the behavior.

```text
TrafficLight
      |
      ↓
TrafficLightState
      |
      |------------------
      |        |        |
     Red     Green    Yellow
```

For example:

```java
interface TrafficLightState {
    void change(TrafficLight light);
}
```

`RedState` changes to `GreenState`.

`GreenState` changes to `YellowState`.

`YellowState` changes to `RedState`.

---

# 18. State Pattern vs Strategy Pattern

This is **very important for interviews** because these patterns look similar.

Both use:

```java
interface
   ↓
Multiple implementations
```

But their purpose is different.

## Strategy

Strategy asks:

> **"Which algorithm/way should I use?"**

Example:

```text
Payment
   |
   +-- UPI
   +-- Credit Card
   +-- PayPal
```

The client chooses the strategy.

---

## State

State asks:

> **"What should I do based on my current state?"**

Example:

```text
Order
   |
   +-- Created
   +-- Paid
   +-- Shipped
   +-- Delivered
```

The object's state changes and that changes its behavior.

---

# 19. Simple Difference

### Strategy

```text
Client
  |
  ↓
Choose Strategy
  |
  +-- UPI
  +-- Card
  +-- PayPal
```

### State

```text
Object
  |
  ↓
Current State
  |
  ↓
Behavior
  |
  ↓
State changes
```

### Memory trick

> **Strategy = I choose how to do something.**

> **State = My behavior changes because my state changed.**

---

# 20. State vs If-Else

### Without State Pattern

```java
if (status.equals("CREATED")) {
    ...
} else if (status.equals("PAID")) {
    ...
} else if (status.equals("SHIPPED")) {
    ...
}
```

As states increase, the code becomes difficult to manage.

### With State Pattern

```java
state.pay(this);
```

The state object contains the relevant behavior.

---

# 21. Advantages

### 1. Removes complex if-else/switch statements

State-specific behavior is moved into separate classes.

### 2. Follows Single Responsibility Principle

Each state class handles behavior related to one state.

### 3. Easy to add new states

For example:

```text
ReturnedState
RefundedState
```

can be added without making the main class huge.

### 4. Makes state transitions explicit

You can clearly see:

```text
Created → Paid → Shipped → Delivered
```

### 5. Better maintainability

Each state has its own logic.

---

# 22. Disadvantages

### 1. More classes

Instead of one class, you may have:

```text
CreatedState
PaidState
ShippedState
DeliveredState
CancelledState
```

### 2. Can be overkill

If there are only two simple states, using State Pattern may make the code unnecessarily complicated.

### 3. State transitions need careful design

You need to make sure invalid transitions are handled correctly.

---

# 23. When Should We Use State Pattern?

Use State Pattern when:

- An object's behavior changes based on its state.
- You have many `if-else`/`switch` statements based on state.
- There are many states.
- State transitions are important.
- Each state has different behavior.
- You want to keep state-specific logic separate.

### Common examples

```text
Order
  Created → Paid → Shipped → Delivered

Vending Machine
  NoCoin → CoinInserted → ItemSelected → Dispensing

ATM
  NoCard → CardInserted → PinVerified → Transaction

Traffic Light
  Red → Green → Yellow

Media Player
  Playing → Paused → Stopped

Document
  Draft → Moderation → Published

Elevator
  Idle → Moving → DoorOpening → DoorClosing
```

---

# 24. State Pattern in LLD

A typical LLD structure looks like:

```text
                  Context
                    |
                    | has-a
                    ↓
              State Interface
                    |
        ---------------------------
        |           |             |
     State A      State B       State C
        |           |             |
        -------- State Transition -
```

The Context:

- Maintains current state.
- Delegates operations to that state.
- Allows state transitions.

The State:

- Defines behavior.
- Can transition the Context to another state.

---

# 25. State Pattern vs Other Patterns

| Pattern | Purpose |
|---|---|
| **State** | Change behavior based on current state |
| **Strategy** | Choose between different algorithms |
| **Command** | Encapsulate a request as an object |
| **Observer** | Notify objects when something changes |
| **Decorator** | Add behavior to an object |
| **Proxy** | Control access to an object |
| **Facade** | Simplify a complex subsystem |

---

# 26. Interview-Friendly Answer

If the interviewer asks:

> **What is State Design Pattern?**

You can answer:

> **State is a behavioral design pattern that allows an object to change its behavior when its internal state changes. Instead of using large if-else or switch statements for different states, we encapsulate state-specific behavior into separate state classes.**

Example:

> In an order-management system, an order can be in Created, Paid, Shipped, or Delivered state. The behavior of operations such as `pay()`, `ship()`, `deliver()`, and `cancel()` depends on the current state. The State Pattern moves this behavior into separate state classes.

---

# 27. Easy Way to Remember

Think about a **traffic light**:

```text
        RED
         |
         ↓
       GREEN
         |
         ↓
       YELLOW
         |
         ↓
        RED
```

The same traffic light behaves differently depending on its current state.

That's State Pattern.

### One-line memory trick

> **State Pattern = "Same object, different behavior depending on its current state."**

Or even simpler:

> **State = Behavior changes when state changes.**

---

# 28. Final Cheat Sheet

```text
State Pattern
     ↓
Behavioral Pattern
     ↓
Object has a current state
     ↓
Behavior depends on state
     ↓
Each state gets its own class
     ↓
State can change
     ↓
Behavior changes automatically
```

### Example

```text
Order
  |
  ↓
CreatedState
  |
  | pay()
  ↓
PaidState
  |
  | ship()
  ↓
ShippedState
  |
  | deliver()
  ↓
DeliveredState
```

### Most important interview difference

```text
Strategy:
"Which way should I do this?"

State:
"How should I behave in my current state?"
```

So, remember:

> **Strategy = interchangeable algorithms.**

> **State = behavior changes with state.**