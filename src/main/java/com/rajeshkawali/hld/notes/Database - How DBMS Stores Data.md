# How DBMS Stores Data

## 1. High-Level View

A DBMS does not usually store every row as a separate file.

At a high level:

```text
Application
    ↓
DBMS
    ↓
Database Files
    ↓
Pages / Blocks
    ↓
Rows / Records
    ↓
Columns / Values
```

---

## 2. Data is Stored on Disk

The DBMS stores persistent data in database files on storage such as:

- SSD
- HDD
- Cloud/block storage

Conceptually:

```text
Database
│
├── Data Files
├── Indexes
├── Transaction / Log Files
└── Metadata
```

The exact file organization depends on the database engine.

---

## 3. Data is Organized into Pages

The DBMS usually divides data into fixed-size units called **pages** or **blocks**.

Conceptually:

```text
Database File

+---------+---------+---------+---------+
| Page 1  | Page 2  | Page 3  | Page 4  |
+---------+---------+---------+---------+
```

A page can contain multiple rows.

For example:

```text
Page 1
--------------------------------
Row 1 → 1, Alice, 25
Row 2 → 2, Bob, 30
Row 3 → 3, Charlie, 28
--------------------------------

Page 2
--------------------------------
Row 4 → 4, David, 35
Row 5 → 5, Emma, 27
--------------------------------
```

> Page size is database-engine specific. Do not assume every DBMS uses the same page size.

---

## 4. What is a Row?

Suppose we have:

```sql
CREATE TABLE users (
    id BIGINT,
    name VARCHAR(100),
    age INT
);
```

A row contains values for these columns:

```text
Row
--------------------------------
id     = 101
name   = Alice
age    = 25
--------------------------------
```

Internally, a database row contains more information than this simple representation, such as row metadata, offsets, null information, and variable-length data information.

---

# 5. How DBMS Reads Data

Suppose we execute:

```sql
SELECT *
FROM users
WHERE id = 101;
```

The DBMS needs to find the row containing:

```text
id = 101
```

There are two common possibilities.

---

## 6. Without an Index

If there is no useful index, the DBMS may perform a **table scan**.

Conceptually:

```text
Query
  ↓
Page 1 → Check rows
  ↓
Page 2 → Check rows
  ↓
Page 3 → Check rows
  ↓
...
  ↓
Page N → Check rows
  ↓
Find id = 101
```

This can be expensive for a large table.

For example:

```text
Table = 100 million rows

Query:
WHERE id = 101
```

The database may need to examine a large amount of data.

---

# 7. With an Index

Suppose we create:

```sql
CREATE INDEX idx_users_id
ON users(id);
```

Now the DBMS can use the index.

Conceptually:

```text
Query
  ↓
Index
  ↓
Find id = 101
  ↓
Find relevant row/page
  ↓
Read page
  ↓
Return row
```

Instead of scanning the entire table, the DBMS can use the index to find the relevant data more efficiently.

---

# 8. Where is the Index Stored?

Indexes are also stored persistently by the database.

Conceptually:

```text
Database
│
├── Table Data
│   ├── Page 1
│   ├── Page 2
│   └── Page 3
│
└── Index
    ├── Index Page 1
    ├── Index Page 2
    └── Index Page 3
```

For example:

```text
Index on user_id

user_id       → Row/Page information

101           → Page 20
102           → Page 45
103           → Page 51
```

The actual implementation depends on the database engine.

---

# 9. DBMS Uses RAM

The DBMS does not want to read from disk for every query.

It keeps frequently used database pages in memory.

This area is commonly called a **buffer pool** or **buffer cache**.

Conceptually:

```text
                RAM
        +-------------------+
        |   Buffer Pool     |
        |                   |
        |   Page 1          |
        |   Page 5          |
        |   Page 10         |
        +-------------------+
                 ↑
                 |
                DBMS
                 |
                 ↓
             Storage
```

---

# 10. Buffer Pool Hit

Suppose the required page is already in RAM.

```text
Query
  ↓
Buffer Pool
  ↓
Page Found
  ↓
Return Data
```

This is faster because the DBMS doesn't need to fetch the page from persistent storage.

---

# 11. Buffer Pool Miss

If the required page is not in RAM:

```text
Query
  ↓
Buffer Pool
  ↓
Page Not Found
  ↓
Read Page from Storage
  ↓
Put Page into Buffer Pool
  ↓
Return Data
```

So the DBMS tries to keep frequently accessed pages in memory.

---

# 12. What Happens During INSERT?

Suppose:

```sql
INSERT INTO users
VALUES (101, 'Alice', 25);
```

Conceptually:

```text
Application
     ↓
DBMS
     ↓
Find appropriate data page
     ↓
Modify page
     ↓
Update required indexes
     ↓
Write transaction/log information
     ↓
Persist data safely
```

The DBMS does not normally rewrite the entire table for one INSERT.

It modifies the relevant data structures/pages.

---

# 13. What Happens During UPDATE?

Suppose:

```sql
UPDATE users
SET age = 26
WHERE id = 101;
```

Conceptually:

```text
Find row
   ↓
Load relevant page
   ↓
Modify row
   ↓
Update affected indexes if necessary
   ↓
Record transaction/log information
   ↓
Persist changes
```

If the updated column is part of an index, the index may also need to be updated.

---

# 14. What Happens During DELETE?

Suppose:

```sql
DELETE FROM users
WHERE id = 101;
```

Conceptually:

```text
Find row
   ↓
Load page
   ↓
Mark/remove row
   ↓
Update indexes
   ↓
Write transaction/log information
   ↓
Persist changes
```

---

# 15. Transaction Log / WAL

The DBMS needs to protect data from crashes.

For example:

```text
UPDATE users
SET age = 26
WHERE id = 101;
```

The database needs to make sure that a crash doesn't leave the database in an inconsistent state.

Many databases use a concept called **Write-Ahead Logging (WAL)**.

Conceptually:

```text
Transaction
     ↓
Write log information
     ↓
Modify data page
     ↓
Persist safely
```

The log can be used during recovery after a crash.

---

# 16. Database Storage Architecture

A simplified view is:

```text
                    DBMS
                      |
        +-------------+-------------+
        |             |             |
     Tables        Indexes         Logs
        |             |             |
      Pages         Pages        Log Records
        |
      Rows
        |
     Columns
```

---

# 17. Complete Read Flow

For a query:

```sql
SELECT *
FROM users
WHERE id = 101;
```

A simplified flow is:

```text
Application
     ↓
DBMS
     ↓
Query Parser / Optimizer
     ↓
Execution Plan
     ↓
Index Lookup
     ↓
Find Data Page
     ↓
Buffer Pool
     ↓
Storage if page is not in memory
     ↓
Read Row
     ↓
Return Result
```

---

# 18. Complete Write Flow

For:

```sql
INSERT INTO users
VALUES (101, 'Alice', 25);
```

A simplified flow is:

```text
Application
     ↓
DBMS
     ↓
Parse Query
     ↓
Execute INSERT
     ↓
Find/modify data page
     ↓
Update indexes
     ↓
Write transaction/log information
     ↓
Persist safely
     ↓
Return success
```

---

# 19. Important Concepts to Remember

```text
Database
    ↓
Data Files
    ↓
Pages / Blocks
    ↓
Rows
    ↓
Columns
```

For performance:

```text
Application
    ↓
DBMS
    ↓
Buffer Pool (RAM)
    ↓
Pages
    ↓
Storage
```

For indexing:

```text
Query
    ↓
Index
    ↓
Find relevant row/page
    ↓
Read data
```

For reliability:

```text
Transaction
    ↓
Log / WAL
    ↓
Data Changes
    ↓
Recovery if failure occurs
```

---

# 20. DBMS Storage — Interview Answer

If the interviewer asks:

> How does a DBMS store data?

A good answer is:

> A DBMS stores persistent data in database files on storage. The data is organized into pages or blocks, and each page contains multiple records/rows. The DBMS uses a buffer pool in RAM to cache frequently accessed pages. Indexes are separate data structures that help locate rows efficiently. During writes, the DBMS also maintains transaction/log information to provide durability and enable recovery after failures.

---

# 21. Easy Mental Model

Remember:

```text
                DATABASE
                    |
          +---------+---------+
          |                   |
       TABLES              INDEXES
          |                   |
        PAGES               PAGES
          |                   |
        ROWS              INDEX ENTRIES
          |
       COLUMNS
```

And:

```text
               DBMS
                |
        +-------+-------+
        |               |
       RAM           STORAGE
        |               |
  Buffer Pool       DB Files
        |               |
       Pages          Pages
```

### Golden Rule

```text
Tables  → store actual data
Indexes → help find data
Pages   → storage units containing data
Buffer Pool → keeps frequently used pages in RAM
Logs/WAL → help provide durability and recovery
```