# AWS EC2 + S3 with Spring Boot — Beginner Interview Notes

## 1. What we are going to build

We have a Spring Boot application:

```text
Spring Boot Application
        |
        v
      EC2
        |
        | IAM Role
        v
       S3
```

Example:

A user uploads a profile image through our Spring Boot application.

```text
User
 |
 | Upload profile.jpg
 v
Spring Boot Application
 |
 | AWS SDK
 v
S3 Bucket
 |
 +-- profile.jpg
```

The Spring Boot application runs on EC2, and S3 stores uploaded files.

---

# 2. AWS services we need

For this project, understand these services:

```text
EC2       -> Runs our Spring Boot application
S3        -> Stores files/images/documents
IAM       -> Provides permissions
Security Group -> Acts as firewall
EBS       -> Disk attached to EC2
VPC       -> AWS networking
```

The most important relationship is:

```text
EC2
 |
 | IAM Role
 |
 v
S3
```

---

# 3. What is EC2?

EC2 stands for:

```text
Elastic Compute Cloud
```

EC2 provides virtual servers in AWS.

We can install:

```text
Linux
Java
Git
Nginx
Docker
Spring Boot
```

on an EC2 instance.

Think of it like:

```text
EC2 = Cloud Computer / Cloud Server
```

For our Spring Boot application:

```text
EC2 Server
 |
 +-- Linux
 +-- Java
 +-- Spring Boot application
 +-- Application logs
```

---

# 4. What is S3?

S3 stands for:

```text
Simple Storage Service
```

S3 is an object storage service.

We use S3 to store:

```text
Images
PDFs
Videos
Documents
Backups
Logs
Files
```

Example:

```text
S3 Bucket
 |
 +-- profile.jpg
 +-- resume.pdf
 +-- invoice.pdf
 +-- product-image.png
```

Think:

```text
EC2 = Server
S3  = File/Object Storage
```

---

# 5. EC2 vs S3

| EC2 | S3 |
|---|---|
| Compute service | Storage service |
| Runs applications | Stores objects/files |
| Has CPU and RAM | Designed for object storage |
| Runs Spring Boot | Stores images/PDFs/etc. |
| Linux/Windows server | Bucket/object model |
| Application server | File/object storage |

Interview answer:

"EC2 is a compute service used to run applications, whereas S3 is an object storage service used to store and retrieve files such as images, documents, videos, and backups."

---

# 6. What is an S3 Bucket?

A bucket is a container for objects.

Example:

```text
my-springboot-files
       |
       +-- profile.jpg
       +-- resume.pdf
       +-- invoice.pdf
```

Think:

```text
Bucket = Folder/container at a high level
Object = File stored inside S3
```

Technically, S3 uses an object/key model rather than a traditional filesystem.

---

# 7. What is an S3 Object?

An object is the data/file stored in S3 along with metadata.

Example:

```text
Bucket:
my-springboot-files

Object:
profile.jpg
```

We can also organize object keys using prefixes:

```text
my-springboot-files
 |
 +-- users/
 |    |
 |    +-- 101/profile.jpg
 |    +-- 102/profile.jpg
 |
 +-- invoices/
      |
      +-- invoice-001.pdf
```

---

# 8. What is IAM?

IAM stands for:

```text
Identity and Access Management
```

IAM controls:

```text
Who can access AWS resources?
What can they do?
Which resources can they access?
```

Example:

```text
Spring Boot running on EC2
             |
             v
          IAM Role
             |
             v
             S3
```

---

# 9. What is IAM Role?

An IAM role provides permissions to an AWS service or workload.

For our application:

```text
EC2
 |
 +-- IAM Role
       |
       +-- s3:GetObject
       +-- s3:PutObject
       +-- s3:ListBucket
```

The Spring Boot application can then use the AWS SDK without putting permanent AWS access keys in the source code.

IMPORTANT:

DO NOT do this:

```java
String accessKey = "xxxxx";
String secretKey = "xxxxx";
```

Instead:

```text
EC2
 |
 IAM Role
 |
 v
S3
```

This is the recommended approach for applications running on EC2.

---

# 10. What is Security Group?

Security Group acts like a virtual firewall for EC2.

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

Typical rules:

```text
Port 22  -> SSH
Port 80  -> HTTP
Port 443 -> HTTPS
```

For a Spring Boot application running directly on port 8080 during testing:

```text
Port 8080 -> Spring Boot
```

However, in a production deployment, a common setup is:

```text
Internet
   |
   | HTTPS
   v
Nginx / Load Balancer
   |
   v
Spring Boot
   |
   v
Port 8080
```

We generally don't expose unnecessary ports publicly.

---

# 11. Spring Boot application architecture

Our application can look like this:

```text
                    USER
                      |
                      | HTTPS
                      v
               +--------------+
               |     EC2      |
               |              |
               |    Nginx     |
               |      |       |
               |      v       |
               | Spring Boot  |
               |      |       |
               +------+-------+
                      |
                      | IAM Role
                      v
               +--------------+
               |     S3       |
               |    Bucket    |
               +--------------+
```

---

# 12. Complete deployment flow

The overall process is:

```text
STEP 1
Create S3 bucket

       ↓

STEP 2
Create IAM policy

       ↓

STEP 3
Create IAM role for EC2

       ↓

STEP 4
Launch EC2

       ↓

STEP 5
Attach IAM role to EC2

       ↓

STEP 6
Configure Security Group

       ↓

STEP 7
Connect to EC2 using SSH

       ↓

STEP 8
Install Java

       ↓

STEP 9
Copy Spring Boot JAR to EC2

       ↓

STEP 10
Run Spring Boot application

       ↓

STEP 11
Configure Spring Boot S3 integration

       ↓

STEP 12
Test upload/download from S3
```

---

# 13. Step 1 — Create S3 Bucket

Go to:

```text
AWS Console
   |
   +-- S3
       |
       +-- Create bucket
```

Example bucket name:

```text
my-springboot-file-storage-2026
```

Bucket names must be globally unique.

For a normal private application bucket, keep:

```text
Block Public Access = ON
```

We do NOT need to make the bucket public just because our application needs to upload/download files.

---

# 14. Step 2 — Create IAM Policy

Our Spring Boot application needs to upload and download files.

For example:

```text
s3:ListBucket
s3:GetObject
s3:PutObject
```

An example least-privilege policy is:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::my-springboot-file-storage-2026"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-springboot-file-storage-2026/*"
    }
  ]
}
```

Important:

```text
arn:aws:s3:::bucket-name
```

refers to the bucket.

While:

```text
arn:aws:s3:::bucket-name/*
```

refers to objects inside the bucket.

---

# 15. Step 3 — Create IAM Role

Create:

```text
IAM
 |
 +-- Roles
      |
      +-- Create role
```

Trusted service:

```text
EC2
```

Attach the S3 policy.

Example role name:

```text
SpringBootEC2S3Role
```

Architecture:

```text
EC2
 |
 +-- SpringBootEC2S3Role
          |
          +-- S3 permissions
```

---

# 16. Step 4 — Launch EC2

Go to:

```text
AWS Console
 |
 +-- EC2
      |
      +-- Launch Instance
```

Select an AMI.

For example:

```text
Ubuntu Linux
```

Select a small instance type appropriate for learning.

Create/select a key pair:

```text
springboot-demo-key
```

Keep the private key secure.

---

# 17. Step 5 — Configure Security Group

For initial testing:

```text
SSH
TCP
22
Source = My IP
```

If directly testing Spring Boot:

```text
Custom TCP
8080
Source = My IP
```

For a public web application:

```text
HTTP
80
0.0.0.0/0
```

and/or:

```text
HTTPS
443
0.0.0.0/0
```

A production architecture normally uses HTTPS and a reverse proxy/load balancer.

---

# 18. Step 6 — Attach IAM Role

During EC2 creation, attach:

```text
SpringBootEC2S3Role
```

Now:

```text
EC2
 |
 IAM Role
 |
 +---- S3 permissions
```

This is how our application will access S3.

---

# 19. Step 7 — Connect to EC2

From your local computer:

```bash
chmod 400 springboot-demo-key.pem
```

Then:

```bash
ssh -i springboot-demo-key.pem ubuntu@YOUR_EC2_PUBLIC_IP
```

Example:

```bash
ssh -i springboot-demo-key.pem ubuntu@18.123.45.67
```

Now you are connected to your AWS server.

---

# 20. Step 8 — Install Java

Inside EC2:

```bash
sudo apt update
```

Install Java.

For example:

```bash
sudo apt install openjdk-17-jdk -y
```

Check:

```bash
java -version
```

You should see Java version information.

IMPORTANT:

Use a Java version compatible with your Spring Boot application's requirements.

For example:

```text
Spring Boot Application
        |
        v
      Java 17
```

---

# 21. Step 9 — Build Spring Boot application

On your development machine:

For Maven:

```bash
mvn clean package
```

Your JAR might be:

```text
target/myapp-0.0.1-SNAPSHOT.jar
```

For Gradle:

```bash
./gradlew clean build
```

Your JAR might be:

```text
build/libs/myapp-0.0.1-SNAPSHOT.jar
```

---

# 22. Step 10 — Copy JAR to EC2

From your local machine:

```bash
scp -i springboot-demo-key.pem \
target/myapp-0.0.1-SNAPSHOT.jar \
ubuntu@YOUR_EC2_PUBLIC_IP:/home/ubuntu/
```

Now the server contains:

```text
/home/ubuntu/
       |
       +-- myapp-0.0.1-SNAPSHOT.jar
```

---

# 23. Step 11 — Run Spring Boot

Inside EC2:

```bash
java -jar myapp-0.0.1-SNAPSHOT.jar
```

Spring Boot will start.

If your application runs on:

```text
server.port=8080
```

then it listens on:

```text
0.0.0.0:8080
```

assuming your application is configured appropriately.

You can test:

```text
http://YOUR_EC2_PUBLIC_IP:8080
```

For a temporary learning setup, your Security Group must allow port 8080 from your test IP.

---

# 24. Better way to run Spring Boot

Instead of manually running:

```bash
java -jar myapp.jar
```

we can configure a Linux systemd service.

Example:

```text
Spring Boot
     |
     v
systemd
     |
     +-- start application
     +-- stop application
     +-- restart application
     +-- start on boot
```

Create:

```bash
sudo nano /etc/systemd/system/myapp.service
```

Example:

```ini
[Unit]
Description=Spring Boot Application
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu
ExecStart=/usr/bin/java -jar /home/ubuntu/myapp-0.0.1-SNAPSHOT.jar
SuccessExitStatus=143
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

Then:

```bash
sudo systemctl daemon-reload
```

Enable:

```bash
sudo systemctl enable myapp
```

Start:

```bash
sudo systemctl start myapp
```

Check:

```bash
sudo systemctl status myapp
```

View logs:

```bash
journalctl -u myapp -f
```

---

# 25. Spring Boot + S3

Now let's connect Spring Boot to S3.

The important components are:

```text
Spring Boot
    |
    v
AWS SDK for Java
    |
    v
IAM Role
    |
    v
S3
```

---

# 26. Add AWS SDK dependency

For Maven, use the AWS SDK for Java v2.

Example:

```xml
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
</dependency>
```

If you use the AWS SDK BOM, manage the SDK version through the BOM rather than hardcoding each individual module version.

Example:

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>software.amazon.awssdk</groupId>
            <artifactId>bom</artifactId>
            <version>YOUR_AWS_SDK_VERSION</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

Then:

```xml
<dependency>
    <groupId>software.amazon.awssdk</groupId>
    <artifactId>s3</artifactId>
</dependency>
```

---

# 27. Configure AWS Region

Example:

```properties
aws.region=ap-south-1
aws.s3.bucket-name=my-springboot-file-storage-2026
```

Since the application is running on EC2 with an IAM role, you don't need:

```properties
aws.access-key=...
aws.secret-key=...
```

Do NOT put permanent AWS credentials in:

```text
application.properties
application.yml
GitHub
source code
```

---

# 28. Create S3 Client

Example:

```java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;

@Configuration
public class S3Config {

    @Value("${aws.region}")
    private String region;

    @Bean
    public S3Client s3Client() {
        return S3Client.builder()
                .region(Region.of(region))
                .build();
    }
}
```

Important:

```java
S3Client.builder()
```

will use the AWS SDK credential provider chain.

When running on EC2 with an IAM role, the SDK can obtain credentials supplied through the EC2 role mechanism.

---

# 29. Create S3 Service

Example:

```java
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;

@Service
public class S3Service {

    private final S3Client s3Client;

    @Value("${aws.s3.bucket-name}")
    private String bucketName;

    public S3Service(S3Client s3Client) {
        this.s3Client = s3Client;
    }

    public void uploadFile(MultipartFile file) throws IOException {

        PutObjectRequest request = PutObjectRequest.builder()
                .bucket(bucketName)
                .key(file.getOriginalFilename())
                .contentType(file.getContentType())
                .build();

        s3Client.putObject(
                request,
                RequestBody.fromBytes(file.getBytes())
        );
    }
}
```

---

# 30. Create Controller

Example:

```java
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/files")
public class FileController {

    private final S3Service s3Service;

    public FileController(S3Service s3Service) {
        this.s3Service = s3Service;
    }

    @PostMapping("/upload")
    public ResponseEntity<String> upload(
            @RequestParam("file") MultipartFile file) {

        try {
            s3Service.uploadFile(file);

            return ResponseEntity.ok(
                    "File uploaded successfully"
            );

        } catch (Exception e) {

            return ResponseEntity.internalServerError()
                    .body("Upload failed");
        }
    }
}
```

---

# 31. Complete request flow

Suppose the user uploads:

```text
profile.jpg
```

The request flow is:

```text
User
 |
 | POST /files/upload
 | profile.jpg
 v
Spring Boot
 |
 v
FileController
 |
 v
S3Service
 |
 v
AWS SDK
 |
 v
IAM Role
 |
 v
S3
 |
 +-- profile.jpg
```

This is the key architecture you should understand for interviews.

---

# 32. Testing the API

You can use Postman.

Request:

```text
POST
http://YOUR_EC2_PUBLIC_IP:8080/files/upload
```

Body:

```text
form-data
```

Key:

```text
file
```

Type:

```text
File
```

Select:

```text
profile.jpg
```

Then send.

The Spring Boot application receives the file and uploads it to S3.

---

# 33. Verify in S3

Go to:

```text
AWS Console
   |
   +-- S3
       |
       +-- my-springboot-file-storage-2026
```

You should see:

```text
profile.jpg
```

So:

```text
Postman
   |
   v
EC2
   |
   v
Spring Boot
   |
   v
AWS SDK
   |
   v
IAM Role
   |
   v
S3
```

---

# 34. Better S3 object naming

Don't always use:

```java
file.getOriginalFilename()
```

because different users may upload files with the same filename.

For example:

```text
profile.jpg
profile.jpg
profile.jpg
```

can cause naming collisions.

A better approach is:

```text
users/{userId}/{UUID}-{filename}
```

Example:

```text
users/101/550e8400-e29b-profile.jpg
```

Example Java:

```java
String key =
        "users/"
        + userId
        + "/"
        + UUID.randomUUID()
        + "-"
        + file.getOriginalFilename();
```

Then:

```java
PutObjectRequest request = PutObjectRequest.builder()
        .bucket(bucketName)
        .key(key)
        .contentType(file.getContentType())
        .build();
```

---

# 35. Downloading a file from S3

Example service method:

```java
import software.amazon.awssdk.services.s3.model.GetObjectRequest;

public byte[] downloadFile(String key) {

    GetObjectRequest request = GetObjectRequest.builder()
            .bucket(bucketName)
            .key(key)
            .build();

    return s3Client.getObjectAsBytes(request)
            .asByteArray();
}
```

Flow:

```text
User
 |
 | GET /files/profile.jpg
 v
Spring Boot
 |
 v
S3Service
 |
 v
S3
 |
 v
profile.jpg
 |
 v
Spring Boot
 |
 v
User
```

---

# 36. Very important: S3 does NOT need to be public

Beginners often think:

```text
Spring Boot -> S3
```

requires:

```text
S3 bucket = Public
```

That is incorrect.

A better architecture is:

```text
S3 Bucket
 |
 +-- Block Public Access
 |
 +-- IAM permissions
 |
 +-- Private objects
```

Your Spring Boot application accesses S3 using its IAM role.

---

# 37. What if the user needs to download an image?

You have several design choices.

### Option 1 — Backend downloads from S3

```text
User
 |
 v
Spring Boot
 |
 v
S3
 |
 v
Spring Boot
 |
 v
User
```

### Option 2 — Generate a pre-signed URL

```text
User
 |
 v
Spring Boot
 |
 | Generate pre-signed URL
 v
S3
 |
 v
User downloads directly
```

The second approach can be more efficient for large files because the application server doesn't have to proxy the entire file.

---

# 38. What is a pre-signed URL?

A pre-signed URL gives temporary access to an S3 object without making the bucket/object public.

Conceptually:

```text
Private S3 Object
       |
       v
Spring Boot
       |
       | Generate temporary URL
       v
User
       |
       v
S3
```

Example concept:

```text
https://bucket.s3.amazonaws.com/file.jpg
?temporary-signature=...
```

The URL expires after a specified period.

This is a very useful interview topic.

---

# 39. EC2 + S3 security architecture

A good production-oriented architecture is:

```text
                    INTERNET
                        |
                        v
                +---------------+
                | Load Balancer |
                +-------+-------+
                        |
                        v
                     EC2
                        |
                 Spring Boot
                        |
                        |
                   IAM Role
                        |
                        v
                  +-----------+
                  |    S3     |
                  |  PRIVATE  |
                  |   BUCKET  |
                  +-----------+
```

Important security principles:

```text
S3 bucket -> Private
EC2 -> IAM Role
IAM -> Least privilege
Application -> No hardcoded AWS keys
HTTPS -> Enabled
Security Group -> Only required ports
```

---

# 40. Common interview questions — EC2

## Q1. What is EC2?

Answer:

"EC2 stands for Elastic Compute Cloud. It provides virtual servers in AWS that can be used to run applications such as Spring Boot applications."

---

## Q2. How do you deploy a Spring Boot application to EC2?

Answer:

"I launch an EC2 instance with a suitable Linux AMI, configure the Security Group, attach an IAM role if AWS services are required, connect using SSH, install the required Java version, copy the Spring Boot JAR to the server, and run it using java -jar. For production, I would use systemd or another process manager and typically place Nginx or a load balancer in front of the application."

---

## Q3. What is AMI?

Answer:

"AMI stands for Amazon Machine Image. It is a template used to launch EC2 instances, including the operating system and other configuration."

---

## Q4. What is a Security Group?

Answer:

"A Security Group is a virtual firewall for an EC2 instance. It controls inbound and outbound network traffic."

---

## Q5. What is port 22?

Answer:

"Port 22 is commonly used for SSH access to Linux EC2 instances."

---

## Q6. What is port 8080?

Answer:

"8080 is commonly used by Java/Spring Boot applications, although the application can be configured to use another port."

---

## Q7. What is EBS?

Answer:

"EBS stands for Elastic Block Store. It provides block storage volumes that can be attached to EC2 instances."

---

# 41. Common interview questions — S3

## Q1. What is S3?

Answer:

"S3 stands for Simple Storage Service. It is an object storage service used to store and retrieve files such as images, documents, videos, backups, and logs."

---

## Q2. What is an S3 bucket?

Answer:

"An S3 bucket is a container used to store objects."

---

## Q3. What is an S3 object?

Answer:

"An S3 object is a file or data object stored in an S3 bucket along with its metadata."

---

## Q4. Can S3 run a Spring Boot application?

Answer:

"No. S3 is an object storage service. EC2 or another compute service would run the Spring Boot application, while S3 can store application files."

---

# 42. Common interview questions — EC2 + S3

## Q1. How does your Spring Boot application access S3?

Answer:

"The Spring Boot application uses the AWS SDK for Java. Since the application runs on EC2, I attach an IAM role to the EC2 instance. The role provides the required S3 permissions, allowing the application to access S3 without hardcoding AWS access keys."

---

## Q2. Why don't you put AWS access keys in application.properties?

Answer:

"Hardcoding long-term AWS credentials is a security risk. If the source code is leaked, the credentials could be compromised. For an application running on EC2, I prefer an IAM role and temporary credentials."

---

## Q3. What permissions does the application need to upload files?

Answer:

"For uploading objects, the application generally needs s3:PutObject permission for the appropriate S3 object resources. If it also needs to list or download objects, I would grant s3:ListBucket and s3:GetObject as required."

---

## Q4. What is least privilege?

Answer:

"Least privilege means giving the application only the permissions it needs and nothing more."

---

## Q5. Does the S3 bucket need to be public?

Answer:

"No. The bucket can remain private. The Spring Boot application can access it using an IAM role attached to the EC2 instance."

---

## Q6. What happens if the IAM role doesn't have s3:PutObject?

Answer:

"The application will receive an AccessDenied or authorization error when it tries to upload an object."

---

# 43. Important troubleshooting questions

## Problem 1 — Spring Boot cannot upload to S3

Check:

```text
1. Is the EC2 IAM role attached?
2. Does the role have s3:PutObject?
3. Is the bucket name correct?
4. Is the AWS region correct?
5. Is the object ARN correct?
6. Is there an S3 bucket policy denying access?
7. Are there KMS permissions required for encryption?
8. Check Spring Boot logs.
```

---

# 44. Problem 2 — Cannot connect to Spring Boot

Check:

```text
1. Is EC2 running?
2. Is Spring Boot running?
3. Is the application listening on the expected port?
4. Is the Security Group allowing that port?
5. Is the EC2 public IP correct?
6. Is Nginx configured correctly?
7. Check application logs.
```

Useful command:

```bash
sudo systemctl status myapp
```

Check listening ports:

```bash
sudo ss -lntp
```

Check logs:

```bash
journalctl -u myapp -f
```

---

# 45. Problem 3 — SSH doesn't work

Check:

```text
1. EC2 is running
2. Correct public IP
3. Correct username
4. Port 22 allowed
5. Correct private key
6. Private key permissions
7. Network connectivity
```

Example:

```bash
chmod 400 springboot-demo-key.pem
```

Then:

```bash
ssh -i springboot-demo-key.pem ubuntu@EC2_PUBLIC_IP
```

---

# 46. Important difference: EC2 vs RDS vs S3

Remember:

```text
EC2
 |
 +-- Application / Server

RDS
 |
 +-- Relational Database

S3
 |
 +-- Files / Objects
```

Example application:

```text
                  Spring Boot
                       |
          +------------+-------------+
          |            |             |
          v            v             v
        EC2           RDS           S3
       Compute      Database       Files
```

For example:

```text
User information -> RDS
Profile image     -> S3
Spring Boot       -> EC2
```

---

# 47. Real-world Spring Boot architecture

A more realistic production architecture:

```text
                         INTERNET
                            |
                            v
                    +---------------+
                    |      DNS      |
                    +-------+-------+
                            |
                            v
                    +---------------+
                    | Load Balancer |
                    +-------+-------+
                            |
               +------------+------------+
               |                         |
               v                         v
          +---------+               +---------+
          |  EC2    |               |  EC2    |
          | Spring  |               | Spring  |
          |  Boot   |               |  Boot   |
          +----+----+               +----+----+
               |                         |
               +------------+------------+
                            |
              +-------------+-------------+
              |                           |
              v                           v
           RDS                         S3
        Database                     Files
```

The IAM role is attached to each EC2 instance:

```text
EC2
 |
 +-- IAM Role
       |
       +-- S3 permissions
```

---

# 48. Very important interview scenario

Interviewer:

"Your Spring Boot application is running on EC2 and needs to upload images to S3. How would you design it?"

Answer:

"I would create a private S3 bucket for the images and create an IAM role for EC2 with least-privilege permissions, such as s3:PutObject for the required bucket path. I would attach that role to the EC2 instance. In the Spring Boot application, I would use the AWS SDK for Java and rely on the SDK's credential provider chain rather than hardcoding AWS access keys. The application would upload the image to S3 using the S3Client."

Architecture:

```text
User
 |
 v
Spring Boot on EC2
 |
 | AWS SDK
 |
 v
EC2 IAM Role
 |
 | s3:PutObject
 v
Private S3 Bucket
 |
 +-- images/
      |
      +-- user-101/profile.jpg
```

---

# 49. Interview scenario — Why S3?

Interviewer:

"Why don't you store uploaded images directly on EC2?"

Answer:

"EC2 is primarily compute infrastructure. Storing application files only on the local server makes scaling and file management more difficult. S3 is designed for object storage and allows the application layer and file storage layer to be separated. This also makes it easier to run multiple application instances."

---

# 50. Interview scenario — Multiple EC2 instances

Suppose we have:

```text
EC2 #1
Spring Boot
 |
 +-- profile.jpg
```

and:

```text
EC2 #2
Spring Boot
 |
 +-- profile.jpg
```

This can create consistency problems.

Better:

```text
                 Load Balancer
                  /          \
                 /            \
                v              v
             EC2 #1          EC2 #2
                \              /
                 \            /
                  v          v
                    S3
                     |
               profile.jpg
```

Now both application servers use the same object storage.

---

# 51. Important commands to remember

## Connect to EC2

```bash
ssh -i key.pem ubuntu@EC2_PUBLIC_IP
```

## Update Linux

```bash
sudo apt update
```

## Install Java

```bash
sudo apt install openjdk-17-jdk -y
```

## Check Java

```bash
java -version
```

## Run Spring Boot

```bash
java -jar myapp.jar
```

## Check service

```bash
sudo systemctl status myapp
```

## Start service

```bash
sudo systemctl start myapp
```

## Stop service

```bash
sudo systemctl stop myapp
```

## Restart service

```bash
sudo systemctl restart myapp
```

## View logs

```bash
journalctl -u myapp -f
```

---

# 52. 30-second interview answer

If the interviewer asks:

"Explain your AWS architecture."

Say:

"My Spring Boot application is deployed on an EC2 instance. EC2 provides the compute environment where Java and the Spring Boot application run. For file storage, such as user-uploaded images and documents, I use an S3 bucket. The S3 bucket is private, and the EC2 instance has an IAM role with least-privilege S3 permissions. The Spring Boot application uses the AWS SDK for Java to upload and download objects from S3. I avoid hardcoding AWS access keys and use the EC2 IAM role instead. In production, I would typically put a load balancer or Nginx in front of the application and use HTTPS."

---

# 53. Quick revision sheet

```text
EC2
=
Virtual Server

S3
=
Object Storage

IAM
=
Permissions

IAM Role
=
Permissions for workload/service

Security Group
=
Firewall

EBS
=
Block Storage / Disk

AMI
=
Template for EC2

Bucket
=
S3 container

Object
=
File/data stored in S3

PutObject
=
Upload object

GetObject
=
Download/read object

ListBucket
=
List objects in bucket

Least Privilege
=
Only required permissions

Spring Boot
=
Application running on EC2

AWS SDK
=
Java library used by Spring Boot to communicate with AWS services
```

---

# 54. Final architecture to remember

```text
                         USER
                           |
                           | HTTPS
                           v
                   +---------------+
                   | Load Balancer |
                   +-------+-------+
                           |
                           v
                  +----------------+
                  |      EC2       |
                  |                |
                  | Linux          |
                  | Java           |
                  | Spring Boot    |
                  +-------+--------+
                          |
                          |
                    IAM Role
                          |
                          | S3 permissions
                          |
                          v
                  +----------------+
                  |       S3       |
                  | Private Bucket |
                  +-------+--------+
                          |
             +------------+------------+
             |            |            |
             v            v            v
         image.jpg    resume.pdf   invoice.pdf


                  Spring Boot
                       |
                       v
                  RDS (optional)
                       |
                       v
                    Database
```

The most important sentence to remember for interviews is:

**"EC2 runs my Spring Boot application, S3 stores my application files, and an IAM role gives the EC2 application secure, least-privilege access to S3 without hardcoded AWS credentials."**