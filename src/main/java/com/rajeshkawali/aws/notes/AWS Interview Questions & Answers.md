# AWS INTERVIEW QUESTIONS & ANSWERS
## Most Asked Questions for Java / Spring Boot Developers

---

# 1. What is AWS?

### Answer

AWS stands for **Amazon Web Services**. It is a cloud platform that provides services for computing, storage, databases, networking, security, monitoring, messaging, and many other purposes.

Instead of purchasing and maintaining physical servers, we can use AWS infrastructure on demand.

### Common AWS services

```text
Compute       → EC2
Storage       → S3
Database      → RDS
Networking    → VPC
Security      → IAM
Load Balancer → ALB
Scaling       → Auto Scaling
Monitoring    → CloudWatch
DNS           → Route 53
Messaging     → SQS / SNS
Containers    → ECS / EKS
```

### Example

Instead of:

```text
Company
   |
Physical Server
   |
Spring Boot Application
```

we can use:

```text
AWS
 |
EC2
 |
Spring Boot Application
```

---

# 2. What is EC2?

### Answer

EC2 stands for **Elastic Compute Cloud**.

It provides virtual servers in AWS where we can run applications.

For example, we can deploy a Spring Boot JAR on an EC2 instance.

```text
Internet
    |
    v
   EC2
    |
    v
Spring Boot
    |
    v
Database
```

### Important EC2 concepts

```text
AMI
Instance Type
EBS
Security Group
Key Pair
Public IP
Private IP
Elastic IP
VPC
Subnet
```

### Interview answer

> EC2 is an AWS compute service that provides resizable virtual servers to run applications.

---

# 3. What is an AMI?

AMI stands for **Amazon Machine Image**.

It is a template used to launch an EC2 instance.

It can contain:

```text
Operating System
Application configuration
Installed software
Required packages
```

Example:

```text
AMI
 |
 +-- Ubuntu
 +-- Java
 +-- Application configuration
```

When you launch EC2:

```text
AMI
 |
 v
EC2 Instance
```

### Simple way to remember

> AMI is a template; EC2 is the running server created from that template.

---

# 4. What is an EC2 instance type?

An instance type determines the resources available to the EC2 instance.

Examples of resources:

```text
CPU
Memory
Network performance
Storage characteristics
```

For example, a small application may need less CPU and memory than a high-traffic production application.

### Interview answer

> EC2 instance types define the compute resources and characteristics of an EC2 instance.

---

# 5. What is EBS?

EBS stands for **Elastic Block Store**.

It provides block storage volumes that can be attached to EC2 instances.

Think of EBS as a disk attached to your EC2 server.

```text
EC2
 |
 +---- EBS Volume
       |
       +-- Application files
       +-- Logs
       +-- Other data
```

### EBS vs S3

```text
EBS → Block storage → Usually attached to EC2

S3  → Object storage → Stores objects/files
```

---

# 6. What is S3?

S3 stands for **Simple Storage Service**.

It is AWS object storage.

Common uses:

```text
Images
Videos
PDFs
Documents
Backups
Logs
Static files
```

Example:

```text
Spring Boot
     |
     v
    S3
     |
     +-- profile.jpg
     +-- invoice.pdf
     +-- report.xlsx
```

### Interview answer

> S3 is a highly scalable object storage service used to store and retrieve files and other objects.

---

# 7. What is an S3 bucket?

A bucket is a container for objects.

Example:

```text
my-company-bucket
       |
       +-- images/
       +-- documents/
       +-- backups/
```

An S3 object has a key, such as:

```text
users/123/profile.jpg
```

---

# 8. What is S3 Versioning?

Versioning allows multiple versions of an object to be retained.

Example:

```text
report.pdf

Version 1
Version 2
Version 3
```

If someone accidentally overwrites or deletes an object, previous versions may be recoverable depending on the operation and configuration.

### Good interview sentence

> I would enable S3 Versioning for important data where recovery from accidental overwrite or deletion is required.

---

# 9. What are S3 storage classes?

S3 provides different storage classes for different access patterns and cost requirements.

Common examples:

```text
S3 Standard
S3 Intelligent-Tiering
S3 Standard-IA
S3 One Zone-IA
S3 Glacier Instant Retrieval
S3 Glacier Flexible Retrieval
S3 Glacier Deep Archive
```

Basic idea:

```text
Frequently accessed
       ↓
S3 Standard

Infrequently accessed
       ↓
IA classes

Archive
       ↓
Glacier classes
```

---

# 10. What is an S3 Lifecycle Policy?

A lifecycle policy automatically transitions or expires objects based on configured rules.

Example:

```text
Day 0
  |
  v
S3 Standard
  |
  | after required period
  v
Lower-cost storage
  |
  | later
  v
Glacier
  |
  | after retention period
  v
Delete
```

Useful for:

```text
Old logs
Backups
Temporary files
Archived documents
```

---

# 11. What is IAM?

IAM stands for **Identity and Access Management**.

It controls who can access AWS resources and what they can do.

Main concepts:

```text
User
Group
Role
Policy
```

Example:

```text
Developer
   |
   v
IAM
   |
   +-- EC2
   +-- S3
   +-- RDS
```

### Interview answer

> IAM is AWS's service for managing authentication and authorization to AWS resources.

---

# 12. What is an IAM Role?

An IAM Role provides permissions that can be assumed by AWS services or other trusted entities.

For example, an EC2 instance can have an IAM role allowing it to access S3.

```text
EC2
 |
IAM Role
 |
IAM Policy
 |
S3
```

This is preferable to putting long-term AWS access keys inside the application.

### Very important interview question

**How does your Spring Boot application running on EC2 access S3?**

Answer:

> I would attach an IAM role to the EC2 instance and grant the role only the required S3 permissions. The application can use the AWS SDK's credential provider chain rather than hardcoding access keys.

---

# 13. What is an IAM Policy?

An IAM policy is a JSON document that defines permissions.

Example concept:

```text
Allow
  |
  Action: s3:GetObject
  |
  Resource: specific S3 objects
```

A policy generally describes:

```text
Effect
Action
Resource
Condition
Principal
```

depending on the policy type.

---

# 14. What is the principle of least privilege?

Give only the permissions that are required.

Bad:

```text
s3:*
```

Better:

```text
s3:GetObject
s3:PutObject
```

only for the required bucket/object resources.

### Interview answer

> Least privilege means giving a user, role, or application only the minimum permissions necessary to perform its job.

---

# 15. What is a Security Group?

A Security Group acts as a virtual firewall for AWS resources such as EC2.

Example:

```text
Internet
   |
   | HTTPS :443
   v
Security Group
   |
   v
EC2
```

Typical rules:

```text
22   → SSH
80   → HTTP
443  → HTTPS
8080 → Spring Boot, if directly exposed
```

### Important

Security Groups are **stateful**.

---

# 16. What is a VPC?

VPC stands for **Virtual Private Cloud**.

It is your logically isolated network environment in AWS.

It can contain:

```text
Subnets
Route Tables
Internet Gateway
NAT Gateway
Security Groups
Network ACLs
```

Example:

```text
VPC
 |
 +-------------------+
 |                   |
Public Subnet     Private Subnet
 |                   |
EC2/LB              EC2/RDS
```

---

# 17. What is a subnet?

A subnet is a range of IP addresses inside a VPC.

Subnets are generally categorized as public or private based on their routing.

Example:

```text
VPC
 |
 +-- Public Subnet
 |      |
 |      +-- Load Balancer
 |
 +-- Private Subnet
        |
        +-- Application
        +-- Database
```

---

# 18. What is a public subnet?

A subnet is considered public when its routing allows resources with appropriate public addressing to reach the internet through an Internet Gateway.

Example:

```text
Internet
    |
Internet Gateway
    |
Public Subnet
    |
Load Balancer
```

---

# 19. What is a private subnet?

A private subnet doesn't have a direct route to an Internet Gateway for inbound internet access.

Example:

```text
Internet
   X
   |
Private Subnet
   |
EC2 / RDS
```

Private subnets are commonly used for application servers and databases.

---

# 20. What is an Internet Gateway?

An Internet Gateway provides a path between a VPC and the internet for resources/subnets whose routing and addressing permit it.

Typical architecture:

```text
Internet
   |
   v
Internet Gateway
   |
   v
Public Subnet
   |
   v
Load Balancer
```

---

# 21. What is a NAT Gateway?

NAT Gateway allows resources in a private subnet to initiate connections to external destinations while not allowing unsolicited inbound internet connections directly to those private resources.

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

Typical use:

> A private EC2 instance needs to download packages or call an external API.

---

# 22. Security Group vs NACL

Very common interview question.

| Security Group | NACL |
|---|---|
| Resource-level control | Subnet-level control |
| Stateful | Stateless |
| Primarily allow rules | Allow and deny rules |
| Applied to ENI/resources | Applied to subnet |

### Easy memory trick

```text
Security Group → Instance/resource

NACL → Subnet
```

---

# 23. What is an Elastic IP?

An Elastic IP is a static public IPv4 address that you can associate with AWS resources such as EC2 where supported.

Normal public IPs can change when an instance is stopped and started.

Use a stable address when your architecture specifically requires one, although DNS/load balancers are generally preferred for application endpoints.

---

# 24. What is RDS?

RDS stands for **Relational Database Service**.

It is a managed relational database service.

It supports engines such as:

```text
PostgreSQL
MySQL
MariaDB
Oracle
SQL Server
```

Example:

```text
Spring Boot
     |
     v
    RDS
     |
     +-- MySQL/PostgreSQL
```

AWS handles many operational tasks such as provisioning, backups, patching options, and infrastructure management.

---

# 25. Why use RDS instead of installing MySQL on EC2?

If you install MySQL yourself:

```text
EC2
 |
MySQL
```

you are responsible for much more operational work.

With RDS:

```text
Spring Boot
    |
    v
RDS
    |
Managed database service
```

RDS provides managed features such as backups, maintenance capabilities, monitoring integration, and high-availability options depending on configuration.

---

# 26. What is Multi-AZ in RDS?

Multi-AZ is used to improve database availability.

Conceptually:

```text
Availability Zone A
       |
    Primary
       |
       | replication
       v
Availability Zone B
       |
    Standby
```

If the primary becomes unavailable, RDS can perform a failover according to its configured Multi-AZ architecture.

### Important interview point

> Multi-AZ is primarily for high availability, not simply for increasing read capacity.

---

# 27. What is an Application Load Balancer?

ALB stands for **Application Load Balancer**.

It distributes incoming application traffic across multiple targets.

Example:

```text
Users
  |
  v
ALB
 |
 +--------+--------+
 |                 |
EC2 #1           EC2 #2
 |                 |
Spring Boot      Spring Boot
```

Benefits:

```text
High availability
Traffic distribution
Health checks
Scalability
```

---

# 28. What is Auto Scaling?

Auto Scaling automatically adjusts the number of EC2 instances based on configured policies and health.

Example:

```text
Normal traffic

EC2 #1
EC2 #2
```

Traffic increases:

```text
EC2 #1
EC2 #2
EC2 #3
EC2 #4
```

Traffic decreases:

```text
EC2 #1
EC2 #2
```

This helps maintain application capacity while controlling cost.

---

# 29. What is an Auto Scaling Group?

An Auto Scaling Group, or ASG, manages a group of EC2 instances according to configured capacity and scaling rules.

Example:

```text
ASG
 |
 +-- EC2 #1
 +-- EC2 #2
 +-- EC2 #3
```

If an instance becomes unhealthy, the ASG can replace it according to its health-check configuration.

---

# 30. What is CloudWatch?

CloudWatch is AWS's monitoring and observability service.

It can provide:

```text
Metrics
Logs
Alarms
Dashboards
Events / automation capabilities
```

Example:

```text
EC2
 |
 v
CloudWatch
 |
 +-- CPU
 +-- Network
 +-- Logs
 +-- Alarms
```

### Example

If CPU usage remains above a threshold:

```text
CPU > threshold
       |
       v
CloudWatch Alarm
       |
       v
Scaling action / notification
```

---

# 31. What is Route 53?

Route 53 is AWS's DNS service.

Example:

```text
myapp.com
    |
    v
Route 53
    |
    v
Load Balancer
    |
    v
EC2
```

It can also provide DNS routing and health-check-related capabilities.

---

# 32. What is SQS?

SQS stands for **Simple Queue Service**.

It is a managed message queue.

Instead of directly calling another service:

```text
Service A
   |
   v
Service B
```

you can use:

```text
Service A
   |
   v
SQS
   |
   v
Service B
```

This decouples the services.

### Example

Order processing:

```text
Spring Boot
    |
    v
SQS
    |
    v
Order Worker
```

The producer doesn't have to wait for the worker to finish processing.

---

# 33. What is SNS?

SNS stands for **Simple Notification Service**.

It is commonly used for publish/subscribe messaging and notifications.

Example:

```text
Application
    |
    v
SNS Topic
   / \
  /   \
Email  SQS
```

### SQS vs SNS

```text
SQS → Queue
SNS → Pub/Sub / notification
```

---

# 34. SQS vs SNS — when would you use each?

### SQS

Use when you want:

```text
Message queue
Asynchronous processing
Decoupling
Worker-based processing
```

### SNS

Use when you want:

```text
Publish/subscribe
One message to multiple subscribers
Notifications/events
```

They can also be used together.

---

# 35. What is CloudFront?

CloudFront is AWS's content delivery network (CDN).

It caches content closer to users through edge locations.

Example:

```text
User
 |
 v
CloudFront
 |
 +---- S3
 |
 +---- Load Balancer
```

Useful for:

```text
Images
CSS
JavaScript
Videos
API/content acceleration
```

---

# 36. What is the difference between S3 and CloudFront?

```text
S3
→ Stores the data

CloudFront
→ Delivers/caches content closer to users
```

Example:

```text
User
 |
 v
CloudFront
 |
 v
S3
```

---

# 37. What is a pre-signed URL?

A pre-signed URL provides temporary access to an S3 object without making the object publicly accessible.

Example:

```text
User
 |
 v
Spring Boot
 |
Generate pre-signed URL
 |
 v
User
 |
 v
S3
```

Useful for:

```text
Private downloads
Direct uploads
Large files
```

---

# 38. What is AWS Lambda?

Lambda is a serverless compute service.

You provide code, and AWS runs it in response to events or requests.

Example:

```text
S3 Upload
    |
    v
Lambda
    |
    v
Process Image
```

You don't manage a traditional EC2 server for that function.

---

# 39. EC2 vs Lambda

| EC2 | Lambda |
|---|---|
| Virtual server | Serverless function |
| You manage the OS | AWS manages infrastructure |
| Long-running applications | Event/request-driven workloads |
| More control | Less infrastructure management |
| You choose instance capacity | AWS manages execution scaling |

For a traditional Spring Boot application, EC2/ECS/EKS may be appropriate depending on the architecture.

---

# 40. What is ECS?

ECS stands for **Elastic Container Service**.

It is a managed AWS service for running containers.

Example:

```text
Spring Boot
    |
Docker Image
    |
    v
ECS
    |
    v
Containers
```

---

# 41. ECS vs EC2?

EC2:

```text
You manage the server
      |
      v
Run Spring Boot
```

ECS:

```text
Container
    |
    v
ECS
    |
AWS manages orchestration
```

ECS can run containers using different infrastructure options, including AWS Fargate or EC2 capacity.

---

# 42. What is Fargate?

AWS Fargate is a serverless compute engine for containers.

You run containers without directly managing the underlying EC2 instances.

Architecture:

```text
Docker Container
      |
      v
ECS + Fargate
```

---

# 43. What is EKS?

EKS stands for **Elastic Kubernetes Service**.

It is AWS's managed Kubernetes service.

Example:

```text
Spring Boot Containers
        |
        v
Kubernetes
        |
        v
EKS
```

It is useful when an organization uses Kubernetes for container orchestration.

---

# 44. What is the difference between ECS and EKS?

```text
ECS → AWS container orchestration service

EKS → Managed Kubernetes
```

For an organization already standardized on Kubernetes, EKS may be appropriate.

---

# 45. What is High Availability?

High Availability means designing a system to remain available despite failures.

Bad:

```text
User
 |
EC2
```

If EC2 fails, application goes down.

Better:

```text
             Load Balancer
              /         \
             /           \
          EC2 #1        EC2 #2
```

Ideally place capacity across multiple Availability Zones.

---

# 46. What is an Availability Zone?

An Availability Zone is an isolated location within an AWS Region.

Example:

```text
Region
 |
 +-- AZ-1
 |
 +-- AZ-2
 |
 +-- AZ-3
```

Using multiple AZs helps improve availability.

---

# 47. What is an AWS Region?

A Region is a geographic AWS infrastructure location containing multiple Availability Zones.

Example:

```text
Region
 |
 +-- Availability Zone 1
 +-- Availability Zone 2
 +-- Availability Zone 3
```

When selecting a region, consider:

```text
Latency
Cost
Service availability
Compliance/data residency
Disaster recovery
```

---

# 48. Region vs Availability Zone

Very common question.

```text
Region
  |
  +-- AZ
  +-- AZ
  +-- AZ
```

### Region

Geographic AWS location.

### Availability Zone

An isolated location within a Region.

---

# 49. What is an Elastic Load Balancer?

ELB is the family of AWS load-balancing services.

Common types include:

```text
Application Load Balancer
Network Load Balancer
Gateway Load Balancer
```

For typical HTTP/HTTPS Spring Boot applications, an **Application Load Balancer** is commonly considered.

---

# 50. How would you deploy a Spring Boot application on AWS?

A common simple architecture:

```text
Internet
   |
   v
Load Balancer
   |
   v
EC2
   |
Spring Boot
   |
   +---- RDS
   |
   +---- S3
```

Deployment steps:

```text
1. Build Spring Boot JAR

2. Launch EC2

3. Configure Security Group

4. Install Java

5. Copy JAR to EC2

6. Start application

7. Configure systemd

8. Put Load Balancer/Nginx in front

9. Configure domain using Route 53

10. Monitor using CloudWatch
```

---

# 51. How does EC2 access S3 securely?

Best practice:

```text
Spring Boot
     |
     v
EC2
     |
     v
IAM Role
     |
     v
S3
```

Avoid:

```text
application.properties

aws.access-key=xxxxx
aws.secret-key=xxxxx
```

Instead use:

```text
EC2 IAM Role
```

and the AWS SDK credential provider chain.

---

# 52. How do you secure an AWS application?

A good interview answer:

> I would use IAM least privilege, private subnets where appropriate, Security Groups, encryption at rest and in transit, secrets management, logging and monitoring, restricted network access, and regular security reviews.

Typical architecture:

```text
Internet
   |
HTTPS
   |
Load Balancer
   |
Private EC2
   |
Private RDS
```

---

# 53. What is AWS Secrets Manager?

Secrets Manager securely stores sensitive information such as:

```text
Database passwords
API keys
Credentials
Application secrets
```

Instead of:

```text
application.properties

password=myPassword123
```

use:

```text
Spring Boot
    |
    v
Secrets Manager
    |
    v
Secret
```

The application retrieves the secret using appropriate IAM permissions.

---

# 54. Secrets Manager vs Parameter Store

Both can store configuration/secrets.

Basic distinction:

```text
Secrets Manager
→ Strong focus on secrets and secret lifecycle/rotation capabilities

Parameter Store
→ Configuration parameters and secrets, often used for simpler configuration management
```

Choose based on application and operational requirements.

---

# 55. What is KMS?

KMS stands for **Key Management Service**.

It is used to create and manage cryptographic keys and integrate encryption into AWS services.

Example:

```text
S3
 |
KMS Key
 |
Encryption
```

Commonly used with:

```text
S3
EBS
RDS
Secrets Manager
```

---

# 56. What is CloudTrail?

CloudTrail records AWS API activity.

Example:

```text
Someone
   |
   v
AWS API
   |
   v
CloudTrail
```

It can help answer:

```text
Who performed the action?
What action was performed?
When?
From where?
```

### CloudWatch vs CloudTrail

```text
CloudWatch
→ Monitoring, metrics, logs, alarms

CloudTrail
→ AWS API activity/auditing
```

---

# 57. What is AWS Backup?

AWS Backup provides centralized backup capabilities for supported AWS resources.

It can help manage:

```text
Backups
Retention
Recovery
Centralized backup policies
```

---

# 58. What is Disaster Recovery?

Disaster Recovery means preparing to recover systems after a major failure.

Example:

```text
Primary Region
      |
      | replication/backup
      v
DR Region
```

You should consider:

```text
RTO
RPO
Cost
Data replication
Application dependencies
DNS failover
```

---

# 59. What is RTO?

RTO = **Recovery Time Objective**.

It defines how quickly the system should be restored after a failure.

Example:

```text
RTO = 1 hour
```

means the target is to restore service within about one hour.

---

# 60. What is RPO?

RPO = **Recovery Point Objective**.

It defines how much data loss, measured in time, is acceptable after a failure.

Example:

```text
RPO = 15 minutes
```

means the business can tolerate losing up to approximately 15 minutes of data, depending on the recovery design.

### Easy memory

```text
RTO → How fast can I recover?

RPO → How much data can I lose?
```

---

# PART 14 — MOST ASKED SCENARIO QUESTIONS

# 61. Scenario: Your Spring Boot application is not accessible from the internet. What do you check?

Answer in this order:

```text
1. Is EC2 running?

2. Is Spring Boot running?

3. Is the application listening on the expected port?

4. Is the Security Group allowing the required traffic?

5. Is the subnet routing configured correctly?

6. Does the instance have appropriate public connectivity?

7. Is Nginx/load balancer configured correctly?

8. Check application logs.

9. Check CloudWatch metrics/logs if configured.
```

### Strong interview answer

> I would troubleshoot from the application layer outward: first verify the process and listening port, then check the OS/network configuration, Security Group, subnet routing, load balancer or Nginx, and finally logs and metrics to identify the root cause.

---

# 62. Scenario: CPU is 100% on EC2. What do you do?

First investigate:

```text
top
htop
```

Then check:

```text
Which process is consuming CPU?
Spring Boot/JVM?
Traffic spike?
Infinite loop?
Database issue?
Garbage collection?
```

Then:

```text
Check CloudWatch
Check application logs
Check JVM metrics
Analyze traffic
Optimize code
Scale if required
```

Don't immediately say:

> "Increase the EC2 instance."

First identify the root cause.

---

# 63. Scenario: EC2 memory is full.

Check:

```text
free -h
top
```

Then investigate:

```text
JVM heap
Memory leak
Too many processes
Large application workload
Garbage collection
```

Possible solutions:

```text
Fix application problem
Tune JVM
Increase instance capacity
Scale horizontally
```

---

# 64. Scenario: Disk is full.

Check:

```text
df -h
du -sh *
```

Common causes:

```text
Application logs
Old files
Temporary files
Large uploads
Core dumps
```

Solutions:

```text
Log rotation
Delete unnecessary files
Increase EBS volume
Move files to S3
```

---

# 65. Scenario: Application works on localhost but not from the internet.

Very common interview scenario.

Possible reasons:

```text
Application listening only on localhost
Security Group
Firewall
Wrong port
Subnet routing
Public connectivity
Load Balancer configuration
```

Example:

```text
localhost:8080 → works

EC2-public-IP:8080 → fails
```

Check whether the application is listening on the expected network interface and whether the required network path is allowed.

---

# 66. Scenario: EC2 application stops whenever the server restarts.

Problem:

You started it manually:

```text
java -jar app.jar
```

After reboot:

```text
Application → stopped
```

Solution:

Configure a **systemd service**.

```text
EC2 reboot
    |
    v
systemd
    |
    v
Spring Boot starts
```

This is a very good real-world interview answer.

---

# 67. Scenario: Traffic suddenly increases from 1,000 to 100,000 users.

Don't simply increase one EC2 instance.

Use horizontal scaling:

```text
Users
  |
  v
Load Balancer
  |
  +---- EC2
  +---- EC2
  +---- EC2
  +---- EC2
  |
 Auto Scaling Group
```

Also evaluate:

```text
Database scaling
Caching
CloudFront
S3
Async processing
Connection pools
Application bottlenecks
```

---

# 68. Scenario: One EC2 instance fails.

If there is only one EC2:

```text
EC2
 X
 |
Application down
```

With multiple instances:

```text
        Load Balancer
          /       \
         /         \
      EC2 #1      EC2 #2
        X
                   |
              Application
                works
```

The load balancer can route traffic to healthy targets.

For automated replacement, use an Auto Scaling Group.

---

# 69. Scenario: Your application needs shared file storage across EC2 instances.

Don't store the shared files only on local EC2 disk.

Use an appropriate shared/durable service.

For application uploads:

```text
EC2 #1 \
        \
         S3
        /
EC2 #2 /
```

S3 is usually a good choice for objects such as:

```text
Images
PDFs
Videos
Documents
```

---

# 70. Scenario: EC2 cannot access S3.

Check:

```text
1. IAM role attached?
2. Correct IAM permissions?
3. Correct bucket?
4. Correct object ARN?
5. Bucket policy?
6. Explicit Deny?
7. KMS permissions?
8. VPC endpoint/network configuration?
9. AWS SDK configuration?
10. Region?
```

### Strong answer

> I would first verify the EC2 IAM role and its permissions, then check the bucket policy and resource ARN. If encryption uses KMS, I would check KMS permissions as well. If the EC2 instance is in a private subnet, I would also verify its network path to S3.

---

# 71. Scenario: S3 upload works but download doesn't.

Likely permissions:

```text
PutObject → Allowed

GetObject → Denied
```

Check:

```text
s3:PutObject
s3:GetObject
```

---

# 72. Scenario: S3 access suddenly starts returning 403.

Check:

```text
IAM
Bucket policy
Explicit Deny
KMS
Block Public Access
VPC endpoint policy
Object ownership/access settings
```

Don't assume it is only an IAM issue.

---

# 73. Scenario: Database is overloaded.

Possible architecture improvements:

```text
Application
     |
     v
RDS
```

Investigate:

```text
Slow queries
Missing indexes
Connection pool
Too many requests
Large transactions
```

Depending on workload, consider:

```text
Read replicas
Caching
Query optimization
Scaling instance size
Connection management
```

---

# 74. Scenario: You need zero/minimal downtime deployment.

Use multiple application instances behind a load balancer.

Possible deployment approaches:

```text
Rolling deployment
Blue/green deployment
Canary deployment
```

Example:

```text
Load Balancer
    |
    +-- Old version
    +-- Old version
```

Deploy new version:

```text
Load Balancer
    |
    +-- Old version
    +-- New version
```

Gradually move traffic to the new version.

---

# 75. Scenario: How would you design a production Spring Boot application on AWS?

A strong answer:

```text
                    Users
                      |
                      v
                 Route 53
                      |
                      v
                 CloudFront
                      |
                      v
               Load Balancer
                 /        \
                /          \
             EC2          EC2
          Spring Boot   Spring Boot
             |              |
             +------+-------+
                    |
              +-----+------+
              |            |
              v            v
             RDS          S3
              |
          Application DB

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
Encryption
Secrets Manager
Least Privilege
```

Scaling:

```text
Auto Scaling Group
Load Balancer
Caching
Database scaling
```

---

# PART 15 — RAPID-FIRE AWS QUESTIONS

These are frequently asked as short questions.

### What is EC2?

> Compute service providing virtual servers.

### What is S3?

> Object storage service.

### What is RDS?

> Managed relational database service.

### What is IAM?

> AWS identity and access management service.

### What is VPC?

> Logically isolated virtual network in AWS.

### What is Security Group?

> Stateful virtual firewall for resources such as EC2.

### What is CloudWatch?

> Monitoring and observability service.

### What is CloudTrail?

> AWS API activity and auditing service.

### What is Route 53?

> AWS DNS service.

### What is ALB?

> Application Load Balancer for HTTP/HTTPS traffic.

### What is Auto Scaling?

> Automatically adjusts application capacity according to configured policies.

### What is SQS?

> Managed message queue.

### What is SNS?

> Publish/subscribe messaging and notification service.

### What is Lambda?

> Serverless compute service.

### What is CloudFront?

> CDN for caching and delivering content closer to users.

### What is KMS?

> AWS key management service.

### What is Secrets Manager?

> Managed service for storing and retrieving secrets.

### What is EBS?

> Block storage for EC2.

### What is an Availability Zone?

> Isolated location within an AWS Region.

### What is a Region?

> Geographic AWS infrastructure location containing multiple Availability Zones.

---

# PART 16 — TOP 15 QUESTIONS TO PREPARE FIRST

If you have limited interview-preparation time, focus on these:

```text
1. What is AWS?

2. What is EC2?

3. What is AMI?

4. What is EBS?

5. What is S3?

6. What is IAM?

7. IAM User vs Role?

8. What is Security Group?

9. What is VPC?

10. Public vs Private Subnet?

11. What is RDS?

12. What is Load Balancer?

13. What is Auto Scaling?

14. What is CloudWatch?

15. How do you deploy a Spring Boot application on AWS?
```

Then prepare these scenarios:

```text
1. EC2 application is not accessible.

2. EC2 CPU is 100%.

3. EC2 memory is full.

4. Disk is full.

5. EC2 cannot access S3.

6. S3 returns AccessDenied.

7. Application works locally but not on EC2.

8. Application stops after EC2 reboot.

9. Traffic suddenly increases.

10. One EC2 instance fails.

11. Database becomes slow.

12. Need minimal downtime deployment.

13. Need shared file storage.

14. Need temporary S3 file access.

15. Need disaster recovery.
```

---

# PART 17 — GOLDEN ANSWER FOR AWS ARCHITECTURE QUESTIONS

When the interviewer asks:

**"How would you design this application on AWS?"**

A good approach is:

```text
1. Understand the requirement
          ↓
2. Choose compute
          ↓
3. Choose database
          ↓
4. Choose storage
          ↓
5. Design networking
          ↓
6. Add security
          ↓
7. Add load balancing
          ↓
8. Add auto scaling
          ↓
9. Add monitoring
          ↓
10. Consider backup/DR
```

For example:

> "For a production Spring Boot application, I would place the application behind an Application Load Balancer and run multiple instances using an Auto Scaling Group across Availability Zones. I would use RDS for relational application data and S3 for object/file storage. I would keep the application and database in appropriate private subnets, use Security Groups for network access control, IAM roles for AWS service access, Secrets Manager for sensitive configuration, and CloudWatch for monitoring. Route 53 can provide DNS, and CloudFront can be used where CDN caching is beneficial."

---

# FINAL AWS INTERVIEW CHEAT SHEET

```text
COMPUTE
EC2       → Virtual server
Lambda    → Serverless function
ECS       → Container orchestration
EKS       → Managed Kubernetes
Fargate   → Serverless container compute

STORAGE
S3        → Object storage
EBS       → Block storage
EFS       → Managed shared file storage

DATABASE
RDS       → Managed relational DB
DynamoDB  → Managed NoSQL database

NETWORKING
VPC       → Virtual network
Subnet    → Network segment
IGW       → Internet connectivity for public routing
NAT       → Outbound internet from private resources
SG        → Stateful resource firewall
NACL      → Stateless subnet firewall
ALB       → Application load balancing
Route 53  → DNS
CloudFront→ CDN

SECURITY
IAM       → Identity/access
KMS       → Encryption key management
Secrets Manager → Secrets
CloudTrail → API auditing

MONITORING
CloudWatch → Metrics/logs/alarms

MESSAGING
SQS       → Queue
SNS       → Pub/Sub/notifications

SCALING
ASG       → EC2 automatic scaling
ALB       → Distributes traffic

BACKUP/DR
Versioning
Replication
AWS Backup
RTO
RPO
```

## One architecture to remember

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
                   v               v
                EC2 #1          EC2 #2
             Spring Boot      Spring Boot
                   |               |
                   +-------+-------+
                           |
              +------------+------------+
              |                         |
              v                         v
             RDS                       S3
        Application Data          Files/Objects
              |
              v
        Database Backup

       EC2 → IAM Role → AWS Services

       Everything monitored with CloudWatch
       AWS API activity audited with CloudTrail
```

**The key interview mindset:** don't just memorize AWS service definitions. Be ready to explain **why you would choose a service, how services connect, how you secure them, and what you would check when something fails.**