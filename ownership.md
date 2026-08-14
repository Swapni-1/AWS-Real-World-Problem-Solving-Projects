# Architecture Diagram
![cloud cost optimizer](cloud-cost-optimizer.svg)

# VPC Design
![vpc-design](vpc-design.svg)

# EC2 Configuration

### Name and Tags

**Instance Name:** Cloud Cost Optimizer

### Application and OS Images (Amazon Machine Image) 

**Description:** Ubuntu Server 26.04 LTS (HVM),EBS General Purpose (SSD) Volume Type.

**Architecture:** 64-bit (x86)

**AMI ID:** ami-01a00762f46d584a1

**Username:** ubuntu

### Instance type

**Instance Type:** t3.micro

### Key pair (login)

**Key pair name:** cloud-key-pair

### Network Settings

**Network:** vpc-id

**Subnet:** default subnets of selected vpc

**Auto-assign public IP:** Enable

**Firewall(security groups):** Existing Security Group

**Common security groups:** sg-id

### Configure storage

**GiB:** 8

**Type:** gp3


# RDS Configuration

### Engine Options
**Engine type:** MariaDB

### Settings
**Engine Version:** MariaDB 11.8.8

**DB instance identifier:** database-1

### Credentials Settings
**Master Username:** admin

**Credentials management:** self managed

**Master password:** admin123

### Additional credential settings
**Database authentication options:** Password and IAM Database authentication

### Instance configuration
**DB instance class:** Burstable classes (includes t classes)

**instance type:** db.t4g.micro

### Storage
**Storage type:** General Purpose SSD (gp3)

**Allocated storage:** 10 GiB

### Connectivity

**Compute resource:** Don’t connect to an EC2 compute resource

**Virtual private cloud (VPC):** vpc-id

**DB subnet group:** 2 subnets

**Public Access:** No

**VPC security group (firewall):** Choose existing

**Existing VPC security groups:** sg-id

**Availability Zone:** ap-south-1a

### Additional Configuration
**Database port:** 3306

# S3 Configuration

### General Configuration
 
**AWS Region:** Asia Pacific (Mumbai) ap-south-1

**Bucket Type:** General Purpose

**Bucket Namespace:** Global Namespace

**Bucket Name:** amzn-s3-demo-bucket

### Object Ownership

**Object Ownership:** ACLs disabled (recommended)

**Object Ownership:** Bucket owner enforced

### Block Public Access settings for this bucket

**Block all public access:** True

### Bucket Versioning

**Bucket Versioning:** Disable

### Default encryption

**Encryption type:** Server-side encryption with Amazon S3 managed keys (SSE-S3)

**Bucket Key:** Enable

### Advanced settings

**Object Lock:** Disable

# Cloud Watch 

## AWS Free Tier Constraints

- 10 Custom metrices (free)
- 10 Alarms (free)
- 5 GB Log Data Ingestion (free)
- 5 GB Log Storage (free)
- 3 Custom Dashboard and every dashboard upto 50 metrices (free)

## Monitoring List

### 🔴 Critical
1. EC2
2. RDS
3. EBS
4. Lambda
5. DynamoDB

### 🟠 High
6. API Gateway
7. EventBridge
8. EventBridge Scheduler
9. S3

### 🟡 Supporting/Operational
10. SNS
11. VPC

## CloudWatch Dashboards

### Dashboard 1
**Dashboard name:** CCO-Infrastructure

**Services list:**
- EC2
- EBS
- RDS
- S3

**EC2 metrices list:**
- CPUUtilization
- NetworkIn
- NetworkOut
- StatusCheckFailed

**EBS metrices list:**
- VolumeReadOps
- VolumeWriteOps
- VolumeReadByte
- VolumeWriteByte

**RDS metrices list:**
- CPUUtilization
- DatabaseConnections
- ReadIOPS
- WriteIOPS
- ReadThroughput
- WriteThroughput

**S3 metrices list:**
- BucketSizeBytes
- NumberOfObjects

**Dashboard 1 design:**

### Dashboard 2
**Dashboard name:** CCO-Platform

**Services list:** 
- Lambda
- DynamoDB
- API Gateway
- EventBridge
- Scheduler
- SNS

**Lambda metrices list:**
- Invocations
- Errors
- Durations
- Throttles
- ConcurrentExecutions

**DynamoDB metrices list:**
- ConsumedReadCapacityUnits
- ConsumedWriteCapacityUnits
- ReadThrottleEvents
- WriteThrottleEvents
- SuccessfulRequestLatency
- SystemErrors
- UserErros

**API Gateway metrices list:**
- Count
- 4XXError
- 5XXError
- Latency
- IntegrationLatency

**EventBridge metrices list:**
- Invocations
- FailedInvocations
- ThrottledRules
- TriggeredRules

**EventBridge Scheduler metrices list:**
- Invocations
- Errors
- Duration

**SNS metrices list:**
- NumberOfMessagePublised
- NumberOfNotificationDelivered
- NumberOfNotificationsFailed

**Dashboard 2 Design:**

### Dashboard 3
**Dashboard name:** CCO-Finops

**Custom metrices lists:**
- ResourcesScanned
- FindingsGenerated
- IdleResources
- OverprovisionedResources
- UnusedStorage
- ScanSuccess
- ScanFailure

**Dashboard 3 Design:**

### Cloudwatch Alarms

| Alarm | Metric | Purpose|
|------|--------|--------|
| EC2 High CPU | CPUUtilization | Workload spike |
| EC2 Status Failure | StatusCheckFailed | Instance health |
| RDS High CPU | CPUUtilization | DB overload |
| RDS Low Storage | FreeStorageSpace | DB storage risk |
| Scanner Errors | Lambda Errors | Scanner failure |
| Lambda Throttles | Lamba Throttles | Lambda capacity issue |
| API 5XX | API Gateway 5XXError | API failure |
| API High Latency | API Gateway Latency | Dashboard/API performance |
| DynamoDB Throttle | Read/Write throttle metric | Data-store capacity |
| FinOps Scan Failure | Custom ScanFailure | Optimizer failure |





