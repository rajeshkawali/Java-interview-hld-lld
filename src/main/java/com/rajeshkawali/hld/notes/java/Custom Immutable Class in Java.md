# Custom Immutable Class in Java

## 1. What is an Immutable Class?

An **immutable class** is a class whose object state **cannot be changed after the object is created**.

For example, `String` is immutable.

```java
String name = "John";

name = name.concat(" Smith");
```

The original `"John"` object is not modified.

A new `String` object is created:

```text
"John"
   ↓
concat()
   ↓
"John Smith"  ← new object
```

Similarly, an immutable custom class should behave like this:

```java
Employee employee = new Employee(101, "John");

employee.setName("Bob");   // should not be possible
```

Once the object is created:

```text
Employee
---------
id   = 101
name = John
```

that state should remain unchanged.

---

# 2. Why Do We Need Immutable Classes?

Immutable objects provide several advantages.

### 1. Thread safety

Immutable objects can safely be shared between threads because their state cannot change.

### 2. Easier reasoning

You do not have to worry about someone changing an object's state unexpectedly.

### 3. Safe HashMap keys

Immutable objects are excellent candidates for keys in:

```java
HashMap
HashSet
ConcurrentHashMap
```

because their fields used by `hashCode()` cannot change after insertion.

### 4. Caching

Immutable objects can safely be cached and reused.

### 5. Security

If an object represents important configuration or security-related state, preventing modification can be valuable.

---

# 3. Basic Rules for Creating an Immutable Class

A commonly used checklist is:

```text
1. Make the class final
2. Make all fields private
3. Make all fields final
4. Initialize fields through constructor
5. Do not provide setters
6. Do not expose mutable objects directly
7. Perform defensive copies of mutable inputs
8. Return defensive copies of mutable fields
9. Be careful with inheritance
10. Be careful with arrays and collections
11. Handle serialization carefully
12. Keep equals() and hashCode() consistent
```

The most important rule is:

> **The object's observable state must not be changeable after construction.**

---

# 4. Simple Immutable Class

Let's start with a simple example.

```java
final class Employee {

    private final int id;
    private final String name;

    public Employee(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }
}
```

This class is immutable because:

```text
class cannot be extended
fields are private
fields are final
fields are initialized in constructor
no setters exist
String is immutable
int is primitive
```

Once created:

```java
Employee employee = new Employee(101, "John");
```

the state cannot be changed.

---

# 5. Why `private` Is Important

Consider:

```java
class Employee {

    public final int id;
}
```

Although `id` is final, exposing internal state publicly is generally bad encapsulation.

Prefer:

```java
private final int id;
```

and:

```java
public int getId() {
    return id;
}
```

The caller can read the value but cannot directly modify the field.

---

# 6. Why `final` Is Important

Consider:

```java
class Employee {

    private int id;

    public Employee(int id) {
        this.id = id;
    }
}
```

Because `id` is not final, some method could potentially modify it:

```java
this.id = 200;
```

For an immutable class, use:

```java
private final int id;
```

Now after construction:

```java
id = 101;
```

cannot be reassigned.

### Important

`final` does **not** automatically make an object immutable.

This is one of the most important interview points.

---

# 7. `final` Reference Does NOT Mean Immutable Object

Consider:

```java
private final List<String> skills;
```

Many candidates think this is immutable.

It is not.

`final` means:

> The reference cannot point to another list.

It does **not** mean:

> The list itself cannot change.

For example:

```java
skills.add("Java");
```

can still modify the list.

Conceptually:

```text
final reference
      |
      v
+-------------+
| ArrayList   |
| Java        |
| Spring      |
+-------------+
```

The reference cannot change:

```text
skills → anotherList   ❌
```

but the object can still change:

```text
skills.add(...)         ✅
```

Therefore:

```java
private final List<String> skills;
```

alone is not enough.

---

# 8. Defensive Copy — The Most Important Concept

Suppose our immutable class contains a mutable object.

```java
final class Employee {

    private final List<String> skills;

    public Employee(List<String> skills) {
        this.skills = skills;
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

This class is **not immutable**.

Why?

Because the caller still owns the original list.

```java
List<String> skills = new ArrayList<>();

skills.add("Java");

Employee employee = new Employee(skills);

skills.add("Spring");
```

Now the employee's internal state has changed:

```text
Before:
Employee.skills = [Java]

Caller modifies original list

After:
Employee.skills = [Java, Spring]
```

The caller changed the employee without calling any method on `Employee`.

That's a violation of immutability.

---

# 9. Fix: Defensive Copy in Constructor

Create a copy when receiving the mutable object.

```java
final class Employee {

    private final List<String> skills;

    public Employee(List<String> skills) {
        this.skills = new ArrayList<>(skills);
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

Now:

```java
List<String> skills = new ArrayList<>();

skills.add("Java");

Employee employee = new Employee(skills);

skills.add("Spring");
```

The employee still has:

```text
[Java]
```

because the constructor created its own copy.

Conceptually:

```text
Caller list
    |
    | copy
    v
Employee internal list
```

They are now different objects.

---

# 10. But There Is Still a Problem

We fixed the constructor.

But look at the getter:

```java
public List<String> getSkills() {
    return skills;
}
```

The caller can still modify the internal list:

```java
employee.getSkills().add("Spring");
```

Now the internal state changes.

So the class is still not immutable.

---

# 11. Defensive Copy in Getter

One solution is:

```java
public List<String> getSkills() {
    return new ArrayList<>(skills);
}
```

Now the caller gets a copy.

```text
Internal list
     |
     | copy
     v
Returned list
```

If the caller does:

```java
employee.getSkills().add("Spring");
```

only the returned copy changes.

The internal list remains unchanged.

---

# 12. Better Approach: Unmodifiable / Immutable View

Modern Java provides:

```java
List.copyOf()
```

For example:

```java
final class Employee {

    private final List<String> skills;

    public Employee(List<String> skills) {
        this.skills = List.copyOf(skills);
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

Now the internal list cannot be modified through the returned reference.

Trying:

```java
employee.getSkills().add("Spring");
```

will throw:

```text
UnsupportedOperationException
```

### Why is `List.copyOf()` useful?

It creates an **unmodifiable copy** of the supplied collection.

This is generally preferable to simply wrapping a mutable list when you want the immutable object's state to be isolated.

---

# 13. `Collections.unmodifiableList()` vs `List.copyOf()`

This is an important interview question.

### `Collections.unmodifiableList()`

```java
List<String> copy =
        Collections.unmodifiableList(skills);
```

This creates an unmodifiable **view** of the original list.

If the original list changes, the view can reflect those changes.

### `List.copyOf()`

```java
List<String> copy =
        List.copyOf(skills);
```

This creates an unmodifiable copy.

Conceptually:

```text
Collections.unmodifiableList()

Original list
     ↑
     |
unmodifiable view
```

The original list can still change.

Whereas:

```text
List.copyOf()

Original list
     |
     | copy
     v
Independent unmodifiable list
```

For immutable-class construction, `List.copyOf()` is often the cleaner choice.

---

# 14. Complete Immutable Class with Collection

A good implementation is:

```java
import java.util.List;

public final class Employee {

    private final int id;
    private final String name;
    private final List<String> skills;

    public Employee(int id, String name, List<String> skills) {
        this.id = id;
        this.name = name;
        this.skills = List.copyOf(skills);
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

Usage:

```java
List<String> skills = new ArrayList<>();

skills.add("Java");
skills.add("Spring");

Employee employee =
        new Employee(101, "John", skills);

skills.add("Hibernate");
```

The employee still has:

```text
[Java, Spring]
```

And:

```java
employee.getSkills().add("Hibernate");
```

is not allowed.

---

# 15. What About Arrays?

Arrays are mutable.

Consider:

```java
final class Employee {

    private final String[] skills;

    public Employee(String[] skills) {
        this.skills = skills;
    }

    public String[] getSkills() {
        return skills;
    }
}
```

This is NOT immutable.

The caller can do:

```java
String[] skills = {"Java", "Spring"};

Employee employee =
        new Employee(skills);

skills[0] = "Python";
```

The employee's internal state changes.

Also:

```java
employee.getSkills()[0] = "Python";
```

can modify internal state.

---

# 16. Defensive Copy for Arrays

Constructor:

```java
this.skills = skills.clone();
```

Getter:

```java
return skills.clone();
```

Complete example:

```java
public final class Employee {

    private final int id;
    private final String[] skills;

    public Employee(int id, String[] skills) {
        this.id = id;
        this.skills = skills.clone();
    }

    public int getId() {
        return id;
    }

    public String[] getSkills() {
        return skills.clone();
    }
}
```

Now the internal array cannot be modified through external references.

---

# 17. Important: Shallow Copy vs Deep Copy

This is a very important senior-level concept.

Suppose:

```java
List<Address> addresses;
```

and `Address` itself is mutable.

Doing:

```java
this.addresses = new ArrayList<>(addresses);
```

only copies the list structure.

It does NOT copy every `Address`.

Conceptually:

```text
Original list
   |
   +----> Address A
   |
   +----> Address B

Copied list
   |
   +----> Address A
   |
   +----> Address B
```

Both lists point to the same mutable `Address` objects.

So:

```java
addresses.get(0).setCity("Mumbai");
```

could still change the state visible inside the immutable object.

---

# 18. Deep Copy

If the elements themselves are mutable, you may need to create copies of those elements too.

For example:

```java
this.addresses = addresses.stream()
        .map(Address::new)
        .toList();
```

assuming `Address` has a copy constructor:

```java
public Address(Address other) {
    this.city = other.city;
    this.state = other.state;
}
```

Now:

```text
Original
   |
Address A

Immutable Employee
   |
Copied Address A
```

The two objects are independent.

### Interview rule

> If a field refers to a mutable object, copying only the outer collection may not be enough. You must determine whether the contained objects are also mutable.

---

# 19. Immutable Field Types

Not every field requires defensive copying.

### Usually safe

```text
int
long
double
boolean
char
byte
short
float
String
enum
```

Also immutable value types such as many types from:

```java
java.time
```

For example:

```java
LocalDate
LocalDateTime
Instant
```

are designed to be immutable.

So:

```java
private final String name;
private final LocalDate joiningDate;
```

is fine.

---

# 20. Mutable Field Types Requiring Attention

Examples:

```text
ArrayList
HashMap
HashSet
Date
Calendar
arrays
StringBuilder
StringBuffer
custom mutable objects
```

For these, you need to consider defensive copying or another immutability strategy.

---

# 21. Old `Date` Is a Classic Interview Trap

Consider:

```java
private final Date date;
```

`Date` is mutable.

This is dangerous:

```java
public Employee(Date date) {
    this.date = date;
}

public Date getDate() {
    return date;
}
```

The caller can modify it:

```java
date.setTime(...);
```

or:

```java
employee.getDate().setTime(...);
```

---

# 22. Fix for Date

Constructor:

```java
this.date = new Date(date.getTime());
```

Getter:

```java
return new Date(date.getTime());
```

Example:

```java
public final class Employee {

    private final Date joiningDate;

    public Employee(Date joiningDate) {
        this.joiningDate =
                new Date(joiningDate.getTime());
    }

    public Date getJoiningDate() {
        return new Date(joiningDate.getTime());
    }
}
```

However, in modern Java, prefer:

```java
LocalDate
LocalDateTime
Instant
```

from `java.time` where appropriate.

---

# 23. Constructor Must Establish Complete State

An immutable object should ideally be fully initialized when construction finishes.

Bad design:

```java
final class Employee {

    private final int id;
    private String name;

    public Employee(int id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }
}
```

This is clearly mutable.

For immutability:

```java
final class Employee {

    private final int id;
    private final String name;

    public Employee(int id, String name) {
        this.id = id;
        this.name = name;
    }
}
```

The object is complete after construction.

---

# 24. Validation in Constructor

An immutable class should validate its state during construction.

Example:

```java
public final class Employee {

    private final int id;
    private final String name;

    public Employee(int id, String name) {

        if (id <= 0) {
            throw new IllegalArgumentException(
                    "id must be positive");
        }

        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException(
                    "name is required");
        }

        this.id = id;
        this.name = name;
    }
}
```

This ensures an object cannot normally be created in an invalid state.

---

# 25. No Setters

An immutable class should not expose methods such as:

```java
setName()
setSalary()
setAddress()
setSkills()
```

For example:

```java
public void setName(String name) {
    this.name = name;
}
```

would directly violate immutability.

---

# 26. What If We Need to "Change" an Immutable Object?

Instead of modifying the existing object, create a **new object**.

For example:

```java
Employee employee =
        new Employee(101, "John");
```

Suppose we want the name to become `"Bob"`.

Do not:

```java
employee.setName("Bob");
```

Instead:

```java
Employee updatedEmployee =
        new Employee(employee.getId(), "Bob");
```

Conceptually:

```text
Original object
Employee(101, "John")
        |
        | create new object
        v
Employee(101, "Bob")
```

The original object remains unchanged.

---

# 27. Immutable Class Can Have Methods

Immutability does NOT mean the class cannot have methods.

For example:

```java
public final class Money {

    private final int amount;

    public Money(int amount) {
        this.amount = amount;
    }

    public int getAmount() {
        return amount;
    }

    public Money add(Money other) {
        return new Money(this.amount + other.amount);
    }
}
```

Usage:

```java
Money m1 = new Money(100);
Money m2 = new Money(50);

Money m3 = m1.add(m2);
```

`m1` remains:

```text
100
```

`m3` is:

```text
150
```

This is a common immutable-object pattern.

---

# 28. `equals()` and `hashCode()` in Immutable Classes

Immutable classes are excellent candidates for value objects.

For example:

```java
public final class Employee {

    private final int id;
    private final String name;

    public Employee(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof Employee)) {
            return false;
        }

        Employee other = (Employee) o;

        return id == other.id &&
               Objects.equals(name, other.name);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name);
    }
}
```

Because the fields cannot change, the hash code remains stable after insertion into a `HashMap`.

---

# 29. Why Immutability Is Important for HashMap Keys

Consider a mutable key:

```java
Map<Employee, String> map =
        new HashMap<>();

Employee employee =
        new Employee(101, "John");

map.put(employee, "Developer");
```

If a field used by `hashCode()` changes after insertion, the object may effectively become unreachable through normal lookup.

Immutable keys avoid this problem because:

```text
hashCode
   ↓
does not change
   ↓
stable HashMap behavior
```

This is one reason immutable value objects make good map keys.

---

# 30. Inheritance Problem

Why do we commonly make an immutable class:

```java
final class Employee
```

?

Because inheritance can break immutability.

Suppose:

```java
class Employee {

    private final int id;

    public Employee(int id) {
        this.id = id;
    }

    public int getId() {
        return id;
    }
}
```

Someone can extend it:

```java
class SpecialEmployee extends Employee {

    private String department;

    public SpecialEmployee(int id, String department) {
        super(id);
        this.department = department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }
}
```

Now:

```java
SpecialEmployee employee =
        new SpecialEmployee(101, "IT");

employee.setDepartment("HR");
```

The subclass is mutable.

---

# 31. Why `final class` Is the Simple Solution

Use:

```java
public final class Employee {
}
```

Now:

```java
class SpecialEmployee extends Employee {
}
```

is not allowed.

This prevents subclasses from adding mutable state or behavior that violates your immutability assumptions.

### Interview answer

> We generally make a custom immutable class `final` to prevent subclassing from introducing mutable state or overriding methods in a way that can break immutability.

---

# 32. Can an Immutable Class Be Non-Final?

Yes, but it requires much more careful design.

There are advanced techniques involving:

```text
controlled inheritance
private constructors
sealed classes
final methods
careful subclass contracts
```

But for a normal interview implementation, the safest approach is:

```java
public final class MyImmutableClass
```

---

# 33. Can Immutable Class Have a Mutable Static Field?

Be careful.

Suppose:

```java
public final class Employee {

    private final int id;

    private static List<Employee> employees =
            new ArrayList<>();
}
```

The **instance objects** may still be immutable, but the class itself has mutable global state.

So distinguish:

```text
object immutability
```

from:

```text
class-level/global mutable state
```

A static mutable cache does not automatically mean every instance field is mutable, but it can create thread-safety and design problems.

---

# 34. Static Final Mutable Objects

This is another trap:

```java
private static final List<String> names =
        new ArrayList<>();
```

`final` prevents reassignment:

```java
names = anotherList;   // ❌
```

but does not prevent:

```java
names.add("John");     // ✅
```

If exposing such state, use an immutable/unmodifiable representation or appropriate encapsulation.

---

# 35. Collections and Nested Mutability

Consider:

```java
private final Map<String, List<String>> data;
```

This is much harder.

Doing:

```java
this.data = Map.copyOf(data);
```

does **not automatically make the nested lists immutable**.

For example:

```text
Map
 |
 +-- "Java" → ArrayList
 |
 +-- "Spring" → ArrayList
```

The map may be unmodifiable, while the lists inside it are still mutable.

You may need to make nested values immutable too.

For example:

```java
this.data = data.entrySet()
        .stream()
        .collect(Collectors.toUnmodifiableMap(
                Map.Entry::getKey,
                e -> List.copyOf(e.getValue())
        ));
```

The exact implementation depends on the structure.

### Key principle

> **Immutability must be considered recursively for the entire reachable object graph.**

---

# 36. What About Getter Returning an Immutable Object?

Suppose:

```java
private final Address address;
```

If `Address` itself is immutable:

```java
public final class Address {
    private final String city;
    private final String state;
}
```

then:

```java
public Address getAddress() {
    return address;
}
```

is safe.

You do not need to create a copy if the returned object itself cannot be mutated.

This is why you must know whether the referenced type is mutable.

---

# 37. Defensive Copy Is Not Always Necessary

Consider:

```java
private final String name;
```

You don't need:

```java
this.name = new String(name);
```

because `String` is already immutable.

Similarly, copying immutable objects is usually unnecessary.

The rule is:

```text
Mutable object
    → defensive copy / immutable representation

Immutable object
    → direct reference is generally safe
```

---

# 38. Serialization Problem

Suppose:

```java
public final class Employee
        implements Serializable {

    private final int id;
    private final String name;

    public Employee(int id, String name) {
        this.id = id;
        this.name = name;
    }
}
```

Serialization can introduce special concerns for immutable classes, especially if the class contains mutable state or invariants that must be validated.

For sensitive immutable designs, consider:

```java
private Object readResolve()
```

or a custom:

```java
readObject()
```

when appropriate.

But do not add these methods automatically. They are needed only when serialization semantics require special handling.

---

# 39. Serialization and Mutable Fields

Suppose an immutable class contains:

```java
private final Date date;
```

Even if you protected it in the constructor/getter, serialization must still preserve the invariant.

For robust immutable serializable classes, you should consider whether deserialization can create an object state that bypasses normal constructor validation or defensive-copy logic.

This is a more advanced interview topic.

---

# 40. Reflection and Immutability

A sufficiently privileged caller can use reflection or other low-level mechanisms to bypass normal encapsulation in some environments.

For example, reflection may potentially access private fields.

But interview-level immutability generally means:

> The class's normal public API and supported usage cannot mutate its state.

You should not normally design everyday immutable classes around hypothetical hostile reflection unless you are working in a security-sensitive environment.

---

# 41. Thread Safety

Immutable objects are naturally thread-safe for their immutable state.

Example:

```java
Employee employee =
        new Employee(101, "John");
```

Suppose 10 threads use:

```java
employee.getName();
employee.getId();
```

No synchronization is required merely to read the immutable fields.

Why?

Because nobody can change:

```text
id
name
```

after construction.

Conceptually:

```text
             Employee
                |
       +--------+--------+
       |                 |
    Thread 1          Thread 2
       |                 |
       +------ read ----+
                |
          state unchanged
```

---

# 42. Important Thread-Safety Caveat

Immutable class is thread-safe only if the **entire observable state is safely immutable**.

This is not enough:

```java
private final List<String> list;
```

if the list itself remains mutable.

Similarly:

```java
private final SomeMutableObject object;
```

does not make the state immutable.

So:

```text
final reference
       ≠
immutable object
```

---

# 43. Final Fields and Safe Publication

Java's memory model gives special guarantees around properly constructed objects with `final` fields.

When an object is correctly constructed and safely published, other threads can reliably observe the initialized values of its final fields.

This is another reason `final` fields are important in immutable designs.

However, `final` field semantics do not magically make mutable referenced objects thread-safe.

For example:

```java
private final List<String> list;
```

still requires the list itself to be immutable or otherwise safely synchronized.

---

# 44. Builder Pattern with Immutable Class

Immutable classes often use a Builder when there are many fields.

Example:

```java
public final class Employee {

    private final int id;
    private final String name;
    private final String department;

    private Employee(Builder builder) {
        this.id = builder.id;
        this.name = builder.name;
        this.department = builder.department;
    }

    public static class Builder {

        private int id;
        private String name;
        private String department;

        public Builder id(int id) {
            this.id = id;
            return this;
        }

        public Builder name(String name) {
            this.name = name;
            return this;
        }

        public Builder department(String department) {
            this.department = department;
            return this;
        }

        public Employee build() {
            return new Employee(this);
        }
    }
}
```

Usage:

```java
Employee employee =
        new Employee.Builder()
                .id(101)
                .name("John")
                .department("IT")
                .build();
```

The builder is mutable.

The resulting `Employee` is immutable.

This is perfectly valid.

---

# 45. Important Builder Trap

Suppose the builder contains:

```java
private List<String> skills;
```

and the immutable class does:

```java
this.skills = builder.skills;
```

This can break immutability.

Instead:

```java
this.skills = List.copyOf(builder.skills);
```

The final object must protect itself from the mutable builder.

### Principle

> **The immutable object must defend itself from every mutable object supplied to it, including builders.**

---

# 46. Factory Methods

Immutable classes commonly provide static factory methods.

Example:

```java
public final class Employee {

    private final int id;
    private final String name;

    private Employee(int id, String name) {
        this.id = id;
        this.name = name;
    }

    public static Employee of(int id, String name) {
        return new Employee(id, name);
    }
}
```

Usage:

```java
Employee employee =
        Employee.of(101, "John");
```

This is similar to APIs such as:

```java
LocalDate.of(...)
List.of(...)
Set.of(...)
Map.of(...)
```

---

# 47. Returning `this` from Immutable Methods

Suppose:

```java
public Employee withName(String newName) {
    return new Employee(this.id, newName);
}
```

This is good.

But sometimes an immutable class may optimize:

```java
if (this.name.equals(newName)) {
    return this;
}
```

because no state change is necessary.

Example:

```java
public Employee withName(String newName) {

    if (Objects.equals(this.name, newName)) {
        return this;
    }

    return new Employee(this.id, newName);
}
```

This is an optional optimization.

---

# 48. "With" Methods

A very common immutable pattern is:

```java
withName()
withSalary()
withAddress()
```

Example:

```java
public Employee withName(String name) {
    return new Employee(this.id, name);
}
```

Usage:

```java
Employee e1 =
        new Employee(101, "John");

Employee e2 =
        e1.withName("Bob");
```

Now:

```text
e1 → 101, John
e2 → 101, Bob
```

`e1` was never modified.

---

# 49. Complete Interview-Quality Immutable Class

Here is a stronger example covering:

- `final` class
- private final fields
- constructor validation
- immutable field types
- defensive copy
- no setters
- immutable collection
- `equals()`
- `hashCode()`
- `toString()`
- with-method

```java
import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

public final class Employee {

    private final int id;
    private final String name;
    private final LocalDate joiningDate;
    private final List<String> skills;

    public Employee(
            int id,
            String name,
            LocalDate joiningDate,
            List<String> skills) {

        if (id <= 0) {
            throw new IllegalArgumentException(
                    "id must be positive");
        }

        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException(
                    "name is required");
        }

        if (joiningDate == null) {
            throw new IllegalArgumentException(
                    "joiningDate is required");
        }

        if (skills == null) {
            throw new IllegalArgumentException(
                    "skills is required");
        }

        this.id = id;
        this.name = name;
        this.joiningDate = joiningDate;
        this.skills = List.copyOf(skills);
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public LocalDate getJoiningDate() {
        return joiningDate;
    }

    public List<String> getSkills() {
        return skills;
    }

    public Employee withName(String newName) {
        return new Employee(
                this.id,
                newName,
                this.joiningDate,
                this.skills
        );
    }

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof Employee)) {
            return false;
        }

        Employee other = (Employee) o;

        return id == other.id
                && Objects.equals(name, other.name)
                && Objects.equals(
                        joiningDate,
                        other.joiningDate)
                && Objects.equals(
                        skills,
                        other.skills);
    }

    @Override
    public int hashCode() {
        return Objects.hash(
                id,
                name,
                joiningDate,
                skills);
    }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", joiningDate=" + joiningDate +
                ", skills=" + skills +
                '}';
    }
}
```

---

# 50. Testing the Immutable Class

```java
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class Main {

    public static void main(String[] args) {

        List<String> skills = new ArrayList<>();

        skills.add("Java");
        skills.add("Spring");

        Employee employee =
                new Employee(
                        101,
                        "John",
                        LocalDate.of(2024, 1, 10),
                        skills);

        // Modify original list
        skills.add("Hibernate");

        System.out.println(employee.getSkills());

        // Try modifying returned list
        employee.getSkills().add("Docker");
    }
}
```

Output before the exception:

```text
[Java, Spring]
```

The first modification does not affect the employee.

The second operation:

```java
employee.getSkills().add("Docker");
```

throws:

```text
UnsupportedOperationException
```

This demonstrates defensive protection from both directions.

---

# 51. The Two-Direction Rule

This is one of the easiest ways to remember defensive copying.

Whenever an immutable class receives or returns a mutable object, protect **both directions**.

```text
                Immutable Object
                     |
          +----------+----------+
          |                     |
       INPUT                  OUTPUT
          |                     |
       protect                protect
          |                     |
   defensive copy       defensive copy /
                        immutable view
```

### Input

Protect the object from the caller:

```java
this.list = List.copyOf(list);
```

### Output

Protect the object from the caller modifying internal state:

```java
return list;
```

is safe only if `list` is itself immutable/unmodifiable.

---

# 52. Common Wrong Immutable Class

This is a classic interview question.

```java
public final class Employee {

    private final int id;
    private final String name;
    private final List<String> skills;

    public Employee(
            int id,
            String name,
            List<String> skills) {

        this.id = id;
        this.name = name;
        this.skills = skills;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

It looks immutable.

But it is NOT.

### Problem 1

```java
this.skills = skills;
```

stores the caller's mutable list directly.

### Problem 2

```java
return skills;
```

exposes the internal mutable list.

Therefore:

```java
employee.getSkills().add("Docker");
```

can modify the object's state.

---

# 53. Correct Version

```java
public final class Employee {

    private final int id;
    private final String name;
    private final List<String> skills;

    public Employee(
            int id,
            String name,
            List<String> skills) {

        this.id = id;
        this.name = name;
        this.skills = List.copyOf(skills);
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

Now the collection is protected.

---

# 54. What If the List Contains Mutable Objects?

This version may still not be deeply immutable:

```java
this.addresses = List.copyOf(addresses);
```

if:

```java
Address
```

is mutable.

Example:

```java
employee.getAddresses()
        .get(0)
        .setCity("Mumbai");
```

The list itself cannot be structurally modified, but the `Address` object might still be modified.

Therefore:

```text
Immutable collection
       ≠
Immutable elements
```

For deep immutability, the elements also need to be immutable or copied.

---

# 55. Null Handling

`List.copyOf()` does not allow null elements.

For example:

```java
List.copyOf(
        Arrays.asList("Java", null)
);
```

will throw an exception.

This can actually be useful because it enforces stronger invariants.

But you should deliberately decide whether null is allowed in your API.

For example:

```java
if (skills == null) {
    throw new IllegalArgumentException(...);
}
```

---

# 56. Immutable Class vs Unmodifiable Collection

These concepts are different.

### Unmodifiable collection

```java
List<String> list =
        Collections.unmodifiableList(original);
```

The caller cannot modify the list through that reference, but `original` can still change.

### Immutable object

An immutable object guarantees that its observable state cannot change.

Therefore:

```text
Unmodifiable
     ↓
A particular reference cannot modify the collection

Immutable
     ↓
The object's state cannot change
```

This distinction is frequently asked in senior interviews.

---

# 57. Immutable vs Final

Do not confuse:

```text
final variable
final class
immutable object
```

### `final` variable

Cannot be reassigned.

### `final class`

Cannot be extended.

### Immutable object

State cannot change after construction.

Example:

```java
final List<String> list =
        new ArrayList<>();
```

The reference is final:

```java
list = anotherList;     // ❌
```

But:

```java
list.add("Java");       // ✅
```

is still possible.

Therefore:

```text
final ≠ immutable
```

---

# 58. Immutable Class and Records

Modern Java also provides `record`.

Example:

```java
public record Employee(
        int id,
        String name
) {}
```

Records are designed as concise data carriers and their components are final.

But an important interview point is:

> **A record is not automatically deeply immutable.**

For example:

```java
public record Employee(
        int id,
        List<String> skills
) {}
```

The list can still be mutable.

So even with records, you may need defensive copying:

```java
public record Employee(
        int id,
        List<String> skills
) {
    public Employee {
        skills = List.copyOf(skills);
    }
}
```

Now the record protects the collection from external structural modification.

---

# 59. Immutability with Collections — Cheat Sheet

| Field | Mutable? | Defensive Copy Needed? |
|---|---:|---:|
| `int` | No | No |
| `String` | No | No |
| `LocalDate` | No | No |
| `enum` | No | No |
| `ArrayList` | Yes | Yes |
| `HashMap` | Yes | Yes |
| `HashSet` | Yes | Yes |
| Array | Yes | Yes |
| `Date` | Yes | Yes |
| `StringBuilder` | Yes | Yes |
| Immutable custom class | No | Usually no |
| Mutable custom class | Yes | Usually yes |

---

# 60. Interview Question: Why Make Immutable Class Final?

### Short answer

> To prevent subclasses from introducing mutable state or overriding behavior in a way that violates the immutability guarantee.

---

# 61. Interview Question: Why Are Fields Private and Final?

### `private`

Prevents direct external access to internal state.

### `final`

Prevents reassignment after construction.

But remember:

```text
private + final
```

still does not guarantee immutability if the field points to a mutable object.

Example:

```java
private final List<String> list;
```

The list can still change unless protected.

---

# 62. Interview Question: Why Defensive Copy?

Answer:

> A defensive copy prevents external code from retaining a reference to the mutable object used internally by the immutable class. We generally copy mutable inputs in the constructor and avoid exposing mutable internal objects directly from getters.

---

# 63. Interview Question: Why Is String Immutable?

Important reasons include:

```text
1. Security
2. String pool
3. Thread safety
4. HashCode caching
5. Safe use as HashMap keys
6. Predictable behavior
```

For example:

```java
Map<String, Integer> map;
```

works reliably because a String's value cannot change after insertion.

---

# 64. Common Interview Traps

### Trap 1

> If all fields are final, the class is immutable.

**Wrong.**

```java
private final List<String> list;
```

The list can still change.

---

### Trap 2

> If the getter returns a final field, it is safe.

**Wrong.**

```java
return list;
```

can expose a mutable object.

---

### Trap 3

> `Collections.unmodifiableList()` always makes the underlying data immutable.

**Wrong.**

It provides an unmodifiable view; the original list can still change.

---

### Trap 4

> `List.copyOf()` makes every nested object immutable.

**Wrong.**

It protects the collection structure, not necessarily mutable elements.

---

### Trap 5

> Immutable means no methods.

**Wrong.**

Immutable classes can have methods.

They simply must not mutate observable state.

---

### Trap 6

> Immutable means final class is mandatory.

**Not strictly.**

Making it final is the simple and safest design for ordinary custom immutable classes.

---

### Trap 7

> Immutable means no new object can ever be created.

**Wrong.**

Immutable objects can create new objects representing modified values.

Example:

```java
Money m2 = m1.add(money);
```

---

# 65. How to Design an Immutable Class in an Interview

If the interviewer says:

> "Create an immutable Employee class."

Think through this sequence:

```text
Step 1
↓
Make class final

Step 2
↓
Make fields private final

Step 3
↓
Initialize everything in constructor

Step 4
↓
Validate constructor input

Step 5
↓
Remove setters

Step 6
↓
Check every field type

Step 7
↓
If mutable → defensive copy

Step 8
↓
Getter must not expose mutable internal state

Step 9
↓
Check nested mutable objects

Step 10
↓
Implement equals/hashCode if it is a value object
```

---

# 66. A Strong Interview Implementation

If you need to write one quickly on a whiteboard, use this:

```java
import java.util.List;

public final class Employee {

    private final int id;
    private final String name;
    private final List<String> skills;

    public Employee(
            int id,
            String name,
            List<String> skills) {

        if (id <= 0) {
            throw new IllegalArgumentException(
                    "Invalid id");
        }

        if (name == null) {
            throw new IllegalArgumentException(
                    "Name cannot be null");
        }

        this.id = id;
        this.name = name;
        this.skills = List.copyOf(skills);
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public List<String> getSkills() {
        return skills;
    }
}
```

Then explain:

> "I made the class final to prevent subclassing, fields private and final so they cannot be reassigned, initialized everything through the constructor, removed setters, and used `List.copyOf()` because the list is mutable. Since the returned list is unmodifiable, callers cannot change the internal state."

That is a strong interview answer.

---

# 67. Final Mental Model

Remember this:

```text
                 IMMUTABLE CLASS
                       |
          +------------+------------+
          |            |            |
       Structure    References    State
          |            |            |
        final        private       fixed
          |            |            |
          +------------+------------+
                       |
              Mutable objects?
                       |
                     YES
                       |
             Defensive copying
                       |
          +------------+------------+
          |                         |
       Constructor                Getter
          |                         |
     copy input              don't expose
                             mutable state
```

The most important formula is:

```text
Immutable Class
=
final class
+
private final fields
+
complete construction
+
no setters
+
defensive copies
+
immutable nested state
+
safe getters
```

### One-line interview answer

> **A custom immutable class is a class whose observable state cannot change after construction. Typically, we make the class final, fields private and final, initialize them in the constructor, provide no setters, and use defensive copies or immutable collections for mutable fields. We also need to consider nested mutable objects, arrays, inheritance, serialization, and equality/hash-code behavior.**