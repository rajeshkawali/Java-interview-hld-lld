# SQL vs NoSQL — Detailed System Design Interview Notes

## 1. Definition

### SQL

**SQL (Structured Query Language)** databases are usually **relational databases** that store data in **tables with rows and columns**.

Examples:

- PostgreSQL
- MySQL
- Oracle Database
- Microsoft SQL Server

Example:

```text
Users Table

+----+-------+-------------------+
| id | name  | email             |
+----+-------+-------------------+
| 1  | John  | john@gmail.com    |
| 2  | Alice | alice@gmail.com   |
+----+-------+-------------------+
```

---

### NoSQL

**NoSQL** databases are non-relational databases designed for flexible schemas, high scalability, and specific access patterns.

Examples:

- DynamoDB
- MongoDB
- Cassandra
- Redis
- HBase

Data can be stored as:

```text
Key → Value
Document
Column Family
Graph
```

Example document:

```json
{
  "id": 1,
  "name": "John",
  "email": "john@gmail.com",
  "orders": [
    {
      "orderId": 101,
      "amount": 500
    }
  ]
}
```

---

# 2. Simple Difference

### SQL

> **Structured data + relationships + strong transactions**

### NoSQL

> **Flexible data + horizontal scalability + high throughput**

Easy memory:

```text
SQL  → Tables + Relationships + JOIN + ACID
NoSQL → Flexible Schema + Scale + High Throughput
```

---

# 3. SQL Example

Suppose we have an e-commerce application.

We have:

```text
Users
Orders
Products
```

### Users

```text
id | name
---+------
1  | John
2  | Alice
```

### Orders

```text
order_id | user_id | amount
---------+---------+-------
101      | 1       | 500
102      | 1       | 800
103      | 2       | 300
```

`user_id` is a foreign key referring to the Users table.

Relationship:

```text
Users
  |
  | 1:N
  ↓
Orders
```

We can query:

```sql
SELECT users.name, orders.amount
FROM users
JOIN orders
ON users.id = orders.user_id
WHERE users.id = 1;
```

Result:

```text
John → 500
John → 800
```

---

# 4. NoSQL Example

In a document database such as MongoDB, we could store:

```json
{
  "userId": 1,
  "name": "John",
  "orders": [
    {
      "orderId": 101,
      "amount": 500
    },
    {
      "orderId": 102,
      "amount": 800
    }
  ]
}
```

Instead of performing a JOIN, the related data can be stored together when that matches the application's access pattern.

---

# 5. SQL Characteristics

SQL databases generally provide:

```text
Structured schema
Tables
Rows
Columns
Primary keys
Foreign keys
JOINs
Indexes
Transactions
ACID
```

Example:

```text
Users
  ↓
Orders
  ↓
Payments
```

SQL is very good when these relationships are important.

---

# 6. NoSQL Characteristics

NoSQL databases commonly provide:

```text
Flexible schema
Horizontal scaling
Distributed storage
High throughput
Low-latency access
Denormalized data
Partitioning
Replication
```

However, **NoSQL is not one single database model**. Different NoSQL databases have very different capabilities.

---

# 7. Types of NoSQL Databases

There are four common categories.

## 7.1 Key-Value

```text
key → value
```

Example:

```text
user:1001 → John
session:abc123 → user data
```

Examples:

- Redis
- DynamoDB (key-value/document model)

Good for:

- Cache
- Sessions
- Simple lookups

---

## 7.2 Document Database

Stores JSON-like documents.

Example:

```json
{
  "userId": 1001,
  "name": "John",
  "address": {
    "city": "Mumbai"
  }
}
```

Examples:

- MongoDB
- Couchbase

Good for:

- Product catalogs
- User profiles
- Content management

---

## 7.3 Wide-Column / Column-Family

Data is distributed using rows/partitions and column families.

Example:

```text
user_id | name | age | city
--------+------+-----+------
1001    | John | 30  | Mumbai
1002    | Alex | 28  | Delhi
```

Examples:

- Cassandra
- ScyllaDB
- HBase

Good for:

- Very large datasets
- High write throughput
- Time-series/event workloads
- Distributed applications

---

## 7.4 Graph Database

Stores:

```text
Nodes + Relationships
```

Example:

```text
John
 |
 | FRIEND_OF
 ↓
Alice
 |
 | WORKS_WITH
 ↓
Bob
```

Examples:

- Neo4j
- Amazon Neptune

Good for:

- Social networks
- Recommendation systems
- Fraud relationship analysis
- Network graphs

---

# 8. SQL vs NoSQL — Main Differences

| Feature | SQL | NoSQL |
|---|---|---|
| Data model | Relational | Key-value/document/column/graph |
| Schema | Usually predefined | Often flexible |
| Relationships | Strong support | Usually limited or application-managed |
| JOIN | Strong support | Often avoided |
| Transactions | Strong ACID support | Varies by database |
| Scaling | Often vertical + some horizontal options | Designed strongly around horizontal scaling |
| Data structure | Tables | Depends on database |
| Query language | SQL | Database-specific APIs/query languages |
| Best for | Relational/business data | Large-scale distributed workloads |
| Consistency | Often strong | Varies |
| Schema changes | More controlled | Often easier |
| Data duplication | Usually minimized | Often accepted |
| Read/write pattern | Flexible queries | Often access-pattern driven |
| Distributed design | Possible | Common/core design goal |
| Examples | PostgreSQL, MySQL | DynamoDB, MongoDB, Cassandra |

---

# 9. Schema Difference

## SQL — Fixed/Structured Schema

Suppose:

```sql
CREATE TABLE users (
    id INT,
    name VARCHAR(100),
    age INT,
    email VARCHAR(200)
);
```

Every row follows the defined structure.

```text
id | name | age | email
---+------+-----+----------------
1  | John | 30  | john@gmail.com
2  | Alice| 25  | alice@gmail.com
```

Schema changes usually require an explicit migration.

---

## NoSQL — Flexible Schema

Example:

```json
{
  "id": 1,
  "name": "John",
  "age": 30
}
```

Another document could be:

```json
{
  "id": 2,
  "name": "Alice",
  "email": "alice@gmail.com",
  "address": "Mumbai"
}
```

The documents don't necessarily need exactly the same fields.

### Advantage

Easy to evolve application data.

### Disadvantage

The application may need to handle schema differences.

---

# 10. Normalization vs Denormalization

## SQL → Normalization

We generally avoid unnecessary duplicate data.

Example:

```text
Users
+----+------+
| id | name |
+----+------+
| 1  | John |
+----+------+

Orders
+------+---------+--------+
| id   | user_id | amount |
+------+---------+--------+
| 101  | 1       | 500    |
+------+---------+--------+
```

Order stores:

```text
user_id = 1
```

instead of copying John's information into every order.

### Advantages

- Less duplication
- Better data consistency
- Easier updates

### Disadvantages

- More JOINs
- More complex read queries
- Potentially more read latency

---

# 11. NoSQL → Denormalization

We may store related data together.

Example:

```json
{
  "orderId": 101,
  "userId": 1,
  "userName": "John",
  "amount": 500
}
```

Now reading the order does not require a JOIN to retrieve the user name.

### Advantages

- Faster reads for known access patterns
- Fewer JOINs
- Good for distributed systems

### Disadvantages

- Duplicate data
- Updates become harder
- Data can become temporarily inconsistent

---

# 12. JOIN Difference

### SQL

JOIN is a core feature.

```sql
SELECT *
FROM users u
JOIN orders o
ON u.id = o.user_id;
```

Very useful for relational data.

---

### NoSQL

Many distributed NoSQL systems avoid cross-partition JOINs.

Instead, data is modeled around queries.

Example:

```text
Get all orders for user 123
```

We might partition/order the data by:

```text
partitionKey = userId
```

Then:

```text
userId = 123
     ↓
One partition / known partition set
     ↓
Orders
```

### Important

Don't say:

> "NoSQL cannot do JOINs."

That's too broad.

The correct statement is:

> **Many NoSQL databases either don't provide traditional JOINs or discourage cross-partition JOINs because distributed JOINs can be expensive.**

---

# 13. ACID Transactions

SQL databases are strongly associated with ACID transactions.

## A — Atomicity

All operations succeed or all fail.

Example:

```text
Transfer $100

Debit Account A
Credit Account B
```

If credit fails:

```text
Debit should not remain committed
```

---

## C — Consistency

Transaction moves the database from one valid state to another according to its constraints/business rules.

---

## I — Isolation

Concurrent transactions should not improperly interfere with each other.

---

## D — Durability

Once committed, data should survive failures according to the database's durability guarantees.

---

# 14. NoSQL Transactions

NoSQL does **not** mean "no transactions."

Modern NoSQL databases may support:

- Atomic operations
- Conditional writes
- Single-item transactions
- Multi-item transactions
- Optimistic concurrency

But transaction capabilities differ significantly between products.

Therefore:

> **Always check the specific NoSQL database's consistency and transaction model.**

---

# 15. Scaling

This is one of the most important interview differences.

## Vertical Scaling

Increase machine capacity.

```text
8 CPU
 ↓
32 CPU
 ↓
64 CPU
```

SQL databases can scale vertically very well.

---

## Horizontal Scaling

Add more machines.

```text
Node 1
Node 2
Node 3
Node 4
...
```

NoSQL systems are often designed around horizontal scaling.

Example:

```text
1 node
 ↓
10 nodes
 ↓
100 nodes
 ↓
1000 nodes
```

---

# 16. SQL Scaling

Traditional SQL architecture:

```text
                 Application
                     |
                     v
                 SQL DB
```

As traffic grows:

```text
                 Load Balancer
                  /         \
                 v           v
              App 1        App 2
                  \         /
                   \       /
                     SQL
```

Then introduce:

```text
Primary
   |
   +---- Replica 1
   |
   +---- Replica 2
```

Reads can be distributed to replicas.

For very large systems, SQL can also use:

- Sharding
- Partitioning
- Read replicas
- Caching
- Distributed SQL databases

So:

> **SQL does not mean "cannot scale horizontally."**

---

# 17. NoSQL Scaling

A common NoSQL architecture:

```text
             Application
                  |
                  v
             Router
                  |
       +----------+----------+
       |          |          |
       v          v          v
     Node A     Node B     Node C
       |          |          |
    Partition  Partition  Partition
```

Data is partitioned across nodes.

As traffic grows:

```text
Add Node D
      ↓
Rebalance
      ↓
More capacity
```

---

# 18. Consistency

## SQL

Traditional relational databases often provide strong transactional consistency.

Example:

```text
WRITE
 ↓
COMMIT
 ↓
READ
 ↓
Latest committed value
```

The exact behavior depends on the database and isolation level.

---

## NoSQL

Consistency varies.

Some systems support:

```text
Strong consistency
```

Others are commonly designed around:

```text
Eventual consistency
```

Some support both.

Example:

```text
Write → Node A

Replication

Node B → eventually receives update
Node C → eventually receives update
```

A read from B/C could temporarily return an older value in an eventually consistent design.

---

# 19. SQL Advantages

### 1. Strong relationships

Excellent for:

```text
Customer
   ↓
Orders
   ↓
Payments
```

### 2. ACID transactions

Useful for:

- Banking
- Payments
- Inventory
- Accounting

### 3. Powerful queries

SQL supports:

```text
JOIN
GROUP BY
ORDER BY
HAVING
Aggregations
Subqueries
Window functions
```

### 4. Data integrity

Features include:

```text
Primary Key
Foreign Key
Unique
NOT NULL
CHECK
```

### 5. Mature ecosystem

Many tools, monitoring systems, libraries, and experienced engineers support SQL.

---

# 20. SQL Disadvantages

### 1. Scaling can become complex

Very large workloads may require:

```text
Sharding
Read replicas
Partitioning
Caching
```

### 2. Schema changes require planning

Large schema migrations can be difficult.

### 3. JOIN-heavy workloads can become expensive at scale

Especially when data is distributed across shards.

### 4. Less natural for highly variable data

If every record has a very different structure, relational modeling may require more schema design.

---

# 21. NoSQL Advantages

### 1. Horizontal scalability

Designed for:

```text
Large traffic
Large datasets
Distributed workloads
```

### 2. Flexible schema

Good when data structure evolves frequently.

### 3. High throughput

Many NoSQL systems are optimized for very high read/write workloads.

### 4. Good availability

Replication across multiple nodes/data centers can provide high availability.

### 5. Access-pattern optimized design

You can model data around the queries your application performs.

---

# 22. NoSQL Disadvantages

### 1. Limited relationships in many systems

Complex relational queries may be difficult.

### 2. Data duplication

Denormalization can create duplicate information.

### 3. Consistency trade-offs

Some systems prioritize availability and partition tolerance with eventual consistency.

### 4. Query flexibility can be lower

Some NoSQL systems require you to know your access patterns in advance.

### 5. More application responsibility

The application may need to handle:

```text
Data duplication
Consistency
Retries
Conflict resolution
Reconciliation
```

depending on the database.

---

# 23. When Should I Use SQL?

Use SQL when you have:

```text
Strong relationships
Complex queries
JOINs
ACID transactions
Strong integrity requirements
Structured data
```

Examples:

### Banking

```text
Account
Transaction
Ledger
Customer
```

### E-commerce

```text
Orders
Payments
Inventory
Customers
```

### ERP

```text
Employees
Departments
Payroll
Invoices
```

---

# 24. When Should I Use NoSQL?

Use NoSQL when you need:

```text
Massive scale
High throughput
Low latency
Flexible schema
Distributed architecture
Simple/highly predictable access patterns
```

Examples:

### Session Store

```text
sessionId → sessionData
```

### Product Catalog

Different products can have different attributes.

```json
{
  "name": "Laptop",
  "ram": "16GB",
  "processor": "i7"
}
```

Another product:

```json
{
  "name": "T-Shirt",
  "size": "XL",
  "color": "Black"
}
```

### IoT

```text
deviceId
timestamp
temperature
humidity
```

Millions of devices can generate huge volumes of events.

---

# 25. SQL vs NoSQL Example — E-Commerce

Suppose Amazon-like system has:

```text
1 billion customers
10 billion orders
Millions of requests/sec
```

### SQL approach

Could use:

```text
SQL
+
Sharding
+
Read Replicas
+
Caching
+
Partitioning
```

This can work.

---

### NoSQL approach

Could use:

```text
NoSQL
+
Partitioning
+
Replication
+
Caching
+
Horizontal Scaling
```

For an access pattern such as:

```text
Get orders for customerId
```

we can partition by:

```text
customerId
```

This can provide scalable access.

### Important Interview Point

Don't say:

> "Amazon uses NoSQL because SQL cannot scale."

Instead say:

> "At very large scale, a workload may benefit from a distributed NoSQL database when its access patterns, availability, latency, and scaling requirements fit that database's model."

---

# 26. SQL vs NoSQL Decision Tree

```text
                Start
                  |
                  v
       Need complex relationships?
              /       \
            YES        NO
             |          |
             v          v
            SQL     Need massive
                   horizontal scale?
                       /      \
                     YES       NO
                      |         |
                      v         v
                    NoSQL    Evaluate both
```

But this is only a starting point.

Always consider:

```text
Access patterns
Consistency
Transactions
Scale
Latency
Availability
Operational complexity
Team expertise
Cost
```

---

# 27. Important Interview Scenario

### Question:

> "We are designing a payment system. SQL or NoSQL?"

Good answer:

> "I would lean toward a relational database because payments require strong transactional guarantees, integrity constraints, and relationships between accounts, transactions, and ledger entries. I would use techniques such as indexing, partitioning, read replicas where appropriate, and caching to scale it rather than choosing NoSQL only because of scale."

---

# 28. Another Interview Scenario

### Question:

> "Design a user session store for millions of users."

Good answer:

> "I would consider a key-value NoSQL database because the access pattern is primarily a simple lookup by session ID, and we need high throughput, low latency, horizontal scalability, replication, and TTL-based expiration."

---

# 29. Another Scenario — Social Media Feed

Suppose:

```text
100M users
Billions of posts
Very high read traffic
```

Possible architecture:

```text
SQL / NoSQL
      +
Cache
      +
Message Queue
      +
Read Model
      +
Object Storage
```

There is no universal answer.

The correct database depends on:

```text
Read pattern
Write pattern
Consistency
Scale
Relationships
Latency
```

---

# 30. Can We Use Both?

### YES.

This is very common.

Example:

```text
                 Application
                  /       \
                 /         \
                v           v
              SQL         NoSQL
               |             |
          Payments       User Feed
          Orders         Sessions
          Billing        Events
```

Use the right database for the right workload.

This is called **polyglot persistence**.

---

# 31. Example — E-Commerce Polyglot Persistence

```text
Customer / Orders
       ↓
      SQL

Product Catalog
       ↓
    Document DB

Session / Cache
       ↓
      Redis

Search
       ↓
 Elasticsearch/OpenSearch

Analytics
       ↓
Data Warehouse
```

The goal is not:

> "SQL vs NoSQL — choose one forever."

The goal is:

> **Choose the right storage technology for each workload.**

---

# 32. SQL vs NoSQL — Interview Cheat Sheet

| Requirement | Better Starting Choice |
|---|---|
| Complex JOINs | SQL |
| Strong relational integrity | SQL |
| Complex transactions | SQL |
| Financial records | SQL |
| Flexible documents | NoSQL |
| Massive distributed scale | NoSQL often |
| Simple key lookup | NoSQL often |
| Very high write throughput | NoSQL often |
| Graph relationships | Graph DB |
| Session storage | Key-value |
| Product catalog | Document DB |
| Analytics | Specialized analytical DB |
| Search | Search engine |

> These are starting points, not absolute rules.

---

# 33. Common Interview Mistakes

### ❌ Mistake 1

> "SQL cannot scale horizontally."

Wrong.

SQL databases can use:

```text
Sharding
Partitioning
Read replicas
Distributed SQL
```

---

### ❌ Mistake 2

> "NoSQL doesn't support transactions."

Wrong.

Transaction support depends on the specific NoSQL database.

---

### ❌ Mistake 3

> "NoSQL is always faster."

Wrong.

Performance depends on:

```text
Workload
Indexes
Data model
Query pattern
Partitioning
Hardware
Consistency requirements
```

---

### ❌ Mistake 4

> "NoSQL is always better for big data."

Wrong.

Large-scale analytical workloads may be better served by:

```text
Data Warehouse
Data Lake
Columnar Database
```

depending on the workload.

---

### ❌ Mistake 5

> "SQL = vertical scaling, NoSQL = horizontal scaling."

Oversimplified.

Both can scale horizontally; the architecture and operational complexity differ.

---

# 34. How to Answer "SQL or NoSQL?"

Use this framework:

```text
1. What is the data model?

2. Do we have relationships?

3. Do we need JOINs?

4. Do we need ACID transactions?

5. What consistency do we need?

6. What is the read pattern?

7. What is the write pattern?

8. How much data?

9. How much traffic?

10. Do we need horizontal scaling?

11. What latency is required?

12. What availability is required?
```

Then choose.

---

# 35. Best Interview Answer

### Question:

> "Why would you choose NoSQL over SQL?"

### Answer:

> "I would choose NoSQL when the workload is naturally distributed, requires very high throughput or horizontal scalability, has flexible or rapidly changing data, and has predictable access patterns that fit the NoSQL data model. However, if the system requires complex relationships, JOINs, strong transactional guarantees, and strict relational integrity, I would prefer SQL."

---

# 36. Best Interview Answer — SQL

> "I would choose SQL when the data is highly relational and the system needs strong ACID transactions, referential integrity, and complex queries. For example, banking and payment systems usually benefit from relational databases. If scale becomes a concern, I can add indexing, partitioning, read replicas, caching, and potentially sharding or distributed SQL."

---

# 37. Best Interview Answer — NoSQL

> "I would choose NoSQL when the workload needs horizontal scalability, high throughput, low latency, flexible data modeling, and the access patterns are well understood. For example, a session store can use a key-value database because the main operation is GET by session ID, and TTL can automatically expire sessions."

---

# 38. Final Comparison

```text
                 SQL
                  |
        +---------+---------+
        |         |         |
      Tables   Relations   ACID
        |         |         |
      JOINs    Foreign     Strong
               Keys       Integrity
```

```text
                NoSQL
                  |
       +----------+----------+
       |          |          |
    Flexible   Distributed  Scale
     Schema       System
       |          |          |
   Documents  Replication  High
   Key-Value  Partitioning Throughput
```

---

# 🧠 FINAL RECALL NOTE

## SQL

```text
SQL
 ↓
Tables
 ↓
Relationships
 ↓
JOIN
 ↓
ACID
 ↓
Strong Integrity
 ↓
Complex Queries
```

### Best for:

```text
Banking
Payments
Orders
Accounting
ERP
Relational business data
```

---

## NoSQL

```text
NoSQL
 ↓
Flexible Schema
 ↓
Partitioning
 ↓
Replication
 ↓
Horizontal Scaling
 ↓
High Throughput
 ↓
Low Latency
```

### Best for:

```text
Sessions
Caches
Large-scale events
Product catalogs
IoT
Distributed workloads
```

---

# 🔥 10-Second Memory Trick

> **SQL = Relationships + Transactions + Complex Queries**

> **NoSQL = Scale + Flexibility + Distributed Access Patterns**

---

# ⭐ Most Important Interview Line

> **"Don't choose SQL or NoSQL based only on scale. First understand the data model, access patterns, consistency, transaction requirements, latency, availability, and scaling needs. Then choose the database that best fits the workload."**