# Java equals(), hashCode() and toString()
## Complete Interview Guide — Coding + Scenarios + Q&A

---

# 1. What is the interviewer actually testing?

When an interviewer says:

> "Write equals(), hashCode() and toString() for this class."

They are usually testing more than syntax.

They want to know whether you understand:

- Object equality
- Logical identity
- equals() contract
- hashCode() contract
- HashMap / HashSet behavior
- null handling
- mutable fields
- inheritance
- collections
- debugging/logging
- entity identity
- good Java coding practices

Do not immediately start typing.

First ask yourself:

1. What makes two objects logically equal?
2. Which fields define the object's identity?
3. Should all fields participate in equality?
4. Can those fields be null?
5. Are those fields mutable?
6. Is inheritance involved?
7. What information should toString() display?

A good opening statement in an interview is:

> "First, I want to identify which fields define the logical identity of this object. I'll use those fields consistently in equals() and hashCode(). For toString(), I'll include useful fields that help with debugging without exposing sensitive information."

---

# 2. The three methods in one sentence

Remember this:

> equals() tells us whether two objects are logically equal.

> hashCode() gives a hash value used by hash-based collections such as HashMap and HashSet.

> toString() gives a readable representation of the object, mainly useful for debugging and logging.

---

# 3. Basic Employee example

Suppose the interviewer gives:

class Employee {

    private Long id;
    private String name;
    private String department;
}

And tells you:

> "Employee ID uniquely identifies an employee."

Then the logical identity is:

    id

Therefore:

    equals()   -> id
    hashCode() -> id
    toString() -> useful fields

Implementation:

import java.util.Objects;

public class Employee {

    private Long id;
    private String name;
    private String department;

    public Employee(Long id, String name, String department) {
        this.id = id;
        this.name = name;
        this.department = department;
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

        return Objects.equals(this.id, other.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", department='" + department + '\'' +
                '}';
    }
}

---

# 4. How to write equals() from scratch

Do not memorize the entire method.

Remember the sequence:

    1. Same reference?
    2. Correct type?
    3. Cast
    4. Compare identity fields

Code:

@Override
public boolean equals(Object o) {

    // 1. Same object?
    if (this == o) {
        return true;
    }

    // 2. Correct type?
    if (!(o instanceof Employee)) {
        return false;
    }

    // 3. Cast
    Employee other = (Employee) o;

    // 4. Compare identity fields
    return Objects.equals(this.id, other.id);
}

---

# 5. Why do we check this == o?

Question:

> Why do you write if (this == o)?

Answer:

It checks whether both references point to exactly the same object.

For example:

Employee e1 = new Employee(1L, "John", "IT");
Employee e2 = e1;

Then:

e1 == e2

is true.

There is no reason to compare individual fields because it is literally the same object.

This is also an efficient early exit.

---

# 6. Why is equals() parameter Object?

Question:

> Why is the method signature equals(Object o) instead of equals(Employee employee)?

Because equals() is defined by java.lang.Object:

public boolean equals(Object obj)

Every Java class inherits this method.

Therefore, when overriding it, the parameter must be Object.

This is correct:

@Override
public boolean equals(Object o)

This is NOT overriding equals():

public boolean equals(Employee employee)

The second version is an overloaded method.

---

# 7. Why use Objects.equals()?

Suppose:

return id.equals(other.id);

If id is null, this can cause:

NullPointerException

Instead:

return Objects.equals(id, other.id);

Objects.equals() handles null safely.

Examples:

Objects.equals(null, null)
-> true

Objects.equals(null, "ABC")
-> false

Objects.equals("ABC", null)
-> false

Objects.equals("ABC", "ABC")
-> true

---

# 8. How to write hashCode()

The most important rule:

> If two objects are equal according to equals(), they MUST have the same hash code.

If equals() uses:

return Objects.equals(id, other.id);

then hashCode() should use id:

@Override
public int hashCode() {
    return Objects.hash(id);
}

If equals() uses three fields:

return Objects.equals(id, other.id)
        && Objects.equals(name, other.name)
        && Objects.equals(department, other.department);

then hashCode() should use:

@Override
public int hashCode() {
    return Objects.hash(id, name, department);
}

---

# 9. The equals/hashCode contract

This is one of the most important interview questions.

Question:

> What is the contract between equals() and hashCode()?

Answer:

If:

a.equals(b) == true

then:

a.hashCode() == b.hashCode()

MUST be true.

However:

a.hashCode() == b.hashCode()

does NOT mean:

a.equals(b) == true

because different objects can have the same hash code.

This is called a hash collision.

The interview-friendly answer:

> "Equal objects must have equal hash codes, but equal hash codes do not necessarily mean the objects are equal."

Remember this sentence.

---

# 10. equals() contract

The equals() method has several important properties.

## 10.1 Reflexive

An object must equal itself.

a.equals(a) == true

---

## 10.2 Symmetric

If:

a.equals(b)

is true, then:

b.equals(a)

must also be true.

---

## 10.3 Transitive

If:

a.equals(b)
b.equals(c)

then:

a.equals(c)

must also be true.

---

## 10.4 Consistent

If nothing relevant changes, repeated calls should return the same result.

---

## 10.5 Non-null

For a non-null object:

a.equals(null)

must be false.

A good interview answer:

> "equals() should be reflexive, symmetric, transitive, consistent, and false when compared with null."

---

# 11. Why override equals()?

Question:

> Why do we override equals()?

By default, Object.equals() essentially compares object identity.

For example:

Employee e1 = new Employee(101L, "John", "IT");
Employee e2 = new Employee(101L, "John", "IT");

Without overriding equals():

e1.equals(e2)

is false because they are two different object instances.

If business logic says they represent the same employee, we override equals() to define logical equality.

---

# 12. Why override hashCode()?

Question:

> Why do we need hashCode() if equals() already exists?

Because hash-based collections use hashCode() to locate objects efficiently.

Important collections include:

- HashMap
- HashSet
- Hashtable
- ConcurrentHashMap

Typical simplified process:

    object
       |
       v
    hashCode()
       |
       v
    find bucket
       |
       v
    equals()
       |
       v
    confirm equality

Therefore, if you override equals(), you should also override hashCode().

---

# 13. What happens if I override equals() but not hashCode()?

This is a classic interview question.

Suppose:

Employee e1 = new Employee(101L, "John", "IT");
Employee e2 = new Employee(101L, "John", "IT");

Assume:

e1.equals(e2) == true

but you did not override hashCode().

Object.hashCode() may return different values for e1 and e2.

Now HashSet or HashMap can behave incorrectly for your intended logical equality.

Example:

Set<Employee> employees = new HashSet<>();

employees.add(e1);
employees.add(e2);

You may expect only one logical employee, but the collection may contain both because their hash codes differ.

Therefore:

> Whenever equals() is overridden, hashCode() should also be overridden.

---

# 14. Can two different objects have the same hashCode()?

YES.

Example:

a.hashCode() == b.hashCode()

does not mean:

a.equals(b)

is true.

Hash collisions are allowed.

The hashCode contract only guarantees:

If:

a.equals(b)

then:

a.hashCode() == b.hashCode()

It does not guarantee the reverse.

---

# 15. Can two equal objects have different hash codes?

NO.

If:

a.equals(b) == true

then:

a.hashCode() == b.hashCode()

must be true.

If equal objects have different hash codes, the equals/hashCode contract is broken.

---

# 16. How does HashSet use equals() and hashCode()?

Question:

> How does HashSet determine whether an object already exists?

Simplified answer:

1. HashSet calculates hashCode().
2. It uses the hash to identify a bucket/location.
3. If another object is already there, equals() is used to determine whether the objects are actually equal.
4. If they are equal, the duplicate is not added.

Conceptually:

    add(object)
        |
        v
    hashCode()
        |
        v
    locate bucket
        |
        v
    compare equals()
        |
      /   \
   equal  different
     |        |
   reject    add

---

# 17. How does HashMap use equals() and hashCode()?

Suppose:

Map<Employee, String> map = new HashMap<>();

Employee e1 = new Employee(101L, "John", "IT");

map.put(e1, "Developer");

Later:

Employee e2 = new Employee(101L, "John", "IT");

map.get(e2);

For this to correctly find the value, e1 and e2 need:

e1.equals(e2) == true

and:

e1.hashCode() == e2.hashCode()

Simplified lookup:

    get(e2)
       |
       v
    e2.hashCode()
       |
       v
    locate bucket
       |
       v
    equals()
       |
       v
    find matching key

---

# 18. Why does HashMap need both hashCode() and equals()?

Question:

> Why not just use equals()?

Because checking every key with equals() would be inefficient.

Suppose a HashMap contains thousands or millions of entries.

hashCode() helps narrow down the possible location first.

Then equals() confirms the exact match.

So:

hashCode() -> efficient lookup

equals() -> exact logical comparison

---

# 19. What is toString()?

Question:

> Why override toString()?

Object provides a default toString() implementation.

Without overriding, you may see something like:

Employee@5e2de80c

This is usually not useful for debugging.

A custom implementation:

@Override
public String toString() {
    return "Employee{" +
            "id=" + id +
            ", name='" + name + '\'' +
            ", department='" + department + '\'' +
            '}';
}

Output:

Employee{id=101, name='John', department='IT'}

This makes logs and debugging much easier.

---

# 20. Should toString() contain every field?

Not necessarily.

The purpose is to provide a useful representation.

Avoid exposing sensitive information such as:

- passwords
- authentication tokens
- credit card information
- security credentials
- sensitive personal information

For example, don't do:

@Override
public String toString() {
    return "User{" +
            "username='" + username + '\'' +
            ", password='" + password + '\'' +
            '}';
}

A safer implementation would omit password.

---

# 21. Scenario: equals() uses all fields

Suppose:

class Product {

    private String sku;
    private String name;
    private double price;
}

The interviewer says:

> "A Product is equal only if sku, name and price are equal."

Then:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Product)) {
        return false;
    }

    Product other = (Product) o;

    return Objects.equals(sku, other.sku)
            && Objects.equals(name, other.name)
            && Double.compare(price, other.price) == 0;
}

@Override
public int hashCode() {
    return Objects.hash(sku, name, price);
}

@Override
public String toString() {
    return "Product{" +
            "sku='" + sku + '\'' +
            ", name='" + name + '\'' +
            ", price=" + price +
            '}';
}

Important:

> hashCode() uses the same fields that participate in equals().

---

# 22. Scenario: only ID defines equality

class Employee {

    private Long id;
    private String name;
    private String department;
    private double salary;
}

If id uniquely identifies the employee:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Employee)) {
        return false;
    }

    Employee other = (Employee) o;

    return Objects.equals(id, other.id);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}

Here:

name
department
salary

do not determine equality.

---

# 23. Should every field participate in equals()?

NO.

This is an important conceptual question.

The correct answer is:

> "It depends on the equality definition of the class."

For example, if Employee ID uniquely identifies an employee, then salary changing should not make the Employee a different employee.

Therefore:

equals() -> id

not:

equals() -> id + name + department + salary

The important question is:

> What is the logical identity of this object?

---

# 24. Scenario: null ID

Suppose:

Employee e1 = new Employee(null, "John", "IT");
Employee e2 = new Employee(null, "John", "IT");

If equals() is:

return Objects.equals(id, other.id);

then:

e1.equals(e2)

returns true because:

Objects.equals(null, null)

is true.

But whether that is correct depends on your business/domain model.

For an entity whose ID is assigned only after database persistence, treating two unsaved entities with null IDs as equal may be undesirable.

This is an important real-world issue.

Interview answer:

> "If the ID can be null before persistence, I would clarify the domain semantics. Two transient entities with null IDs may not necessarily represent the same entity."

---

# 25. Scenario: database entity ID assigned later

Consider:

Employee employee = new Employee();

Initially:

employee.id == null

After saving to the database:

employee.id == 101

If id participates in hashCode(), the hash code changes.

That can be dangerous if the object was already placed into a HashSet or used as a HashMap key.

Example:

Set<Employee> employees = new HashSet<>();

employees.add(employee);

// Later ID changes
employee.setId(101L);

Now the object's hashCode() may be different from the hash code when it was inserted.

This can cause lookup/removal problems.

Interview answer:

> "For objects used as HashMap keys or HashSet elements, fields participating in hashCode() should ideally remain stable while the object is inside the collection."

---

# 26. Mutable fields and HashSet

Suppose:

class Employee {

    private Long id;

    // equals/hashCode use id
}

Then:

Employee e = new Employee(101L);

Set<Employee> set = new HashSet<>();
set.add(e);

Now:

e.setId(999L);

The object's hash code may change.

Then:

set.contains(e)

can unexpectedly return false.

Why?

Because the object may have been placed into the bucket corresponding to the old hash code.

Now lookup uses the new hash code.

This is why mutable fields used in equals/hashCode can be dangerous.

---

# 27. Interview question: Can hashCode() return a constant?

Technically, yes.

For example:

@Override
public int hashCode() {
    return 1;
}

This does not violate the basic hashCode contract.

However, it causes massive hash collisions and poor performance in hash-based collections.

Interview answer:

> "A constant hash code is technically legal, but it destroys the performance benefit of hash-based collections because many objects end up in the same bucket."

---

# 28. Interview question: Can hashCode() return a random number?

Generally, NO.

If an object's hash code changes between calls while the object remains unchanged, it violates the expectations of hash-based collections.

Bad:

@Override
public int hashCode() {
    return new Random().nextInt();
}

The hash code should be consistent during the object's relevant lifetime unless the fields used to calculate it change.

---

# 29. instanceOf vs getClass()

You may see two approaches.

Approach 1:

if (!(o instanceof Employee)) {
    return false;
}

Approach 2:

if (o == null || getClass() != o.getClass()) {
    return false;
}

Difference:

instanceof:

    Allows subclass instances to participate in the comparison.

getClass():

    Requires exactly the same runtime class.

There is no universal "always use this" answer.

Inheritance changes the equality problem significantly.

Interview answer:

> "For a simple class without inheritance, either can be appropriate depending on the intended equality semantics. With inheritance, I need to be careful because equals() must remain symmetric and transitive."

---

# 30. Inheritance scenario

Suppose:

class Employee {
    Long id;
}

class Manager extends Employee {
    String department;
}

If Employee.equals() compares only id, but Manager.equals() compares id + department, you can potentially create asymmetric equality.

For example:

Employee e = new Employee(101L);
Manager m = new Manager(101L, "IT");

If Employee says:

e.equals(m) == true

but Manager says:

m.equals(e) == false

then symmetry is broken.

This is why equals() with inheritance requires careful design.

Interview answer:

> "Inheritance makes equals() more complicated because subclasses can introduce additional state and accidentally violate symmetry or transitivity. I would define equality carefully, often preferring final/value-based classes or exact-class comparison when appropriate."

---

# 31. Why is @Override important?

Use:

@Override
public boolean equals(Object o)

The annotation tells the compiler:

> "I intend to override a superclass method."

It protects you from accidental overloading.

For example, this is wrong:

public boolean equals(Employee employee)

You intended to override Object.equals(Object), but you actually created a different overloaded method.

With @Override, the compiler catches the mistake.

Always use @Override for equals(), hashCode(), and toString().

---

# 32. What happens if equals() is overloaded instead of overridden?

Suppose:

public boolean equals(Employee employee)

instead of:

public boolean equals(Object o)

Then:

Employee e1 = ...
Employee e2 = ...

A direct call may compile:

e1.equals(e2)

but when treated as Object, behavior can be different because Object.equals(Object) is still being used.

This can create very confusing behavior.

Therefore:

Always use:

@Override
public boolean equals(Object o)

---

# 33. Why use Objects.hash()?

Instead of manually writing:

@Override
public int hashCode() {
    int result = id != null ? id.hashCode() : 0;
    result = 31 * result + (name != null ? name.hashCode() : 0);
    return result;
}

you can use:

@Override
public int hashCode() {
    return Objects.hash(id, name);
}

This is simpler and handles null values.

In an interview, using Objects.hash() is perfectly reasonable unless the interviewer specifically asks you to implement the hash algorithm manually.

---

# 34. If interviewer says "Don't use Objects.hash()"

Then you should understand the basic idea.

Example:

@Override
public int hashCode() {

    int result = 17;

    result = 31 * result + (id == null ? 0 : id.hashCode());
    result = 31 * result + (name == null ? 0 : name.hashCode());

    return result;
}

The exact numbers are not the important part.

The important idea is:

- combine field hash codes
- handle null
- produce the same result for equal objects

---

# 35. Why 31 is commonly used?

You may see:

result = 31 * result + field.hashCode();

31 is traditionally used in Java hash implementations because it gives a reasonable distribution and is inexpensive to calculate.

You do NOT need to memorize why 31 specifically unless the interviewer asks.

A good answer:

> "31 is a commonly used multiplier in Java hash implementations because it generally provides good distribution and is inexpensive to calculate."

---

# 36. String fields

Suppose:

class Employee {
    private String name;
}

String already overrides equals() and hashCode().

Therefore:

Objects.equals(name, other.name)

works based on String content.

Example:

String s1 = new String("John");
String s2 = new String("John");

s1 == s2

is false.

But:

s1.equals(s2)

is true.

This is an important distinction.

---

# 37. == vs equals()

Interview question:

> What is the difference between == and equals()?

For objects:

== checks whether two references point to the same object.

equals() checks logical equality according to the implementation.

Example:

String a = new String("Java");
String b = new String("Java");

a == b

-> false

a.equals(b)

-> true

Therefore:

==       -> reference identity

equals() -> logical equality

---

# 38. What if the class contains another custom object?

Suppose:

class Employee {

    private Long id;
    private Address address;
}

And:

return Objects.equals(id, other.id)
        && Objects.equals(address, other.address);

This works correctly only if Address has a meaningful equals() implementation.

Otherwise Address.equals() may fall back to reference equality.

Therefore, equality often propagates through the object graph.

Interview answer:

> "If a field is itself a custom value object, that class should also implement meaningful equals() and hashCode() if logical equality is required."

---

# 39. What if a field is an array?

Arrays are a common trap.

This is generally NOT what you want:

Objects.equals(array1, array2)

because arrays don't override equals() based on contents.

Use:

Arrays.equals(array1, array2)

For hashCode:

Arrays.hashCode(array)

For nested arrays:

Arrays.deepEquals()

and:

Arrays.deepHashCode()

Interview answer:

> "For arrays, I use Arrays.equals() and Arrays.hashCode() because array equals() is reference-based rather than content-based."

---

# 40. What if a field is a List?

For most Java collections such as List:

list1.equals(list2)

already compares contents according to the collection's equality contract.

Therefore:

Objects.equals(list1, list2)

is normally fine.

Likewise, Objects.hash(list) can incorporate the list's hash code.

---

# 41. What if a field is a Set?

Set.equals() is based on set contents rather than ordering.

Therefore:

Set<String> s1 = Set.of("A", "B");
Set<String> s2 = Set.of("B", "A");

s1.equals(s2)

is true.

If a Set participates in equality, its own equals/hashCode implementation handles the appropriate semantics.

---

# 42. What if a field is double?

Floating-point values can have tricky edge cases.

Instead of casually writing:

price == other.price

you may use:

Double.compare(price, other.price) == 0

Example:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Product)) {
        return false;
    }

    Product other = (Product) o;

    return Objects.equals(sku, other.sku)
            && Double.compare(price, other.price) == 0;
}

For BigDecimal, be especially careful because:

new BigDecimal("10.0").equals(new BigDecimal("10.00"))

is false due to scale.

But:

compareTo()

may consider them numerically equal.

So equality semantics should be decided deliberately.

---

# 43. BigDecimal interview trap

Question:

> Does BigDecimal.equals() behave the same as compareTo()?

No.

Example:

BigDecimal a = new BigDecimal("10.0");
BigDecimal b = new BigDecimal("10.00");

a.equals(b)

-> false

a.compareTo(b) == 0

-> true

Why?

BigDecimal.equals() considers scale.

Therefore, when designing equality around BigDecimal, clarify whether:

10.0

and:

10.00

should be considered equal.

---

# 44. What if fields are inherited?

Suppose:

class Person {
    String name;
}

class Employee extends Person {
    Long id;
}

You need to decide whether equality includes inherited fields.

There is no automatic universal answer.

Ask:

> "Does logical identity include the parent class fields?"

Then design equals/hashCode accordingly.

---

# 45. What if the object is immutable?

Immutable objects are excellent candidates for use as HashMap keys or HashSet elements.

For example:

final class EmployeeId {

    private final Long id;

    public EmployeeId(Long id) {
        this.id = id;
    }

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof EmployeeId)) {
            return false;
        }

        EmployeeId other = (EmployeeId) o;

        return Objects.equals(id, other.id);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}

Because id cannot change, hash-based collection behavior is safer.

---

# 46. Should fields used by equals/hashCode be final?

Not strictly required.

But immutable fields are often preferable.

For example:

private final Long id;

is safer than:

private Long id;

when id defines equality.

Interview answer:

> "Fields used for equality don't have to be final, but keeping them immutable is generally safer, especially when objects are used as hash-based collection keys."

---

# 47. What happens if a HashMap key is mutated?

Example:

Map<Employee, String> map = new HashMap<>();

Employee e = new Employee(101L, "John", "IT");

map.put(e, "Developer");

e.setId(999L);

map.get(e);

This can fail to find the value.

The object is still physically associated with the bucket determined by its old hash code, while lookup may use the new hash code.

Therefore:

> Never mutate equality/hashCode-defining fields while an object is being used as a HashMap key or HashSet element.

---

# 48. Can toString() affect equals() or hashCode()?

No.

These methods have independent purposes.

toString() is a textual representation.

equals() defines logical equality.

hashCode() supports equality in hash-based structures.

You should not implement equals() using toString():

return this.toString().equals(other.toString());

This is bad design.

---

# 49. Should toString() call getters or fields directly?

Both approaches can exist.

For a simple POJO:

return "Employee{id=" + id + ", name=" + name + "}";

is fine.

Calling getters may make sense if your class intentionally exposes computed/derived values or has special accessor behavior.

But don't introduce unnecessary complexity.

---

# 50. What should I do when the interviewer gives me an unfamiliar class?

Use this process:

STEP 1:
Read all fields.

STEP 2:
Ask what defines identity.

STEP 3:
Separate identity fields from descriptive fields.

STEP 4:
Implement equals().

STEP 5:
Use exactly the equality fields in hashCode().

STEP 6:
Implement readable toString().

STEP 7:
Think about null.

STEP 8:
Think about mutability.

STEP 9:
Think about inheritance.

STEP 10:
Explain the collection implications.

---

# 51. Practical interview template

When given a class, say:

> "First I'll identify the equality fields."

Then:

> "I'll implement equals() with a reference check, type check, and field comparison."

Then:

> "I'll use the same fields in hashCode() so the equals/hashCode contract is maintained."

Then:

> "I'll implement toString() with useful non-sensitive fields."

Then check:

> "I also want to consider whether the equality fields can change after the object is inserted into a HashSet or used as a HashMap key."

This demonstrates strong understanding.

---

# 52. 15 PRACTICE QUESTIONS AND ANSWERS

## Q1. Why override equals()?

Answer:

> Object.equals() provides identity-based equality by default. We override equals() when the class needs logical/business equality. For example, two Employee objects with the same employee ID may represent the same employee even though they are different object instances.

---

## Q2. Why override hashCode()?

Answer:

> Hash-based collections such as HashMap and HashSet use hashCode() to efficiently locate objects. If we override equals(), we should also override hashCode() so that equal objects always have the same hash code.

---

## Q3. Why override toString()?

Answer:

> The default Object.toString() usually produces a class name and hash-like value, which isn't very useful. Overriding it gives a readable representation that helps with debugging and logging.

---

## Q4. What is the equals/hashCode contract?

Answer:

> If two objects are equal according to equals(), they must have the same hash code. However, two objects can have the same hash code and still not be equal because hash collisions are allowed.

---

## Q5. What happens if you override equals() but not hashCode()?

Answer:

> Equal objects may have different hash codes because they may inherit Object.hashCode(). This can cause incorrect behavior when the objects are used as keys in HashMap or elements in HashSet. Therefore, equals() and hashCode() should be overridden consistently.

---

## Q6. How does HashMap use hashCode() and equals()?

Answer:

> HashMap first uses hashCode() to determine the appropriate bucket or location. If multiple keys map to the same bucket, equals() is used to determine the exact matching key.

Simplified:

    hashCode() -> locate bucket
    equals()   -> find exact key

---

## Q7. How does HashSet determine duplicates?

Answer:

> HashSet uses hashCode() to locate the appropriate bucket and equals() to determine whether an existing object is logically equal to the new object. If an equal object already exists, the new object is not added.

---

## Q8. What happens if a field used in hashCode() changes after insertion into HashSet?

Answer:

> The object's hash code may change, so it may no longer be found in the bucket corresponding to its new hash code. Operations such as contains() or remove() can therefore behave unexpectedly.

---

## Q9. Can two different objects have the same hash code?

Answer:

> Yes. Hash collisions are allowed. Same hash code does not mean objects are equal.

---

## Q10. Can two equal objects have different hash codes?

Answer:

> No. That violates the equals/hashCode contract.

---

## Q11. Which fields should participate in equals()?

Answer:

> Fields that define the logical identity of the object. We should not automatically include every field. The decision depends on the domain/business semantics.

---

## Q12. What is the difference between instanceof and getClass() in equals()?

Answer:

> instanceof allows compatible subclass instances to participate in equality, while getClass() requires the exact same runtime class. With inheritance, the choice matters because equals() must remain symmetric and transitive.

---

## Q13. What happens if the ID is initially null?

Answer:

> It depends on the domain model. Objects with null IDs may be transient and may not represent the same logical entity. If the ID is assigned later, using it in equals/hashCode can also introduce mutability problems. I would clarify the equality semantics for transient objects.

---

## Q14. Should mutable fields be used in equals()?

Answer:

> They can be, but it can be dangerous when the object is used as a HashMap key or HashSet element. If a field used by equals/hashCode changes, the hash code can change and break collection lookup behavior. Stable or immutable identity fields are preferable.

---

## Q15. Why is @Override important?

Answer:

> It tells the compiler that we intend to override a superclass method. It helps catch mistakes such as accidentally writing equals(Employee) instead of correctly overriding equals(Object).

---

# 53. Additional interview questions you should know

## Q16. What are the properties of equals()?

Answer:

equals() should be:

1. Reflexive
2. Symmetric
3. Transitive
4. Consistent
5. False when compared with null

---

## Q17. What is the difference between == and equals()?

Answer:

> For objects, == compares references, while equals() compares logical equality according to the implementation.

Example:

String a = new String("Java");
String b = new String("Java");

a == b          // false
a.equals(b)     // true

---

## Q18. Can hashCode() be constant?

Answer:

> Yes, technically. But it causes many collisions and can significantly degrade HashMap/HashSet performance.

---

## Q19. Can hashCode() be random?

Answer:

> No, not as a normal implementation. hashCode() should be consistent for an unchanged object. Returning random values can break hash-based collection behavior.

---

## Q20. Can equals() use toString()?

Answer:

> Technically you could compare strings, but it is bad design. toString() is intended for human-readable representation, not defining object identity.

---

## Q21. Should toString() contain sensitive fields?

Answer:

> No. Passwords, tokens, secrets, payment details, and other sensitive information should not normally be included in toString() because objects can be logged accidentally.

---

## Q22. Does an array use content equality automatically?

Answer:

> No. Arrays inherit Object.equals(), so normal array equality is reference-based. Use Arrays.equals() for content equality and Arrays.hashCode() for content-based hashing.

---

## Q23. What about List fields?

Answer:

> List.equals() generally compares elements in order, so Objects.equals(list1, list2) is appropriate when list content and ordering are part of the equality semantics.

---

## Q24. What about Set fields?

Answer:

> Set.equals() compares set contents, not iteration order. Therefore two sets containing the same elements are logically equal.

---

## Q25. What is the issue with BigDecimal?

Answer:

> BigDecimal.equals() considers scale. Therefore new BigDecimal("10.0") and new BigDecimal("10.00") are not equal according to equals(), although compareTo() returns zero.

---

# 54. Full manual implementation without Objects

If the interviewer says:

> "Don't use Objects.equals() or Objects.hash(). Write everything yourself."

You should be able to do it.

Example:

public class Employee {

    private Long id;
    private String name;

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof Employee)) {
            return false;
        }

        Employee other = (Employee) o;

        if (id == null) {
            if (other.id != null) {
                return false;
            }
        } else {
            if (!id.equals(other.id)) {
                return false;
            }
        }

        return true;
    }

    @Override
    public int hashCode() {

        int result = 17;

        result = 31 * result + (id == null ? 0 : id.hashCode());

        return result;
    }

    @Override
    public String toString() {

        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                '}';
    }
}

The important thing is not memorizing the exact 17/31 implementation.

Understand the principle.

---

# 55. What if all fields participate?

Example:

public class Employee {

    private Long id;
    private String name;
    private String department;

    @Override
    public boolean equals(Object o) {

        if (this == o) {
            return true;
        }

        if (!(o instanceof Employee)) {
            return false;
        }

        Employee other = (Employee) o;

        return Objects.equals(id, other.id)
                && Objects.equals(name, other.name)
                && Objects.equals(department, other.department);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, name, department);
    }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", department='" + department + '\'' +
                '}';
    }
}

Notice the important relationship:

equals():

    id
    name
    department

hashCode():

    id
    name
    department

Same equality fields.

---

# 56. A very common interview mistake

Bad:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    Employee other = (Employee) o;

    return id.equals(other.id);
}

Problems:

1. No null check.
2. No type check.
3. Potential ClassCastException.
4. Potential NullPointerException.

Better:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Employee)) {
        return false;
    }

    Employee other = (Employee) o;

    return Objects.equals(id, other.id);
}

---

# 57. Another common mistake

Bad:

@Override
public boolean equals(Object o) {
    ...
    return Objects.equals(id, other.id)
            && Objects.equals(name, other.name);
}

@Override
public int hashCode() {
    return Objects.hash(id);
}

Problem:

equals() uses:

    id + name

hashCode() uses:

    id

This is not necessarily a direct contract violation because unequal objects can have the same hash code.

But it is a poor implementation because it unnecessarily increases collisions.

Better:

@Override
public int hashCode() {
    return Objects.hash(id, name);
}

---

# 58. Another common mistake

Bad:

public boolean equals(Employee employee) {
    ...
}

This does NOT override Object.equals(Object).

Correct:

@Override
public boolean equals(Object o) {
    ...
}

Use @Override so the compiler catches mistakes.

---

# 59. Another common mistake

Bad:

@Override
public int hashCode() {
    return (int) id;
}

This can be problematic for Long values because converting a Long to int can lose information.

Better:

return Objects.hash(id);

or:

return id == null ? 0 : id.hashCode();

---

# 60. Interview coding challenge

Interviewer:

"Write equals(), hashCode(), and toString() for this class."

class Customer {

    private Long customerId;
    private String email;
    private String name;
    private String password;

}

They tell you:

> customerId uniquely identifies the customer.

Your thought process should be:

    Equality field = customerId

Therefore:

equals()   -> customerId
hashCode() -> customerId
toString() -> customerId + email + name

Do NOT include password in toString().

Implementation:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Customer)) {
        return false;
    }

    Customer other = (Customer) o;

    return Objects.equals(customerId, other.customerId);
}

@Override
public int hashCode() {
    return Objects.hash(customerId);
}

@Override
public String toString() {
    return "Customer{" +
            "customerId=" + customerId +
            ", email='" + email + '\'' +
            ", name='" + name + '\'' +
            '}';
}

---

# 61. How to handle pressure during the interview

If you forget the exact code, don't panic.

Say:

> "I'll build this step by step."

Then write:

@Override
public boolean equals(Object o) {

    if (this == o) {
        return true;
    }

    if (!(o instanceof Employee)) {
        return false;
    }

    Employee other = (Employee) o;

    // compare identity fields
}

Then:

@Override
public int hashCode() {

    // same fields used in equals
}

Then:

@Override
public String toString() {

    // readable representation
}

This demonstrates that you understand the design even if you need a moment for syntax.

---

# 62. The fastest way to remember equals()

Remember:

    SAME
      |
      v
    TYPE
      |
      v
    CAST
      |
      v
    COMPARE

Code:

if (this == o) {
    return true;
}

if (!(o instanceof Employee)) {
    return false;
}

Employee other = (Employee) o;

return Objects.equals(id, other.id);

---

# 63. The fastest way to remember hashCode()

Remember:

> Whatever participates in equals() should participate consistently in hashCode().

Example:

equals:

Objects.equals(id, other.id)
&& Objects.equals(name, other.name)

Then:

hashCode:

Objects.hash(id, name)

Simple.

---

# 64. The fastest way to remember toString()

Remember:

> Class name + useful fields - sensitive data.

Example:

return "Employee{" +
        "id=" + id +
        ", name='" + name + '\'' +
        ", department='" + department + '\'' +
        '}';

---

# 65. The most important mental model

When you see:

class Employee {
    Long id;
    String name;
    String department;
}

Don't immediately think:

> "How do I generate equals/hashCode?"

Think:

> "What makes two Employees the same?"

If answer:

    id

Then:

    equals  -> id
    hashCode -> id
    toString -> useful information

If answer:

    id + name

Then:

    equals  -> id + name
    hashCode -> id + name
    toString -> useful information

That's the real interview skill.

---

# 66. Final interview checklist

Before you finish your answer, mentally check:

[ ] Did I use @Override?

[ ] Did I check this == o?

[ ] Did I check the type?

[ ] Did I safely compare null values?

[ ] Did I identify the correct equality fields?

[ ] Does hashCode() use the same equality fields?

[ ] Did I think about mutable fields?

[ ] Did I think about HashMap/HashSet behavior?

[ ] Did I consider inheritance?

[ ] Does toString() contain useful information?

[ ] Did I avoid passwords/secrets/sensitive data?

[ ] If arrays are involved, did I use Arrays.equals/hashCode?

[ ] If BigDecimal is involved, did I consider equals vs compareTo?

---

# 67. The 30-second answer to impress the interviewer

If the interviewer asks:

> "Explain how you would implement equals(), hashCode() and toString()."

A strong answer is:

> "First, I would identify the fields that define the logical identity of the object. In equals(), I would first check reference equality, then verify the object type, cast it, and compare the identity fields safely, usually with Objects.equals(). I would use those same identity fields in hashCode() because equal objects must have equal hash codes. This is important for HashMap and HashSet. For toString(), I would provide a readable representation of the useful fields while avoiding sensitive information. I would also consider nullability, mutability, and inheritance because they can affect the correctness of equals() and hashCode()."

---

# 68. Final cheat sheet

MEMORIZE THIS:

    equals()
    --------
    Defines logical equality.

    hashCode()
    ----------
    Equal objects MUST have the same hash code.

    toString()
    ----------
    Human-readable representation.

    HashMap
    -------
    hashCode() -> locate bucket
    equals()   -> find exact key

    HashSet
    -------
    hashCode() -> locate bucket
    equals()   -> detect duplicate

    equals() rules
    -------------
    Reflexive
    Symmetric
    Transitive
    Consistent
    false for null

    Best pattern
    ------------
    if (this == o)
        return true;

    if (!(o instanceof Employee))
        return false;

    Employee other = (Employee) o;

    return Objects.equals(identityField, other.identityField);

    hashCode()
    ----------
    return Objects.hash(identityField);

    toString()
    ----------
    return "Employee{" +
            "id=" + id +
            ", name='" + name + '\'' +
            '}';

    Golden rule
    -----------
    SAME fields in equals() and hashCode().

    Critical warning
    ----------------
    Don't mutate fields used by equals()/hashCode()
    while the object is inside HashSet or used as a HashMap key.

---

# 69. One final interview mindset

Don't treat this question as:

> "Can I remember the generated Java code?"

Treat it as:

> "Can I define equality correctly for an object?"

The interviewer may change:

    Employee
    Customer
    Product
    Order
    Address
    User
    Account

The syntax stays almost the same.

The real question changes:

> "What makes two instances of this class logically the same?"

Once you answer that, the implementation becomes much easier.

The sequence to remember is:

    UNDERSTAND IDENTITY
           ↓
       equals()
           ↓
       hashCode()
           ↓
       toString()
           ↓
    CHECK COLLECTIONS
           ↓
    CHECK NULLABILITY
           ↓
    CHECK MUTABILITY
           ↓
    CHECK INHERITANCE

If you can explain this sequence while coding, you are demonstrating understanding rather than simply reproducing IDE-generated code.