# Java `equals()` and `hashCode()` — Employee

## 1. Definition

- `equals(Object)` tests **logical equality**. The default `Object.equals` uses reference identity (`==`).
- `hashCode()` returns an `int` used by hash-based collections such as `HashMap` and `HashSet` to locate candidate entries.
- `==` on references asks whether they refer to the **same object**; `equals()` can ask whether different objects represent the **same value/entity**.
- Default `Object.hashCode()` is identity-consistent, but **is not guaranteed to be a memory address or unique**.

## 2. Contracts (must memorize)

`equals()` must be **reflexive**, **symmetric**, **transitive**, **consistent** (while relevant state stays unchanged), and return `false` for `null`.

`hashCode()` must be consistent while equality-relevant state remains unchanged. **If `a.equals(b)`, then `a.hashCode() == b.hashCode()`**. The reverse is **not** required: unequal objects may share a hash (collision).

**Rule:** Override both together. Base both on the **same fields**.

## 3. Complete copyable example — `EmployeeInterviewDemo.java`

This example defines equality by **employee ID only**. Names and salaries are descriptive, not identity fields. The ID is `final` so an employee's hash remains stable in a `HashSet` or as a `HashMap` key.

```java
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

public class EmployeeInterviewDemo {

    static final class Employee {
        private final int id;             // Immutable identity
        private String name;              // Not part of equality
        private double salary;            // Not part of equality

        Employee(int id, String name, double salary) {
            this.id = id;
            this.name = name;
            this.salary = salary;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;                 // Same reference
            if (!(obj instanceof Employee)) return false; // Handles null
            Employee other = (Employee) obj;
            return this.id == other.id;                   // Logical identity
        }

        @Override
        public int hashCode() {
            return Integer.hashCode(id); // Same field as equals()
        }

        @Override
        public String toString() {
            return "Employee{id=" + id + ", name='" + name
                    + "', salary=" + salary + "}";
        }

        void setName(String name) { this.name = name; }
        void setSalary(double salary) { this.salary = salary; }
    }

    public static void main(String[] args) {
        Employee e1 = new Employee(101, "Raj", 50000);
        Employee e2 = new Employee(101, "Rajesh", 60000);
        Employee e3 = new Employee(102, "Raj", 50000);
        Employee alias = e1;

        // 1. Reference equality vs logical equality
        System.out.println(e1 == e2);                  // false
        System.out.println(e1.equals(e2));             // true: same ID
        System.out.println(e1.equals(e3));             // false
        System.out.println(e1 == alias);               // true
        System.out.println(e1.equals(null));           // false
        System.out.println(e1.equals("not employee")); // false

        // 2. Equal objects must have equal hash codes
        System.out.println(e1.hashCode() == e2.hashCode()); // true

        // 3. HashSet: logical duplicates are rejected
        Set<Employee> employees = new HashSet<>();
        employees.add(e1);
        employees.add(e2); // Duplicate ID: not added
        employees.add(e3);
        System.out.println(employees.size()); // 2
        System.out.println(employees.contains(
                new Employee(101, "Someone", 1))); // true

        // 4. HashMap: logically equal key replaces the value
        Map<Employee, String> departments = new HashMap<>();
        departments.put(e1, "IT");
        departments.put(e2, "HR"); // Same logical key; updates value
        System.out.println(departments.size()); // 1
        System.out.println(departments.get(
                new Employee(101, "Other", 0))); // HR

        // 5. Changing non-identity fields is safe for hashing
        e1.setName("Updated Raj");
        e1.setSalary(70000);
        System.out.println(employees.contains(e1)); // true

        // 6. A hash collision does NOT mean equality
        Employee c1 = new Employee(7, "A", 0);
        Employee c2 = new Employee(7, "B", 0);
        System.out.println(c1.equals(c2)); // true by chosen ID rule
        System.out.println(Objects.equals(e1, e2)); // true, null-safe
    }
}
```

Run with:

```bash
javac EmployeeInterviewDemo.java
java EmployeeInterviewDemo
```

**Design choice:** This example assumes IDs are globally unique. If an ID is only unique **within a company**, use both `companyId` and `employeeId` in **both** methods.

## 4. Alternative: equality based on multiple fields

For a value object where `id` and `name` both define equality:

```java
@Override
public boolean equals(Object obj) {
    if (this == obj) return true;
    if (!(obj instanceof Employee)) return false;
    Employee other = (Employee) obj;
    return id == other.id && Objects.equals(name, other.name);
}

@Override
public int hashCode() {
    return Objects.hash(id, name);
}
```

This is an **alternative implementation**, not a replacement for the ID-only example unless you intentionally change the identity rule. Avoid mutable `name` in hash keys; prefer immutable fields.

### Manual hash formula (common interview request)

```java
@Override
public int hashCode() {
    int result = 17;
    result = 31 * result + Integer.hashCode(id);
    // Only include name if equals() also compares name:
    // result = 31 * result + (name == null ? 0 : name.hashCode());
    return result;
}
```

`31` is a conventional multiplier, **not a mandatory number**. `Objects.hash(id, name)` is convenient but may allocate a varargs array; for a single `int`, `Integer.hashCode(id)` is simpler.

## 5. How `HashMap` and `HashSet` use the methods

1. Compute the key's `hashCode()` (HashMap may mix the bits internally).
2. Choose a bucket based on the hash and table capacity.
3. Within candidate entries, compare hash and key equality (`==` or `equals()`).
4. Equal keys update the existing map entry; `HashSet` rejects logical duplicates.
5. Collisions can coexist in one bucket when keys are **not equal**. Java 8+ `HashMap` can treeify crowded buckets under certain conditions.

`hashCode()` alone **never proves equality**. `HashMap` does not simply call `equals()` on every key in the whole map.

## 6. Tricky interview Q&A — simple answers (Q1–Q25)

**How to study:** Read the question, say the short answer aloud, then check the example.

**Q1. Why do we override both `equals()` and `hashCode()`?**

**Answer:** `equals()` tells Java whether two employees represent the same employee. `hashCode()` helps `HashMap` and `HashSet` find them. Equal employees must have equal hash codes.

**Example / interview tip:** Two `Employee(101)` objects should be treated as one employee in a `HashSet`.

**Q2. Can two different objects have the same hash code?**

**Answer:** Yes. This is called a **hash collision**. Java uses `equals()` to check whether they are actually equal.

**Example / interview tip:** `"FB"` and `"Ea"` have the same `String.hashCode()` but are not equal.

**Q3. Can two equal objects have different hash codes?**

**Answer:** No. That breaks the Java contract.

**Example / interview tip:** If `e1.equals(e2)` is `true`, their hash codes must match.

**Q4. Is a hash code a unique ID or memory address?**

**Answer:** No. It is just an integer used for hashing. Different objects may share it.

**Example / interview tip:** Do not use `hashCode()` as an employee ID.

**Q5. What is the difference between `==` and `equals()`?**

**Answer:** For objects, `==` checks whether both references point to the same object. `equals()` can compare actual values.

**Example / interview tip:** `new String("Java") == new String("Java")` is `false`; `.equals()` is `true`.

**Q6. What if I override only `equals()`?**

**Answer:** Two equal objects might get different hash codes, so `HashSet` may store both and `HashMap` lookups may fail.

**Example / interview tip:** Always override `hashCode()` whenever you override `equals()`.

**Q7. What if I override only `hashCode()`?**

**Answer:** Objects can have the same hash but still be unequal because the default `equals()` compares references.

**Example / interview tip:** Same hash does **not** mean same employee.

**Q8. Can `hashCode()` always return `1`?**

**Answer:** Yes, it can satisfy the contract, but it is a bad idea: too many collisions make hash collections slower.

**Example / interview tip:** Correct but inefficient.

**Q9. Why should employee ID be immutable?**

**Answer:** If the ID is used in hashing and changes after insertion, Java may search the wrong hash bucket.

**Example / interview tip:** Prefer `private final int id;`.

**Q10. Can `HashSet` store two employees with the same ID?**

**Answer:** Not if `equals()` and `hashCode()` both use ID and are implemented correctly. The second equal employee is not added.

**Example / interview tip:** `set.add(e1)` → `true`; `set.add(e2)` → `false` for equal IDs.

**Q11. What happens if I put two equal Employee keys into a `HashMap`?**

**Answer:** The second `put()` updates the value for the existing key. The map still has one entry.

**Example / interview tip:** `map.put(e1,"IT"); map.put(e2,"HR");` → size `1`, value `"HR"`.

**Q12. Does `HashMap` maintain insertion order?**

**Answer:** No. Use `LinkedHashMap` if you need insertion order.

**Example / interview tip:** Do not depend on `HashMap` iteration order.

**Q13. Can `HashMap` and `HashSet` store `null`?**

**Answer:** Yes. `HashMap` allows one null key and null values. `HashSet` allows one null element.

**Example / interview tip:** `ConcurrentHashMap` does not allow null keys or values.

**Q14. Should I use `getClass()` or `instanceof` inside `equals()`?**

**Answer:** `getClass()` accepts only the exact same class. `instanceof` also accepts subclasses. Both require careful design.

**Example / interview tip:** For a simple Employee class, `getClass()` is easy to explain.

**Q15. Why write `if (this == obj) return true;`?**

**Answer:** If both references point to the same object, they are obviously equal. This is a quick check.

**Example / interview tip:** It is an optimization, not a requirement.

**Q16. Why use `Objects.equals(a, b)`?**

**Answer:** It safely compares objects even when one or both values are null.

**Example / interview tip:** `Objects.equals(null, null)` → `true`.

**Q17. Why use `Objects.hash(...)`?**

**Answer:** It is a short way to create a hash code from multiple fields.

**Example / interview tip:** `return Objects.hash(id, name);` — only if both fields define equality.

**Q18. What are the main rules of `equals()`?**

**Answer:** An object equals itself; equality works both ways; equality stays consistent across chains; repeated checks stay stable when relevant data is unchanged; a non-null object is never equal to null.

**Example / interview tip:** Remember: reflexive, symmetric, transitive, consistent, non-null.

**Q19. How do we compare array fields?**

**Answer:** Arrays do not compare contents with their normal `equals()`. Use matching methods from `Arrays`.

**Example / interview tip:** `Arrays.equals(a,b)` with `Arrays.hashCode(a)`; use deep variants for nested arrays.

**Q20. How should we compare `double` fields?**

**Answer:** Use `Double.compare(a,b) == 0` and `Double.hashCode(a)` to handle special values consistently.

**Example / interview tip:** `0.0` and `-0.0` are distinguished by `Double.compare()`.

**Q21. What if two real employees accidentally have the same ID?**

**Answer:** If ID defines equality, Java treats them as equal. Your business rule must guarantee IDs are unique.

**Example / interview tip:** Decide the equality rule before writing code.

**Q22. What if the employee ID is assigned later?**

**Answer:** Avoid using an employee as a hash key until its identity is stable, or choose a different immutable identity.

**Example / interview tip:** Changing an ID after `map.put()` can break lookups.

**Q23. Are `equals()` and `hashCode()` automatically thread-safe?**

**Answer:** No. Reading only a final immutable ID is straightforward, but reading mutable fields concurrently may need synchronization.

**Example / interview tip:** Thread-safe collection and thread-safe key are different things.

**Q24. Do Java records generate these methods?**

**Answer:** Yes. Records generate `equals()` and `hashCode()` using all record components.

**Example / interview tip:** `record Employee(int id, String name) {}` compares both ID and name.

**Q25. Does a hash collision always make `HashMap` O(n)?**

**Answer:** No. Modern `HashMap` can use tree bins for some heavily-colliding buckets. Good hash distribution still matters.

**Example / interview tip:** A collision does not automatically mean a slow lookup.

## 7. Classic trap: mutable keys

```java
// BAD DESIGN: id is mutable and used in equals/hashCode.
// Employee e = new Employee(101, "Raj");
// map.put(e, "IT");
// e.setId(999); // Hash changes; lookup may fail.
// map.get(e);   // Can return null despite entry still existing.
```

## 8. 30-second interview answer

> `equals()` defines logical equality; `hashCode()` supports efficient lookup in hash-based collections. If two objects are equal, their hash codes must match, but equal hashes do not imply equal objects. For an Employee entity, I usually compare an immutable unique employee ID in both methods. This ensures that HashMap and HashSet recognize logically equal employees correctly. Mutable equality fields are dangerous when objects are used as hash keys.

**Memory trick:** `equals()` decides **same logical object?**; `hashCode()` helps find **where to look?**

---

## 9. Custom all-fields equality: primitive, wrappers, String, nested object, and mutable fields

The earlier `EmployeeInterviewDemo` uses **ID-only equality**, which is generally safer for entities used as hash keys. The following **separate, runnable** example demonstrates **all-fields equality** for interview questions. Save as `EmployeeAllFieldsDemo.java`.

**Equality rule in this example:** two employees are equal only when `id`, `age`, `salary`, `name`, and `address` all match. This is a *value-based* rule, not necessarily the best business rule for employee entities.

```java
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class EmployeeAllFieldsDemo {

    static final class Address {
        private String city;  // Mutable nested field
        private String state; // Mutable nested field

        Address(String city, String state) {
            this.city = city;
            this.state = state;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true; // Same reference
            if (obj == null || getClass() != obj.getClass()) return false;
            Address other = (Address) obj;
            // Compare contents, not references; null-safe.
            return Objects.equals(city, other.city)
                    && Objects.equals(state, other.state);
        }

        @Override
        public int hashCode() {
            // Exactly the fields used by Address.equals().
            int result = 1;
            result = 31 * result + Objects.hashCode(city);
            result = 31 * result + Objects.hashCode(state);
            return result;
        }
    }

    static final class Employee {
        private final int id;  // Primitive, immutable
        private Integer age;   // Wrapper, nullable/mutable
        private Double salary; // Wrapper, nullable/mutable
        private String name;   // String reference can be reassigned
        private Address address; // Nested object can change internally

        Employee(int id, Integer age, Double salary,
                 String name, Address address) {
            this.id = id;
            this.age = age;
            this.salary = salary;
            this.name = name;
            this.address = address;
        }

        @Override
        public boolean equals(Object obj) {
            // 1. Fast path: both references point to the same instance.
            if (this == obj) return true;

            // 2. Null or a different runtime class cannot be equal.
            if (obj == null || getClass() != obj.getClass()) return false;

            // 3. Safe cast after checking the class.
            Employee other = (Employee) obj;

            // 4. Primitive int: compare with ==.
            // 5. Wrappers, String, nested object: null-safe value equality.
            //    Address must implement its own equals() for value equality.
            return id == other.id
                    && Objects.equals(age, other.age)
                    && Objects.equals(salary, other.salary)
                    && Objects.equals(name, other.name)
                    && Objects.equals(address, other.address);
        }

        @Override
        public int hashCode() {
            // 1. Start from a nonzero value.
            int result = 1;

            // 2. Multiply by 31 and combine every equality field.
            result = 31 * result + Integer.hashCode(id);
            result = 31 * result + Objects.hashCode(age);
            result = 31 * result + Objects.hashCode(salary);
            result = 31 * result + Objects.hashCode(name);
            result = 31 * result + Objects.hashCode(address);
            return result;
        }

        // Alternative, more concise implementation (do not declare both):
        // @Override
        // public int hashCode() {
        //     return Objects.hash(id, age, salary, name, address);
        // }
    }

    public static void main(String[] args) {
        Employee e1 = new Employee(101, 25, 50000.0, "Rahul",
                new Address("Mumbai", "MH"));
        Employee e2 = new Employee(101, 25, 50000.0, "Rahul",
                new Address("Mumbai", "MH"));
        Employee e3 = new Employee(102, 30, 60000.0, "Amit",
                new Address("Pune", "MH"));

        System.out.println(e1 == e2);                    // false: different objects
        System.out.println(e1.equals(e2));               // true: same values
        System.out.println(e1.equals(e3));               // false
        System.out.println(e1.hashCode() == e2.hashCode()); // true: required

        Set<Employee> employees = new HashSet<>();
        employees.add(e1);
        employees.add(e2); // Duplicate by equality; not added
        employees.add(e3);
        System.out.println(employees.size());            // 2
    }
}
```

### How the custom methods work

1. **`this == obj`**: identical references are automatically equal.
2. **`obj == null || getClass() != obj.getClass()`**: reject null and different runtime classes; using `final` classes avoids subclass equality surprises.
3. **Cast to `Employee`**: safe after the class check.
4. **`id == other.id`**: compare primitive `int` values directly.
5. **`Objects.equals(age, other.age)`**: compare wrapper values, not `Integer` object references; handles null.
6. **`Objects.equals(name, other.name)`**: compare string contents, not string references.
7. **`Objects.equals(address, other.address)`**: delegates to `Address.equals()`; without its override, different `Address` instances with the same fields would not compare equal.
8. **`31 * result + fieldHash`**: combines field hashes. The number `31` is a conventional multiplier, not a Java requirement. Integer overflow is allowed and deterministic.
9. **Same equality fields in both methods**: if `equals()` checks five fields, the hash must remain consistent with those fields. Using all five is the normal choice; a constant hash would technically meet the contract but perform poorly.

### Wrapper and floating-point traps

```java
Integer a = 1000;
Integer b = 1000;
System.out.println(a == b);                 // false for these separately boxed values
System.out.println(Objects.equals(a, b));   // true

Double x = null;
Double y = null;
System.out.println(Objects.equals(x, y));   // true; no NullPointerException

// For primitive doubles, use Double.compare and Double.hashCode together:
double p = 1.5, q = 1.5;
System.out.println(Double.compare(p, q) == 0); // true
System.out.println(Double.hashCode(p) == Double.hashCode(q)); // true
```

**Why `Double` wrapper comparison is different from primitive `==`:** `Double.equals()` uses the wrapper's defined value semantics (including special handling of NaN and signed zero). `Objects.equals()` delegates to `Double.equals()` when both values are non-null. For primitive `double` fields, use `Double.compare(a, b) == 0` paired with `Double.hashCode(a)`.

### The mutable-field problem: a working demonstration

```java
import java.util.HashSet;
import java.util.Objects;
import java.util.Set;

public class MutableHashKeyTrap {
    static final class Employee {
        private final int id;
        private String name;

        Employee(int id, String name) {
            this.id = id;
            this.name = name;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj) return true;
            if (!(obj instanceof Employee)) return false;
            Employee other = (Employee) obj;
            return id == other.id && Objects.equals(name, other.name);
        }

        @Override
        public int hashCode() {
            return Objects.hash(id, name);
        }
    }

    public static void main(String[] args) {
        Employee e = new Employee(101, "Raj");
        Set<Employee> set = new HashSet<>();
        set.add(e);
        System.out.println(set.contains(e)); // true

        e.name = "Amit"; // BAD: changes equality/hash fields after insertion
        // set.contains(e) may now return false, even though e is still in set.
        System.out.println("Contains after mutation: " + set.contains(e));
    }
}
```

**Safer alternative:** For a real employee entity with an immutable unique ID, compare and hash **only `id`**, as shown in section 3. Then changing `name`, `age`, `salary`, or `address` does not change the key's hash or equality. Note that `final Address address` alone does **not** make the address's internal fields immutable.

### Additional interview Q&A — simple answers (Q26–Q35)

**Q26. How many common ways are there to write these methods?**

**Answer:** Five common approaches: manual code, `Objects` utilities, IDE generation, Lombok, and records. This is not a fixed Java language count.

**Example / interview tip:** In interviews, show manual code first.

**Q27. Why not compare `Integer` or `Long` using `==`?**

**Answer:** For two wrapper references, `==` compares identity, not numeric value. Use `Objects.equals()`.

**Example / interview tip:** `Integer.valueOf(1000) == Integer.valueOf(1000)` is usually `false`; `.equals()` is `true`.

**Q28. What if `Address` does not override `equals()`?**

**Answer:** Two separate Address objects with identical values will still compare unequal by default.

**Example / interview tip:** Implement `equals()` and `hashCode()` in Address too for value-based comparison.

**Q29. Can mutable fields be included in equality?**

**Answer:** Yes, but it is risky for `HashMap` keys and `HashSet` elements if those fields change after insertion.

**Example / interview tip:** Prefer immutable ID-based equality for Employee entities.

**Q30. Can `hashCode()` use fewer fields than `equals()`?**

**Answer:** Yes, if equal objects still always get the same hash. But it may cause more collisions.

**Example / interview tip:** Never hash a field that `equals()` ignores if it can differ between equal objects.

**Q31. Why might manual hashing be faster than `Objects.hash()`?**

**Answer:** `Objects.hash()` uses varargs and can involve extra allocations or boxing. Manual hashing gives more control.

**Example / interview tip:** Performance difference usually matters only in hot code.

**Q32. Should Employee equality use ID only or all fields?**

**Answer:** It depends on the business meaning. Use ID only when ID uniquely identifies an employee. Use all fields when the entire value matters.

**Example / interview tip:** For a database-like Employee entity, immutable ID is usually better.

**Q33. What if Employee contains an array or a `List`?**

**Answer:** Use `Arrays.equals/hashCode` for arrays. Lists already compare elements, but changing a list can change the employee hash.

**Example / interview tip:** Avoid mutable collections in hash keys.

**Q34. Which is safer with inheritance: `getClass()` or `instanceof`?**

**Answer:** Neither is universally best. `getClass()` prevents equality across subclasses; `instanceof` requires care to avoid breaking symmetry.

**Example / interview tip:** A `final` value class is easiest to reason about.

**Q35. Does `hashCode()` have to be unique?**

**Answer:** No. Equal objects must share a hash, but unequal objects can also share one.

**Example / interview tip:** Hash identifies a bucket, not a unique employee.

**Final interview takeaway:** First decide what makes two employees equal. Then use the **same equality-relevant fields** in both methods. If an employee is used as a `HashMap` key or `HashSet` element, prefer a stable, immutable ID.
