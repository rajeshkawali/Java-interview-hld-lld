# Database Indexing --- System Design & Interview Perspective

## 1. What is Database Indexing?

A **database index** is a data structure that helps the database find
rows faster without scanning the entire table.

### Simple analogy

Imagine a 1,000-page book.

Without an index:

> "Find the chapter about networking."

You may need to scan page by page.

With an index:

> Search the index → find the page number → jump directly to the
> relevant page.

A database index works in a similar way.

``` text
Without index
Query
  ↓
Scan many/all rows
  ↓
Find matching row
  ↓
Return result

With index
Query
  ↓
Search index
  ↓
Find row location
  ↓
Read required row
  ↓
Return result
```

------------------------------------------------------------------------

## 2. Why Do We Need Indexes?

Consider:

``` sql
SELECT *
FROM users
WHERE email = 'alice@example.com';
```

Suppose the `users` table has 100 million rows.

### Without an index

The database may have to check many rows:

``` text
User 1      → email doesn't match
User 2      → email doesn't match
User 3      → email doesn't match
...
User 100M   → email matches
```

This can be expensive.

### With an index

Create:

``` sql
CREATE INDEX idx_users_email
ON users(email);
```

Now the database can search the index for the email and locate the
matching row much more efficiently.

### Important

An index **usually improves reads**, but it also adds storage and write
overhead.

------------------------------------------------------------------------

# 3. Table Scan vs Index Lookup

## Full Table Scan

``` text
Query
  ↓
Read table pages
  ↓
Check rows
  ↓
Return matching rows
```

Approximate cost:

``` text
O(N)
```

where `N` is the number of rows/pages that must be examined.

## Index Lookup

``` text
Query
  ↓
Search index
  ↓
Find matching key
  ↓
Locate row
  ↓
Return result
```

For a typical B-tree index, lookup is approximately:

``` text
O(log N)
```

The exact cost depends on the database engine, index structure, data
distribution, caching, and query.

------------------------------------------------------------------------

# 4. Database Pages and Why Indexes Help

Databases generally read data from disk/storage in **pages or blocks**,
rather than reading one row at a time.

For example, conceptually:

``` text
Table

Page 1 → rows 1 - 100
Page 2 → rows 101 - 200
Page 3 → rows 201 - 300
...
```

A full scan may require reading many pages.

An index can narrow the search to a much smaller number of pages.

> Page size is database-engine dependent; don't assume every database
> uses 8 KB pages.

------------------------------------------------------------------------

# 5. B-Tree / B+Tree Index

The most common general-purpose database index is based on a **B-tree
family** structure.

Conceptually:

``` text
                 [50]
               /      \
           [20,30]   [70,90]
          /   |   \   /   |   \
        ...  ... ... ... ... ...
```

The tree remains balanced, so searching can be efficient.

Many database implementations use B+tree-style structures where actual
indexed entries are stored in leaf levels and leaf nodes can support
efficient ordered/range traversal.

### Why B-tree indexes are useful

They support:

-   Equality searches
-   Range searches
-   Sorting
-   Prefix-style searches
-   Many `ORDER BY` operations
-   Many join conditions

Example:

``` sql
WHERE age = 30
```

or:

``` sql
WHERE age > 30
```

or:

``` sql
WHERE created_at BETWEEN '2026-01-01' AND '2026-01-31'
```

------------------------------------------------------------------------

# 6. What Does an Index Store?

An index generally stores information similar to:

``` text
Indexed value → row location / row identifier
```

For example:

``` text
email                     → row location

alice@example.com         → row A
bob@example.com           → row B
charlie@example.com       → row C
```

The exact representation depends on the database engine and index type.

The database can first find the key in the index and then retrieve the
corresponding row.

------------------------------------------------------------------------

# 7. Covering Index

A **covering index** contains all the columns required by a query.

Suppose:

``` sql
SELECT name, age
FROM users
WHERE email = 'alice@example.com';
```

An index such as:

``` sql
CREATE INDEX idx_users_email_name_age
ON users(email, name, age);
```

may contain everything needed for the query.

Conceptually:

``` text
Index
-------------------------
email | name | age
-------------------------
alice | Alice| 25
bob   | Bob  | 30
```

The database may be able to answer the query directly from the index
without fetching the full table row.

### Benefit

``` text
Index → result
```

instead of:

``` text
Index → table row → result
```

This can reduce I/O.

The exact behavior is database-engine dependent.

------------------------------------------------------------------------

# 8. Common Types of Indexes

## 8.1 B-tree Index

General-purpose index.

Good for:

``` sql
=
>
<
>=
<=
BETWEEN
ORDER BY
```

Example:

``` sql
CREATE INDEX idx_users_age
ON users(age);
```

------------------------------------------------------------------------

## 8.2 Hash Index

Uses a hash-based structure.

Good for exact equality lookups:

``` sql
WHERE user_id = 123
```

Conceptually:

``` text
hash(123)
   ↓
bucket
   ↓
row
```

Hash indexes are generally not suitable for ordered/range operations
such as:

``` sql
WHERE age > 30
```

Support and behavior vary by database engine.

------------------------------------------------------------------------

## 8.3 Full-Text Index

Used for text-search workloads.

Example:

``` text
Search:
"distributed systems"
```

A full-text index is designed for searching words/tokens in large text
fields.

This is different from simply creating a normal B-tree index on a text
column.

------------------------------------------------------------------------

## 8.4 Spatial Index

Used for geographic/spatial data.

Example:

``` text
Find restaurants
within 5 km
of a location.
```

The specific spatial index type depends on the database.

------------------------------------------------------------------------

# 9. Single-Column Index

Index on one column:

``` sql
CREATE INDEX idx_users_email
ON users(email);
```

Useful for:

``` sql
SELECT *
FROM users
WHERE email = 'alice@example.com';
```

------------------------------------------------------------------------

# 10. Composite Index

A composite index contains multiple columns.

Example:

``` sql
CREATE INDEX idx_orders_user_status
ON orders(user_id, status);
```

This can help queries such as:

``` sql
SELECT *
FROM orders
WHERE user_id = 123
  AND status = 'PAID';
```

It may also help:

``` sql
WHERE user_id = 123
```

But whether it helps a query using only `status` depends on the index
structure and optimizer; with a normal B-tree composite index, the
column order matters greatly.

------------------------------------------------------------------------

# 11. Composite Index Column Order

This is one of the most important interview topics.

Suppose:

``` sql
CREATE INDEX idx_orders
ON orders(user_id, status, created_at);
```

Think of the index as being ordered by:

``` text
user_id
    ↓
status
    ↓
created_at
```

This is often useful for:

``` sql
WHERE user_id = ?
```

``` sql
WHERE user_id = ?
  AND status = ?
```

``` sql
WHERE user_id = ?
  AND status = ?
  AND created_at > ?
```

But it is generally not equivalent to having an index beginning with
`status`.

### Leftmost-prefix idea

For:

``` text
(user_id, status, created_at)
```

the useful prefixes are roughly:

``` text
(user_id)

(user_id, status)

(user_id, status, created_at)
```

A query using only:

``` text
status
```

cannot generally exploit the index as effectively as one starting with
`user_id`.

### Interview rule

> Put the columns that match your important query patterns first. Don't
> blindly follow a universal "high cardinality first" rule.

------------------------------------------------------------------------

# 12. Equality, Range, and Composite Indexes

Consider:

``` sql
CREATE INDEX idx_orders
ON orders(user_id, status, created_at);
```

Query:

``` sql
WHERE user_id = 10
  AND status = 'PAID'
  AND created_at > '2026-01-01'
```

This is a strong match because:

``` text
user_id     → equality
status      → equality
created_at  → range
```

A common index-design heuristic is:

``` text
Equality predicates
        ↓
Range / ordering columns
```

But actual index design should be based on real query patterns and the
database optimizer.

------------------------------------------------------------------------

# 13. Cardinality

**Cardinality** describes how many distinct values a column has.

Example:

``` text
gender:
M
F
```

Low cardinality.

``` text
user_id:
1
2
3
4
...
100,000,000
```

High cardinality.

### Why does cardinality matter?

Suppose:

``` sql
WHERE gender = 'M'
```

If 50% of the table is male, an index may not provide much benefit for
some workloads because a huge portion of the rows still need to be
processed.

But:

``` sql
WHERE user_id = 12345678
```

may identify only one row.

### Important

Cardinality alone does not determine whether an index should exist.

The optimizer considers:

-   Selectivity
-   Table size
-   Query cost
-   Statistics
-   Data distribution
-   Available indexes
-   Query shape
-   Cached data
-   Database engine behavior

------------------------------------------------------------------------

# 14. Selectivity

**Selectivity** describes how narrowly a condition filters the data.

Example:

``` sql
WHERE user_id = 123
```

If only one row matches:

``` text
Very selective
```

Example:

``` sql
WHERE country = 'India'
```

If 20% of the table matches:

``` text
Less selective
```

Indexes are often most useful when predicates significantly reduce the
amount of data that must be examined.

------------------------------------------------------------------------

# 15. Clustered vs Non-Clustered Index

The exact behavior is database-engine specific.

## Clustered Index

A clustered index determines how table data is physically/logically
organized around the index key, depending on the engine.

Conceptually:

``` text
Index
  ↓
Data organized around index key
```

There is typically one primary clustered organization per table in
engines that support this model.

## Non-Clustered Index

A separate index structure points toward the table's rows.

Conceptually:

``` text
Index
  ↓
Row identifier
  ↓
Table row
```

### Interview answer

> Clustered indexes organize the table's data around the indexed key,
> while non-clustered indexes are separate structures that reference the
> underlying rows. The exact implementation differs between database
> engines.

------------------------------------------------------------------------

# 16. Primary Key and Index

In many relational databases, a primary key is backed by an index or a
primary index structure.

Example:

``` sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY,
    name VARCHAR(100)
);
```

The primary key allows efficient lookup:

``` sql
SELECT *
FROM users
WHERE id = 123;
```

A primary key also enforces uniqueness.

------------------------------------------------------------------------

# 17. Unique Index

A unique index prevents duplicate values.

Example:

``` sql
CREATE UNIQUE INDEX idx_users_email
ON users(email);
```

Now two users cannot have the same email, subject to the database's NULL
semantics.

It provides:

``` text
Uniqueness constraint
+
Fast lookup
```

------------------------------------------------------------------------

# 18. Indexes and WHERE

Indexes are commonly used for filtering.

Example:

``` sql
SELECT *
FROM orders
WHERE user_id = 123;
```

Index:

``` sql
CREATE INDEX idx_orders_user_id
ON orders(user_id);
```

Conceptually:

``` text
user_id = 123
      ↓
Index lookup
      ↓
Matching order rows
```

------------------------------------------------------------------------

# 19. Indexes and JOIN

Indexes can make joins much faster.

Suppose:

``` sql
SELECT *
FROM users u
JOIN orders o
  ON u.id = o.user_id
WHERE u.id = 123;
```

An index on:

``` sql
orders(user_id)
```

can help find the relevant orders efficiently.

Example:

``` sql
CREATE INDEX idx_orders_user_id
ON orders(user_id);
```

### Interview rule

> Columns frequently used to join large tables are strong candidates for
> indexing.

------------------------------------------------------------------------

# 20. Indexes and ORDER BY

Consider:

``` sql
SELECT *
FROM orders
WHERE user_id = 123
ORDER BY created_at DESC
LIMIT 20;
```

A useful composite index may be:

``` sql
CREATE INDEX idx_orders_user_created
ON orders(user_id, created_at);
```

This can potentially help with both:

``` text
WHERE user_id = 123
```

and:

``` text
ORDER BY created_at
```

The optimizer and database engine determine the actual execution plan.

------------------------------------------------------------------------

# 21. Indexes and GROUP BY

Indexes can sometimes help grouping or aggregation by providing data in
a useful order.

Example:

``` sql
SELECT status, COUNT(*)
FROM orders
GROUP BY status;
```

An index on:

``` sql
status
```

may sometimes help, but this is highly dependent on:

-   Database engine
-   Query plan
-   Table size
-   Distribution
-   Cost of scanning the index vs table

Don't assume an index automatically makes every `GROUP BY` faster.

------------------------------------------------------------------------

# 22. Range Queries

B-tree indexes are especially useful for ordered ranges.

Example:

``` sql
SELECT *
FROM orders
WHERE created_at >= '2026-01-01'
  AND created_at < '2026-02-01';
```

Index:

``` sql
CREATE INDEX idx_orders_created_at
ON orders(created_at);
```

Conceptually:

``` text
Index

2025-12-01
2025-12-15
2026-01-01  ← start
2026-01-05
2026-01-15
2026-01-31  ← end
2026-02-01
...
```

The database can traverse the relevant range instead of checking every
row.

------------------------------------------------------------------------

# 23. LIKE and Indexes

Consider:

``` sql
WHERE name LIKE 'Ali%'
```

A B-tree index may be useful for a prefix search, depending on database
and collation.

Example:

``` text
Ali%
```

can often use an ordered index.

But:

``` sql
WHERE name LIKE '%Ali%'
```

usually cannot efficiently use a normal B-tree index for the leading
wildcard.

For serious text-search workloads, consider a full-text/search engine
appropriate for the use case.

------------------------------------------------------------------------

# 24. Functions on Indexed Columns

Suppose we have:

``` sql
CREATE INDEX idx_users_email
ON users(email);
```

Query:

``` sql
SELECT *
FROM users
WHERE LOWER(email) = 'alice@example.com';
```

Depending on the database, applying a function to the indexed column may
prevent the normal index from being used efficiently.

A better approach can be:

-   Normalize/store the searchable value
-   Use a function/expression index if supported
-   Design the query and index together

Example conceptually:

``` sql
CREATE INDEX ...
ON users(LOWER(email));
```

The exact syntax is database-specific.

------------------------------------------------------------------------

# 25. Why Might the Database NOT Use an Index?

Having an index does **not** mean the database must use it.

Possible reasons:

### 1. Query returns too many rows

If:

``` sql
WHERE status = 'ACTIVE'
```

matches 80% of the table, scanning the table may be cheaper.

### 2. Small table

For a tiny table, a full scan can be faster than index traversal.

### 3. Poor selectivity

The indexed column may not filter enough rows.

### 4. Function/cast prevents efficient use

Example:

``` sql
WHERE LOWER(email) = ...
```

### 5. Statistics are outdated

The optimizer may make a poor choice if statistics don't reflect current
data.

### 6. Query pattern doesn't match the index

Example:

``` text
Index: (user_id, status)

Query:
WHERE status = ?
```

The index may not be the right access path.

### 7. Cost model

The optimizer chooses the plan it estimates to be cheapest.

------------------------------------------------------------------------

# 26. EXPLAIN

When debugging a slow query, use the database's execution-plan tools.

Example:

``` sql
EXPLAIN
SELECT *
FROM users
WHERE email = 'alice@example.com';
```

Depending on the database, you may also have:

``` sql
EXPLAIN ANALYZE
```

Look for concepts such as:

``` text
Table Scan / Sequential Scan
Index Scan
Index Seek
Rows examined
Rows returned
Estimated cost
Actual time
Join strategy
```

Exact terminology differs by database.

### Interview answer

> I would not assume an index is being used. I would inspect the
> execution plan with EXPLAIN/EXPLAIN ANALYZE and compare estimated vs
> actual work.

------------------------------------------------------------------------

# 27. Index Scan vs Table Scan

Suppose:

``` text
Table = 100 million rows
Query returns = 1 row
```

An index lookup is likely attractive.

But:

``` text
Table = 100 million rows
Query returns = 90 million rows
```

A table/sequence scan may be more efficient.

### Key idea

> An index is valuable when it reduces the amount of expensive work
> enough to justify using it.

------------------------------------------------------------------------

# 28. Indexes Increase Write Cost

Indexes are not free.

Suppose:

``` text
Table:
users

Indexes:
email
phone
username
created_at
country
status
```

When inserting a row, the database may need to update multiple indexes.

``` text
INSERT
  ↓
Update table
  ↓
Update email index
  ↓
Update phone index
  ↓
Update username index
  ↓
Update created_at index
  ↓
...
```

Therefore:

``` text
More indexes
    ↓
More storage
    ↓
More write work
    ↓
Potentially slower INSERT/UPDATE/DELETE
```

------------------------------------------------------------------------

# 29. UPDATE Can Also Be Expensive

Suppose:

``` sql
UPDATE users
SET email = 'new@example.com'
WHERE id = 123;
```

If `email` is indexed, the database may need to update the index entry.

So index overhead applies to:

-   INSERT
-   UPDATE
-   DELETE

------------------------------------------------------------------------

# 30. Advantages of Indexes

### 1. Faster reads

Especially for selective queries.

### 2. Faster lookups

Useful for:

``` sql
WHERE id = ?
WHERE email = ?
```

### 3. Faster joins

Indexes on join keys can reduce lookup work.

### 4. Faster sorting in some cases

Useful for compatible `ORDER BY` patterns.

### 5. Faster range queries

B-tree indexes are good for ordered ranges.

------------------------------------------------------------------------

# 31. Disadvantages of Indexes

### 1. Storage overhead

Indexes consume disk/memory resources.

### 2. Write overhead

INSERT/UPDATE/DELETE may become more expensive.

### 3. Maintenance overhead

Indexes need to be maintained as data changes.

### 4. Too many indexes can hurt performance

Don't index every column blindly.

### 5. Poorly designed indexes may provide little value

The index must match actual query patterns.

------------------------------------------------------------------------

# 32. Index vs Cache

They solve different problems.

## Index

``` text
Database
  ↓
Index
  ↓
Find data faster
```

The data is still retrieved from the database.

## Cache

``` text
Application
  ↓
Cache
  ↓
Return frequently used data
```

The application may avoid hitting the database entirely.

### Example

Without cache:

``` text
Request
  ↓
Application
  ↓
Database
  ↓
Index
  ↓
Data
```

With cache:

``` text
Request
  ↓
Application
  ↓
Cache HIT
  ↓
Data
```

### Interview answer

> Indexing optimizes database access; caching reduces database access.

------------------------------------------------------------------------

# 33. Index vs Partitioning

These are also different concepts.

## Indexing

Helps locate rows within a data set.

``` text
Table
  ↓
Index
  ↓
Matching rows
```

## Partitioning

Splits a large table into partitions.

Example:

``` text
orders

2024 → Partition A
2025 → Partition B
2026 → Partition C
```

Query:

``` sql
WHERE created_at >= '2026-01-01'
```

may only need to access the relevant partition(s), depending on the
partitioning scheme and optimizer.

### Can they be used together?

Yes.

Large systems commonly use:

``` text
Partitioning
+
Indexes
```

------------------------------------------------------------------------

# 34. Index vs Sharding

## Indexing

Optimizes lookup within a database/node.

## Sharding

Distributes data across multiple database nodes.

Example:

``` text
Application
    ↓
Shard router
    ├── Shard 1
    ├── Shard 2
    ├── Shard 3
    └── Shard 4
```

Then each shard can have its own indexes.

### Key idea

``` text
Index → find data faster
Sharding → distribute data
```

They solve different scaling problems.

------------------------------------------------------------------------

# 35. Indexes with Read Replicas

Suppose:

``` text
                Primary DB
                   |
        -----------------------
        |          |          |
     Replica 1  Replica 2  Replica 3
```

Read traffic can go to replicas.

Each replica generally needs the indexes required for the queries it
serves.

### Important

Adding replicas does not automatically fix a slow query.

If each replica executes:

``` text
Full table scan
```

the query may still be expensive.

A better architecture may combine:

``` text
Read replicas
+
Proper indexes
+
Caching
+
Query optimization
```

------------------------------------------------------------------------

# 36. Indexing in Distributed Databases

In distributed databases, indexes can be more complicated.

Suppose data is distributed:

``` text
Shard 1 → users 1-1M
Shard 2 → users 1M-2M
Shard 3 → users 2M-3M
```

A query by the shard key may be efficient:

``` sql
WHERE user_id = 123
```

But a query on another field may require checking multiple shards.

Example:

``` sql
WHERE email = 'alice@example.com'
```

If the database cannot determine the correct shard from `email`, it may
need a distributed lookup.

------------------------------------------------------------------------

# 37. Local vs Global Index

In distributed systems, indexes may conceptually be:

## Local index

Index exists separately on each shard.

``` text
Shard 1 → local index
Shard 2 → local index
Shard 3 → local index
```

A query may need to search multiple shards.

## Global index

A centralized/distributed index maps the search key to the relevant
shard/data.

``` text
Global index
     ↓
email → Shard 2
     ↓
Shard 2
```

This can make non-shard-key lookups efficient but introduces additional
complexity.

Exact implementations vary significantly across distributed databases.

------------------------------------------------------------------------

# 38. Indexing and Hotspots

Indexes can interact with write hotspots.

Suppose rows are inserted using increasing IDs:

``` text
1001
1002
1003
1004
1005
...
```

An index ordered by this key may repeatedly receive writes near the
newest end of the index.

Depending on the database and workload, this can contribute to
contention or hot regions.

Distributed systems may use techniques such as:

-   Better key distribution
-   UUID/ULID-like identifiers where appropriate
-   Time-sortable identifiers
-   Hash-based distribution
-   Sharding strategies

The right choice depends on the database and access pattern.

------------------------------------------------------------------------

# 39. Pagination and Indexing

This is a common system-design interview topic.

Suppose:

``` sql
SELECT *
FROM orders
ORDER BY id
LIMIT 50 OFFSET 1000000;
```

Large offsets can become expensive because the database may need to walk
past many rows before returning the requested page.

## Keyset / Cursor Pagination

Instead:

``` sql
SELECT *
FROM orders
WHERE id > :last_id
ORDER BY id
LIMIT 50;
```

With an appropriate index, this can be much more efficient for deep
pagination.

Conceptually:

``` text
Page 1:
id > 0
LIMIT 50

Page 2:
id > 50
LIMIT 50

Page 3:
id > 100
LIMIT 50
```

The real cursor should use the last returned key, not assume IDs are
perfectly consecutive.

------------------------------------------------------------------------

# 40. Index Design for a Large Orders Table

Suppose:

``` text
orders = 10 billion rows
```

Common queries:

``` sql
WHERE user_id = ?
```

``` sql
WHERE user_id = ?
AND status = ?
```

``` sql
WHERE user_id = ?
ORDER BY created_at DESC
LIMIT 20
```

Potential index:

``` sql
CREATE INDEX idx_orders_user_created
ON orders(user_id, created_at);
```

If the second query is extremely important:

``` sql
CREATE INDEX idx_orders_user_status_created
ON orders(user_id, status, created_at);
```

But don't create both automatically.

Ask:

-   Which queries are most frequent?
-   Which are latency-sensitive?
-   How many rows do they return?
-   What is the write rate?
-   How much storage can indexes consume?
-   Can one composite index serve multiple queries?
-   Is partitioning needed?
-   Is sharding needed?

------------------------------------------------------------------------

# 41. Indexing in a Read-Heavy System

Suppose:

``` text
Reads = 99%
Writes = 1%
```

Indexes are often very valuable.

You can potentially afford more indexes because:

``` text
Read performance
     ↓
Very important
```

while write overhead is relatively less important.

But still avoid unnecessary indexes.

A good design might be:

``` text
Application
   ↓
Cache
   ↓
Read replicas
   ↓
Well-designed indexes
   ↓
Database
```

------------------------------------------------------------------------

# 42. Indexing in a Write-Heavy System

Suppose:

``` text
Reads = 10%
Writes = 90%
```

Be more conservative.

Every extra index can increase write work.

Potential strategy:

``` text
Only important indexes
+
Batch writes where appropriate
+
Partitioning if needed
+
Queue/asynchronous processing where appropriate
```

The exact architecture depends on consistency and latency requirements.

------------------------------------------------------------------------

# 43. Partial / Filtered Indexes

Some databases support indexes that only include rows matching a
condition.

Conceptually:

``` sql
CREATE INDEX ...
ON orders(user_id)
WHERE status = 'ACTIVE';
```

This can be useful when only a subset of rows is frequently queried.

Example:

``` text
100M total orders
10M active orders
```

A filtered/partial index may avoid indexing all 100M rows.

Support and syntax are database-specific.

------------------------------------------------------------------------

# 44. Expression / Functional Indexes

Some databases allow indexes on expressions.

Example concept:

``` sql
CREATE INDEX ...
ON users(LOWER(email));
```

This can support queries such as:

``` sql
WHERE LOWER(email) = 'alice@example.com'
```

This is useful when queries consistently use a transformation.

Again, exact syntax and support vary by database.

------------------------------------------------------------------------

# 45. Common Indexing Mistakes

## Mistake 1: Index every column

Wrong because:

``` text
More indexes
→ More storage
→ More write cost
→ More maintenance
```

## Mistake 2: Ignore query patterns

Indexes should be designed around real access patterns.

## Mistake 3: Ignore column order

For composite indexes:

``` text
(a, b)
```

is not the same as:

``` text
(b, a)
```

## Mistake 4: Assume every index is used

Always check the execution plan.

## Mistake 5: Ignore write performance

Indexes help reads but can hurt writes.

## Mistake 6: Ignore data growth

An index that is fine for:

``` text
100K rows
```

may behave differently at:

``` text
1B rows
```

## Mistake 7: Ignore distributed architecture

A local index does not automatically solve a cross-shard query.

------------------------------------------------------------------------

# 46. Interview Scenario 1 --- Slow User Lookup

### Question

You have:

``` text
Users = 100 million
```

Query:

``` sql
SELECT *
FROM users
WHERE email = ?;
```

The query is slow. What do you do?

### Answer

First:

``` text
1. Check EXPLAIN / execution plan
2. Check whether email is indexed
3. Check selectivity/cardinality
4. Check rows examined
5. Check database load
6. Check whether the query is doing a full scan
```

If appropriate:

``` sql
CREATE INDEX idx_users_email
ON users(email);
```

Then re-check the execution plan and measure latency.

If email must be unique:

``` sql
CREATE UNIQUE INDEX idx_users_email
ON users(email);
```

------------------------------------------------------------------------

# 47. Interview Scenario 2 --- Query Uses user_id and status

### Question

You frequently run:

``` sql
SELECT *
FROM orders
WHERE user_id = ?
AND status = ?;
```

What index would you consider?

### Answer

A composite index:

``` sql
CREATE INDEX idx_orders_user_status
ON orders(user_id, status);
```

Why?

Because both query predicates match the beginning of the index.

If another frequent query is:

``` sql
WHERE user_id = ?
ORDER BY created_at DESC
LIMIT 20;
```

then an index such as:

``` sql
(user_id, created_at)
```

may be more useful for that access pattern.

### Interview lesson

> Index design should follow the workload, not just the table schema.

------------------------------------------------------------------------

# 48. Interview Scenario 3 --- Index Exists but Query Is Still Slow

### Question

There is already an index:

``` sql
CREATE INDEX idx_users_email
ON users(email);
```

But the query is slow.

What do you check?

### Answer

Check:

``` text
1. EXPLAIN / EXPLAIN ANALYZE
2. Is the index actually being used?
3. How many rows match?
4. Are statistics current?
5. Is there a function/cast on email?
6. Is the query returning many columns/rows?
7. Is the database under heavy load?
8. Is the index bloated/inefficient for the engine?
9. Is another plan cheaper?
10. Is the problem actually outside the database?
```

------------------------------------------------------------------------

# 49. Interview Scenario 4 --- Read-Heavy System

### Question

Your system has:

``` text
99% reads
1% writes
```

Would you use indexes?

### Answer

Yes, likely.

I would:

``` text
1. Identify top queries
2. Add indexes for important access patterns
3. Use composite indexes where appropriate
4. Consider covering indexes for hot queries
5. Use caching for very frequently requested data
6. Use read replicas if database read capacity is needed
7. Monitor write overhead and storage
```

------------------------------------------------------------------------

# 50. Interview Scenario 5 --- Write-Heavy System

### Question

Your database receives millions of writes per second.

Would you create many indexes?

### Answer

No.

Indexes improve reads but increase write cost.

I would:

``` text
1. Identify critical read queries
2. Keep only necessary indexes
3. Measure write latency
4. Consider partitioning/sharding
5. Use batching where appropriate
6. Monitor index storage and maintenance cost
```

The exact architecture depends on the database and consistency
requirements.

------------------------------------------------------------------------

# 51. Interview Scenario 6 --- 10 Billion Row Table

### Question

You have a 10-billion-row `orders` table.

Query:

``` sql
SELECT *
FROM orders
WHERE user_id = ?
ORDER BY created_at DESC
LIMIT 20;
```

How would you optimize it?

### Answer

I would first identify the access pattern.

A likely candidate is:

``` sql
CREATE INDEX idx_orders_user_created
ON orders(user_id, created_at);
```

Then:

``` text
Check execution plan
Measure latency
Measure index size
Check write overhead
```

At this scale I would also consider:

``` text
Partitioning
Sharding
Read replicas
Caching
Archival
Data retention
```

Indexing alone may not solve all scalability problems.

------------------------------------------------------------------------

# 52. Interview Scenario 7 --- Search with %keyword%

### Question

This query is slow:

``` sql
SELECT *
FROM products
WHERE name LIKE '%phone%';
```

You created a B-tree index on `name`, but it didn't help much. Why?

### Answer

Because the leading wildcard:

``` text
%phone%
```

does not provide a useful starting point for normal ordered B-tree
traversal.

For serious text search, consider:

``` text
Full-text indexing
or
Dedicated search engine
```

depending on the requirements.

------------------------------------------------------------------------

# 53. Interview Scenario 8 --- Slow Pagination

### Question

Why can this become expensive?

``` sql
SELECT *
FROM orders
ORDER BY id
LIMIT 50 OFFSET 5000000;
```

### Answer

The database may need to process/skip a large number of rows before
returning the requested page.

Use cursor/keyset pagination when appropriate:

``` sql
SELECT *
FROM orders
WHERE id > ?
ORDER BY id
LIMIT 50;
```

This works especially well when `id` is indexed and the pagination order
matches the index.

------------------------------------------------------------------------

# 54. Interview Scenario 9 --- Too Many Indexes

### Question

A developer created 15 indexes on a table.

Is that good?

### Answer

Not necessarily.

I would analyze:

``` text
1. Which queries use each index?
2. Are any indexes redundant?
3. Are some indexes overlapping?
4. How much storage do they consume?
5. How much write overhead do they create?
6. Which indexes are actually used?
```

Then remove unnecessary indexes carefully, after validating workload and
operational impact.

------------------------------------------------------------------------

# 55. Interview Scenario 10 --- Composite Index Ordering

### Question

You have:

``` text
Index:
(country, user_id)
```

Query:

``` sql
WHERE user_id = 123;
```

Will it be as effective as:

``` text
Index:
(user_id, country)
```

### Answer

Usually no.

With a normal B-tree composite index, the leading column is important.

If the important query is:

``` sql
WHERE user_id = ?
```

then:

``` text
(user_id, country)
```

is generally a better match.

------------------------------------------------------------------------

# 56. Interview Scenario 11 --- Query Suddenly Became Slow

### Question

A query was fast for months but suddenly became slow.

What could have happened?

### Possible reasons

``` text
1. Table grew significantly
2. Data distribution changed
3. Statistics became stale
4. Query plan changed
5. Index became less effective
6. Database load increased
7. Cache hit rate decreased
8. Lock/contention increased
9. Hardware/storage performance changed
10. Application query changed
```

Start with:

``` text
Execution plan
+
Actual query latency
+
Rows examined
+
Database metrics
```

------------------------------------------------------------------------

# 57. Interview Scenario 12 --- Covering Index

### Question

Query:

``` sql
SELECT name, age
FROM users
WHERE email = ?;
```

Could an index help more than just locating the row?

### Answer

Yes.

A covering index could contain:

``` text
email
name
age
```

Conceptually:

``` sql
(email, name, age)
```

Then the database may be able to return the result directly from the
index.

This can reduce table lookups.

------------------------------------------------------------------------

# 58. Indexing Strategy for System Design

When designing a system, follow this process.

## Step 1 --- Identify access patterns

Ask:

``` text
How will the data be queried?
```

Examples:

``` text
Get user by ID
Get user by email
Get orders by user
Get recent orders
Search products
Find nearby locations
```

## Step 2 --- Identify hot queries

Find:

``` text
High QPS queries
High latency queries
Business-critical queries
```

## Step 3 --- Design indexes

Create indexes that match those queries.

## Step 4 --- Check write cost

Ask:

``` text
How many writes per second?
```

## Step 5 --- Check data growth

Ask:

``` text
10M rows?
1B rows?
10B rows?
```

## Step 6 --- Check execution plans

Use:

``` text
EXPLAIN
EXPLAIN ANALYZE
```

where supported.

## Step 7 --- Monitor continuously

Track:

``` text
Query latency
CPU
I/O
Rows examined
Index usage
Storage
Write latency
Cache hit rate
```

------------------------------------------------------------------------

# 59. Practical Indexing Rules

### Rule 1

Index columns used frequently in:

``` text
WHERE
JOIN
ORDER BY
```

when the workload benefits.

### Rule 2

For composite indexes, think about:

``` text
query pattern
+
column order
```

### Rule 3

Do not create indexes blindly.

### Rule 4

Always verify with execution plans.

### Rule 5

Remember indexes increase write cost.

### Rule 6

Consider covering indexes for very hot read queries.

### Rule 7

For large tables, think beyond indexes:

``` text
Index
+
Partitioning
+
Caching
+
Read replicas
+
Sharding
```

### Rule 8

Optimize based on actual workload and measurements.

------------------------------------------------------------------------

# 60. Common Interview Questions

## Q1. What is a database index?

An index is a data structure that helps the database find rows
efficiently without scanning the entire table.

------------------------------------------------------------------------

## Q2. Why are indexes faster?

They provide an organized access path so the database can locate
relevant rows/pages without examining the whole table.

------------------------------------------------------------------------

## Q3. What is the most common index structure?

B-tree/B+tree-style structures are common for general-purpose relational
database indexing.

------------------------------------------------------------------------

## Q4. What is a composite index?

An index containing multiple columns.

Example:

``` text
(user_id, status, created_at)
```

------------------------------------------------------------------------

## Q5. Why does column order matter?

Because composite indexes are ordered according to their leading
columns. Queries that match the leftmost portion can generally use the
index more effectively.

------------------------------------------------------------------------

## Q6. What is cardinality?

The number of distinct values in a column.

------------------------------------------------------------------------

## Q7. What is selectivity?

How effectively a condition filters the data.

------------------------------------------------------------------------

## Q8. Can indexes slow down writes?

Yes.

INSERT, UPDATE, and DELETE operations may need to maintain indexes.

------------------------------------------------------------------------

## Q9. Does an index always make a query faster?

No.

The optimizer may choose a table scan if it estimates that to be
cheaper.

------------------------------------------------------------------------

## Q10. How do you know whether an index is being used?

Inspect the execution plan using tools such as:

``` sql
EXPLAIN
```

or:

``` sql
EXPLAIN ANALYZE
```

depending on the database.

------------------------------------------------------------------------

## Q11. Index vs cache?

``` text
Index → makes database lookup faster
Cache → avoids database lookup
```

------------------------------------------------------------------------

## Q12. Index vs partitioning?

``` text
Index → efficient access path
Partitioning → splits data into manageable pieces
```

They can be used together.

------------------------------------------------------------------------

## Q13. Index vs sharding?

``` text
Index → optimize lookup within a data set/node
Sharding → distribute data across nodes
```

------------------------------------------------------------------------

## Q14. Why might `LIKE '%abc%'` not use a normal B-tree efficiently?

Because the leading wildcard prevents the database from knowing a useful
starting point in the ordered index.

------------------------------------------------------------------------

## Q15. What is a covering index?

An index that contains all columns required to answer a query,
potentially avoiding a table lookup.

------------------------------------------------------------------------

# 61. Quick Recall Cheat Sheet

``` text
DATABASE INDEXING
=================

Index:
    Data structure for faster lookup.

Without index:
    Table scan
    O(N) approximately

B-tree:
    General-purpose
    Equality
    Range
    Ordering

Hash:
    Equality-focused
    Not ideal for range queries

Composite:
    Multiple columns
    Example: (user_id, status)

Important:
    Column order matters.

Leftmost prefix:
    (A, B, C)
    Good match:
        A
        A + B
        A + B + C
    Not equivalent to:
        B alone

Cardinality:
    Number of distinct values.

Selectivity:
    How much a predicate filters data.

Indexes help:
    WHERE
    JOIN
    ORDER BY
    Some GROUP BY patterns

Indexes cost:
    Storage
    INSERT overhead
    UPDATE overhead
    DELETE overhead

Covering index:
    Index contains everything query needs.

EXPLAIN:
    Check actual execution plan.

Index != Cache:
    Index → faster DB access
    Cache → fewer DB accesses

Index != Partition:
    Index → access path
    Partition → split data

Index != Sharding:
    Index → optimize lookup
    Sharding → distribute data

Large systems:
    Index
    + Cache
    + Replicas
    + Partitioning
    + Sharding

Golden rule:
    Design indexes from real query patterns,
    then verify with execution plans and metrics.
```

------------------------------------------------------------------------

# 62. One-Minute Interview Answer

If the interviewer asks:

> "How would you approach database indexing?"

A strong answer is:

> "I would first identify the most important query patterns and their
> read/write frequency. Then I would create indexes for selective
> `WHERE` conditions, join keys, and important ordering patterns. For
> multi-column queries, I would design composite indexes with the
> correct column order. I would also consider covering indexes for hot
> read queries. After adding an index, I would verify the execution plan
> using EXPLAIN and measure actual latency. Finally, I would consider
> the write and storage overhead, because indexes improve reads but add
> maintenance cost. For very large systems, I would combine indexing
> with caching, partitioning, read replicas, and sharding as needed."

------------------------------------------------------------------------

# 63. Final Takeaway

The most important thing to remember is:

``` text
Indexing is not:
"Add an index to every column."

Indexing is:
"Design the right access path for the queries
that matter most."
```

For system design interviews, think in this order:

``` text
Query pattern
      ↓
Selectivity
      ↓
Index type
      ↓
Composite column order
      ↓
Execution plan
      ↓
Read performance
      ↓
Write/storage cost
      ↓
Scale
```

That is the core database-indexing thought process.
