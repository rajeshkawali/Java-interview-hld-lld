# Strangler Pattern – Revision Notes

## What is Strangler Pattern?

Strangler Pattern is a **migration pattern** used to gradually migrate a **monolithic application to microservices**.

Instead of rewriting the entire monolith at once, functionality is extracted **step by step** into new services.

```text
Old Monolith
     ↓
Extract Payment
     ↓
Extract Inventory
     ↓
Extract Order
     ↓
Extract User
     ↓
Monolith Removed
```

It is called "Strangler" because the new system gradually grows around and replaces the old system.

---

## Example

### Initially

```text
Client
  ↓
Monolith
 ├── User
 ├── Order
 ├── Payment
 └── Inventory
```

### During Migration

```text
                 Client
                   ↓
              API Gateway
               /        \
              ↓          ↓
         Monolith    Payment Service
         ├── User
         ├── Order
         └── Inventory
```

Requests can be routed:

```text
/users      → Monolith
/orders     → Monolith
/payments   → Payment Service
```

Later:

```text
                 API Gateway
              /      |       \
             ↓       ↓        ↓
          User     Order    Payment
         Service  Service   Service
```

Finally, the monolith can be removed.

---

## Advantages

1. **Lower migration risk** – migrate functionality gradually.
2. **No big-bang rewrite** – system continues working during migration.
3. **Continuous delivery** – development can continue while migration happens.
4. **Easier rollback** – traffic can potentially be routed back to the monolith.
5. **Gradual adoption** – teams can learn and adopt microservices step by step.

---

## Disadvantages

1. **Temporary complexity** – old and new systems run together.
2. **Higher operational overhead** – two architectures must be maintained.
3. **Data migration is difficult** – moving data from shared monolith DBs to service-owned DBs can be challenging.
4. **Temporary duplication** – functionality may exist in both systems during migration.
5. **Migration can take a long time.**

---

## Strangler vs Saga

### Strangler Pattern
Used for **migrating monolith → microservices**.

### Saga Pattern
Used for **managing distributed transactions across microservices**.

```text
Strangler → Migration

Saga → Distributed Transaction
```

---

## Interview Answer

"Strangler Pattern is a gradual migration approach where we put a gateway or proxy in front of an existing monolith and incrementally extract business capabilities into new microservices. Traffic is gradually redirected to the new services, while the remaining functionality continues to run in the monolith. Once the migration is complete, the monolith can be decommissioned."

### Key Line

**Don't rewrite a large monolith in one shot; gradually replace it with new services.**