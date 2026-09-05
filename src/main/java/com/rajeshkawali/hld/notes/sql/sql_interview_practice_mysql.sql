CREATE DATABASE IF NOT EXISTS sql_interview_practice;
USE sql_interview_practice;

-- Compatible with MySQL 8.0+.
-- Requires MySQL 8.0.16+ for enforced CHECK constraints.
-- Foreign-key checks are temporarily disabled only during cleanup.

/* ============================================================
   SQL INTERVIEW PRACTICE DATABASE
   Database: MySQL 8.0+
   Purpose : SQL Interview / Advanced Query Practice
   ============================================================ */


/* ============================================================
   1. CLEANUP
   ============================================================ */
DROP VIEW IF EXISTS employee_details;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS employee_salary_history;
DROP TABLE IF EXISTS employee_projects;
DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS employee_addresses;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS addresses;
DROP TABLE IF EXISTS jobs;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS companies;

SET FOREIGN_KEY_CHECKS = 1;


/* ============================================================
   2. COMPANIES
   ============================================================ */

CREATE TABLE companies (
    company_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_code     VARCHAR(20) NOT NULL UNIQUE,
    company_name     VARCHAR(100) NOT NULL,
    industry         VARCHAR(100),
    headquarters     VARCHAR(100),
    founded_year     INT CHECK (founded_year BETWEEN 1800 AND 2100),
    annual_revenue   DECIMAL(15,2) CHECK (annual_revenue >= 0),
    is_active        BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);


/* ============================================================
   3. DEPARTMENTS
   ============================================================ */

CREATE TABLE departments (
    department_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    company_id           BIGINT NOT NULL,
    department_code      VARCHAR(20) NOT NULL,
    department_name      VARCHAR(100) NOT NULL,
    department_head_id   BIGINT,
    location             VARCHAR(100),
    budget               DECIMAL(15,2) CHECK (budget >= 0),
    is_active             BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_department_company
        FOREIGN KEY (company_id)
        REFERENCES companies(company_id),

    CONSTRAINT uq_department_company_code
        UNIQUE (company_id, department_code),

    CONSTRAINT uq_department_company_name
        UNIQUE (company_id, department_name)
);


/* ============================================================
   4. JOBS
   ============================================================ */

CREATE TABLE jobs (
    job_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    job_code        VARCHAR(30) NOT NULL UNIQUE,
    job_title       VARCHAR(100) NOT NULL,
    job_level       VARCHAR(30) NOT NULL,
    min_salary      DECIMAL(12,2) CHECK (min_salary >= 0),
    max_salary      DECIMAL(12,2) CHECK (max_salary >= min_salary)
);


/* ============================================================
   5. ADDRESSES
   ============================================================ */

CREATE TABLE addresses (
    address_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    address_line1    VARCHAR(200) NOT NULL,
    address_line2    VARCHAR(200),
    city             VARCHAR(100) NOT NULL,
    state            VARCHAR(100),
    postal_code      VARCHAR(20),
    country          VARCHAR(100) NOT NULL DEFAULT 'India',
    address_type     VARCHAR(30) NOT NULL DEFAULT 'HOME',
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_address_type
        CHECK (address_type IN ('HOME', 'OFFICE', 'MAILING'))
);


/* ============================================================
   6. EMPLOYEES
   ============================================================ */

CREATE TABLE employees (
    employee_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_code     VARCHAR(20) NOT NULL UNIQUE,
    first_name        VARCHAR(50) NOT NULL,
    last_name         VARCHAR(50) NOT NULL,
    email             VARCHAR(150) NOT NULL UNIQUE,
    phone             VARCHAR(30),
    date_of_birth     DATE,
    gender            VARCHAR(20),
    department_id     BIGINT NOT NULL,
    job_id            BIGINT NOT NULL,
    manager_id        BIGINT,
    address_id        BIGINT,
    salary            DECIMAL(12,2) NOT NULL CHECK (salary >= 0),
    hire_date         DATE NOT NULL,
    termination_date  DATE,
    employment_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE',
    performance_score DECIMAL(4,2),
    work_mode         VARCHAR(30) NOT NULL DEFAULT 'OFFICE',
    created_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_employee_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id),

    CONSTRAINT fk_employee_job
        FOREIGN KEY (job_id)
        REFERENCES jobs(job_id),

    CONSTRAINT fk_employee_manager
        FOREIGN KEY (manager_id)
        REFERENCES employees(employee_id),

    CONSTRAINT fk_employee_address
        FOREIGN KEY (address_id)
        REFERENCES addresses(address_id),

    CONSTRAINT chk_employee_status
        CHECK (
            employment_status IN
            ('ACTIVE', 'ON_LEAVE', 'RESIGNED', 'TERMINATED')
        ),

    CONSTRAINT chk_employee_work_mode
        CHECK (
            work_mode IN
            ('OFFICE', 'REMOTE', 'HYBRID')
        ),

    CONSTRAINT chk_employee_performance
        CHECK (
            performance_score IS NULL
            OR performance_score BETWEEN 0 AND 5
        ),

    CONSTRAINT chk_employee_dates
        CHECK (
            termination_date IS NULL
            OR termination_date >= hire_date
        )
);


/* ============================================================
   7. EMPLOYEE ADDRESS HISTORY
   ============================================================ */

CREATE TABLE employee_addresses (
    employee_address_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id         BIGINT NOT NULL,
    address_id          BIGINT NOT NULL,
    address_type        VARCHAR(30) NOT NULL,
    effective_from      DATE NOT NULL,
    effective_to        DATE,

    CONSTRAINT fk_employee_addresses_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    CONSTRAINT fk_employee_addresses_address
        FOREIGN KEY (address_id)
        REFERENCES addresses(address_id),

    CONSTRAINT chk_employee_address_type
        CHECK (
            address_type IN ('HOME', 'MAILING', 'OFFICE')
        ),

    CONSTRAINT chk_employee_address_dates
        CHECK (
            effective_to IS NULL
            OR effective_to >= effective_from
        )
);


/* ============================================================
   8. SALARY HISTORY
   ============================================================ */

CREATE TABLE employee_salary_history (
    salary_history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id       BIGINT NOT NULL,
    old_salary        DECIMAL(12,2),
    new_salary        DECIMAL(12,2) NOT NULL,
    effective_date    DATE NOT NULL,
    change_reason     VARCHAR(100),
    changed_by        BIGINT,

    CONSTRAINT fk_salary_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    CONSTRAINT fk_salary_changed_by
        FOREIGN KEY (changed_by)
        REFERENCES employees(employee_id),

    CONSTRAINT chk_old_salary
        CHECK (old_salary IS NULL OR old_salary >= 0),

    CONSTRAINT chk_new_salary
        CHECK (new_salary >= 0)
);


/* ============================================================
   9. PROJECTS
   ============================================================ */

CREATE TABLE projects (
    project_id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    project_code     VARCHAR(30) NOT NULL UNIQUE,
    project_name     VARCHAR(150) NOT NULL,
    department_id    BIGINT,
    project_manager_id BIGINT,
    start_date       DATE NOT NULL,
    end_date         DATE,
    budget           DECIMAL(15,2) CHECK (budget >= 0),
    project_status   VARCHAR(30) NOT NULL DEFAULT 'PLANNED',

    CONSTRAINT fk_project_department
        FOREIGN KEY (department_id)
        REFERENCES departments(department_id),

    CONSTRAINT fk_project_manager
        FOREIGN KEY (project_manager_id)
        REFERENCES employees(employee_id),

    CONSTRAINT chk_project_status
        CHECK (
            project_status IN
            ('PLANNED', 'ACTIVE', 'COMPLETED', 'CANCELLED')
        ),

    CONSTRAINT chk_project_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        )
);


/* ============================================================
   10. EMPLOYEE PROJECT ASSIGNMENTS
   ============================================================ */

CREATE TABLE employee_projects (
    employee_id       BIGINT NOT NULL,
    project_id        BIGINT NOT NULL,
    role_name         VARCHAR(100),
    allocation_pct    DECIMAL(5,2) CHECK (allocation_pct > 0 AND allocation_pct <= 100),
    assigned_date     DATE NOT NULL,
    released_date     DATE,

    PRIMARY KEY (employee_id, project_id),

    CONSTRAINT fk_ep_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    CONSTRAINT fk_ep_project
        FOREIGN KEY (project_id)
        REFERENCES projects(project_id),

    CONSTRAINT chk_assignment_dates
        CHECK (
            released_date IS NULL
            OR released_date >= assigned_date
        )
);


/* ============================================================
   11. SALES
   ============================================================ */

CREATE TABLE sales (
    sale_id          BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id      BIGINT NOT NULL,
    sale_date        DATE NOT NULL,
    customer_name    VARCHAR(150) NOT NULL,
    product_name     VARCHAR(150) NOT NULL,
    region           VARCHAR(50),
    quantity         INT NOT NULL CHECK (quantity > 0),
    amount           DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    sales_status     VARCHAR(30) NOT NULL DEFAULT 'COMPLETED',
    created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sales_employee
        FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id),

    CONSTRAINT chk_sales_status
        CHECK (
            sales_status IN
            ('COMPLETED', 'PENDING', 'CANCELLED', 'REFUNDED')
        )
);


/* ============================================================
   12. INSERT COMPANIES
   ============================================================ */

INSERT INTO companies
(company_code, company_name, industry, headquarters, founded_year, annual_revenue)
VALUES
('TECH01', 'TechNova Solutions', 'Technology', 'Mumbai', 2012, 850000000),
('FIN01',  'Global Finance Corp', 'Financial Services', 'Bangalore', 2005, 1250000000),
('RETL01', 'Urban Retail Pvt Ltd', 'Retail', 'Delhi', 2010, 640000000),
('HLTH01', 'HealthFirst Systems', 'Healthcare', 'Pune', 2015, 430000000),
('CONS01', 'Apex Consulting Group', 'Consulting', 'Hyderabad', 2008, 720000000);


/* ============================================================
   13. INSERT DEPARTMENTS
   ============================================================ */

INSERT INTO departments
(company_id, department_code, department_name, location, budget)
VALUES
(1, 'ENG', 'Engineering', 'Mumbai', 25000000),
(1, 'SAL', 'Sales', 'Delhi', 18000000),
(1, 'HR',  'Human Resources', 'Mumbai', 8000000),
(1, 'FIN', 'Finance', 'Bangalore', 12000000),
(1, 'MKT', 'Marketing', 'Pune', 15000000),

(2, 'IT',  'Technology', 'Bangalore', 30000000),
(2, 'RISK','Risk Management', 'Bangalore', 14000000),
(3, 'OPS', 'Operations', 'Delhi', 20000000),
(4, 'MED', 'Medical Operations', 'Pune', 22000000),
(5, 'CON', 'Consulting', 'Hyderabad', 17000000),

-- Intentionally empty department for LEFT JOIN / NOT EXISTS practice
(1, 'LEG', 'Legal', 'Mumbai', 6000000);


/* ============================================================
   14. INSERT JOBS
   ============================================================ */

INSERT INTO jobs
(job_code, job_title, job_level, min_salary, max_salary)
VALUES
('ENG_MGR', 'Engineering Manager', 'MANAGER', 100000, 180000),
('SR_DEV',  'Senior Developer', 'SENIOR', 80000, 140000),
('DEV',     'Developer', 'MID', 60000, 100000),
('JR_DEV',  'Junior Developer', 'JUNIOR', 40000, 70000),
('SAL_MGR', 'Sales Manager', 'MANAGER', 90000, 160000),
('SAL_EXEC','Sales Executive', 'MID', 50000, 90000),
('HR_MGR',  'HR Manager', 'MANAGER', 80000, 140000),
('HR_EXEC', 'HR Executive', 'MID', 50000, 80000),
('FIN_MGR', 'Finance Manager', 'MANAGER', 90000, 150000),
('ACCOUNTANT','Accountant', 'MID', 55000, 90000),
('MKT_MGR', 'Marketing Manager', 'MANAGER', 85000, 145000),
('MKT_EXEC','Marketing Executive', 'MID', 55000, 90000);


/* ============================================================
   15. INSERT ADDRESSES
   ============================================================ */

INSERT INTO addresses
(address_line1, address_line2, city, state, postal_code, country, address_type)
VALUES
('12 Marine Drive', NULL, 'Mumbai', 'Maharashtra', '400020', 'India', 'HOME'),
('45 Powai Lake Road', 'Flat 402', 'Mumbai', 'Maharashtra', '400076', 'India', 'HOME'),
('78 Andheri East', NULL, 'Mumbai', 'Maharashtra', '400069', 'India', 'HOME'),
('23 Connaught Place', NULL, 'New Delhi', 'Delhi', '110001', 'India', 'HOME'),
('91 Saket Road', 'Block B', 'New Delhi', 'Delhi', '110017', 'India', 'HOME'),
('17 Whitefield Main Road', NULL, 'Bangalore', 'Karnataka', '560066', 'India', 'HOME'),
('56 Koramangala', 'Apartment 901', 'Bangalore', 'Karnataka', '560034', 'India', 'HOME'),
('88 Indiranagar', NULL, 'Bangalore', 'Karnataka', '560038', 'India', 'HOME'),
('31 Koregaon Park', NULL, 'Pune', 'Maharashtra', '411001', 'India', 'HOME'),
('64 Baner Road', NULL, 'Pune', 'Maharashtra', '411045', 'India', 'HOME'),
('11 Banjara Hills', NULL, 'Hyderabad', 'Telangana', '500034', 'India', 'HOME'),
('29 Hitech City', 'Tower 4', 'Hyderabad', 'Telangana', '500081', 'India', 'HOME'),
('102 Viman Nagar', NULL, 'Pune', 'Maharashtra', '411014', 'India', 'HOME'),
('7 Thane West', NULL, 'Thane', 'Maharashtra', '400601', 'India', 'HOME'),
('54 Navi Mumbai', NULL, 'Navi Mumbai', 'Maharashtra', '400703', 'India', 'HOME'),
('19 Gurgaon Sector 44', NULL, 'Gurgaon', 'Haryana', '122003', 'India', 'HOME'),
('82 Noida Sector 18', NULL, 'Noida', 'Uttar Pradesh', '201301', 'India', 'HOME'),
('35 Salt Lake', NULL, 'Kolkata', 'West Bengal', '700091', 'India', 'HOME'),
('40 Adyar', NULL, 'Chennai', 'Tamil Nadu', '600020', 'India', 'HOME'),
('26 HSR Layout', NULL, 'Bangalore', 'Karnataka', '560102', 'India', 'HOME');


/* ============================================================
   16. INSERT EMPLOYEES
   ------------------------------------------------------------
   IMPORTANT:
   Managers must be inserted before employees who reference them.
   ============================================================ */


/* -------------------------
   LEVEL 1 MANAGERS
   ------------------------- */

INSERT INTO employees
(employee_code, first_name, last_name, email, phone,
 date_of_birth, gender, department_id, job_id, manager_id,
 address_id, salary, hire_date, employment_status,
 performance_score, work_mode)
VALUES
('EMP001', 'Alice', 'Sharma', 'alice.sharma@technova.com',
 '9000000001', '1985-02-15', 'FEMALE',
 1, 1, NULL, 1, 120000, '2018-01-15',
 'ACTIVE', 4.70, 'HYBRID'),

('EMP005', 'Eva', 'Patel', 'eva.patel@technova.com',
 '9000000005', '1984-08-20', 'FEMALE',
 2, 5, NULL, 5, 110000, '2019-08-12',
 'ACTIVE', 4.50, 'OFFICE'),

('EMP009', 'Ivy', 'Mehta', 'ivy.mehta@technova.com',
 '9000000009', '1987-09-10', 'FEMALE',
 3, 7, NULL, 9, 80000, '2020-09-15',
 'ACTIVE', 4.20, 'HYBRID'),

('EMP011', 'Karen', 'Rao', 'karen.rao@technova.com',
 '9000000011', '1982-05-22', 'FEMALE',
 4, 9, NULL, 11, 105000, '2018-05-22',
 'ACTIVE', 4.60, 'OFFICE'),

('EMP013', 'Mia', 'Kapoor', 'mia.kapoor@technova.com',
 '9000000013', '1986-02-20', 'FEMALE',
 5, 11, NULL, 13, 95000, '2021-02-20',
 'ACTIVE', 4.10, 'REMOTE');


/* -------------------------
   LEVEL 2 EMPLOYEES
   ------------------------- */

INSERT INTO employees
(employee_code, first_name, last_name, email, phone,
 date_of_birth, gender, department_id, job_id, manager_id,
 address_id, salary, hire_date, employment_status,
 performance_score, work_mode)
VALUES
('EMP002', 'Bob', 'Verma', 'bob.verma@technova.com',
 '9000000002', '1988-03-11', 'MALE',
 1, 2, 1, 2, 90000, '2021-03-10',
 'ACTIVE', 4.40, 'HYBRID'),

('EMP003', 'Charlie', 'Singh', 'charlie.singh@technova.com',
 '9000000003', '1990-06-25', 'MALE',
 1, 3, 1, 3, 85000, '2022-06-20',
 'ACTIVE', 4.00, 'REMOTE'),

('EMP006', 'Frank', 'Joshi', 'frank.joshi@technova.com',
 '9000000006', '1992-01-10', 'MALE',
 2, 6, 5, 6, 70000, '2022-01-10',
 'ACTIVE', 4.30, 'OFFICE'),

('EMP007', 'Grace', 'Iyer', 'grace.iyer@technova.com',
 '9000000007', '1991-11-05', 'FEMALE',
 2, 6, 5, 7, 75000, '2021-11-05',
 'ACTIVE', 4.80, 'HYBRID'),

('EMP008', 'Henry', 'Das', 'henry.das@technova.com',
 '9000000008', '1993-07-01', 'MALE',
 2, 6, 5, 8, 65000, '2023-07-01',
 'ACTIVE', 3.80, 'OFFICE'),

('EMP010', 'Jack', 'Nair', 'jack.nair@technova.com',
 '9000000010', '1994-04-18', 'MALE',
 3, 8, 9, 10, 60000, '2022-04-18',
 'ACTIVE', 3.90, 'REMOTE'),

('EMP012', 'Leo', 'Bose', 'leo.bose@technova.com',
 '9000000012', '1995-01-15', 'MALE',
 4, 10, 11, 12, 68000, '2023-01-15',
 'ACTIVE', 4.00, 'HYBRID'),

('EMP014', 'Nick', 'Malhotra', 'nick.malhotra@technova.com',
 '9000000014', '1992-08-10', 'MALE',
 5, 12, 13, 14, 72000, '2022-08-10',
 'ACTIVE', 3.70, 'REMOTE');


/* -------------------------
   LEVEL 3 EMPLOYEES
   ------------------------- */

INSERT INTO employees
(employee_code, first_name, last_name, email, phone,
 date_of_birth, gender, department_id, job_id, manager_id,
 address_id, salary, hire_date, employment_status,
 performance_score, work_mode)
VALUES
('EMP004', 'David', 'Kumar', 'david.kumar@technova.com',
 '9000000004', '1993-02-01', 'MALE',
 1, 3, 2, 4, 95000, '2023-02-01',
 'ACTIVE', 4.90, 'REMOTE'),

('EMP015', 'Olivia', 'Shah', 'olivia.shah@technova.com',
 '9000000015', '1996-05-12', 'FEMALE',
 1, 4, 2, 15, 60000, '2024-01-10',
 'ACTIVE', 4.10, 'REMOTE'),

('EMP016', 'Peter', 'Gupta', 'peter.gupta@technova.com',
 '9000000016', '1991-09-14', 'MALE',
 2, 6, 5, 16, 70000, '2020-04-15',
 'ON_LEAVE', 3.50, 'OFFICE'),

('EMP017', 'Rachel', 'Chopra', 'rachel.chopra@technova.com',
 '9000000017', '1990-12-22', 'FEMALE',
 3, 8, 9, 17, 60000, '2021-06-01',
 'ACTIVE', 4.20, 'HYBRID'),

('EMP018', 'Samir', 'Khan', 'samir.khan@technova.com',
 '9000000018', '1989-10-30', 'MALE',
 4, 10, 11, 18, 68000, '2020-10-05',
 'RESIGNED', 3.20, 'OFFICE'),

('EMP019', 'Tina', 'Thomas', 'tina.thomas@technova.com',
 '9000000019', '1995-03-18', 'FEMALE',
 5, 12, 13, 19, 72000, '2023-03-12',
 'ACTIVE', 4.40, 'HYBRID'),

('EMP020', 'Vikram', 'Sethi', 'vikram.sethi@technova.com',
 '9000000020', '1994-07-25', 'MALE',
 1, 3, 2, 20, 85000, '2022-11-20',
 'ACTIVE', NULL, 'REMOTE');


/* ============================================================
   17. DEPARTMENT HEADS
   ============================================================ */

UPDATE departments SET department_head_id = 1  WHERE department_id = 1;
UPDATE departments SET department_head_id = 5  WHERE department_id = 2;
UPDATE departments SET department_head_id = 9  WHERE department_id = 3;
UPDATE departments SET department_head_id = 11 WHERE department_id = 4;
UPDATE departments SET department_head_id = 13 WHERE department_id = 5;


/* ============================================================
   18. EMPLOYEE ADDRESS HISTORY
   ============================================================ */

INSERT INTO employee_addresses
(employee_id, address_id, address_type, effective_from, effective_to)
VALUES
(1,  1,  'HOME', '2018-01-15', NULL),
(2,  2,  'HOME', '2021-03-10', NULL),
(3,  3,  'HOME', '2022-06-20', NULL),
(4,  4,  'HOME', '2023-02-01', NULL),
(5,  5,  'HOME', '2019-08-12', NULL),
(6,  6,  'HOME', '2022-01-10', NULL),
(7,  7,  'HOME', '2021-11-05', NULL),
(8,  8,  'HOME', '2023-07-01', NULL),
(9,  9,  'HOME', '2020-09-15', NULL),
(10, 10, 'HOME', '2022-04-18', NULL),
(11, 11, 'HOME', '2018-05-22', NULL),
(12, 12, 'HOME', '2023-01-15', NULL),
(13, 13, 'HOME', '2021-02-20', NULL),
(14, 14, 'HOME', '2022-08-10', NULL),
(15, 15, 'HOME', '2024-01-10', NULL),
(16, 16, 'HOME', '2020-04-15', NULL),
(17, 17, 'HOME', '2021-06-01', NULL),
(18, 18, 'HOME', '2020-10-05', NULL),
(19, 19, 'HOME', '2023-03-12', NULL),
(20, 20, 'HOME', '2022-11-20', NULL);


/* ============================================================
   19. SALARY HISTORY
   ============================================================ */

INSERT INTO employee_salary_history
(employee_id, old_salary, new_salary, effective_date, change_reason, changed_by)
VALUES
(1,  100000, 120000, '2022-01-01', 'Promotion', 1),
(2,   80000,  90000, '2024-01-01', 'Annual Increment', 1),
(3,   75000,  85000, '2024-01-01', 'Annual Increment', 1),
(4,   85000,  95000, '2025-01-01', 'Performance Increase', 2),
(5,   95000, 110000, '2023-01-01', 'Promotion', 5),
(6,   60000,  70000, '2025-01-01', 'Annual Increment', 5),
(7,   65000,  75000, '2025-01-01', 'Annual Increment', 5),
(8,   60000,  65000, '2025-01-01', 'Annual Increment', 5),
(9,   70000,  80000, '2023-01-01', 'Promotion', 9),
(10,  55000,  60000, '2024-01-01', 'Annual Increment', 9),
(11,  90000, 105000, '2023-01-01', 'Promotion', 11),
(12,  60000,  68000, '2025-01-01', 'Annual Increment', 11),
(13,  85000,  95000, '2023-01-01', 'Promotion', 13),
(14,  65000,  72000, '2025-01-01', 'Annual Increment', 13),
(15,   NULL,  60000, '2024-01-10', 'Initial Salary', 2),
(16,  65000,  70000, '2024-01-01', 'Annual Increment', 5),
(17,  55000,  60000, '2024-01-01', 'Annual Increment', 9),
(18,  62000,  68000, '2023-01-01', 'Annual Increment', 11),
(19,  65000,  72000, '2025-01-01', 'Annual Increment', 13),
(20,  75000,  85000, '2025-01-01', 'Performance Increase', 2);


/* ============================================================
   20. PROJECTS
   ============================================================ */

INSERT INTO projects
(project_code, project_name, department_id, project_manager_id,
 start_date, end_date, budget, project_status)
VALUES
('PRJ001', 'Customer Portal', 1, 1,
 '2025-01-01', NULL, 5000000, 'ACTIVE'),

('PRJ002', 'Mobile Banking Platform', 1, 2,
 '2025-03-01', NULL, 8000000, 'ACTIVE'),

('PRJ003', 'Sales Analytics', 2, 5,
 '2025-06-01', NULL, 3500000, 'ACTIVE'),

('PRJ004', 'HR Automation', 3, 9,
 '2024-01-01', '2025-12-31', 1500000, 'COMPLETED'),

('PRJ005', 'Financial Reporting', 4, 11,
 '2025-01-15', NULL, 2500000, 'ACTIVE'),

('PRJ006', 'Marketing Campaign 2026', 5, 13,
 '2026-01-01', NULL, 4000000, 'ACTIVE'),

('PRJ007', 'Legacy Migration', 1, 2,
 '2024-01-01', '2025-06-30', 3000000, 'COMPLETED'),

('PRJ008', 'Data Warehouse', 1, 1,
 '2025-09-01', NULL, 10000000, 'ACTIVE'),

('PRJ009', 'Internal Audit', 4, 11,
 '2026-01-01', NULL, 1800000, 'PLANNED'),

('PRJ010', 'Brand Refresh', 5, 13,
 '2026-02-01', NULL, 2200000, 'ACTIVE');


/* ============================================================
   21. EMPLOYEE PROJECT ASSIGNMENTS
   ============================================================ */

INSERT INTO employee_projects
(employee_id, project_id, role_name, allocation_pct, assigned_date, released_date)
VALUES
(1,  1,  'Project Sponsor', 20, '2025-01-01', NULL),
(2,  1,  'Technical Lead', 70, '2025-01-01', NULL),
(3,  1,  'Developer', 80, '2025-01-15', NULL),
(4,  1,  'Developer', 100, '2025-02-01', NULL),

(2,  2,  'Technical Lead', 50, '2025-03-01', NULL),
(3,  2,  'Developer', 60, '2025-03-01', NULL),
(20, 2,  'Developer', 80, '2025-03-01', NULL),

(5,  3,  'Project Manager', 40, '2025-06-01', NULL),
(6,  3,  'Sales Analyst', 80, '2025-06-01', NULL),
(7,  3,  'Business Analyst', 70, '2025-06-01', NULL),
(8,  3,  'Sales Analyst', 60, '2025-07-01', NULL),

(9,  4,  'Project Manager', 40, '2024-01-01', '2025-12-31'),
(10, 4,  'HR Analyst', 80, '2024-01-01', '2025-12-31'),

(11, 5,  'Project Manager', 40, '2025-01-15', NULL),
(12, 5,  'Accountant', 70, '2025-01-15', NULL),
(18, 5,  'Accountant', 50, '2025-01-15', '2025-12-31'),

(13, 6,  'Project Manager', 30, '2026-01-01', NULL),
(14, 6,  'Marketing Executive', 80, '2026-01-01', NULL),
(19, 6,  'Marketing Executive', 70, '2026-01-01', NULL),

(2,  8,  'Architecture Lead', 30, '2025-09-01', NULL),
(3,  8,  'Data Engineer', 50, '2025-09-01', NULL),
(20, 8,  'Data Engineer', 70, '2025-09-01', NULL);


/* ============================================================
   22. SALES DATA
   ============================================================ */

INSERT INTO sales
(employee_id, sale_date, customer_name, product_name, region, quantity, amount, sales_status)
VALUES
(6,  '2026-01-05', 'Acme Corp',       'Enterprise License', 'NORTH',  2, 5000, 'COMPLETED'),
(6,  '2026-01-15', 'Beta Industries', 'Cloud Package',      'WEST',   1, 7000, 'COMPLETED'),
(6,  '2026-02-10', 'Gamma Ltd',       'Enterprise License', 'SOUTH',  3, 6000, 'COMPLETED'),

(7,  '2026-01-08', 'Delta Corp',      'Cloud Package',      'WEST',   2, 8000, 'COMPLETED'),
(7,  '2026-02-12', 'Omega Ltd',       'Enterprise License', 'NORTH',  3, 9000, 'COMPLETED'),

(8,  '2026-01-20', 'Zenith Corp',     'Basic License',      'EAST',   5, 4000, 'COMPLETED'),
(8,  '2026-02-05', 'Alpha Ltd',       'Basic License',      'WEST',   6, 4500, 'COMPLETED'),

(2,  '2026-01-12', 'Tech Corp',       'Consulting',         'WEST',   1, 3000, 'COMPLETED'),
(3,  '2026-02-15', 'Startup Inc',     'Consulting',         'NORTH',  1, 2500, 'COMPLETED'),

(14, '2026-02-20', 'MarketOne',       'Campaign Package',   'WEST',   2, 5500, 'COMPLETED'),

(6,  '2026-03-01', 'Retail Corp',     'Cloud Package',      'NORTH',  2, 7500, 'COMPLETED'),
(7,  '2026-03-03', 'Finance Ltd',     'Enterprise License', 'SOUTH',  1, 9500, 'COMPLETED'),
(7,  '2026-03-15', 'Health Corp',     'Cloud Package',      'EAST',   2, 6500, 'PENDING'),

(8,  '2026-03-18', 'Retail Ltd',      'Basic License',      'WEST',   4, 3000, 'COMPLETED'),

(6,  '2026-04-01', 'Global Corp',     'Enterprise License', 'NORTH',  1, 11000, 'COMPLETED'),
(7,  '2026-04-05', 'Mega Industries', 'Cloud Package',      'SOUTH',  3, 10000, 'COMPLETED'),

(2,  '2026-04-10', 'Digital Ltd',     'Consulting',         'WEST',   2, 4500, 'COMPLETED'),
(3,  '2026-04-15', 'Cloud Corp',      'Consulting',         'NORTH',  1, 3500, 'COMPLETED'),

(14, '2026-04-20', 'Brand Corp',      'Campaign Package',   'EAST',   2, 6000, 'COMPLETED'),
(19, '2026-05-01', 'Fashion Ltd',     'Campaign Package',   'WEST',   1, 5000, 'COMPLETED'),

(6,  '2026-05-05', 'Enterprise Ltd',  'Cloud Package',      'NORTH',  2, 9000, 'COMPLETED'),
(7,  '2026-05-10', 'Retail Group',    'Enterprise License', 'SOUTH',  1, 12000, 'COMPLETED'),
(8,  '2026-05-15', 'Local Corp',      'Basic License',      'EAST',   4, 3500, 'CANCELLED'),

(14, '2026-05-20', 'Media Ltd',       'Campaign Package',   'WEST',   2, 7000, 'COMPLETED'),

(6,  '2026-06-01', 'Bank Corp',       'Enterprise License', 'NORTH',  1, 15000, 'COMPLETED'),
(7,  '2026-06-05', 'Insurance Ltd',   'Cloud Package',      'SOUTH',  2, 8500, 'COMPLETED'),
(19, '2026-06-10', 'Travel Ltd',      'Campaign Package',   'WEST',   2, 6500, 'COMPLETED');


/* ============================================================
   23. TERMINATION DATA
   ============================================================ */

UPDATE employees
SET termination_date = '2026-02-28'
WHERE employee_id = 18;


/* ============================================================
   24. INDEXES
   ============================================================ */

CREATE INDEX idx_employees_department
    ON employees(department_id);

CREATE INDEX idx_employees_manager
    ON employees(manager_id);

CREATE INDEX idx_employees_salary
    ON employees(salary);

CREATE INDEX idx_employees_hire_date
    ON employees(hire_date);

CREATE INDEX idx_employees_status
    ON employees(employment_status);

CREATE INDEX idx_employees_department_salary
    ON employees(department_id, salary);

CREATE INDEX idx_sales_employee
    ON sales(employee_id);

CREATE INDEX idx_sales_date
    ON sales(sale_date);

CREATE INDEX idx_sales_employee_date
    ON sales(employee_id, sale_date);

CREATE INDEX idx_projects_department
    ON projects(department_id);

CREATE INDEX idx_employee_projects_project
    ON employee_projects(project_id);

CREATE INDEX idx_salary_history_employee_date
    ON employee_salary_history(employee_id, effective_date);


/* ============================================================
   25. USEFUL VIEW FOR INTERVIEWS
   ============================================================ */

CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.employee_id,
    e.employee_code,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    e.email,
    e.salary,
    e.hire_date,
    e.employment_status,
    e.work_mode,

    d.department_id,
    d.department_name,

    j.job_title,
    j.job_level,

    m.employee_id AS manager_id,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,

    c.company_id,
    c.company_name

FROM employees e

JOIN departments d
    ON e.department_id = d.department_id

JOIN jobs j
    ON e.job_id = j.job_id

JOIN companies c
    ON d.company_id = c.company_id

LEFT JOIN employees m
    ON e.manager_id = m.employee_id;


/* ============================================================
   26. VERIFICATION QUERIES
   ============================================================ */

SELECT 'companies' AS table_name, COUNT(*) AS row_count
FROM companies

UNION ALL

SELECT 'departments', COUNT(*)
FROM departments

UNION ALL

SELECT 'jobs', COUNT(*)
FROM jobs

UNION ALL

SELECT 'addresses', COUNT(*)
FROM addresses

UNION ALL

SELECT 'employees', COUNT(*)
FROM employees

UNION ALL

SELECT 'employee_addresses', COUNT(*)
FROM employee_addresses

UNION ALL

SELECT 'salary_history', COUNT(*)
FROM employee_salary_history

UNION ALL

SELECT 'projects', COUNT(*)
FROM projects

UNION ALL

SELECT 'employee_projects', COUNT(*)
FROM employee_projects

UNION ALL

SELECT 'sales', COUNT(*)
FROM sales;


/* ============================================================
   27. BASIC SANITY CHECK
   ============================================================ */

SELECT
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    d.department_name,
    j.job_title,
    e.salary,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name,
    c.company_name
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN jobs j
    ON e.job_id = j.job_id
JOIN companies c
    ON d.company_id = c.company_id
LEFT JOIN employees m
    ON e.manager_id = m.employee_id
ORDER BY e.employee_id;
