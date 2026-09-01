# Monolith vs Microservices – Revision Notes

## Monolith

A monolithic application is a single application containing multiple business functionalities such as User, Order, Payment, and Inventory.

```text
Client
  ↓
Monolithic Application
  ├── User
  ├── Order
  ├── Payment
  └── Inventory
        ↓
     Database
```

### Advantages
- Simple development
- Easy debugging
- Simple deployment
- Easy database transactions
- Lower infrastructure complexity/cost

### Disadvantages
- Difficult to scale individual modules
- Large codebase as application grows
- Entire application may need deployment for small changes
- Technology is more tightly coupled
- Failure can potentially affect the whole application

---

## Microservices

Microservices divide an application into small, independently deployable services, where each service handles a specific business capability.

```text
Client
  ↓
API Gateway
  ├── User Service → User DB
  ├── Order Service → Order DB
  ├── Payment Service → Payment DB
  └── Inventory Service → Inventory DB
```

### Advantages
- Independent deployment
- Independent scaling
- Fault isolation
- Smaller codebases
- Team independence
- Technology flexibility

### Disadvantages
- Higher complexity
- Network latency/failures
- Distributed transactions are difficult
- Data consistency becomes difficult
- Debugging is harder
- Higher infrastructure/operational cost

---

## When to Use Monolith?

Use monolith when:
- Application is small/medium
- Team is small
- Traffic is manageable
- Domain is simple
- Fast development is important

## When to Use Microservices?

Use microservices when:
- Independent scaling is required
- Independent deployment is required
- Large teams need independent ownership
- Services have clear business boundaries
- Different parts have different scaling/availability requirements

## Important Interview Point

Do NOT choose microservices just because the application is large.

Microservices provide scalability and organizational benefits but introduce distributed-system complexity.

### Key Line

"Start simple when possible. Move to microservices when the complexity and scale of the system justify the additional operational and distributed-system complexity."

## Distributed Monolith

A system can have multiple services but still behave like a monolith if services are highly coupled and depend heavily on each other.

```text
Order → Payment → Inventory → User
```

If failure of one service causes the entire business operation to fail, the architecture may effectively behave like a distributed monolith.