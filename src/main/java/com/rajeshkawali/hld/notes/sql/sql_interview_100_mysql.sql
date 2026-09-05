-- ============================================================
-- SQL INTERVIEW PRACTICE: 110+ MYSQL 8.0+ QUESTIONS & ANSWERS
-- Based on the SQL Interview Practice database/schema.
--
-- Run the database setup script first:
--     sql_interview_practice_mysql.sql
--
-- Then run this file in MySQL Workbench.
--
-- IMPORTANT:
-- * Window functions and CTEs require MySQL 8.0+.
-- * Questions are ordered from SIMPLE -> INTERMEDIATE -> ADVANCED.
-- * Comments explain what each query is doing and why.
-- ============================================================

USE sql_interview_practice;

-- ============================================================
-- LEVEL 1: BASIC SELECT / WHERE / ORDER BY
-- ============================================================

-- Q1. Display all employees.
-- Explanation:
-- SELECT * returns every column from the employees table.
SELECT *
FROM employees;


-- Q2. Display employee names and salaries.
-- Explanation:
-- Select only the columns required by the interviewer.
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees;


-- Q3. Find employees earning more than 70,000.
-- Explanation:
-- WHERE filters rows before they are returned.
SELECT *
FROM employees
WHERE salary > 70000;


-- Q4. Find employees earning 70,000 or less.
SELECT *
FROM employees
WHERE salary <= 70000;


-- Q5. Find employees earning between 50,000 and 80,000.
-- Explanation:
-- BETWEEN is inclusive, so 50,000 and 80,000 are included.
SELECT *
FROM employees
WHERE salary BETWEEN 50000 AND 80000;


-- Q6. Find employees with salary exactly 70,000.
SELECT *
FROM employees
WHERE salary = 70000;


-- Q7. Find employees whose salary is not 70,000.
SELECT *
FROM employees
WHERE salary <> 70000;


-- Q8. Find employees in department IDs 1, 2, or 3.
-- IN is cleaner than writing multiple OR conditions.
SELECT *
FROM employees
WHERE department_id IN (1, 2, 3);


-- Q9. Find employees whose first name starts with 'A'.
-- % represents zero or more characters.
SELECT *
FROM employees
WHERE first_name LIKE 'A%';


-- Q10. Find employees whose first name ends with 'n'.
SELECT *
FROM employees
WHERE first_name LIKE '%n';


-- Q11. Find employees whose first name contains 'an'.
SELECT *
FROM employees
WHERE first_name LIKE '%an%';


-- Q12. Find employees whose first name has exactly 5 characters.
-- _ represents exactly one character.
SELECT *
FROM employees
WHERE first_name LIKE '_____';


-- Q13. Find employees whose phone number is missing.
-- NULL must be checked with IS NULL, not = NULL.
SELECT *
FROM employees
WHERE phone IS NULL;


-- Q14. Find employees whose phone number is available.
SELECT *
FROM employees
WHERE phone IS NOT NULL;


-- Q15. Sort employees by salary from highest to lowest.
SELECT *
FROM employees
ORDER BY salary DESC;


-- Q16. Sort employees by salary from lowest to highest.
SELECT *
FROM employees
ORDER BY salary ASC;


-- Q17. Sort by department and then salary.
-- Explanation:
-- The second ORDER BY column breaks ties in department order.
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM employees
ORDER BY department_id, salary DESC;


-- Q18. Return the top 5 highest-paid employees.
-- LIMIT restricts the number of returned rows in MySQL.
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC
LIMIT 5;


-- Q19. Return the 5 lowest-paid employees.
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary ASC
LIMIT 5;


-- Q20. Find active employees.
SELECT *
FROM employees
WHERE employment_status = 'ACTIVE';


-- Q21. Find employees hired after 2020-01-01.
SELECT *
FROM employees
WHERE hire_date > '2020-01-01';


-- Q22. Find employees hired during 2022.
-- YEAR() extracts the year portion of a DATE value.
SELECT *
FROM employees
WHERE YEAR(hire_date) = 2022;


-- ============================================================
-- LEVEL 2: DISTINCT / AGGREGATE FUNCTIONS
-- ============================================================

-- Q23. Find all distinct work modes.
SELECT DISTINCT
    work_mode
FROM employees;


-- Q24. Count all employees.
-- COUNT(*) counts rows, including rows containing NULL values.
SELECT COUNT(*) AS employee_count
FROM employees;


-- Q25. Count employees who have a phone number.
-- COUNT(column) ignores NULL values.
SELECT COUNT(phone) AS employees_with_phone
FROM employees;


-- Q26. Find the highest salary.
SELECT MAX(salary) AS highest_salary
FROM employees;


-- Q27. Find the lowest salary.
SELECT MIN(salary) AS lowest_salary
FROM employees;


-- Q28. Find the average salary.
SELECT ROUND(AVG(salary), 2) AS average_salary
FROM employees;


-- Q29. Find total salary expense.
SELECT SUM(salary) AS total_salary
FROM employees;


-- Q30. Count employees by employment status.
-- GROUP BY creates one result row for each status.
SELECT
    employment_status,
    COUNT(*) AS employee_count
FROM employees
GROUP BY employment_status;


-- Q31. Count employees by gender.
SELECT
    gender,
    COUNT(*) AS employee_count
FROM employees
GROUP BY gender;


-- Q32. Count employees by work mode.
SELECT
    work_mode,
    COUNT(*) AS employee_count
FROM employees
GROUP BY work_mode;


-- Q33. Find average salary by department.
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id;


-- Q34. Find highest salary by department.
SELECT
    department_id,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department_id;


-- Q35. Find lowest salary by department.
SELECT
    department_id,
    MIN(salary) AS lowest_salary
FROM employees
GROUP BY department_id;


-- Q36. Find total salary by department.
SELECT
    department_id,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department_id;


-- Q37. Find departments having more than 3 employees.
-- HAVING filters groups after GROUP BY.
SELECT
    department_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department_id
HAVING COUNT(*) > 3;


-- Q38. Find departments whose average salary is above 70,000.
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > 70000;


-- ============================================================
-- LEVEL 3: JOINS
-- ============================================================

-- Q39. Display employees with department names.
-- INNER JOIN returns only matching employee/department rows.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id;


-- Q40. Display employees with job titles.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    j.job_title
FROM employees e
JOIN jobs j
    ON e.job_id = j.job_id;


-- Q41. Display employee, department, and job.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    j.job_title,
    e.salary
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN jobs j
    ON e.job_id = j.job_id;


-- Q42. Display employees with their company names.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    c.company_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN companies c
    ON d.company_id = c.company_id;


-- Q43. Display every department, even if it has no employees.
-- LEFT JOIN preserves every row from departments.
SELECT
    d.department_id,
    d.department_name,
    e.employee_id,
    e.first_name,
    e.last_name
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id;


-- Q44. Count employees for every department, including zero.
-- COUNT(e.employee_id), rather than COUNT(*), is important here.
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name;


-- Q45. Find departments with no employees.
SELECT
    d.department_id,
    d.department_name
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
WHERE e.employee_id IS NULL;


-- Q46. Display each employee and their manager.
-- This is a SELF JOIN because employee and manager are in the same table.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
LEFT JOIN employees m
    ON e.manager_id = m.employee_id;


-- Q47. Find employees earning more than their manager.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.salary AS employee_salary,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    m.salary AS manager_salary
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;


-- Q48. Find managers who manage at least one employee.
SELECT DISTINCT
    m.employee_id,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
JOIN employees m
    ON e.manager_id = m.employee_id;


-- Q49. Display all employees and their department budget.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    d.budget
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id;


-- Q50. Find employees working in departments with budget above 1 million.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    d.budget
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
WHERE d.budget > 1000000;


-- ============================================================
-- LEVEL 4: SUBQUERIES
-- ============================================================

-- Q51. Find employees earning above company average.
SELECT
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);


-- Q52. Find the highest-paid employee.
-- Using MAX() in a subquery also returns all employees in case of a tie.
SELECT *
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);


-- Q53. Find the lowest-paid employee.
SELECT *
FROM employees
WHERE salary = (
    SELECT MIN(salary)
    FROM employees
);


-- Q54. Find the second-highest distinct salary.
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);


-- Q55. Find employees earning the second-highest salary.
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


-- Q56. Find employees earning above their department average.
-- The subquery is correlated with the outer employee's department.
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


-- Q57. Find the department with the highest average salary.
SELECT
    department_id,
    ROUND(AVG(salary), 2) AS average_salary
FROM employees
GROUP BY department_id
ORDER BY average_salary DESC
LIMIT 1;


-- Q58. Find employees in the department with the highest average salary.
SELECT *
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    ORDER BY AVG(salary) DESC
    LIMIT 1
);


-- Q59. Find employees earning more than every employee in HR.
-- ALL means the employee's salary must be greater than every HR salary.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE e.salary > ALL (
    SELECT e2.salary
    FROM employees e2
    JOIN departments d
        ON e2.department_id = d.department_id
    WHERE d.department_name = 'HR'
);


-- Q60. Find employees who have the same salary as employee ID 5.
SELECT *
FROM employees
WHERE salary = (
    SELECT salary
    FROM employees
    WHERE employee_id = 5
);


-- Q61. Find employees who work in the same department as employee ID 5.
SELECT *
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE employee_id = 5
)
AND employee_id <> 5;


-- Q62. Find employees whose salary is greater than the salary of every employee in Sales.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE e.salary > ALL (
    SELECT e2.salary
    FROM employees e2
    JOIN departments d
        ON e2.department_id = d.department_id
    WHERE d.department_name = 'Sales'
);


-- ============================================================
-- LEVEL 5: CASE / NULL / STRING / DATE FUNCTIONS
-- ============================================================

-- Q63. Create salary bands.
-- CASE lets us create business categories from numeric data.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;


-- Q64. Categorize employees by hire date.
SELECT
    employee_id,
    first_name,
    last_name,
    hire_date,
    CASE
        WHEN hire_date < '2020-01-01' THEN 'Experienced'
        ELSE 'Recent Hire'
    END AS employee_category
FROM employees;


-- Q65. Display phone if available; otherwise display email.
-- COALESCE returns the first non-NULL expression.
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS employee_name,
    COALESCE(phone, email) AS contact_information
FROM employees;


-- Q66. Display full employee name.
SELECT
    employee_id,
    CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;


-- Q67. Convert first names to uppercase.
SELECT
    employee_id,
    UPPER(first_name) AS first_name_uppercase
FROM employees;


-- Q68. Convert last names to lowercase.
SELECT
    employee_id,
    LOWER(last_name) AS last_name_lowercase
FROM employees;


-- Q69. Find the length of each employee's first name.
SELECT
    employee_id,
    first_name,
    CHAR_LENGTH(first_name) AS name_length
FROM employees;


-- Q70. Find employees hired in 2022.
SELECT *
FROM employees
WHERE YEAR(hire_date) = 2022;


-- Q71. Find employees hired in January.
SELECT *
FROM employees
WHERE MONTH(hire_date) = 1;


-- Q72. Calculate completed years of employment.
-- TIMESTAMPDIFF(YEAR, ...) calculates completed years.
SELECT
    employee_id,
    first_name,
    last_name,
    hire_date,
    TIMESTAMPDIFF(YEAR, hire_date, CURDATE()) AS tenure_years
FROM employees;


-- Q73. Find employees hired in the last 5 years.
SELECT *
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);


-- Q74. Find employees hired before 2020.
SELECT *
FROM employees
WHERE hire_date < '2020-01-01';


-- Q75. Display employee email in uppercase.
SELECT
    employee_id,
    UPPER(email) AS email_uppercase
FROM employees;


-- Q76. Find employees whose first name begins with A and salary is above 70,000.
SELECT *
FROM employees
WHERE first_name LIKE 'A%'
  AND salary > 70000;


-- ============================================================
-- LEVEL 6: WINDOW FUNCTIONS
-- ============================================================

-- Q77. Assign row numbers by salary.
-- ROW_NUMBER gives every row a unique sequence number.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC, employee_id
    ) AS row_num
FROM employees;


-- Q78. Rank employees by salary.
-- RANK gives the same rank to ties and leaves gaps afterward.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;


-- Q79. Dense-rank employees by salary.
-- DENSE_RANK gives the same rank to ties without gaps.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    DENSE_RANK() OVER (
        ORDER BY salary DESC
    ) AS salary_rank
FROM employees;


-- Q80. Find the second-highest salary using DENSE_RANK.
WITH ranked_employees AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM ranked_employees
WHERE salary_rank = 2;


-- Q81. Find the top 3 salary levels.
WITH ranked_employees AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM ranked_employees
WHERE salary_rank <= 3
ORDER BY salary DESC;


-- Q82. Rank employees within each department.
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS department_salary_rank
FROM employees;


-- Q83. Find the highest-paid employee in each department.
WITH ranked AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        department_id,
        salary,
        RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM employees
)
SELECT *
FROM ranked
WHERE rnk = 1;


-- Q84. Find top 2 employees in every department.
WITH ranked AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        department_id,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC, employee_id
        ) AS row_num
    FROM employees
)
SELECT *
FROM ranked
WHERE row_num <= 2
ORDER BY department_id, salary DESC;


-- Q85. Find the second-highest salary in every department.
WITH ranked AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS rnk
    FROM employees
)
SELECT *
FROM ranked
WHERE rnk = 2;


-- Q86. Show salary and department average on every employee row.
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary,
    ROUND(
        AVG(salary) OVER (
            PARTITION BY department_id
        ),
        2
    ) AS department_average_salary
FROM employees;


-- Q87. Find employees earning above their department average using a window function.
WITH employee_salary AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        department_id,
        salary,
        AVG(salary) OVER (
            PARTITION BY department_id
        ) AS department_average
    FROM employees
)
SELECT *
FROM employee_salary
WHERE salary > department_average;


-- Q88. Calculate salary difference from department average.
SELECT
    employee_id,
    first_name,
    last_name,
    department_id,
    salary,
    ROUND(
        salary - AVG(salary) OVER (
            PARTITION BY department_id
        ),
        2
    ) AS difference_from_department_average
FROM employees;


-- Q89. Calculate each employee's percentage of total company salary.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    ROUND(
        salary * 100.0 / SUM(salary) OVER (),
        2
    ) AS salary_percentage
FROM employees;


-- Q90. Calculate a running total of salaries.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    SUM(salary) OVER (
        ORDER BY employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_salary
FROM employees;


-- Q91. Compare each salary with the previous salary in salary order.
-- LAG returns a value from the previous row.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    LAG(salary) OVER (
        ORDER BY salary DESC, employee_id
    ) AS previous_salary
FROM employees;


-- Q92. Compare each salary with the next salary in salary order.
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    LEAD(salary) OVER (
        ORDER BY salary DESC, employee_id
    ) AS next_salary
FROM employees;


-- ============================================================
-- LEVEL 7: CTEs / ADVANCED ORGANIZATION
-- ============================================================

-- Q93. Find high-salary employees using a CTE.
WITH high_salary AS (
    SELECT *
    FROM employees
    WHERE salary > 80000
)
SELECT *
FROM high_salary;


-- Q94. Find departments whose average salary is above company average.
WITH department_salary AS (
    SELECT
        department_id,
        AVG(salary) AS department_average
    FROM employees
    GROUP BY department_id
),
company_salary AS (
    SELECT AVG(salary) AS company_average
    FROM employees
)
SELECT
    ds.department_id,
    ROUND(ds.department_average, 2) AS department_average,
    ROUND(cs.company_average, 2) AS company_average
FROM department_salary ds
CROSS JOIN company_salary cs
WHERE ds.department_average > cs.company_average;


-- Q95. Find departments with no employees using a CTE.
WITH department_counts AS (
    SELECT
        d.department_id,
        d.department_name,
        COUNT(e.employee_id) AS employee_count
    FROM departments d
    LEFT JOIN employees e
        ON d.department_id = e.department_id
    GROUP BY
        d.department_id,
        d.department_name
)
SELECT *
FROM department_counts
WHERE employee_count = 0;


-- Q96. Find employees who have never worked on a project.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN employee_projects ep
    ON e.employee_id = ep.employee_id
WHERE ep.employee_id IS NULL;


-- Q97. Count projects for every employee, including zero.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
LEFT JOIN employee_projects ep
    ON e.employee_id = ep.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name;


-- Q98. Find employees working on more than 2 projects.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COUNT(ep.project_id) AS project_count
FROM employees e
JOIN employee_projects ep
    ON e.employee_id = ep.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
HAVING COUNT(ep.project_id) > 2;


-- Q99. Find the department with the highest employee count.
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY employee_count DESC
LIMIT 1;


-- Q100. Find the top 3 departments by employee count.
SELECT
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY employee_count DESC
LIMIT 3;


-- ============================================================
-- LEVEL 8: SALES / BUSINESS QUERIES
-- ============================================================

-- Q101. Find total sales made by each employee.
-- LEFT JOIN includes employees who have never made a sale.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM employees e
LEFT JOIN sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name;


-- Q102. Find the employee with the highest total sales.
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    SUM(s.amount) AS total_sales
FROM employees e
JOIN sales s
    ON e.employee_id = s.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name
ORDER BY total_sales DESC
LIMIT 1;


-- Q103. Find total sales by department.
SELECT
    d.department_id,
    d.department_name,
    COALESCE(SUM(s.amount), 0) AS total_sales
FROM departments d
LEFT JOIN employees e
    ON d.department_id = e.department_id
LEFT JOIN sales s
    ON e.employee_id = s.employee_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_sales DESC;


-- Q104. Find employees who never made a sale.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
LEFT JOIN sales s
    ON e.employee_id = s.employee_id
WHERE s.sale_id IS NULL;


-- Q105. Find the highest individual sale.
SELECT MAX(amount) AS highest_sale
FROM sales;


-- Q106. Find the average sale amount.
SELECT ROUND(AVG(amount), 2) AS average_sale
FROM sales;


-- Q107. Find sales above the average sale amount.
SELECT *
FROM sales
WHERE amount > (
    SELECT AVG(amount)
    FROM sales
);


-- Q108. Find monthly sales.
-- DATE_FORMAT converts each date to the first day of its month,
-- making it convenient to GROUP BY month.
SELECT
    DATE_FORMAT(sale_date, '%Y-%m-01') AS sales_month,
    SUM(amount) AS total_sales
FROM sales
GROUP BY DATE_FORMAT(sale_date, '%Y-%m-01')
ORDER BY sales_month;


-- Q109. Rank employees by total sales.
WITH employee_sales AS (
    SELECT
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        COALESCE(SUM(s.amount), 0) AS total_sales
    FROM employees e
    LEFT JOIN sales s
        ON e.employee_id = s.employee_id
    GROUP BY
        e.employee_id,
        e.first_name,
        e.last_name
)
SELECT
    employee_id,
    employee_name,
    total_sales,
    RANK() OVER (
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM employee_sales;


-- Q110. Calculate each department's percentage of total sales.
WITH department_sales AS (
    SELECT
        d.department_id,
        d.department_name,
        COALESCE(SUM(s.amount), 0) AS total_sales
    FROM departments d
    LEFT JOIN employees e
        ON d.department_id = e.department_id
    LEFT JOIN sales s
        ON e.employee_id = s.employee_id
    GROUP BY
        d.department_id,
        d.department_name
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
ORDER BY total_sales DESC;


-- ============================================================
-- LEVEL 9: DUPLICATES / SELF-JOIN / EXISTS / HISTORY
-- ============================================================

-- Q111. Find duplicate employee names.
SELECT
    first_name,
    last_name,
    COUNT(*) AS duplicate_count
FROM employees
GROUP BY
    first_name,
    last_name
HAVING COUNT(*) > 1;


-- Q112. Find salaries shared by multiple employees.
SELECT
    salary,
    COUNT(*) AS employee_count
FROM employees
GROUP BY salary
HAVING COUNT(*) > 1
ORDER BY salary DESC;


-- Q113. Find employees whose salary is shared with another employee.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.salary = e.salary
      AND e2.employee_id <> e.employee_id
);


-- Q114. Find employees who share a salary with someone in another department.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
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


-- Q115. Find employees whose salary has increased in salary history.
SELECT DISTINCT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary AS current_salary
FROM employees e
JOIN employee_salary_history h
    ON e.employee_id = h.employee_id
WHERE h.new_salary > h.old_salary;


-- Q116. Find the latest salary history record for every employee.
WITH ranked_history AS (
    SELECT
        salary_history_id,
        employee_id,
        old_salary,
        new_salary,
        effective_date,
        reason,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC, salary_history_id DESC
        ) AS row_num
    FROM employee_salary_history
)
SELECT
    employee_id,
    old_salary,
    new_salary,
    effective_date,
    reason
FROM ranked_history
WHERE row_num = 1;


-- Q117. Find employees whose current salary differs from their latest historical new salary.
WITH ranked_history AS (
    SELECT
        employee_id,
        new_salary,
        effective_date,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date DESC, salary_history_id DESC
        ) AS row_num
    FROM employee_salary_history
)
SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.salary AS current_salary,
    rh.new_salary AS latest_history_salary
FROM employees e
JOIN ranked_history rh
    ON e.employee_id = rh.employee_id
WHERE rh.row_num = 1
  AND e.salary <> rh.new_salary;


-- Q118. Find the largest salary increase ever recorded.
SELECT
    salary_history_id,
    employee_id,
    old_salary,
    new_salary,
    new_salary - old_salary AS salary_increase,
    effective_date
FROM employee_salary_history
ORDER BY salary_increase DESC
LIMIT 1;


-- ============================================================
-- LEVEL 10: VERY COMMON ADVANCED INTERVIEW QUESTIONS
-- ============================================================

-- Q119. Find the second-highest salary without using LIMIT.
-- Explanation:
-- First find the maximum salary, then find the maximum below it.
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
);


-- Q120. Find the third-highest distinct salary.
SELECT MAX(salary) AS third_highest_salary
FROM employees
WHERE salary < (
    SELECT MAX(salary)
    FROM employees
    WHERE salary < (
        SELECT MAX(salary)
        FROM employees
    )
);


-- Q121. Find employees with the third-highest salary.
WITH ranked AS (
    SELECT
        employee_id,
        first_name,
        last_name,
        salary,
        DENSE_RANK() OVER (
            ORDER BY salary DESC
        ) AS rnk
    FROM employees
)
SELECT *
FROM ranked
WHERE rnk = 3;


-- Q122. Find the highest-paid employee in each department,
-- including ties.
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


-- Q123. Find departments where the highest salary is above 100,000.
SELECT
    department_id,
    MAX(salary) AS highest_salary
FROM employees
GROUP BY department_id
HAVING MAX(salary) > 100000;


-- Q124. Find departments where every employee earns at least 60,000.
SELECT
    department_id,
    MIN(salary) AS minimum_salary
FROM employees
GROUP BY department_id
HAVING MIN(salary) >= 60000;


-- Q125. Find departments where at least one employee earns above 100,000.
SELECT
    department_id,
    MAX(salary) AS maximum_salary
FROM employees
GROUP BY department_id
HAVING MAX(salary) > 100000;


-- Q126. Find employees who are not managers.
-- A manager is anyone whose employee_id appears as another employee's manager_id.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM employees sub
    WHERE sub.manager_id = e.employee_id
);


-- Q127. Find employees who are managers.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM employees sub
    WHERE sub.manager_id = e.employee_id
);


-- Q128. Find employees who have both sales and projects.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
)
AND EXISTS (
    SELECT 1
    FROM employee_projects ep
    WHERE ep.employee_id = e.employee_id
);


-- Q129. Find employees who have projects but no sales.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM employee_projects ep
    WHERE ep.employee_id = e.employee_id
)
AND NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
);


-- Q130. Find employees who have sales but no projects.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
)
AND NOT EXISTS (
    SELECT 1
    FROM employee_projects ep
    WHERE ep.employee_id = e.employee_id
);


-- ============================================================
-- BONUS: CLASSIC INTERVIEW CONCEPTS
-- ============================================================

-- Q131. Find duplicate salaries and list the employees sharing them.
SELECT
    e.salary,
    GROUP_CONCAT(
        CONCAT(e.first_name, ' ', e.last_name)
        ORDER BY e.last_name
        SEPARATOR ', '
    ) AS employees,
    COUNT(*) AS employee_count
FROM employees e
GROUP BY e.salary
HAVING COUNT(*) > 1
ORDER BY e.salary DESC;


-- Q132. Find the employee with the maximum salary in each department
-- using a correlated subquery.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);


-- Q133. Find employees whose salary is above both:
-- 1) company average and
-- 2) department average.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees
)
AND e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);


-- Q134. Find the department with the largest total salary expense.
SELECT
    d.department_id,
    d.department_name,
    SUM(e.salary) AS total_salary
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY total_salary DESC
LIMIT 1;


-- Q135. Find the employee with the largest salary increase percentage
-- in salary history.
SELECT
    salary_history_id,
    employee_id,
    old_salary,
    new_salary,
    ROUND(
        (new_salary - old_salary) * 100.0 /
        NULLIF(old_salary, 0),
        2
    ) AS increase_percentage
FROM employee_salary_history
ORDER BY increase_percentage DESC
LIMIT 1;


-- Q136. Find employees whose current salary is greater than
-- their original salary recorded in salary history.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary AS current_salary,
    h.old_salary AS original_salary
FROM employees e
JOIN (
    SELECT
        employee_id,
        old_salary,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY effective_date ASC, salary_history_id ASC
        ) AS row_num
    FROM employee_salary_history
) h
    ON e.employee_id = h.employee_id
WHERE h.row_num = 1
  AND e.salary > h.old_salary;


-- Q137. Find the average salary of managers versus non-managers.
WITH employee_types AS (
    SELECT
        e.employee_id,
        e.salary,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM employees x
                WHERE x.manager_id = e.employee_id
            )
            THEN 'Manager'
            ELSE 'Non-Manager'
        END AS employee_type
    FROM employees e
)
SELECT
    employee_type,
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS average_salary
FROM employee_types
GROUP BY employee_type;


-- Q138. Find the highest-paid employee who is not a manager.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM employees x
    WHERE x.manager_id = e.employee_id
)
ORDER BY e.salary DESC
LIMIT 1;


-- Q139. Find employees whose salary is greater than their department's
-- minimum salary but less than its maximum salary.
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT MIN(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
)
AND e.salary < (
    SELECT MAX(e3.salary)
    FROM employees e3
    WHERE e3.department_id = e.department_id
);


-- Q140. Find the top 3 departments by average salary.
SELECT
    d.department_id,
    d.department_name,
    ROUND(AVG(e.salary), 2) AS average_salary
FROM departments d
JOIN employees e
    ON d.department_id = e.department_id
GROUP BY
    d.department_id,
    d.department_name
ORDER BY average_salary DESC
LIMIT 3;


-- ============================================================
-- QUICK REVISION: 15 PATTERNS TO MEMORIZE
-- ============================================================

-- PATTERN 1: Maximum salary
SELECT MAX(salary) FROM employees;


-- PATTERN 2: Second-highest salary
SELECT MAX(salary)
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);


-- PATTERN 3: Employees above average
SELECT *
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);


-- PATTERN 4: Duplicate values
SELECT email, COUNT(*)
FROM employee_import
GROUP BY email
HAVING COUNT(*) > 1;


-- PATTERN 5: Employees with no matching rows
SELECT e.*
FROM employees e
LEFT JOIN employee_projects ep
    ON e.employee_id = ep.employee_id
WHERE ep.employee_id IS NULL;


-- PATTERN 6: Highest salary per department
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


-- PATTERN 7: Top N per group
WITH ranked AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS row_num
    FROM employees e
)
SELECT *
FROM ranked
WHERE row_num <= 3;


-- PATTERN 8: Running total
SELECT
    employee_id,
    salary,
    SUM(salary) OVER (
        ORDER BY employee_id
    ) AS running_total
FROM employees;


-- PATTERN 9: Previous row
SELECT
    employee_id,
    salary,
    LAG(salary) OVER (
        ORDER BY salary DESC
    ) AS previous_salary
FROM employees;


-- PATTERN 10: Department average
SELECT
    employee_id,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_average
FROM employees;


-- PATTERN 11: Conditional logic
SELECT
    employee_id,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 70000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;


-- PATTERN 12: NULL handling
SELECT
    employee_id,
    COALESCE(phone, email) AS contact
FROM employees;


-- PATTERN 13: Current date minus 5 years
SELECT *
FROM employees
WHERE hire_date >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR);


-- PATTERN 14: Employees with related records
SELECT e.*
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
);


-- PATTERN 15: Employees without related records
SELECT e.*
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s
    WHERE s.employee_id = e.employee_id
);


-- ============================================================
-- END OF 140 MYSQL INTERVIEW QUESTIONS
-- ============================================================
