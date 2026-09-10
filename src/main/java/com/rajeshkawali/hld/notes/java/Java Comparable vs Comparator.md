# Comparable vs Comparator in Java

`Comparable` and `Comparator` are both used to **define ordering for objects**, especially when sorting collections.

For example, suppose we have:

```java
class Employee {
    private int id;
    private String name;
    private double salary;
}
```

If we have:

```java
List<Employee> employees;
```

and want to sort employees, Java needs to know:

> "How should two Employee objects be compared?"

This is where `Comparable` and `Comparator` are used.

---

# 1. Comparable

`Comparable` is used when a class has a **natural/default ordering**.

It is present in:

```java
java.lang.Comparable
```

It has one important method:

```java
int compareTo(T other);
```

### Basic syntax

```java
class Employee implements Comparable<Employee> {

    @Override
    public int compareTo(Employee other) {
        return this.id - other.id;
    }
}
```

Now `Employee` has a natural ordering based on `id`.

---

# 2. Comparable Example

```java
import java.util.*;

class Employee implements Comparable<Employee> {

    private int id;
    private String name;
    private double salary;

    public Employee(int id, String name, double salary) {
        this.id = id;
        this.name = name;
        this.salary = salary;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public double getSalary() {
        return salary;
    }

    @Override
    public int compareTo(Employee other) {
        return Integer.compare(this.id, other.id);
    }

    @Override
    public String toString() {
        return id + " " + name + " " + salary;
    }
}
```

Now:

```java
List<Employee> employees = new ArrayList<>();

employees.add(new Employee(3, "John", 50000));
employees.add(new Employee(1, "Alice", 70000));
employees.add(new Employee(2, "Bob", 60000));

Collections.sort(employees);
```

Output:

```text
1 Alice 70000
2 Bob 60000
3 John 50000
```

Because `compareTo()` compares employees by `id`.

---

# 3. How compareTo() Works

The return value of `compareTo()` has three meanings.

```java
this.compareTo(other)
```

### Negative

```text
this < other
```

Example:

```java
1.compareTo(2)
```

returns a negative value.

### Zero

```text
this == other
```

Example:

```java
2.compareTo(2)
```

returns `0`.

### Positive

```text
this > other
```

Example:

```java
3.compareTo(2)
```

returns a positive value.

### Important

You should generally think in terms of:

```text
negative
zero
positive
```

rather than assuming the result will specifically be `-1`, `0`, or `1`.

---

# 4. Better Way to Write compareTo()

Avoid:

```java
return this.id - other.id;
```

Although commonly seen, subtraction can overflow for extreme integer values.

Prefer:

```java
return Integer.compare(this.id, other.id);
```

For `long`:

```java
return Long.compare(this.id, other.id);
```

For `double`:

```java
return Double.compare(this.salary, other.salary);
```

---

# 5. Comparator

`Comparator` is used when you want to define **external/custom ordering**.

It is present in:

```java
java.util.Comparator
```

It has the main method:

```java
int compare(T o1, T o2);
```

Example:

```java
Comparator<Employee> bySalary =
        (e1, e2) -> Double.compare(
                e1.getSalary(),
                e2.getSalary()
        );
```

Now employees can be sorted by salary.

---

# 6. Comparator Example

Using the same `Employee` class:

```java
List<Employee> employees = new ArrayList<>();

employees.add(new Employee(3, "John", 50000));
employees.add(new Employee(1, "Alice", 70000));
employees.add(new Employee(2, "Bob", 60000));
```

Sort by salary:

```java
employees.sort(
    Comparator.comparingDouble(Employee::getSalary)
);
```

Output:

```text
John 50000
Bob 60000
Alice 70000
```

The class itself does not need to change.

---

# 7. Why Do We Need Comparator?

Suppose `Employee` has many possible ways to sort:

```text
By ID
By Name
By Salary
By Age
By Department
By Joining Date
```

If we use `Comparable`, we generally define one natural ordering inside the class.

But we can create multiple `Comparator`s:

```java
Comparator<Employee> byId =
        Comparator.comparingInt(Employee::getId);

Comparator<Employee> byName =
        Comparator.comparing(Employee::getName);

Comparator<Employee> bySalary =
        Comparator.comparingDouble(Employee::getSalary);
```

Then:

```java
employees.sort(byId);
```

or:

```java
employees.sort(byName);
```

or:

```java
employees.sort(bySalary);
```

This is the biggest practical advantage of `Comparator`.

---

# 8. Comparable vs Comparator — Main Difference

| Feature | Comparable | Comparator |
|---|---|---|
| Package | `java.lang` | `java.util` |
| Main method | `compareTo()` | `compare()` |
| Where ordering is defined | Inside the class | Outside the class |
| Purpose | Natural/default ordering | Custom/alternative ordering |
| Number of orderings | Usually one natural ordering | Multiple possible orderings |
| Modifies original class? | Yes, class implements interface | No |
| Usage | `Collections.sort(list)` / `list.sort(null)` | `list.sort(comparator)` |
| Lambda | Not normally used as a lambda for class declaration | Commonly used |
| Best when | Class has one obvious natural order | Different sorting strategies are needed |
| Example | Employee by ID | Employee by salary/name |

---

# 9. Comparable Example — Natural Ordering

Suppose:

```java
class Student implements Comparable<Student> {

    private int rollNo;
    private String name;

    @Override
    public int compareTo(Student other) {
        return Integer.compare(
                this.rollNo,
                other.rollNo
        );
    }
}
```

Here:

```text
Student
   ↓
Natural ordering
   ↓
rollNo
```

So:

```java
Collections.sort(students);
```

means:

> Sort students according to their `compareTo()` implementation.

---

# 10. Comparator Example — Multiple Sort Options

```java
Comparator<Student> byName =
        Comparator.comparing(Student::getName);

Comparator<Student> byRollNo =
        Comparator.comparingInt(Student::getRollNo);
```

Now:

```java
students.sort(byName);
```

means:

```text
Sort by name
```

while:

```java
students.sort(byRollNo);
```

means:

```text
Sort by roll number
```

The `Student` class doesn't need to change.

---

# 11. Comparator Using Lambda

Modern Java makes Comparator very easy.

```java
Comparator<Employee> bySalary =
        (e1, e2) ->
                Double.compare(
                    e1.getSalary(),
                    e2.getSalary()
                );
```

Then:

```java
employees.sort(bySalary);
```

You can also write:

```java
employees.sort(
    (e1, e2) ->
        Double.compare(
            e1.getSalary(),
            e2.getSalary()
        )
);
```

---

# 12. Comparator.comparing()

A cleaner modern approach is:

```java
employees.sort(
    Comparator.comparing(Employee::getName)
);
```

For integer fields:

```java
employees.sort(
    Comparator.comparingInt(Employee::getId)
);
```

For double:

```java
employees.sort(
    Comparator.comparingDouble(Employee::getSalary)
);
```

For long:

```java
employees.sort(
    Comparator.comparingLong(Employee::getId)
);
```

---

# 13. Descending Order

By default:

```java
employees.sort(
    Comparator.comparingDouble(Employee::getSalary)
);
```

sorts ascending.

For descending:

```java
employees.sort(
    Comparator.comparingDouble(Employee::getSalary)
            .reversed()
);
```

Example:

```text
Alice 70000
Bob   60000
John  50000
```

---

# 14. Sorting Strings

```java
List<String> names = new ArrayList<>(
    List.of("John", "Alice", "Bob")
);
```

Ascending:

```java
names.sort(Comparator.naturalOrder());
```

Result:

```text
Alice
Bob
John
```

Descending:

```java
names.sort(Comparator.reverseOrder());
```

Result:

```text
John
Bob
Alice
```

---

# 15. Multiple Conditions — thenComparing()

This is very important in interviews.

Suppose:

> Sort employees by salary. If salary is the same, sort by name.

```java
Comparator<Employee> comparator =
        Comparator.comparingDouble(Employee::getSalary)
                  .thenComparing(Employee::getName);
```

Example:

```text
Alice 50000
Bob   50000
John  60000
Mike  60000
```

The logic is:

```text
Compare salary
      ↓
Same salary?
      ↓
Compare name
```

---

# 16. Multiple Conditions with Different Directions

Suppose:

> Sort by salary descending, and for equal salary sort by name ascending.

```java
Comparator<Employee> comparator =
        Comparator.comparingDouble(Employee::getSalary)
                  .reversed()
                  .thenComparing(Employee::getName);
```

Be careful when combining `reversed()` with chained comparators.

A clearer approach can sometimes be:

```java
Comparator<Employee> comparator =
        Comparator.comparingDouble(
            Employee::getSalary,
            Comparator.reverseOrder()
        );
```

For primitive-specialized comparator methods, use the appropriate composition strategy.

The key interview concept is:

```text
comparing()
thenComparing()
reversed()
```

---

# 17. Null Values

Suppose employee names can be `null`.

This can cause problems:

```java
employees.sort(
    Comparator.comparing(Employee::getName)
);
```

You can explicitly define null behavior.

### Nulls first

```java
employees.sort(
    Comparator.comparing(
        Employee::getName,
        Comparator.nullsFirst(
            Comparator.naturalOrder()
        )
    )
);
```

### Nulls last

```java
employees.sort(
    Comparator.comparing(
        Employee::getName,
        Comparator.nullsLast(
            Comparator.naturalOrder()
        )
    )
);
```

This is a useful senior-level Comparator feature.

---

# 18. Comparable with TreeSet

`Comparable` becomes particularly important with sorted collections.

Example:

```java
class Employee implements Comparable<Employee> {

    private int id;

    @Override
    public int compareTo(Employee other) {
        return Integer.compare(this.id, other.id);
    }
}
```

Then:

```java
Set<Employee> employees =
        new TreeSet<>();
```

The `TreeSet` uses the ordering to organize its elements.

### Important trap

For sorted sets/maps, comparison returning `0` can affect whether elements are considered duplicates by the collection's ordering.

Example:

```java
compareTo() == 0
```

may cause a `TreeSet` to treat two objects as the same element for set purposes, even if `equals()` says they are different.

This is why the ordering used by sorted collections should be designed carefully.

---

# 19. Comparable and equals()

A good natural ordering should ideally be consistent with `equals()`.

Suppose:

```java
employee1.equals(employee2)
```

returns:

```text
true
```

Then ideally:

```java
employee1.compareTo(employee2)
```

should return:

```text
0
```

This is not an absolute requirement of the `Comparable` interface, but inconsistency can cause surprising behavior in sorted collections.

### Example problem

```java
compareTo() == 0
```

but:

```java
equals() == false
```

A `TreeSet` may consider them duplicates according to ordering.

---

# 20. Comparator and equals()

The same concept applies to a `Comparator`.

If:

```java
comparator.compare(a, b) == 0
```

the comparator considers `a` and `b` equivalent for ordering purposes.

This can matter greatly with:

```java
TreeSet
TreeMap
```

because those collections use their ordering to determine placement/equivalence.

---

# 21. Comparable Example — Complete Program

```java
import java.util.*;

class Employee implements Comparable<Employee> {

    private int id;
    private String name;
    private double salary;

    public Employee(int id, String name, double salary) {
        this.id = id;
        this.name = name;
        this.salary = salary;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public double getSalary() {
        return salary;
    }

    @Override
    public int compareTo(Employee other) {
        return Integer.compare(this.id, other.id);
    }

    @Override
    public String toString() {
        return id + " " + name + " " + salary;
    }
}

public class Main {

    public static void main(String[] args) {

        List<Employee> employees = new ArrayList<>();

        employees.add(
            new Employee(3, "John", 50000)
        );

        employees.add(
            new Employee(1, "Alice", 70000)
        );

        employees.add(
            new Employee(2, "Bob", 60000)
        );

        // Comparable
        Collections.sort(employees);

        System.out.println(employees);
    }
}
```

Natural ordering:

```text
ID ascending
```

---

# 22. Comparator Example — Complete Program

```java
import java.util.*;

class Employee {

    private int id;
    private String name;
    private double salary;

    public Employee(int id, String name, double salary) {
        this.id = id;
        this.name = name;
        this.salary = salary;
    }

    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public double getSalary() {
        return salary;
    }

    @Override
    public String toString() {
        return id + " " + name + " " + salary;
    }
}

public class Main {

    public static void main(String[] args) {

        List<Employee> employees = new ArrayList<>();

        employees.add(
            new Employee(3, "John", 50000)
        );

        employees.add(
            new Employee(1, "Alice", 70000)
        );

        employees.add(
            new Employee(2, "Bob", 60000)
        );

        // Sort by salary
        employees.sort(
            Comparator.comparingDouble(
                Employee::getSalary
            )
        );

        System.out.println(employees);

        // Sort by name
        employees.sort(
            Comparator.comparing(
                Employee::getName
            )
        );

        System.out.println(employees);

        // Sort by ID
        employees.sort(
            Comparator.comparingInt(
                Employee::getId
            )
        );

        System.out.println(employees);
    }
}
```

One class can have many different `Comparator`s.

---

# 23. Real-World Example

Imagine an e-commerce application has:

```java
class Product {

    String name;
    double price;
    int rating;
}
```

The business may need:

```text
Sort by price
Sort by rating
Sort by name
Sort by rating + price
Sort by price descending
```

It would be a bad design to change `Product.compareTo()` every time the UI wants a different sorting option.

Instead:

```java
Comparator<Product> byPrice =
    Comparator.comparingDouble(Product::getPrice);

Comparator<Product> byRating =
    Comparator.comparingInt(Product::getRating);

Comparator<Product> byName =
    Comparator.comparing(Product::getName);
```

Then:

```java
products.sort(byPrice);
```

or:

```java
products.sort(byRating);
```

or:

```java
products.sort(byName);
```

This is exactly where `Comparator` is useful.

---

# 24. When Should You Use Comparable?

Use `Comparable` when:

```text
The class has one obvious natural ordering
```

Examples:

```text
Student → roll number
Employee → employee ID
Version → version number
Date/time → chronological order
```

The ordering is part of the class's meaning.

Example:

```java
class Version implements Comparable<Version> {
    // natural version ordering
}
```

---

# 25. When Should You Use Comparator?

Use `Comparator` when:

```text
You need multiple sorting strategies
```

For example:

```text
Employee → by salary
Employee → by name
Employee → by age
Employee → by joining date
```

It is also useful when:

- You don't own the class.
- You don't want to modify the class.
- Natural ordering doesn't exist.
- You need temporary/custom sorting.
- Different parts of the application need different ordering.

---

# 26. Important Difference in Design

### Comparable

The class says:

> "This is my natural ordering."

```java
class Employee
        implements Comparable<Employee> {

    @Override
    public int compareTo(Employee other) {
        ...
    }
}
```

### Comparator

Another object/function says:

> "For this particular operation, use this ordering."

```java
Comparator<Employee> bySalary =
        Comparator.comparingDouble(
            Employee::getSalary
        );
```

---

# 27. Interview Traps

### Trap 1 — Can Comparable have multiple compareTo methods?

No.

`Comparable` defines one comparison method:

```java
compareTo(T other)
```

You don't create multiple natural orderings through multiple `compareTo()` methods.

For multiple orderings, use `Comparator`.

---

### Trap 2 — Can Comparator be used with lambda?

Yes.

```java
Comparator<Employee> bySalary =
    (e1, e2) ->
        Double.compare(
            e1.getSalary(),
            e2.getSalary()
        );
```

This works because `Comparator` is a functional interface.

---

### Trap 3 — Can Comparable use lambda?

Not in the same way for the class declaration.

You don't do:

```java
class Employee implements Comparable<Employee> {
    ...
}
```

with a lambda implementation.

Instead, `compareTo()` is implemented as a class method.

---

### Trap 4 — Does compareTo() return only -1, 0, 1?

No.

It returns:

```text
negative → less than
0        → equal in ordering
positive → greater than
```

The exact non-zero number is generally irrelevant.

---

### Trap 5 — Is `compareTo() == 0` always the same as `equals()`?

Not necessarily.

But inconsistency can create surprising behavior, especially with:

```text
TreeSet
TreeMap
```

---

### Trap 6 — Is Comparable always better?

No.

It depends on the requirement.

Use:

```text
Comparable → natural ordering
Comparator → custom/multiple ordering
```

---

# 28. Quick Comparison Table

| Feature | Comparable | Comparator |
|---|---|---|
| Purpose | Natural ordering | Custom ordering |
| Package | `java.lang` | `java.util` |
| Method | `compareTo(T)` | `compare(T, T)` |
| Implemented by | Class being compared | Separate comparator |
| Class modification | Required | Not required |
| Multiple sorting strategies | Not suitable | Excellent |
| Lambda | No typical use | Yes |
| Common usage | `Collections.sort(list)` | `list.sort(comparator)` |
| Java 8 style | Less commonly changed | `comparing()`, `thenComparing()`, `reversed()` |
| Best use | One obvious natural order | Multiple/custom orders |
| Example | Employee by ID | Employee by salary/name |
| Can work with TreeSet/TreeMap | Yes | Yes |

---

# 29. Easy Memory Trick

Remember:

```text
Comparable
    ↓
"Compare ME"
    ↓
Object compares itself
    ↓
compareTo()
    ↓
Natural ordering
```

```text
Comparator
    ↓
"Compare THESE objects"
    ↓
Separate comparison logic
    ↓
compare()
    ↓
Custom ordering
```

---

# 30. Best Interview Answer

### Short answer

> **Comparable is used to define a class's natural ordering using `compareTo()`, while Comparator is used to define custom or multiple sorting strategies using `compare()`. Comparable requires the class to implement the interface, whereas Comparator keeps the sorting logic outside the class.**

### Detailed interview answer

> "I use Comparable when a class has one clear natural ordering—for example, an Employee could naturally be ordered by ID. The class implements Comparable and defines `compareTo()`. I use Comparator when I need different sorting strategies, such as sorting employees by salary, name, or joining date. Comparator keeps that ordering logic outside the domain class and allows multiple strategies. In modern Java, I commonly use `Comparator.comparing()`, `thenComparing()`, and `reversed()` to build these orderings."

---

# 31. One Final Example to Remember

```java
class Employee implements Comparable<Employee> {

    private int id;
    private String name;
    private double salary;

    @Override
    public int compareTo(Employee other) {

        // Natural ordering
        return Integer.compare(
            this.id,
            other.id
        );
    }
}
```

Natural ordering:

```java
employees.sort(null);
```

or:

```java
Collections.sort(employees);
```

Custom salary ordering:

```java
employees.sort(
    Comparator.comparingDouble(
        Employee::getSalary
    )
);
```

Custom name ordering:

```java
employees.sort(
    Comparator.comparing(
        Employee::getName
    )
);
```

Salary descending:

```java
employees.sort(
    Comparator.comparingDouble(
        Employee::getSalary
    ).reversed()
);
```

Salary ascending + name ascending:

```java
employees.sort(
    Comparator.comparingDouble(
        Employee::getSalary
    ).thenComparing(
        Employee::getName
    )
);
```

### Final rule

```text
Comparable  → One natural ordering → compareTo()

Comparator  → Custom/multiple ordering → compare()
```