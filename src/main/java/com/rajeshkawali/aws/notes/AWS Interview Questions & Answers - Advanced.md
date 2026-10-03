# AWS INTERVIEW QUESTIONS & ANSWERS
## Advanced + Detailed Questions for Java / Spring Boot Developers

---

# SECTION 1 — AWS CORE CONCEPTS

## 1. What is the difference between scalability and elasticity?

This is a very common conceptual question.

### Scalability

Scalability means the system can handle increasing workload by adding resources.

There are two types:

### Vertical scaling

Increase the capacity of an existing server.

```text
Before:

EC2
2 CPU
4 GB RAM

       ↓

After:

EC2
8 CPU
32 GB RAM
```

### Horizontal scaling

Add more servers.

```text
Before:

       EC2
        |
   Spring Boot


After:

       Load Balancer
        /       \
       /         \
    EC2 #1     EC2 #2
```

### Elasticity

Elasticity means resources can automatically increase or decrease based on workload.

Example:

```text
Normal traffic
     |
     v
2 EC2 instances

Traffic increases
     |
     v
5 EC2 instances

Traffic decreases
     |
     v
2 EC2 instances
```

### Interview answer

> Scalability is the ability to handle increased workload by adding resources. Elasticity goes a step further by automatically adjusting resources according to demand.

---

# 2. Vertical scaling vs horizontal scaling?

### Vertical scaling

Increase the size of one machine.

```text
t3.small
   ↓
larger instance
```

Advantages:

- Simple
- Usually easier to implement

Disadvantages:

- Has hardware/resource limits
- Can create a single-server dependency

### Horizontal scaling

Add more instances.

```text
          Load Balancer
          /           \
       EC2 #1        EC2 #2
```

Advantages:

- Better availability
- Better scalability
- Can handle instance failures

For production web applications, horizontal scaling is often preferred.

---

# 3. What is fault tolerance?

Fault tolerance means the system continues operating even when some components fail.

Example:

```text
             Load Balancer
              /        \
             /          \
         EC2 #1        EC2 #2
            X
         FAILED
                         |
                         v
                    Application
                      works
```

If one EC2 fails, the other can continue serving requests.

### Interview answer

> Fault tolerance means designing a system so that failure of one component does not cause the entire application to become unavailable.

---

# 4. What is high availability?

High availability means designing the system to minimize downtime.

Example:

```text
AWS Region
 |
 +-- AZ-1
 |    |
 |   EC2
 |
 +-- AZ-2
      |
     EC2
```

If AZ-1 has a problem, AZ-2 can continue serving traffic.

### Important

High availability and fault tolerance are related but not exactly identical concepts.

---

# 5. What is the difference between backup and replication?

### Backup

A copy of data maintained for recovery.

```text
Database
   |
   v
Backup
```

### Replication

Data is copied between systems, often to keep another copy synchronized or nearly synchronized.

```text
Primary
   |
   v
Replica
```

Example:

```text
RDS
 |
 +-- Primary
 |
 +-- Read Replica
```

### Interview answer

> Backup is primarily for recovery from data loss or corruption, while replication maintains another copy of data for availability, scaling, or disaster recovery depending on the architecture.

---

# 6. What is a stateless application?

A stateless application does not depend on local server memory to maintain user session state.

Example:

```text
User
 |
 v
Load Balancer
 /        \
EC2 #1   EC2 #2
```

The user's next request can go to either server.

This makes horizontal scaling easier.

### Bad design

```text
EC2 #1
 |
Session stored only in memory
```

If the next request goes to EC2 #2, the session may not exist there.

### Better

Use:

```text
Redis
Database
External session store
```

or use stateless authentication such as appropriately designed JWT-based authentication.

---

# 7. Why is stateless architecture useful?

Suppose:

```text
100 users
```

becomes:

```text
100,000 users
```

You can add servers:

```text
              Load Balancer
             /     |      \
            /      |       \
         EC2      EC2      EC2
```

Requests don't have to remain tied to one particular application server.

---

# SECTION 2 — VPC & NETWORKING

# 8. Explain a VPC in detail.

A VPC is your logically isolated network in AWS.

A simplified architecture:

```text
                         VPC
                          |
             +------------+------------+
             |                         |
       Public Subnet              Private Subnet
             |                         |
        Load Balancer             EC2 / RDS
             |
        Internet Gateway
             |
          Internet
```

VPC contains things such as:

```text
CIDR
Subnets
Route Tables
Internet Gateway
NAT Gateway
Security Groups
Network ACLs
VPC Endpoints
```

---

# 9. What is CIDR?

CIDR defines an IP address range.

Example:

```text
10.0.0.0/16
```

This can be used as the CIDR block for a VPC.

You can divide it into smaller subnet ranges.

Example:

```text
VPC
10.0.0.0/16

     |
     +-- Public subnet
     |   10.0.1.0/24
     |
     +-- Private subnet
         10.0.2.0/24
```

### Interview tip

You don't need to become a networking expert for most Java interviews, but understand:

```text
VPC → Network
Subnet → Smaller network inside VPC
CIDR → IP range
```

---

# 10. What is a route table?

A route table defines where network traffic should go.

Example:

```text
Destination       Target

10.0.0.0/16       local
0.0.0.0/0         Internet Gateway
```

Conceptually:

```text
EC2
 |
Route Table
 |
 +-- Local VPC traffic
 |
 +-- Internet Gateway
```

### Private subnet

A private subnet may have:

```text
0.0.0.0/0 → NAT Gateway
```

for outbound internet connectivity.

---

# 11. What is an Internet Gateway?

An Internet Gateway connects a VPC to the internet for resources that have the required routing and public addressing.

Example:

```text
Internet
    |
    v
Internet Gateway
    |
    v
Route Table
    |
    v
Public Subnet
```

---

# 12. What is NAT Gateway?

NAT Gateway allows resources in private subnets to initiate connections to external destinations.

Example:

```text
Private EC2
    |
    v
NAT Gateway
    |
    v
Internet
```

For example, a private EC2 instance might need to:

```text
Download packages
Call an external API
Access external repositories
```

without being directly reachable from the internet.

---

# 13. Public subnet vs private subnet?

### Public subnet

Has a route to an Internet Gateway.

Typical resource:

```text
Load Balancer
```

### Private subnet

Doesn't have a direct route for inbound internet access through an Internet Gateway.

Typical resources:

```text
Application servers
Databases
```

Example:

```text
Internet
   |
   v
Load Balancer
   |
   v
Private EC2
   |
   v
Private RDS
```

This is a common production architecture.

---

# 14. What is a VPC Endpoint?

A VPC endpoint allows private connectivity from a VPC to supported AWS services without requiring the same public internet path.

For example:

```text
Private EC2
     |
     v
S3 VPC Endpoint
     |
     v
S3
```

This is particularly useful for private workloads that need AWS services.

---

# 15. Security Group vs NACL — explain in detail.

### Security Group

Works at the resource/network-interface level.

```text
EC2
 |
Security Group
```

Characteristics:

- Stateful
- Primarily allow rules
- Associated with resources/network interfaces

### NACL

Works at subnet level.

```text
Subnet
 |
NACL
```

Characteristics:

- Stateless
- Supports allow and deny rules
- Evaluated for subnet traffic

### Easy interview answer

> Security Groups protect resources such as EC2 and are stateful, whereas Network ACLs operate at the subnet level and are stateless.

---

# SECTION 3 — LOAD BALANCING

# 16. Why do we need a Load Balancer?

Suppose you have:

```text
100,000 users
```

and only one EC2:

```text
Users
  |
  v
EC2
```

This creates a bottleneck and single point of failure.

Instead:

```text
                 Load Balancer
                /      |      \
               /       |       \
            EC2 #1   EC2 #2   EC2 #3
```

The load balancer distributes requests.

---

# 17. What is a health check?

A load balancer periodically checks whether a target is healthy.

For example:

```text
GET /health
```

Response:

```text
200 OK
```

means healthy.

If an instance stops responding:

```text
EC2 #1 → unhealthy
```

the load balancer can stop sending new requests to it according to its health-check behavior.

---

# 18. What is ALB vs NLB?

### ALB — Application Load Balancer

Works at Layer 7.

Useful for:

```text
HTTP
HTTPS
Path-based routing
Host-based routing
```

Example:

```text
example.com/users
        |
        v
Service A

example.com/orders
        |
        v
Service B
```

### NLB — Network Load Balancer

Works at Layer 4.

Designed for high-performance TCP/UDP/TLS use cases.

### Easy memory

```text
ALB → Application/HTTP
NLB → Network/TCP/UDP
```

---

# 19. What is path-based routing?

ALB can route requests based on URL path.

Example:

```text
/api/users/*
       |
       v
User Service

/api/orders/*
       |
       v
Order Service
```

This is useful in microservice architectures.

---

# SECTION 4 — DATABASE QUESTIONS

# 20. RDS vs DynamoDB?

### RDS

Relational database.

Useful when you need:

```text
SQL
Relationships
Joins
Transactions
Structured schemas
```

Example:

```text
Users
Orders
Products
```

### DynamoDB

NoSQL database.

Useful for highly scalable key-value/document workloads.

Example:

```text
UserId → User profile
```

### Interview answer

> I would choose RDS when the application has relational data and SQL requirements. I would consider DynamoDB for highly scalable key-value or document workloads where its access patterns fit the application.

---

# 21. What is a Read Replica?

A read replica is a copy of a database used primarily to serve read traffic.

Example:

```text
                Application
                 /       \
                /         \
           Write          Read
             |              |
             v              v
          Primary       Read Replica
```

Useful when:

```text
Reads >> Writes
```

It can reduce read pressure on the primary database.

---

# 22. Multi-AZ vs Read Replica?

Very common interview question.

### Multi-AZ

Primarily for:

```text
High availability
Failover
```

### Read Replica

Primarily for:

```text
Read scaling
```

Simple memory:

```text
Multi-AZ     → Availability

Read Replica → Read scaling
```

---

# 23. What happens if RDS primary fails?

If configured for a high-availability architecture such as Multi-AZ, RDS can perform failover to the standby according to the configuration.

Your application should be designed to handle connection interruption/retry appropriately.

---

# 24. What is database connection pooling?

Opening a new database connection for every request is expensive.

Instead:

```text
Application
     |
Connection Pool
 |   |   |   |
 DB connections
```

Spring Boot commonly uses HikariCP.

Example:

```text
100 requests
```

Instead of creating 100 new DB connections, the application can reuse connections from a pool.

### Interview follow-up

If the database is overloaded, check:

```text
Connection pool size
Slow queries
Long-running transactions
Database CPU
Connection leaks
```

---

# SECTION 5 — IAM & SECURITY

# 25. IAM User vs IAM Role?

### IAM User

Usually represents a specific identity such as a person or application identity requiring persistent credentials.

### IAM Role

Provides permissions that can be assumed by trusted entities such as AWS services, applications, or users.

For EC2:

```text
EC2
 |
IAM Role
 |
S3
```

### Interview answer

> For an application running on EC2, I prefer an IAM role attached to the instance instead of storing long-term access keys in the application.

---

# 26. What is an explicit Deny?

In AWS policy evaluation, an explicit Deny overrides an Allow.

Example:

```text
IAM Policy
   |
Allow S3 access

Bucket Policy
   |
Explicit Deny
```

Result:

```text
ACCESS DENIED
```

This is why debugging permissions requires checking both allows and denies.

---

# 27. How would you troubleshoot AccessDenied?

I would check:

```text
1. IAM identity policy

2. IAM role

3. Resource policy

4. Explicit Deny

5. Resource ARN

6. KMS permissions

7. VPC endpoint policy

8. SCP if AWS Organizations is involved

9. Permissions boundary if configured

10. Application credentials/configuration
```

### Strong interview answer

> I wouldn't assume that an AccessDenied error is caused only by the IAM policy. I would inspect the complete authorization path, including resource policies, explicit denies, KMS, endpoint policies, and organization-level controls where applicable.

---

# 28. What is MFA?

MFA stands for **Multi-Factor Authentication**.

It requires more than one authentication factor.

Example:

```text
Password
   +
Authenticator code
```

MFA reduces risk if a password is compromised.

---

# 29. What is AWS Organizations?

AWS Organizations lets companies centrally manage multiple AWS accounts.

Example:

```text
AWS Organization
 |
 +-- Production Account
 |
 +-- Development Account
 |
 +-- Testing Account
 |
 +-- Security Account
```

Benefits include:

```text
Central governance
Account separation
Billing management
Service control policies
```

---

# 30. What is an SCP?

SCP stands for **Service Control Policy**.

It is used with AWS Organizations to define permission guardrails for accounts/organizational units.

Important:

> An SCP does not itself grant permissions. It can restrict the maximum available permissions.

Example:

```text
IAM Policy → Allows action

SCP → Denies action

Result → Denied
```

---

# SECTION 6 — MONITORING & TROUBLESHOOTING

# 31. CloudWatch vs CloudTrail?

### CloudWatch

Used for:

```text
Metrics
Logs
Alarms
Dashboards
Monitoring
```

Example:

```text
EC2 CPU = 90%
```

CloudWatch can monitor it.

### CloudTrail

Used to record AWS API activity.

Example:

```text
Who changed the Security Group?
Who deleted the S3 object?
Who modified an IAM policy?
```

### Easy memory

```text
CloudWatch → How is my system performing?

CloudTrail → Who did what in AWS?
```

---

# 32. What is a CloudWatch Alarm?

An alarm monitors a metric and changes state when a configured condition is met.

Example:

```text
CPU > 80%
for 5 minutes
       |
       v
CloudWatch Alarm
```

It can trigger configured actions such as notifications or scaling-related workflows.

---

# 33. How would you monitor a Spring Boot application on AWS?

I would monitor at multiple levels.

### Infrastructure

```text
EC2 CPU
Memory
Disk
Network
```

### Application

```text
Request rate
Response time
Error rate
JVM memory
Garbage collection
Thread usage
```

### Database

```text
CPU
Connections
Latency
Storage
```

### AWS

```text
CloudWatch
CloudTrail
```

Spring Boot Actuator can expose application health and metrics that can be integrated into an observability solution.

---

# 34. Scenario: Application is returning HTTP 500 errors.

What do you check?

Start at the application layer:

```text
Request
  |
  v
Load Balancer
  |
  v
Spring Boot
  |
  X
500
```

Check:

```text
Application logs
Stack trace
Database connectivity
External API
Configuration
Memory/CPU
Recent deployment
```

Then check infrastructure if required.

---

# 35. Scenario: Application returns 502 Bad Gateway.

Possible causes:

```text
Load Balancer/Nginx
       |
       X
Backend unavailable
```

Check:

```text
Backend health
Application process
Port
Security Group
Target group
Health check
Network connectivity
```

### Interview answer

> A 502 generally means the proxy/load-balancer layer couldn't successfully communicate with the backend. I would check target health, application status, port configuration, security rules, and backend logs.

---

# 36. Scenario: Application is very slow.

Don't immediately increase EC2 size.

Investigate:

```text
1. Application latency
2. CPU
3. Memory
4. GC
5. Database queries
6. DB connections
7. External APIs
8. Network latency
9. Load
10. Recent deployments
```

Then identify the bottleneck.

Example:

```text
Request
  |
Spring Boot → 50 ms
  |
Database → 3 seconds
```

The EC2 server may not be the problem.

---

# SECTION 7 — DEPLOYMENT & CI/CD

# 37. What is CI/CD?

### CI

Continuous Integration.

Developers frequently merge code, and automated processes build/test it.

```text
Git
 |
Build
 |
Unit Tests
 |
Package
```

### CD

Continuous Delivery/Deployment.

The software is automatically prepared or deployed to environments.

```text
Git
 |
Build
 |
Test
 |
Deploy
 |
AWS
```

---

# 38. What AWS services can be used for CI/CD?

Examples:

```text
CodePipeline
CodeBuild
CodeDeploy
ECR
ECS
EC2
Lambda
```

You can also integrate AWS deployments with third-party tools such as Jenkins, GitHub Actions, GitLab CI, etc.

---

# 39. How would you deploy a Spring Boot application automatically?

Example:

```text
Developer
    |
    v
Git
    |
    v
CI/CD Pipeline
    |
    v
Build + Test
    |
    v
Docker Image / JAR
    |
    v
Deployment
    |
    v
AWS
```

For EC2:

```text
Build JAR
   |
Deploy to EC2
   |
Restart service
```

For containers:

```text
Build Docker Image
      |
      v
ECR
      |
      v
ECS
```

---

# 40. What is ECR?

ECR stands for **Elastic Container Registry**.

It is a managed container image registry.

Example:

```text
Spring Boot
    |
Docker Build
    |
Docker Image
    |
    v
ECR
    |
    v
ECS
```

---

# 41. What is blue-green deployment?

Two environments are maintained:

```text
Blue → Current version
Green → New version
```

Example:

```text
                Load Balancer
                     |
              Current traffic
                     |
                    Blue
```

Deploy new version:

```text
Blue → Version 1

Green → Version 2
```

Test Green.

Then switch traffic:

```text
                Load Balancer
                     |
                     v
                   Green
```

Benefits:

```text
Fast rollback
Reduced deployment risk
Minimal downtime
```

---

# 42. What is rolling deployment?

Instead of replacing every server at once, update instances gradually.

```text
Before:

EC2 #1 → v1
EC2 #2 → v1
EC2 #3 → v1

During:

EC2 #1 → v2
EC2 #2 → v1
EC2 #3 → v1

Then:

EC2 #1 → v2
EC2 #2 → v2
EC2 #3 → v2
```

This can reduce downtime and deployment risk.

---

# SECTION 8 — S3 ADVANCED QUESTIONS

# 43. What is the difference between S3 and EBS?

### S3

```text
Object storage
```

Good for:

```text
Images
Documents
Backups
Videos
```

### EBS

```text
Block storage
```

Good for:

```text
EC2 filesystem
Application disk
Database disk
```

### Memory trick

```text
S3 → Files as objects

EBS → Disk for EC2
```

---

# 44. Why shouldn't you store user-uploaded files on EC2 local disk?

Suppose:

```text
EC2 #1
 |
uploads/
```

Then Auto Scaling creates:

```text
EC2 #2
```

EC2 #2 doesn't automatically have the same local files.

Better:

```text
EC2 #1 \
        \
         S3
        /
EC2 #2 /
```

This makes application instances more independent.

---

# 45. What is S3 pre-signed URL?

A pre-signed URL gives temporary access to an S3 object.

Example:

```text
User
 |
 v
Spring Boot
 |
Generate temporary URL
 |
 v
User
 |
 v
S3
```

The bucket can remain private.

---

# 46. Why use pre-signed URLs?

Suppose users upload 2 GB files.

Without pre-signed URL:

```text
User
 |
 v
Spring Boot
 |
 v
EC2
 |
 v
S3
```

EC2 handles the file traffic.

With direct upload:

```text
User
 |
 +-----------------> S3
 |
Spring Boot
 |
Generate URL
```

This can reduce application-server bandwidth and processing.

---

# SECTION 9 — LAMBDA & SERVERLESS

# 47. What is serverless?

Serverless does not mean there are no servers.

It means you don't directly manage the underlying server infrastructure for the service.

Example:

```text
S3 Event
   |
   v
Lambda
   |
   v
Process File
```

AWS manages the underlying execution infrastructure.

---

# 48. When would you use Lambda?

Good examples:

```text
Image processing
Scheduled jobs
Event processing
Lightweight APIs
Automation
S3 event processing
```

Example:

```text
User uploads image
       |
       v
S3
       |
       v
Lambda
       |
       v
Resize image
```

---

# 49. What are Lambda limitations you should know?

For interviews, understand:

```text
Execution duration limits
Memory limits
Concurrency
Cold starts
Stateless execution model
Package/deployment limits
```

Don't treat Lambda like a permanent EC2 server.

---

# SECTION 10 — QUEUES & MICROSERVICES

# 50. Why use SQS between microservices?

Without queue:

```text
Order Service
      |
      v
Payment Service
```

If Payment Service is down:

```text
Order Service
      |
      X
Payment Service
```

With SQS:

```text
Order Service
      |
      v
     SQS
      |
      v
Payment Worker
```

The message waits in the queue until the consumer processes it.

Benefits:

```text
Decoupling
Asynchronous processing
Load smoothing
Retry capability
Fault isolation
```

---

# 51. What is a Dead Letter Queue?

A DLQ stores messages that could not be successfully processed after configured retry attempts.

Example:

```text
SQS
 |
Consumer
 |
Processing fails
 |
Retry
 |
Retry
 |
Retry
 |
 v
DLQ
```

This prevents a problematic message from continuously blocking normal processing.

---

# 52. What is message visibility timeout in SQS?

When a consumer receives a message, SQS temporarily hides that message from other consumers for the configured visibility timeout.

Concept:

```text
SQS
 |
Message
 |
Consumer receives
 |
Visibility timeout
 |
Consumer processes
 |
Delete message
```

If the consumer doesn't delete it within the required time, the message can become visible again.

This is important for designing reliable consumers.

---

# SECTION 11 — REAL PRODUCTION SCENARIOS

# 53. Scenario: Your application suddenly receives 10x traffic.

My approach:

```text
1. Check CloudWatch metrics

2. Check CPU/memory

3. Check load balancer metrics

4. Check database load

5. Check application latency

6. Check error rate

7. Verify Auto Scaling

8. Scale horizontally if required

9. Check caching/CDN opportunities

10. Identify the bottleneck
```

Architecture:

```text
Users
 |
Load Balancer
 |
Auto Scaling Group
 |
EC2 #1
EC2 #2
EC2 #3
 |
RDS
 |
S3
```

---

# 54. Scenario: One Availability Zone goes down.

If your application is deployed only in that AZ:

```text
AZ-1
 |
EC2
 X
 |
Application Down
```

Better:

```text
              Load Balancer
              /           \
             /             \
          AZ-1             AZ-2
           |                |
         EC2              EC2
```

Traffic can continue through healthy capacity in another AZ.

---

# 55. Scenario: Database is the bottleneck.

Suppose:

```text
EC2 CPU = 30%
RDS CPU = 95%
```

Increasing EC2 size won't solve the root cause.

Investigate:

```text
Slow queries
Indexes
Connection pool
Locks
Read/write ratio
Database capacity
```

Possible solutions:

```text
Query optimization
Read replicas
Caching
Database scaling
Connection-pool tuning
```

---

# 56. Scenario: Users report that images are loading slowly.

If images are stored in S3:

```text
User
 |
 v
S3
```

Consider:

```text
CloudFront
Image optimization
Caching
Appropriate object metadata
```

Architecture:

```text
User
 |
 v
CloudFront
 |
 v
S3
```

CloudFront can cache frequently requested content closer to users.

---

# 57. Scenario: Your application is deployed in one EC2 instance and that instance fails.

Current:

```text
User
 |
EC2
 X
```

Improved:

```text
             Load Balancer
              /        \
             /          \
          EC2 #1       EC2 #2
```

Then use:

```text
Auto Scaling Group
Multiple AZs
Health checks
```

for better resilience.

---

# 58. Scenario: Your application is working but users are getting intermittent errors.

This is a very good troubleshooting question.

Possible architecture:

```text
Load Balancer
 /          \
EC2 #1      EC2 #2
```

Maybe:

```text
EC2 #1 → Healthy
EC2 #2 → Buggy
```

Some requests succeed and some fail.

Check:

```text
Target health
Application logs per instance
Load balancer logs/metrics
Deployment versions
Configuration differences
```

### Strong answer

> Because the issue is intermittent, I would compare instances individually rather than assuming the entire application is broken. I would check target health, instance-level logs, configuration, deployment version, and load-balancer metrics.

---

# 59. Scenario: Deployment succeeded but application is returning errors.

Don't immediately roll back without investigation.

Check:

```text
Application logs
Environment variables
Secrets
Database migration
Dependencies
Port configuration
Health checks
IAM permissions
Recent code changes
```

If the new version is confirmed to be faulty:

```text
Rollback
```

Then investigate root cause.

---

# 60. Scenario: Your application cannot connect to RDS.

Check:

```text
1. RDS status

2. RDS endpoint

3. Port

4. Security Group

5. Network/subnet routing

6. Credentials

7. Database availability

8. DNS resolution

9. Connection pool

10. Application configuration
```

Example:

```text
EC2
 |
Security Group
 |
RDS Security Group
 |
RDS
```

A common secure pattern is to allow the database Security Group to accept traffic only from the application Security Group rather than from the entire internet.

---

# 61. Scenario: RDS is accessible from your laptop but not from EC2.

Check:

```text
Network routing
Security Groups
Subnet
DNS
RDS accessibility
Port
EC2 outbound rules
```

Don't simply open RDS to:

```text
0.0.0.0/0
```

That is usually a serious security mistake for a production database.

---

# 62. Scenario: How would you secure RDS?

A common architecture:

```text
Internet
   |
   v
Load Balancer
   |
   v
Private EC2
   |
   v
Private RDS
```

Security Group:

```text
RDS Security Group
       |
Allow DB port
       |
Source = Application Security Group
```

This is better than allowing the whole internet to reach the database.

---

# 63. Scenario: How would you store database credentials?

Avoid:

```text
application.properties

username=admin
password=secret123
```

Prefer a secrets/configuration service such as:

```text
AWS Secrets Manager
```

Architecture:

```text
Spring Boot
    |
    v
Secrets Manager
    |
    v
DB Credentials
```

Use IAM permissions to control access.

---

# 64. Scenario: How would you design a highly available Spring Boot application?

A good answer:

```text
                    Users
                      |
                      v
                  Route 53
                      |
                      v
                Load Balancer
                 /         \
                /           \
             AZ-1          AZ-2
              |              |
             EC2            EC2
              \              /
               \            /
                    RDS
                     |
                    S3
```

Add:

```text
Auto Scaling
CloudWatch
IAM
Secrets Manager
CloudFront where appropriate
Backup/DR
```

---

# 65. Scenario: How would you migrate a Spring Boot application from on-premises to AWS?

I would approach it in phases.

### Step 1 — Analyze

```text
Application dependencies
Database
Storage
Network
Traffic
Security
```

### Step 2 — Choose AWS services

For example:

```text
Spring Boot → EC2/ECS
Database → RDS
Files → S3
DNS → Route 53
Load balancing → ALB
Monitoring → CloudWatch
Secrets → Secrets Manager
```

### Step 3 — Deploy

```text
AWS environment
 |
Application
 |
Database
 |
Storage
```

### Step 4 — Test

```text
Functional
Performance
Security
Failover
```

### Step 5 — Cut over

Move production traffic gradually or during a planned migration window.

---

# SECTION 12 — INTERVIEWER FOLLOW-UP QUESTIONS

These are questions interviewers often ask after your first answer.

### If you say "I use EC2"

They may ask:

```text
Why EC2?
Why not ECS?
Why not Lambda?
How do you scale EC2?
How do you secure EC2?
How do you monitor it?
What happens if EC2 fails?
```

---

### If you say "I use S3"

They may ask:

```text
Why S3?
How do you secure S3?
How does EC2 access S3?
What is versioning?
What is lifecycle?
What is a pre-signed URL?
What happens if S3 returns 403?
```

---

### If you say "I use RDS"

They may ask:

```text
Why RDS?
Multi-AZ?
Read Replica?
Backup?
Failover?
How does EC2 connect to RDS?
How do you secure RDS?
```

---

### If you say "I use Load Balancer"

They may ask:

```text
Why?
ALB vs NLB?
Health check?
What happens if one EC2 fails?
How does Auto Scaling work with it?
```

---

# SECTION 13 — VERY IMPORTANT "DESIGN THIS" QUESTION

## 66. Design an AWS architecture for an e-commerce Spring Boot application.

A strong answer:

```text
                         USERS
                           |
                           v
                       Route 53
                           |
                           v
                      CloudFront
                           |
                           v
                    Application LB
                     /           \
                    /             \
                 EC2             EC2
              Spring Boot     Spring Boot
                    |             |
                    +------+------+
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
            RDS           S3            SQS
             |             |             |
        Application      Images       Async jobs
           data          invoices
             |
             v
        Read Replica

           |
           v
       CloudWatch

           |
           v
        CloudTrail
```

Security:

```text
IAM
Security Groups
Private Subnets
Secrets Manager
KMS
Encryption
Least Privilege
```

Scaling:

```text
ALB
+
Auto Scaling
+
Caching
+
Database scaling
```

---

# SECTION 14 — HOW TO ANSWER AWS SCENARIO QUESTIONS

When interviewer gives you a problem, don't start randomly naming AWS services.

Use this approach:

```text
                PROBLEM
                   |
                   v
             Identify layer
                   |
       +-----------+-----------+
       |           |           |
 Application    Network    Infrastructure
       |           |           |
       +-----------+-----------+
                   |
                   v
             Check metrics
                   |
                   v
             Check logs
                   |
                   v
            Find root cause
                   |
                   v
                 Fix
                   |
                   v
          Prevent recurrence
```

### Example

Interviewer:

> "Our Spring Boot application is suddenly slow. What will you do?"

Bad answer:

> "I will increase EC2 size."

Better:

> "First I would determine where the latency is coming from. I would check CloudWatch metrics for EC2, load balancer metrics, application logs and JVM metrics, then check database latency and connection usage. I would also check whether traffic increased or a recent deployment introduced a regression. Once I identify the bottleneck, I would apply the appropriate fix, such as query optimization, scaling, caching, or application optimization."

That sounds much more like a production engineer.

---

# SECTION 15 — 30 HIGH-VALUE QUESTIONS TO PRACTICE

Prepare these particularly well:

```text
1. What is AWS?

2. What is EC2?

3. What is AMI?

4. What is EBS?

5. What is S3?

6. What is IAM?

7. IAM User vs Role?

8. What is least privilege?

9. What is VPC?

10. Public vs private subnet?

11. Security Group vs NACL?

12. Internet Gateway vs NAT Gateway?

13. What is a Route Table?

14. What is an ALB?

15. ALB vs NLB?

16. What is Auto Scaling?

17. What is RDS?

18. Multi-AZ vs Read Replica?

19. RDS vs DynamoDB?

20. What is CloudWatch?

21. CloudWatch vs CloudTrail?

22. What is Route 53?

23. What is CloudFront?

24. What is SQS?

25. SQS vs SNS?

26. What is Lambda?

27. EC2 vs Lambda?

28. What is Secrets Manager?

29. What is KMS?

30. How would you deploy and secure a Spring Boot application on AWS?
```

---

# SECTION 16 — 15 SCENARIOS YOU SHOULD DEFINITELY PRACTICE

```text
1. EC2 application is not accessible.

2. Application works locally but not on AWS.

3. EC2 CPU reaches 100%.

4. EC2 memory is full.

5. EC2 disk is full.

6. EC2 cannot access S3.

7. S3 returns AccessDenied.

8. EC2 cannot connect to RDS.

9. RDS becomes slow.

10. One EC2 instance fails.

11. Traffic increases 10x.

12. Application returns intermittent 502/500 errors.

13. Deployment causes production errors.

14. Users complain that images are slow.

15. Design a highly available Spring Boot application.
```

---

# FINAL INTERVIEW FORMULA

For almost every AWS scenario, remember:

```text
                    USER REQUEST
                         |
                         v
                       DNS
                         |
                         v
                    Load Balancer
                         |
                         v
                       EC2
                         |
              +----------+----------+
              |                     |
              v                     v
             RDS                   S3
              |
              v
         Application Data
```

And around the architecture:

```text
IAM          → Who can access?
Security     → How is it protected?
VPC          → How does traffic flow?
ALB          → How is traffic distributed?
ASG          → How does it scale?
RDS          → Where is relational data?
S3           → Where are files?
SQS          → How are async jobs handled?
CloudWatch   → How do we monitor?
CloudTrail   → Who changed what?
Secrets      → Where do credentials live?
KMS          → How is encryption managed?
```

### The most important interview skill

Don't answer AWS questions only with definitions.

For every service, learn these **5 things**:

```text
1. What is it?
2. Why do we use it?
3. How does it work?
4. What problem does it solve?
5. What happens when it fails?
```

For example, for **S3**:

```text
What?       → Object storage

Why?        → Store files at scale

How?        → Bucket + object + key + API

Problem?    → Shared durable file/object storage

Failure?    → Check IAM, bucket policy, KMS,
               network, object key, etc.
```

That approach will prepare you much better for **real AWS interviews** than memorizing definitions alone.