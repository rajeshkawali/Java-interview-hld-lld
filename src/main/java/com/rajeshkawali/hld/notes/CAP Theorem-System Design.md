# CAP Theorem — Beginner-Friendly System Design Notes

## 1. Definition

**CAP Theorem** says:

> In a distributed system, when a network partition happens, you can guarantee either **Consistency (C)** or **Availability (A)**, but not both at the same time.

CAP stands for:

```text
C = Consistency
A = Availability
P = Partition Tolerance
```

### Easy way to remember

**Network breaks → Choose C or A**

---

# 2. Why Do We Need CAP?

Imagine we have two servers:

```text
        Database
       /        \
    Node A     Node B
```

Both contain:

```text
user:101 → balance = $100
```

Now Node A receives:

```text
SET balance = $50
```

But suddenly the network between A and B breaks.

```text
Node A  ❌❌❌  Node B
```

This is a **network partition**.

Now the system has a choice.

---

# 3. C = Consistency

Consistency means:

> Every successful read gets the latest value or an error, according to the system's consistency guarantee.

Example:

```text
Node A → balance = $50
Node B → balance = $100
```

If a user reads from Node B and gets:

```text
$100
```

while `$50` is the latest committed value, the system is not providing strong consistency for that read.

A strongly consistent system may instead reject/block the read until it can guarantee the correct value.

### Simple example

Banking system:

```text
Account balance = $100

Withdraw $80

New balance = $20
```

We don't want another server to incorrectly show:

```text
$100
```

after the withdrawal has succeeded.

### Consistency Advantage

- Correct/latest data
- Easier reasoning about state
- Important for financial transactions

### Consistency Disadvantage

- May reject requests during network failures
- Higher latency
- Can reduce availability

---

# 4. A = Availability

Availability means:

> Every request to a non-failing node receives a response, even if some other nodes are unavailable.

During a network partition:

```text
Node A  ❌❌❌  Node B
```

Node B can still respond.

For example:

```text
GET product:123
```

Node B might return:

```text
price = $100
```

even if it has not yet received a newer update.

### Availability Advantage

- System continues responding
- Better user experience
- Good for highly available services

### Availability Disadvantage

- Data may temporarily be stale
- Conflicting updates may need resolution
- Application may need eventual consistency

---

# 5. P = Partition Tolerance

Partition tolerance means:

> The system continues operating even when communication between distributed nodes is lost.

Example:

```text
Node A  XXXXXXXXX  Node B
             ↑
       Network failure
```

The nodes cannot communicate.

A partition can happen because of:

- Network failure
- Switch failure
- Router failure
- Data-center connectivity issue
- Packet loss/timeouts

### Important Interview Point

In a distributed system, **network partitions are considered possible**, so in practice you generally need **P**.

Therefore, the real choice during a partition is:

```text
CP  OR  AP
```

Not:

```text
CA
```

for a distributed system that must tolerate network partitions.

---

# 6. CAP Combinations

There are three theoretical combinations:

```text
CA
CP
AP
```

But during an actual network partition:

```text
CP → Consistency + Partition Tolerance

AP → Availability + Partition Tolerance
```

---

# 7. CP System

**CP = Consistency + Partition Tolerance**

When a partition happens:

```text
Consistency ✅
Partition Tolerance ✅
Availability ❌ / reduced
```

The system may reject or delay some requests rather than return potentially stale/conflicting data.

### Example

Distributed database used for:

- Financial transactions
- Inventory
- Critical configuration

Example:

```text
Node A  XXXXXXXXX  Node B
```

If the system cannot confirm the latest value:

```text
Request
   ↓
Cannot guarantee consistency
   ↓
Reject / wait
```

### Advantages

- Stronger data correctness
- Avoids conflicting/stale results
- Good for critical data

### Disadvantages

- Some requests may fail during partition
- Lower availability during failures
- Potentially higher latency

---

# 8. AP System

**AP = Availability + Partition Tolerance**

When a partition happens:

```text
Availability ✅
Partition Tolerance ✅
Strong Consistency ❌
```

The system continues responding, even if some returned data is temporarily stale.

Later, replicas synchronize.

This is commonly associated with **eventual consistency**.

### Example

Social media likes:

```text
User A likes post
      ↓
Node A = 101 likes

Node B = 100 likes
```

During a network partition, Node B might still respond:

```text
100 likes
```

Later:

```text
100 → 101
```

### Advantages

- High availability
- Continues working during network problems
- Good scalability
- Lower latency in many designs

### Disadvantages

- Stale data possible
- Conflicts may occur
- Requires conflict-resolution/eventual-consistency mechanisms

---

# 9. CA System

**CA = Consistency + Availability**

```text
Consistency ✅
Availability ✅
Partition Tolerance ❌
```

This can make sense for a **single-node/non-distributed system**, where network partition between replicas isn't part of the system model.

Example:

```text
Application
    |
    v
Single Database
```

But for a distributed system, you generally cannot simply choose CA and ignore partitions.

### Important Interview Answer

> "CAP is mainly about what happens during a network partition. In a distributed system, partition tolerance is usually required, so the practical trade-off is generally CP vs AP."

---

# 10. Simple Example — Shopping Inventory

Suppose:

```text
Product:
iPhone
Stock = 1
```

Two users try to buy it simultaneously.

```text
User A → Node A
User B → Node B
```

Network partition:

```text
Node A  XXXXXXXXX  Node B
```

Both nodes think:

```text
Stock = 1
```

Both may sell the same phone.

Now:

```text
Stock = -1
```

This is bad.

For inventory, we may prefer **CP behavior**:

```text
Cannot confirm correct stock
        ↓
Reject / wait
```

Correctness is more important than accepting every request.

---

# 11. Simple Example — Social Media Likes

Suppose:

```text
Post = 1,000 likes
```

A network partition happens.

One node has:

```text
1,005 likes
```

Another has:

```text
1,002 likes
```

It is usually acceptable to temporarily show:

```text
1,002
```

and synchronize later.

So an **AP/eventually consistent** design can be reasonable.

Availability is more important than immediately showing the exact count.

---

# 12. CP vs AP

| Feature | CP | AP |
|---|---|---|
| Consistency | Stronger | Eventual/relaxed |
| Availability during partition | Reduced | High |
| Stale reads | Minimized | Possible |
| Writes during partition | May be rejected | Usually continue |
| Latency | Can be higher | Often lower |
| Good for | Banking, inventory | Social feeds, likes |
| Main priority | Correctness | Availability |

---

# 13. CAP Is NOT "Pick Any 2"

A common beginner mistake is:

> "CAP means I can pick any two of C, A, and P."

That's an oversimplification.

The important statement is:

> **When a network partition occurs, a distributed system must trade off strong consistency against availability.**

Because if you choose partition tolerance:

```text
P = required
```

then the practical choice is:

```text
CP or AP
```

---

# 14. CAP vs Normal Failures

CAP specifically focuses on **network partitions**.

It is not simply:

```text
Server crashed → CAP
```

The key problem is:

```text
Node A cannot communicate with Node B
```

while both may still be running.

Example:

```text
Node A        Node B
  |             |
  |             |
  XXXXXXXXXXXXXXX
       Network
       Partition
```

---

# 15. Real-World Systems

Don't blindly label an entire database as simply "CP" or "AP" without considering configuration and operation.

Different databases can provide different consistency/availability behaviors depending on:

- Configuration
- Replication model
- Read/write settings
- Failure scenario
- Transaction model

In interviews, focus on the **behavior you choose for your specific system**.

---

# 16. How to Answer CAP in an Interview

### Interviewer:

> What is CAP theorem?

### Answer:

> "CAP theorem states that during a network partition in a distributed system, we cannot simultaneously guarantee strong consistency and availability. Partition tolerance is generally required in distributed systems, so we typically choose between CP and AP depending on business requirements."

---

### Interviewer:

> Which one would you choose for banking?

Answer:

> "I would favor CP because correctness is more important than accepting requests with potentially inconsistent data."

---

### Interviewer:

> Which one would you choose for social media likes?

Answer:

> "I would favor AP because temporary inconsistency is acceptable, while keeping the service available is more important."

---

# 17. Easy Decision Rule

Ask:

### Question 1:

**Can the user tolerate stale data?**

```text
YES → AP may be suitable
NO  → CP may be suitable
```

### Question 2:

**Can we reject requests during a network partition?**

```text
YES → CP may be suitable
NO  → AP may be suitable
```

---

# 18. CAP + TinyURL Example

For your TinyURL system:

```text
Short Code → Long URL
```

Suppose:

```text
DB Node A  XXXXXXXXX  DB Node B
```

If the destination URL rarely changes, temporary stale reads may be acceptable.

You could favor:

```text
AP / eventual consistency
```

for some parts of the system.

But if you have operations requiring a unique short code, you need strong coordination for uniqueness.

Therefore, don't simply say:

> "TinyURL is AP."

Instead say:

> "Different operations can have different consistency requirements. URL creation/uniqueness needs strong coordination, while cached redirect reads can often tolerate eventual consistency."

---

# 19. CAP vs PACELC

CAP only describes the trade-off **during partition**.

Another concept is **PACELC**:

```text
P → Partition
A → Availability
C → Consistency

E → Else
L → Latency
C → Consistency
```

Meaning:

> If there is a partition, choose Availability or Consistency; otherwise, choose between Latency and Consistency.

You don't need PACELC for a beginner CAP question, but it is useful for advanced interviews.

---

# 🧠 FINAL RECALL NOTE

## CAP

```text
C = Consistency
A = Availability
P = Partition Tolerance
```

### C — Consistency

**Always see the latest correct data.**

```text
Adv → Correctness
Disadv → May reject/wait
```

### A — Availability

**Always get a response.**

```text
Adv → High availability
Disadv → Stale data possible
```

### P — Partition Tolerance

**System survives network communication failure.**

```text
Adv → Works despite network partition
Disadv → Forces C vs A trade-off
```

---

## 🔥 Most Important Rule

```text
Network Partition
       ↓
   Choose one
    /       \
   CP       AP
   ↓         ↓
Consistency Availability
```

### CP

**"I'd rather reject/wait than return incorrect data."**

### AP

**"I'd rather return possibly stale data than reject the request."**

---

## ⭐ One-Line Interview Answer

> **"CAP theorem says that when a network partition occurs in a distributed system, you must trade off strong Consistency and Availability. Since Partition Tolerance is generally required, the practical choice is usually CP or AP based on the business requirement."**

## 🧠 Memory Trick

**C = Correct data**  
**A = Always respond**  
**P = Partition survives**

**Partition happens → Choose Correctness or Availability.**