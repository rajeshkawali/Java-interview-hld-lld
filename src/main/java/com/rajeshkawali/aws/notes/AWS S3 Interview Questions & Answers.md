# AWS S3 INTERVIEW QUESTIONS & ANSWERS
## Beginner → Intermediate → Scenario Based

---

# PART 1 — S3 BASIC QUESTIONS

## 1. What is Amazon S3?

**Answer:**

Amazon S3 stands for **Amazon Simple Storage Service**.

It is an AWS **object storage service** used to store and retrieve files and other objects.

Examples of data stored in S3:

```text
Images
Videos
PDF files
Documents
Backups
Logs
Application files
Static website assets
```

Basic architecture:

```text
Spring Boot Application
        |
        v
       S3
        |
        +-- image.jpg
        +-- report.pdf
        +-- video.mp4
        +-- document.txt
```

**Interview one-liner:**

> Amazon S3 is a highly scalable object storage service used to store and retrieve data as objects inside buckets.

---

# 2. What is an S3 bucket?

A bucket is a container for storing objects in S3.

Example:

```text
Bucket: company-prod-files

        company-prod-files
               |
       +-------+-------+
       |       |       |
       v       v       v
    images/  pdf/    backups/
       |
       +-- user1.jpg
       +-- user2.jpg
```

**Interview answer:**

> An S3 bucket is a logical container in which objects are stored.

---

# 3. What is an S3 object?

An object is the actual data stored in S3.

An object consists conceptually of:

```text
Object
 |
 +-- Data
 +-- Key
 +-- Metadata
 +-- Other object properties
```

Example:

```text
Bucket:
my-company-bucket

Object key:
images/profile/user123.jpg
```

The object data is the image.

---

# 4. What is an S3 key?

A key identifies an object within a bucket.

Example:

```text
Bucket:
my-bucket

Key:
images/profile/user123.jpg
```

S3 doesn't have traditional filesystem directories in the same way an operating system does. Strings such as:

```text
images/profile/user123.jpg
```

are object keys, and the console can display prefixes like folders.

**Interview tip:**

Don't say that S3 is a normal folder-based filesystem.

---

# 5. What is the difference between bucket and object?

```text
Bucket = Container
Object = Actual stored data
```

Example:

```text
Bucket
 |
 +-- image.jpg
 +-- report.pdf
 +-- video.mp4
```

---

# 6. Is S3 a database?

**No.**

S3 is primarily **object storage**.

For example:

```text
S3
 |
 +-- Images
 +-- Videos
 +-- PDFs
 +-- Backups
```

For relational application data, you would normally use a database such as Amazon RDS.

For example:

```text
Spring Boot
    |
    +---- RDS -> User/order/application data
    |
    +---- S3  -> Images/files/documents
```

---

# 7. Is S3 block storage or object storage?

S3 is **object storage**.

Compare:

```text
EBS = Block storage

S3 = Object storage
```

---

# 8. What is S3 durability?

Amazon S3 is designed for extremely high durability.

The commonly cited S3 durability target is:

```text
99.999999999%
```

or approximately **11 nines** of durability for S3 storage classes designed for that durability model.

**Important:**

Durability and availability are different concepts.

---

# 9. What is S3 availability?

Availability describes how accessible the service/storage is expected to be over time.

Do not confuse:

```text
Durability = Probability of retaining data
Availability = Ability to access the service/data
```

---

# 10. What are S3 storage classes?

Common S3 storage classes include:

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
        |
        v
S3 Standard

Infrequent access
        |
        v
IA classes

Archive
        |
        v
Glacier classes
```

---

# 11. What is S3 Standard?

S3 Standard is designed for frequently accessed data.

Examples:

```text
User profile images
Application files
Frequently accessed documents
```

---

# 12. What is S3 Intelligent-Tiering?

Intelligent-Tiering automatically moves objects between access tiers based on access patterns, subject to its pricing/monitoring behavior.

Useful when:

```text
You don't know exactly how frequently data will be accessed.
```

Example:

```text
Application
    |
    v
S3 Intelligent-Tiering
    |
    +-- Frequently accessed
    |
    +-- Less frequently accessed
```

---

# 13. What is S3 Glacier?

S3 Glacier storage classes are designed for archival data.

Examples:

```text
Old backups
Compliance records
Historical documents
Long-term archives
```

They generally trade access characteristics for lower storage cost.

---

# 14. What is S3 versioning?

Versioning keeps multiple versions of an object.

Example:

```text
report.pdf

Version 1
Version 2
Version 3
```

If a user accidentally overwrites or deletes an object, versioning can help recover previous versions, depending on the exact operation and configuration.

---

# 15. Why use S3 versioning?

Benefits include:

```text
Accidental deletion recovery
Accidental overwrite recovery
Object history
Protection against some application mistakes
```

Example:

```text
Application
    |
    v
S3
    |
    +-- file.txt Version 1
    +-- file.txt Version 2
    +-- file.txt Version 3
```

---

# 16. What is an S3 lifecycle policy?

A lifecycle configuration automatically transitions or expires objects based on rules.

Example:

```text
Day 0
 |
 v
S3 Standard
 |
 | after 30 days
 v
IA / appropriate lower-cost tier
 |
 | after 90 days
 v
Glacier
 |
 | after required retention period
 v
Delete
```

Exact transition timing and eligible storage classes depend on the configured lifecycle rules.

---

# 17. What is S3 object expiration?

You can configure lifecycle rules to automatically delete objects after a specified period.

Example:

```text
Temporary files
       |
       v
S3
       |
       | 7 days
       v
Delete
```

Useful for:

```text
Temporary uploads
Old logs
Temporary reports
Expired files
```

---

# PART 2 — S3 SECURITY QUESTIONS

# 18. Is an S3 bucket private by default?

S3 has strong security defaults, including **Block Public Access** settings designed to prevent unintended public exposure.

You should still explicitly review:

```text
Bucket policy
IAM policies
Block Public Access
Access points if used
Object ownership
Encryption
```

**Interview answer:**

> I would keep S3 private by default and grant access only to the identities or services that require it.

---

# 19. What is an S3 bucket policy?

A bucket policy is a resource-based JSON policy attached to an S3 bucket.

It can control access to bucket resources.

Example concept:

```text
User/Application
       |
       v
Bucket Policy
       |
       v
S3 Bucket
```

A policy can specify:

```text
Principal
Action
Resource
Condition
Effect
```

---

# 20. What is IAM policy vs S3 bucket policy?

### IAM policy

Attached to an IAM identity such as:

```text
User
Role
Group
```

Example:

```text
EC2 IAM Role
      |
      v
IAM Policy
      |
      v
S3
```

### Bucket policy

Attached directly to the S3 bucket.

```text
S3 Bucket
    |
    v
Bucket Policy
```

**Interview answer:**

> IAM policies are identity-based policies, while S3 bucket policies are resource-based policies attached to the bucket.

---

# 21. What is Block Public Access?

S3 Block Public Access provides settings that help prevent public access to buckets and objects through various mechanisms.

For private application data, it is generally a best practice to keep public access blocked.

---

# 22. How should EC2 access S3?

For an EC2-hosted Spring Boot application, the preferred approach is:

```text
EC2
 |
 IAM Role
 |
 IAM Policy
 |
 S3
```

Do **not** hardcode:

```text
AWS Access Key
AWS Secret Key
```

inside the application.

---

# 23. Why use IAM Role instead of access keys?

Access keys stored in applications can accidentally be exposed.

For example:

```text
application.properties
        |
        v
GitHub
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
Temporary credentials
 |
S3
```

---

# 24. What is least privilege in S3?

Give only the permissions required.

For example, if the application only uploads files:

```text
s3:PutObject
```

may be required.

Don't unnecessarily grant:

```text
s3:*
```

on all buckets.

---

# 25. What is the difference between s3:ListBucket and s3:GetObject?

Very common interview question.

```text
s3:ListBucket
```

allows listing objects in a bucket.

```text
s3:GetObject
```

allows reading/downloading a specific object.

For example:

```text
ListBucket
   |
   +-- See object names

GetObject
   |
   +-- Read/download object
```

---

# 26. What permission is required to upload an object?

Typically:

```text
s3:PutObject
```

for the relevant object ARN.

Example:

```text
arn:aws:s3:::my-bucket/uploads/*
```

---

# 27. What permission is required to delete an object?

Typically:

```text
s3:DeleteObject
```

for the relevant object ARN.

---

# 28. What permissions are commonly required for a Spring Boot S3 application?

Depending on functionality:

```text
Upload:
s3:PutObject

Download:
s3:GetObject

Delete:
s3:DeleteObject

List:
s3:ListBucket
```

Do not grant all of these unless the application actually needs them.

---

# PART 3 — S3 + SPRING BOOT QUESTIONS

# 29. How do you upload a file from Spring Boot to S3?

High-level flow:

```text
Client
  |
  | Multipart File
  v
Spring Boot
  |
  | AWS SDK
  v
S3
```

Example Java concept:

```java
S3Client s3Client = S3Client.builder()
        .region(Region.AP_SOUTH_1)
        .build();

PutObjectRequest request = PutObjectRequest.builder()
        .bucket("my-bucket")
        .key("uploads/file.pdf")
        .build();

s3Client.putObject(
        request,
        RequestBody.fromFile(file.toPath())
);
```

In production, use the AWS SDK credential provider chain and an IAM role rather than hardcoded credentials.

---

# 30. How does Spring Boot authenticate with S3 on EC2?

Typical architecture:

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
Temporary AWS credentials
     |
     v
S3
```

The application doesn't need to contain permanent AWS credentials.

---

# 31. What is AWS SDK?

AWS SDK stands for **Software Development Kit**.

For Java applications, AWS provides an SDK that allows Java applications to interact with AWS services.

Example:

```text
Spring Boot
     |
     v
AWS SDK for Java
     |
     +---- S3
     +---- SQS
     +---- DynamoDB
     +---- etc.
```

---

# 32. What happens if Spring Boot gets AccessDenied from S3?

Check:

```text
1. IAM Role
2. IAM permissions
3. Bucket policy
4. Object ARN
5. Region/configuration
6. Explicit Deny
7. KMS permissions if using SSE-KMS
8. VPC endpoint policy if applicable
```

Example:

```text
Spring Boot
     |
     v
S3
     |
     X
AccessDenied
```

Don't immediately assume the application code is wrong.

---

# PART 4 — MOST IMPORTANT SCENARIO QUESTIONS

# 33. Scenario: Application can list S3 objects but cannot upload.

Possible situation:

```text
s3:ListBucket = allowed

s3:PutObject = denied
```

Therefore:

```text
List -> SUCCESS
Upload -> AccessDenied
```

Solution:

> Check that the IAM role has `s3:PutObject` permission for the correct bucket/object ARN.

---

# 34. Scenario: Application can upload but cannot download.

Possible permissions:

```text
s3:PutObject = allowed
s3:GetObject = denied
```

Therefore:

```text
Upload -> SUCCESS
Download -> AccessDenied
```

Solution:

> Grant `s3:GetObject` for the required object resources, subject to the bucket's other access controls.

---

# 35. Scenario: Application can access one bucket but not another.

Check:

```text
IAM policy
Bucket policy
Resource ARN
Explicit Deny
KMS configuration
```

Example:

```text
EC2 IAM Role
 |
 +---- Bucket A -> Allowed
 |
 +---- Bucket B -> Denied
```

Likely the permissions/resource scope differ.

---

# 36. Scenario: User uploads profile image. Where would you store it?

Recommended:

```text
User
 |
 v
Spring Boot
 |
 v
S3
```

Database:

```text
RDS
 |
 +-- user_id
 +-- image/object key
```

Example:

```text
S3:
users/123/profile.jpg

RDS:
user_id = 123
profile_image_key = users/123/profile.jpg
```

Don't usually store the actual image binary in the relational database unless there is a specific reason.

---

# 37. Scenario: Two EC2 instances need access to the same uploaded files.

Bad design:

```text
EC2 #1
 |
 +-- local/image.jpg

EC2 #2
 |
 +-- doesn't have image.jpg
```

Better:

```text
EC2 #1 \
        \
         ---> S3
        /
EC2 #2 /
```

S3 provides shared durable object storage.

---

# 38. Scenario: EC2 instance crashes. What happens to files stored only on that EC2?

If the files were stored only on local instance storage, they may become unavailable or be lost depending on the storage type and lifecycle.

Better:

```text
Spring Boot
     |
     v
S3
```

Then an EC2 instance can be replaced without losing the application's uploaded objects.

---

# 39. Scenario: Your S3 bucket accidentally becomes public. What do you do?

First:

```text
1. Identify how public access was granted.
2. Enable/review S3 Block Public Access.
3. Review bucket policies.
4. Review IAM/resource policies.
5. Review object ownership/access settings.
6. Check CloudTrail/access logs if configured.
7. Rotate/revoke exposed credentials if credentials were involved.
8. Determine whether sensitive data was accessed.
```

Then prevent recurrence:

```text
Least privilege
Block Public Access
Security review
Monitoring
Automated policy checks
```

---

# 40. Scenario: You need to give a user temporary access to download an S3 file.

Use a **pre-signed URL**.

Flow:

```text
User
 |
 v
Spring Boot
 |
Generate pre-signed URL
 |
 v
S3
 |
 v
Temporary access
```

Example concept:

```text
https://s3.../file.pdf?temporary-signature...
```

The URL can have an expiration time.

Important:

> A pre-signed URL provides temporary access without making the bucket/object publicly accessible.

---

# 41. Scenario: You need to allow users to upload directly to S3.

Instead of:

```text
User
 |
 v
Spring Boot
 |
 v
S3
```

you can use:

```text
User
 |
 v
Spring Boot
 |
Generate pre-signed upload URL
 |
 v
S3
```

Then:

```text
User
 |
 | upload
 v
S3
```

Benefits:

```text
Less load on Spring Boot
Better scalability
Large files don't have to pass through the application server
```

---

# 42. Scenario: Large files are being uploaded and EC2 memory/CPU is increasing.

Possible architecture problem:

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

Every large file passes through the application server.

Better:

```text
User
 |
 v
Spring Boot
 |
 | generate pre-signed URL
 v
S3

User
 |
 | directly uploads
 v
S3
```

This reduces load on EC2.

---

# 43. Scenario: You deleted an important S3 file accidentally. How can you recover it?

If S3 Versioning was enabled and the relevant version still exists:

```text
file.txt

Version 1
Version 2
Version 3
```

you may be able to restore an earlier version.

Also consider:

```text
S3 replication
Backups
Object Lock
```

depending on the application's recovery requirements.

---

# 44. Scenario: Someone accidentally overwrites an important file.

Solution:

```text
Enable Versioning
```

Then:

```text
file.txt
 |
 +-- Version 1
 +-- Version 2
```

You can retrieve/restore the required version.

---

# 45. Scenario: Company must retain files for 7 years and users rarely access them.

Possible approach:

```text
Frequently accessed
       |
       v
S3 Standard

After access declines
       |
       v
Lifecycle transition

Long-term archive
       |
       v
S3 Glacier storage class
```

Use lifecycle policies based on your actual retention, access, retrieval, and compliance requirements.

---

# 46. Scenario: S3 storage cost is increasing.

What would you check?

```text
1. Number of objects
2. Object sizes
3. Storage class
4. Access patterns
5. Old/unneeded files
6. Lifecycle rules
7. Incomplete multipart uploads
8. Replication configuration
9. Versioned object storage
```

Potential solutions:

```text
Lifecycle policies
Appropriate storage classes
Delete unnecessary objects
Expire old versions where appropriate
Clean incomplete multipart uploads
```

---

# 47. Scenario: Millions of temporary files are stored in S3.

Solution:

Create a lifecycle rule.

Example:

```text
temporary/
     |
     | after 7 days
     v
Delete
```

This prevents unnecessary storage costs.

---

# 48. Scenario: You have old application logs stored in S3.

Possible lifecycle:

```text
0 - 30 days
     |
     v
S3 Standard

30 - 90 days
     |
     v
Lower-cost storage class

Long term
     |
     v
Glacier
```

Exact transitions should be based on your retention and retrieval requirements.

---

# 49. Scenario: Your application needs to upload sensitive files to S3.

Use:

```text
Private bucket
IAM least privilege
Encryption
HTTPS/TLS
Block Public Access
Logging/monitoring
```

Encryption options include:

```text
SSE-S3
SSE-KMS
```

For stronger key-management/control requirements, SSE-KMS can be used with AWS KMS keys and the necessary KMS permissions.

---

# 50. What is S3 encryption?

S3 supports encryption for objects at rest.

Common options include:

```text
SSE-S3
SSE-KMS
DSSE-KMS
Client-side encryption
```

For interview purposes:

> S3 supports server-side encryption, and AWS KMS can be used when you need additional key-management and access-control capabilities.

---

# 51. What is SSE-S3?

SSE-S3 means **Server-Side Encryption with Amazon S3-managed keys**.

Conceptually:

```text
Application
    |
    v
S3
    |
    +-- Encrypt object
```

AWS manages the encryption keys for this encryption mode.

---

# 52. What is SSE-KMS?

SSE-KMS means **Server-Side Encryption with AWS KMS keys**.

Architecture:

```text
Application
     |
     v
S3
     |
     v
AWS KMS
```

It provides additional key-management capabilities and can be integrated with IAM/KMS policies.

---

# PART 5 — ADVANCED SCENARIO QUESTIONS

# 53. Scenario: EC2 and S3 are in different regions. Can EC2 access S3?

Yes.

An application can access S3 buckets in another AWS Region if it has the necessary permissions and network connectivity.

However, consider:

```text
Latency
Data transfer costs
Application architecture
Region requirements
```

---

# 54. Scenario: S3 bucket is private. How can the application access it?

Use authenticated AWS API calls.

For EC2:

```text
EC2
 |
IAM Role
 |
AWS SDK
 |
S3
```

The bucket does not need to be public.

---

# 55. Scenario: You don't want S3 traffic to go through the public internet from a VPC.

Use an **S3 VPC endpoint** where appropriate.

Architecture:

```text
EC2
 |
 VPC
 |
 S3 VPC Endpoint
 |
 S3
```

This can keep traffic on AWS networking paths and can reduce the need for NAT/internet routing for S3 access depending on the endpoint type and architecture.

---

# 56. Gateway Endpoint vs Interface Endpoint for S3?

For S3, the commonly used VPC endpoint type is a **Gateway Endpoint**.

Conceptually:

```text
Private EC2
    |
    v
Route Table
    |
    v
S3 Gateway Endpoint
    |
    v
S3
```

Interface endpoints use AWS PrivateLink and are supported for various AWS services, while S3 has specific endpoint options.

---

# 57. Scenario: S3 upload works locally but fails on EC2.

Very common Spring Boot interview scenario.

Local:

```text
Laptop
 |
AWS credentials
 |
S3 -> SUCCESS
```

EC2:

```text
EC2
 |
S3 -> AccessDenied
```

Check:

```text
1. EC2 IAM Role
2. IAM permissions
3. Bucket policy
4. Region
5. AWS SDK configuration
6. Network/VPC endpoint configuration
7. KMS permissions
```

A common mistake is assuming the credentials available on the developer's laptop are also available on EC2.

---

# 58. Scenario: S3 upload works from EC2 but fails after moving EC2 into a private subnet.

Possible issue:

```text
Private EC2
      |
      X
S3
```

Check whether the VPC has appropriate connectivity to S3.

Options can include:

```text
S3 VPC Gateway Endpoint
```

or appropriate network routing such as NAT where required by the architecture.

---

# 59. Scenario: S3 returns 403 Forbidden. What do you check?

Don't assume only IAM.

Check:

```text
IAM policy
Bucket policy
Explicit Deny
Block Public Access
Object ownership
KMS permissions
VPC endpoint policy
Requester Pays, if applicable
Wrong bucket/object
```

---

# 60. Scenario: S3 returns 404 Not Found.

Possible reasons:

```text
Wrong bucket
Wrong object key
Object doesn't exist
Incorrect region/endpoint usage
Permissions may also affect what existence information is revealed
```

Remember:

```text
S3 object key is case-sensitive.
```

For example:

```text
image.jpg
```

and:

```text
Image.jpg
```

are different keys.

---

# 61. Scenario: User uploads two files with the same name.

Example:

```text
profile.jpg
profile.jpg
```

If you use the same object key, one object operation may overwrite the previous object unless your design prevents it.

Better:

```text
UUID + original filename
```

Example:

```text
uploads/550e8400-e29b-41d4-a716-446655440000-profile.jpg
```

or another unique key strategy.

---

# 62. Scenario: You have 10 million objects. Should you create 10 million folders?

No.

S3 uses object keys and prefixes rather than traditional directories.

Example:

```text
users/123/profile.jpg
users/456/profile.jpg
orders/10001/invoice.pdf
```

These are object keys containing prefixes.

---

# 63. Scenario: How do you organize objects in S3?

Use meaningful key prefixes.

Example:

```text
my-bucket/
 |
 +-- users/
 |    +-- 123/
 |    |    +-- profile.jpg
 |    |
 |    +-- 456/
 |
 +-- invoices/
 |    +-- 2026/
 |
 +-- temporary/
```

---

# 64. Scenario: How do you protect against accidental deletion?

Use multiple controls depending on requirements:

```text
S3 Versioning
S3 Object Lock where appropriate
IAM least privilege
MFA Delete where supported/appropriate
Backups/replication
Lifecycle controls
```

For compliance/WORM requirements, S3 Object Lock can help enforce retention.

---

# 65. Scenario: What is S3 Object Lock?

S3 Object Lock helps prevent objects from being deleted or overwritten for a defined retention period.

Useful for:

```text
Compliance
Audit records
Regulatory retention
WORM-style storage requirements
```

---

# 66. Scenario: Business requires disaster recovery for S3.

Possible solution:

```text
Region A
   |
   v
S3 Bucket
   |
   | Replication
   v
Region B
   |
   v
S3 Bucket
```

Depending on requirements, use S3 replication features such as Cross-Region Replication.

Consider:

```text
RPO
RTO
Cost
Data residency
Encryption
Replication permissions
```

---

# PART 6 — S3 PERFORMANCE QUESTIONS

# 67. Is S3 scalable?

Yes.

S3 is designed to provide massive scalability without manually managing storage servers.

You don't normally provision:

```text
Disk size = 500 GB
```

in the same way you do for an EBS volume.

You store objects in S3 and AWS manages the underlying infrastructure.

---

# 68. Can S3 handle high traffic?

Yes.

S3 is designed for very high request rates and large-scale workloads.

However, applications should still follow AWS best practices for request patterns, retries, timeouts, and workload architecture.

---

# 69. What is multipart upload?

Multipart upload allows a large object to be uploaded in multiple parts.

Concept:

```text
Large File
   |
   +-- Part 1
   +-- Part 2
   +-- Part 3
   +-- Part 4
   |
   v
S3
```

Benefits:

```text
Large file uploads
Parallel upload
Better recovery of failed parts
```

---

# 70. Scenario: A 10 GB file upload keeps failing.

Possible solution:

Use multipart upload.

```text
10 GB
 |
 +-- Part 1
 +-- Part 2
 +-- Part 3
 ...
```

If one part fails, you don't necessarily need to restart the entire upload.

---

# PART 7 — S3 STATIC WEBSITE QUESTIONS

# 71. Can S3 host a website?

Yes, S3 can be used to host static website content.

Example:

```text
HTML
CSS
JavaScript
Images
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
 |
 +-- index.html
 +-- style.css
 +-- app.js
```

For modern production architectures, CloudFront is commonly placed in front of S3.

---

# 72. Can S3 run Spring Boot?

No.

S3 stores objects; it does not run your Java/Spring Boot application.

Correct:

```text
Spring Boot -> EC2/ECS/etc.
Files       -> S3
```

Incorrect:

```text
Spring Boot -> S3
```

---

# PART 8 — VERY COMMON TRICK QUESTIONS

# 73. Is S3 a file system?

Not in the traditional filesystem sense.

It is an **object storage service**.

---

# 74. Does S3 have folders?

The S3 data model uses object keys and prefixes.

The AWS console presents prefixes in a folder-like way, but they are not traditional filesystem directories.

---

# 75. Can two objects have the same key in one bucket?

A bucket can have only one current object at a given key at a time.

With versioning enabled, multiple historical versions can exist for that same key.

---

# 76. Is S3 automatically public?

No.

You should keep buckets private unless there is a deliberate requirement for public access.

---

# 77. Can EC2 access private S3?

Yes.

Example:

```text
EC2
 |
IAM Role
 |
AWS SDK
 |
Private S3 Bucket
```

The bucket does not need to be publicly accessible.

---

# 78. Does S3 store data in only one physical disk?

No.

AWS manages the underlying storage infrastructure and replicates data to provide its durability characteristics.

---

# 79. Does deleting an S3 object always mean the data is immediately physically erased?

Don't answer this simply as "yes."

S3's object deletion semantics and underlying physical data lifecycle are managed by AWS.

From an application perspective, the object is deleted according to S3's API semantics.

For compliance/security questions, discuss:

```text
Versioning
Object Lock
Lifecycle
AWS deletion semantics
```

---

# PART 9 — TOP 20 S3 QUESTIONS TO MEMORIZE

If the interviewer asks rapid-fire questions, remember these:

```text
1. What is S3?

2. What is a bucket?

3. What is an object?

4. What is an S3 key?

5. S3 object storage or block storage?

6. What is S3 Versioning?

7. What are S3 storage classes?

8. What is S3 Lifecycle?

9. What is an IAM Role?

10. How does EC2 access S3?

11. What is a bucket policy?

12. IAM policy vs bucket policy?

13. What is Block Public Access?

14. What is a pre-signed URL?

15. What is multipart upload?

16. What is S3 encryption?

17. SSE-S3 vs SSE-KMS?

18. What is S3 Object Lock?

19. How do you troubleshoot S3 AccessDenied?

20. How do you design S3 for Spring Boot?
```

---

# PART 10 — MOST IMPORTANT SCENARIOS

## Scenario 1 — EC2 → S3

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
AWS SDK
     |
     v
Private S3 Bucket
```

Remember:

> Don't hardcode AWS credentials.

---

## Scenario 2 — File Upload

```text
User
 |
 v
Spring Boot
 |
 v
S3
```

For large/scalable uploads:

```text
User
 |
 v
Spring Boot
 |
 | generate pre-signed URL
 v
S3

User
 |
 | direct upload
 v
S3
```

---

## Scenario 3 — AccessDenied

```text
AccessDenied
     |
     +-- IAM
     +-- Bucket Policy
     +-- Explicit Deny
     +-- KMS
     +-- VPC Endpoint
     +-- Object ARN
```

---

## Scenario 4 — Accidental Delete

```text
S3 Versioning
      |
      v
Previous Version
      |
      v
Recovery
```

---

## Scenario 5 — Storage Cost Increasing

```text
S3
 |
 +-- Check old objects
 +-- Check versions
 +-- Check storage classes
 +-- Check lifecycle
 +-- Check incomplete multipart uploads
 |
 v
Optimize
```

---

# PART 11 — BEST INTERVIEW ANSWER: "EXPLAIN HOW YOUR SPRING BOOT APPLICATION USES S3"

You can answer:

> "In my Spring Boot application, I would use Amazon S3 for storing objects such as user-uploaded images, PDFs, and documents. The application communicates with S3 using the AWS SDK for Java. When the application runs on EC2, I would attach an IAM role to the EC2 instance and grant the role only the required S3 permissions, such as PutObject and GetObject. I would keep the S3 bucket private rather than making it publicly accessible. For large files or high traffic, I could generate pre-signed URLs so clients can upload or download files directly from S3. I would also consider versioning, lifecycle policies, encryption, CloudWatch/CloudTrail monitoring, and appropriate backup or replication requirements."

---

# PART 12 — COMPLETE SPRING BOOT + EC2 + S3 ARCHITECTURE

```text
                         USERS
                           |
                           v
                    +-------------+
                    |     DNS     |
                    +------+------+
                           |
                           v
                    +-------------+
                    |Load Balancer|
                    +------+------+
                           |
             +-------------+-------------+
             |                           |
             v                           v
        +---------+                 +---------+
        |  EC2 #1 |                 |  EC2 #2 |
        | Spring  |                 | Spring  |
        |  Boot   |                 |  Boot   |
        +----+----+                 +----+----+
             |                           |
             +-------------+-------------+
                           |
                      IAM Role
                           |
                           v
                    +-------------+
                    |     S3      |
                    |   Bucket    |
                    +-------------+
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
          images/       documents/    backups/

                    +-------------+
                    |     RDS     |
                    +-------------+
                    | Application |
                    |    Data     |
                    +-------------+

                    +-------------+
                    | CloudWatch  |
                    +-------------+
                    | Monitoring  |
                    +-------------+
```

---

# PART 13 — GOLDEN INTERVIEW RULE

When an interviewer gives you an S3 problem, answer in this order:

```text
1. Identify the problem
        ↓
2. Check IAM permissions
        ↓
3. Check bucket policy
        ↓
4. Check object/key
        ↓
5. Check encryption/KMS
        ↓
6. Check VPC/network configuration
        ↓
7. Check application logs
        ↓
8. Fix root cause
        ↓
9. Add preventive controls
```

For security questions:

```text
Private by default
       +
Least privilege
       +
IAM Role
       +
Encryption
       +
Block Public Access
       +
Monitoring
```

For scalability:

```text
S3
 +
Pre-signed URLs
 +
Multipart Upload
 +
Lifecycle Policies
 +
Appropriate Storage Classes
```

For Spring Boot:

```text
Spring Boot
     |
AWS SDK
     |
EC2 IAM Role
     |
S3
```

**Most important sentence to remember:**

> "I would keep the S3 bucket private, use an IAM role with least-privilege permissions for my Spring Boot application, avoid hardcoded AWS credentials, and use pre-signed URLs when direct client-to-S3 transfers are appropriate."