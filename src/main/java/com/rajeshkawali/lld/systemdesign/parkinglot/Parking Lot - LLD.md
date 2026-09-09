# Parking Lot — Low-Level Design (LLD)

A beginner-friendly, step-by-step Low-Level Design of a Parking Lot system using Java.

---

# Table of Contents

1. What is LLD?
2. How to Approach an LLD Problem
3. Parking Lot Requirements
4. Use Cases
5. Identify Entities
6. Vehicle Design
7. Parking Spot Design
8. Parking Floor Design
9. Parking Lot Design
10. Ticket Design
11. Pricing Design
12. Payment Design
13. Parking Service
14. Class Relationships
15. Complete Class Diagram
16. Complete Java Code
17. Parking Vehicle Flow
18. Exit Vehicle Flow
19. OOP Concepts Used
20. SOLID Principles
21. Design Patterns Used
22. Why Not Use Inheritance Everywhere?
23. Common Beginner Mistakes
24. How to Explain This in an Interview
25. Possible Extensions
26. Final Design Summary

---

# 1. What is LLD?

## LLD = Low-Level Design

Low-Level Design is about designing the internal structure of a software system.

In LLD, we decide:

- What classes do we need?
- What objects do we need?
- What fields should each class contain?
- What methods should each class contain?
- How do classes communicate?
- Which class should be responsible for which operation?
- Where should we use interfaces?
- Where should we use inheritance?
- Which design patterns are useful?
- How can the design be extended later?

For example, in a Parking Lot system, we may have:

```text
ParkingLot
    |
    +---- ParkingFloor
              |
              +---- ParkingSpot
                       |
                       +---- Vehicle
```

We also need:

```text
Ticket
PricingStrategy
PaymentProcessor
ParkingService
```

---

# 2. How to Approach an LLD Problem

As a beginner, do not immediately start writing Java code.

Follow this process:

```text
Requirements
     |
     v
Use Cases
     |
     v
Identify Entities
     |
     v
Identify Responsibilities
     |
     v
Identify Relationships
     |
     v
Identify Changing Behavior
     |
     v
Interfaces / Abstractions
     |
     v
Design Patterns
     |
     v
Class Diagram
     |
     v
Java Code
```

This is one of the most important things to learn for LLD interviews.

---

# 3. Parking Lot Requirements

Let's first define the requirements.

## Functional Requirements

Our Parking Lot should support:

1. Parking lot can have multiple floors.
2. Each floor can have multiple parking spots.
3. Parking spots can be of different types.
4. Vehicles can be of different types.
5. A vehicle can enter the parking lot.
6. System should find an appropriate available parking spot.
7. Vehicle should be parked in the selected spot.
8. A parking ticket should be generated.
9. Vehicle can exit the parking lot.
10. Parking fee should be calculated.
11. User should be able to pay.
12. After payment, parking spot should become available.

---

# 4. Use Cases

Before designing classes, identify what users/system actually do.

## Use Case 1: Park Vehicle

```text
Vehicle enters
      |
      v
Find available parking spot
      |
      v
Park vehicle
      |
      v
Generate ticket
```

---

## Use Case 2: Exit Vehicle

```text
Vehicle wants to exit
      |
      v
Find ticket
      |
      v
Calculate parking fee
      |
      v
Process payment
      |
      v
Remove vehicle from spot
```

---

## Use Case 3: Add Parking Floor

```text
Parking Lot
     |
     v
Add Floor
     |
     v
Add Parking Spots
```

---

# 5. Identify Entities

Now extract important nouns from the requirements.

Potential entities:

```text
ParkingLot
ParkingFloor
ParkingSpot
Vehicle
Ticket
Payment
```

We also have behaviors:

```text
Pricing
Payment Processing
Parking
```

These may become interfaces/classes.

---

# 6. Vehicle Design

A vehicle needs basic information.

For example:

```text
Vehicle
---------
licensePlate
vehicleType
```

We can represent vehicle type using an enum.

## VehicleType

```java
public enum VehicleType {
    BIKE,
    CAR,
    TRUCK
}
```

Why use `enum`?

Because vehicle types are a fixed set.

Instead of:

```java
String vehicleType;
```

we use:

```java
VehicleType vehicleType;
```

This gives compile-time safety.

For example:

```java
VehicleType.CAR
```

is valid.

But:

```java
VehicleType.ABC
```

will not compile.

---

## Vehicle Class

```java
public class Vehicle {

    private String licensePlate;
    private VehicleType vehicleType;

    public Vehicle(String licensePlate, VehicleType vehicleType) {
        this.licensePlate = licensePlate;
        this.vehicleType = vehicleType;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public VehicleType getVehicleType() {
        return vehicleType;
    }
}
```

---

# 7. Parking Spot Design

A parking spot needs:

```text
id
spot type
currently parked vehicle
```

We can use:

```java
public enum SpotType {
    BIKE,
    CAR,
    TRUCK
}
```

---

## ParkingSpot Class

```java
public class ParkingSpot {

    private String id;
    private SpotType spotType;
    private Vehicle vehicle;

    public ParkingSpot(String id, SpotType spotType) {
        this.id = id;
        this.spotType = spotType;
    }

    public boolean isAvailable() {
        return vehicle == null;
    }

    public boolean canFitVehicle(Vehicle vehicle) {

        return switch (vehicle.getVehicleType()) {

            case BIKE -> spotType == SpotType.BIKE;

            case CAR -> spotType == SpotType.CAR;

            case TRUCK -> spotType == SpotType.TRUCK;
        };
    }

    public void parkVehicle(Vehicle vehicle) {

        if (!isAvailable()) {
            throw new IllegalStateException(
                    "Parking spot is already occupied"
            );
        }

        if (!canFitVehicle(vehicle)) {
            throw new IllegalArgumentException(
                    "Vehicle cannot fit in this parking spot"
            );
        }

        this.vehicle = vehicle;
    }

    public void removeVehicle() {
        this.vehicle = null;
    }

    public String getId() {
        return id;
    }

    public SpotType getSpotType() {
        return spotType;
    }

    public Vehicle getVehicle() {
        return vehicle;
    }
}
```

---

# 8. Why Don't We Have `boolean occupied`?

A beginner may write:

```java
private boolean occupied;
private Vehicle vehicle;
```

But this creates duplicate state.

For example:

```text
occupied = false
vehicle = BMW
```

Now our system has inconsistent data.

Instead, we can derive occupancy from the vehicle:

```java
return vehicle == null;
```

Therefore:

```java
public boolean isAvailable() {
    return vehicle == null;
}
```

This is cleaner.

---

# 9. Parking Floor Design

A parking floor contains multiple parking spots.

Relationship:

```text
ParkingFloor HAS-A ParkingSpot
```

So:

```java
private List<ParkingSpot> parkingSpots;
```

---

## ParkingFloor Class

```java
import java.util.ArrayList;
import java.util.List;

public class ParkingFloor {

    private String id;
    private List<ParkingSpot> parkingSpots;

    public ParkingFloor(String id) {
        this.id = id;
        this.parkingSpots = new ArrayList<>();
    }

    public void addParkingSpot(ParkingSpot spot) {
        parkingSpots.add(spot);
    }

    public ParkingSpot findAvailableSpot(Vehicle vehicle) {

        for (ParkingSpot spot : parkingSpots) {

            if (spot.isAvailable()
                    && spot.canFitVehicle(vehicle)) {

                return spot;
            }
        }

        return null;
    }

    public String getId() {
        return id;
    }

    public List<ParkingSpot> getParkingSpots() {
        return parkingSpots;
    }
}
```

---

# 10. Parking Lot Design

A parking lot contains multiple floors.

Relationship:

```text
ParkingLot HAS-A ParkingFloor
```

Therefore:

```java
private List<ParkingFloor> floors;
```

---

## ParkingLot Class

```java
import java.util.ArrayList;
import java.util.List;

public class ParkingLot {

    private String id;
    private List<ParkingFloor> floors;

    public ParkingLot(String id) {
        this.id = id;
        this.floors = new ArrayList<>();
    }

    public void addFloor(ParkingFloor floor) {
        floors.add(floor);
    }

    public ParkingSpot findAvailableSpot(Vehicle vehicle) {

        for (ParkingFloor floor : floors) {

            ParkingSpot spot =
                    floor.findAvailableSpot(vehicle);

            if (spot != null) {
                return spot;
            }
        }

        return null;
    }

    public String getId() {
        return id;
    }

    public List<ParkingFloor> getFloors() {
        return floors;
    }
}
```

---

# 11. Why Does ParkingLot Find the Spot?

We could put all spot-finding logic inside `ParkingService`.

For example:

```java
for (ParkingFloor floor : floors) {
    ...
}
```

But that makes the service know too much about the internal structure of the parking lot.

Instead:

```text
ParkingService
      |
      v
ParkingLot
      |
      v
ParkingFloor
      |
      v
ParkingSpot
```

Each class manages its own responsibility.

This is an example of **separation of responsibilities**.

---

# 12. Ticket Design

When a vehicle enters, we generate a ticket.

A ticket contains:

```text
ticket ID
vehicle
parking spot
entry time
exit time
```

---

## Ticket Class

```java
import java.time.LocalDateTime;

public class Ticket {

    private String id;
    private Vehicle vehicle;
    private ParkingSpot parkingSpot;
    private LocalDateTime entryTime;
    private LocalDateTime exitTime;

    public Ticket(
            String id,
            Vehicle vehicle,
            ParkingSpot parkingSpot,
            LocalDateTime entryTime) {

        this.id = id;
        this.vehicle = vehicle;
        this.parkingSpot = parkingSpot;
        this.entryTime = entryTime;
    }

    public void setExitTime(LocalDateTime exitTime) {
        this.exitTime = exitTime;
    }

    public String getId() {
        return id;
    }

    public Vehicle getVehicle() {
        return vehicle;
    }

    public ParkingSpot getParkingSpot() {
        return parkingSpot;
    }

    public LocalDateTime getEntryTime() {
        return entryTime;
    }

    public LocalDateTime getExitTime() {
        return exitTime;
    }
}
```

---

# 13. Pricing Design

Now we need to calculate parking fees.

A simple implementation might be:

```java
if (vehicleType == VehicleType.BIKE) {
    return 20;
}

if (vehicleType == VehicleType.CAR) {
    return 50;
}

if (vehicleType == VehicleType.TRUCK) {
    return 100;
}
```

Initially this looks fine.

But imagine the requirements change.

Tomorrow we need:

```text
Hourly pricing
Weekend pricing
Night pricing
Festival pricing
Monthly pricing
Premium parking pricing
```

We don't want one giant `if-else`.

This is where the **Strategy Pattern** is useful.

---

# 14. Strategy Pattern

The Strategy Pattern allows us to encapsulate interchangeable algorithms/behaviors.

Here the changing behavior is:

```text
How should parking price be calculated?
```

So we create:

```java
public interface PricingStrategy {

    double calculatePrice(Ticket ticket);
}
```

Now any pricing algorithm can implement this interface.

---

# 15. Hourly Pricing Strategy

```java
import java.time.Duration;

public class HourlyPricingStrategy
        implements PricingStrategy {

    @Override
    public double calculatePrice(Ticket ticket) {

        long hours = Duration.between(
                ticket.getEntryTime(),
                ticket.getExitTime()
        ).toHours();

        if (hours == 0) {
            hours = 1;
        }

        return hours * 50;
    }
}
```

---

# 16. Another Pricing Strategy

For example, weekend pricing:

```java
public class WeekendPricingStrategy
        implements PricingStrategy {

    @Override
    public double calculatePrice(Ticket ticket) {
        return 100;
    }
}
```

Now we have:

```text
PricingStrategy
      |
      +---- HourlyPricingStrategy
      |
      +---- WeekendPricingStrategy
```

The `ParkingService` doesn't need to know how pricing works.

---

# 17. Why Interface?

We could write:

```java
class ParkingService {

    private HourlyPricingStrategy strategy;
}
```

But then the service is tightly coupled to hourly pricing.

Instead:

```java
class ParkingService {

    private PricingStrategy strategy;
}
```

Now we can inject any pricing strategy.

Example:

```java
PricingStrategy strategy =
        new HourlyPricingStrategy();
```

or:

```java
PricingStrategy strategy =
        new WeekendPricingStrategy();
```

This is **polymorphism**.

---

# 18. Payment Design

A parking lot can support multiple payment methods.

For example:

```text
CASH
CARD
UPI
```

We can use an enum:

```java
public enum PaymentMethod {
    CASH,
    CARD,
    UPI
}
```

---

# 19. PaymentProcessor Interface

Different payment methods have different implementations.

Create an interface:

```java
public interface PaymentProcessor {

    void pay(double amount);
}
```

---

# 20. Cash Payment

```java
public class CashPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {

        System.out.println(
                "Paid ₹" + amount + " using cash"
        );
    }
}
```

---

# 21. Card Payment

```java
public class CardPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {

        System.out.println(
                "Paid ₹" + amount + " using card"
        );
    }
}
```

---

# 22. UPI Payment

```java
public class UpiPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {

        System.out.println(
                "Paid ₹" + amount + " using UPI"
        );
    }
}
```

---

# 23. Factory Pattern

Now we need to create the correct payment processor.

We could write:

```java
if (method == PaymentMethod.CASH) {
    return new CashPaymentProcessor();
}

if (method == PaymentMethod.CARD) {
    return new CardPaymentProcessor();
}

if (method == PaymentMethod.UPI) {
    return new UpiPaymentProcessor();
}
```

But we don't want this creation logic spread across the system.

So we create a Factory.

---

## PaymentProcessorFactory

```java
public class PaymentProcessorFactory {

    public static PaymentProcessor getProcessor(
            PaymentMethod method) {

        return switch (method) {

            case CASH ->
                    new CashPaymentProcessor();

            case CARD ->
                    new CardPaymentProcessor();

            case UPI ->
                    new UpiPaymentProcessor();
        };
    }
}
```

Usage:

```java
PaymentProcessor processor =
        PaymentProcessorFactory.getProcessor(
                PaymentMethod.UPI
        );

processor.pay(100);
```

The caller doesn't need to know how the UPI processor is created.

---

# 24. Parking Service

We now have multiple classes.

We need something to coordinate the overall flow.

That class can be:

```text
ParkingService
```

Its responsibilities are:

```text
Park vehicle
Generate ticket
Exit vehicle
Calculate price
Process payment
Free parking spot
```

It acts as an orchestration layer.

---

# 25. ParkingService Class

```java
import java.time.LocalDateTime;
import java.util.UUID;

public class ParkingService {

    private ParkingLot parkingLot;
    private PricingStrategy pricingStrategy;

    public ParkingService(
            ParkingLot parkingLot,
            PricingStrategy pricingStrategy) {

        this.parkingLot = parkingLot;
        this.pricingStrategy = pricingStrategy;
    }

    public Ticket parkVehicle(Vehicle vehicle) {

        ParkingSpot spot =
                parkingLot.findAvailableSpot(vehicle);

        if (spot == null) {
            throw new IllegalStateException(
                    "No parking spot available"
            );
        }

        spot.parkVehicle(vehicle);

        return new Ticket(
                UUID.randomUUID().toString(),
                vehicle,
                spot,
                LocalDateTime.now()
        );
    }

    public double exitVehicle(
            Ticket ticket,
            PaymentMethod paymentMethod) {

        ticket.setExitTime(LocalDateTime.now());

        double amount =
                pricingStrategy.calculatePrice(ticket);

        PaymentProcessor processor =
                PaymentProcessorFactory
                        .getProcessor(paymentMethod);

        processor.pay(amount);

        ticket.getParkingSpot().removeVehicle();

        return amount;
    }
}
```

---

# 26. Why ParkingService?

Without `ParkingService`, the client might have to do this:

```java
ParkingSpot spot =
        parkingLot.findAvailableSpot(vehicle);

spot.parkVehicle(vehicle);

Ticket ticket = new Ticket(...);

ticket.setExitTime(...);

double amount =
        pricingStrategy.calculatePrice(ticket);

PaymentProcessor processor =
        PaymentProcessorFactory.getProcessor(...);

processor.pay(amount);

spot.removeVehicle();
```

That's too much knowledge for the client.

Instead:

```java
parkingService.parkVehicle(vehicle);
```

and:

```java
parkingService.exitVehicle(
        ticket,
        PaymentMethod.UPI
);
```

The service coordinates the workflow.

---

# 27. Complete Class Relationships

Our main relationships are:

```text
ParkingLot
    |
    | HAS-A
    v
ParkingFloor
    |
    | HAS-A
    v
ParkingSpot
    |
    | HAS-A
    v
Vehicle
```

Ticket:

```text
Ticket
    |
    +---- Vehicle
    |
    +---- ParkingSpot
```

Pricing:

```text
PricingStrategy
       |
       +---- HourlyPricingStrategy
       |
       +---- WeekendPricingStrategy
```

Payment:

```text
PaymentProcessor
       |
       +---- CashPaymentProcessor
       |
       +---- CardPaymentProcessor
       |
       +---- UpiPaymentProcessor
```

Service:

```text
ParkingService
       |
       +---- ParkingLot
       |
       +---- PricingStrategy
       |
       +---- PaymentProcessorFactory
```

---

# 28. Complete Class Diagram

```text
+----------------------+
|      ParkingLot      |
+----------------------+
| - id                 |
| - floors             |
+----------------------+
| + addFloor()         |
| + findAvailableSpot()|
+----------+-----------+
           |
           | HAS MANY
           v
+----------------------+
|    ParkingFloor      |
+----------------------+
| - id                 |
| - parkingSpots       |
+----------------------+
| + addParkingSpot()   |
| + findAvailableSpot()|
+----------+-----------+
           |
           | HAS MANY
           v
+----------------------+
|     ParkingSpot      |
+----------------------+
| - id                 |
| - spotType           |
| - vehicle            |
+----------------------+
| + isAvailable()      |
| + canFitVehicle()    |
| + parkVehicle()      |
| + removeVehicle()    |
+----------+-----------+
           |
           | HAS-A
           v
+----------------------+
|       Vehicle        |
+----------------------+
| - licensePlate       |
| - vehicleType        |
+----------------------+


+----------------------+
|       Ticket         |
+----------------------+
| - id                 |
| - vehicle            |
| - parkingSpot        |
| - entryTime          |
| - exitTime           |
+----------------------+


+-----------------------------+
|      PricingStrategy        |
+-----------------------------+
| + calculatePrice()          |
+-------------+---------------+
              |
       +------+------+
       |             |
       v             v
+----------------+ +----------------------+
| HourlyPricing  | | WeekendPricing       |
+----------------+ +----------------------+


+-----------------------------+
|     PaymentProcessor        |
+-----------------------------+
| + pay()                     |
+-------------+---------------+
              |
       +------+------+------+
       |             |      |
       v             v      v
+----------+ +----------+ +----------+
|   Cash   | |   Card   | |   UPI    |
+----------+ +----------+ +----------+


+-----------------------------+
|       ParkingService        |
+-----------------------------+
| - parkingLot                |
| - pricingStrategy           |
+-----------------------------+
| + parkVehicle()             |
| + exitVehicle()             |
+-----------------------------+
```

---

# 29. Complete Java Code

Below is the complete basic implementation.

---

## VehicleType.java

```java
public enum VehicleType {
    BIKE,
    CAR,
    TRUCK
}
```

---

## SpotType.java

```java
public enum SpotType {
    BIKE,
    CAR,
    TRUCK
}
```

---

## PaymentMethod.java

```java
public enum PaymentMethod {
    CASH,
    CARD,
    UPI
}
```

---

## Vehicle.java

```java
public class Vehicle {

    private String licensePlate;
    private VehicleType vehicleType;

    public Vehicle(
            String licensePlate,
            VehicleType vehicleType) {

        this.licensePlate = licensePlate;
        this.vehicleType = vehicleType;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public VehicleType getVehicleType() {
        return vehicleType;
    }
}
```

---

## ParkingSpot.java

```java
public class ParkingSpot {

    private String id;
    private SpotType spotType;
    private Vehicle vehicle;

    public ParkingSpot(
            String id,
            SpotType spotType) {

        this.id = id;
        this.spotType = spotType;
    }

    public boolean isAvailable() {
        return vehicle == null;
    }

    public boolean canFitVehicle(Vehicle vehicle) {

        return switch (vehicle.getVehicleType()) {

            case BIKE ->
                    spotType == SpotType.BIKE;

            case CAR ->
                    spotType == SpotType.CAR;

            case TRUCK ->
                    spotType == SpotType.TRUCK;
        };
    }

    public void parkVehicle(Vehicle vehicle) {

        if (!isAvailable()) {

            throw new IllegalStateException(
                    "Parking spot is already occupied"
            );
        }

        if (!canFitVehicle(vehicle)) {

            throw new IllegalArgumentException(
                    "Vehicle cannot fit in this spot"
            );
        }

        this.vehicle = vehicle;
    }

    public void removeVehicle() {
        this.vehicle = null;
    }

    public String getId() {
        return id;
    }

    public SpotType getSpotType() {
        return spotType;
    }

    public Vehicle getVehicle() {
        return vehicle;
    }
}
```

---

## ParkingFloor.java

```java
import java.util.ArrayList;
import java.util.List;

public class ParkingFloor {

    private String id;
    private List<ParkingSpot> parkingSpots;

    public ParkingFloor(String id) {

        this.id = id;
        this.parkingSpots = new ArrayList<>();
    }

    public void addParkingSpot(ParkingSpot spot) {
        parkingSpots.add(spot);
    }

    public ParkingSpot findAvailableSpot(Vehicle vehicle) {

        for (ParkingSpot spot : parkingSpots) {

            if (spot.isAvailable()
                    && spot.canFitVehicle(vehicle)) {

                return spot;
            }
        }

        return null;
    }

    public String getId() {
        return id;
    }

    public List<ParkingSpot> getParkingSpots() {
        return parkingSpots;
    }
}
```

---

## ParkingLot.java

```java
import java.util.ArrayList;
import java.util.List;

public class ParkingLot {

    private String id;
    private List<ParkingFloor> floors;

    public ParkingLot(String id) {

        this.id = id;
        this.floors = new ArrayList<>();
    }

    public void addFloor(ParkingFloor floor) {
        floors.add(floor);
    }

    public ParkingSpot findAvailableSpot(Vehicle vehicle) {

        for (ParkingFloor floor : floors) {

            ParkingSpot spot =
                    floor.findAvailableSpot(vehicle);

            if (spot != null) {
                return spot;
            }
        }

        return null;
    }

    public String getId() {
        return id;
    }

    public List<ParkingFloor> getFloors() {
        return floors;
    }
}
```

---

## Ticket.java

```java
import java.time.LocalDateTime;

public class Ticket {

    private String id;
    private Vehicle vehicle;
    private ParkingSpot parkingSpot;
    private LocalDateTime entryTime;
    private LocalDateTime exitTime;

    public Ticket(
            String id,
            Vehicle vehicle,
            ParkingSpot parkingSpot,
            LocalDateTime entryTime) {

        this.id = id;
        this.vehicle = vehicle;
        this.parkingSpot = parkingSpot;
        this.entryTime = entryTime;
    }

    public void setExitTime(LocalDateTime exitTime) {
        this.exitTime = exitTime;
    }

    public String getId() {
        return id;
    }

    public Vehicle getVehicle() {
        return vehicle;
    }

    public ParkingSpot getParkingSpot() {
        return parkingSpot;
    }

    public LocalDateTime getEntryTime() {
        return entryTime;
    }

    public LocalDateTime getExitTime() {
        return exitTime;
    }
}
```

---

## PricingStrategy.java

```java
public interface PricingStrategy {

    double calculatePrice(Ticket ticket);
}
```

---

## HourlyPricingStrategy.java

```java
import java.time.Duration;

public class HourlyPricingStrategy
        implements PricingStrategy {

    @Override
    public double calculatePrice(Ticket ticket) {

        long hours = Duration.between(
                ticket.getEntryTime(),
                ticket.getExitTime()
        ).toHours();

        if (hours == 0) {
            hours = 1;
        }

        return hours * 50;
    }
}
```

---

## PaymentProcessor.java

```java
public interface PaymentProcessor {

    void pay(double amount);
}
```

---

## CashPaymentProcessor.java

```java
public class CashPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {

        System.out.println(
                "Paid ₹" + amount + " using cash"
        );
    }
}
```

---

## CardPaymentProcessor.java

```java
public class CardPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {

        System.out.println(
                "Paid ₹" + amount + " using card"
        );
    }
}
```

---

## UpiPaymentProcessor.java

```java
public class UpiPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {

        System.out.println(
                "Paid ₹" + amount + " using UPI"
        );
    }
}
```

---

## PaymentProcessorFactory.java

```java
public class PaymentProcessorFactory {

    public static PaymentProcessor getProcessor(
            PaymentMethod method) {

        return switch (method) {

            case CASH ->
                    new CashPaymentProcessor();

            case CARD ->
                    new CardPaymentProcessor();

            case UPI ->
                    new UpiPaymentProcessor();
        };
    }
}
```

---

## ParkingService.java

```java
import java.time.LocalDateTime;
import java.util.UUID;

public class ParkingService {

    private ParkingLot parkingLot;
    private PricingStrategy pricingStrategy;

    public ParkingService(
            ParkingLot parkingLot,
            PricingStrategy pricingStrategy) {

        this.parkingLot = parkingLot;
        this.pricingStrategy = pricingStrategy;
    }

    public Ticket parkVehicle(Vehicle vehicle) {

        ParkingSpot spot =
                parkingLot.findAvailableSpot(vehicle);

        if (spot == null) {

            throw new IllegalStateException(
                    "No parking spot available"
            );
        }

        spot.parkVehicle(vehicle);

        return new Ticket(
                UUID.randomUUID().toString(),
                vehicle,
                spot,
                LocalDateTime.now()
        );
    }

    public double exitVehicle(
            Ticket ticket,
            PaymentMethod paymentMethod) {

        ticket.setExitTime(
                LocalDateTime.now()
        );

        double amount =
                pricingStrategy.calculatePrice(ticket);

        PaymentProcessor processor =
                PaymentProcessorFactory
                        .getProcessor(paymentMethod);

        processor.pay(amount);

        ticket.getParkingSpot()
                .removeVehicle();

        return amount;
    }
}
```

---

# 30. Main Class

Let's see how a client would use our design.

```java
public class Main {

    public static void main(String[] args) {

        // Create Parking Lot
        ParkingLot parkingLot =
                new ParkingLot("LOT-1");

        // Create Floor
        ParkingFloor floor1 =
                new ParkingFloor("FLOOR-1");

        // Add parking spots
        floor1.addParkingSpot(
                new ParkingSpot(
                        "CAR-1",
                        SpotType.CAR
                )
        );

        floor1.addParkingSpot(
                new ParkingSpot(
                        "CAR-2",
                        SpotType.CAR
                )
        );

        floor1.addParkingSpot(
                new ParkingSpot(
                        "BIKE-1",
                        SpotType.BIKE
                )
        );

        // Add floor to parking lot
        parkingLot.addFloor(floor1);

        // Create pricing strategy
        PricingStrategy pricingStrategy =
                new HourlyPricingStrategy();

        // Create Parking Service
        ParkingService parkingService =
                new ParkingService(
                        parkingLot,
                        pricingStrategy
                );

        // Create vehicle
        Vehicle car =
                new Vehicle(
                        "MH01AB1234",
                        VehicleType.CAR
                );

        // Park vehicle
        Ticket ticket =
                parkingService.parkVehicle(car);

        System.out.println(
                "Vehicle parked successfully"
        );

        System.out.println(
                "Ticket ID: "
                        + ticket.getId()
        );

        System.out.println(
                "Spot: "
                        + ticket.getParkingSpot().getId()
        );

        // Exit vehicle
        double amount =
                parkingService.exitVehicle(
                        ticket,
                        PaymentMethod.UPI
                );

        System.out.println(
                "Total amount: ₹" + amount
        );
    }
}
```

---

# 31. Parking Vehicle Flow

Let's understand the exact execution flow.

We call:

```java
parkingService.parkVehicle(car);
```

### Step 1

`ParkingService` receives the vehicle.

```text
ParkingService
      |
      v
parkVehicle(car)
```

### Step 2

It asks `ParkingLot` for a spot.

```text
ParkingService
      |
      v
ParkingLot.findAvailableSpot()
```

### Step 3

Parking lot checks floors.

```text
ParkingLot
    |
    +--- Floor 1
    |
    +--- Floor 2
    |
    +--- Floor 3
```

### Step 4

Each floor checks its spots.

```text
ParkingFloor
     |
     +--- Spot 1
     +--- Spot 2
     +--- Spot 3
```

### Step 5

It finds a suitable spot.

```text
CAR-1
```

### Step 6

Vehicle is parked.

```java
spot.parkVehicle(car);
```

### Step 7

Ticket is generated.

```java
new Ticket(...)
```

Final flow:

```text
Vehicle
   |
   v
ParkingService
   |
   v
ParkingLot
   |
   v
ParkingFloor
   |
   v
ParkingSpot
   |
   v
Park Vehicle
   |
   v
Generate Ticket
```

---

# 32. Exit Vehicle Flow

Suppose the vehicle wants to leave.

We call:

```java
parkingService.exitVehicle(
        ticket,
        PaymentMethod.UPI
);
```

Flow:

```text
Ticket
  |
  v
ParkingService
  |
  v
Set Exit Time
  |
  v
PricingStrategy
  |
  v
Calculate Price
  |
  v
PaymentProcessorFactory
  |
  v
UPI PaymentProcessor
  |
  v
Payment
  |
  v
ParkingSpot.removeVehicle()
```

After this:

```text
ParkingSpot
     |
     v
vehicle = null
```

Therefore:

```java
spot.isAvailable()
```

returns:

```text
true
```

---

# 33. OOP Concepts Used

This Parking Lot design uses several important OOP concepts.

---

## 33.1 Encapsulation

Fields are private:

```java
private String id;
private Vehicle vehicle;
```

Outside classes cannot directly modify them.

Instead, behavior is exposed through methods:

```java
parkVehicle()
removeVehicle()
isAvailable()
```

This protects the object's internal state.

---

## 33.2 Abstraction

We expose:

```java
public interface PricingStrategy {
    double calculatePrice(Ticket ticket);
}
```

The caller only cares that pricing can be calculated.

It doesn't need to know how.

---

## 33.3 Polymorphism

We can write:

```java
PricingStrategy strategy =
        new HourlyPricingStrategy();
```

The variable type is:

```text
PricingStrategy
```

while the actual implementation is:

```text
HourlyPricingStrategy
```

Similarly:

```java
PaymentProcessor processor =
        new UpiPaymentProcessor();
```

---

## 33.4 Composition

Parking lot contains floors:

```java
private List<ParkingFloor> floors;
```

Floor contains spots:

```java
private List<ParkingSpot> parkingSpots;
```

This is a HAS-A relationship.

---

# 34. IS-A vs HAS-A

This is extremely important for LLD interviews.

## IS-A

Used for inheritance.

Example:

```text
Car IS-A Vehicle
```

Java:

```java
class Car extends Vehicle {
}
```

---

## HAS-A

Used for composition.

Example:

```text
ParkingLot HAS-A ParkingFloor
```

Java:

```java
class ParkingLot {

    private List<ParkingFloor> floors;
}
```

---

# 35. Why We Don't Use `Car extends Vehicle`

We could design:

```text
Vehicle
   |
   +--- Bike
   |
   +--- Car
   |
   +--- Truck
```

But currently our vehicle types don't have significantly different behavior.

We only need:

```java
VehicleType.CAR
```

Therefore:

```java
Vehicle
    |
    +--- VehicleType
```

is sufficient.

Don't create inheritance just because classes have a natural relationship.

Use inheritance when you need **polymorphic behavior**.

---

# 36. SOLID Principles

SOLID is a group of principles that help us create maintainable object-oriented designs.

---

# 37. S — Single Responsibility Principle

> A class should have one primary responsibility.

Our classes have focused responsibilities.

```text
Vehicle
    -> vehicle information

ParkingSpot
    -> manage parking spot

ParkingFloor
    -> manage spots

ParkingLot
    -> manage floors

Ticket
    -> parking session information

PricingStrategy
    -> calculate price

PaymentProcessor
    -> process payment

ParkingService
    -> coordinate parking workflow
```

This is much better than creating one huge class.

---

# 38. O — Open/Closed Principle

> Classes should be open for extension but closed for modification.

Suppose we currently have:

```text
HourlyPricingStrategy
```

Later we add:

```text
WeekendPricingStrategy
MonthlyPricingStrategy
FestivalPricingStrategy
```

We don't need to modify the `PricingStrategy` interface.

We simply add new implementations.

```text
PricingStrategy
       |
       +--- Hourly
       +--- Weekend
       +--- Monthly
       +--- Festival
```

---

# 39. L — Liskov Substitution Principle

> Objects of a subtype should be usable wherever the parent abstraction is expected.

For example:

```java
PricingStrategy strategy;
```

We can assign:

```java
strategy = new HourlyPricingStrategy();
```

or:

```java
strategy = new WeekendPricingStrategy();
```

Both should correctly behave as a `PricingStrategy`.

---

# 40. I — Interface Segregation Principle

> Don't force classes to implement methods they don't need.

Instead of creating one giant interface:

```java
interface ParkingSystem {

    park();
    calculatePrice();
    makePayment();
    sendNotification();
    generateReport();
}
```

we have smaller interfaces:

```java
PricingStrategy
```

and:

```java
PaymentProcessor
```

This keeps abstractions focused.

---

# 41. D — Dependency Inversion Principle

> High-level modules should depend on abstractions rather than concrete implementations.

Instead of:

```java
private HourlyPricingStrategy pricingStrategy;
```

we use:

```java
private PricingStrategy pricingStrategy;
```

This means `ParkingService` doesn't care which pricing implementation is being used.

---

# 42. Dependency Injection

We inject the pricing strategy through the constructor:

```java
public ParkingService(
        ParkingLot parkingLot,
        PricingStrategy pricingStrategy) {

    this.parkingLot = parkingLot;
    this.pricingStrategy = pricingStrategy;
}
```

Then:

```java
PricingStrategy strategy =
        new HourlyPricingStrategy();

ParkingService service =
        new ParkingService(
                parkingLot,
                strategy
        );
```

This is called **constructor dependency injection**.

---

# 43. Design Patterns Used

Our basic design uses two important patterns.

---

## 43.1 Strategy Pattern

Used for:

```text
PricingStrategy
```

Why?

Because pricing behavior can change.

```text
PricingStrategy
      |
      +--- Hourly
      +--- Weekend
      +--- Monthly
```

---

## 43.2 Factory Pattern

Used for:

```text
PaymentProcessorFactory
```

Why?

Because payment processor creation can vary.

```text
PaymentProcessorFactory
       |
       +--- CashPaymentProcessor
       +--- CardPaymentProcessor
       +--- UpiPaymentProcessor
```

---

# 44. Why Not Use Singleton?

A common beginner mistake is:

> "Parking Lot is one object, so I'll make it Singleton."

For example:

```java
public class ParkingLot {

    private static ParkingLot instance;

    ...
}
```

Don't automatically use Singleton.

The requirement might say:

```text
There is one parking lot.
```

That doesn't necessarily mean the class must enforce Singleton at the application level.

Singleton introduces global state and makes testing harder.

Use it only when there is a genuine requirement for a single globally accessible instance.

---

# 45. Common Beginner Mistakes

## Mistake 1: Start Coding Immediately

Bad approach:

```text
Question
   |
   v
Create classes immediately
```

Better:

```text
Requirements
   |
   v
Use Cases
   |
   v
Entities
   |
   v
Responsibilities
   |
   v
Relationships
   |
   v
Code
```

---

## Mistake 2: One Giant Class

Avoid:

```java
class ParkingLot {

    parkVehicle();
    calculatePrice();
    processPayment();
    generateTicket();
    sendNotification();
    ...
}
```

This becomes a God Class.

---

## Mistake 3: Too Much Inheritance

Don't create:

```text
Vehicle
 |
 +-- Bike
 |
 +-- Car
 |
 +-- Truck
```

unless different vehicle types actually need different behavior.

---

## Mistake 4: Giant `if-else`

Avoid:

```java
if (type == CAR) {
    ...
} else if (type == BIKE) {
    ...
} else if (type == TRUCK) {
    ...
}
```

everywhere.

When behavior varies significantly, consider Strategy or another appropriate abstraction.

---

## Mistake 5: Using Design Patterns Everywhere

Don't say:

```text
Factory here
Singleton there
Observer there
Builder there
Strategy there
```

just to show knowledge.

Design patterns are tools.

First understand the problem.

Then choose the pattern.

---

# 46. Possible Extensions

Our current design is intentionally simple.

A real interview may add requirements.

---

## 46.1 Multiple Entry Gates

```text
ParkingLot
    |
    +--- EntryGate
    +--- EntryGate
    +--- EntryGate
```

Each gate may have:

```text
id
location
```

---

## 46.2 Multiple Exit Gates

```text
ParkingLot
    |
    +--- ExitGate
    +--- ExitGate
```

---

## 46.3 Display Board

A display board could show:

```text
Floor 1

Bike Spots  : 20 available
Car Spots   : 10 available
Truck Spots : 2 available
```

We could introduce:

```text
DisplayBoard
```

---

## 46.4 Different Vehicle Sizes

Instead of:

```text
BIKE
CAR
TRUCK
```

we could have:

```text
SMALL
MEDIUM
LARGE
```

Then a large spot might accept:

```text
Bike
Car
Truck
```

depending on business rules.

---

## 46.5 Different Pricing Rules

We could have:

```text
HourlyPricingStrategy
WeekendPricingStrategy
NightPricingStrategy
MonthlyPricingStrategy
```

---

## 46.6 Different Payment Methods

We could add:

```text
CreditCardPaymentProcessor
DebitCardPaymentProcessor
UPIPaymentProcessor
CashPaymentProcessor
WalletPaymentProcessor
```

without changing the core payment abstraction.

---

## 46.7 Reservation

We could introduce:

```text
ParkingReservation
```

Flow:

```text
User
 |
 v
Reserve Spot
 |
 v
Reservation
 |
 v
Vehicle arrives
 |
 v
Use reserved spot
```

---

## 46.8 Parking Spot Allocation Strategy

Currently:

```text
First available spot
```

But we might want:

```text
Nearest spot
Cheapest spot
First floor
Lowest floor
Electric vehicle spot
```

This could itself become a Strategy.

For example:

```java
public interface SpotAllocationStrategy {

    ParkingSpot findSpot(
            ParkingLot parkingLot,
            Vehicle vehicle);
}
```

Then:

```text
SpotAllocationStrategy
        |
        +--- FirstAvailableStrategy
        |
        +--- NearestSpotStrategy
        |
        +--- CheapestSpotStrategy
```

This is a natural extension of the design.

---

# 47. Advanced Version of the Design

As requirements grow, the architecture could become:

```text
                    ParkingLot
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
     Entry Gates    Parking Floors   Exit Gates
                         |
                         v
                   Parking Spots
                         |
                         v
                      Vehicle


                   ParkingService
                         |
          +--------------+--------------+
          |              |              |
          v              v              v
    SpotAllocation   Pricing        Payment
      Strategy       Strategy       Processor
          |              |              |
          v              v              v
     FirstAvailable   Hourly          UPI
     NearestSpot      Weekend         Card
     Cheapest         Monthly         Cash
```

This is much more extensible.

---

# 48. Concurrency Consideration

This is an important real-world problem.

Suppose only one car spot is available.

Two vehicles arrive at almost exactly the same time:

```text
Vehicle A ---> Find spot ---> CAR-1
Vehicle B ---> Find spot ---> CAR-1
```

If both threads see the spot as available before either parks, both may try to park there.

This can cause double allocation.

Therefore, in a production system, spot allocation needs concurrency control.

Conceptually:

```text
Check availability
       +
Reserve atomically
```

Possible Java mechanisms include:

```text
synchronized
Lock
ReentrantLock
Atomic operations
Database transactions
```

The exact solution depends on whether this is an in-memory system or distributed system.

For a beginner LLD interview, mention concurrency if asked, rather than overcomplicating the initial design.

---

# 49. Testing the Design

Good LLD should also be testable.

For example:

## Test 1

Car enters when car spot is available.

Expected:

```text
Vehicle parked
Ticket generated
```

---

## Test 2

Car enters when no car spot is available.

Expected:

```text
No parking spot available
```

---

## Test 3

Bike tries to park in truck spot.

Expected:

```text
Vehicle cannot fit in this spot
```

---

## Test 4

Vehicle exits.

Expected:

```text
Payment processed
Spot becomes available
```

---

## Test 5

Different pricing strategy.

Expected:

```text
Correct strategy calculates correct price
```

---

# 50. Interview Explanation

If an interviewer asks:

> "Design a Parking Lot."

You can start like this:

```text
First, I would like to clarify the requirements.

I'll assume the parking lot can have multiple floors,
each floor can have multiple parking spots, and we support
different vehicle and spot types.

When a vehicle enters, the system should find an appropriate
available spot, park the vehicle, and generate a ticket.

When the vehicle exits, the system should calculate the
parking fee, process payment, and release the parking spot.

For the design, I will use ParkingLot, ParkingFloor,
ParkingSpot, Vehicle, Ticket, and ParkingService as the
main entities.

For pricing, I'll use a PricingStrategy interface because
pricing rules can change.

For payment, I'll use a PaymentProcessor interface with
different implementations for cash, card, and UPI.

I'll use a factory to create the appropriate payment
processor.
```

Then draw the class diagram.

Then explain the flow.

---

# 51. What the Interviewer Is Actually Checking

The interviewer usually isn't only checking whether you can write Java.

They are checking whether you can:

```text
Understand requirements
        |
        v
Break a problem into objects
        |
        v
Assign responsibilities correctly
        |
        v
Create clean relationships
        |
        v
Use abstraction
        |
        v
Avoid unnecessary coupling
        |
        v
Design for change
```

The most important skill is **how you think about the design**.

---

# 52. Final Design

Our basic Parking Lot design is:

```text
                         +----------------+
                         |  ParkingLot    |
                         +----------------+
                                  |
                                  | HAS MANY
                                  v
                         +----------------+
                         | ParkingFloor   |
                         +----------------+
                                  |
                                  | HAS MANY
                                  v
                         +----------------+
                         | ParkingSpot    |
                         +----------------+
                                  |
                                  | HAS
                                  v
                         +----------------+
                         |    Vehicle     |
                         +----------------+


+------------------+
|      Ticket      |
+------------------+
| id               |
| vehicle          |
| parkingSpot      |
| entryTime        |
| exitTime         |
+------------------+


+-----------------------+
|   PricingStrategy     |
+-----------------------+
| calculatePrice()      |
+-----------+-----------+
            |
      +-----+------+
      |            |
      v            v
    Hourly      Weekend


+-----------------------+
|  PaymentProcessor     |
+-----------------------+
| pay()                 |
+-----------+-----------+
            |
     +------+------+------+
     |             |      |
     v             v      v
   Cash          Card     UPI


+-----------------------+
|    ParkingService     |
+-----------------------+
| parkingLot            |
| pricingStrategy       |
+-----------------------+
| parkVehicle()         |
| exitVehicle()         |
+-----------------------+
```

---

# 53. Key Concepts to Remember

For this Parking Lot LLD, remember these:

```text
CLASS
    ↓
Represents an entity/object

ENUM
    ↓
Represents a fixed set of values

INTERFACE
    ↓
Defines a contract/abstraction

ENCAPSULATION
    ↓
Keep internal state private

COMPOSITION
    ↓
HAS-A relationship

INHERITANCE
    ↓
IS-A relationship

POLYMORPHISM
    ↓
Same abstraction, different implementations

DEPENDENCY INJECTION
    ↓
Pass dependencies from outside

STRATEGY PATTERN
    ↓
Encapsulate interchangeable behavior

FACTORY PATTERN
    ↓
Encapsulate object creation

SOLID
    ↓
Guidelines for maintainable design
```

---

# 54. The Most Important LLD Rule

Don't memorize the Parking Lot code.

Instead, remember the **design process**:

```text
                LLD PROBLEM
                     |
                     v
              Understand Requirements
                     |
                     v
                 Use Cases
                     |
                     v
              Find Important Nouns
                     |
                     v
                  Classes
                     |
                     v
             Assign Responsibilities
                     |
                     v
             Define Relationships
                     |
                     v
          Find What Is Likely To Change
                     |
                     v
                Add Abstraction
                     |
                     v
             Apply Design Patterns
                     |
                     v
                Class Diagram
                     |
                     v
                  Java Code
```

If you learn to follow this process, you can use the same approach for:

```text
Parking Lot
    ↓
Elevator
    ↓
ATM
    ↓
Library Management
    ↓
Tic-Tac-Toe
    ↓
Chess
    ↓
Splitwise
    ↓
Movie Ticket Booking
    ↓
Food Delivery
    ↓
Ride Sharing
```

The problem changes, but the **LLD thinking process remains largely the same**.