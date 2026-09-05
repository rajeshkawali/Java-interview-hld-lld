# SQL interview-question

---

> **Dataset used:** `companies`, `departments`, `jobs`, `addresses`, `employees`, `employee_addresses`, `employee_salary_history`, `projects`, `employee_projects`, `sales`.

I have deliberately written the queries in an **interview-friendly style**: first give the query, then explain what it does and what an interviewer may ask as a follow-up.

---

# 50 Most Asked SQL Interview Queries & Answers

## Quick Table of Contents

| #  | Interview Problem                             | Main Concept        |
| -- | --------------------------------------------- | ------------------- |
| 1  | Display all employees                         | SELECT              |
| 2  | Employees earning > 80,000                    | WHERE               |
| 3  | Employees from a department                   | JOIN                |
| 4  | Sort employees by salary                      | ORDER BY            |
| 5  | Find distinct salaries                        | DISTINCT            |
| 6  | Highest salary                                | MAX                 |
| 7  | Second-highest salary                         | Subquery            |
| 8  | Nth-highest salary                            | DENSE_RANK          |
| 9  | Highest salary in each department             | GROUP BY            |
| 10 | Employee with highest salary                  | MAX/subquery        |
| 11 | Employees earning above company average       | Subquery            |
| 12 | Employees earning above department average    | Window              |
| 13 | Department average salary                     | GROUP BY            |
| 14 | Departments with > 3 employees                | HAVING              |
| 15 | Employees without manager                     | NULL                |
| 16 | Employees earning more than manager           | Self JOIN           |
| 17 | Employees with manager names                  | Self JOIN           |
| 18 | Employees without completed sales             | NOT EXISTS          |
| 19 | Employees without projects                    | NOT EXISTS          |
| 20 | Departments without employees                 | LEFT JOIN           |
| 21 | Find duplicate emails                         | GROUP BY            |
| 22 | Employees with same salary                    | GROUP BY            |
| 23 | Top 3 salaries                                | LIMIT               |
| 24 | Top 3 employees per department                | ROW_NUMBER          |
| 25 | Rank employees by salary                      | RANK                |
| 26 | Difference between RANK/DENSE_RANK/ROW_NUMBER | Window              |
| 27 | Salary percentage of department               | Window              |
| 28 | Running salary total                          | Window              |
| 29 | Previous employee salary                      | LAG                 |
| 30 | Next employee salary                          | LEAD                |
| 31 | Highest-paid employee per department          | Window              |
| 32 | Second-highest salary per department          | DENSE_RANK          |
| 33 | Top salesperson per month                     | Window              |
| 34 | Monthly sales                                 | DATE_TRUNC          |
| 35 | Month-over-month sales growth                 | LAG                 |
| 36 | Running sales total                           | Window              |
| 37 | Top 2 salespeople per region                  | Window              |
| 38 | Employees with multiple projects              | HAVING              |
| 39 | Employees assigned to all projects?           | Relational logic    |
| 40 | Salary increased in history                   | Salary history      |
| 41 | Latest salary of each employee                | ROW_NUMBER          |
| 42 | Employees whose salary increased > 10%        | History             |
| 43 | Recursive employee hierarchy                  | Recursive CTE       |
| 44 | Employee count by company                     | JOIN/GROUP          |
| 45 | Department with highest average salary        | CTE                 |
| 46 | Employees hired in same year                  | DATE                |
| 47 | Employees hired before their manager          | Self JOIN           |
| 48 | Conditional salary classification             | CASE                |
| 49 | Find employees with no sales + no projects    | NOT EXISTS          |
| 50 | Complex employee performance report           | CTE + JOIN + Window |

---

# 1. Display All Employees

### Question

**Write a query to display all employees.**

```sql
SELECT *
FROM employees;
```

### Explanation

`SELECT *` returns every column and every row.

### Interview tip

In production code, avoid `SELECT *` when you only need specific columns.

Better:

```sql
SELECT
    employee_id,
    employee_code,
    first_name,
    last_name,
    salary,
    department_id
FROM employees;
```

---

# 2. Find Employees Earning More Than 80,000

### Question

**Find employees whose salary is greater than 80,000.**

```sql
SELECT
    employee_id,
    employee_code,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > 80000
ORDER BY salary DESC;
```

### Explanation

`WHERE` filters rows **before** grouping and aggregation.

### Expected idea

Employees such as:

```text
David
Mia
Alice
Carol
...
```

depending on the exact salary values in the seed data.

---

# 3. Find Employees With Their Department Names

### Question

**Display employee name and department name.**

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
ORDER BY e.employee_id;
```

### Explanation

This is an **INNER JOIN**.

Only employees having a matching department are returned.

### Interview question

> What happens if an employee has an invalid/missing department?

With `INNER JOIN`, that employee disappears from the result.

For all employees:

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
LEFT JOIN departments d
    ON d.department_id = e.department_id;
```

---

# 4. Sort Employees by Highest Salary

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC;
```

### Ascending

```sql
ORDER BY salary ASC;
```

### Interview memory trick

```text
DESC = Highest → Lowest
ASC  = Lowest → Highest
```

---

# 5. Find Distinct Salaries

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC;
```

### Explanation

`DISTINCT` removes duplicate values.

For example:

```text
95000
95000
90000
80000
80000
```

becomes:

```text
95000
90000
80000
```

This distinction is important in **second-highest salary** questions.

---

# 6. Find the Highest Salary

```sql
SELECT MAX(salary) AS highest_salary
FROM employees;
```

### Expected result

```text
highest_salary
--------------
highest salary in dataset
```

### Find the employee too

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);
```

### Why this version is better?

If two employees have the highest salary, it returns **both**.

---

# 7. Find the Second-Highest Salary

This is one of the most repeatedly asked SQL interview problems.

## Method 1 — Subquery

```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

### How it works

Inner query:

```sql
SELECT MAX(salary)
FROM employees;
```

gets the highest salary.

Outer query finds the largest salary below it.

---

## Method 2 — DENSE_RANK

```sql
WITH ranked AS (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT DISTINCT salary
FROM ranked
WHERE salary_rank = 2;
```

### Why I prefer this in interviews

It naturally handles duplicate salaries and easily extends to:

```text
3rd highest
4th highest
Nth highest
```

---

# 8. Find the Nth-Highest Salary

Suppose the interviewer asks:

> Find the 3rd highest salary.

```sql
WITH ranked AS (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT DISTINCT salary
FROM ranked
WHERE salary_rank = 3;
```

For 5th highest:

```sql
WHERE salary_rank = 5;
```

### Memory trick

```text
DENSE_RANK = distinct salary position
```

---

# 9. Find Highest Salary in Each Department

```sql
SELECT
    department_id,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department_id
ORDER BY department_id;
```

### Explanation

`GROUP BY department_id` creates one group for each department.

`MAX(salary)` finds the highest salary inside each group.

---

# 10. Find Employee(s) With Highest Salary

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(salary)
    FROM employees
);
```

### Important

Do **not** write:

```sql
WHERE salary = MAX(salary)
```

because aggregate functions cannot normally be used directly in `WHERE`.

---

# 11. Employees Earning More Than Company Average

### Question

**Find employees whose salary is greater than the overall company average.**

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary DESC;
```

### Pattern

```text
Calculate average
       ↓
Compare every employee
       ↓
Return employees above average
```

---

# 12. Employees Earning More Than Their Department Average

This is another very common interview pattern.

### Best interview answer — Window Function

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary,
    dept_avg_salary
FROM (
    SELECT
        e.*,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS dept_avg_salary
    FROM employees e
) x
WHERE salary > dept_avg_salary
ORDER BY department_id, salary DESC;
```

### Explanation

```sql
PARTITION BY department_id
```

calculates a separate average for each department.

Unlike `GROUP BY`, a window function **does not collapse the employee rows**.

---

# 13. Find Average Salary by Department

```sql
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
ORDER BY average_salary DESC;
```

### Include department name

```sql
SELECT
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM departments d
JOIN employees e
    ON e.department_id = d.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY average_salary DESC;
```

---

# 14. Departments Having More Than 3 Employees

```sql
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 3;
```

### Critical interview concept

`WHERE` filters **rows**.

`HAVING` filters **groups**.

Wrong:

```sql
WHERE COUNT(*) > 3
```

Correct:

```sql
HAVING COUNT(*) > 3
```

### Memory trick

```text
WHERE  → before GROUP BY
HAVING → after GROUP BY
```

---

# 15. Find Employees Without a Manager

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    manager_id
FROM employees
WHERE manager_id IS NULL;
```

### Important NULL rule

Never write:

```sql
WHERE manager_id = NULL;
```

Use:

```sql
WHERE manager_id IS NULL;
```

And:

```sql
WHERE manager_id IS NOT NULL;
```

---

# 16. Find Employees Earning More Than Their Manager

This is a classic **self-join** question.

```sql
SELECT
    e.employee_id,
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

### Explanation

The same table is used twice:

```text
employees e = employee
employees m = manager
```

This is called a **self join**.

### Interview follow-up

> Why not use LEFT JOIN?

You can, but employees without managers don't have a manager salary to compare against. `INNER JOIN` is appropriate when a manager is required for the comparison.

---

# 17. Display Employee and Manager Names

```sql
SELECT
    e.employee_id,
    e.first_name AS employee_name,
    m.first_name AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id
ORDER BY e.employee_id;
```

### Why LEFT JOIN?

We want employees who have **no manager** too.

---

# 18. Find Employees With No Completed Sales

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
      AND s.status = 'COMPLETED'
);
```

### Why `NOT EXISTS`?

It asks:

> Does a matching completed sale exist?

If no → employee is returned.

This is often preferable to `NOT IN`, especially when NULLs could appear in the subquery.

---

# 19. Find Employees Not Assigned to Any Project

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM employee_projects ep
    WHERE ep.employee_id = e.employee_id
);
```

### Alternative LEFT JOIN

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
WHERE ep.employee_id IS NULL;
```

### Interview answer

Both are valid.

```text
NOT EXISTS → excellent for existence logic
LEFT JOIN  → intuitive for "find missing rows"
```

---

# 20. Find Departments With No Employees

Our dataset intentionally contains an empty department, which makes this an excellent interview example.

```sql
SELECT
    d.department_id,
    d.department_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;
```

### Important

Start from `departments`, not employees.

Why?

Because we want to preserve departments even when no employee exists.

---

# 21. Find Duplicate Employee Emails

```sql
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

### Pattern

```text
GROUP BY duplicate column
        ↓
COUNT(*)
        ↓
HAVING COUNT(*) > 1
```

This is one of the standard duplicate-detection interview patterns.

---

# 22. Find Employees Who Have the Same Salary

```sql
SELECT
    salary,
    COUNT(*) AS employee_count
FROM employees
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;
```

### To display the actual employees

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
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

# 23. Find Top 3 Salaries

```sql
SELECT DISTINCT salary
FROM employees
ORDER BY salary DESC
LIMIT 3;
```

### Why DISTINCT?

Without it, duplicate salaries may consume the three positions.

For example:

```text
95000
95000
90000
90000
85000
```

With `DISTINCT`:

```text
95000
90000
85000
```

---

# 24. Find Top 3 Employees in Each Department

This is one of the most important **Top-N-per-group** interview questions.

```sql
WITH ranked AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.department_id,
        e.salary,
        ROW_NUMBER() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC
        ) AS rn
    FROM employees e
)
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM ranked
WHERE rn <= 3
ORDER BY department_id, salary DESC;
```

### Interview memory trick

```text
Top N per group
       ↓
PARTITION BY group
       ↓
ORDER BY value DESC
       ↓
ROW_NUMBER/RANK/DENSE_RANK
       ↓
WHERE rank <= N
```

---

# 25. Rank Employees by Salary

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees
ORDER BY salary_rank;
```

### Example

If salaries are:

```text
100000
100000
90000
80000
```

`RANK()` produces:

```text
100000 → 1
100000 → 1
90000  → 3
80000  → 4
```

---

# 26. ROW_NUMBER vs RANK vs DENSE_RANK

This is frequently tested because interviewers intentionally introduce salary ties.

```sql
SELECT
    employee_id,
    first_name,
    salary,

    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_num,

    RANK() OVER (
        ORDER BY salary DESC
    ) AS rank_num,

    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS dense_rank_num

FROM employees
ORDER BY salary DESC;
```

### Remember

Suppose:

```text
Salary
100
100
90
80
```

Results:

```text
ROW_NUMBER   RANK   DENSE_RANK
1            1      1
2            1      1
3            3      2
4            4      3
```

### Memory trick

```text
ROW_NUMBER → No ties
RANK       → Ties + gaps
DENSE_RANK → Ties + no gaps
```

---

# 27. Salary as Percentage of Department Payroll

This is a very good intermediate/advanced interview question.

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary,
    ROUND(
        100.0 * e.salary /
        SUM(e.salary) OVER (
            PARTITION BY e.department_id
        ),
        2
    ) AS salary_percentage
FROM employees e
ORDER BY e.department_id, e.salary DESC;
```

### Example idea

If department payroll is:

```text
300000
```

and employee salary is:

```text
90000
```

then:

```text
90000 / 300000 * 100 = 30%
```

---

# 28. Calculate Running Salary Total

```sql
SELECT
    employee_id,
    first_name,
    hire_date,
    salary,

    SUM(salary) OVER (
        ORDER BY hire_date, employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_salary_total

FROM employees
ORDER BY hire_date, employee_id;
```

### Important

`ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`

means:

```text
Start from first row
+
current row
```

This pattern is widely used for running totals.

---

# 29. Find Previous Employee Salary

Use `LAG()`.

```sql
SELECT
    employee_id,
    first_name,
    salary,

    LAG(salary) OVER (
        ORDER BY hire_date, employee_id
    ) AS previous_salary

FROM employees
ORDER BY hire_date, employee_id;
```

### Use cases

`LAG()` is useful for:

* previous salary
* previous transaction
* previous month's revenue
* previous order
* change detection

---

# 30. Find Next Employee Salary

Use `LEAD()`.

```sql
SELECT
    employee_id,
    first_name,
    salary,

    LEAD(salary) OVER (
        ORDER BY hire_date, employee_id
    ) AS next_salary

FROM employees
ORDER BY hire_date, employee_id;
```

### Memory trick

```text
LAG  → look backward
LEAD → look forward
```

---

# 31. Highest-Paid Employee in Each Department

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
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM ranked
WHERE rnk = 1;
```

### Why `RANK()`?

If two employees tie for highest salary, both are returned.

If the interviewer says:

> Return exactly one employee per department.

Use:

```sql
ROW_NUMBER()
```

instead.

---

# 32. Second-Highest Salary in Each Department

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
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM ranked
WHERE salary_rank = 2
ORDER BY department_id;
```

### Why DENSE_RANK?

Because the interviewer usually means:

> second **distinct** salary.

This handles salary ties correctly.

---

# 33. Top Salesperson for Each Month

```sql
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS sales_month,
        employee_id,
        SUM(amount) AS total_sales
    FROM sales
    WHERE status = 'COMPLETED'
    GROUP BY
        DATE_TRUNC('month', sale_date),
        employee_id
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY sales_month
            ORDER BY total_sales DESC
        ) AS rnk
    FROM monthly_sales
)
SELECT
    sales_month,
    employee_id,
    total_sales
FROM ranked
WHERE rnk = 1
ORDER BY sales_month;
```

### Concepts tested

This single question tests:

```text
DATE_TRUNC
GROUP BY
SUM
CTE
RANK
PARTITION BY
```

Excellent interview question.

---

# 34. Calculate Monthly Sales

```sql
SELECT
    DATE_TRUNC('month', sale_date) AS sales_month,
    SUM(amount) AS total_sales
FROM sales
WHERE status = 'COMPLETED'
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY sales_month;
```

### Output concept

```text
sales_month    total_sales
------------   -----------
2026-01-01     ...
2026-02-01     ...
2026-03-01     ...
```

---

# 35. Calculate Month-over-Month Sales Growth

This is a classic `LAG()` problem.

```sql
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS sales_month,
        SUM(amount) AS total_sales
    FROM sales
    WHERE status = 'COMPLETED'
    GROUP BY DATE_TRUNC('month', sale_date)
),
comparison AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    ROUND(
        100.0 *
        (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0),
        2
    ) AS growth_percentage
FROM comparison
ORDER BY sales_month;
```

### Why `NULLIF`?

To prevent division by zero.

```sql
NULLIF(previous_month_sales, 0)
```

turns zero into NULL instead of causing a division-by-zero error.

---

# 36. Calculate Running Sales Total

```sql
SELECT
    sale_date,
    sale_id,
    amount,

    SUM(amount) OVER (
        ORDER BY sale_date, sale_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_sales

FROM sales
WHERE status = 'COMPLETED'
ORDER BY sale_date, sale_id;
```

### Interview follow-up

> What is the difference between GROUP BY and a window function?

`GROUP BY` reduces multiple rows into groups.

Window functions calculate across related rows **while retaining individual rows**.

---

# 37. Top 2 Salespeople in Each Region

```sql
WITH employee_region_sales AS (
    SELECT
        region,
        employee_id,
        SUM(amount) AS total_sales
    FROM sales
    WHERE status = 'COMPLETED'
    GROUP BY
        region,
        employee_id
),
ranked AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY total_sales DESC
        ) AS rnk
    FROM employee_region_sales
)
SELECT
    region,
    employee_id,
    total_sales
FROM ranked
WHERE rnk <= 2
ORDER BY region, total_sales DESC;
```

### Key pattern

```sql
PARTITION BY region
ORDER BY total_sales DESC
```

means:

> Rank salespeople independently inside each region.

---

# 38. Find Employees Assigned to More Than One Project

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
HAVING COUNT(ep.project_id) > 1
ORDER BY project_count DESC;
```

### Important distinction

```text
WHERE → filters rows
HAVING → filters aggregate result
```

---

# 39. Find Employees Assigned to Every Project in Their Department

This is a more advanced relational-logic question.

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM projects p
    WHERE p.department_id = e.department_id
      AND NOT EXISTS (
          SELECT 1
          FROM employee_projects ep
          WHERE ep.employee_id = e.employee_id
            AND ep.project_id = p.project_id
      )
);
```

### Read it in English

> Return employees for whom there does NOT EXIST a department project for which there does NOT EXIST an employee-project assignment.

This is called **double NOT EXISTS** logic.

---

# 40. Find Employees Whose Salary Increased

Using `employee_salary_history`:

```sql
SELECT DISTINCT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
JOIN employee_salary_history h
    ON h.employee_id = e.employee_id
WHERE h.new_salary > h.old_salary;
```

### Better: show the increase

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    h.old_salary,
    h.new_salary,
    h.new_salary - h.old_salary AS salary_increase
FROM employees e
JOIN employee_salary_history h
    ON h.employee_id = e.employee_id
WHERE h.new_salary > h.old_salary
ORDER BY salary_increase DESC;
```

---

# 41. Find the Latest Salary Record for Each Employee

Very common `ROW_NUMBER()` question.

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

### Memory trick

Whenever interviewer says:

> Latest record per employee/customer/order

Think:

```text
ROW_NUMBER()
+
PARTITION BY ID
+
ORDER BY date DESC
```

---

# 42. Employees Whose Salary Increased by More Than 10%

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    h.old_salary,
    h.new_salary,
    ROUND(
        100.0 * (h.new_salary - h.old_salary)
        / NULLIF(h.old_salary, 0),
        2
    ) AS increase_percentage
FROM employees e
JOIN employee_salary_history h
    ON h.employee_id = e.employee_id
WHERE h.new_salary > h.old_salary
  AND (
      100.0 * (h.new_salary - h.old_salary)
      / NULLIF(h.old_salary, 0)
  ) > 10
ORDER BY increase_percentage DESC;
```

### Interview concept

This tests:

* joins
* arithmetic
* percentage calculation
* NULLIF
* filtering calculated values

---

# 43. Display Employee Hierarchy Using Recursive CTE

This is an advanced SQL interview question.

```sql
WITH RECURSIVE employee_hierarchy AS (
    -- Top-level employees
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        0 AS hierarchy_level,
        e.first_name::TEXT AS hierarchy_path
    FROM employees e
    WHERE e.manager_id IS NULL

    UNION ALL

    -- Employees reporting to previous level
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        eh.hierarchy_level + 1,
        eh.hierarchy_path || ' -> ' || e.first_name
    FROM employees e
    JOIN employee_hierarchy eh
        ON e.manager_id = eh.employee_id
)
SELECT
    employee_id,
    first_name,
    last_name,
    manager_id,
    hierarchy_level,
    hierarchy_path
FROM employee_hierarchy
ORDER BY hierarchy_path;
```

### Example concept

```text
CEO
 ├── Manager A
 │    ├── Employee A
 │    └── Employee B
 └── Manager B
      └── Employee C
```

### Interview topics

This tests:

```text
WITH RECURSIVE
self join
hierarchical data
UNION ALL
```

---

# 44. Count Employees by Company

```sql
SELECT
    c.company_id,
    c.company_name,
    COUNT(e.employee_id) AS employee_count
FROM companies c
LEFT JOIN departments d
    ON d.company_id = c.company_id
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY
    c.company_id,
    c.company_name
ORDER BY employee_count DESC;
```

### Why LEFT JOIN?

We want companies with **zero employees** too.

If you use `INNER JOIN`, companies with no matching employees disappear.

---

# 45. Find the Department With the Highest Average Salary

### CTE solution

```sql
WITH department_salary AS (
    SELECT
        d.department_id,
        d.department_name,
        AVG(e.salary) AS avg_salary
    FROM departments d
    JOIN employees e
        ON e.department_id = d.department_id
    GROUP BY
        d.department_id,
        d.department_name
)
SELECT
    department_id,
    department_name,
    ROUND(avg_salary, 2) AS avg_salary
FROM department_salary
ORDER BY avg_salary DESC
LIMIT 1;
```

### Alternative using RANK

```sql
WITH department_salary AS (
    SELECT
        d.department_id,
        d.department_name,
        AVG(e.salary) AS avg_salary
    FROM departments d
    JOIN employees e
        ON e.department_id = d.department_id
    GROUP BY
        d.department_id,
        d.department_name
),
ranked AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY avg_salary DESC
        ) AS rnk
    FROM department_salary
)
SELECT *
FROM ranked
WHERE rnk = 1;
```

### Why is the second version useful?

If two departments tie for highest average salary, both are returned.

---

# 46. Find Employees Hired in the Same Year

```sql
SELECT
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    COUNT(*) AS employee_count
FROM employees
GROUP BY EXTRACT(YEAR FROM hire_date)
ORDER BY hire_year;
```

### Find employees hired in 2022

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    hire_date
FROM employees
WHERE hire_date >= DATE '2022-01-01'
  AND hire_date < DATE '2023-01-01'
ORDER BY hire_date;
```

### Production tip

Prefer a date range over:

```sql
WHERE EXTRACT(YEAR FROM hire_date) = 2022
```

when performance/index usage matters.

---

# 47. Find Employees Hired Before Their Manager

Another excellent self-join problem.

```sql
SELECT
    e.employee_id,
    e.first_name AS employee_name,
    e.hire_date AS employee_hire_date,
    m.first_name AS manager_name,
    m.hire_date AS manager_hire_date
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.hire_date < m.hire_date;
```

### Business interpretation

This identifies a potentially unusual hierarchy:

> Employee joined before their current manager.

This could be completely legitimate—for example, the manager was promoted later.

---

# 48. Classify Employees by Salary

Use `CASE`.

```sql
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'HIGH'
        WHEN salary >= 70000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS salary_category
FROM employees
ORDER BY salary DESC;
```

### Memory trick

```text
CASE
    WHEN condition THEN result
    WHEN condition THEN result
    ELSE result
END
```

---

# 49. Find Employees With Neither Completed Sales Nor Projects

This is a strong interview-level query.

```sql
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
      AND s.status = 'COMPLETED'
)
AND NOT EXISTS (
    SELECT 1
    FROM employee_projects ep
    WHERE ep.employee_id = e.employee_id
);
```

### English translation

Find employees where:

```text
NO completed sales
AND
NO project assignment
```

### Why `NOT EXISTS`?

It directly expresses the business requirement.

---

# 50. Build a Complete Employee Performance Report

This is the type of query I would practice for a **2–5 year SQL interview**, because it combines many concepts.

### Requirement

Return:

* employee
* department
* manager
* salary
* department average salary
* salary rank within department
* completed sales
* project count
* salary category
* whether employee earns above department average

```sql
WITH employee_sales AS (
    SELECT
        employee_id,
        SUM(amount) AS completed_sales
    FROM sales
    WHERE status = 'COMPLETED'
    GROUP BY employee_id
),

employee_projects_count AS (
    SELECT
        employee_id,
        COUNT(DISTINCT project_id) AS project_count
    FROM employee_projects
    GROUP BY employee_id
),

employee_metrics AS (
    SELECT
        e.employee_id,
        e.employee_code,
        e.first_name,
        e.last_name,
        e.department_id,
        e.manager_id,
        e.salary,

        AVG(e.salary) OVER (
            PARTITION BY e.department_id
        ) AS department_avg_salary,

        RANK() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC
        ) AS department_salary_rank

    FROM employees e
)

SELECT
    em.employee_id,
    em.employee_code,
    em.first_name,
    em.last_name,

    d.department_name,

    CONCAT(m.first_name, ' ', m.last_name)
        AS manager_name,

    em.salary,

    ROUND(em.department_avg_salary, 2)
        AS department_avg_salary,

    em.department_salary_rank,

    COALESCE(es.completed_sales, 0)
        AS completed_sales,

    COALESCE(ep.project_count, 0)
        AS project_count,

    CASE
        WHEN em.salary >= 100000 THEN 'HIGH'
        WHEN em.salary >= 70000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS salary_category,

    CASE
        WHEN em.salary > em.department_avg_salary
            THEN 'ABOVE AVERAGE'
        WHEN em.salary < em.department_avg_salary
            THEN 'BELOW AVERAGE'
        ELSE 'AVERAGE'
    END AS salary_vs_department

FROM employee_metrics em

JOIN departments d
    ON d.department_id = em.department_id

LEFT JOIN employees m
    ON m.employee_id = em.manager_id

LEFT JOIN employee_sales es
    ON es.employee_id = em.employee_id

LEFT JOIN employee_projects_count ep
    ON ep.employee_id = em.employee_id

ORDER BY
    d.department_name,
    em.department_salary_rank,
    em.salary DESC;
```

---

# ⭐ The 15 Queries You MUST Memorize

If your interview is tomorrow, don't try to memorize all 50 equally.

Master these first:

### 1. Second highest salary

```sql
SELECT MAX(salary)
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

### 2. Nth highest salary

```sql
SELECT DISTINCT salary
FROM (
    SELECT
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS rnk
    FROM employees
) x
WHERE rnk = 3;
```

### 3. Employee earning more than manager

```sql
SELECT
    e.first_name AS employee,
    e.salary AS employee_salary,
    m.first_name AS manager,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```

### 4. Employee above department average

```sql
SELECT *
FROM (
    SELECT
        e.*,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS dept_avg
    FROM employees e
) x
WHERE salary > dept_avg;
```

### 5. Highest salary per department

```sql
SELECT
    department_id,
    MAX(salary) AS max_salary
FROM employees
GROUP BY department_id;
```

### 6. Top 3 per department

```sql
SELECT *
FROM (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rn
    FROM employees e
) x
WHERE rn <= 3;
```

### 7. Duplicate records

```sql
SELECT
    email,
    COUNT(*)
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

### 8. Employees without manager

```sql
SELECT *
FROM employees
WHERE manager_id IS NULL;
```

### 9. Departments without employees

```sql
SELECT d.*
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;
```

### 10. Employees without projects

```sql
SELECT e.*
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM employee_projects ep
    WHERE ep.employee_id = e.employee_id
);
```

### 11. Running total

```sql
SELECT
    sale_date,
    amount,
    SUM(amount) OVER (
        ORDER BY sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_total
FROM sales;
```

### 12. Previous row

```sql
SELECT
    sale_date,
    amount,
    LAG(amount) OVER (
        ORDER BY sale_date
    ) AS previous_amount
FROM sales;
```

### 13. Latest record per employee

```sql
SELECT *
FROM (
    SELECT
        h.*,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC
        ) AS rn
    FROM employee_salary_history h
) x
WHERE rn = 1;
```

### 14. Monthly sales

```sql
SELECT
    DATE_TRUNC('month', sale_date) AS month,
    SUM(amount) AS total_sales
FROM sales
WHERE status = 'COMPLETED'
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY month;
```

### 15. Month-over-month growth

```sql
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(amount) AS sales
    FROM sales
    WHERE status = 'COMPLETED'
    GROUP BY DATE_TRUNC('month', sale_date)
)
SELECT
    month,
    sales,
    LAG(sales) OVER (
        ORDER BY month
    ) AS previous_sales
FROM monthly
ORDER BY month;
```

---

# 🧠 SQL Interview Memory Map

Instead of memorizing 50 independent queries, memorize these **patterns**.

## Pattern 1 — "Highest"

Think:

```sql
MAX()
```

---

## Pattern 2 — "Nth Highest"

Think:

```sql
DENSE_RANK()
```

---

## Pattern 3 — "Top N in Each Department"

Think:

```sql
PARTITION BY department_id
ORDER BY salary DESC
ROW_NUMBER()
```

---

## Pattern 4 — "Employee vs Manager"

Think:

```sql
employees e
JOIN employees m
ON e.manager_id = m.employee_id
```

**Self JOIN**

---

## Pattern 5 — "Above Average"

Think:

```sql
AVG() OVER (PARTITION BY ...)
```

or:

```sql
AVG()
GROUP BY
```

---

## Pattern 6 — "Previous"

Think:

```sql
LAG()
```

---

## Pattern 7 — "Next"

Think:

```sql
LEAD()
```

---

## Pattern 8 — "Running Total"

Think:

```sql
SUM() OVER (
    ORDER BY ...
)
```

---

## Pattern 9 — "Missing"

Think:

```sql
LEFT JOIN ... IS NULL
```

or:

```sql
NOT EXISTS
```

---

## Pattern 10 — "Duplicates"

Think:

```sql
GROUP BY
HAVING COUNT(*) > 1
```

---

## Pattern 11 — "Latest Record"

Think:

```sql
ROW_NUMBER()
PARTITION BY id
ORDER BY date DESC
```

---

## Pattern 12 — "Monthly"

Think:

```sql
DATE_TRUNC('month', date_column)
```

---

# 🔥 Most Important Interview Trick: Understand the Question Words

When the interviewer says:

| They say...          | You should think...      |
| -------------------- | ------------------------ |
| Highest              | `MAX()`                  |
| Lowest               | `MIN()`                  |
| Average              | `AVG()`                  |
| Total                | `SUM()`                  |
| Number of            | `COUNT()`                |
| Unique               | `DISTINCT`               |
| More than            | `>`                      |
| Less than            | `<`                      |
| Same as              | `=`                      |
| Above average        | `AVG()` + comparison     |
| Nth highest          | `DENSE_RANK()`           |
| Top 3 per department | `PARTITION BY`           |
| Previous             | `LAG()`                  |
| Next                 | `LEAD()`                 |
| Running              | `SUM() OVER()`           |
| Duplicate            | `GROUP BY + HAVING`      |
| Missing              | `LEFT JOIN / NOT EXISTS` |
| Manager              | Self JOIN                |
| Latest               | `ROW_NUMBER() + DESC`    |
| Monthly              | `DATE_TRUNC()`           |
| Percentage           | division + `NULLIF()`    |
| Hierarchy            | Recursive CTE            |
| Multiple             | `GROUP BY + HAVING`      |

---

# ⚠️ 10 Common Interview Traps

### 1. `WHERE` vs `HAVING`

Wrong:

```sql
WHERE COUNT(*) > 3
```

Correct:

```sql
HAVING COUNT(*) > 3
```

---

### 2. NULL comparison

Wrong:

```sql
WHERE manager_id = NULL
```

Correct:

```sql
WHERE manager_id IS NULL
```

---

### 3. Second highest with duplicate salaries

Be careful with:

```sql
LIMIT 1 OFFSET 1
```

if salaries can tie.

Prefer:

```sql
DENSE_RANK()
```

when the question means the second **distinct** salary.

---

### 4. `COUNT(*)` vs `COUNT(column)`

```sql
COUNT(*)
```

counts rows.

```sql
COUNT(phone)
```

does not count rows where `phone` is NULL.

---

### 5. INNER JOIN vs LEFT JOIN

```text
INNER JOIN
→ matching rows only

LEFT JOIN
→ everything from left table
  + matching rows from right
```

---

### 6. `NOT IN` and NULL

Be cautious:

```sql
WHERE employee_id NOT IN (...)
```

If the subquery can produce NULL, results can become surprising.

For existence questions, `NOT EXISTS` is often safer.

---

### 7. `ROW_NUMBER` vs `RANK`

If ties should all be returned:

```sql
RANK()
```

If exactly one row is needed:

```sql
ROW_NUMBER()
```

---

### 8. `RANK` vs `DENSE_RANK`

```text
RANK:
1
1
3

DENSE_RANK:
1
1
2
```

---

### 9. Filtering a window function

You generally cannot do:

```sql
WHERE ROW_NUMBER() OVER (...) <= 3
```

directly in the same SELECT level.

Use a CTE/subquery:

```sql
WITH ranked AS (
    SELECT
        ...,
        ROW_NUMBER() OVER (...) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 3;
```

---

### 10. Division by zero

Production-grade SQL should consider:

```sql
NULLIF(denominator, 0)
```

Example:

```sql
sales / NULLIF(target, 0)
```

---

# 🎯 What I Recommend You Practice

Don't just read these 50.

Open PostgreSQL and practice them in this order:

```text
LEVEL 1
───────
1  SELECT
2  WHERE
3  ORDER BY
4  DISTINCT
5  MAX / MIN / AVG / SUM / COUNT


LEVEL 2
───────
6  GROUP BY
7  HAVING
8  INNER JOIN
9  LEFT JOIN
10 SELF JOIN


LEVEL 3
───────
11 Subqueries
12 EXISTS
13 NOT EXISTS
14 CASE
15 COALESCE
16 NULLIF


LEVEL 4
───────
17 ROW_NUMBER
18 RANK
19 DENSE_RANK
20 PARTITION BY
21 LAG
22 LEAD


LEVEL 5
───────
23 CTE
24 Recursive CTE
25 Running total
26 Top-N per group
27 Month-over-month growth
28 Latest record per group


LEVEL 6
───────
29 Indexes
30 EXPLAIN ANALYZE
31 Transactions
32 ACID
33 Isolation levels
34 Deadlocks
35 Query optimization
```

---
---
---
---






# SQL Interview Questions — Query + Comments

```sql
-- Q1: Display all Engineering employees ordered by salary from highest to lowest.
-- WHERE filters only Engineering employees.
-- ORDER BY salary DESC sorts the highest salary first.

SELECT
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
WHERE d.department_name = 'Engineering'
ORDER BY e.salary DESC;
```

```sql
-- Q2: Find the number of employees in each department.
-- GROUP BY creates one group for each department.
-- COUNT(*) counts employees in each group.
-- LEFT JOIN also displays departments having zero employees.

SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;
```

```sql
-- Q3: Find the second-highest DISTINCT salary.
-- The inner query finds the highest salary.
-- The outer query ignores that salary and finds the next highest salary.
-- MAX() returns the second-highest distinct value.

SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

```sql
-- Q4: Find employees earning more than the company average salary.
-- The subquery calculates the average salary of all employees.
-- The outer query returns employees whose salary is greater than that average.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY salary DESC;
```

```sql
-- Q5: Find the highest salary in each department.
-- GROUP BY creates one group per department.
-- MAX(salary) returns the highest salary in each department.
-- This returns the salary value, not necessarily the employee details.

SELECT
    d.department_name,
    MAX(e.salary) AS highest_salary
FROM departments d
JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY highest_salary DESC;
```

```sql
-- Q6: Find employees whose salary is higher than their manager's salary.
-- This is a SELF JOIN because employee and manager are stored in the same table.
-- e represents the employee.
-- m represents the manager.
-- e.manager_id = m.employee_id connects employee to manager.
-- The WHERE condition compares their salaries.

SELECT
    e.employee_id,
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary
ORDER BY e.salary DESC;
```

```sql
-- Q7: Display each order with the customer name.
-- customer_id is the common key between customers and orders.
-- JOIN combines the order information with the customer information.
-- Each order is displayed together with its customer's name.

SELECT
    o.order_id,
    c.customer_name,
    o.order_amount,
    o.status
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;
```

```sql
-- Q8: Find customers who have never placed an order.
-- LEFT JOIN keeps every customer.
-- If a customer has no matching order, o.order_id becomes NULL.
-- Therefore, WHERE o.order_id IS NULL identifies customers with no orders.

SELECT
    c.customer_id,
    c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

```sql
-- Q9: Find customers who placed more than one order.
-- GROUP BY creates one group for each customer.
-- COUNT() counts the orders belonging to each customer.
-- HAVING filters the grouped result.
-- HAVING is used instead of WHERE because COUNT() is an aggregate function.

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(o.order_id) > 1
ORDER BY order_count DESC;
```

```sql
-- Q10: Find the highest-spending customer based only on delivered orders.
-- WHERE filters the data before aggregation.
-- Therefore, only DELIVERED orders contribute to the total.
-- SUM() calculates each customer's total delivered spending.
-- ORDER BY DESC puts the highest spender first.
-- LIMIT 1 returns the top customer.

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.order_amount) AS total_spending
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.status = 'DELIVERED'
GROUP BY c.customer_id, c.customer_name
ORDER BY total_spending DESC
LIMIT 1;
```

```sql
-- Q11: Remove all rows quickly while keeping the table.
-- TRUNCATE removes all rows from the table.
-- The table structure remains available.
-- TRUNCATE is generally faster than DELETE for removing every row.
-- Unlike DELETE, TRUNCATE cannot use a WHERE condition.
-- PostgreSQL also allows TRUNCATE to participate in a transaction.

TRUNCATE TABLE employees;
```

```sql
-- Q12: Give an intern read-only access to the Employees table.
-- GRANT SELECT gives permission to read the table.
-- It does NOT give INSERT, UPDATE, or DELETE permission.
-- This follows the principle of least privilege.

GRANT SELECT
ON TABLE employees
TO intern_user;
```

```sql
-- Q13: Why can't a SELECT alias normally be used in WHERE?
-- SQL logically processes WHERE before SELECT.
-- Therefore, the SELECT alias has not been created when WHERE is evaluated.

-- Incorrect:
-- SELECT
--     first_name,
--     salary * 12 AS annual_salary
-- FROM employees
-- WHERE annual_salary > 600000;

-- Correct approach: repeat the expression.

SELECT
    first_name,
    salary * 12 AS annual_salary
FROM employees
WHERE salary * 12 > 600000;

-- Another approach is to calculate the alias first
-- using a CTE and then filter it in the outer query.

WITH employee_salary AS (
    SELECT
        first_name,
        salary * 12 AS annual_salary
    FROM employees
)
SELECT
    first_name,
    annual_salary
FROM employee_salary
WHERE annual_salary > 600000;
```

```sql
-- Q14: Difference between ROW_NUMBER(), RANK(), and DENSE_RANK().
--
-- ROW_NUMBER():
-- Gives every row a unique number.
--
-- RANK():
-- Tied rows receive the same rank.
-- Gaps appear after a tie.
--
-- DENSE_RANK():
-- Tied rows receive the same rank.
-- No gaps appear after a tie.
--
-- Example:
-- Salaries: 90000, 80000, 80000, 70000
--
-- ROW_NUMBER : 1, 2, 3, 4
-- RANK       : 1, 2, 2, 4
-- DENSE_RANK : 1, 2, 2, 3

SELECT
    employee_id,
    first_name,
    salary,

    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_number,

    RANK() OVER (
        ORDER BY salary DESC
    ) AS rank,

    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS dense_rank

FROM employees
ORDER BY salary DESC;
```

```sql
-- Q15: Difference between COUNT(*), COUNT(email),
-- and COUNT(DISTINCT email).
--
-- COUNT(*):
-- Counts every row, including rows containing NULL values.
--
-- COUNT(email):
-- Counts only rows where email is NOT NULL.
--
-- COUNT(DISTINCT email):
-- Counts unique, non-NULL email values.
-- Duplicate email values are counted only once.

SELECT
    COUNT(*) AS total_rows,
    COUNT(email) AS non_null_emails,
    COUNT(DISTINCT email) AS unique_non_null_emails
FROM employees;
```

```sql
-- Q16: Use COALESCE to return the first available non-NULL value.
-- COALESCE checks values from left to right.
-- It returns the first value that is NOT NULL.
-- If all values are NULL, the final value is returned.

SELECT
    employee_id,
    first_name,
    last_name,
    COALESCE(
        phone,
        email,
        'No contact information'
    ) AS contact_information
FROM employees;

-- Example:
-- phone is available -> return phone
-- phone is NULL -> return email
-- phone and email are NULL -> return 'No contact information'
```

```sql
-- Q17: Find each user's previous login date using LAG().
-- LAG() accesses a value from the previous row.
-- PARTITION BY user_id creates a separate login history for each user.
-- ORDER BY login_at creates the chronological order.
-- The first login of each user has no previous login, so it returns NULL.

SELECT
    user_id,
    login_at,
    LAG(login_at) OVER (
        PARTITION BY user_id
        ORDER BY login_at
    ) AS previous_login
FROM user_logins
ORDER BY user_id, login_at;
```

```sql
-- Q18: Classify employees into Low, Medium, and High salary bands.
-- CASE is used for conditional logic inside a SELECT statement.
-- Conditions are evaluated from top to bottom.
-- Therefore, the highest threshold should be checked first.
--
-- High   : salary >= 80000
-- Medium : salary >= 50000
-- Low    : salary < 50000

SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 80000 THEN 'High'
        WHEN salary >= 50000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees
ORDER BY salary DESC;
```

```sql
-- Q19: Prevent divide-by-zero using NULLIF().
-- NULLIF(target_sales, 0) returns NULL when target_sales is 0.
-- Dividing by NULL returns NULL instead of causing a divide-by-zero error.
-- The original row is still preserved.
-- 100.0 ensures decimal percentage calculation.

SELECT
    employee_id,
    achieved_sales,
    target_sales,
    achieved_sales * 100.0
        / NULLIF(target_sales, 0) AS achievement_pct
FROM sales_targets;
```

```sql
-- Q20: Delete duplicate records while keeping the newest record for each email.
-- ROW_NUMBER() creates a sequence within each email group.
-- PARTITION BY email groups duplicate email addresses together.
-- ORDER BY created_at DESC puts the newest record first.
-- Therefore:
--     rn = 1  -> newest record that should be kept
--     rn > 1  -> older duplicate records that should be deleted
--
-- customer_id DESC is used as a tie-breaker when created_at is identical.
--
-- Always preview the ranked records before running a DELETE
-- and preferably execute the DELETE inside a transaction.

WITH ranked AS (
    SELECT
        customer_id,
        ROW_NUMBER() OVER (
            PARTITION BY email
            ORDER BY created_at DESC, customer_id DESC
        ) AS rn
    FROM customer_records
    WHERE email IS NOT NULL
)
DELETE FROM customer_records
WHERE customer_id IN (
    SELECT customer_id
    FROM ranked
    WHERE rn > 1
);
```

## Quick Interview Memory Notes

```sql
-- WHERE
-- Filters individual rows BEFORE grouping.

-- GROUP BY
-- Creates groups for aggregate calculations.

-- HAVING
-- Filters groups AFTER GROUP BY.

-- JOIN
-- Combines matching rows from tables.

-- LEFT JOIN
-- Keeps all rows from the left table.

-- COUNT(*)
-- Counts all rows.

-- COUNT(column)
-- Counts non-NULL values.

-- COUNT(DISTINCT column)
-- Counts unique non-NULL values.

-- MAX()
-- Finds the highest value.

-- MIN()
-- Finds the lowest value.

-- AVG()
-- Calculates the average.

-- SUM()
-- Calculates the total.

-- DISTINCT
-- Removes duplicate result values.

-- CASE
-- Performs conditional logic.

-- COALESCE
-- Returns the first non-NULL value.

-- NULLIF
-- Returns NULL when two values are equal.
-- Commonly used to prevent division by zero.

-- LAG()
-- Gets a value from the previous row.

-- LEAD()
-- Gets a value from the next row.

-- ROW_NUMBER()
-- Gives every row a unique sequence number.

-- RANK()
-- Same rank for ties, with gaps.

-- DENSE_RANK()
-- Same rank for ties, without gaps.

-- EXISTS
-- Checks whether a matching row exists.

-- NOT EXISTS
-- Checks whether a matching row does NOT exist.

-- SELF JOIN
-- Joins a table to itself.
-- Common example: employee -> manager.

-- SUBQUERY
-- A query inside another query.

-- CTE
-- WITH clause used to create a temporary named result
-- for the duration of a single SQL statement.
```