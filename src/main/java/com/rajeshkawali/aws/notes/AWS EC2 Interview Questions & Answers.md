# AWS EC2 Interview Questions & Answers
## Beginner → Intermediate → Scenario Based

---

# PART 1 — EC2 BASIC INTERVIEW QUESTIONS

## 1. What is AWS EC2?

**Answer:**

EC2 stands for **Elastic Compute Cloud**.

It is an AWS service that provides virtual servers in the cloud. We can use EC2 to deploy and run applications such as Spring Boot, Node.js, Python, and .NET applications.

Example:

```text
EC2
 |
 +-- Linux
 +-- Java
 +-- Spring Boot
 +-- Application
```

**Interview one-liner:**

> EC2 is an AWS compute service that provides virtual servers for running applications.

---

# 2. What is an EC2 instance?

**Answer:**

An EC2 instance is a virtual server created using an AMI and an instance type.

For example:

```text
EC2 Instance
 |
 +-- Operating System
 +-- CPU
 +-- RAM
 +-- Network
 +-- Storage
```

---

# 3. What is AMI?

AMI stands for **Amazon Machine Image**.

It is a template used to launch EC2 instances.

It can contain:

- Operating system
- Application configuration
- Installed software
- Other required configuration

Examples:

```text
Ubuntu AMI
Amazon Linux AMI
Windows Server AMI
```

**Interview answer:**

> An AMI is a template used to create EC2 instances. It contains the information required to launch an instance, such as the operating system and configuration.

---

# 4. What is an EC2 instance type?

Instance type defines the compute resources available to the EC2 instance.

It determines things such as:

```text
CPU
Memory
Network performance
Storage characteristics
```

Example conceptually:

```text
Small instance
   |
   +-- Less CPU
   +-- Less RAM

Large instance
   |
   +-- More CPU
   +-- More RAM
```

**Interview answer:**

> Instance type determines the hardware resources allocated to an EC2 instance, such as CPU and memory.

---

# 5. What is EBS?

EBS stands for **Elastic Block Store**.

It provides block storage volumes that can be attached to EC2 instances.

Think:

```text
EC2 = Computer
EBS = Disk
```

Example:

```text
EC2
 |
 +-- EBS Volume
       |
       +-- OS
       +-- Application
       +-- Files
```

---

# 6. What is a Security Group?

A Security Group is a **virtual firewall** associated with an EC2 instance.

It controls network traffic.

Example:

```text
Internet
   |
   v
Security Group
   |
   v
EC2
```

Example rules:

```text
22   -> SSH
80   -> HTTP
443  -> HTTPS
8080 -> Spring Boot
```

---

# 7. What is port 22?

Port 22 is commonly used for **SSH**.

Example:

```bash
ssh -i my-key.pem ubuntu@EC2_PUBLIC_IP
```

---

# 8. What is port 80?

Port 80 is the standard port for HTTP.

Example:

```text
http://example.com
```

---

# 9. What is port 443?

Port 443 is the standard port for HTTPS.

Example:

```text
https://example.com
```

---

# 10. What is port 8080?

8080 is commonly used by Java/Spring Boot applications.

Example:

```text
Spring Boot
   |
   +-- Port 8080
```

However, Spring Boot can be configured to use another port.

---

# 11. What is a Key Pair in EC2?

A key pair is used to authenticate when connecting to an EC2 instance, particularly Linux instances using SSH.

Example:

```text
my-server.pem
```

Connection:

```bash
ssh -i my-server.pem ubuntu@PUBLIC_IP
```

**Important:**

Never commit the private key to GitHub or share it.

---

# 12. What is a public IP?

A public IP allows an EC2 instance to communicate with the internet.

Example:

```text
18.xxx.xxx.xxx
```

You might use it to access your application:

```text
http://18.xxx.xxx.xxx:8080
```

For production applications, you normally use a domain name and HTTPS rather than relying on an ephemeral public IP.

---

# 13. What is a private IP?

A private IP is used for communication within the VPC/private network.

Example:

```text
EC2
Private IP: 10.0.1.25
```

Other AWS resources in the VPC can communicate using private networking when their routing and security rules allow it.

---

# 14. Public IP vs Private IP?

| Public IP | Private IP |
|---|---|
| Used for internet communication | Used within private networking |
| Internet reachable when allowed | Not directly reachable from the public internet |
| Can change depending on configuration/lifecycle | Used for internal communication |
| Useful for public endpoints | Useful for internal services |

---

# 15. What is an Elastic IP?

An Elastic IP is a static public IPv4 address that you can associate with AWS resources such as EC2, subject to AWS's current pricing and allocation rules.

Without a persistent address:

```text
EC2
 |
 +-- Public IP
```

The address can change after certain instance lifecycle events.

With an Elastic IP:

```text
EC2
 |
 +-- Elastic IP
```

the address remains associated until you release/disassociate it.

**Important:** In modern architectures, DNS and load balancers are often preferable to directly depending on a fixed EC2 IP.

---

# 16. What is VPC?

VPC stands for **Virtual Private Cloud**.

It is your logically isolated network in AWS.

Example:

```text
VPC
 |
 +-- Subnet
 |     |
 |     +-- EC2
 |
 +-- Subnet
       |
       +-- EC2
```

---

# 17. What is a subnet?

A subnet is a range of IP addresses inside a VPC.

Subnets can be public or private depending on their routing configuration.

Example:

```text
VPC
 |
 +-- Public Subnet
 |      |
 |      +-- EC2
 |
 +-- Private Subnet
        |
        +-- Database
```

---

# 18. Public subnet vs private subnet?

A subnet is considered public when its routing configuration provides a path to an Internet Gateway.

Typical architecture:

```text
Internet
    |
    v
Public Subnet
    |
    +-- Load Balancer

Private Subnet
    |
    +-- Application
    +-- Database
```

A common production architecture keeps databases in private subnets.

---

# 19. What is an Internet Gateway?

An Internet Gateway provides a path between a VPC and the internet for resources whose routing and security configuration permit it.

Example:

```text
Internet
    |
    v
Internet Gateway
    |
    v
VPC
```

---

# 20. What is a Route Table?

A route table determines where network traffic should go.

Example:

```text
Destination       Target

0.0.0.0/0         Internet Gateway
10.0.0.0/16       local
```

Think:

> Route table = Traffic direction/routing rules.

---

# PART 2 — EC2 LIFECYCLE QUESTIONS

# 21. What are EC2 instance states?

Common states include:

```text
Pending
Running
Stopping
Stopped
Shutting-down
Terminated
```

Important difference:

```text
Stopped
```

means the instance can generally be started again.

```text
Terminated
```

means the instance has been permanently deleted.

---

# 22. What is the difference between Stop and Terminate?

### Stop

```text
EC2
 |
 +-- Instance stopped
```

You can normally start it again.

EBS-backed storage generally persists according to its configuration.

### Terminate

```text
EC2
 |
 X
```

The instance is permanently removed.

Some attached resources may persist depending on configuration, while the instance itself is gone.

**Interview answer:**

> Stop shuts down the instance so it can generally be started again, whereas terminate permanently deletes the EC2 instance.

---

# 23. What happens to public IP when EC2 is stopped?

For a normal EC2 public IPv4 address, the public IP can change when the instance is stopped and started.

If you need a stable public IPv4 address, an Elastic IP can be used, although load balancers and DNS are often preferable for production architectures.

---

# 24. What happens to private IP when EC2 is stopped?

The primary private IPv4 address normally remains associated with the network interface.

---

# 25. What happens to data when EC2 is terminated?

It depends on where the data is stored.

For example:

```text
EBS
```

can be configured to be deleted or retained when the instance is terminated.

Instance-store data has different lifecycle behavior and is not persistent across instance termination.

**Interview tip:**

Never say:

> "All EC2 data is automatically lost."

The correct answer is:

> It depends on the storage type and its configuration.

---

# PART 3 — EC2 + SPRING BOOT INTERVIEW QUESTIONS

# 26. How do you deploy a Spring Boot application on EC2?

**Answer:**

I would follow these steps:

```text
1. Create EC2 instance
2. Select Linux AMI
3. Select appropriate instance type
4. Create/select key pair
5. Configure Security Group
6. Attach IAM role if required
7. Connect using SSH
8. Install Java
9. Copy Spring Boot JAR
10. Configure application properties
11. Start the application
12. Configure systemd
13. Configure Nginx/load balancer
14. Configure HTTPS
15. Monitor logs and server health
```

---

# 27. How do you copy a Spring Boot JAR to EC2?

Using SCP:

```bash
scp -i my-key.pem \
target/myapp.jar \
ubuntu@EC2_PUBLIC_IP:/home/ubuntu/
```

Then connect:

```bash
ssh -i my-key.pem ubuntu@EC2_PUBLIC_IP
```

Run:

```bash
java -jar myapp.jar
```

---

# 28. How do you run Spring Boot in the background?

A better production approach is to use `systemd`.

Example:

```ini
[Unit]
Description=Spring Boot Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/java -jar /home/ubuntu/myapp.jar
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
```

Check:

```bash
sudo systemctl status myapp
```

Logs:

```bash
journalctl -u myapp -f
```

---

# 29. Why use Nginx in front of Spring Boot?

Instead of:

```text
Internet
   |
   v
Spring Boot :8080
```

we can use:

```text
Internet
   |
   v
Nginx :80/:443
   |
   v
Spring Boot :8080
```

Nginx can act as a reverse proxy and can help with:

- HTTPS termination
- Routing
- Serving static content
- Hiding the application port
- Reverse proxying

---

# 30. How would you deploy a Spring Boot application for production?

A good answer:

```text
Internet
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
   v
Nginx
   |
   v
Spring Boot
   |
   +---- RDS
   |
   +---- S3
```

For high availability:

```text
                 Load Balancer
                  /          \
                 v            v
              EC2 #1        EC2 #2
                 |            |
                 +-----+------+
                       |
                       v
                      RDS
                       |
                       v
                       S3
```

---

# PART 4 — SECURITY QUESTIONS

# 31. What is an IAM Role?

An IAM role provides permissions to AWS resources without requiring you to embed long-term credentials in your application.

Example:

```text
EC2
 |
 +-- IAM Role
       |
       +-- S3 permissions
```

---

# 32. How does EC2 access S3 securely?

**Best interview answer:**

> I attach an IAM role to the EC2 instance. The role contains only the required S3 permissions. The Spring Boot application uses the AWS SDK, which obtains credentials through the EC2 role mechanism. I don't hardcode AWS access keys in the application.

Architecture:

```text
Spring Boot
     |
     v
AWS SDK
     |
     v
EC2 IAM Role
     |
     v
S3
```

---

# 33. Why should you not store AWS credentials in application.properties?

Bad:

```properties
aws.access-key=xxxxx
aws.secret-key=xxxxx
```

Problems:

```text
Source code
     |
     v
Git repository
     |
     v
Credentials exposed
```

Better:

```text
EC2
 |
IAM Role
 |
S3
```

---

# 34. What is least privilege?

Least privilege means giving an application only the permissions it needs.

For example, if the application only uploads objects:

```text
s3:PutObject
```

Don't automatically give:

```text
AdministratorAccess
```

or unrestricted S3 access.

---

# 35. What should you do if someone asks you to open port 22 to 0.0.0.0/0?

A good answer:

> I would avoid opening SSH to the entire internet unless there is a specific requirement. I would restrict SSH access to trusted IP addresses or use a managed access mechanism such as AWS Systems Manager where appropriate.

---

# 36. What is the difference between Security Group and NACL?

### Security Group

```text
Instance-level firewall
Stateful
```

### Network ACL

```text
Subnet-level network control
Stateless
```

Easy interview answer:

> Security Groups operate at the instance/network-interface level and are stateful, while Network ACLs operate at the subnet level and are stateless.

---

# PART 5 — MOST ASKED SCENARIO QUESTIONS

# 37. Scenario: Your Spring Boot application is not accessible from the browser. What will you check?

This is a very common interview question.

Answer:

```text
1. Is EC2 running?
2. Is Spring Boot running?
3. Is the application listening on the expected port?
4. Is the Security Group allowing the port?
5. Is the subnet routing configured correctly?
6. Does the instance have internet connectivity/public addressing if required?
7. Is Nginx running?
8. Is Nginx forwarding to the correct Spring Boot port?
9. Check application logs.
10. Check systemd logs.
```

Useful commands:

```bash
sudo systemctl status myapp
```

```bash
journalctl -u myapp -f
```

```bash
sudo ss -lntp
```

---

# 38. Scenario: Spring Boot works on localhost but not from the internet.

Suppose:

```text
curl localhost:8080
```

works.

But:

```text
http://EC2_PUBLIC_IP:8080
```

doesn't work.

Possible reasons:

```text
1. Security Group does not allow 8080.
2. Application is bound only to localhost.
3. Network routing problem.
4. OS firewall is blocking traffic.
5. Wrong public IP.
6. Application isn't actually listening on the expected interface/port.
```

For example, if an application is only listening on:

```text
127.0.0.1:8080
```

external connections cannot reach it.

---

# 39. Scenario: EC2 is running but website is down.

What do you check?

```text
EC2 status
     ↓
Security Group
     ↓
Network connectivity
     ↓
Nginx
     ↓
Spring Boot
     ↓
Application logs
```

Commands:

```bash
sudo systemctl status nginx
```

```bash
sudo systemctl status myapp
```

```bash
journalctl -u myapp -f
```

---

# 40. Scenario: Spring Boot application stopped after EC2 reboot.

Why?

If you manually ran:

```bash
java -jar myapp.jar
```

the process may not automatically restart after reboot.

Solution:

Use:

```text
systemd
```

with:

```ini
[Install]
WantedBy=multi-user.target
```

and:

```bash
sudo systemctl enable myapp
```

Interview answer:

> I would configure the Spring Boot application as a systemd service and enable it at boot so that it automatically starts after an EC2 restart.

---

# 41. Scenario: Application is using 100% CPU.

What will you do?

First check CPU/processes:

```bash
top
```

or:

```bash
htop
```

Then check:

```text
Application logs
JVM behavior
Thread usage
Traffic/load
Database performance
```

Possible solutions:

```text
Short term:
Investigate and restart if necessary.

Long term:
Fix application issue
Optimize code
Increase instance size
Scale horizontally
Use Auto Scaling
```

Interview answer:

> I would first identify the process consuming CPU and check application/JVM logs. I would determine whether the issue is traffic-related, a code problem, or resource exhaustion. Depending on the root cause, I could optimize the application, increase capacity, or scale horizontally.

---

# 42. Scenario: EC2 memory is full.

Check:

```bash
free -h
```

and:

```bash
top
```

Investigate:

```text
JVM heap
Application memory usage
Other processes
Memory leaks
```

Potential solutions:

```text
Tune JVM
Fix memory leak
Increase instance size
Restart as temporary mitigation
Scale application
```

---

# 43. Scenario: Disk space is full.

Check:

```bash
df -h
```

Find large directories:

```bash
sudo du -sh /* 2>/dev/null
```

Check logs:

```text
/var/log
```

Potential solution:

```text
Clean unnecessary files
Rotate logs
Increase EBS volume
Extend filesystem
Move large objects to S3
```

---

# 44. Scenario: EC2 cannot access S3.

What do you check?

```text
1. Is IAM role attached to EC2?
2. Does IAM role have required permissions?
3. Is bucket name correct?
4. Is AWS region correct?
5. Is there an explicit deny?
6. Is a bucket policy restricting access?
7. Is KMS involved?
8. Is the application using the expected AWS credentials/provider chain?
9. Is network connectivity available?
```

Common error:

```text
AccessDenied
```

---

# 45. Scenario: S3 upload returns AccessDenied.

Suppose:

```text
Spring Boot
   |
   v
S3
   |
   X
AccessDenied
```

Check whether the IAM role has:

```text
s3:PutObject
```

for the correct object ARN.

Example:

```text
arn:aws:s3:::my-bucket/*
```

Also check:

```text
Bucket policy
Explicit Deny
KMS permissions
Object ownership/security configuration
```

---

# 46. Scenario: Application can list S3 bucket but cannot upload.

This is a very good interview question.

Possible permissions:

```text
ListBucket
```

allows listing the bucket.

But uploading requires:

```text
PutObject
```

So you may have:

```text
s3:ListBucket -> YES
s3:PutObject  -> NO
```

Result:

```text
List works
Upload fails
```

---

# 47. Scenario: Two EC2 instances are running your Spring Boot application. Where should uploaded files be stored?

Don't store them only on local EC2 disk.

Better:

```text
EC2 #1 \
        \
         ---> S3
        /
EC2 #2 /
```

Reason:

Both application servers need access to the same files.

---

# 48. Scenario: EC2 instance fails. What happens to your application?

If you have only one EC2:

```text
EC2
 |
 X
```

your application becomes unavailable.

Better architecture:

```text
              Load Balancer
               /          \
              v            v
           EC2 #1        EC2 #2
```

If one instance fails:

```text
EC2 #1 -> DOWN

EC2 #2 -> still serving traffic
```

This provides better availability.

---

# 49. Scenario: Traffic suddenly increases.

Initially:

```text
Users
  |
  v
EC2
```

During high traffic:

```text
Users
  |
  v
EC2
 |
100% CPU
```

Better architecture:

```text
                 Load Balancer
                 /     |     \
                v      v      v
              EC2    EC2    EC2
```

Use:

```text
Auto Scaling Group
```

to automatically add/remove instances based on configured scaling policies.

---

# 50. What is an Auto Scaling Group?

An Auto Scaling Group maintains a fleet of EC2 instances according to desired capacity and scaling rules.

Example:

```text
Minimum = 2
Desired = 2
Maximum = 5
```

During high load:

```text
2 EC2
 |
High traffic
 |
v
3 EC2
 |
v
4 EC2
```

During low load, instances can scale back down according to the configured policy.

---

# 51. Scenario: One EC2 instance is not enough. How do you scale?

Two approaches:

### Vertical scaling

Increase instance size:

```text
t-type-small
      ↓
t-type-large
```

More CPU/RAM.

### Horizontal scaling

Add more instances:

```text
EC2 #1
EC2 #2
EC2 #3
```

with a load balancer.

**Interview answer:**

> Vertical scaling increases the capacity of an individual instance, while horizontal scaling adds more instances. For highly available web applications, horizontal scaling is usually preferred.

---

# 52. Scenario: How do you achieve high availability for Spring Boot on EC2?

Answer:

```text
              Load Balancer
                 /     \
                v       v
             EC2 #1   EC2 #2
                |       |
                +---+---+
                    |
              Shared services
               /         \
              v           v
             RDS         S3
```

Ideally, instances should be distributed across multiple Availability Zones.

Use:

```text
Load Balancer
Auto Scaling Group
Multiple AZs
```

---

# 53. Scenario: EC2 instance is unhealthy. How can you automatically replace it?

Use:

```text
Auto Scaling Group
```

The ASG can maintain the desired number of healthy instances according to its health-check configuration.

Example:

```text
Desired = 2

EC2 #1 -> unhealthy
EC2 #2 -> healthy

ASG
 |
 +-- terminates/replaces unhealthy capacity as configured
```

---

# 54. Scenario: Your application needs zero/minimal downtime during deployment.

Basic approach:

```text
Old version
   |
   v
EC2 #1 + EC2 #2
```

Deploy new version to another instance or use a controlled rolling deployment:

```text
Load Balancer
    |
    +-- EC2 #1 OLD
    +-- EC2 #2 NEW
```

Then gradually shift traffic as instances become healthy.

For mature deployments, tools such as AWS CodeDeploy, ECS, Kubernetes, or blue/green/rolling strategies may be used depending on architecture.

---

# 55. Scenario: How do you deploy a new Spring Boot version?

Simple deployment:

```text
1. Build JAR
2. Copy JAR to EC2
3. Stop old application
4. Replace JAR
5. Start application
6. Check health
7. Check logs
```

Production:

```text
Load Balancer
      |
      v
Multiple EC2
      |
Rolling/Blue-Green Deployment
      |
      v
New Version
```

---

# 56. Scenario: Your EC2 application is running but users receive 502 Bad Gateway.

If using Nginx:

```text
User
 |
 v
Nginx
 |
 X
Spring Boot
```

Possible causes:

```text
Spring Boot is stopped
Wrong application port
Wrong Nginx configuration
Spring Boot listening on wrong interface
Application crashed
```

Check:

```bash
sudo systemctl status myapp
```

```bash
sudo systemctl status nginx
```

```bash
journalctl -u myapp -f
```

---

# 57. Scenario: Your Spring Boot application is running on port 8080, but you don't want to expose 8080 publicly.

Use:

```text
Internet
   |
   v
Nginx :443
   |
   v
Spring Boot :8080
```

Security Group:

```text
443 -> allowed
8080 -> not publicly exposed
```

The application can be accessible through Nginx while the backend port remains restricted.

---

# 58. Scenario: EC2 has no internet access. What do you check?

Check:

```text
1. Subnet
2. Route table
3. Internet Gateway
4. NAT Gateway if private subnet requires outbound internet
5. Security Group
6. Network ACL
7. DNS configuration
```

For example:

```text
Public EC2:

EC2
 |
Route Table
 |
Internet Gateway
 |
Internet
```

Private subnet:

```text
Private EC2
     |
     v
NAT Gateway
     |
     v
Internet Gateway
     |
     v
Internet
```

A NAT Gateway provides outbound internet connectivity for resources in private subnets; it does not make those resources directly reachable from the internet.

---

# 59. Scenario: How can you connect to a private EC2 instance?

Common approaches include:

```text
AWS Systems Manager Session Manager
```

or a controlled bastion/jump-host architecture where appropriate.

Example:

```text
Your Computer
      |
      v
Bastion Host
      |
      v
Private EC2
```

Modern AWS environments often prefer Systems Manager to reduce the need for publicly reachable SSH access.

---

# 60. Scenario: You lost your EC2 private key. What do you do?

Don't simply say:

> "Create another key pair."

The original private key cannot simply be downloaded again from AWS.

Possible recovery depends on the instance setup and available access mechanisms.

For example:

```text
AWS Systems Manager
```

may allow access if it was configured beforehand.

Other recovery approaches can involve offline filesystem/key replacement procedures depending on the OS and storage configuration.

**Interview answer:**

> I would first check whether Systems Manager or another existing administrative access mechanism is available. I would avoid exposing SSH broadly just to recover access.

---

# PART 6 — PERFORMANCE QUESTIONS

# 61. How do you monitor EC2?

Common AWS service:

```text
CloudWatch
```

Monitor metrics such as:

```text
CPUUtilization
Network traffic
Disk-related metrics where available/configured
Status checks
```

For application-level monitoring, also use:

```text
Application logs
JVM metrics
Spring Boot Actuator
APM tools
```

---

# 62. What is CloudWatch?

CloudWatch is an AWS monitoring and observability service.

It can be used for:

```text
Metrics
Logs
Alarms
Dashboards
```

Example:

```text
EC2 CPU > 80%
       |
       v
CloudWatch Alarm
       |
       v
Notification / scaling action
```

---

# 63. What are EC2 status checks?

EC2 provides status checks to help identify issues with:

```text
System
Instance
```

If a status check fails, investigate the underlying infrastructure or instance/application depending on the type of failure.

---

# 64. CPU is high. Is the EC2 server definitely down?

No.

High CPU does not necessarily mean the server is down.

It means:

```text
CPU utilization is high
```

The application might still be serving requests.

Investigate:

```text
top
Application logs
CloudWatch
JVM metrics
Request traffic
```

---

# PART 7 — STORAGE QUESTIONS

# 65. What is the difference between EBS and S3?

```text
EBS
 |
 +-- Block storage
 +-- Commonly attached to EC2
 +-- Used like a disk

S3
 |
 +-- Object storage
 +-- Stores objects/files
 +-- Accessed through APIs/SDK/console
```

Interview answer:

> EBS is block storage commonly used as an EC2 disk, while S3 is object storage used for files and other objects.

---

# 66. Should you store uploaded user images on EC2?

Usually, no—not as the primary durable storage design for a scalable application.

Better:

```text
Spring Boot
     |
     v
S3
```

instead of:

```text
Spring Boot
     |
     v
EC2 local disk
     |
     +-- image.jpg
```

S3 separates file storage from compute and works better with multiple application instances.

---

# PART 8 — VERY IMPORTANT SCENARIO QUESTIONS

# 67. Interviewer: "Your application works on EC2 but stops whenever you close your SSH session. Why?"

If you launched:

```bash
java -jar app.jar
```

directly from an SSH session, the process may be tied to the session.

Better:

```text
systemd
```

or another appropriate process manager.

---

# 68. Interviewer: "Your application is slow. What do you check?"

Answer:

```text
1. CPU
2. Memory
3. Disk
4. Network
5. JVM
6. Database
7. Application logs
8. API latency
9. Number of requests
10. External dependencies
```

Don't immediately say:

> Increase EC2 size.

First identify the bottleneck.

---

# 69. Interviewer: "CPU is 95%. What do you do?"

Good answer:

> First I would identify which process/thread is consuming CPU and check application and system metrics. I would determine whether the increase is caused by traffic, inefficient code, JVM behavior, or another process. Depending on the root cause, I would optimize the application, scale horizontally, or increase instance capacity.

---

# 70. Interviewer: "Disk is 100% full. What do you do?"

Answer:

```bash
df -h
```

Then:

```bash
du -sh /*
```

Check:

```text
Application logs
Old files
Temporary files
Core dumps
Large application data
```

Then:

```text
Clean unnecessary files
Configure log rotation
Increase EBS
Move files to S3
```

---

# 71. Interviewer: "EC2 is healthy but application is down. Why?"

EC2 health and application health are different.

```text
EC2
 |
 +-- Healthy
 |
 +-- Spring Boot
       |
       X
     Down
```

Check:

```bash
sudo systemctl status myapp
```

and:

```bash
journalctl -u myapp -f
```

---

# 72. Interviewer: "How do you make EC2 highly available?"

Answer:

```text
Load Balancer
      |
 +----+----+
 |         |
EC2       EC2
 |         |
AZ-1      AZ-2
```

Use:

```text
Multiple Availability Zones
Auto Scaling Group
Load Balancer
Health checks
```

---

# 73. Interviewer: "How do you scale your Spring Boot application?"

Answer:

> I can scale vertically by increasing the EC2 instance size, or horizontally by running multiple EC2 instances behind a load balancer. For production workloads, horizontal scaling with an Auto Scaling Group generally provides better availability and scalability.

---

# 74. Interviewer: "What happens if one EC2 instance fails?"

Single EC2:

```text
EC2
 |
 X
 |
Application DOWN
```

Multiple EC2:

```text
Load Balancer
    |
    +-- EC2 #1 -> DOWN
    |
    +-- EC2 #2 -> UP
```

The load balancer can stop routing traffic to an unhealthy instance based on health checks.

---

# 75. Interviewer: "How do you store session data if you have multiple EC2 instances?"

Problem:

```text
User
 |
 v
EC2 #1
 |
Session stored locally
```

Next request:

```text
User
 |
 v
EC2 #2
 |
Session missing
```

Solutions can include:

```text
External session store
Redis
Database
Stateless authentication such as JWT where appropriate
```

The key concept is:

> Don't depend on local instance memory for shared state when requests can reach different instances.

---

# 76. Interviewer: "How do you store files when using multiple EC2 instances?"

Answer:

```text
EC2 #1 \
        \
         ---> S3
        /
EC2 #2 /
```

Use S3 for object/file storage instead of relying on each EC2's local disk.

---

# 77. Interviewer: "What happens when traffic increases from 1,000 to 100,000 users?"

A strong answer:

```text
Load Balancer
      |
      v
Auto Scaling Group
      |
 +----+----+
 |    |    |
EC2  EC2  EC2
      |
      +---- RDS
      |
      +---- S3
```

Consider:

```text
Auto Scaling
Load Balancer
Caching
Database scaling
S3
CloudWatch
CDN where appropriate
```

---

# PART 9 — QUICK INTERVIEW RAPID-FIRE

## 78. EC2 full form?

**Elastic Compute Cloud**

---

## 79. S3 full form?

**Simple Storage Service**

---

## 80. IAM full form?

**Identity and Access Management**

---

## 81. EBS full form?

**Elastic Block Store**

---

## 82. VPC full form?

**Virtual Private Cloud**

---

## 83. Default SSH port?

**22**

---

## 84. HTTP port?

**80**

---

## 85. HTTPS port?

**443**

---

## 86. Common Spring Boot port?

**8080**

---

## 87. EC2 firewall?

**Security Group**

---

## 88. EC2 disk?

**EBS**

---

## 89. Object storage?

**S3**

---

## 90. EC2 monitoring service?

**CloudWatch**

---

## 91. EC2 scaling service?

**Auto Scaling**

---

## 92. Traffic distribution?

**Elastic Load Balancing**

---

## 93. Secure EC2-to-S3 authentication?

**IAM Role**

---

# PART 10 — TOP 15 QUESTIONS TO MEMORIZE

If you have limited interview preparation time, focus on these:

```text
1. What is EC2?

2. What is AMI?

3. What is an EC2 instance type?

4. What is EBS?

5. What is a Security Group?

6. What is the difference between public and private IP?

7. What is VPC?

8. What is a subnet?

9. How do you deploy a Spring Boot application on EC2?

10. How does EC2 access S3 securely?

11. What is an IAM Role?

12. What is the difference between Stop and Terminate?

13. How do you troubleshoot an EC2 application that is not accessible?

14. How do you scale an EC2 application?

15. How do you achieve high availability with EC2?
```

---

# PART 11 — BEST 5 SCENARIOS TO PRACTICE

## Scenario 1 — Application not accessible

Remember:

```text
EC2
 ↓
Application
 ↓
Port
 ↓
Security Group
 ↓
Route
 ↓
Nginx
 ↓
Logs
```

---

## Scenario 2 — S3 AccessDenied

Remember:

```text
IAM Role
 ↓
IAM Policy
 ↓
Bucket Policy
 ↓
Object ARN
 ↓
KMS (if applicable)
```

---

## Scenario 3 — High CPU

Remember:

```text
CloudWatch
 ↓
Identify process
 ↓
Check JVM
 ↓
Check application
 ↓
Check traffic
 ↓
Optimize / Scale
```

---

## Scenario 4 — EC2 failure

Remember:

```text
Load Balancer
       ↓
Auto Scaling Group
       ↓
Multiple EC2
       ↓
Multiple AZs
```

---

## Scenario 5 — Multiple EC2 + file upload

Remember:

```text
EC2 #1 \
        \
         S3
        /
EC2 #2 /
```

Do not store shared uploaded files only on one EC2 instance.

---

# FINAL INTERVIEW ANSWER — "EXPLAIN YOUR EC2 EXPERIENCE"

For your Spring Boot background, a strong answer is:

> "I have worked with Spring Boot applications that can be deployed on AWS EC2. EC2 provides the compute environment where the Java application runs. I would launch an EC2 instance with a suitable Linux AMI and instance type, configure the Security Group, connect using SSH or Systems Manager, install the required Java version, and deploy the Spring Boot JAR. For a production setup, I would configure the application as a systemd service and place Nginx or a load balancer in front of it. If the application needs AWS services such as S3, I would attach an IAM role to the EC2 instance and grant only the required permissions rather than hardcoding AWS credentials. For high availability and scalability, I would use multiple EC2 instances behind a load balancer and manage them with an Auto Scaling Group."

# ONE DIAGRAM TO REMEMBER

```text
                         USERS
                           |
                           | HTTPS
                           v
                   +---------------+
                   | Load Balancer |
                   +-------+-------+
                           |
              +------------+------------+
              |                         |
              v                         v
        +-----------+             +-----------+
        |   EC2 #1  |             |   EC2 #2  |
        | Spring    |             | Spring    |
        | Boot      |             | Boot      |
        +-----+-----+             +-----+-----+
              |                         |
              +------------+------------+
                           |
                    IAM Role
                           |
             +-------------+-------------+
             |                           |
             v                           v
            S3                          RDS
         File Storage                Database


EC2:
  -> Runs Spring Boot

S3:
  -> Stores files

RDS:
  -> Stores relational data

IAM Role:
  -> Gives EC2 permissions

Security Group:
  -> Controls network traffic

Load Balancer:
  -> Distributes traffic

Auto Scaling:
  -> Adds/removes EC2 instances

CloudWatch:
  -> Monitoring and alarms
```

# Golden Rule for Interviews

When answering scenario questions, don't jump immediately to a solution.

Use this pattern:

```text
1. Identify the problem
2. Check logs/metrics
3. Check network/security
4. Find the root cause
5. Apply the fix
6. Explain how you would prevent it in the future
```

This makes your answer sound like someone who has actually worked with production systems rather than someone who has only memorized AWS definitions.