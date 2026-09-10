# What are the Four Pillars of OOP?

The four commonly cited pillars of Object-Oriented Programming (OOP) are:

1. **Encapsulation**
2. **Inheritance**
3. **Polymorphism**
4. **Abstraction**

---

# 1. Encapsulation

### What is Encapsulation?

**Encapsulation means wrapping data and methods together inside a class and controlling access to the data.**

In Java, we commonly achieve encapsulation by:

- Making fields `private`
- Providing `public` getters/setters or controlled methods

### Example

```java
class Employee {

    private String name;
    private double salary;

    public void setName(String name) {
        this.name = name;
    }

    public String getName() {
        return name;
    }

    public void setSalary(double salary) {
        if (salary > 0) {
            this.salary = salary;
        }
    }

    public double getSalary() {
        return salary;
    }
}
```

Usage:

```java
public class Main {
    public static void main(String[] args) {

        Employee emp = new Employee();

        emp.setName("Rahul");
        emp.setSalary(50000);

        System.out.println(emp.getName());
        System.out.println(emp.getSalary());
    }
}
```

### Why do we use Encapsulation?

It provides:

- **Data protection**
- **Controlled access**
- **Validation**
- **Maintainability**

For example, instead of allowing:

```java
emp.salary = -5000;
```

we control it through:

```java
setSalary(50000);
```

and can prevent invalid values.

### Interview Answer

> **Encapsulation is the process of hiding an object's internal data and providing controlled access to it through methods. In Java, it is commonly achieved using private fields and public methods such as getters and setters.**

---

# 2. Inheritance

### What is Inheritance?

**Inheritance allows one class to acquire the properties and behavior of another class.**

We use the `extends` keyword.

The existing class is called the:

- **Parent / Superclass**

The new class is called the:

- **Child / Subclass**

### Example

```java
class Animal {

    void eat() {
        System.out.println("Animal is eating");
    }
}

class Dog extends Animal {

    void bark() {
        System.out.println("Dog is barking");
    }
}
```

Usage:

```java
public class Main {
    public static void main(String[] args) {

        Dog dog = new Dog();

        dog.eat();   // inherited method
        dog.bark(); // own method
    }
}
```

Output:

```text
Animal is eating
Dog is barking
```

The `Dog` class automatically gets the `eat()` method from `Animal`.

### Real-world example

```text
Animal
   |
   +-- Dog
   |
   +-- Cat
   |
   +-- Horse
```

All animals may have common behavior such as:

```java
eat()
sleep()
```

while each child can have its own behavior:

```java
Dog  -> bark()
Cat  -> meow()
Horse -> run()
```

### Why do we use Inheritance?

Mainly for:

- Code reuse
- Establishing an IS-A relationship
- Supporting method overriding
- Supporting runtime polymorphism

### Interview Answer

> **Inheritance is a mechanism where a child class acquires properties and methods of a parent class. In Java, it is achieved using the `extends` keyword and promotes code reuse.**

---

# 3. Polymorphism

### What is Polymorphism?

**Polymorphism means "one name, many forms."**

The same method name can behave differently depending on the situation.

Java mainly has two types:

1. **Compile-time polymorphism**
2. **Runtime polymorphism**

---

## A. Compile-Time Polymorphism

It is mainly achieved through **method overloading**.

Same method name but different parameters.

### Example

```java
class Calculator {

    int add(int a, int b) {
        return a + b;
    }

    int add(int a, int b, int c) {
        return a + b + c;
    }

    double add(double a, double b) {
        return a + b;
    }
}
```

Usage:

```java
Calculator calculator = new Calculator();

System.out.println(calculator.add(10, 20));
System.out.println(calculator.add(10, 20, 30));
System.out.println(calculator.add(10.5, 20.5));
```

Output:

```text
30
60
31.0
```

The compiler decides which `add()` method should be called.

Therefore:

```text
Method Overloading
        ↓
Compile-time polymorphism
```

---

## B. Runtime Polymorphism

It is mainly achieved through **method overriding**.

A parent reference can refer to a child object.

### Example

```java
class Animal {

    void sound() {
        System.out.println("Animal makes sound");
    }
}

class Dog extends Animal {

    @Override
    void sound() {
        System.out.println("Dog barks");
    }
}

class Cat extends Animal {

    @Override
    void sound() {
        System.out.println("Cat meows");
    }
}
```

Usage:

```java
public class Main {

    public static void main(String[] args) {

        Animal animal;

        animal = new Dog();
        animal.sound();

        animal = new Cat();
        animal.sound();
    }
}
```

Output:

```text
Dog barks
Cat meows
```

Here:

```java
Animal animal = new Dog();
```

The reference type is:

```text
Animal
```

but the actual object is:

```text
Dog
```

Therefore Java decides at runtime which overridden method to execute.

### Interview Answer

> **Polymorphism means one interface or method name can have multiple forms. In Java, method overloading provides compile-time polymorphism, while method overriding provides runtime polymorphism.**

---

# 4. Abstraction

### What is Abstraction?

**Abstraction means hiding implementation details and exposing only the essential functionality.**

In Java, abstraction is mainly achieved using:

- `abstract` classes
- `interfaces`

### Example using Abstract Class

```java
abstract class Vehicle {

    abstract void start();

    void stop() {
        System.out.println("Vehicle stopped");
    }
}
```

Child class:

```java
class Car extends Vehicle {

    @Override
    void start() {
        System.out.println("Car starts using key");
    }
}
```

Usage:

```java
public class Main {

    public static void main(String[] args) {

        Vehicle vehicle = new Car();

        vehicle.start();
        vehicle.stop();
    }
}
```

Output:

```text
Car starts using key
Vehicle stopped
```

The user knows:

```java
vehicle.start();
```

but doesn't need to know all the internal details of how the car starts.

### Real-world example

When you use an ATM:

```text
Insert Card
     ↓
Enter PIN
     ↓
Select Withdraw
     ↓
Receive Money
```

You don't need to know the internal implementation of:

- database communication
- account validation
- transaction processing
- cash dispenser mechanism

That is **abstraction**.

### Interview Answer

> **Abstraction means hiding implementation details and exposing only the required functionality. In Java, abstraction is mainly achieved using abstract classes and interfaces.**

---

# Four Pillars — Quick Comparison

| Pillar | Meaning | Common Java Feature |
|---|---|---|
| Encapsulation | Hide and protect data | `private`, getters/setters |
| Inheritance | Reuse parent functionality | `extends` |
| Polymorphism | One name, multiple behaviors | Overloading/Overriding |
| Abstraction | Hide implementation details | `abstract`, `interface` |

---

# Easy Way to Remember

```text
ENCAPSULATION
     ↓
Protect the data

INHERITANCE
     ↓
Reuse the code

POLYMORPHISM
     ↓
Different behavior

ABSTRACTION
     ↓
Hide implementation
```

---

# One Real-World Example Combining All Four

Consider a banking system.

### 1. Encapsulation

```java
class BankAccount {

    private double balance;

    public double getBalance() {
        return balance;
    }

    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }
}
```

`balance` is protected using `private`.

---

### 2. Inheritance

```java
class SavingsAccount extends BankAccount {

    void addInterest() {
        System.out.println("Adding interest");
    }
}
```

`SavingsAccount` inherits from `BankAccount`.

---

### 3. Polymorphism

```java
class BankAccount {

    void calculateInterest() {
        System.out.println("Normal interest");
    }
}

class SavingsAccount extends BankAccount {

    @Override
    void calculateInterest() {
        System.out.println("Savings account interest");
    }
}
```

Different account types can provide different implementations.

---

### 4. Abstraction

```java
abstract class BankAccount {

    abstract void calculateInterest();
}
```

The parent defines **what** should happen, while the child defines **how** it happens.

---

# ⭐ Best Interview Answer

If the interviewer asks:

**"What are the four pillars of OOP?"**

You can answer:

> **The four pillars of OOP are Encapsulation, Inheritance, Polymorphism, and Abstraction. Encapsulation protects and controls access to data. Inheritance allows a child class to reuse functionality from a parent class. Polymorphism allows the same method or interface to have different behaviors, mainly through overloading and overriding. Abstraction hides implementation details and exposes only the required functionality, typically using abstract classes and interfaces in Java.**

### One-line version

```text
Encapsulation → Data hiding/protection
Inheritance   → Code reuse
Polymorphism  → Many forms/behaviors
Abstraction   → Hide implementation details
```