# SQL Interview Preparation Guide

## Table of Contents

1. SQL Fundamentals
2. Consistent Interview Dataset
3. Most Frequently Asked SQL Interview Q&A
4. Scenario-Based SQL Questions
5. Multiple Query Solutions + Pros/Cons
6. JOIN Interview Questions
7. GROUP BY, HAVING & Aggregation
8. Subqueries & CTEs
9. Window Functions
10. Advanced SQL Scenarios
11. DELETE vs TRUNCATE vs DROP
12. NULL and Three-Valued Logic
13. Indexing & Query Performance
14. Transactions & ACID
15. Constraints & Keys
16. Common SQL Mistakes
17. Interview Memory Tricks
18. SQL Interview Simulation
19. Quick Revision Cheat Sheet

---

# 1. SQL Fundamentals

## What is SQL?

**SQL (Structured Query Language)** is used to communicate with relational databases.

It is commonly used to:

- Retrieve data — `SELECT`
- Insert data — `INSERT`
- Modify data — `UPDATE`
- Delete data — `DELETE`
- Create database objects — `CREATE`
- Modify objects — `ALTER`
- Remove objects — `DROP`
- Control transactions — `COMMIT`, `ROLLBACK`
- Control permissions — `GRANT`, `REVOKE`

---

## SQL Command Categories

| Category | Meaning | Examples |
|---|---|---|
| DQL | Data Query Language | `SELECT` |
| DML | Data Manipulation Language | `INSERT`, `UPDATE`, `DELETE` |
| DDL | Data Definition Language | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| DCL | Data Control Language | `GRANT`, `REVOKE` |
| TCL | Transaction Control Language | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

### Memory Trick

**DQL = Query**  
**DML = Manipulate data**  
**DDL = Define database structure**  
**DCL = Control access**  
**TCL = Transaction control**

---

# 2. Consistent Interview Dataset

We will use the following company database throughout the guide.

## Entity Relationship

```text
Departments
     |
     | 1
     |
     | N
Employees
     |
     | 1
     |
     | N
Sales
```

An employee belongs to a department.

An employee may also manage other employees.

An employee can have multiple sales.

---

## CREATE TABLE Statements

```sql
CREATE TABLE Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);

CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    manager_id INT,
    salary DECIMAL(10,2),
    hire_date DATE,
    job_title VARCHAR(50),
    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id),
    FOREIGN KEY (manager_id)
        REFERENCES Employees(employee_id)
);

CREATE TABLE Sales (
    sale_id INT PRIMARY KEY,
    employee_id INT,
    sale_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (employee_id)
        REFERENCES Employees(employee_id)
);
```

---

# 3. Sample Data

## Departments

```sql
INSERT INTO Departments
(department_id, department_name, location)
VALUES
(10, 'Engineering', 'Mumbai'),
(20, 'Sales', 'Delhi'),
(30, 'HR', 'Mumbai'),
(40, 'Finance', 'Bangalore'),
(50, 'Marketing', 'Pune');
```

## Employees

```sql
INSERT INTO Employees
(employee_id, employee_name, department_id, manager_id, salary, hire_date, job_title)
VALUES
(1, 'Alice', 10, NULL, 120000, '2020-01-15', 'Engineering Manager'),
(2, 'Bob', 10, 1, 90000, '2021-03-10', 'Senior Developer'),
(3, 'Charlie', 10, 1, 85000, '2022-06-20', 'Developer'),
(4, 'David', 10, 2, 95000, '2023-02-01', 'Developer'),

(5, 'Eva', 20, NULL, 110000, '2019-08-12', 'Sales Manager'),
(6, 'Frank', 20, 5, 70000, '2022-01-10', 'Sales Executive'),
(7, 'Grace', 20, 5, 75000, '2021-11-05', 'Sales Executive'),
(8, 'Henry', 20, 5, 65000, '2023-07-01', 'Sales Executive'),

(9, 'Ivy', 30, NULL, 80000, '2020-09-15', 'HR Manager'),
(10, 'Jack', 30, 9, 60000, '2022-04-18', 'HR Executive'),

(11, 'Karen', 40, NULL, 105000, '2018-05-22', 'Finance Manager'),
(12, 'Leo', 40, 11, 68000, '2023-01-15', 'Accountant'),

(13, 'Mia', 50, NULL, 95000, '2021-02-20', 'Marketing Manager'),
(14, 'Nick', 50, 13, 72000, '2022-08-10', 'Marketing Executive');
```

## Sales

```sql
INSERT INTO Sales
(sale_id, employee_id, sale_date, amount)
VALUES
(101, 6, '2026-01-05', 5000),
(102, 6, '2026-01-15', 7000),
(103, 6, '2026-02-10', 6000),

(104, 7, '2026-01-08', 8000),
(105, 7, '2026-02-12', 9000),

(106, 8, '2026-01-20', 4000),
(107, 8, '2026-02-05', 4500),

(108, 2, '2026-01-12', 3000),
(109, 3, '2026-02-15', 2500),
(110, 14, '2026-02-20', 5500);
```

---

# 4. Frequently Asked SQL Interview Q&A

## Q1. What is a primary key?

A **primary key** uniquely identifies every row in a table.

Properties:

- Must be unique.
- Cannot contain `NULL`.
- A table normally has one primary key constraint.
- It can consist of multiple columns — a composite primary key.

Example:

```sql
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100)
);
```

### Interview shortcut

> Primary key = "Who exactly is this row?"

---

# Q2. What is a foreign key?

A foreign key establishes a relationship between tables.

```sql
department_id INT REFERENCES Departments(department_id)
```

It ensures that an employee cannot reference a department that doesn't exist, subject to the database's constraint behavior.

### Memory trick

**Primary key → Parent identity**

**Foreign key → Child relationship**

---

# Q3. What is a UNIQUE constraint?

It prevents duplicate values.

```sql
email VARCHAR(255) UNIQUE
```

Unlike a primary key, the exact treatment of `NULL` values in a unique constraint can vary by database system.

---

# Q4. What is the difference between WHERE and HAVING?

### WHERE

Filters rows **before grouping**.

```sql
SELECT *
FROM Employees
WHERE salary > 80000;
```

### HAVING

Filters groups **after GROUP BY**.

```sql
SELECT department_id, AVG(salary)
FROM Employees
GROUP BY department_id
HAVING AVG(salary) > 80000;
```

### Memory Trick

> **WHERE = rows**

> **HAVING = groups**

---

# Q5. What is GROUP BY?

`GROUP BY` combines rows having the same values so aggregate functions can operate on each group.

```sql
SELECT department_id, AVG(salary)
FROM Employees
GROUP BY department_id;
```

---

# Q6. What are aggregate functions?

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
SELECT
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    MAX(salary) AS maximum_salary
FROM Employees;
```

---

# Q7. What is the difference between COUNT(*) and COUNT(column)?

```sql
COUNT(*)
```

counts rows.

```sql
COUNT(column_name)
```

counts non-NULL values in that column.

Example:

```sql
SELECT
    COUNT(*) AS total_rows,
    COUNT(manager_id) AS employees_with_manager
FROM Employees;
```

Expected result:

| total_rows | employees_with_manager |
|---:|---:|
| 14 | 10 |

Four employees are department managers and therefore have no manager.

---

# Q8. What is NULL?

`NULL` means **unknown, missing, or not applicable**.

It is not:

- `0`
- `''`
- `FALSE`

Incorrect:

```sql
WHERE manager_id = NULL
```

Correct:

```sql
WHERE manager_id IS NULL
```

And:

```sql
WHERE manager_id IS NOT NULL
```

---

# Q9. What is a JOIN?

A JOIN combines rows from multiple tables based on a relationship.

Example:

```sql
SELECT
    e.employee_name,
    d.department_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id;
```

---

# Q10. Explain INNER JOIN vs LEFT JOIN.

### INNER JOIN

Returns matching rows from both tables.

```sql
SELECT *
FROM Employees e
INNER JOIN Departments d
    ON e.department_id = d.department_id;
```

### LEFT JOIN

Returns every row from the left table, even if no matching row exists on the right.

```sql
SELECT *
FROM Employees e
LEFT JOIN Departments d
    ON e.department_id = d.department_id;
```

### Memory Trick

> LEFT JOIN = "Don't lose my left table."

---

# Q11. What is a SELF JOIN?

A table joined to itself.

It is especially useful for hierarchical data such as employees and managers.

```sql
SELECT
    e.employee_name AS employee,
    m.employee_name AS manager
FROM Employees e
LEFT JOIN Employees m
    ON e.manager_id = m.employee_id;
```

---

# Q12. What is a CROSS JOIN?

A Cartesian product.

If table A has 5 rows and table B has 4 rows:

```text
5 × 4 = 20 rows
```

Example:

```sql
SELECT *
FROM Employees
CROSS JOIN Departments;
```

Use it carefully because it can generate a very large result set.

---

# Q13. What is a subquery?

A query inside another query.

```sql
SELECT *
FROM Employees
WHERE salary > (
    SELECT AVG(salary)
    FROM Employees
);
```

---

# Q14. What is a correlated subquery?

A subquery that refers to a column from the outer query.

```sql
SELECT e.employee_name, e.salary
FROM Employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
);
```

The inner query is evaluated in relation to each outer employee.

---

# Q15. What is a CTE?

CTE = **Common Table Expression**.

It creates a temporary named result set for one SQL statement.

```sql
WITH HighEarners AS (
    SELECT *
    FROM Employees
    WHERE salary > 80000
)
SELECT *
FROM HighEarners;
```

Advantages:

- Easier to read.
- Useful for multi-step queries.
- Useful for recursive queries.
- Can make complex logic easier to maintain.

---

# Q16. UNION vs UNION ALL?

### UNION

Combines results and removes duplicates.

```sql
SELECT employee_name
FROM Employees
WHERE department_id = 10

UNION

SELECT employee_name
FROM Employees
WHERE salary > 80000;
```

### UNION ALL

Combines results without removing duplicates.

```sql
SELECT employee_name
FROM Employees
WHERE department_id = 10

UNION ALL

SELECT employee_name
FROM Employees
WHERE salary > 80000;
```

### Performance tip

If duplicates don't need to be removed, prefer:

```sql
UNION ALL
```

because duplicate elimination can require additional work.

---

# Q17. What is the difference between DELETE, TRUNCATE and DROP?

| Feature | DELETE | TRUNCATE | DROP |
|---|---|---|---|
| Removes rows | Yes | Yes | Table itself |
| Removes structure | No | No | Yes |
| WHERE allowed | Yes | No | No |
| Usually row-by-row operation | Often | Usually no | N/A |
| Table remains | Yes | Yes | No |
| Can be transactionally rolled back | DB-dependent, commonly yes | DB-dependent | DB-dependent |
| Triggers/identity behavior | DB-dependent | DB-dependent | N/A |

### DELETE

```sql
DELETE FROM Employees
WHERE department_id = 20;
```

### TRUNCATE

```sql
TRUNCATE TABLE Employees;
```

### DROP

```sql
DROP TABLE Employees;
```

### Memory Trick

> DELETE = delete data selectively

> TRUNCATE = empty the table

> DROP = remove the table

Always check the specific database's transaction, identity, trigger, and locking behavior before relying on these details.

---

# Q18. What is normalization?

Normalization organizes data to reduce:

- Duplication
- Update anomalies
- Insert anomalies
- Delete anomalies

Common levels:

### 1NF

Atomic values; no repeating groups.

### 2NF

1NF + no partial dependency on part of a composite key.

### 3NF

2NF + no transitive dependency on non-key columns.

### Interview shortcut

> 1NF = atomic

> 2NF = whole key

> 3NF = nothing but the key

---

# Q19. What is denormalization?

Intentionally adding redundancy to improve read performance or simplify queries.

Example:

Instead of repeatedly joining:

```text
Orders → Customers
```

an application might store selected customer information directly in an order reporting table.

Trade-off:

> Faster/easier reads vs more storage and consistency complexity.

---

# Q20. What is a view?

A view is a stored query that behaves like a virtual table.

```sql
CREATE VIEW EmployeeDetails AS
SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    e.salary
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id;
```

Then:

```sql
SELECT *
FROM EmployeeDetails;
```

---

# 5. Scenario-Based SQL Questions

The following are some of the most common practical interview problems.

---

# Scenario 1: Find Employees Earning More Than the Company Average

## Requirement

Find employees whose salary is greater than the average salary of all employees.

---

## Solution 1 — Subquery

```sql
SELECT employee_id, employee_name, salary
FROM Employees
WHERE salary > (
    SELECT AVG(salary)
    FROM Employees
);
```

### Example output

| employee_id | employee_name | salary |
|---:|---|---:|
| 1 | Alice | 120000 |
| 5 | Eva | 110000 |
| 11 | Karen | 105000 |
| 13 | Mia | 95000 |
| 4 | David | 95000 |
| 2 | Bob | 90000 |
| 3 | Charlie | 85000 |

---

## Solution 2 — CTE

```sql
WITH AverageSalary AS (
    SELECT AVG(salary) AS avg_salary
    FROM Employees
)
SELECT
    e.employee_id,
    e.employee_name,
    e.salary
FROM Employees e
CROSS JOIN AverageSalary a
WHERE e.salary > a.avg_salary;
```

### Pros

- Very readable.
- Easy to extend.
- Good for complex multi-step queries.

### Cons

- More verbose than a simple subquery.

---

## Solution 3 — Window Function

```sql
SELECT employee_id, employee_name, salary
FROM (
    SELECT
        employee_id,
        employee_name,
        salary,
        AVG(salary) OVER () AS avg_salary
    FROM Employees
) x
WHERE salary > avg_salary;
```

### Pros

- Useful when you also need the average displayed.
- Powerful for analytical queries.

### Cons

- Overkill for a simple aggregate comparison.

### Interview Tip

If asked this question, start with the **subquery**. Then mention the CTE/window-function alternatives.

---

# Scenario 2: Find the Second Highest Salary

This is one of the most frequently asked SQL interview questions.

---

## Solution 1 — MAX + Subquery

```sql
SELECT MAX(salary) AS second_highest_salary
FROM Employees
WHERE salary < (
    SELECT MAX(salary)
    FROM Employees
);
```

Output:

| second_highest_salary |
|---:|
| 110000 |

---

## Solution 2 — DENSE_RANK

```sql
SELECT employee_id, employee_name, salary
FROM (
    SELECT
        employee_id,
        employee_name,
        salary,
        DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM Employees
) x
WHERE salary_rank = 2;
```

Output:

| employee_id | employee_name | salary |
|---:|---|---:|
| 5 | Eva | 110000 |

### Why DENSE_RANK?

Suppose salaries are:

```text
120000
110000
110000
95000
```

`DENSE_RANK()` produces:

```text
120000 → 1
110000 → 2
110000 → 2
95000  → 3
```

Therefore it correctly handles ties.

---

## Solution 3 — OFFSET/FETCH

For databases supporting this syntax:

```sql
SELECT DISTINCT salary
FROM Employees
ORDER BY salary DESC
OFFSET 1 ROW
FETCH NEXT 1 ROW ONLY;
```

### Pros/Cons

| Method | Advantage | Disadvantage |
|---|---|---|
| MAX subquery | Simple | Doesn't directly return all employees with that salary |
| DENSE_RANK | Handles ties | Slightly more complex |
| OFFSET | Short | Syntax/database support varies |

### Interview Tip

If the interviewer says:

> "Find the second highest salary."

Ask:

> "Do you mean the second highest distinct salary, and should I return all employees tied at that salary?"

That's a strong interview response.

---

# Scenario 3: Find Employees Earning More Than Their Manager

This is a classic SELF JOIN question.

---

## Solution 1 — SELF JOIN

```sql
SELECT
    e.employee_name AS employee,
    e.salary AS employee_salary,
    m.employee_name AS manager,
    m.salary AS manager_salary
FROM Employees e
JOIN Employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

Output:

| employee | employee_salary | manager | manager_salary |
|---|---:|---|---:|
| David | 95000 | Bob | 90000 |

---

## Solution 2 — Correlated Subquery

```sql
SELECT
    e.employee_name,
    e.salary
FROM Employees e
WHERE e.salary > (
    SELECT m.salary
    FROM Employees m
    WHERE m.employee_id = e.manager_id
);
```

### Pros

- Compact.
- Easy to understand once correlated subqueries are familiar.

### Cons

- SELF JOIN is generally clearer for this relationship.

---

## Solution 3 — CTE + JOIN

```sql
WITH EmployeeManagers AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.salary,
        m.employee_name AS manager_name,
        m.salary AS manager_salary
    FROM Employees e
    JOIN Employees m
        ON e.manager_id = m.employee_id
)
SELECT *
FROM EmployeeManagers
WHERE salary > manager_salary;
```

### Interview Tip

Whenever you hear:

> "employee vs manager"

immediately think:

> **SELF JOIN**

---

# Scenario 4: Find the Highest-Paid Employee in Each Department

---

## Solution 1 — Window Function

```sql
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM (
    SELECT
        employee_id,
        employee_name,
        department_id,
        salary,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees
) x
WHERE rnk = 1;
```

---

## Solution 2 — GROUP BY + JOIN

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM Employees e
JOIN (
    SELECT
        department_id,
        MAX(salary) AS max_salary
    FROM Employees
    GROUP BY department_id
) x
    ON e.department_id = x.department_id
   AND e.salary = x.max_salary;
```

### Important

This version returns **all employees tied for the highest salary**.

---

## Solution 3 — Correlated Subquery

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM Employees e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
);
```

### Which should you choose?

For modern SQL interviews:

> Prefer `RANK()`/`DENSE_RANK()` when solving top-N-per-group problems.

---

# Scenario 5: Find the Top 2 Salaries in Each Department

This is a classic **TOP-N PER GROUP** problem.

---

## Solution 1 — DENSE_RANK

```sql
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM (
    SELECT
        employee_id,
        employee_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees
) x
WHERE rnk <= 2;
```

### Why DENSE_RANK?

It handles salary ties correctly.

---

## Solution 2 — ROW_NUMBER

```sql
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM (
    SELECT
        employee_id,
        employee_name,
        department_id,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rn
    FROM Employees
) x
WHERE rn <= 2;
```

### Difference

`ROW_NUMBER()` gives unique positions.

`DENSE_RANK()` gives the same rank to ties.

---

## Solution 3 — Correlated Count

```sql
SELECT e.*
FROM Employees e
WHERE (
    SELECT COUNT(DISTINCT e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
      AND e2.salary > e.salary
) < 2;
```

### Pros

- Demonstrates strong understanding of correlated subqueries.

### Cons

- Less readable.
- Usually less attractive than a window function.

---

# Scenario 6: Find Departments With More Than 2 Employees

---

## Solution 1 — GROUP BY + HAVING

```sql
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM Employees
GROUP BY department_id
HAVING COUNT(*) > 2;
```

Output:

| department_id | employee_count |
|---:|---:|
| 10 | 4 |
| 20 | 4 |

---

## Solution 2 — JOIN Departments

```sql
SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM Departments d
JOIN Employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
HAVING COUNT(e.employee_id) > 2;
```

---

## Solution 3 — CTE

```sql
WITH DepartmentCounts AS (
    SELECT
        department_id,
        COUNT(*) AS employee_count
    FROM Employees
    GROUP BY department_id
)
SELECT
    d.department_name,
    x.employee_count
FROM DepartmentCounts x
JOIN Departments d
    ON d.department_id = x.department_id
WHERE x.employee_count > 2;
```

### Interview Tip

Whenever you see:

> "groups having more than X"

think:

```sql
GROUP BY ...
HAVING COUNT(...) > X
```

---

# Scenario 7: Find Departments With No Employees

---

## Solution 1 — LEFT JOIN

```sql
SELECT
    d.department_id,
    d.department_name
FROM Departments d
LEFT JOIN Employees e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;
```

Output:

| department_id | department_name |
|---:|---|
| — | Depends on current dataset |

Our current sample data has employees in every department.

To test the query:

```sql
INSERT INTO Departments
(department_id, department_name, location)
VALUES
(60, 'Legal', 'Mumbai');
```

Then the result becomes:

| department_id | department_name |
|---:|---|
| 60 | Legal |

---

## Solution 2 — NOT EXISTS

```sql
SELECT
    d.department_id,
    d.department_name
FROM Departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.department_id = d.department_id
);
```

### Which is better?

`NOT EXISTS` is often an excellent choice for existence tests.

### Memory Trick

> "Find things with no matching rows" → `LEFT JOIN ... IS NULL` or `NOT EXISTS`

---

# Scenario 8: Calculate Total Sales Per Employee

---

## Solution 1 — GROUP BY

```sql
SELECT
    e.employee_id,
    e.employee_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM Employees e
LEFT JOIN Sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.employee_name;
```

Example:

| employee | total_sales |
|---|---:|
| Frank | 18000 |
| Grace | 17000 |
| Henry | 8500 |
| Bob | 3000 |
| Charlie | 2500 |
| Nick | 5500 |
| Alice | 0 |

### Why LEFT JOIN?

We want employees with **zero sales** too.

An INNER JOIN would remove employees with no sales.

---

## Solution 2 — Correlated Subquery

```sql
SELECT
    e.employee_id,
    e.employee_name,
    COALESCE((
        SELECT SUM(s.amount)
        FROM Sales s
        WHERE s.employee_id = e.employee_id
    ), 0) AS total_sales
FROM Employees e;
```

### Pros

- Simple conceptually.

### Cons

- Can be less efficient or less scalable depending on the optimizer and database.

---

## Solution 3 — Pre-Aggregate Then JOIN

```sql
SELECT
    e.employee_id,
    e.employee_name,
    COALESCE(x.total_sales, 0) AS total_sales
FROM Employees e
LEFT JOIN (
    SELECT
        employee_id,
        SUM(amount) AS total_sales
    FROM Sales
    GROUP BY employee_id
) x
    ON e.employee_id = x.employee_id;
```

### Interview Tip

If aggregation happens before joining, pre-aggregation can prevent accidental row multiplication.

---

# Scenario 9: Find the Employee With the Highest Total Sales

---

## Solution 1 — GROUP BY + ORDER BY

```sql
SELECT
    e.employee_id,
    e.employee_name,
    SUM(s.amount) AS total_sales
FROM Employees e
JOIN Sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.employee_name
ORDER BY total_sales DESC
FETCH FIRST 1 ROW ONLY;
```

Expected result:

| employee | total_sales |
|---|---:|
| Frank | 18000 |

---

## Solution 2 — RANK

```sql
SELECT
    employee_id,
    employee_name,
    total_sales
FROM (
    SELECT
        e.employee_id,
        e.employee_name,
        SUM(s.amount) AS total_sales,
        RANK() OVER (
            ORDER BY SUM(s.amount) DESC
        ) AS rnk
    FROM Employees e
    JOIN Sales s
        ON e.employee_id = s.employee_id
    GROUP BY
        e.employee_id,
        e.employee_name
) x
WHERE rnk = 1;
```

### Advantage

Returns all employees tied for first place.

---

# Scenario 10: Find Employees Who Have Never Made a Sale

---

## Solution 1 — LEFT JOIN

```sql
SELECT
    e.employee_id,
    e.employee_name
FROM Employees e
LEFT JOIN Sales s
    ON e.employee_id = s.employee_id
WHERE s.sale_id IS NULL;
```

---

## Solution 2 — NOT EXISTS

```sql
SELECT
    e.employee_id,
    e.employee_name
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales s
    WHERE s.employee_id = e.employee_id
);
```

### Interview Preference

For "does a related record exist?" questions:

```sql
EXISTS
NOT EXISTS
```

are often elegant choices.

---

# Scenario 11: Find Employees Hired in the Last 3 Years

Date functions vary between database systems.

A PostgreSQL-style solution:

```sql
SELECT
    employee_id,
    employee_name,
    hire_date
FROM Employees
WHERE hire_date >= CURRENT_DATE - INTERVAL '3 years';
```

Another approach:

```sql
SELECT
    employee_id,
    employee_name,
    hire_date
FROM Employees
WHERE hire_date >= DATE '2023-09-04';
```

The second is useful for reproducible testing, while the first is dynamic.

### Interview Tip

Always ask which SQL database is being used if date syntax matters:

- PostgreSQL
- MySQL
- SQL Server
- Oracle
- Snowflake
- BigQuery

SQL concepts transfer, but syntax doesn't always.

---

# Scenario 12: Find the Average Salary by Department

```sql
SELECT
    department_id,
    AVG(salary) AS average_salary
FROM Employees
GROUP BY department_id;
```

Join to display department names:

```sql
SELECT
    d.department_name,
    AVG(e.salary) AS average_salary
FROM Departments d
JOIN Employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name;
```

---

# Scenario 13: Find Employees Whose Salary Is Above Their Department Average

This is more difficult and commonly appears in interviews.

---

## Solution 1 — Correlated Subquery

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM Employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employees e2
    WHERE e2.department_id = e.department_id
);
```

---

## Solution 2 — CTE + JOIN

```sql
WITH DepartmentAverage AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM Employees
    GROUP BY department_id
)
SELECT
    e.employee_id,
    e.employee_name,
    e.salary,
    e.department_id
FROM Employees e
JOIN DepartmentAverage d
    ON e.department_id = d.department_id
WHERE e.salary > d.avg_salary;
```

---

## Solution 3 — Window Function

```sql
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM (
    SELECT
        employee_id,
        employee_name,
        department_id,
        salary,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS dept_avg
    FROM Employees
) x
WHERE salary > dept_avg;
```

### Best interview answer

Use the **window function** if the question involves both:

- Individual rows
- Group-level statistics

---

# Scenario 14: Assign Salary Rank Within Each Department

```sql
SELECT
    employee_id,
    employee_name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS salary_rank
FROM Employees;
```

---

# Scenario 15: Difference Between RANK, DENSE_RANK and ROW_NUMBER

Suppose salaries are:

```text
120000
110000
110000
95000
```

### ROW_NUMBER

```text
1
2
3
4
```

### RANK

```text
1
2
2
4
```

### DENSE_RANK

```text
1
2
2
3
```

### Memory Trick

> `ROW_NUMBER` = every row gets a unique number

> `RANK` = ties create gaps

> `DENSE_RANK` = ties don't create gaps

---

# 6. JOIN Interview Questions

## INNER JOIN

Only matching records.

```sql
SELECT *
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id;
```

---

## LEFT JOIN

Everything from the left table + matching rows from the right.

```sql
SELECT *
FROM Departments d
LEFT JOIN Employees e
    ON d.department_id = e.department_id;
```

Useful for:

> "Show all departments, including departments with no employees."

---

## RIGHT JOIN

Everything from the right table.

Conceptually:

```sql
A RIGHT JOIN B
```

is similar to:

```sql
B LEFT JOIN A
```

Many developers prefer LEFT JOIN because it is easier to reason about consistently.

---

## FULL OUTER JOIN

Returns:

- Matching rows
- Unmatched rows from left
- Unmatched rows from right

Support varies by database.

---

## SELF JOIN

Example:

```sql
SELECT
    e.employee_name,
    m.employee_name AS manager_name
FROM Employees e
LEFT JOIN Employees m
    ON e.manager_id = m.employee_id;
```

---

# 7. GROUP BY, HAVING and Aggregation

## WHERE vs HAVING

Remember the logical idea:

```text
FROM
→ WHERE
→ GROUP BY
→ HAVING
→ SELECT
→ ORDER BY
```

This is a conceptual logical processing order, not necessarily the physical execution order used by the optimizer.

Example:

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM Employees
WHERE salary > 60000
GROUP BY department_id
HAVING AVG(salary) > 80000
ORDER BY avg_salary DESC;
```

---

# 8. Subqueries and CTEs

## Scalar Subquery

Returns one value.

```sql
SELECT *
FROM Employees
WHERE salary > (
    SELECT AVG(salary)
    FROM Employees
);
```

---

## IN Subquery

```sql
SELECT *
FROM Employees
WHERE department_id IN (
    SELECT department_id
    FROM Departments
    WHERE location = 'Mumbai'
);
```

---

## EXISTS

```sql
SELECT d.*
FROM Departments d
WHERE EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.department_id = d.department_id
);
```

### EXISTS memory trick

> EXISTS asks: "Does at least one matching row exist?"

The database doesn't conceptually need the selected value from `SELECT 1`; the existence itself is what matters.

---

# 9. Window Functions

Window functions are among the most important advanced SQL interview topics.

General structure:

```sql
function() OVER (
    PARTITION BY ...
    ORDER BY ...
)
```

Unlike `GROUP BY`, window functions generally **do not collapse rows**.

---

## Example: Department Average

```sql
SELECT
    employee_name,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_average
FROM Employees;
```

Each employee remains in the output while the department average is attached.

---

## Example: Running Total of Sales

```sql
SELECT
    employee_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY employee_id
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM Sales;
```

For Frank:

| sale_date | amount | running_total |
|---|---:|---:|
| 2026-01-05 | 5000 | 5000 |
| 2026-01-15 | 7000 | 12000 |
| 2026-02-10 | 6000 | 18000 |

---

## Example: Previous Sale

```sql
SELECT
    employee_id,
    sale_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY employee_id
        ORDER BY sale_date
    ) AS previous_sale
FROM Sales;
```

---

## Example: Difference From Previous Sale

```sql
SELECT
    employee_id,
    sale_date,
    amount,
    amount - LAG(amount) OVER (
        PARTITION BY employee_id
        ORDER BY sale_date
    ) AS difference
FROM Sales;
```

---

## Example: Highest Sale Per Employee

```sql
SELECT *
FROM (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY amount DESC
        ) AS rn
    FROM Sales s
) x
WHERE rn = 1;
```

---

# 10. Advanced Scenario: Month-by-Month Sales

PostgreSQL-style:

```sql
SELECT
    DATE_TRUNC('month', sale_date) AS month,
    SUM(amount) AS total_sales
FROM Sales
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY month;
```

Example:

| month | total_sales |
|---|---:|
| 2026-01-01 | 27000 |
| 2026-02-01 | 28000 |

---

# 11. Advanced Scenario: Compare Current Month Sales With Previous Month

```sql
WITH MonthlySales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(amount) AS total_sales
    FROM Sales
    GROUP BY DATE_TRUNC('month', sale_date)
)
SELECT
    month,
    total_sales,
    LAG(total_sales) OVER (
        ORDER BY month
    ) AS previous_month_sales,
    total_sales -
        LAG(total_sales) OVER (
            ORDER BY month
        ) AS change
FROM MonthlySales
ORDER BY month;
```

### Interview concept

This combines:

1. Aggregation
2. CTE
3. Window function
4. `LAG()`

---

# 12. Advanced Scenario: Find Duplicate Values

Suppose we want to find duplicate salaries.

```sql
SELECT
    salary,
    COUNT(*) AS occurrences
FROM Employees
GROUP BY salary
HAVING COUNT(*) > 1;
```

Example:

| salary | occurrences |
|---:|---:|
| 95000 | 2 |

---

# 13. Advanced Scenario: Remove Duplicate Records

Be careful: deletion syntax is database-specific when using physical row identifiers.

A generic pattern is to identify duplicates using `ROW_NUMBER()`:

```sql
WITH Duplicates AS (
    SELECT
        employee_id,
        ROW_NUMBER() OVER (
            PARTITION BY employee_name, department_id, salary
            ORDER BY employee_id
        ) AS rn
    FROM Employees
)
SELECT *
FROM Duplicates
WHERE rn > 1;
```

For a real deletion, first define precisely:

- What constitutes a duplicate?
- Which record should survive?
- What foreign keys reference the records?

### Interview best practice

Never immediately write `DELETE`.

First write the equivalent `SELECT` to verify the rows.

---

# 14. CASE Expression

`CASE` is SQL's conditional expression.

```sql
SELECT
    employee_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 80000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM Employees;
```

Example:

| employee | salary | category |
|---|---:|---|
| Alice | 120000 | High |
| Bob | 90000 | Medium |
| Jack | 60000 | Low |

---

# 15. COALESCE

`COALESCE()` returns the first non-NULL value.

```sql
SELECT
    employee_name,
    COALESCE(manager_id, 0) AS manager_id
FROM Employees;
```

A more meaningful example:

```sql
SELECT
    e.employee_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM Employees e
LEFT JOIN Sales s
    ON e.employee_id = s.employee_id
GROUP BY e.employee_id, e.employee_name;
```

### Memory Trick

> COALESCE = "Give me the first available value."

---

# 16. NULL Interview Traps

Consider:

```sql
salary > NULL
```

The result is not TRUE.

SQL uses three-valued logic:

```text
TRUE
FALSE
UNKNOWN
```

Therefore:

```sql
WHERE salary > NULL
```

does not return rows.

Use:

```sql
WHERE salary IS NULL
```

or:

```sql
WHERE salary IS NOT NULL
```

---

# 17. NOT IN vs NOT EXISTS

This is a common interview trap.

Consider:

```sql
WHERE department_id NOT IN (...)
```

If the subquery contains `NULL`, unexpected results can occur because of SQL's three-valued logic.

A safer existence-based pattern is often:

```sql
WHERE NOT EXISTS (
    SELECT 1
    FROM ...
    WHERE ...
);
```

### Interview Tip

For anti-joins, remember:

```text
NOT EXISTS
```

is often easier to reason about than:

```text
NOT IN
```

especially when NULLs may exist.

---

# 18. Indexing

## What is an index?

An index is a data structure that can help the database locate rows more efficiently.

Think of it like the index of a book.

Without an index:

```text
Search every page
```

With an appropriate index:

```text
Navigate closer to the required information
```

---

## Example

```sql
CREATE INDEX idx_employees_department
ON Employees(department_id);
```

For frequent lookups:

```sql
SELECT *
FROM Employees
WHERE department_id = 20;
```

an index on `department_id` may help.

---

## Composite Index

```sql
CREATE INDEX idx_employee_dept_salary
ON Employees(department_id, salary);
```

Column order matters.

An index on:

```text
(department_id, salary)
```

is not automatically equivalent to:

```text
(salary, department_id)
```

---

## Index Advantages

- Faster lookups.
- Can improve joins.
- Can improve filtering.
- Can help sorting/grouping in suitable cases.

## Index Disadvantages

- Takes storage.
- Slows some `INSERT`, `UPDATE`, and `DELETE` operations.
- Requires maintenance.
- Too many indexes can hurt performance.

### Interview Trick

> Indexes speed up reads but aren't free.

---

# 19. Clustered vs Non-Clustered Index

The exact implementation depends on the database.

Conceptually:

### Clustered

The table's storage/order is closely associated with the index key.

### Non-clustered

The index is a separate structure pointing toward table data.

Don't give overly database-specific answers without first asking which database engine is being discussed.

---

# 20. How to Optimize a Slow SQL Query

A strong interview answer:

### Step 1 — Inspect the execution plan

Examples:

```sql
EXPLAIN
SELECT ...
```

or database-specific variants such as:

```sql
EXPLAIN ANALYZE
```

### Step 2 — Check indexes

Ask:

- Are filter columns indexed?
- Are join columns indexed?
- Is an index actually selective/useful?

### Step 3 — Reduce unnecessary data

Avoid:

```sql
SELECT *
```

when only a few columns are required.

Prefer:

```sql
SELECT employee_id, employee_name, salary
FROM Employees;
```

### Step 4 — Check JOINs

Look for:

- Missing join conditions
- Accidental Cartesian products
- Many-to-many row multiplication

### Step 5 — Check filtering

Filter as early as appropriate.

### Step 6 — Check functions on indexed columns

For example, this can sometimes prevent effective index use:

```sql
WHERE YEAR(hire_date) = 2025
```

A range predicate may be more index-friendly:

```sql
WHERE hire_date >= DATE '2025-01-01'
  AND hire_date < DATE '2026-01-01'
```

Exact optimizer behavior is database-specific.

---

# 21. Transactions

A transaction is a logical unit of work.

Example:

```sql
BEGIN;

UPDATE Employees
SET salary = salary * 1.10
WHERE department_id = 10;

COMMIT;
```

If something goes wrong:

```sql
BEGIN;

UPDATE Employees
SET salary = salary * 1.10
WHERE department_id = 10;

ROLLBACK;
```

---

# 22. ACID Properties

## A — Atomicity

All operations happen, or none happen.

## C — Consistency

The database moves from one valid state to another valid state.

## I — Isolation

Concurrent transactions should not improperly interfere with one another.

## D — Durability

Committed changes survive failures according to the database's durability guarantees.

### Memory Trick

> **A**ll  
> **C**hanges  
> **I**n  
> **D**atabase

---

# 23. Transaction Example: Money Transfer

Suppose an account transfer consists of:

```sql
BEGIN;

UPDATE Accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE Accounts
SET balance = balance + 1000
WHERE account_id = 2;

COMMIT;
```

If the second update fails:

```sql
ROLLBACK;
```

The goal is to prevent only half of the transfer from being committed.

---

# 24. Transaction Isolation Levels

Common isolation levels:

```text
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
```

Generally, stronger isolation provides stronger consistency guarantees but may reduce concurrency or increase contention.

Database behavior varies.

---

# 25. Common Concurrency Problems

## Dirty Read

Transaction A reads uncommitted changes made by Transaction B.

---

## Non-Repeatable Read

Transaction A reads the same row twice and gets different committed values because Transaction B changed it between reads.

---

## Phantom Read

A repeated query returns a different set of rows because another transaction inserted/deleted matching rows.

---

# 26. Constraints

Common constraints:

```text
PRIMARY KEY
FOREIGN KEY
UNIQUE
NOT NULL
CHECK
DEFAULT
```

Example:

```sql
CREATE TABLE Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    salary DECIMAL(10,2) CHECK (salary >= 0),
    department_id INT,
    FOREIGN KEY (department_id)
        REFERENCES Departments(department_id)
);
```

---

# 27. Primary Key vs Unique Key

| Primary Key | UNIQUE |
|---|---|
| Identifies a row | Enforces uniqueness |
| Cannot be NULL | NULL handling varies by DB |
| One primary-key constraint | Multiple UNIQUE constraints possible |
| Often used as main identifier | Used for alternate unique values |

Example:

```text
employee_id → PRIMARY KEY
email       → UNIQUE
```

---

# 28. DELETE vs TRUNCATE vs DROP — Interview Version

### DELETE

```sql
DELETE FROM Employees
WHERE department_id = 20;
```

Use when:

> "I want to delete selected rows."

---

### TRUNCATE

```sql
TRUNCATE TABLE Employees;
```

Use when:

> "I want to empty the table."

---

### DROP

```sql
DROP TABLE Employees;
```

Use when:

> "I no longer need the table itself."

### One-line memory trick

> **DELETE = rows**

> **TRUNCATE = all rows**

> **DROP = object**

---

# 29. WHERE vs HAVING — Interview Version

### WHERE

```sql
SELECT *
FROM Employees
WHERE salary > 80000;
```

Filters individual rows.

### HAVING

```sql
SELECT department_id, AVG(salary)
FROM Employees
GROUP BY department_id
HAVING AVG(salary) > 80000;
```

Filters groups.

### Shortcut

> WHERE before aggregation; HAVING after aggregation.

---

# 30. UNION vs JOIN

These are often confused.

## UNION

Adds rows vertically.

```text
Query A
+
Query B
```

Example:

```sql
SELECT employee_name FROM Employees WHERE department_id = 10
UNION
SELECT employee_name FROM Employees WHERE department_id = 20;
```

## JOIN

Combines columns horizontally based on relationships.

```sql
SELECT
    e.employee_name,
    d.department_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id;
```

### Memory Trick

> UNION = stack rows

> JOIN = combine columns

---

# 31. EXISTS vs IN

### IN

Good when comparing a value against a set.

```sql
SELECT *
FROM Employees
WHERE department_id IN (
    SELECT department_id
    FROM Departments
    WHERE location = 'Mumbai'
);
```

### EXISTS

Good when checking whether a related row exists.

```sql
SELECT *
FROM Departments d
WHERE EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.department_id = d.department_id
);
```

Don't claim one is universally faster. The optimizer, data distribution, indexes, and database engine matter.

---

# 32. Find Employees Who Work in Mumbai

## Solution 1 — JOIN

```sql
SELECT
    e.employee_name
FROM Employees e
JOIN Departments d
    ON e.department_id = d.department_id
WHERE d.location = 'Mumbai';
```

## Solution 2 — IN

```sql
SELECT employee_name
FROM Employees
WHERE department_id IN (
    SELECT department_id
    FROM Departments
    WHERE location = 'Mumbai'
);
```

## Solution 3 — EXISTS

```sql
SELECT e.employee_name
FROM Employees e
WHERE EXISTS (
    SELECT 1
    FROM Departments d
    WHERE d.department_id = e.department_id
      AND d.location = 'Mumbai'
);
```

### Interview choice

The JOIN is usually the most immediately readable.

---

# 33. Find Managers and Number of Direct Reports

```sql
SELECT
    m.employee_id,
    m.employee_name,
    COUNT(e.employee_id) AS direct_reports
FROM Employees m
LEFT JOIN Employees e
    ON e.manager_id = m.employee_id
GROUP BY
    m.employee_id,
    m.employee_name
ORDER BY direct_reports DESC;
```

### Why LEFT JOIN?

Managers with zero direct reports should still be eligible to appear.

---

# 34. Find the Department With the Highest Average Salary

## Solution 1 — ORDER BY

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM Employees
GROUP BY department_id
ORDER BY avg_salary DESC
FETCH FIRST 1 ROW ONLY;
```

## Solution 2 — RANK

```sql
SELECT
    department_id,
    avg_salary
FROM (
    SELECT
        department_id,
        AVG(salary) AS avg_salary,
        RANK() OVER (
            ORDER BY AVG(salary) DESC
        ) AS rnk
    FROM Employees
    GROUP BY department_id
) x
WHERE rnk = 1;
```

### Difference

The first may return one row.

The second can return all tied departments.

---

# 35. Find Employees With the Same Salary

```sql
SELECT
    e.employee_name,
    e.salary
FROM Employees e
JOIN (
    SELECT salary
    FROM Employees
    GROUP BY salary
    HAVING COUNT(*) > 1
) x
    ON e.salary = x.salary
ORDER BY e.salary DESC;
```

Expected duplicate salary:

```text
95000
```

Employees:

```text
David
Mia
```

---

# 36. Find Employees Hired Before Their Manager

## Solution — SELF JOIN

```sql
SELECT
    e.employee_name,
    e.hire_date,
    m.employee_name AS manager_name,
    m.hire_date AS manager_hire_date
FROM Employees e
JOIN Employees m
    ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;
```

This is another useful SELF JOIN interview scenario.

---

# 37. Find the First Employee Hired in Each Department

## Solution — ROW_NUMBER

```sql
SELECT
    employee_id,
    employee_name,
    department_id,
    hire_date
FROM (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY hire_date
        ) AS rn
    FROM Employees e
) x
WHERE rn = 1;
```

Alternative using `MIN()`:

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.hire_date
FROM Employees e
JOIN (
    SELECT
        department_id,
        MIN(hire_date) AS first_hire_date
    FROM Employees
    GROUP BY department_id
) x
    ON e.department_id = x.department_id
   AND e.hire_date = x.first_hire_date;
```

### Difference

`ROW_NUMBER()` provides more flexibility for additional ranking logic.

The `MIN()` approach is simple when only the earliest date matters.

---

# 38. Find Employees Who Have Made More Than One Sale

```sql
SELECT
    e.employee_id,
    e.employee_name,
    COUNT(s.sale_id) AS sale_count
FROM Employees e
JOIN Sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.employee_name
HAVING COUNT(s.sale_id) > 1;
```

Expected:

| employee | sale_count |
|---|---:|
| Frank | 3 |
| Grace | 2 |

---

# 39. Find the Top-Selling Employee in Each Department

This combines JOIN + aggregation + window function.

```sql
WITH EmployeeSales AS (
    SELECT
        e.employee_id,
        e.employee_name,
        e.department_id,
        COALESCE(SUM(s.amount), 0) AS total_sales
    FROM Employees e
    LEFT JOIN Sales s
        ON e.employee_id = s.employee_id
    GROUP BY
        e.employee_id,
        e.employee_name,
        e.department_id
),
Ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY total_sales DESC
        ) AS rnk
    FROM EmployeeSales
)
SELECT *
FROM Ranked
WHERE rnk = 1;
```

### Interview value

This tests whether you can combine:

```text
JOIN
+
GROUP BY
+
CTE
+
Window Function
```

---

# 40. Find Sales Greater Than the Average Sale

## Solution 1 — Subquery

```sql
SELECT *
FROM Sales
WHERE amount > (
    SELECT AVG(amount)
    FROM Sales
);
```

## Solution 2 — Window Function

```sql
SELECT *
FROM (
    SELECT
        s.*,
        AVG(amount) OVER () AS avg_sale
    FROM Sales s
) x
WHERE amount > avg_sale;
```

---

# 41. Find Each Employee's Percentage of Total Sales

```sql
SELECT
    employee_id,
    SUM(amount) AS employee_sales,
    ROUND(
        100.0 * SUM(amount) / SUM(SUM(amount)) OVER (),
        2
    ) AS percentage_of_total
FROM Sales
GROUP BY employee_id;
```

This is a very good advanced interview question because it combines:

- `GROUP BY`
- `SUM`
- Window function
- Arithmetic

---

# 42. Find the Highest Salary Without Using MAX()

A common interview challenge.

## Solution 1 — ORDER BY

```sql
SELECT salary
FROM Employees
ORDER BY salary DESC
FETCH FIRST 1 ROW ONLY;
```

## Solution 2 — NOT EXISTS

```sql
SELECT salary
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM Employees e2
    WHERE e2.salary > e.salary
);
```

The second approach demonstrates relational reasoning:

> Return an employee for whom no employee has a higher salary.

---

# 43. Find the Nth Highest Salary

For example, third highest distinct salary:

```sql
SELECT salary
FROM (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees
) x
WHERE rnk = 3;
```

### Generic pattern

```sql
DENSE_RANK() OVER (ORDER BY salary DESC)
```

then filter:

```sql
WHERE rnk = N
```

This is one of the most useful interview templates to memorize.

---

# 44. SQL Query Logical Processing Order

A very common interview question.

Conceptually:

```text
FROM
JOIN
WHERE
GROUP BY
HAVING
SELECT
DISTINCT
ORDER BY
LIMIT / OFFSET
```

Example:

```sql
SELECT DISTINCT department_id
FROM Employees
WHERE salary > 70000
ORDER BY department_id;
```

Even though `SELECT` appears first in the written query, logically the database determines the source rows before producing the selected result.

### Memory Trick

> **F-W-G-H-S-D-O-L**

Think:

**From → Where → Group → Having → Select → Distinct → Order → Limit**

---

# 45. Why Can't We Use a SELECT Alias in WHERE?

For example:

```sql
SELECT
    salary * 12 AS annual_salary
FROM Employees
WHERE annual_salary > 1000000;
```

This generally doesn't work because the alias is defined in the SELECT phase, while WHERE is logically processed earlier.

Use:

```sql
SELECT *
FROM (
    SELECT
        employee_name,
        salary * 12 AS annual_salary
    FROM Employees
) x
WHERE annual_salary > 1000000;
```

Or a CTE:

```sql
WITH EmployeeSalary AS (
    SELECT
        employee_name,
        salary * 12 AS annual_salary
    FROM Employees
)
SELECT *
FROM EmployeeSalary
WHERE annual_salary > 1000000;
```

---

# 46. SQL Performance: Common Interview Questions

## Why is SELECT * discouraged?

Instead of:

```sql
SELECT *
FROM Employees;
```

prefer:

```sql
SELECT
    employee_id,
    employee_name,
    salary
FROM Employees;
```

Potential benefits:

- Less data transferred.
- Less memory.
- Clearer intent.
- Can sometimes enable more efficient plans.
- Reduces accidental dependency on schema changes.

---

# 47. Why Can JOINs Create Duplicate Rows?

Suppose:

```text
Employees = 14 rows
Sales = multiple rows per employee
```

If you join:

```sql
SELECT *
FROM Employees e
JOIN Sales s
    ON e.employee_id = s.employee_id;
```

Frank appears three times because Frank has three sales.

That's not necessarily a SQL error.

It reflects a:

```text
1 Employee : Many Sales
```

relationship.

### Interview Tip

Before joining, ask:

> "What is the grain of each table?"

This is one of the most valuable SQL interview habits.

---

# 48. Grain of a Table

"Grain" means:

> What does one row represent?

Examples:

```text
Employees
1 row = 1 employee

Departments
1 row = 1 department

Sales
1 row = 1 sale
```

If you understand the grain, many SQL mistakes become obvious.

---

# 49. Common SQL Mistake: Accidental Multiplication

Suppose you need employee totals.

Bad approach:

```sql
SELECT
    e.employee_name,
    SUM(s.amount)
FROM Employees e
JOIN Sales s
    ON e.employee_id = s.employee_id
JOIN Departments d
    ON e.department_id = d.department_id
GROUP BY e.employee_name;
```

This particular query is fine because Departments has one row per department.

But if the second joined table contained multiple rows per employee, sales could be multiplied.

### Best practice

Aggregate one-to-many data before joining when appropriate:

```sql
WITH SalesByEmployee AS (
    SELECT
        employee_id,
        SUM(amount) AS total_sales
    FROM Sales
    GROUP BY employee_id
)
SELECT
    e.employee_name,
    COALESCE(s.total_sales, 0)
FROM Employees e
LEFT JOIN SalesByEmployee s
    ON e.employee_id = s.employee_id;
```

---

# 50. SQL Interview Simulation

Now imagine the interviewer asks the following questions.

---

## Interview Question 1

### Interviewer

> Find the second-highest salary.

### Strong answer

```sql
SELECT employee_id, employee_name, salary
FROM (
    SELECT
        employee_id,
        employee_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees
) x
WHERE rnk = 2;
```

### Explain

"I used `DENSE_RANK()` because the question can involve duplicate salaries. This returns the second-highest distinct salary and all employees tied at that salary."

---

# Interview Question 2

### Interviewer

> Find employees earning more than their manager.

### Strong answer

```sql
SELECT
    e.employee_name,
    e.salary,
    m.employee_name AS manager_name,
    m.salary AS manager_salary
FROM Employees e
JOIN Employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

### Explain

"I use a self join because employees and managers are stored in the same table. The employee's manager_id points to another employee's employee_id."

---

# Interview Question 3

### Interviewer

> Find the highest-paid employee in each department.

### Strong answer

```sql
SELECT *
FROM (
    SELECT
        e.*,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees e
) x
WHERE rnk = 1;
```

### Explain

"I partition by department and rank employees by salary descending. `RANK()` also handles ties."

---

# Interview Question 4

### Interviewer

> Find departments whose average salary is greater than 80,000.

### Answer

```sql
SELECT
    department_id,
    AVG(salary) AS avg_salary
FROM Employees
GROUP BY department_id
HAVING AVG(salary) > 80000;
```

### Key point

Use:

```sql
HAVING
```

not:

```sql
WHERE
```

because the condition is on an aggregate result.

---

# Interview Question 5

### Interviewer

> Find employees who don't have any sales.

### Answer

```sql
SELECT
    e.employee_id,
    e.employee_name
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales s
    WHERE s.employee_id = e.employee_id
);
```

Alternative:

```sql
SELECT
    e.employee_id,
    e.employee_name
FROM Employees e
LEFT JOIN Sales s
    ON e.employee_id = s.employee_id
WHERE s.sale_id IS NULL;
```

---

# Interview Question 6

### Interviewer

> Find the top 2 employees by salary in each department.

### Answer

```sql
SELECT *
FROM (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees e
) x
WHERE rnk <= 2;
```

---

# Interview Question 7

### Interviewer

> Find each employee's running sales total.

### Answer

```sql
SELECT
    employee_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY employee_id
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM Sales;
```

---

# Interview Question 8

### Interviewer

> How would you optimize a slow query?

### Strong answer

"I would first inspect the execution plan rather than guessing. Then I would check indexes, join conditions, cardinality, filtering, unnecessary columns, sorting, aggregation, and whether functions or implicit conversions are preventing efficient access. I'd compare the plan before and after the change and measure the result."

This is much stronger than simply saying:

> "Add an index."

---

# Interview Question 9

### Interviewer

> Explain DELETE, TRUNCATE and DROP.

### Strong answer

"DELETE removes rows and supports a WHERE clause. TRUNCATE removes all rows while keeping the table structure, subject to database-specific transactional and trigger behavior. DROP removes the table object itself."

---

# Interview Question 10

### Interviewer

> What happens if you use INNER JOIN instead of LEFT JOIN?

### Strong answer

"An INNER JOIN removes rows from the result when there is no match on the other side. A LEFT JOIN preserves every row from the left table and supplies NULLs for missing matches."

---

# 51. Most Important SQL Patterns to Memorize

## Pattern 1 — Above Average

```sql
WHERE salary > (
    SELECT AVG(salary)
    FROM Employees
)
```

---

## Pattern 2 — Highest Per Group

```sql
RANK() OVER (
    PARTITION BY department_id
    ORDER BY salary DESC
)
```

---

## Pattern 3 — Top N Per Group

```sql
ROW_NUMBER() OVER (
    PARTITION BY department_id
    ORDER BY salary DESC
)
```

or:

```sql
DENSE_RANK() OVER (
    PARTITION BY department_id
    ORDER BY salary DESC
)
```

---

## Pattern 4 — Employee vs Manager

```sql
FROM Employees e
JOIN Employees m
    ON e.manager_id = m.employee_id
```

---

## Pattern 5 — No Matching Records

```sql
WHERE NOT EXISTS (...)
```

or:

```sql
LEFT JOIN ...
WHERE right_table.id IS NULL
```

---

## Pattern 6 — Group Filter

```sql
GROUP BY ...
HAVING COUNT(*) > ...
```

---

## Pattern 7 — Running Total

```sql
SUM(amount) OVER (
    PARTITION BY employee_id
    ORDER BY sale_date
)
```

---

## Pattern 8 — Previous Row

```sql
LAG(column) OVER (
    PARTITION BY ...
    ORDER BY ...
)
```

---

## Pattern 9 — Next Row

```sql
LEAD(column) OVER (
    PARTITION BY ...
    ORDER BY ...
)
```

---

## Pattern 10 — NULL Replacement

```sql
COALESCE(column, default_value)
```

---

# 52. Memory Tricks

## JOINs

Think:

```text
INNER = intersection
LEFT  = keep left
RIGHT = keep right
FULL  = keep both
SELF  = same table twice
CROSS = every combination
```

---

## Aggregation

Think:

```text
WHERE  → filter rows
GROUP  → create groups
HAVING → filter groups
```

---

## Ranking

Remember:

```text
ROW_NUMBER → unique numbering
RANK       → gaps after ties
DENSE_RANK → no gaps after ties
```

---

## Window Functions

Think:

> "Calculate something across related rows without collapsing them."

---

## EXISTS

Think:

> "Does a matching row exist?"

---

## NOT EXISTS

Think:

> "Does no matching row exist?"

---

## COALESCE

Think:

> "Fallback value."

---

# 53. Common Interview Traps

## Trap 1 — Using = NULL

Wrong:

```sql
WHERE manager_id = NULL
```

Correct:

```sql
WHERE manager_id IS NULL
```

---

## Trap 2 — WHERE with Aggregate

Wrong:

```sql
WHERE COUNT(*) > 2
```

Correct:

```sql
HAVING COUNT(*) > 2
```

---

## Trap 3 — Forgetting Ties

If asked for the highest salary per department, decide whether ties should be returned.

Use:

```sql
RANK()
```

or:

```sql
DENSE_RANK()
```

when ties matter.

---

## Trap 4 — Accidental INNER JOIN

If the requirement says:

> "Include employees with zero sales"

don't use:

```sql
INNER JOIN Sales
```

Use:

```sql
LEFT JOIN Sales
```

---

## Trap 5 — Using DISTINCT to Hide a Bad JOIN

If a query unexpectedly returns duplicates, don't immediately write:

```sql
SELECT DISTINCT ...
```

First determine why the join is multiplying rows.

---

## Trap 6 — NOT IN + NULL

Be cautious with:

```sql
NOT IN
```

when the subquery may return NULL.

Consider:

```sql
NOT EXISTS
```

---

## Trap 7 — SELECT *

Avoid it in production queries when you know the required columns.

---

# 54. SQL Coding Interview Strategy

When given a SQL problem, follow this process.

## Step 1 — Identify the output

Ask:

> What columns do I need?

---

## Step 2 — Identify the tables

Ask:

> Where does each column come from?

---

## Step 3 — Determine the grain

Ask:

> What does one row represent?

---

## Step 4 — Identify relationships

Look for:

```text
employee_id
department_id
manager_id
```

---

## Step 5 — Decide whether aggregation is required

If the question contains:

```text
average
maximum
minimum
total
count
number of
```

consider:

```sql
GROUP BY
```

---

## Step 6 — Decide whether HAVING is needed

If filtering an aggregate:

```sql
HAVING
```

---

## Step 7 — Check for ranking

If the question says:

```text
top N
highest per department
second highest
Nth highest
```

consider:

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
```

---

## Step 8 — Check for missing records

If the question says:

```text
without
never
no
missing
doesn't have
```

consider:

```sql
NOT EXISTS
```

or:

```sql
LEFT JOIN ... IS NULL
```

---

## Step 9 — Check NULL behavior

Ask:

> Could this column contain NULL?

---

## Step 10 — Test edge cases

Think about:

- Duplicate values
- NULLs
- Empty tables
- Ties
- Employees without managers
- Departments without employees
- Employees without sales
- Multiple sales per employee

---

# 55. Advanced Interview Topics Checklist

Before an SQL interview, make sure you can explain:

### Fundamentals

- [ ] SELECT
- [ ] WHERE
- [ ] ORDER BY
- [ ] DISTINCT
- [ ] GROUP BY
- [ ] HAVING
- [ ] CASE
- [ ] COALESCE

### Joins

- [ ] INNER JOIN
- [ ] LEFT JOIN
- [ ] RIGHT JOIN
- [ ] FULL OUTER JOIN
- [ ] CROSS JOIN
- [ ] SELF JOIN

### Subqueries

- [ ] Scalar subquery
- [ ] Correlated subquery
- [ ] IN
- [ ] EXISTS
- [ ] NOT EXISTS

### Advanced SQL

- [ ] CTE
- [ ] Recursive CTE
- [ ] Window functions
- [ ] ROW_NUMBER
- [ ] RANK
- [ ] DENSE_RANK
- [ ] LAG
- [ ] LEAD

### Database Concepts

- [ ] Primary keys
- [ ] Foreign keys
- [ ] Unique constraints
- [ ] Normalization
- [ ] Views
- [ ] Indexes
- [ ] Transactions
- [ ] ACID
- [ ] Isolation levels
- [ ] Execution plans

---

# 56. 20 Rapid-Fire SQL Interview Questions

## 1. What is SQL?

A language for querying and managing relational data.

## 2. Primary key?

Uniquely identifies rows.

## 3. Foreign key?

References a key in another table.

## 4. WHERE vs HAVING?

WHERE filters rows; HAVING filters groups.

## 5. DELETE vs TRUNCATE?

DELETE removes selected rows; TRUNCATE empties the table, with behavior varying by DBMS.

## 6. DROP?

Removes the database object.

## 7. INNER vs LEFT JOIN?

INNER keeps matches; LEFT keeps all left-side rows.

## 8. UNION vs UNION ALL?

UNION removes duplicates; UNION ALL doesn't.

## 9. What is a CTE?

A named temporary result used within a statement.

## 10. What is a window function?

Calculates across related rows without collapsing the result set.

## 11. RANK vs DENSE_RANK?

RANK has gaps after ties; DENSE_RANK doesn't.

## 12. What is normalization?

Organizing data to reduce redundancy and anomalies.

## 13. What is an index?

A structure that can speed up data access.

## 14. Why not index every column?

Indexes consume storage and can increase write/maintenance costs.

## 15. What is a transaction?

A logical unit of database work.

## 16. What is ACID?

Atomicity, Consistency, Isolation, Durability.

## 17. What is a SELF JOIN?

Joining a table to itself.

## 18. What is NULL?

Unknown/missing/not-applicable value.

## 19. How do you find duplicates?

```sql
GROUP BY ...
HAVING COUNT(*) > 1
```

## 20. How do you find top N per group?

Usually:

```sql
ROW_NUMBER()
RANK()
DENSE_RANK()
```

with:

```sql
PARTITION BY
```

---

# 57. Final SQL Cheat Sheet

```text
FILTER ROWS
WHERE

FILTER GROUPS
HAVING

GROUP DATA
GROUP BY

SORT
ORDER BY

REMOVE DUPLICATES
DISTINCT

COMBINE TABLES
JOIN

KEEP ALL LEFT ROWS
LEFT JOIN

CHECK EXISTENCE
EXISTS

CHECK NON-EXISTENCE
NOT EXISTS

REPLACE NULL
COALESCE

CONDITIONAL LOGIC
CASE

SECOND/NTH DISTINCT VALUE
DENSE_RANK()

TOP N WITH UNIQUE ROW POSITIONS
ROW_NUMBER()

TOP N WITH TIES
RANK() / DENSE_RANK()

PREVIOUS ROW
LAG()

NEXT ROW
LEAD()

RUNNING TOTAL
SUM() OVER (ORDER BY ...)

GROUP STATISTIC WITHOUT COLLAPSING ROWS
AVG() OVER (...)

REUSABLE QUERY BLOCK
CTE

REMOVE SELECTED ROWS
DELETE

EMPTY TABLE
TRUNCATE

REMOVE TABLE
DROP

MAKE CHANGES PERMANENT
COMMIT

UNDO TRANSACTION
ROLLBACK

CHECK PERFORMANCE
EXPLAIN / EXPLAIN ANALYZE
```

---

# 58. The 10 SQL Queries You Should Be Able to Write From Memory

## 1. Employees above company average

```sql
SELECT *
FROM Employees
WHERE salary > (
    SELECT AVG(salary)
    FROM Employees
);
```

## 2. Second-highest salary

```sql
SELECT *
FROM (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees e
) x
WHERE rnk = 2;
```

## 3. Employees earning more than managers

```sql
SELECT e.employee_name
FROM Employees e
JOIN Employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

## 4. Highest salary per department

```sql
SELECT *
FROM (
    SELECT
        e.*,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees e
) x
WHERE rnk = 1;
```

## 5. Departments with more than two employees

```sql
SELECT department_id
FROM Employees
GROUP BY department_id
HAVING COUNT(*) > 2;
```

## 6. Employees with no sales

```sql
SELECT e.*
FROM Employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM Sales s
    WHERE s.employee_id = e.employee_id
);
```

## 7. Total sales by employee

```sql
SELECT
    employee_id,
    SUM(amount) AS total_sales
FROM Sales
GROUP BY employee_id;
```

## 8. Running sales total

```sql
SELECT
    employee_id,
    sale_date,
    amount,
    SUM(amount) OVER (
        PARTITION BY employee_id
        ORDER BY sale_date
    ) AS running_total
FROM Sales;
```

## 9. Duplicate salaries

```sql
SELECT salary, COUNT(*)
FROM Employees
GROUP BY salary
HAVING COUNT(*) > 1;
```

## 10. Top 2 salaries per department

```sql
SELECT *
FROM (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM Employees e
) x
WHERE rnk <= 2;
```

---

# 59. Final Interview Advice

When solving SQL problems, don't focus only on producing a query.

Explain your thought process:

1. **What is the required output?**
2. **What is the grain of each table?**
3. **Which tables need to be joined?**
4. **Could the join multiply rows?**
5. **Do I need aggregation?**
6. **Do I need WHERE or HAVING?**
7. **Could NULL affect the result?**
8. **Are duplicates/ties important?**
9. **Would a window function simplify the problem?**
10. **How would this query perform on millions of rows?**

A strong SQL candidate doesn't just know syntax.

They understand:

```text
DATA
  ↓
RELATIONSHIPS
  ↓
FILTERING
  ↓
AGGREGATION
  ↓
ANALYSIS
  ↓
PERFORMANCE
  ↓
CORRECTNESS
```

## The most important rule

**Before writing SQL, understand exactly what one row in the desired result represents.**

If you master:

```text
JOINs
GROUP BY + HAVING
Subqueries
CTEs
Window Functions
NULL handling
Top-N problems
Self JOINs
EXISTS / NOT EXISTS
Indexes
Transactions
```

you will be prepared for a large portion of SQL technical interviews.