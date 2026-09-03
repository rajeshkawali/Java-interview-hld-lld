# DESIGN IDEMPOTENT API — HANDLE DUPLICATE REQUESTS

## 1. What is Idempotency?

**Idempotency** means:

> Sending the same request multiple times produces the **same final result** as sending it once.

This is very important in distributed systems because clients may retry requests when they don't receive a response.

### Simple Example

Client sends:

```text
POST /payments
Idempotency-Key: abc123

{
    "userId": 101,
    "amount": 500
}
```

Server processes the payment successfully.

But the response is lost because of a network problem.

Client retries:

```text
POST /payments
Idempotency-Key: abc123
```

Without idempotency:

```text
Request 1 → Payment ₹500
Request 2 → Payment ₹500

Total charged = ₹1000 ❌
```

With idempotency:

```text
Request 1 → Payment ₹500
Request 2 → Return same result

Total charged = ₹500 ✅
```

---

# 2. Why Do We Need Idempotency?

Duplicate requests can happen because of:

```text
1. Network timeout
2. Client retry
3. Load balancer retry
4. Message redelivery
5. User double-click
6. Mobile app retry
7. Service failure after DB commit but before response
```

The most important scenario:

```text
Client
  |
  | POST
  ↓
Server
  |
  | DB COMMIT ✅
  |
  X Response lost
  |
Client thinks request failed
  |
  | RETRY
  ↓
Server
```

Without an idempotency mechanism, the operation may execute twice.

---

# 3. Idempotency Key

The most common solution is an:

```text
Idempotency-Key
```

The client generates a unique key for each logical operation.

Example:

```text
Idempotency-Key: 7f8a9c10
```

The client must reuse the **same key when retrying the same operation**.

A new business operation should receive a new key.

---

# 4. High-Level Architecture

```text
                Client
                  |
                  |
          Idempotency-Key
                  |
                  ↓
            API Gateway
                  |
                  ↓
         Idempotency Handler
                  |
            ┌─────┴─────┐
            ↓           ↓
       Idempotency     Business
           Store        Service
            |              |
            ↓              ↓
          Redis          Database
```

The idempotency handler checks whether the request was already processed.

---

# 5. Basic Flow

```text
Client
  |
  | POST /payment
  | Idempotency-Key = ABC123
  ↓
Idempotency Handler
  |
  | Check ABC123
  ↓
Idempotency Store
```

### Case 1 — Key does not exist

```text
ABC123 → NOT FOUND
```

Process request:

```text
Create Payment
      ↓
Save Payment
      ↓
Save response for ABC123
      ↓
Return response
```

---

### Case 2 — Key already exists

```text
ABC123 → FOUND
```

Do **not** execute the business operation again.

Return the previously stored result:

```text
Stored Response
      ↓
Return to Client
```

---

# 6. Recommended Idempotency Table

Example:

```text
idempotency_records

------------------------------------------------
idempotency_key
user_id
request_hash
status
response_status
response_body
resource_id
created_at
expires_at
------------------------------------------------
```

Example record:

```text
idempotency_key = ABC123
user_id         = 101
request_hash    = SHA256(request)
status          = COMPLETED
response_status = 201
resource_id     = PAYMENT-999
response_body   = {...}
created_at      = ...
expires_at      = ...
```

---

# 7. Status Values

A useful state machine is:

```text
IN_PROGRESS
     |
     ↓
 COMPLETED
```

Failure path:

```text
IN_PROGRESS
     |
     ↓
 FAILED
```

Depending on the business requirement, failed keys may be retriable or may be retained to prevent accidental reuse.

---

# 8. Important Problem — Concurrent Duplicate Requests

This is a very common interview question.

Suppose two identical requests arrive at exactly the same time:

```text
Request A ──→ Server
Request B ──→ Server

Both use:

Idempotency-Key = ABC123
```

Naive implementation:

```text
Request A → CHECK → NOT FOUND
Request B → CHECK → NOT FOUND

Request A → CREATE PAYMENT
Request B → CREATE PAYMENT
```

Result:

```text
Duplicate payment ❌
```

---

# 9. Solution — Atomic Create / Conditional Insert

Instead of:

```text
CHECK
+
INSERT
```

use an atomic operation:

```text
INSERT IF NOT EXISTS
```

or a database unique constraint.

Example:

```text
UNIQUE(user_id, idempotency_key)
```

Now:

```text
Request A → INSERT ABC123 → SUCCESS
Request B → INSERT ABC123 → FAIL
```

Only one request becomes the owner of the operation.

---

# 10. Concurrent Request Flow

```text
              Request A
                  |
                  ↓
             Idempotency
                Store
                  |
             CREATE KEY
                  |
                SUCCESS
                  |
                  ↓
             Process Request
```

At the same time:

```text
              Request B
                  |
                  ↓
             Idempotency
                Store
                  |
             CREATE KEY
                  |
                EXISTS
                  |
                  ↓
          Wait / Return Result
```

This prevents duplicate processing.

---

# 11. What Should the Second Request Do?

If the first request is still processing:

```text
ABC123 = IN_PROGRESS
```

The second request should **not execute the business operation**.

Possible approaches:

### Option 1 — Return 409

```text
409 Conflict

Request already in progress.
```

Simple and useful when the client can retry later.

### Option 2 — Wait

The second request waits for the first request to complete and then receives the result.

### Option 3 — Poll

Return an operation ID:

```text
202 Accepted

operationId = ABC123
```

Client polls:

```text
GET /payments/status/ABC123
```

For long-running operations, this is often cleaner.

---

# 12. Request Hash

The idempotency key alone may not be enough.

Suppose:

```text
Request 1:

Key = ABC123
Amount = ₹500
```

Later someone sends:

```text
Request 2:

Key = ABC123
Amount = ₹1000
```

Same key but different request.

This should usually be rejected.

Therefore calculate:

```text
request_hash = SHA-256(canonical_request)
```

Store it:

```text
ABC123
   |
   └── request_hash = XYZ789
```

On retry:

```text
Same key
+
Same hash
→ Allowed
```

Different hash:

```text
Same key
+
Different hash
→ Reject
```

Example:

```text
409 Conflict

Idempotency key was already used with a different request.
```

---

# 13. Complete Flow

```text
                     Client
                        |
                        |
             Idempotency-Key: ABC123
                        |
                        ↓
               Idempotency Handler
                        |
                Calculate Hash
                        |
                        ↓
                Idempotency Store
                        |
             ┌──────────┴──────────┐
             |                     |
          NOT FOUND              FOUND
             |                     |
             ↓                     ↓
        Create Record         Check Hash
        IN_PROGRESS                |
             |              ┌──────┴──────┐
             |              |             |
             |           Same Hash    Different Hash
             |              |             |
             |              ↓             ↓
             |        Return Result     REJECT
             |
             ↓
       Business Service
             |
             ↓
       Database Transaction
             |
             ↓
        SUCCESS
             |
             ↓
     Update Idempotency
       → COMPLETED
             |
             ↓
        Return Response
```

---

# 14. Where Should Idempotency Be Implemented?

There are several choices.

## Option 1 — API Gateway

```text
Client
  ↓
API Gateway
  ↓
Service
```

### Advantages

```text
✓ Centralized
✓ Common implementation
✓ Easy to apply to many APIs
```

### Disadvantages

```text
✗ Gateway becomes more complex
✗ Business-specific rules may not belong here
✗ Response storage can be complicated
```

---

## Option 2 — Application Service

```text
Client
  ↓
API
  ↓
Idempotency Handler
  ↓
Business Logic
```

### Advantages

```text
✓ Business context available
✓ Easier to validate request
✓ More control over response
```

### Disadvantages

```text
✗ Must implement consistently across services
✗ Duplicate implementation
```

For business-critical operations such as payments, **application-level idempotency is often important even if a gateway also has protections**.

---

# 15. Redis vs Database

The idempotency store can use Redis or a database.

## Redis

```text
Idempotency Key
      ↓
Redis
```

### Advantages

```text
✓ Very fast
✓ TTL support
✓ Good for high request volume
✓ Easy atomic operations
```

### Disadvantages

```text
✗ Data can be lost depending on configuration
✗ Memory cost
✗ Must carefully handle Redis failure
```

---

## SQL Database

```text
Idempotency Key
      ↓
SQL DB
```

### Advantages

```text
✓ Durable
✓ Unique constraints
✓ Transaction support
✓ Strong consistency
```

### Disadvantages

```text
✗ Higher latency than Redis
✗ Database load
✗ Cleanup/retention required
```

---

# 16. Best Practical Design

For a critical operation such as payment:

```text
Client
  ↓
API Gateway
  ↓
Payment Service
  ↓
Idempotency Store
  ↓
Payment DB
  ↓
Payment Provider
```

Use:

```text
Idempotency Store
→ Redis / SQL

Business Record
→ Durable SQL database
```

Do **not** rely only on Redis for the permanent business record.

The payment/order itself must be stored durably.

---

# 17. Database Unique Constraint

For strong protection, create:

```text
UNIQUE(user_id, idempotency_key)
```

Example:

```text
CREATE TABLE idempotency_records (
    idempotency_key VARCHAR(255) NOT NULL,
    user_id BIGINT NOT NULL,
    request_hash VARCHAR(64) NOT NULL,
    status VARCHAR(20) NOT NULL,
    response_body TEXT,
    created_at TIMESTAMP NOT NULL,

    UNIQUE(user_id, idempotency_key)
);
```

This provides a database-level guarantee against duplicate keys for the same user.

---

# 18. Important: Idempotency Does NOT Mean "No Duplicate Request"

This is an important interview point.

Idempotency does **not** stop duplicate requests from reaching the server.

It ensures:

```text
Duplicate request
       ↓
Same logical operation
       ↓
Same final effect
```

Example:

```text
POST 1 → received
POST 2 → received
POST 3 → received

But:

Payment created = 1
```

---

# 19. POST and Idempotency

Normally:

```text
GET
PUT
DELETE
```

are generally designed to be idempotent by HTTP semantics, although application behavior still matters.

`POST` is commonly used for operations such as:

```text
POST /payments
POST /orders
POST /bookings
POST /transfers
```

These operations may create new resources or cause side effects.

Therefore, an **Idempotency-Key** is commonly added for retry-safe POST operations.

Example:

```text
POST /orders

Idempotency-Key: ORDER-ABC123
```

Retrying the same logical operation with the same key should return the existing order rather than create another one.

---

# 20. Idempotency vs Deduplication

These concepts are related but not exactly the same.

### Deduplication

Question:

> "Have I already seen this request/message?"

```text
Message ABC123
     ↓
Already processed?
     ↓
YES → Ignore
```

### Idempotency

Question:

> "If this operation is executed again, will the final effect remain the same?"

```text
Same operation
     ↓
Repeated execution
     ↓
Same final state
```

---

# 21. Idempotency vs Distributed Lock

They solve different problems.

### Idempotency

Protects against:

```text
Duplicate logical requests
```

### Distributed Lock

Protects against:

```text
Concurrent access to a shared resource
```

You may use both, but they are not interchangeable.

For duplicate POST requests, prefer **idempotency keys + atomic uniqueness** rather than relying only on a distributed lock.

---

# 22. Failure Scenario — DB Commit but Response Lost

This is the most important example.

```text
Client
  |
  | POST + ABC123
  ↓
Server
  |
  ↓
DB COMMIT ✅
  |
  X
Response lost
  |
Client retries
  |
  | POST + ABC123
  ↓
Idempotency Store
  |
  ↓
COMPLETED
  |
  ↓
Return previous result
```

Result:

```text
Business operation = executed once
Client receives successful result
```

---

# 23. Failure Scenario — Server Crashes During Processing

Suppose:

```text
ABC123 = IN_PROGRESS
```

Then server crashes.

Now we need recovery.

Possible design:

```text
IN_PROGRESS
     |
     ↓
TTL / timeout
     |
     ↓
Recovery
```

After a timeout, the system can determine whether the business transaction actually succeeded.

This is why **idempotency state should not blindly be treated as the source of truth**.

For critical operations, check the durable business record.

Example:

```text
Idempotency:
ABC123 → IN_PROGRESS

Payment DB:
paymentId ABC123 → SUCCESS
```

Recovery can safely mark the idempotency record:

```text
ABC123 → COMPLETED
```

---

# 24. Idempotency and Database Transaction

For operations within your own database, a strong approach is:

```text
BEGIN TRANSACTION

1. Create/check idempotency record
2. Create business record
3. Store resulting resource information

COMMIT
```

This can make the idempotency record and business operation atomic **within the same database**.

Example:

```text
BEGIN

INSERT idempotency_key ABC123

INSERT payment PAYMENT999

COMMIT
```

If the transaction fails:

```text
ROLLBACK
```

Both changes are rolled back.

---

# 25. External Payment Provider

Things become harder when your system calls an external provider.

Example:

```text
Your Payment Service
       |
       ↓
Payment Provider
```

Your DB transaction cannot automatically roll back the external provider's transaction.

Therefore use:

```text
Your Idempotency-Key
+
Provider's Idempotency-Key
+
Durable payment state
```

Example:

```text
Client
  |
  | ABC123
  ↓
Payment Service
  |
  | ABC123
  ↓
Payment Provider
```

This gives protection at both levels.

---

# 26. TTL / Expiration

Idempotency records should generally not live forever.

Example:

```text
Key: ABC123
Created: 10:00
Expires: 11:00
```

After expiration:

```text
ABC123 → removed
```

But TTL depends on business requirements.

For financial transactions, you may need much longer retention or a durable audit record.

### Important

> Never choose TTL only based on cache convenience. Choose it based on the maximum retry/replay window of the business operation.

---

# 27. Security Considerations

Idempotency keys should:

```text
✓ Be unpredictable/unique
✓ Be scoped to the authenticated user/account
✓ Have reasonable length limits
✓ Not contain sensitive information
```

Also validate:

```text
userId + idempotencyKey
```

so one user cannot reuse another user's idempotency record.

---

# 28. Interview Design Example — Payment API

Requirement:

```text
POST /payments
```

Input:

```text
{
    "amount": 500,
    "currency": "INR"
}
```

Header:

```text
Idempotency-Key: ABC123
```

Architecture:

```text
                 Client
                    |
                    ↓
               API Gateway
                    |
                    ↓
              Payment Service
                    |
          ┌─────────┴─────────┐
          ↓                   ↓
   Idempotency Store       Payment DB
          |                   |
          |                   ↓
          |              Payment Record
          |
          ↓
    Payment Provider
```

Flow:

```text
1. Validate authentication
2. Validate Idempotency-Key
3. Calculate request hash
4. Atomically create idempotency record
5. If key exists:
      - same hash → return existing result
      - different hash → reject
6. If new:
      - process payment
      - persist payment result
      - mark idempotency record COMPLETED
7. Return response
```

---

# 29. Advantages of Idempotency

```text
✓ Prevents duplicate payments/orders
✓ Safe client retries
✓ Handles network failures
✓ Improves reliability
✓ Important for distributed systems
✓ Protects against duplicate message delivery
✓ Makes APIs safer
```

---

# 30. Disadvantages / Tradeoffs

```text
✗ Additional storage
✗ Additional lookup
✗ More implementation complexity
✗ Requires TTL/cleanup
✗ Concurrent requests need careful handling
✗ Response storage can consume space
✗ Recovery logic can be complex
```

---

# 31. Common Interview Mistakes

### Mistake 1

```text
CHECK key
INSERT key
```

These are separate operations and can race.

Better:

```text
Atomic INSERT IF NOT EXISTS
```

or:

```text
Unique constraint
```

---

### Mistake 2

Using only an in-memory map:

```text
Map<String, Response>
```

This fails when:

```text
Server 1 → processed request
Server 1 → crashes

Server 2 → receives retry
```

Server 2 doesn't know about the previous request.

Use shared durable/distributed storage where appropriate.

---

### Mistake 3

Only storing the key.

Better:

```text
key
+
request hash
+
status
+
result/resource ID
```

---

### Mistake 4

Treating `IN_PROGRESS` as permanently failed.

A crash can leave:

```text
IN_PROGRESS
```

even though the business operation may have succeeded.

Recovery needs to check durable business state.

---

# 32. ⭐ Interview Answer — 60 Seconds

> I would make the POST API idempotent using an Idempotency-Key supplied by the client. For every logical operation, the client generates a unique key and reuses it when retrying. The server stores the key, request hash, processing status, and result. I would use an atomic insert or a unique constraint so concurrent requests with the same key cannot both execute the operation. If the key already exists with the same request hash, I return the previously stored result. If the same key is used with a different request, I reject it. For critical operations such as payments, the idempotency record and business transaction should be persisted durably, and recovery logic should handle cases where the database commit succeeds but the response is lost.

---

# 33. ⭐ QUICK RECALL

```text
IDEMPOTENCY

Goal:
→ Same logical request = same final effect.

Common solution:
→ Idempotency-Key

Store:
→ key
→ request hash
→ status
→ result/resource ID
→ timestamps/TTL

Flow:

New key
   ↓
Atomic create
   ↓
IN_PROGRESS
   ↓
Execute business operation
   ↓
COMPLETED
   ↓
Store result
   ↓
Return response

Duplicate key:
   ↓
Check hash
   ↓
Same request → return previous result
Different request → reject

Concurrent duplicates:
→ Atomic INSERT IF NOT EXISTS
→ Unique constraint

Important failure:
DB commit SUCCESS
+
Response LOST
+
Client retries
→ Return existing result
→ Do NOT execute again

Storage:
→ Redis: fast + TTL
→ SQL: durable + unique constraint

POST:
→ Often needs explicit idempotency for payments/orders/bookings.

Idempotency ≠ locking
Idempotency ≠ deduplication

Main idea:
→ "Same key, same operation, execute effect once."
```

# ONE-LINE MEMORY TRICK

> **Idempotency = Give every logical POST a unique key; process the key once, store the result, and return the same result for retries.**

### HTTP Idempotency Rules

| Method     | Idempotent?  | Simple Meaning                                           | Example             |
| ---------- | ------------ | -------------------------------------------------------- | ------------------- |
| **GET**    | ✅ Yes        | Reading does not change resource state                   | `GET /users/101`    |
| **PUT**    | ✅ Yes        | Replacing/updating with same data gives same final state | `PUT /users/101`    |
| **DELETE** | ✅ Yes        | Deleting the same resource repeatedly leaves it deleted  | `DELETE /users/101` |
| **POST**   | ❌ Usually No | Repeated requests may create multiple resources          | `POST /orders`      |

### Memory Trick:
* **GET**, **PUT**, **DELETE** = Idempotent (Safe to repeat)
* **POST** = Usually not (Repeated requests cause side effects)




