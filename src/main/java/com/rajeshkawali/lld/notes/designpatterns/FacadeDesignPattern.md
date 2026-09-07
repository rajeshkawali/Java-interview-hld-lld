# Facade Design Pattern

## 1. Definition

The **Facade Design Pattern** is a **structural design pattern** that provides a **simple interface to a complex system of classes, libraries, or subsystems**.

In simple words:

> **Facade Pattern = Hide the complexity of multiple classes behind one simple interface.**

The client interacts with the **Facade** instead of directly interacting with many different classes.

---

# 2. Real-Life Example

Think about **booking a flight**.

Internally, many things may happen:

```text
Check Flight Availability
        ↓
Check Seat Availability
        ↓
Make Payment
        ↓
Generate Ticket
        ↓
Send Confirmation
```

Without a Facade, the client has to deal with all these services.

With a Facade:

```text
Client
   |
   v
FlightBookingFacade
   |
   ├── FlightService
   ├── SeatService
   ├── PaymentService
   └── TicketService
```

The client simply calls:

```java
facade.bookFlight();
```

The Facade handles the complex workflow internally.

---

# 3. Problem Without Facade

Suppose we have these classes:

```java
class FlightService {

    public void searchFlight() {
        System.out.println("Searching flight...");
    }
}
```

```java
class SeatService {

    public void reserveSeat() {
        System.out.println("Seat reserved");
    }
}
```

```java
class PaymentService {

    public void makePayment() {
        System.out.println("Payment successful");
    }
}
```

```java
class TicketService {

    public void generateTicket() {
        System.out.println("Ticket generated");
    }
}
```

Now the client needs to know about **all these classes**:

```java
FlightService flightService = new FlightService();
SeatService seatService = new SeatService();
PaymentService paymentService = new PaymentService();
TicketService ticketService = new TicketService();

flightService.searchFlight();
seatService.reserveSeat();
paymentService.makePayment();
ticketService.generateTicket();
```

This creates a lot of dependency between the client and the subsystem classes.

The client needs to know:

- Which classes to create
- Which methods to call
- In what order to call them
- How the overall process works

That's the complexity we want to hide.

---

# 4. Facade Solution

We create one class:

```java
class FlightBookingFacade {

    private FlightService flightService;
    private SeatService seatService;
    private PaymentService paymentService;
    private TicketService ticketService;

    public FlightBookingFacade() {
        flightService = new FlightService();
        seatService = new SeatService();
        paymentService = new PaymentService();
        ticketService = new TicketService();
    }

    public void bookFlight() {

        flightService.searchFlight();

        seatService.reserveSeat();

        paymentService.makePayment();

        ticketService.generateTicket();
    }
}
```

Now the client only needs to know about the Facade:

```java
public class Main {

    public static void main(String[] args) {

        FlightBookingFacade facade =
                new FlightBookingFacade();

        facade.bookFlight();
    }
}
```

That's much simpler.

---

# 5. How It Works

The overall structure is:

```text
                  Client
                    |
                    | bookFlight()
                    ↓
            FlightBookingFacade
                    |
          ┌─────────┼──────────┐
          ↓         ↓          ↓
     FlightService SeatService PaymentService
                              |
                              ↓
                         TicketService
```

The client doesn't need to know how all the individual services work.

It simply says:

```java
facade.bookFlight();
```

The Facade coordinates everything.

---

# 6. Another Simple Example — Computer Startup

Imagine starting a computer.

Internally:

```text
Computer
  |
  ├── CPU
  ├── Memory
  ├── HardDisk
  ├── OperatingSystem
  └── BIOS
```

Starting the computer may require:

```text
Check CPU
   ↓
Load memory
   ↓
Read hard disk
   ↓
Load OS
   ↓
Start system
```

Without Facade:

```java
cpu.start();
memory.load();
hardDisk.read();
os.load();
```

With Facade:

```java
computer.start();
```

The `Computer` class acts as a Facade.

```java
class ComputerFacade {

    private CPU cpu;
    private Memory memory;
    private HardDisk hardDisk;
    private OperatingSystem os;

    public ComputerFacade() {
        cpu = new CPU();
        memory = new Memory();
        hardDisk = new HardDisk();
        os = new OperatingSystem();
    }

    public void start() {

        cpu.start();
        memory.load();
        hardDisk.read();
        os.load();

        System.out.println("Computer started");
    }
}
```

Client:

```java
ComputerFacade computer = new ComputerFacade();

computer.start();
```

The client doesn't need to understand the internal startup process.

---

# 7. Important Point

A **Facade does not replace the subsystem classes**.

The subsystem classes still exist:

```text
FlightService
SeatService
PaymentService
TicketService
```

The Facade simply provides a **simplified entry point** to them.

```text
             Client
                |
                ↓
             Facade
                |
       ┌────────┼────────┐
       ↓        ↓        ↓
    Service  Service  Service
```

---

# 8. Advantages

### 1. Reduces complexity

The client doesn't need to interact with many classes.

### 2. Reduces coupling

The client depends mainly on the Facade instead of many subsystem classes.

### 3. Easier to use

The client gets a simple API.

Instead of:

```java
serviceA.doSomething();
serviceB.doSomething();
serviceC.doSomething();
```

we can have:

```java
facade.doSomething();
```

### 4. Better maintainability

If the internal workflow changes, we can modify the Facade without requiring changes in the client.

For example:

```text
Old flow:

A → B → C

New flow:

A → B → D → C
```

The client can still call:

```java
facade.execute();
```

---

# 9. Disadvantages

### 1. Facade can become too large

If we keep adding every possible operation to one Facade, it can become a **God Class**.

### 2. May hide too much

Sometimes clients actually need direct access to specific subsystem functionality.

### 3. Additional abstraction

We introduce another class, which may be unnecessary for a very simple system.

---

# 10. Facade vs Adapter

This is a common interview question.

### Facade

Facade provides a **simplified interface to a complex subsystem**.

```text
Complex System
      ↓
   Facade
      ↓
  Simple API
```

Example:

```java
facade.bookFlight();
```

### Adapter

Adapter makes an **incompatible interface compatible** with what the client expects.

```text
Client
  ↓
Adapter
  ↓
Existing/Third-party Class
```

### Easy way to remember

> **Facade simplifies.**

> **Adapter converts.**

---

# 11. Facade vs Decorator

### Facade

Facade **hides complexity**.

```text
Client
  ↓
Facade
  ↓
Multiple Subsystems
```

### Decorator

Decorator **adds functionality/behavior** to an existing object.

```text
Object
  ↓
Decorator
  ↓
Extra Behavior
```

### Easy way to remember

> **Facade = Simplify**

> **Decorator = Add behavior**

---

# 12. LLD Example — Food Ordering System

Suppose we are designing a food-ordering system.

We have:

```text
RestaurantService
PaymentService
InventoryService
DeliveryService
NotificationService
```

Without Facade:

```java
restaurantService.placeOrder();

inventoryService.updateInventory();

paymentService.processPayment();

deliveryService.assignDelivery();

notificationService.sendNotification();
```

The client needs to understand the entire workflow.

Instead, create:

```java
class OrderFacade {

    private RestaurantService restaurantService;
    private InventoryService inventoryService;
    private PaymentService paymentService;
    private DeliveryService deliveryService;
    private NotificationService notificationService;

    public OrderFacade() {
        restaurantService = new RestaurantService();
        inventoryService = new InventoryService();
        paymentService = new PaymentService();
        deliveryService = new DeliveryService();
        notificationService = new NotificationService();
    }

    public void placeOrder() {

        restaurantService.placeOrder();

        inventoryService.updateInventory();

        paymentService.processPayment();

        deliveryService.assignDelivery();

        notificationService.sendNotification();
    }
}
```

Client:

```java
OrderFacade orderFacade = new OrderFacade();

orderFacade.placeOrder();
```

Now:

```text
                  Client
                    |
                    ↓
               OrderFacade
                    |
      ┌─────────────┼──────────────┐
      ↓             ↓              ↓
Restaurant      Inventory       Payment
Service          Service         Service
      ↓             ↓              ↓
      └─────────────┼──────────────┘
                    ↓
               Delivery
                 Service
                    ↓
              Notification
                 Service
```

The Facade coordinates the complete operation.

---

# 13. When Should We Use Facade?

Use the Facade Pattern when:

- You have a **complex subsystem**.
- The client needs to interact with many classes.
- You want to provide a **simple API**.
- You want to reduce coupling between clients and subsystem classes.
- You want to hide implementation details.
- You have a common workflow involving multiple services.

---

# 14. Interview Answer

If the interviewer asks:

### "What is Facade Design Pattern?"

You can say:

> **Facade is a structural design pattern that provides a simplified interface to a complex subsystem. It hides the internal complexity by providing a single entry point through which the client can perform an operation. The subsystem classes still exist, but the client doesn't need to know how they work or how they interact with each other.**

### One-line version

> **Facade Pattern hides the complexity of multiple classes behind a simple interface.**

---

# 15. Easy Way to Remember

Think about a **hotel receptionist**.

You want to stay at a hotel.

You don't personally contact:

```text
Room Service
Housekeeping
Billing
Restaurant
Laundry
Maintenance
```

Instead:

```text
             You
              |
              ↓
        Hotel Reception
              |
      ┌───────┼────────┐
      ↓       ↓        ↓
    Room    Billing  Restaurant
   Service  Service   Service
```

You simply tell the receptionist:

> "I want to check in."

The receptionist coordinates the complex operations for you.

**That's the Facade Pattern.**

### Final memory trick

```text
Facade
   ↓
Simple interface
   ↓
Hides complex subsystem
   ↓
Reduces client complexity
```

> **Facade = One simple door to a complicated system.**