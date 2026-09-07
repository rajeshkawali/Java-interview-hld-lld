# SQL INTERVIEW THEORY Q&A
## Most Asked SQL Interview Questions + Scenario-Based Questions

> **How to use this guide:**  
> First understand the concept, then remember the short interview answer.  
> Examples use MySQL-style SQL where syntax matters.

---

# PART 1 — SQL BASICS

## Q1. What is SQL?

**Answer:**

SQL stands for **Structured Query Language**.

It is used to communicate with relational databases.

We use SQL to:

- Create databases and tables
- Insert data
- Read data
- Update data
- Delete data
- Control access
- Perform analysis using queries

Example:

```sql
SELECT *
FROM employees;
```

This retrieves employees from the `employees` table.

---

## Q2. What is a database?

**Answer:**

A database is an organized collection of data that can be stored, managed, and retrieved efficiently.

For example, an employee database may contain:

```text
employees
departments
jobs
projects
salary_history
sales
```

A database allows applications to store and retrieve this information efficiently.

---

## Q3. What is a DBMS?

**Answer:**

DBMS stands for **Database Management System**.

It is software used to create, store, manage, and retrieve data from databases.

Examples:

- MySQL
- PostgreSQL
- Oracle
- SQL Server

---

## Q4. What is an RDBMS?

**Answer:**

RDBMS stands for **Relational Database Management System**.

It stores data in tables and establishes relationships between tables.

For example:

```text
employees
    |
    | department_id
    ↓
departments
```

MySQL, PostgreSQL, Oracle, and SQL Server are examples of relational database systems.

---

## Q5. What is a table?

**Answer:**

A table stores data in the form of **rows and columns**.

Example:

```text
employees

employee_id | first_name | salary
------------|------------|-------
1           | John       | 50000
2           | David      | 70000
3           | Sarah      | 80000
```

- Row = one record
- Column = one attribute/property

---

# PART 2 — SQL COMMAND TYPES

## Q6. What are DDL, DML, DQL, DCL and TCL?

**Answer:**

SQL commands are commonly divided into these categories:

### DDL — Data Definition Language

Used to define database structure.

Examples:

```sql
CREATE
ALTER
DROP
TRUNCATE
```

### DML — Data Manipulation Language

Used to modify data.

Examples:

```sql
INSERT
UPDATE
DELETE
```

### DQL — Data Query Language

Used to retrieve data.

Example:

```sql
SELECT
```

### DCL — Data Control Language

Used to control permissions.

Examples:

```sql
GRANT
REVOKE
```

### TCL — Transaction Control Language

Used to manage transactions.

Examples:

```sql
COMMIT
ROLLBACK
SAVEPOINT
```

---

# PART 3 — PRIMARY KEY AND FOREIGN KEY

## Q7. What is a Primary Key?

**Answer:**

A primary key uniquely identifies each row in a table.

Properties:

- Must be unique
- Cannot contain NULL
- A table normally has one primary key constraint

Example:

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    salary DECIMAL(10,2)
);
```

Here `employee_id` uniquely identifies an employee.

---

## Q8. What is a Foreign Key?

**Answer:**

A foreign key is a column that creates a relationship between two tables.

Example:

```text
employees.department_id
        ↓
departments.department_id
```

Example:

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);
```

The foreign key helps maintain **referential integrity**.

---

## Q9. Primary Key vs Foreign Key?

| Primary Key | Foreign Key |
|---|---|
| Uniquely identifies a row | References another table |
| Cannot be NULL | Can usually be NULL |
| Must be unique | Can contain duplicates |
| Identifies the record | Creates relationship |

Example:

```text
departments
department_id = 10  ← Primary Key

employees
department_id = 10  ← Foreign Key
```

---

# PART 4 — UNIQUE, NOT NULL, DEFAULT, CHECK

## Q10. What is a UNIQUE constraint?

**Answer:**

A UNIQUE constraint prevents duplicate values in a column.

Example:

```sql
email VARCHAR(255) UNIQUE
```

Two employees cannot have the same email.

---

## Q11. Primary Key vs UNIQUE?

**Answer:**

Both enforce uniqueness, but they have different purposes.

| Primary Key | UNIQUE |
|---|---|
| Main identifier | Prevents duplicate values |
| Cannot be NULL | NULL handling differs by DBMS |
| One primary-key constraint per table | Multiple UNIQUE constraints possible |

Example:

```sql
employee_id INT PRIMARY KEY,
email VARCHAR(255) UNIQUE
```

---

## Q12. What is NOT NULL?

**Answer:**

`NOT NULL` means a column must have a value.

Example:

```sql
first_name VARCHAR(100) NOT NULL
```

This prevents:

```text
first_name = NULL
```

---

## Q13. What is DEFAULT?

**Answer:**

`DEFAULT` automatically provides a value when no value is supplied.

Example:

```sql
employment_status VARCHAR(20) DEFAULT 'ACTIVE'
```

If we don't provide `employment_status`, the database can use `ACTIVE`.

---

## Q14. What is CHECK constraint?

**Answer:**

A CHECK constraint ensures that data satisfies a condition.

Example:

```sql
salary DECIMAL(12,2)
CHECK (salary >= 0)
```

This prevents negative salary values.

---

# PART 5 — NULL

## Q15. What is NULL?

**Answer:**

`NULL` means the value is **missing, unknown, or not applicable**.

NULL is not the same as:

```text
0
''
'NULL'
```

For example, a top-level manager may have:

```text
manager_id = NULL
```

because they don't report to another employee.

---

## Q16. How do you check for NULL?

**Correct:**

```sql
SELECT *
FROM employees
WHERE manager_id IS NULL;
```

For non-NULL:

```sql
SELECT *
FROM employees
WHERE manager_id IS NOT NULL;
```

Do not use:

```sql
WHERE manager_id = NULL
```

because NULL is not compared using `=`.

---

## Q17. What is COALESCE?

**Answer:**

`COALESCE()` returns the first non-NULL value.

Example:

```sql
SELECT
    first_name,
    COALESCE(phone, 'Phone Not Available') AS phone
FROM employees;
```

If `phone` is NULL, it returns:

```text
Phone Not Available
```

---

# PART 6 — WHERE, HAVING AND ORDER BY

## Q18. What is WHERE?

**Answer:**

`WHERE` filters individual rows before grouping.

Example:

```sql
SELECT *
FROM employees
WHERE salary > 70000;
```

---

## Q19. What is HAVING?

**Answer:**

`HAVING` filters groups after `GROUP BY`.

Example:

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 70000;
```

---

## Q20. WHERE vs HAVING?

**Answer:**

`WHERE` filters rows.

`HAVING` filters groups.

Example:

```sql
-- Filter employees first
WHERE salary > 50000

-- Filter departments after grouping
HAVING AVG(salary) > 70000
```

A common interview statement:

> **WHERE works before GROUP BY, HAVING works after GROUP BY.**

---

## Q21. What is ORDER BY?

**Answer:**

`ORDER BY` sorts the result.

Ascending:

```sql
SELECT *
FROM employees
ORDER BY salary ASC;
```

Descending:

```sql
SELECT *
FROM employees
ORDER BY salary DESC;
```

---

# PART 7 — DISTINCT

## Q22. What is DISTINCT?

**Answer:**

`DISTINCT` removes duplicate combinations from the selected result.

Example:

```sql
SELECT DISTINCT department_id
FROM employees;
```

This returns each department only once.

---

# PART 8 — AGGREGATE FUNCTIONS

## Q23. What are aggregate functions?

**Answer:**

Aggregate functions perform calculations on multiple rows.

Common aggregate functions:

```text
COUNT()
SUM()
AVG()
MIN()
MAX()
```

Example:

```sql
SELECT AVG(salary)
FROM employees;
```

---

## Q24. COUNT(*) vs COUNT(column)?

**Answer:**

`COUNT(*)` counts rows.

```sql
SELECT COUNT(*)
FROM employees;
```

`COUNT(column)` counts non-NULL values in that column.

```sql
SELECT COUNT(phone)
FROM employees;
```

If 3 employees have NULL phone numbers:

```text
COUNT(*)       → all employees
COUNT(phone)   → employees with non-NULL phone
```

---

# PART 9 — GROUP BY

## Q25. What is GROUP BY?

**Answer:**

`GROUP BY` combines rows having the same value so aggregate functions can be applied to each group.

Example:

```sql
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id;
```

This gives employee count department-wise.

---

## Q26. Find department-wise average salary.

```sql
SELECT
    department_id,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department_id;
```

---

## Q27. Find departments having more than 5 employees.

```sql
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 5;
```

---

# PART 10 — JOINS

## Q28. What is a JOIN?

**Answer:**

A JOIN is used to combine data from multiple tables using a related column.

Example:

```text
employees.department_id
        ↓
departments.department_id
```

---

## Q29. What is INNER JOIN?

**Answer:**

`INNER JOIN` returns only rows that have a matching record in both tables.

Example:

```sql
SELECT
    e.first_name,
    d.department_name
FROM employees e
INNER JOIN departments d
    ON e.department_id = d.department_id;
```

---

## Q30. What is LEFT JOIN?

**Answer:**

`LEFT JOIN` returns all rows from the left table and matching rows from the right table.

If there is no match, columns from the right table become NULL.

Example:

```sql
SELECT
    d.department_name,
    e.first_name
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id;
```

This is especially useful when we want to find departments with **zero employees**.

---

## Q31. How do you find departments having no employees?

```sql
SELECT
    d.department_name
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;
```

**Interview explanation:**

We use LEFT JOIN because we want all departments, including departments without employees.

Then:

```sql
WHERE e.employee_id IS NULL
```

identifies departments where no employee matched.

---

## Q32. INNER JOIN vs LEFT JOIN?

| INNER JOIN | LEFT JOIN |
|---|---|
| Only matching rows | All left-table rows |
| Unmatched rows removed | Unmatched right values become NULL |
| Used when match is required | Used when preserving left-side records |

---

# PART 11 — SELF JOIN

## Q33. What is a SELF JOIN?

**Answer:**

A self join means joining a table with itself.

It is commonly used for hierarchical relationships such as:

```text
Employee → Manager
```

Example:

```sql
SELECT
    e.first_name AS employee,
    m.first_name AS manager
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id;
```

Here:

```text
e = employee
m = manager
```

Both come from the same table.

---

## Q34. Find employees whose salary is greater than their manager's salary.

```sql
SELECT
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

Important relationship:

```text
employee.manager_id
        =
manager.employee_id
```

---

# PART 12 — SUBQUERIES

## Q35. What is a subquery?

**Answer:**

A subquery is a query inside another query.

Example:

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

The inner query calculates average salary.

The outer query finds employees earning above that average.

---

## Q36. Find employees earning more than the average salary.

```sql
SELECT
    first_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

---

## Q37. What is a correlated subquery?

**Answer:**

A correlated subquery depends on the outer query.

It is executed logically for each row considered by the outer query.

Example:

```sql
SELECT
    e.first_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

This finds employees earning more than their **department's average salary**.

---

# PART 13 — IN, EXISTS, ANY, ALL

## Q38. What is IN?

**Answer:**

`IN` checks whether a value exists in a list or subquery result.

Example:

```sql
SELECT *
FROM employees
WHERE department_id IN (1, 2, 3);
```

---

## Q39. What is EXISTS?

**Answer:**

`EXISTS` checks whether the subquery returns at least one row.

Example:

```sql
SELECT *
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

This finds departments having at least one employee.

---

## Q40. IN vs EXISTS?

**Simple interview answer:**

Both can be used to test whether related values exist.

`EXISTS` is often useful when we only care whether a matching row exists, especially for correlated queries.

Example:

```sql
WHERE EXISTS (...)
```

means:

> Does at least one matching record exist?

---

# PART 14 — DELETE, TRUNCATE, DROP

## Q41. DELETE vs TRUNCATE vs DROP?

**Answer:**

### DELETE

Removes rows.

```sql
DELETE FROM employees
WHERE employee_id = 10;
```

Can use a `WHERE` condition.

### TRUNCATE

Removes all rows from a table.

```sql
TRUNCATE TABLE employees;
```

It does not allow a normal `WHERE` clause.

### DROP

Removes the database object itself.

```sql
DROP TABLE employees;
```

The table structure is removed.

---

## Q42. DELETE vs TRUNCATE — common interview answer

| DELETE | TRUNCATE |
|---|---|
| DML | Usually treated as DDL in MySQL |
| Can use WHERE | Cannot use WHERE |
| Deletes selected rows | Removes all rows |
| Row-by-row deletion semantics | Faster way to empty a table |
| Can be transaction-controlled depending on engine/context | Has different transactional behavior in MySQL |

Always mention that exact transactional/identity behavior can depend on the database system.

---

# PART 15 — UPDATE

## Q43. How do you update an employee's salary?

```sql
UPDATE employees
SET salary = 80000
WHERE employee_id = 10;
```

Always be careful with the `WHERE` condition.

Without `WHERE`:

```sql
UPDATE employees
SET salary = 80000;
```

every employee could be updated.

---

# PART 16 — CASE

## Q44. What is CASE?

**Answer:**

`CASE` is used for conditional logic inside SQL.

Example:

```sql
SELECT
    first_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM employees;
```

---

## Q45. How do you categorize employees based on salary?

```sql
SELECT
    first_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High Salary'
        WHEN salary >= 70000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS category
FROM employees;
```

---

# PART 17 — VIEWS

## Q46. What is a View?

**Answer:**

A view is a virtual table based on a SQL query.

Example:

```sql
CREATE VIEW employee_details AS
SELECT
    e.employee_id,
    e.first_name,
    d.department_name,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;
```

Then:

```sql
SELECT *
FROM employee_details;
```

---

## Q47. Why do we use Views?

Common reasons:

- Simplify complex queries
- Reuse queries
- Hide unnecessary columns
- Provide controlled access to data
- Improve readability

A view normally stores the query definition rather than storing a separate copy of the result.

---

# PART 18 — INDEXES

## Q48. What is an index?

**Answer:**

An index is a data structure that helps the database find rows faster.

Example:

```sql
CREATE INDEX idx_employee_department
ON employees(department_id);
```

If we frequently search:

```sql
SELECT *
FROM employees
WHERE department_id = 5;
```

an appropriate index can improve performance.

---

## Q49. What is the disadvantage of indexes?

**Answer:**

Indexes improve read performance, but they have costs.

They:

- Consume storage
- Can slow down INSERT
- Can slow down UPDATE
- Can slow down DELETE
- Need maintenance

Why?

Because when indexed data changes, the related index structures may also need to be updated.

---

## Q50. When should you create an index?

**Answer:**

Consider indexes on columns frequently used in:

```text
WHERE
JOIN
ORDER BY
GROUP BY
```

But don't create indexes blindly.

Too many indexes can hurt write performance and consume storage.

---

# PART 19 — COMPOSITE INDEX

## Q51. What is a composite index?

**Answer:**

A composite index is an index containing multiple columns.

Example:

```sql
CREATE INDEX idx_employee_dept_salary
ON employees(department_id, salary);
```

The column order matters.

A common concept is the **leftmost-prefix rule**: an index beginning with `(department_id, salary)` is generally useful for conditions beginning with `department_id`, while salary-only searches may not benefit in the same way.

---

# PART 20 — NORMALIZATION

## Q52. What is normalization?

**Answer:**

Normalization is the process of organizing data to reduce:

- Duplicate data
- Data inconsistency
- Update anomalies
- Insert anomalies
- Delete anomalies

For example, instead of storing:

```text
employee_id
employee_name
department_name
department_location
department_budget
```

repeatedly for every employee, we can separate:

```text
employees
departments
```

and connect them using `department_id`.

---

## Q53. What is 1NF?

**Answer:**

First Normal Form means:

- Each column contains atomic values
- No repeating groups
- Each row represents a record

Bad:

```text
phone_numbers = '9999,8888,7777'
```

Better:

```text
employee_phone
employee_id | phone
```

---

## Q54. What is 2NF?

**Answer:**

2NF means:

- Table is already in 1NF
- No partial dependency on part of a composite key

This is mainly relevant when a table has a composite primary key.

---

## Q55. What is 3NF?

**Answer:**

3NF means:

- Table is already in 2NF
- Non-key columns should not depend on another non-key column

Example:

```text
employee_id
department_id
department_name
```

If `department_name` depends on `department_id`, it may belong in the department table instead of repeatedly storing it in employees.

---

# PART 21 — DENORMALIZATION

## Q56. What is denormalization?

**Answer:**

Denormalization intentionally introduces some redundancy to improve read/query performance or simplify reporting.

Example:

Instead of joining:

```text
orders → customers
```

a reporting table might also store:

```text
customer_name
```

directly.

Trade-off:

```text
Faster/easier reads
        vs
More duplicate data
```

---

# PART 22 — TRANSACTIONS

## Q57. What is a transaction?

**Answer:**

A transaction is a group of operations treated as one logical unit of work.

Example:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 2;

COMMIT;
```

Both operations should succeed together.

---

# PART 23 — ACID

## Q58. What is ACID?

**Answer:**

ACID describes important transaction properties.

### A — Atomicity

All operations succeed or the transaction is rolled back.

### C — Consistency

The database remains in a valid state.

### I — Isolation

Concurrent transactions should not improperly interfere with each other.

### D — Durability

Once committed, changes should survive failures according to the database's durability guarantees.

---

# PART 24 — COMMIT AND ROLLBACK

## Q59. What is COMMIT?

**Answer:**

`COMMIT` permanently commits the transaction changes according to the database's transaction rules.

```sql
COMMIT;
```

---

## Q60. What is ROLLBACK?

**Answer:**

`ROLLBACK` undoes uncommitted transaction changes.

```sql
ROLLBACK;
```

Example:

```sql
START TRANSACTION;

UPDATE employees
SET salary = salary * 1.10;

ROLLBACK;
```

The uncommitted update is undone.

---

# PART 25 — STORED PROCEDURES

## Q61. What is a Stored Procedure?

**Answer:**

A stored procedure is a stored program containing SQL statements that can be executed when needed.

Example:

```sql
CALL get_employee_details(10);
```

Benefits can include:

- Reusable database logic
- Centralized processing
- Reduced repeated SQL
- Controlled access in some designs

---

# PART 26 — FUNCTIONS

## Q62. What is a SQL function?

**Answer:**

A function performs an operation and returns a value.

Examples of built-in functions:

```sql
COUNT()
SUM()
AVG()
COALESCE()
UPPER()
LOWER()
```

Databases can also support user-defined functions.

---

# PART 27 — TRIGGERS

## Q63. What is a Trigger?

**Answer:**

A trigger is automatically executed when a specified database event occurs.

For example:

```text
INSERT
UPDATE
DELETE
```

Example use case:

When salary changes, automatically insert the old and new salary into a salary history table.

Conceptually:

```text
employees UPDATE
       ↓
salary trigger
       ↓
employee_salary_history
```

---

## Q64. When should triggers be avoided?

**Answer:**

Triggers can be useful, but too many triggers can make application behavior difficult to understand and debug.

Avoid unnecessary trigger logic when the same business rule can be implemented more clearly in application/service logic or explicit database operations.

---

# PART 28 — WINDOW FUNCTIONS

## Q65. What is a Window Function?

**Answer:**

A window function performs calculations across related rows **without collapsing the rows into one row per group**.

Examples:

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
LAG()
LEAD()
SUM() OVER()
AVG() OVER()
```

---

## Q66. GROUP BY vs Window Function?

**Answer:**

`GROUP BY` reduces multiple rows into groups.

Window functions keep the individual rows.

Example:

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id;
```

Returns one row per department.

Window function:

```sql
SELECT
    first_name,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg
FROM employees;
```

Keeps every employee row while showing department average.

---

# PART 29 — ROW_NUMBER, RANK, DENSE_RANK

## Q67. ROW_NUMBER vs RANK vs DENSE_RANK?

**Answer:**

Suppose salaries are:

```text
100000
90000
90000
80000
```

### ROW_NUMBER

```text
100000 → 1
90000  → 2
90000  → 3
80000  → 4
```

Every row gets a unique number.

### RANK

```text
100000 → 1
90000  → 2
90000  → 2
80000  → 4
```

There is a gap after the tie.

### DENSE_RANK

```text
100000 → 1
90000  → 2
90000  → 2
80000  → 3
```

No gap after the tie.

---

## Q68. Find the highest-paid employee in each department.

```sql
WITH ranked_employees AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rn
    FROM employees e
)
SELECT *
FROM ranked_employees
WHERE rn = 1;
```

---

## Q69. Find the second-highest salary.

One approach:

```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

This returns the second **distinct** highest salary.

---

## Q70. Find the second-highest salary using DENSE_RANK.

```sql
WITH ranked AS (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT salary
FROM ranked
WHERE salary_rank = 2;
```

---

# PART 30 — CTE

## Q71. What is a CTE?

**Answer:**

CTE stands for **Common Table Expression**.

It allows us to define a temporary named result set that can be referenced by the following query.

Syntax:

```sql
WITH employee_data AS (
    SELECT *
    FROM employees
)
SELECT *
FROM employee_data;
```

CTEs improve readability and are especially useful for complex queries and recursive hierarchies.

---

## Q72. CTE vs Subquery?

**Answer:**

Both can solve similar problems.

CTEs are often easier to read when the query contains multiple logical steps.

Example:

```sql
WITH high_salary AS (
    SELECT *
    FROM employees
    WHERE salary > 80000
)
SELECT *
FROM high_salary;
```

---

# PART 31 — RECURSIVE CTE

## Q73. What is a Recursive CTE?

**Answer:**

A recursive CTE repeatedly references itself and is useful for hierarchical data.

Example use cases:

```text
Employee → Manager → Director
Category → Subcategory
Parent → Child
```

For an employee hierarchy, a recursive CTE can start from top-level employees and repeatedly find their subordinates.

---

# PART 32 — DUPLICATES

## Q74. How do you find duplicate emails?

```sql
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

---

## Q75. How do you find duplicate records?

**Answer:**

Group by the columns that define a duplicate.

Example:

```sql
SELECT
    first_name,
    last_name,
    email,
    COUNT(*) AS duplicate_count
FROM employee_import
GROUP BY
    first_name,
    last_name,
    email
HAVING COUNT(*) > 1;
```

---

## Q76. How do you delete duplicate records while keeping one?

A common MySQL 8 approach uses `ROW_NUMBER()`.

```sql
DELETE ei
FROM employee_import ei
JOIN (
    SELECT employee_import_id
    FROM (
        SELECT
            employee_import_id,
            ROW_NUMBER() OVER (
                PARTITION BY email
                ORDER BY created_at DESC, employee_import_id DESC
            ) AS rn
        FROM employee_import
    ) x
    WHERE rn > 1
) d
    ON d.employee_import_id = ei.employee_import_id;
```

The newest record is kept and older duplicates are deleted.

**Always test the ranking query with SELECT first before running DELETE in production.**

---

# PART 33 — UNION

## Q77. What is UNION?

**Answer:**

`UNION` combines the results of two compatible SELECT queries and removes duplicate rows.

Example:

```sql
SELECT employee_id
FROM employees
WHERE department_id = 1

UNION

SELECT employee_id
FROM employees
WHERE salary > 100000;
```

---

## Q78. What is UNION ALL?

**Answer:**

`UNION ALL` combines results but keeps duplicates.

Usually it is faster than `UNION` because duplicate elimination is not performed.

---

## Q79. UNION vs UNION ALL?

| UNION | UNION ALL |
|---|---|
| Removes duplicates | Keeps duplicates |
| Additional duplicate-elimination work | Usually faster |
| Used when unique combined result is needed | Used when duplicates are meaningful/acceptable |

---

# PART 34 — DATE FUNCTIONS

## Q80. How do you find employees hired in the last 5 years?

MySQL:

```sql
SELECT *
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
```

---

## Q81. How do you calculate employee experience?

```sql
SELECT
    first_name,
    TIMESTAMPDIFF(
        YEAR,
        hire_date,
        CURDATE()
    ) AS years_of_experience
FROM employees;
```

---

# PART 35 — STRING FUNCTIONS

## Q82. How do you combine first and last name?

```sql
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;
```

---

## Q83. What are common string functions?

Examples:

```sql
UPPER()
LOWER()
CONCAT()
SUBSTRING()
TRIM()
LENGTH()
REPLACE()
```

Example:

```sql
SELECT UPPER(first_name)
FROM employees;
```

---

# PART 36 — SQL EXECUTION ORDER

## Q84. What is the logical order of SQL query execution?

**Answer:**

A commonly taught logical order is:

```text
FROM
JOIN
WHERE
GROUP BY
HAVING
SELECT
DISTINCT
ORDER BY
LIMIT
```

Example:

```sql
SELECT department_id, COUNT(*)
FROM employees
WHERE salary > 50000
GROUP BY department_id
HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC
LIMIT 5;
```

The database logically processes the clauses in the above conceptual order, although the optimizer may physically execute operations differently.

---

# PART 37 — WHY CAN'T WE USE SELECT ALIAS IN WHERE?

## Q85. Why can't we normally use a SELECT alias in WHERE?

Example:

```sql
SELECT
    salary * 12 AS annual_salary
FROM employees
WHERE annual_salary > 1000000;
```

This generally doesn't work because `WHERE` is logically evaluated before `SELECT`.

Instead:

```sql
SELECT
    salary * 12 AS annual_salary
FROM employees
WHERE salary * 12 > 1000000;
```

Or use a derived table/CTE.

---

# PART 38 — LIMIT

## Q86. What is LIMIT?

**Answer:**

`LIMIT` restricts the number of rows returned.

Example:

```sql
SELECT *
FROM employees
ORDER BY salary DESC
LIMIT 5;
```

Returns the top 5 employees by salary.

---

# PART 39 — TOP N PER GROUP

## Q87. How do you find the top 3 employees by salary in each department?

```sql
WITH ranked AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rn
    FROM employees e
)
SELECT *
FROM ranked
WHERE rn <= 3;
```

---

# PART 40 — LEAD AND LAG

## Q88. What is LAG?

**Answer:**

`LAG()` accesses a previous row without requiring a self join.

Example:

```sql
SELECT
    employee_id,
    salary,
    LAG(salary) OVER (
        ORDER BY employee_id
    ) AS previous_salary
FROM employees;
```

---

## Q89. What is LEAD?

**Answer:**

`LEAD()` accesses a following row.

```sql
SELECT
    employee_id,
    salary,
    LEAD(salary) OVER (
        ORDER BY employee_id
    ) AS next_salary
FROM employees;
```

---

# PART 41 — SCENARIO QUESTIONS

# Q90. Scenario: Find employees who earn more than their manager.

```sql
SELECT
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

**How to explain in interview:**

> Employees and managers are stored in the same table, so I use a self join. `e.manager_id` references `m.employee_id`, then I compare their salaries.

---

# Q91. Scenario: Find employees who don't have a manager.

```sql
SELECT
    employee_id,
    first_name
FROM employees
WHERE manager_id IS NULL;
```

**Explanation:**

`manager_id IS NULL` identifies employees without a manager.

---

# Q92. Scenario: Find departments with no employees.

```sql
SELECT
    d.department_id,
    d.department_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;
```

---

# Q93. Scenario: Find employees who earn more than their department average.

```sql
SELECT
    e.first_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

---

# Q94. Scenario: Find the highest-paid employee in each department.

```sql
WITH ranked AS (
    SELECT
        e.*,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM employees e
)
SELECT *
FROM ranked
WHERE rnk = 1;
```

**Why RANK?**

If two employees have the same highest salary, both are returned.

---

# Q95. Scenario: Find departments whose average salary is greater than the company average.

```sql
WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_department_salary
    FROM employees
    GROUP BY department_id
),
company_avg AS (
    SELECT AVG(salary) AS avg_company_salary
    FROM employees
)
SELECT
    da.department_id,
    da.avg_department_salary
FROM department_avg da
CROSS JOIN company_avg ca
WHERE da.avg_department_salary > ca.avg_company_salary;
```

---

# Q96. Scenario: Find employees who have never made a sale.

```sql
SELECT
    e.employee_id,
    e.first_name
FROM employees e
LEFT JOIN sales s
    ON s.employee_id = e.employee_id
WHERE s.sale_id IS NULL;
```

**Important interview concept:**

This is a classic:

```text
LEFT JOIN + IS NULL
```

pattern.

---

# Q97. Scenario: Find employees who have made at least one sale.

Using `EXISTS`:

```sql
SELECT
    e.employee_id,
    e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
);
```

---

# Q98. Scenario: Find each employee's total sales.

```sql
SELECT
    e.employee_id,
    e.first_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM employees e
LEFT JOIN sales s
    ON s.employee_id = e.employee_id
GROUP BY
    e.employee_id,
    e.first_name;
```

---

# Q99. Scenario: Find the employee with the highest total sales.

```sql
WITH employee_sales AS (
    SELECT
        e.employee_id,
        e.first_name,
        COALESCE(SUM(s.amount), 0) AS total_sales
    FROM employees e
    LEFT JOIN sales s
        ON s.employee_id = e.employee_id
    GROUP BY
        e.employee_id,
        e.first_name
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY total_sales DESC
        ) AS rnk
    FROM employee_sales
)
SELECT *
FROM ranked
WHERE rnk = 1;
```

---

# Q100. Scenario: Find employees who are not assigned to any project.

```sql
SELECT
    e.employee_id,
    e.first_name
FROM employees e
LEFT JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
WHERE ep.employee_id IS NULL;
```

---

# Q101. Scenario: Find employees working on more than 2 projects.

```sql
SELECT
    e.employee_id,
    e.first_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
GROUP BY
    e.employee_id,
    e.first_name
HAVING COUNT(ep.project_id) > 2;
```

---

# Q102. Scenario: Find the second-highest salary in each department.

```sql
WITH ranked AS (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees e
)
SELECT *
FROM ranked
WHERE salary_rank = 2;
```

Using `DENSE_RANK()` means we are looking for the second **distinct salary level** in each department.

---

# Q103. Scenario: Find employees who have the same salary.

```sql
SELECT
    salary,
    COUNT(*) AS employee_count
FROM employees
GROUP BY salary
HAVING COUNT(*) > 1;
```

To return the actual employees:

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.salary
FROM employees e
JOIN (
    SELECT salary
    FROM employees
    GROUP BY salary
    HAVING COUNT(*) > 1
) x
    ON x.salary = e.salary
ORDER BY e.salary DESC;
```

---

# Q104. Scenario: Find employees who joined before their manager.

```sql
SELECT
    e.first_name AS employee_name,
    e.hire_date AS employee_hire_date,
    m.first_name AS manager_name,
    m.hire_date AS manager_hire_date
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;
```

This can identify potentially unusual hierarchy data.

---

# Q105. Scenario: Find managers who manage more than 3 employees.

```sql
SELECT
    m.employee_id AS manager_id,
    m.first_name AS manager_name,
    COUNT(e.employee_id) AS employee_count
FROM employees m
JOIN employees e
    ON e.manager_id = m.employee_id
GROUP BY
    m.employee_id,
    m.first_name
HAVING COUNT(e.employee_id) > 3;
```

---

# Q106. Scenario: Find employees who have never changed salary.

```sql
SELECT
    e.employee_id,
    e.first_name
FROM employees e
LEFT JOIN employee_salary_history h
    ON h.employee_id = e.employee_id
WHERE h.employee_id IS NULL;
```

---

# Q107. Scenario: Find the latest salary change for each employee.

```sql
WITH ranked AS (
    SELECT
        h.*,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC, salary_history_id DESC
        ) AS rn
    FROM employee_salary_history h
)
SELECT *
FROM ranked
WHERE rn = 1;
```

---

# Q108. Scenario: Find employees whose current salary differs from their latest recorded new salary.

```sql
WITH latest_history AS (
    SELECT
        h.*,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC, salary_history_id DESC
        ) AS rn
    FROM employee_salary_history h
)
SELECT
    e.employee_id,
    e.first_name,
    e.salary AS current_salary,
    h.new_salary AS latest_history_salary
FROM employees e
JOIN latest_history h
    ON h.employee_id = e.employee_id
   AND h.rn = 1
WHERE e.salary <> h.new_salary;
```

This is a useful **data-quality interview scenario**.

---

# PART 42 — MORE ADVANCED SCENARIOS

# Q109. Scenario: Find the top 2 salaries in every department, including ties.

```sql
WITH ranked AS (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees e
)
SELECT *
FROM ranked
WHERE salary_rank <= 2;
```

Use `DENSE_RANK()` when salary ties should share the same rank.

---

# Q110. Scenario: Find employees whose salary is higher than all employees in another department.

Example: Engineering employees earning more than **every** HR employee.

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.salary
FROM employees e
WHERE e.department_id = 1
  AND e.salary > ALL (
      SELECT e2.salary
      FROM employees e2
      WHERE e2.department_id = 2
  );
```

---

# Q111. Scenario: Find employees whose salary is higher than at least one employee in another department.

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.salary
FROM employees e
WHERE e.department_id = 1
  AND e.salary > ANY (
      SELECT e2.salary
      FROM employees e2
      WHERE e2.department_id = 2
  );
```

---

# Q112. Scenario: Find the percentage of employees in each department.

```sql
SELECT
    department_id,
    COUNT(*) AS employee_count,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS employee_percentage
FROM employees
GROUP BY department_id;
```

---

# Q113. Scenario: Find salary contribution percentage by department.

```sql
SELECT
    department_id,
    SUM(salary) AS department_salary,
    ROUND(
        SUM(salary) * 100.0 /
        SUM(SUM(salary)) OVER (),
        2
    ) AS salary_percentage
FROM employees
GROUP BY department_id;
```

---

# Q114. Scenario: Find employees whose salary is in the top 10% of the company.

One possible approach:

```sql
WITH ranked AS (
    SELECT
        e.*,
        NTILE(10) OVER (
            ORDER BY salary DESC
        ) AS salary_bucket
    FROM employees e
)
SELECT *
FROM ranked
WHERE salary_bucket = 1;
```

This divides employees into 10 buckets.

---

# Q115. Scenario: Find the running total of sales.

```sql
SELECT
    sale_id,
    employee_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        ORDER BY sale_date, sale_id
    ) AS running_total
FROM sales;
```

---

# Q116. Scenario: Find running sales total for each employee.

```sql
SELECT
    sale_id,
    employee_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY employee_id
        ORDER BY sale_date, sale_id
    ) AS employee_running_total
FROM sales;
```

---

# Q117. Scenario: Find month-wise sales.

```sql
SELECT
    DATE_FORMAT(sale_date, '%Y-%m-01') AS sale_month,
    SUM(amount) AS total_sales
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m-01')
ORDER BY sale_month;
```

---

# Q118. Scenario: Find employees whose sales increased compared with their previous sale.

```sql
WITH sales_with_previous AS (
    SELECT
        sale_id,
        employee_id,
        sale_date,
        amount,
        LAG(amount) OVER (
            PARTITION BY employee_id
            ORDER BY sale_date, sale_id
        ) AS previous_amount
    FROM sales
)
SELECT *
FROM sales_with_previous
WHERE previous_amount IS NOT NULL
  AND amount > previous_amount;
```

---

# PART 43 — PERFORMANCE SCENARIOS

# Q119. Scenario: A query is slow. What would you check?

**Answer:**

I would check:

1. The execution plan
2. Indexes
3. Join conditions
4. Filtering conditions
5. Number of rows scanned
6. Whether unnecessary columns are selected
7. Whether functions prevent index usage
8. Whether a large sort or temporary operation is occurring
9. Data volume
10. Whether the query can be rewritten

In MySQL, I would commonly start with:

```sql
EXPLAIN
SELECT ...
```

and, where appropriate, use more detailed execution-plan tools.

---

# Q120. Why is SELECT * sometimes discouraged?

**Answer:**

`SELECT *` returns every column.

In production queries, explicitly selecting required columns is often better because:

- Less data is transferred
- Query intent is clearer
- Unnecessary columns aren't read/returned
- Application code is less affected by schema changes
- It can help performance in some cases

Instead of:

```sql
SELECT *
FROM employees;
```

use:

```sql
SELECT
    employee_id,
    first_name,
    salary
FROM employees;
```

---

# Q121. Why can a function on an indexed column hurt performance?

Example:

```sql
WHERE YEAR(hire_date) = 2025
```

Depending on the optimizer and available indexes, applying a function to the column can make it harder to use a normal index efficiently.

A range condition is often preferable:

```sql
WHERE hire_date >= '2025-01-01'
  AND hire_date < '2026-01-01'
```

This is a common performance consideration.

---

# Q122. What is EXPLAIN?

**Answer:**

`EXPLAIN` shows how the database plans to execute a query.

Example:

```sql
EXPLAIN
SELECT *
FROM employees
WHERE department_id = 1;
```

It can help identify:

- Access methods
- Index usage
- Join order
- Estimated rows
- Potentially expensive operations

---

# PART 44 — TRANSACTION SCENARIOS

# Q123. Scenario: Transfer ₹10,000 from Account A to Account B.

**Answer:**

Both operations should be inside one transaction.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 10000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 10000
WHERE account_id = 2;

COMMIT;
```

If something fails:

```sql
ROLLBACK;
```

The goal is to avoid a situation where money is removed from one account but not added to the other.

---

# Q124. What happens if a transaction fails before COMMIT?

**Answer:**

If the transaction is rolled back, uncommitted changes are undone.

Example:

```sql
START TRANSACTION;

UPDATE employees
SET salary = salary * 1.10;

ROLLBACK;
```

The uncommitted update is rolled back.

---

# PART 45 — CONCURRENCY

# Q125. What is a deadlock?

**Answer:**

A deadlock occurs when two transactions wait for each other to release resources.

Example concept:

```text
Transaction A locks Row 1
Transaction B locks Row 2

A waits for Row 2
B waits for Row 1

        ↓

Deadlock
```

The database detects deadlocks and typically aborts one transaction so the other can proceed.

---

# Q126. What is a dirty read?

**Answer:**

A dirty read happens when one transaction reads data written by another transaction that has not committed yet.

If the second transaction rolls back, the first transaction read data that was never actually committed.

---

# Q127. What is a non-repeatable read?

**Answer:**

A transaction reads the same row twice and gets different values because another transaction committed an update between the two reads.

---

# Q128. What is a phantom read?

**Answer:**

A transaction runs the same query twice and finds a different set of rows because another transaction inserted or deleted matching rows between the reads.

---

# PART 46 — ISOLATION LEVELS

# Q129. What are transaction isolation levels?

**Answer:**

Common SQL isolation levels are:

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

They control how much one transaction can observe changes made by other concurrent transactions.

Higher isolation generally provides stronger consistency but may reduce concurrency.

---

# PART 47 — DATA INTEGRITY

# Q130. What is referential integrity?

**Answer:**

Referential integrity ensures relationships between tables remain valid.

Example:

If:

```text
employees.department_id = 10
```

then department 10 should exist in the referenced `departments` table when enforced by a foreign key.

---

# PART 48 — NULL AND JOINS SCENARIO

# Q131. Why can a LEFT JOIN accidentally become an INNER JOIN?

Consider:

```sql
SELECT
    d.department_name,
    e.first_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
WHERE e.salary > 70000;
```

The `WHERE` condition removes rows where `e` is NULL.

Therefore departments without employees disappear.

If you want to preserve the LEFT JOIN behavior and only match employees earning above 70,000, put the condition in the JOIN:

```sql
SELECT
    d.department_name,
    e.first_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
   AND e.salary > 70000;
```

This is a **very common interview scenario**.

---

# PART 49 — COUNT WITH LEFT JOIN

# Q132. Why can COUNT(*) give unexpected results with LEFT JOIN?

Example:

```sql
SELECT
    d.department_id,
    COUNT(*) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id;
```

A department with no employees can still have one result row because of the LEFT JOIN.

Better:

```sql
SELECT
    d.department_id,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id;
```

Why?

Because `COUNT(e.employee_id)` counts only non-NULL employee IDs.

---

# PART 50 — NULL AND NOT IN

# Q133. Why can NOT IN cause unexpected results when NULL exists?

Suppose:

```sql
WHERE employee_id NOT IN (
    SELECT manager_id
    FROM employees
);
```

If the subquery contains NULL, SQL's three-valued logic can produce unexpected results.

A safer alternative for many anti-join scenarios is:

```sql
WHERE NOT EXISTS (
    SELECT 1
    FROM employees m
    WHERE m.manager_id = e.employee_id
);
```

`NOT EXISTS` is often preferred for this type of existence test.

---

# PART 51 — DATABASE DESIGN SCENARIOS

# Q134. How would you design an employee database?

**Answer:**

I would avoid storing everything in one table.

I might create:

```text
companies
departments
jobs
employees
addresses
employee_addresses
employee_salary_history
projects
employee_projects
sales
```

Relationships could be:

```text
company
   ↓
department
   ↓
employee
   ↓
salary history

employee ↔ project
employee → sales
employee → manager
```

This reduces unnecessary duplication and allows the database to represent relationships clearly.

---

# Q135. How would you store employee salary history?

**Answer:**

I would use a separate history table.

Example:

```text
employee_salary_history

salary_history_id
employee_id
old_salary
new_salary
effective_date
reason
```

Instead of overwriting historical salary information, each change creates a new history record.

This provides an audit trail.

---

# Q136. An employee can work on multiple projects. How would you design it?

**Answer:**

This is a many-to-many relationship.

We should use a junction table:

```text
employees
    ↕
employee_projects
    ↕
projects
```

Example:

```text
employee_projects

employee_id
project_id
```

This avoids storing:

```text
project1, project2, project3
```

inside a single employee column.

---

# PART 52 — COMMON INTERVIEW TRAPS

# Q137. What is the difference between = and IS NULL?

**Answer:**

`=` is used for normal value comparison.

Example:

```sql
WHERE salary = 70000
```

NULL requires:

```sql
WHERE manager_id IS NULL
```

Because NULL represents an unknown/missing value and is handled using SQL's three-valued logic.

---

# Q138. Can we use aggregate functions in WHERE?

**Answer:**

Normally, no.

This is incorrect:

```sql
WHERE AVG(salary) > 70000
```

Use:

```sql
HAVING AVG(salary) > 70000
```

because the aggregate is evaluated for groups.

---

# Q139. Can GROUP BY and ORDER BY be used together?

**Answer:**

Yes.

Example:

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
ORDER BY avg_salary DESC;
```

This returns departments ordered by average salary.

---

# Q140. What happens when we use DISTINCT with multiple columns?

**Answer:**

DISTINCT applies to the **combination** of selected columns.

Example:

```sql
SELECT DISTINCT
    department_id,
    work_mode
FROM employees;
```

It removes duplicate `(department_id, work_mode)` combinations.

It does not independently make each column unique.

---

# PART 53 — VERY COMMON RAPID-FIRE QUESTIONS

## Q141. What is a candidate key?

A candidate key is a column or combination of columns that can uniquely identify a row.

A table can have multiple candidate keys, but one is selected as the primary key.

---

## Q142. What is a composite key?

A composite key uses multiple columns together to uniquely identify a row.

Example:

```sql
PRIMARY KEY (employee_id, project_id)
```

This is common in junction tables.

---

## Q143. What is a surrogate key?

A surrogate key is an artificial/system-generated identifier.

Example:

```text
employee_id = 101
```

It has no business meaning and exists mainly to identify the row.

---

## Q144. What is a natural key?

A natural key is a real-world/business value that uniquely identifies a record.

Example:

```text
email
employee_code
```

if the business rules guarantee uniqueness.

---

## Q145. What is referential action?

A foreign key can define what happens when the referenced row is updated or deleted.

Examples:

```text
CASCADE
SET NULL
RESTRICT
NO ACTION
```

The exact behavior and support can vary by database system and configuration.

---

## Q146. What is a Cartesian product?

A Cartesian product occurs when every row from one table is combined with every row from another table.

Example:

```sql
SELECT *
FROM employees
CROSS JOIN departments;
```

If:

```text
employees = 20 rows
departments = 10 rows
```

the result can contain:

```text
20 × 10 = 200 rows
```

An accidental missing join condition can sometimes produce a huge Cartesian-like result.

---

# PART 54 — PRACTICAL INTERVIEW SCENARIOS

## Q147. Your query returns duplicate employees after a JOIN. What would you check?

**Answer:**

I would check:

1. Whether the relationship is one-to-many
2. Whether the JOIN condition is correct
3. Whether I accidentally joined on a non-unique column
4. Whether I actually need DISTINCT
5. Whether aggregation is required
6. Whether the business requirement expects multiple rows

I would **not blindly add DISTINCT** without understanding why duplicates exist.

---

## Q148. Your LEFT JOIN is returning fewer rows than expected. What do you check?

**Answer:**

I would look for filters on the right table in the `WHERE` clause.

For example:

```sql
LEFT JOIN employees e
    ON ...
WHERE e.salary > 50000
```

can remove NULL-side rows.

I would consider moving the condition into the `ON` clause if the requirement is to preserve unmatched left rows.

---

## Q149. A report needs departments even when they have zero employees. Which JOIN?

**Answer:**

Use:

```sql
departments d
LEFT JOIN employees e
```

because the department table is the table whose rows must all be preserved.

---

## Q150. A report needs only employees who belong to a valid department. Which JOIN?

**Answer:**

Usually:

```sql
employees e
INNER JOIN departments d
    ON e.department_id = d.department_id
```

because only matching records are required.

---

# PART 55 — FINAL INTERVIEW CHEAT SHEET

## Most Important SQL Patterns to Remember

### 1. Employees above average

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
```

### 2. Employee vs manager

```sql
JOIN employees m
    ON e.manager_id = m.employee_id
```

### 3. Departments with no employees

```sql
LEFT JOIN employees e
    ON e.department_id = d.department_id
WHERE e.employee_id IS NULL
```

### 4. Duplicate values

```sql
GROUP BY column
HAVING COUNT(*) > 1
```

### 5. Top N overall

```sql
ORDER BY salary DESC
LIMIT N
```

### 6. Top N per department

```sql
ROW_NUMBER() OVER (
    PARTITION BY department_id
    ORDER BY salary DESC
)
```

### 7. Ranking with ties

```sql
DENSE_RANK() OVER (
    ORDER BY salary DESC
)
```

### 8. Previous row

```sql
LAG(value) OVER (
    ORDER BY date_column
)
```

### 9. Next row

```sql
LEAD(value) OVER (
    ORDER BY date_column
)
```

### 10. Running total

```sql
SUM(amount) OVER (
    ORDER BY date_column
)
```

### 11. Department average while keeping employees

```sql
AVG(salary) OVER (
    PARTITION BY department_id
)
```

### 12. NULL check

```sql
IS NULL
IS NOT NULL
```

### 13. Replace NULL

```sql
COALESCE(column, default_value)
```

### 14. Conditional logic

```sql
CASE
    WHEN condition THEN result
    ELSE result
END
```

### 15. Existence check

```sql
WHERE EXISTS (...)
```

### 16. Transaction

```sql
START TRANSACTION;

-- operations

COMMIT;
```

or:

```sql
ROLLBACK;
```

---

# HOW TO ANSWER SQL INTERVIEW QUESTIONS

When the interviewer asks a SQL theory question, use this structure:

### 1. Give the definition

Keep it short.

### 2. Explain why it is used

Tell the interviewer the practical purpose.

### 3. Give a small example

Use a simple example instead of a huge query.

### 4. Mention an important difference/trade-off

For example:

```text
WHERE → rows
HAVING → groups
```

or:

```text
RANK → gaps after ties
DENSE_RANK → no gaps
```

or:

```text
INNER JOIN → matching rows
LEFT JOIN → all left rows
```

This makes your answer sound practical rather than memorized.

---

# TOP 20 QUESTIONS TO PREPARE FIRST

If you have limited interview preparation time, prioritize these:

1. What is SQL?
2. SQL vs DBMS vs RDBMS
3. Primary Key vs Foreign Key
4. Primary Key vs UNIQUE
5. DELETE vs TRUNCATE vs DROP
6. WHERE vs HAVING
7. GROUP BY
8. INNER JOIN vs LEFT JOIN
9. SELF JOIN
10. Subquery vs Correlated Subquery
11. IN vs EXISTS
12. UNION vs UNION ALL
13. NULL and COALESCE
14. Indexes and their disadvantages
15. Normalization
16. Transactions
17. ACID properties
18. RANK vs DENSE_RANK vs ROW_NUMBER
19. CTE
20. Employee vs Manager / Top N / Duplicate / Highest Salary scenarios

These concepts cover a very large portion of common SQL interview discussions.