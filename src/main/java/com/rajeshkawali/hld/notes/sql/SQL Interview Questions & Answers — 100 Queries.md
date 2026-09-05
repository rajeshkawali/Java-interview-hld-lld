# SQL Interview Questions & Answers — 100 Queries
## PostgreSQL | Simple → Complex | Production-Style Dataset

---

# LEVEL 1 — BASIC SQL

## Q1. Display all employees

```sql
-- Q1: Display all employees.
-- SELECT * returns all columns and all rows from employees.

SELECT *
FROM employees;
```

---

## Q2. Display employee names and salaries

```sql
-- Q2: Display employee first name, last name and salary.
-- Select only the columns required instead of using SELECT *.

SELECT
    first_name,
    last_name,
    salary
FROM employees;
```

---

## Q3. Find employees earning more than 70,000

```sql
-- Q3: Find employees whose salary is greater than 70,000.
-- WHERE filters individual rows.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > 70000;
```

---

## Q4. Find employees earning 70,000 or less

```sql
-- Q4: Find employees whose salary is less than or equal to 70,000.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary <= 70000;
```

---

## Q5. Find employees with salary between 50,000 and 80,000

```sql
-- Q5: BETWEEN checks whether a value falls within an inclusive range.
-- 50,000 and 80,000 are both included.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary BETWEEN 50000 AND 80000;
```

---

## Q6. Find employees from Engineering

```sql
-- Q6: Find employees working in the Engineering department.
-- JOIN connects employees with departments.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
WHERE d.department_name = 'Engineering';
```

---

## Q7. Find employees from Engineering or Sales

```sql
-- Q7: IN is useful when checking multiple possible values.
-- This is cleaner than using multiple OR conditions.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
WHERE d.department_name IN ('Engineering', 'Sales');
```

---

## Q8. Find employees whose first name starts with A

```sql
-- Q8: LIKE is used for pattern matching.
-- 'A%' means the value starts with A.
-- % represents zero or more characters.

SELECT
    employee_id,
    first_name,
    last_name
FROM employees
WHERE first_name LIKE 'A%';
```

---

## Q9. Find employees whose name contains 'an'

```sql
-- Q9: '%an%' means 'an' can appear anywhere in the value.

SELECT
    employee_id,
    first_name,
    last_name
FROM employees
WHERE first_name LIKE '%an%';
```

---

## Q10. Sort employees by salary highest to lowest

```sql
-- Q10: ORDER BY sorts the result.
-- DESC means descending order.
-- Therefore, the highest salary appears first.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC;
```

---

## Q11. Find the highest salary

```sql
-- Q11: MAX() returns the highest salary in the table.

SELECT MAX(salary) AS highest_salary
FROM employees;
```

---

## Q12. Find the lowest salary

```sql
-- Q12: MIN() returns the lowest salary.

SELECT MIN(salary) AS lowest_salary
FROM employees;
```

---

## Q13. Find the average salary

```sql
-- Q13: AVG() calculates the average salary.

SELECT AVG(salary) AS average_salary
FROM employees;
```

---

## Q14. Find the total salary paid

```sql
-- Q14: SUM() adds all salary values.

SELECT SUM(salary) AS total_salary
FROM employees;
```

---

## Q15. Count total employees

```sql
-- Q15: COUNT(*) counts every row.

SELECT COUNT(*) AS employee_count
FROM employees;
```

---

## Q16. Count employees with non-NULL phone numbers

```sql
-- Q16: COUNT(column) counts only non-NULL values.

SELECT COUNT(phone) AS employees_with_phone
FROM employees;
```

---

## Q17. Display unique work modes

```sql
-- Q17: DISTINCT removes duplicate values from the result.

SELECT DISTINCT work_mode
FROM employees;
```

---

## Q18. Find active employees

```sql
-- Q18: Filter employees whose employment status is ACTIVE.

SELECT
    employee_id,
    first_name,
    last_name,
    employment_status
FROM employees
WHERE employment_status = 'ACTIVE';
```

---

## Q19. Find employees hired after 2020

```sql
-- Q19: DATE conditions can be used directly in WHERE.

SELECT
    employee_id,
    first_name,
    last_name,
    hire_date
FROM employees
WHERE hire_date > DATE '2020-01-01'
ORDER BY hire_date;
```

---

## Q20. Display the first 5 highest-paid employees

```sql
-- Q20: ORDER BY sorts employees by salary.
-- LIMIT restricts the number of rows returned.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC
LIMIT 5;
```

---

# LEVEL 2 — AGGREGATION & GROUP BY

## Q21. Count employees in each department

```sql
-- Q21: GROUP BY creates one group for each department.
-- COUNT() counts employees in each department.

SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
ORDER BY employee_count DESC;
```

---

## Q22. Find average salary by department

```sql
-- Q22: AVG() calculates the average salary inside each department.

SELECT
    department_id,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department_id
ORDER BY average_salary DESC;
```

---

## Q23. Find highest salary by department

```sql
-- Q23: MAX() returns the highest salary within each department.

SELECT
    department_id,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department_id
ORDER BY highest_salary DESC;
```

---

## Q24. Find lowest salary by department

```sql
-- Q24: MIN() returns the lowest salary within each department.

SELECT
    department_id,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY department_id;
```

---

## Q25. Find total salary by department

```sql
-- Q25: SUM() calculates total salary for every department.

SELECT
    department_id,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department_id
ORDER BY total_salary DESC;
```

---

## Q26. Find departments having more than 3 employees

```sql
-- Q26: HAVING filters groups after GROUP BY.
-- WHERE cannot be used to filter COUNT() results.

SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 3;
```

---

## Q27. Find departments with average salary above 70,000

```sql
-- Q27: HAVING filters the aggregated average salary.
-- AVG() is calculated separately for each department.

SELECT
    department_id,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 70000;
```

---

## Q28. Count employees by employment status

```sql
-- Q28: GROUP BY can be used with categorical columns.
-- Each employment status gets its own group.

SELECT
    employment_status,
    COUNT(*) AS employee_count
FROM employees
GROUP BY employment_status
ORDER BY employee_count DESC;
```

---

## Q29. Count employees by gender

```sql
-- Q29: Count employees for each gender.

SELECT
    gender,
    COUNT(*) AS employee_count
FROM employees
GROUP BY gender;
```

---

## Q30. Count employees by work mode

```sql
-- Q30: Find how many employees work in each work mode.

SELECT
    work_mode,
    COUNT(*) AS employee_count
FROM employees
GROUP BY work_mode
ORDER BY employee_count DESC;
```

---

# LEVEL 3 — JOINS

## Q31. Display employees with department names

```sql
-- Q31: JOIN combines employees with departments.
-- department_id is the common key.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id;
```

---

## Q32. Display employees with their job titles

```sql
-- Q32: JOIN employees with jobs using job_id.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    j.job_title
FROM employees e
JOIN jobs j
    ON j.job_id = e.job_id;
```

---

## Q33. Display employees with department and job

```sql
-- Q33: Multiple JOINs can combine information from several tables.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    j.job_title,
    e.salary
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
JOIN jobs j
    ON j.job_id = e.job_id;
```

---

## Q34. Display employees with company name

```sql
-- Q34: employees -> departments -> companies.
-- The company is reached through the employee's department.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name,
    c.company_name
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
JOIN companies c
    ON c.company_id = d.company_id;
```

---

## Q35. Display all departments including empty departments

```sql
-- Q35: LEFT JOIN keeps every department.
-- Departments without employees will still appear.
-- Employee columns will be NULL for empty departments.

SELECT
    d.department_id,
    d.department_name,
    e.employee_id,
    e.first_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id;
```

---

## Q36. Count employees in every department including zero

```sql
-- Q36: LEFT JOIN is important here.
-- It preserves departments that have no employees.
-- COUNT(e.employee_id) does not count NULL employee rows.

SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;
```

---

## Q37. Find employees without a department

```sql
-- Q37: LEFT JOIN keeps all employees.
-- NULL department_name identifies employees without a matching department.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN departments d
    ON d.department_id = e.department_id
WHERE d.department_id IS NULL;
```

---

## Q38. Display employee and manager names

```sql
-- Q38: This is a SELF JOIN.
-- The employees table is joined to itself.
-- e = employee.
-- m = manager.

SELECT
    e.employee_id,
    e.first_name AS employee_name,
    m.first_name AS manager_name
FROM employees e
LEFT JOIN employees m
    ON m.employee_id = e.manager_id;
```

---

## Q39. Find employees earning more than their manager

```sql
-- Q39: SELF JOIN connects each employee with their manager.
-- Compare the employee salary with manager salary.

SELECT
    e.employee_id,
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name AS manager_name,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON m.employee_id = e.manager_id
WHERE e.salary > m.salary;
```

---

## Q40. Find managers who manage at least one employee

```sql
-- Q40: Join employees to their managers.
-- DISTINCT prevents a manager from appearing multiple times.

SELECT DISTINCT
    m.employee_id,
    m.first_name,
    m.last_name
FROM employees e
JOIN employees m
    ON m.employee_id = e.manager_id;
```

---

# LEVEL 4 — SUBQUERIES

## Q41. Find employees earning more than average salary

```sql
-- Q41: The subquery calculates the company average.
-- The outer query finds employees above that average.

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

---

## Q42. Find the highest-paid employee

```sql
-- Q42: The subquery finds the maximum salary.
-- The outer query returns employee details for that salary.

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

---

## Q43. Find the lowest-paid employee

```sql
-- Q43: The subquery finds the minimum salary.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);
```

---

## Q44. Find the second-highest distinct salary

```sql
-- Q44: First find the highest salary.
-- Then find the maximum salary below the highest salary.
-- This handles duplicate highest salaries correctly.

SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);
```

---

## Q45. Find employees earning the second-highest salary

```sql
-- Q45: First identify the second-highest distinct salary.
-- Then return all employees having that salary.
-- Multiple employees can therefore be returned when salaries are tied.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (
        SELECT MAX(salary)
        FROM employees
    )
);
```

---

## Q46. Find employees earning above their department average

```sql
-- Q46: The correlated subquery calculates the average salary
-- for the employee's own department.
-- Each employee is compared against their department average.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

---

## Q47. Find departments having the highest average salary

```sql
-- Q47: First calculate average salary for every department.
-- Then compare each department average with the maximum department average.

SELECT
    department_id,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) = (
    SELECT MAX(avg_salary)
    FROM (
        SELECT AVG(salary) AS avg_salary
        FROM employees
        GROUP BY department_id
    ) x
);
```

---

## Q48. Find employees working in the department with the highest average salary

```sql
-- Q48: The subquery finds the department with the highest average salary.
-- The outer query returns employees belonging to that department.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.department_id = (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    ORDER BY AVG(salary) DESC
    LIMIT 1
);
```

---

## Q49. Find employees whose salary is greater than every employee in HR

```sql
-- Q49: ALL means the employee salary must be greater than
-- every salary returned by the subquery.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees e2
    JOIN departments d2
        ON d2.department_id = e2.department_id
    WHERE d2.department_name = 'HR'
);
```

---

## Q50. Find employees who belong to departments with budget above 1 million

```sql
-- Q50: The subquery returns departments with a budget above 1 million.
-- IN checks whether the employee's department belongs to that list.

SELECT
    employee_id,
    first_name,
    last_name,
    department_id
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE budget > 1000000
);
```

---

# LEVEL 5 — CASE, NULL, DATE & STRING FUNCTIONS

## Q51. Classify employees into salary bands

```sql
-- Q51: CASE implements conditional logic.
-- Conditions are evaluated from top to bottom.

SELECT
    employee_id,
    first_name,
    salary,
    CASE
        WHEN salary >= 80000 THEN 'High'
        WHEN salary >= 50000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;
```

---

## Q52. Classify employees as experienced or recent hires

```sql
-- Q52: DATE comparison is used to classify employees.
-- Employees hired before 2020 are considered experienced for this example.

SELECT
    employee_id,
    first_name,
    hire_date,
    CASE
        WHEN hire_date < DATE '2020-01-01' THEN 'Experienced'
        ELSE 'Recent Hire'
    END AS employee_category
FROM employees;
```

---

## Q53. Replace NULL phone numbers with email

```sql
-- Q53: COALESCE returns the first non-NULL value.
-- If phone is NULL, email is returned.

SELECT
    employee_id,
    first_name,
    COALESCE(phone, email) AS contact_information
FROM employees;
```

---

## Q54. Find employees with missing phone numbers

```sql
-- Q54: NULL must be checked using IS NULL.
-- Do not use phone = NULL.

SELECT
    employee_id,
    first_name,
    last_name
FROM employees
WHERE phone IS NULL;
```

---

## Q55. Find employees whose phone number is available

```sql
-- Q55: IS NOT NULL identifies rows containing a phone number.

SELECT
    employee_id,
    first_name,
    phone
FROM employees
WHERE phone IS NOT NULL;
```

---

## Q56. Display full employee name

```sql
-- Q56: CONCAT combines multiple strings.
-- CONCAT safely handles NULL values.

SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;
```

---

## Q57. Convert employee names to uppercase

```sql
-- Q57: UPPER() converts text to uppercase.

SELECT
    employee_id,
    UPPER(first_name) AS first_name_upper
FROM employees;
```

---

## Q58. Find employees hired in a particular year

```sql
-- Q58: EXTRACT() retrieves a specific date component.
-- Here we extract the year from hire_date.

SELECT
    employee_id,
    first_name,
    hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2022;
```

---

## Q59. Calculate employee tenure in years

```sql
-- Q59: AGE() calculates the difference between two dates.
-- CURRENT_DATE represents today's date.

SELECT
    employee_id,
    first_name,
    hire_date,
    AGE(CURRENT_DATE, hire_date) AS tenure
FROM employees;
```

---

## Q60. Find employees hired in the last 5 years

```sql
-- Q60: CURRENT_DATE is used as the reference date.
-- INTERVAL subtracts five years from the current date.

SELECT
    employee_id,
    first_name,
    hire_date
FROM employees
WHERE hire_date >= CURRENT_DATE - INTERVAL '5 years';
```

---

# LEVEL 6 — WINDOW FUNCTIONS

## Q61. Assign row numbers based on salary

```sql
-- Q61: ROW_NUMBER() gives every row a unique sequence number.
-- Highest salary receives row number 1.

SELECT
    employee_id,
    first_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS row_num
FROM employees;
```

---

## Q62. Rank employees by salary

```sql
-- Q62: RANK() gives tied salaries the same rank.
-- Gaps appear after ties.

SELECT
    employee_id,
    first_name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

---

## Q63. Dense-rank employees by salary

```sql
-- Q63: DENSE_RANK() gives the same rank to ties.
-- Unlike RANK(), it does not leave gaps.

SELECT
    employee_id,
    first_name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;
```

---

## Q64. Find the second-highest salary using DENSE_RANK

```sql
-- Q64: DENSE_RANK() ranks distinct salary values.
-- Rank 2 represents the second-highest distinct salary.
-- This is a common interview solution.

SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM (
    SELECT
        employee_id,
        first_name,
        last_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
) x
WHERE salary_rank = 2;
```

---

## Q65. Find top 3 salaries in the company

```sql
-- Q65: DENSE_RANK() handles salary ties.
-- Rank <= 3 returns employees earning one of the top three
-- distinct salary levels.

SELECT
    employee_id,
    first_name,
    salary
FROM (
    SELECT
        employee_id,
        first_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
) x
WHERE salary_rank <= 3
ORDER BY salary DESC;
```

---

## Q66. Rank employees within each department

```sql
-- Q66: PARTITION BY resets the ranking for every department.
-- Each department therefore has its own salary ranking.

SELECT
    employee_id,
    first_name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS department_rank
FROM employees;
```

---

## Q67. Find highest-paid employee in each department

```sql
-- Q67: Rank employees within each department.
-- rank = 1 identifies the highest salary.
-- Tied highest salaries are all returned.

SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM (
    SELECT
        e.*,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees e
) x
WHERE salary_rank = 1;
```

---

## Q68. Find top 2 employees in each department

```sql
-- Q68: ROW_NUMBER() gives exactly two rows per department.
-- Use RANK() or DENSE_RANK() instead if ties should also be included.

SELECT
    employee_id,
    first_name,
    department_id,
    salary
FROM (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rn
    FROM employees e
) x
WHERE rn <= 2;
```

---

## Q69. Calculate salary difference from department average

```sql
-- Q69: AVG() OVER() calculates the department average
-- without collapsing employee rows.
-- Each employee remains visible.

SELECT
    employee_id,
    first_name,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_average,
    salary - AVG(salary) OVER (
        PARTITION BY department_id
    ) AS difference_from_average
FROM employees;
```

---

## Q70. Find previous employee salary by salary ranking

```sql
-- Q70: LAG() returns the salary from the previous row.
-- ORDER BY salary DESC establishes the ranking order.

SELECT
    employee_id,
    first_name,
    salary,
    LAG(salary) OVER (
        ORDER BY salary DESC
    ) AS previous_salary
FROM employees;
```

---

# LEVEL 7 — ADVANCED AGGREGATION & CTEs

## Q71. Calculate running total of salaries

```sql
-- Q71: SUM() with an OVER clause creates a window aggregate.
-- The running total increases row by row according to salary order.

SELECT
    employee_id,
    first_name,
    salary,
    SUM(salary) OVER (
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_salary
FROM employees;
```

---

## Q72. Calculate percentage of total salary

```sql
-- Q72: SUM(salary) OVER() calculates the company-wide salary total.
-- Each employee salary is divided by that total.
-- NULLIF prevents division by zero.

SELECT
    employee_id,
    first_name,
    salary,
    ROUND(
        salary * 100.0 /
        NULLIF(SUM(salary) OVER (), 0),
        2
    ) AS salary_percentage
FROM employees;
```

---

## Q73. Find employees above their department average using a window function

```sql
-- Q73: AVG() OVER(PARTITION BY department_id)
-- calculates the department average without GROUP BY.
-- The outer query filters employees above that average.

SELECT
    employee_id,
    first_name,
    department_id,
    salary
FROM (
    SELECT
        e.*,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS department_average
    FROM employees e
) x
WHERE salary > department_average;
```

---

## Q74. Create a CTE for high-salary employees

```sql
-- Q74: A CTE is defined using WITH.
-- The CTE creates a temporary named result for this query.

WITH high_salary_employees AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        salary
    FROM employees
    WHERE salary >= 80000
)
SELECT *
FROM high_salary_employees;
```

---

## Q75. Use a CTE to find departments above company average salary

```sql
-- Q75: First calculate the company average.
-- Then calculate average salary for each department.
-- Finally return departments above the company average.

WITH company_avg AS (
    SELECT AVG(salary) AS avg_salary
    FROM employees
),
department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    d.department_id,
    d.department_name,
    da.avg_salary
FROM department_avg da
JOIN departments d
    ON d.department_id = da.department_id
CROSS JOIN company_avg ca
WHERE da.avg_salary > ca.avg_salary;
```

---

## Q76. Find departments with no employees

```sql
-- Q76: LEFT JOIN preserves all departments.
-- NULL employee_id means there is no matching employee.

SELECT
    d.department_id,
    d.department_name
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
WHERE e.employee_id IS NULL;
```

---

## Q77. Find employees who have never worked on a project

```sql
-- Q77: LEFT JOIN keeps every employee.
-- Employees without a project have NULL project assignments.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
WHERE ep.employee_id IS NULL;
```

---

## Q78. Count projects assigned to each employee

```sql
-- Q78: LEFT JOIN ensures employees with zero projects are included.
-- COUNT(ep.project_id) counts only matching projects.

SELECT
    e.employee_id,
    e.first_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
LEFT JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name
ORDER BY project_count DESC;
```

---

## Q79. Find employees working on more than 2 projects

```sql
-- Q79: GROUP BY creates one group per employee.
-- HAVING filters employees after counting projects.

SELECT
    e.employee_id,
    e.first_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
JOIN employee_projects ep
    ON ep.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name
HAVING COUNT(ep.project_id) > 2
ORDER BY project_count DESC;
```

---

## Q80. Find the department with the highest employee count

```sql
-- Q80: Count employees for each department.
-- ORDER BY places the largest count first.
-- LIMIT 1 returns the department with the highest count.

SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC
LIMIT 1;
```

---

# LEVEL 8 — SALES & BUSINESS QUESTIONS

## Q81. Find total sales by employee

```sql
-- Q81: SUM() calculates total sales for each employee.
-- LEFT JOIN keeps employees who have no sales.

SELECT
    e.employee_id,
    e.first_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM employees e
LEFT JOIN sales s
    ON s.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name
ORDER BY total_sales DESC;
```

---

## Q82. Find the employee with the highest total sales

```sql
-- Q82: First aggregate sales for each employee.
-- ORDER BY DESC places the highest salesperson first.
-- LIMIT 1 returns the top employee.

SELECT
    e.employee_id,
    e.first_name,
    SUM(s.amount) AS total_sales
FROM employees e
JOIN sales s
    ON s.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name
ORDER BY total_sales DESC
LIMIT 1;
```

---

## Q83. Find total sales by department

```sql
-- Q83: Join sales -> employees -> departments.
-- SUM() calculates department-level sales.

SELECT
    d.department_name,
    SUM(s.amount) AS total_sales
FROM sales s
JOIN employees e
    ON e.employee_id = s.employee_id
JOIN departments d
    ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_sales DESC;
```

---

## Q84. Find employees who have never made a sale

```sql
-- Q84: LEFT JOIN keeps all employees.
-- Employees without matching sales have NULL sales records.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN sales s
    ON s.employee_id = e.employee_id
WHERE s.sale_id IS NULL;
```

---

## Q85. Find the highest sale amount

```sql
-- Q85: MAX() returns the largest individual sale amount.

SELECT MAX(amount) AS highest_sale
FROM sales;
```

---

## Q86. Find the average sale amount

```sql
-- Q86: AVG() calculates the average value of individual sales.

SELECT AVG(amount) AS average_sale
FROM sales;
```

---

## Q87. Find monthly sales

```sql
-- Q87: DATE_TRUNC() groups dates into calendar months.
-- SUM() calculates the total sales for each month.

SELECT
    DATE_TRUNC('month', sale_date) AS sales_month,
    SUM(amount) AS total_sales
FROM sales
GROUP BY DATE_TRUNC('month', sale_date)
ORDER BY sales_month;
```

---

## Q88. Find employees whose sales are above average sales

```sql
-- Q88: First calculate the average individual sale.
-- Return sales records above that average.

SELECT
    sale_id,
    employee_id,
    amount,
    sale_date
FROM sales
WHERE amount > (
    SELECT AVG(amount)
    FROM sales
)
ORDER BY amount DESC;
```

---

## Q89. Rank employees by total sales

```sql
-- Q89: First calculate total sales per employee.
-- Then use RANK() to rank employees by their totals.

WITH employee_sales AS (
    SELECT
        e.employee_id,
        e.first_name,
        SUM(s.amount) AS total_sales
    FROM employees e
    JOIN sales s
        ON s.employee_id = e.employee_id
    GROUP BY e.employee_id, e.first_name
)
SELECT
    employee_id,
    first_name,
    total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM employee_sales
ORDER BY sales_rank;
```

---

## Q90. Find each department's percentage of total company sales

```sql
-- Q90: First calculate sales by department.
-- SUM(total_sales) OVER() calculates total company sales.
-- Divide department sales by company sales to get the percentage.

WITH department_sales AS (
    SELECT
        d.department_id,
        d.department_name,
        SUM(s.amount) AS total_sales
    FROM departments d
    JOIN employees e
        ON e.department_id = d.department_id
    JOIN sales s
        ON s.employee_id = e.employee_id
    GROUP BY d.department_id, d.department_name
)
SELECT
    department_id,
    department_name,
    total_sales,
    ROUND(
        total_sales * 100.0 /
        NULLIF(SUM(total_sales) OVER (), 0),
        2
    ) AS sales_percentage
FROM department_sales
ORDER BY sales_percentage DESC;
```

---

# LEVEL 9 — ADVANCED INTERVIEW QUESTIONS

## Q91. Find the second-highest salary in every department

```sql
-- Q91: DENSE_RANK() ranks salaries separately inside each department.
-- Rank 2 represents the second-highest distinct salary.
-- Ties at rank 2 are all returned.

SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees e
) x
WHERE salary_rank = 2;
```

---

## Q92. Find the top 3 earners in every department

```sql
-- Q92: DENSE_RANK() ranks employees within each department.
-- Rank <= 3 returns employees in the top three distinct salary levels.

SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees e
) x
WHERE salary_rank <= 3
ORDER BY department_id, salary DESC;
```

---

## Q93. Find employees whose salary is higher than their department head

```sql
-- Q93: departments.department_head_id identifies the department head.
-- Join employees to departments and then to the head employee.
-- Compare the employee's salary with the department head's salary.

SELECT
    e.employee_id,
    e.first_name AS employee_name,
    e.salary AS employee_salary,
    d.department_name,
    h.first_name AS department_head,
    h.salary AS head_salary
FROM employees e
JOIN departments d
    ON d.department_id = e.department_id
JOIN employees h
    ON h.employee_id = d.department_head_id
WHERE e.salary > h.salary;
```

---

## Q94. Find duplicate email addresses

```sql
-- Q94: GROUP BY groups employees by email.
-- HAVING identifies emails appearing more than once.
-- COUNT(*) tells us how many records use each email.

SELECT
    email,
    COUNT(*) AS email_count
FROM employees
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

---

## Q95. Find duplicate employee names

```sql
-- Q95: Group by first and last name.
-- HAVING identifies names appearing more than once.

SELECT
    first_name,
    last_name,
    COUNT(*) AS duplicate_count
FROM employees
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;
```

---

## Q96. Find employees with the same salary

```sql
-- Q96: Group employees by salary.
-- HAVING finds salary values shared by multiple employees.

SELECT
    salary,
    COUNT(*) AS employee_count
FROM employees
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;
```

---

## Q97. Delete duplicate records while keeping the newest one

```sql
-- Q97: ROW_NUMBER() identifies duplicate records.
-- PARTITION BY email creates one group for every email.
-- The newest record gets rn = 1.
-- Records with rn > 1 are older duplicates.
--
-- employee_import is used as a staging/import table where
-- duplicate emails are allowed.

WITH ranked AS (
    SELECT
        employee_import_id,
        ROW_NUMBER() OVER (
            PARTITION BY email
            ORDER BY created_at DESC, employee_import_id DESC
        ) AS rn
    FROM employee_import
    WHERE email IS NOT NULL
)
DELETE FROM employee_import
WHERE employee_import_id IN (
    SELECT employee_import_id
    FROM ranked
    WHERE rn > 1
);
```

---

## Q98. Find employees who have the same salary as someone in another department

```sql
-- Q98: EXISTS checks whether another employee exists
-- with the same salary but a different department.
-- The employee is compared against another row from employees.

SELECT
    e.employee_id,
    e.first_name,
    e.department_id,
    e.salary
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.salary = e.salary
      AND e2.department_id <> e.department_id
      AND e2.employee_id <> e.employee_id
);
```

---

## Q99. Find employees whose salary increased in salary history

```sql
-- Q99: employee_salary_history stores old and new salary values.
-- Compare new_salary with old_salary.
-- This identifies salary increase records.

SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    h.old_salary,
    h.new_salary,
    h.effective_date
FROM employee_salary_history h
JOIN employees e
    ON e.employee_id = h.employee_id
WHERE h.new_salary > h.old_salary
ORDER BY h.effective_date DESC;
```

---

## Q100. Find the latest salary for every employee from salary history

```sql
-- Q100: This is a common advanced interview problem.
-- ROW_NUMBER() ranks salary-history records for each employee.
-- The newest effective_date gets rn = 1.
-- Return only the latest salary record for each employee.

WITH latest_salary AS (
    SELECT
        h.employee_id,
        h.new_salary,
        h.effective_date,
        ROW_NUMBER() OVER (
            PARTITION BY h.employee_id
            ORDER BY h.effective_date DESC, h.salary_history_id DESC
        ) AS rn
    FROM employee_salary_history h
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    ls.new_salary AS latest_salary,
    ls.effective_date
FROM latest_salary ls
JOIN employees e
    ON e.employee_id = ls.employee_id
WHERE ls.rn = 1
ORDER BY e.employee_id;
```

---

# ⭐ BONUS — SQL INTERVIEW CHEAT SHEET

```sql
-- SELECT
-- Choose columns to display.

-- WHERE
-- Filter individual rows.

-- DISTINCT
-- Remove duplicate values from the result.

-- ORDER BY
-- Sort the result.

-- LIMIT
-- Restrict the number of rows returned.

-- GROUP BY
-- Create groups for aggregate calculations.

-- HAVING
-- Filter groups after GROUP BY.

-- JOIN
-- Combine matching rows from tables.

-- LEFT JOIN
-- Keep every row from the left table.

-- SELF JOIN
-- Join a table to itself.

-- MAX()
-- Highest value.

-- MIN()
-- Lowest value.

-- AVG()
-- Average value.

-- SUM()
-- Total value.

-- COUNT(*)
-- Count all rows.

-- COUNT(column)
-- Count non-NULL values.

-- COUNT(DISTINCT column)
-- Count unique non-NULL values.

-- CASE
-- Conditional logic.

-- COALESCE()
-- Return the first non-NULL value.

-- NULLIF()
-- Return NULL when two values are equal.
-- Commonly used to prevent division by zero.

-- IN
-- Check whether a value exists in a list.

-- EXISTS
-- Check whether a matching row exists.

-- NOT EXISTS
-- Check whether a matching row does not exist.

-- LIKE
-- Pattern matching.

-- BETWEEN
-- Check whether a value is within a range.

-- ROW_NUMBER()
-- Unique sequential number.

-- RANK()
-- Same rank for ties, with gaps.

-- DENSE_RANK()
-- Same rank for ties, without gaps.

-- LAG()
-- Get the previous row's value.

-- LEAD()
-- Get the next row's value.

-- PARTITION BY
-- Divide window-function calculations into groups.

-- CTE / WITH
-- Create a temporary named result for a query.

-- SUBQUERY
-- Query inside another query.

-- UNION
-- Combine results and remove duplicates.

-- UNION ALL
-- Combine results without removing duplicates.

-- INTERSECT
-- Return rows common to both queries.

-- EXCEPT
-- Return rows from the first query that are not in the second.

-- TRUNCATE
-- Remove all rows while keeping the table structure.

-- DELETE
-- Remove rows, optionally using WHERE.

-- DROP
-- Remove the database object itself.

-- GRANT
-- Give privileges to a user/role.

-- REVOKE
-- Remove privileges from a user/role.
```