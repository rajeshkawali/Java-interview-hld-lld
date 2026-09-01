# Microservices – Short Revision Notes

## What is Microservices?
Microservices is an architecture where a large application is divided into **small, independent services**, with each service responsible for a specific business functionality.

**Example:**
```text
E-Commerce
   |
   +-- User Service
   +-- Order Service
   +-- Payment Service
   +-- Inventory Service
```

Each service can have its own database and can be developed, deployed, and scaled independently.

---

## Advantages of Microservices

### 1. Independent Deployment
Each service can be deployed separately without deploying the whole application.

**Example:** Update Payment Service without deploying Order Service.

### 2. Independent Scaling
Services can be scaled based on their individual traffic.

**Example:** Product Service may need 10 servers, while Payment Service needs only 2.

### 3. Fault Isolation
Failure of one service does not necessarily bring down the entire system.

**Example:** Recommendation Service is down, but users can still place orders.

### 4. Technology Flexibility
Different services can use different technologies when required.

**Example:**
```text
Order Service → Java
Recommendation Service → Python
Search → Elasticsearch
```

### 5. Smaller Codebase
Each service has a smaller and more manageable codebase.

### 6. Team Independence
Different teams can own and independently develop different services.

---

## Disadvantages of Microservices

### 1. Increased Complexity
Managing many services is more complex than managing one application.

### 2. Network Latency
Communication between services happens over the network, which adds latency and can fail.

### 3. Distributed Transactions
Transactions involving multiple services are difficult to manage.

**Example:**
```text
Payment → SUCCESS
Inventory → FAILED
```
Now we need mechanisms such as Saga/compensating transactions.

### 4. Data Consistency
Different services may have different databases, making consistency harder to maintain.

### 5. Difficult Debugging
A single request may pass through many services, so debugging requires logs, metrics, and distributed tracing.

### 6. Higher Infrastructure Cost
Multiple services require more servers, containers, monitoring, networking, CI/CD, etc.

---

## Key Point

**Microservices provide:**
- Independent deployment
- Independent scaling
- Fault isolation
- Team and technology flexibility

**But introduce:**
- Distributed-system complexity
- Network failures/latency
- Data consistency problems
- Distributed transactions
- Higher operational cost

### Interview Line

"Microservices solve scaling, deployment, and organizational problems, but they introduce distributed-system complexity."