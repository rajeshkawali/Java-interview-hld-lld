# Car Rental System — Low-Level Design (LLD)

## 1. Problem Statement

We need to design a **Car Rental System** where customers can:

1. Search for available cars.
2. Select a car.
3. Rent the car for a specific period.
4. Make a payment.
5. Return the car.
6. Calculate the rental amount.

The system should support:

- Multiple cars
- Multiple customers
- Different types of cars
- Different pricing strategies
- Car availability
- Reservations/rentals
- Payments

---

# 2. First Understand the Flow

Before creating classes, understand the basic flow.

```text
Customer
   |
   | Search for car
   v
Rental System
   |
   | Find available cars
   v
Available Cars
   |
   | Select car
   v
Reservation
   |
   | Make payment
   v
Payment
   |
   | Pick up car
   v
Car rented
   |
   | Return car
   v
Calculate final amount
   |
   v
Car becomes AVAILABLE
```

The important question in LLD is:

> **What are the objects involved in this process?**

---

# 3. Identify the Main Entities

From the requirements, we can identify:

```text
Customer
Car
Vehicle
Rental
Payment
RentalSystem
```

We may also need:

```text
Location
Reservation
PricingStrategy
```

For a beginner-friendly design, we can start with:

```text
RentalSystem
    |
    +-- Customer
    |
    +-- Car
    |
    +-- Rental
    |
    +-- Payment
    |
    +-- PricingStrategy
```

---

# 4. Car

A car should contain information about itself.

For example:

```text
Car
 |
 +-- id
 +-- registrationNumber
 +-- model
 +-- brand
 +-- carType
 +-- pricePerDay
 +-- status
```

The car should also know whether it is available.

---

# 5. Car Type

Different cars can have different categories.

For example:

```java
public enum CarType {
    SEDAN,
    SUV,
    HATCHBACK,
    LUXURY,
    SPORTS
}
```

---

# 6. Car Status

A car can be in different states.

```java
public enum CarStatus {
    AVAILABLE,
    RESERVED,
    RENTED,
    MAINTENANCE
}
```

For example:

```text
Car 101

AVAILABLE
   |
   | Reservation
   v
RESERVED
   |
   | Pick up
   v
RENTED
   |
   | Return
   v
AVAILABLE
```

---

# 7. Customer

A customer represents the person renting a car.

```text
Customer
    |
    +-- id
    +-- name
    +-- email
    +-- phoneNumber
    +-- drivingLicenseNumber
```

Java:

```java
public class Customer {

    private int id;
    private String name;
    private String email;
    private String phoneNumber;
    private String drivingLicenseNumber;

    public Customer(
            int id,
            String name,
            String email,
            String phoneNumber,
            String drivingLicenseNumber) {

        this.id = id;
        this.name = name;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.drivingLicenseNumber = drivingLicenseNumber;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getEmail() {
        return email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public String getDrivingLicenseNumber() {
        return drivingLicenseNumber;
    }
}
```

---

# 8. Car Class

Now let's create the main `Car` class.

```java
public class Car {

    private int id;
    private String registrationNumber;
    private String brand;
    private String model;

    private CarType carType;
    private CarStatus status;

    private double pricePerDay;

    public Car(
            int id,
            String registrationNumber,
            String brand,
            String model,
            CarType carType,
            double pricePerDay) {

        this.id = id;
        this.registrationNumber = registrationNumber;
        this.brand = brand;
        this.model = model;
        this.carType = carType;
        this.pricePerDay = pricePerDay;
        this.status = CarStatus.AVAILABLE;
    }

    public boolean isAvailable() {
        return status == CarStatus.AVAILABLE;
    }

    public void reserve() {
        if (!isAvailable()) {
            throw new IllegalStateException(
                    "Car is not available"
            );
        }

        status = CarStatus.RESERVED;
    }

    public void rent() {
        if (status != CarStatus.RESERVED) {
            throw new IllegalStateException(
                    "Car must be reserved before renting"
            );
        }

        status = CarStatus.RENTED;
    }

    public void returnCar() {
        status = CarStatus.AVAILABLE;
    }

    public int getId() {
        return id;
    }

    public String getRegistrationNumber() {
        return registrationNumber;
    }

    public String getBrand() {
        return brand;
    }

    public String getModel() {
        return model;
    }

    public CarType getCarType() {
        return carType;
    }

    public CarStatus getStatus() {
        return status;
    }

    public double getPricePerDay() {
        return pricePerDay;
    }
}
```

---

# 9. Why Does Car Have `reserve()` and `rent()`?

This is an important LLD concept.

We could write:

```java
car.status = CarStatus.RENTED;
```

from anywhere.

But that's bad design because anyone could put the car into an invalid state.

For example:

```text
AVAILABLE
   |
   | directly set RENTED
   v
RENTED
```

This bypasses business rules.

Instead:

```java
car.reserve();
car.rent();
```

The `Car` class controls its own state transitions.

This follows the idea:

> **An object should control its own state and behavior.**

---

# 10. Rental

Now we need an object representing an actual rental transaction.

A rental contains:

```text
Rental
 |
 +-- rentalId
 +-- customer
 +-- car
 +-- startDate
 +-- endDate
 +-- amount
 +-- status
```

---

# 11. Rental Status

```java
public enum RentalStatus {
    CREATED,
    ACTIVE,
    COMPLETED,
    CANCELLED
}
```

Flow:

```text
CREATED
   |
   | Pick up
   v
ACTIVE
   |
   | Return
   v
COMPLETED
```

---

# 12. Rental Class

```java
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class Rental {

    private int rentalId;
    private Customer customer;
    private Car car;

    private LocalDate startDate;
    private LocalDate endDate;

    private double amount;

    private RentalStatus status;

    public Rental(
            int rentalId,
            Customer customer,
            Car car,
            LocalDate startDate,
            LocalDate endDate) {

        if (endDate.isBefore(startDate)) {
            throw new IllegalArgumentException(
                    "End date cannot be before start date"
            );
        }

        this.rentalId = rentalId;
        this.customer = customer;
        this.car = car;
        this.startDate = startDate;
        this.endDate = endDate;

        this.status = RentalStatus.CREATED;
    }

    public long getRentalDays() {

        long days = ChronoUnit.DAYS.between(
                startDate,
                endDate
        );

        // Minimum one rental day
        return Math.max(days, 1);
    }

    public void startRental() {

        if (status != RentalStatus.CREATED) {
            throw new IllegalStateException(
                    "Rental cannot be started"
            );
        }

        car.rent();
        status = RentalStatus.ACTIVE;
    }

    public void completeRental() {

        if (status != RentalStatus.ACTIVE) {
            throw new IllegalStateException(
                    "Rental is not active"
            );
        }

        car.returnCar();
        status = RentalStatus.COMPLETED;
    }

    public int getRentalId() {
        return rentalId;
    }

    public Customer getCustomer() {
        return customer;
    }

    public Car getCar() {
        return car;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public double getAmount() {
        return amount;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public RentalStatus getStatus() {
        return status;
    }
}
```

---

# 13. Payment

The customer needs to pay for the rental.

We can create:

```text
Payment
 |
 +-- paymentId
 +-- amount
 +-- paymentMethod
 +-- paymentStatus
```

---

# 14. Payment Method

```java
public enum PaymentMethod {
    CASH,
    CREDIT_CARD,
    DEBIT_CARD,
    UPI
}
```

---

# 15. Payment Status

```java
public enum PaymentStatus {
    PENDING,
    SUCCESS,
    FAILED
}
```

---

# 16. Payment Class

```java
public class Payment {

    private int paymentId;
    private double amount;
    private PaymentMethod paymentMethod;
    private PaymentStatus status;

    public Payment(
            int paymentId,
            double amount,
            PaymentMethod paymentMethod) {

        this.paymentId = paymentId;
        this.amount = amount;
        this.paymentMethod = paymentMethod;
        this.status = PaymentStatus.PENDING;
    }

    public void processPayment() {

        // In a real system, payment gateway
        // integration would happen here.

        status = PaymentStatus.SUCCESS;
    }

    public int getPaymentId() {
        return paymentId;
    }

    public double getAmount() {
        return amount;
    }

    public PaymentMethod getPaymentMethod() {
        return paymentMethod;
    }

    public PaymentStatus getStatus() {
        return status;
    }
}
```

---

# 17. Pricing Problem

Now we encounter an important LLD question.

Suppose today pricing is:

```text
Car price × number of days
```

Tomorrow business says:

```text
SUV gets 10% discount
Luxury cars have 20% additional charge
Weekend pricing is different
Long-term rentals get discounts
```

If we put all this logic inside `Rental`, the class becomes complicated.

Bad design:

```java
if (carType == SUV) {
    ...
} else if (carType == LUXURY) {
    ...
} else if (...) {
    ...
}
```

Instead, pricing is a **changeable behavior**.

This is a good candidate for the:

# Strategy Pattern

---

# 18. Pricing Strategy

Create an interface:

```java
public interface PricingStrategy {

    double calculatePrice(
            Car car,
            long rentalDays
    );
}
```

Now we can create different strategies.

---

# 19. Basic Pricing Strategy

```java
public class BasicPricingStrategy
        implements PricingStrategy {

    @Override
    public double calculatePrice(
            Car car,
            long rentalDays) {

        return car.getPricePerDay() * rentalDays;
    }
}
```

---

# 20. Discount Pricing Strategy

For example, give a 10% discount for rentals of 7+ days.

```java
public class LongTermPricingStrategy
        implements PricingStrategy {

    @Override
    public double calculatePrice(
            Car car,
            long rentalDays) {

        double price =
                car.getPricePerDay() * rentalDays;

        if (rentalDays >= 7) {
            price = price * 0.90;
        }

        return price;
    }
}
```

Now the pricing logic can change without modifying `Rental`.

---

# 21. Rental System

Now we need a class that coordinates the entire system.

```text
RentalSystem
 |
 +-- cars
 +-- customers
 +-- rentals
 +-- pricingStrategy
```

Its responsibilities:

- Add cars
- Add customers
- Search cars
- Create rental
- Calculate price
- Start rental
- Complete rental
- Process payment

---

# 22. RentalSystem Class

```java
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class RentalSystem {

    private List<Car> cars;
    private List<Customer> customers;
    private List<Rental> rentals;

    private PricingStrategy pricingStrategy;

    public RentalSystem(
            PricingStrategy pricingStrategy) {

        this.cars = new ArrayList<>();
        this.customers = new ArrayList<>();
        this.rentals = new ArrayList<>();
        this.pricingStrategy = pricingStrategy;
    }

    public void addCar(Car car) {
        cars.add(car);
    }

    public void addCustomer(Customer customer) {
        customers.add(customer);
    }

    public List<Car> searchAvailableCars(
            CarType carType) {

        List<Car> result = new ArrayList<>();

        for (Car car : cars) {

            if (car.isAvailable()
                    && car.getCarType() == carType) {

                result.add(car);
            }
        }

        return result;
    }

    public Rental createRental(
            int rentalId,
            Customer customer,
            Car car,
            LocalDate startDate,
            LocalDate endDate) {

        if (!car.isAvailable()) {
            throw new IllegalStateException(
                    "Car is not available"
            );
        }

        car.reserve();

        Rental rental = new Rental(
                rentalId,
                customer,
                car,
                startDate,
                endDate
        );

        double amount =
                pricingStrategy.calculatePrice(
                        car,
                        rental.getRentalDays()
                );

        rental.setAmount(amount);

        rentals.add(rental);

        return rental;
    }

    public void startRental(Rental rental) {
        rental.startRental();
    }

    public void completeRental(Rental rental) {
        rental.completeRental();
    }
}
```

---

# 23. Main Class

Let's see how the system is used.

```java
import java.time.LocalDate;

public class Main {

    public static void main(String[] args) {

        PricingStrategy pricingStrategy =
                new BasicPricingStrategy();

        RentalSystem rentalSystem =
                new RentalSystem(pricingStrategy);

        // Create cars

        Car car1 = new Car(
                1,
                "MH01AB1234",
                "Toyota",
                "Camry",
                CarType.SEDAN,
                3000
        );

        Car car2 = new Car(
                2,
                "MH01CD5678",
                "Hyundai",
                "Creta",
                CarType.SUV,
                4000
        );

        rentalSystem.addCar(car1);
        rentalSystem.addCar(car2);

        // Create customer

        Customer customer = new Customer(
                101,
                "Rahul",
                "rahul@example.com",
                "9999999999",
                "DL123456"
        );

        rentalSystem.addCustomer(customer);

        // Search cars

        System.out.println(
                rentalSystem.searchAvailableCars(
                        CarType.SEDAN
                )
        );

        // Create rental

        Rental rental =
                rentalSystem.createRental(
                        1001,
                        customer,
                        car1,
                        LocalDate.of(2026, 9, 10),
                        LocalDate.of(2026, 9, 13)
                );

        System.out.println(
                "Rental amount = " +
                rental.getAmount()
        );

        // Start rental

        rentalSystem.startRental(rental);

        // Return car

        rentalSystem.completeRental(rental);
    }
}
```

---

# 24. Class Relationships

Let's understand the relationships.

```text
                    +------------------+
                    |   RentalSystem   |
                    +------------------+
                    | - cars           |
                    | - customers      |
                    | - rentals        |
                    | - pricingStrategy|
                    +--------+---------+
                             |
              +--------------+--------------+
              |              |              |
              v              v              v
           +------+      +----------+    +--------+
           | Car  |      | Customer |    | Rental |
           +------+      +----------+    +---+----+
                                             |
                              +--------------+--------------+
                              |                             |
                              v                             v
                           Customer                         Car


                    +---------------------+
                    |  PricingStrategy    |
                    +---------------------+
                    | + calculatePrice()  |
                    +----------+----------+
                               |
                +--------------+--------------+
                |                             |
                v                             v
      +---------------------+       +----------------------+
      | BasicPricing        |       | LongTermPricing      |
      | Strategy            |       | Strategy             |
      +---------------------+       +----------------------+
```

---

# 25. Complete Class Diagram

```text
+------------------------------------------------+
|                 RentalSystem                   |
+------------------------------------------------+
| - cars: List<Car>                              |
| - customers: List<Customer>                   |
| - rentals: List<Rental>                       |
| - pricingStrategy: PricingStrategy             |
+------------------------------------------------+
| + addCar()                                     |
| + addCustomer()                                |
| + searchAvailableCars()                        |
| + createRental()                               |
| + startRental()                                |
| + completeRental()                             |
+-------------------------+----------------------+
                          |
                          | HAS MANY
                          v
                    +-----------+
                    |    Car    |
                    +-----------+
                    | id        |
                    | model     |
                    | brand     |
                    | carType   |
                    | status    |
                    | price/day |
                    +-----------+
                          |
                          | HAS-A
                          v
                    CarStatus


+---------------------+
|      Customer       |
+---------------------+
| id                  |
| name                |
| email               |
| phoneNumber         |
| drivingLicense      |
+---------------------+


+---------------------+
|       Rental        |
+---------------------+
| rentalId            |
| customer            |
| car                 |
| startDate           |
| endDate             |
| amount              |
| status              |
+---------------------+


              +-------------------------+
              |    PricingStrategy      |
              +-------------------------+
              | + calculatePrice()     |
              +------------+------------+
                           |
                  implements
                           |
              +------------+-------------+
              |                          |
              v                          v
   +---------------------+    +---------------------+
   | BasicPricing        |    | LongTermPricing     |
   | Strategy            |    | Strategy            |
   +---------------------+    +---------------------+
```

---

# 26. Complete Flow

Suppose Rahul wants to rent a Toyota Camry for 3 days.

### Step 1 — Customer searches

```java
rentalSystem.searchAvailableCars(CarType.SEDAN);
```

System finds:

```text
Car 1
Toyota Camry
₹3000/day
AVAILABLE
```

---

### Step 2 — Customer selects the car

```text
Customer
   |
   v
Toyota Camry
```

---

### Step 3 — Create rental

```java
Rental rental = rentalSystem.createRental(
    1001,
    customer,
    car,
    startDate,
    endDate
);
```

The car changes:

```text
AVAILABLE
     |
     v
RESERVED
```

---

### Step 4 — Calculate price

```text
₹3000/day × 3 days
```

Therefore:

```text
₹9000
```

---

### Step 5 — Start rental

```java
rentalSystem.startRental(rental);
```

Car:

```text
RESERVED
    |
    v
RENTED
```

Rental:

```text
CREATED
    |
    v
ACTIVE
```

---

### Step 6 — Customer returns car

```java
rentalSystem.completeRental(rental);
```

Car:

```text
RENTED
   |
   v
AVAILABLE
```

Rental:

```text
ACTIVE
   |
   v
COMPLETED
```

---

# 27. Why Do We Need `Rental`?

A beginner might ask:

> Why not just put customer and dates inside `Car`?

Because one car can have **many rentals over its lifetime**.

For example:

```text
Car #101

Rental #1
Jan 1 → Jan 5
Customer A

Rental #2
Jan 10 → Jan 15
Customer B

Rental #3
Feb 1 → Feb 7
Customer C
```

Therefore:

```text
Car 1
 |
 +---- Rental 1
 |
 +---- Rental 2
 |
 +---- Rental 3
```

`Rental` represents a **transaction/history**, while `Car` represents the actual vehicle.

This is an important separation of responsibilities.

---

# 28. Why Strategy Pattern?

Pricing is likely to change.

Today:

```text
price = pricePerDay × days
```

Tomorrow:

```text
weekend price
holiday price
long-term discount
premium car pricing
corporate discount
```

Instead of:

```java
if (...)
else if (...)
else if (...)
```

we use:

```java
PricingStrategy
```

Then:

```text
RentalSystem
      |
      v
PricingStrategy
      |
      +---- BasicPricingStrategy
      |
      +---- LongTermPricingStrategy
      |
      +---- WeekendPricingStrategy
      |
      +---- PremiumPricingStrategy
```

This follows:

### Open/Closed Principle

The system is open for adding new pricing strategies without modifying the core rental logic.

---

# 29. SOLID Principles

## Single Responsibility Principle

Each class has a clear responsibility.

```text
Car
 → Car information + car state

Customer
 → Customer information

Rental
 → Rental transaction

Payment
 → Payment information/processing

RentalSystem
 → Coordinate rental operations

PricingStrategy
 → Calculate rental price
```

---

## Open/Closed Principle

We can add:

```java
WeekendPricingStrategy
```

without modifying:

```java
Rental
```

or:

```java
Car
```

---

## Dependency Inversion Principle

`RentalSystem` depends on:

```java
PricingStrategy
```

instead of:

```java
BasicPricingStrategy
```

This is good:

```java
private PricingStrategy pricingStrategy;
```

rather than:

```java
private BasicPricingStrategy pricingStrategy;
```

---

# 30. What About Payment?

We can also apply Strategy Pattern to payment.

Create:

```java
public interface PaymentProcessor {

    void pay(double amount);
}
```

Then:

```java
public class CashPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {
        System.out.println(
                "Paid using cash: " + amount
        );
    }
}
```

And:

```java
public class CardPaymentProcessor
        implements PaymentProcessor {

    @Override
    public void pay(double amount) {
        System.out.println(
                "Paid using card: " + amount
        );
    }
}
```

We could also have:

```text
PaymentProcessor
       |
       +---- CashPaymentProcessor
       |
       +---- CardPaymentProcessor
       |
       +---- UPIPaymentProcessor
```

Again, we don't need to use a design pattern unless the behavior is expected to vary.

---

# 31. Important Interview Question: What if Two Customers Try to Rent the Same Car?

This is a **concurrency problem**.

Imagine:

```text
Customer A                Customer B
    |                         |
    | Check car available     |
    |                         |
    +-------- AVAILABLE ------+
    |                         |
    | Reserve                 | Reserve
    v                         v
```

Both might see:

```text
AVAILABLE
```

and both could try to reserve it.

We need the reservation operation to be **atomic**.

In a multithreaded Java application, we could protect the operation using synchronization/locking, while in a real production system the database transaction would usually be the final authority.

Conceptually:

```java
public synchronized void reserve() {

    if (status != CarStatus.AVAILABLE) {
        throw new IllegalStateException(
                "Car is already reserved"
        );
    }

    status = CarStatus.RESERVED;
}
```

For a real distributed system, application-level `synchronized` alone is not enough; we would use transactional database locking or an equivalent concurrency-control mechanism.

---

# 32. Important Interview Question: What If Customer Cancels?

We can add:

```java
public void cancelRental() {

    if (status != RentalStatus.CREATED) {
        throw new IllegalStateException(
                "Rental cannot be cancelled"
        );
    }

    car.returnCar();
    status = RentalStatus.CANCELLED;
}
```

Flow:

```text
AVAILABLE
    |
    v
RESERVED
    |
    | Cancel
    v
AVAILABLE
```

Rental:

```text
CREATED
    |
    | Cancel
    v
CANCELLED
```

---

# 33. Important Interview Question: What If the Car Goes for Maintenance?

We already have:

```java
MAINTENANCE
```

So:

```text
AVAILABLE
    |
    | Maintenance
    v
MAINTENANCE
    |
    | Repair complete
    v
AVAILABLE
```

Search should only return:

```java
car.isAvailable()
```

Therefore maintenance cars won't appear.

---

# 34. What If We Have Multiple Rental Locations?

Now the requirements become more realistic.

A car can belong to a location.

For example:

```text
Location
 |
 +-- id
 +-- name
 +-- address
```

Then:

```text
Mumbai Airport
    |
    +-- Car 1
    +-- Car 2
    +-- Car 3

Mumbai Station
    |
    +-- Car 4
    +-- Car 5
```

Customer can search:

```text
Pickup Location
Return Location
```

For example:

```text
Pickup:
Mumbai Airport

Return:
Mumbai Station
```

This introduces another concept:

```text
Rental
 |
 +-- pickupLocation
 +-- returnLocation
```

---

# 35. Location Class

```java
public class Location {

    private int id;
    private String name;
    private String address;

    public Location(
            int id,
            String name,
            String address) {

        this.id = id;
        this.name = name;
        this.address = address;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getAddress() {
        return address;
    }
}
```

Then `Car` can have:

```java
private Location location;
```

---

# 36. Reservation vs Rental

This is an important design decision.

Are these the same thing?

Not necessarily.

### Reservation

Customer says:

> I want this car tomorrow.

```text
RESERVED
```

### Rental

Customer actually picks up the car.

```text
RENTED
```

Therefore we can model them separately:

```text
Reservation
    |
    +-- customer
    +-- car
    +-- startDate
    +-- endDate
    +-- status
```

and:

```text
Rental
    |
    +-- customer
    +-- car
    +-- pickupDate
    +-- returnDate
    +-- amount
```

For a simple LLD interview, combining them into `Rental` can be acceptable if the requirements don't distinguish booking from actual rental.

For a more realistic system, keeping them separate is cleaner.

---

# 37. Better Architecture

For a more interview-ready design, we can separate responsibilities:

```text
                  +--------------------+
                  |   RentalSystem     |
                  +---------+----------+
                            |
                            v
                  +--------------------+
                  | RentalService      |
                  +---------+----------+
                            |
            +---------------+---------------+
            |               |               |
            v               v               v
       CarRepository   RentalRepository  PaymentService
            |               |               |
            v               v               v
          Cars            Rentals         Payments
```

This is closer to what we might see in a real application.

However:

> **Don't introduce repositories/services just to make the diagram bigger.**

For a basic LLD interview, the simpler design is often better.

---

# 38. Recommended Interview-Level Design

For an interview, I would start with these classes:

```text
Car
Customer
Rental
Payment
Location
RentalSystem
PricingStrategy
```

Enums:

```text
CarType
CarStatus
RentalStatus
PaymentMethod
PaymentStatus
```

Interfaces:

```text
PricingStrategy
PaymentProcessor
```

Then add complexity only if the interviewer asks.

---

# 39. Package Structure

A clean Java project could look like:

```text
src/
│
├── model/
│   ├── Car.java
│   ├── Customer.java
│   ├── Rental.java
│   ├── Payment.java
│   └── Location.java
│
├── enums/
│   ├── CarType.java
│   ├── CarStatus.java
│   ├── RentalStatus.java
│   ├── PaymentMethod.java
│   └── PaymentStatus.java
│
├── strategy/
│   ├── PricingStrategy.java
│   ├── BasicPricingStrategy.java
│   └── LongTermPricingStrategy.java
│
├── service/
│   └── RentalSystem.java
│
└── Main.java
```

---

# 40. Design Patterns Used

We don't want to force design patterns.

The useful ones here are:

### 1. Strategy Pattern

Used for:

```text
Pricing
```

Potentially also:

```text
Payment
```

because the algorithm/behavior can vary.

### 2. State Pattern — Optional

If `CarStatus` becomes complicated:

```text
AVAILABLE
RESERVED
RENTED
MAINTENANCE
DAMAGED
```

and each state has different behavior, we could replace the enum-based approach with the State Pattern.

But for a basic interview:

```java
enum CarStatus
```

is enough.

### 3. Factory Pattern — Optional

If car creation becomes complicated:

```text
CarFactory
```

could create:

```text
Sedan
SUV
LuxuryCar
```

But don't introduce it unnecessarily.

---

# 41. Common Mistakes

## Mistake 1 — One giant class

Bad:

```text
RentalSystem

+ search
+ payment
+ pricing
+ car management
+ customer management
+ notifications
+ invoice
+ maintenance
```

This violates SRP.

---

## Mistake 2 — Putting pricing inside Car

Bad:

```java
car.calculateRentalPrice();
```

The car shouldn't necessarily know business pricing rules.

Better:

```text
PricingStrategy
```

handles pricing.

---

## Mistake 3 — Using many `if-else`

Bad:

```java
if (paymentMethod == CASH) {
    ...
}
else if (paymentMethod == CARD) {
    ...
}
else if (paymentMethod == UPI) {
    ...
}
```

If payment behavior is expected to grow, use:

```text
PaymentProcessor
```

with different implementations.

---

## Mistake 4 — Overengineering

Don't immediately create:

```text
Factory
AbstractFactory
Builder
Observer
Command
State
Strategy
Repository
Service
Controller
DAO
```

before understanding the requirements.

Start simple.

Then identify **what is changing**.

---

# 42. Interview Approach

When the interviewer says:

> Design a Car Rental System.

Don't immediately start coding.

Start with:

### Step 1 — Clarify requirements

Say:

> "I'll assume customers can search available cars, select a car, reserve it for a date range, make a payment, pick up the car, and return it."

Then ask:

```text
Do we support multiple locations?
Do we support different car types?
Can customers cancel?
Are pricing rules different?
Do we need payment support?
Can cars be returned to another location?
```

---

### Step 2 — Identify entities

Say:

> "The main entities I see are Car, Customer, Rental, Payment and Location."

---

### Step 3 — Define responsibilities

```text
Car
→ vehicle state

Customer
→ customer information

Rental
→ rental transaction

Payment
→ payment

RentalSystem
→ orchestration

PricingStrategy
→ pricing calculation
```

---

### Step 4 — Identify changing behavior

Ask:

> "Pricing can change independently of the rental flow, so I would use a Strategy Pattern for pricing."

---

### Step 5 — Draw relationships

```text
RentalSystem
    |
    +---- Car
    |
    +---- Customer
    |
    +---- Rental
    |
    +---- PricingStrategy
```

---

### Step 6 — Write code

Only after the design is clear.

---

# 43. Final Mental Model

When solving an LLD problem, think like this:

```text
             REQUIREMENTS
                   |
                   v
          Identify the objects
                   |
                   v
          Identify responsibilities
                   |
                   v
          Define relationships
                   |
                   v
       What behavior is changing?
                   |
                   v
       Create an abstraction
                   |
                   v
          Apply design pattern
                   |
                   v
          Handle edge cases
                   |
                   v
               Write code
```

For Car Rental:

```text
Requirement
     |
     v
Car + Customer + Rental + Payment
     |
     v
Car manages its state
Rental manages rental transaction
Payment manages payment
RentalSystem coordinates everything
     |
     v
Pricing can change
     |
     v
PricingStrategy
     |
     +---- BasicPricingStrategy
     +---- LongTermPricingStrategy
     +---- WeekendPricingStrategy
```

# 44. Final Design Summary

```text
+---------------------------------------------------+
|                  RentalSystem                     |
+---------------------------------------------------+
| - cars                                            |
| - customers                                       |
| - rentals                                         |
| - pricingStrategy                                 |
+---------------------------------------------------+
| + searchAvailableCars()                           |
| + createRental()                                  |
| + startRental()                                   |
| + completeRental()                                |
+---------------------------------------------------+
            |               |               |
            v               v               v
        +-------+      +----------+     +---------+
        |  Car  |      | Customer |     | Rental  |
        +-------+      +----------+     +---------+
            |                               |
            |                               |
            +-------------------------------+
                            |
                            v
                       +---------+
                       | Payment |
                       +---------+


              +-----------------------+
              |   PricingStrategy     |
              +-----------------------+
              | + calculatePrice()    |
              +-----------+-----------+
                          |
              +-----------+-----------+
              |                       |
              v                       v
      BasicPricingStrategy    LongTermPricingStrategy
```

The **core idea** is:

> `RentalSystem` coordinates the workflow, `Car` owns car state, `Rental` represents the transaction, and `PricingStrategy` isolates pricing rules that are likely to change.