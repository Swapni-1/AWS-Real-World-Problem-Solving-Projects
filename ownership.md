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

**Service:** EC2 

| Metrice | Widget |
|---------|--------|
| CPUUtilization | Line Graph |
| NetworkIn | Line Graph|
| NetworkOut | Line Graph |
| StatusCheckFailed | Number Graph |

**Service:** EBS

| Metrice | Widget |
|---------|--------|
| VolumeReadOps | Line Graph |
| VolumeWriteOps | Line Graph |
| VolumeReadBytes | Line Graph |
| VolumeWriteBytes | Line Graph |

**Service:** RDS

| Metrice | Widget |
|---------|--------|
| CPUUtilization | Line Graph |
| DatabaseConnections | Line Graph |
| FreeStorageSpace | Gauge + Alarm |
| ReadIOPS | Line Graph |
| WriteIOPS | Line Graph |
| ReadThroughput | Line Graph |
| WriteThroughput | Line Graph |

**Service:** S3

| Metrice | Widget |
|---------|--------|
| BucketSizeBytes | Line Graph |
| NumberOfObjects | Bar Chart |

**Dashboard 1 design:**

```text
╔══════════════════════════════════════════════════════════════════════════════╗
║                 CCO-INFRASTRUCTURE                                           ║
║            AWS Resource Health & Utilization                                 ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║                         INFRASTRUCTURE HEALTH                                ║
║                                                                              ║
║   EC2 Status      RDS Status      EC2 Status      RDS Free Storage           ║
║   ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────────┐           ║
║   │    🟢    │    │    🟢    │    │  Failed  │    │    42 GB     │           ║
║   │   HEALTHY│    │  HEALTHY │    │     0    │    │    Gauge     │           ║
║   └──────────┘    └──────────┘    └──────────┘    └──────────────┘           ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                              EC2                                             ║
║                                                                              ║
║  CPU UTILIZATION                         NETWORK TRAFFIC                     ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │                            │          │                            │      ║
║  │      CPUUtilization        │          │    NetworkIn / NetworkOut  │      ║
║  │        LINE GRAPH          │          │        LINE GRAPH          │      ║
║  │                            │          │                            │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  STATUS CHECK                              DISK ACTIVITY                     ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ StatusCheckFailed          │          │ ReadOps / WriteOps         │      ║
║  │                            │          │ ReadBytes / WriteBytes     │      ║
║  │          NUMBER            │          │       LINE GRAPH           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                              RDS                                             ║
║                                                                              ║
║  CPU + CONNECTIONS                      IOPS                                 ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ CPUUtilization             │          │ ReadIOPS / WriteIOPS       │      ║
║  │ DatabaseConnections        │          │                            │      ║
║  │       LINE GRAPH           │          │       LINE GRAPH           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  THROUGHPUT                              FREE STORAGE                        ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ ReadThroughput             │          │                            │      ║
║  │ WriteThroughput            │          │       FREE STORAGE         │      ║
║  │       LINE GRAPH           │          │          GAUGE             │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                             EBS                                              ║
║                                                                              ║
║  EBS OPERATIONS                           EBS THROUGHPUT                     ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ VolumeReadOps              │          │ VolumeReadBytes            │      ║
║  │ VolumeWriteOps             │          │ VolumeWriteBytes           │      ║
║  │       LINE GRAPH           │          │       LINE GRAPH           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                              S3                                              ║
║                                                                              ║
║  BUCKET STORAGE                            OBJECT COUNT                      ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ BucketSizeBytes            │          │ NumberOfObjects            │      ║
║  │        BAR / LINE          │          │        BAR CHART           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                         NETWORK / VPC                                        ║
║                                                                              ║
║  VPC FLOW LOGS / NETWORK EVENTS                                              ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │ Accepted traffic       Rejected traffic       Network anomalies        │  ║
║  │                         LOG / COUNT VIEW                               │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Dashboard 2
**Dashboard name:** CCO-Platform

**Service:** Lambda
| Metrice | Widget |
|---------|--------|
| Invocations | Line Graph |
| Errors | Number |
| Duration | Line Graph |
| Throttles | Number |
| ConcurrentExecutions | Line Graph |

**Service:** DynamoDB
| Metrice | Widget |
|---------|--------|
| ConsumedReadCapacityUnits | Line Graph |
| ConsumedWriteCapacityUnits | Line Graph |
| ReadThrottleEvents | Number |
| WriteThrottleEvents | Number |
| SuccessfulRequestLatency | Line Graph |
| SystemErrors | Number |
| UserErrors | Number |

**Service:** API Gateway
| Metrice | Widget |
|---------|--------|
| Count | Line Graph |
| 4XXError | Line Graph|
| 5XXError | Line Graph |
| Latency | Line Graph |
| IntegrationLatency | Line Graph |

**Service:** EventBridge
| Metrice | Widget |
|---------|--------|
| Invocations | Line Graph |
| FailedInvocations | Number |
| ThrottledRules | Number |
| TriggeredRules | Line Graph |

**Service:** EventBridge Scheduler
| Metrice | Widget |
|---------|--------|
| Invocations | Number |
| Errors | Number |
| Duration | Line Graph |

**Service:** SNS
| Metrice | Widget |
|---------|--------|
| NumberOfMessagePublised | Number |
| NumberOfNotificationDelivered | Number |
| NumberOfNotificationsFailed | Number |

**Dashboard 2 Design:**

```text
╔══════════════════════════════════════════════════════════════════════════════╗
║                     CCO-PLATFORM                                             ║
║              Cloud Cost Optimizer Platform Health                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║                           PLATFORM HEALTH                                    ║
║                                                                              ║
║  Scanner        Analyzer       Dashboard API      DynamoDB      Scheduler    ║
║   🟢               🟢               🟢              🟢             🟢        ║
║  HEALTHY         HEALTHY          HEALTHY        HEALTHY        HEALTHY      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                             LAMBDA                                           ║
║                                                                              ║
║  INVOCATIONS / ERRORS                    EXECUTION DURATION                  ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ Invocations                │          │ Duration                   │      ║
║  │ Errors                     │          │ Avg / p95 / p99            │      ║
║  │       LINE GRAPH           │          │       LINE GRAPH           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  THROTTLES                               CONCURRENCY                         ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │          0                 │          │ ConcurrentExecutions       │      ║
║  │       NUMBER               │          │       LINE GRAPH           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  FUNCTIONS                                                                   ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │ resource-scanner     🟢  24 invocations      0 errors                  │  ║
║  │ finops-analyzer      🟢  24 invocations      0 errors                  │  ║
║  │ dashboard-api        🟢  180 requests        0 errors                  │  ║
║  │ approval-handler     🟢  healthy                                       │  ║
║  │ remediation-handler  🟢  healthy                                       │  ║
║  │ incident-handler     🟢  healthy                                       │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                           DYNAMODB                                           ║
║                                                                              ║
║  READ / WRITE CAPACITY                  THROTTLING                           ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ ReadCapacity               │          │ ReadThrottleEvents         │      ║
║  │ WriteCapacity              │          │ WriteThrottleEvents        │      ║
║  │       LINE GRAPH           │          │     NUMBER / LINE          │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  LATENCY                                  ERRORS                             ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ SuccessfulRequestLatency   │          │ SystemErrors / UserErrors  │      ║
║  │       LINE GRAPH           │          │       NUMBER               │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                         API GATEWAY                                          ║
║                                                                              ║
║  REQUEST TRAFFIC                         ERROR RATE                          ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ Count                      │          │ 4XXError / 5XXError        │      ║
║  │       LINE GRAPH           │          │       NUMBER / LINE        │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  LATENCY                                  INTEGRATION LATENCY                ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ Latency                    │          │ IntegrationLatency         │      ║
║  │       LINE GRAPH           │          │       LINE GRAPH           │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                      EVENT-DRIVEN PIPELINE                                   ║
║                                                                              ║
║  EVENTBRIDGE                              SCHEDULER                          ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ Invocations                │          │ Invocations                │      ║
║  │ TriggeredRules             │          │ Errors                     │      ║
║  │ FailedInvocations          │          │ Duration                   │      ║
║  │ ThrottledRules             │          │                            │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                              SNS                                             ║
║                                                                              ║
║  PUBLISHED          DELIVERED          FAILED                                ║
║    ┌───────┐          ┌───────┐          ┌───────┐                           ║
║    │  18   │          │  18   │          │   0   │                           ║
║    └───────┘          └───────┘          └───────┘                           ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Dashboard 3
**Dashboard name:** CCO-Finops

**Custom**
| Metrice | Widget |
|---------|--------|
| ResourcesScanned | Number |
| FindingsGenerated | Number + Line Graph |
| IdleResources | Number + Line Graph|
| OverprovisionedResources | Number |
| UnusedStorage | Number + Optional Line |
| ScanSuccess | Number + Line |
| ScanFailure | Number + Line |

**Dashboard 3 Design:**

```text
╔══════════════════════════════════════════════════════════════════════════════╗
║                         CCO-FINOPS                                           ║
║              Cloud Cost Optimization Intelligence                            ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║                         LATEST FINOPS SCAN                                   ║
║                                                                              ║
║   RESOURCES SCANNED     FINDINGS     IDLE RESOURCES     UNUSED STORAGE       ║
║          31                 17              11                120 GB         ║
║                                                                              ║
║   OVERPROVISIONED        SCAN STATUS       LAST SCAN       NEXT SCAN         ║
║          3                 🟢 SUCCESS      14:00 UTC       15:00 UTC         ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                      FINOPS DETECTION TREND                                  ║
║                                                                              ║
║  RESOURCES SCANNED                      FINDINGS GENERATED                   ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │                            │          │                            │      ║
║  │        LINE GRAPH          │          │        LINE GRAPH          │      ║
║  │                            │          │                            │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  IDLE RESOURCES                          OVERPROVISIONED                     ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │                            │          │                            │      ║
║  │        LINE GRAPH          │          │        LINE GRAPH          │      ║
║  │                            │          │                            │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                      STORAGE OPTIMIZATION                                    ║
║                                                                              ║
║  UNUSED STORAGE                         RESOURCE DISTRIBUTION                ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │                            │          │ Idle EC2       ██████  6   │      ║
║  │         120 GB             │          │ Overprov. RDS  ███    3    │      ║
║  │          NUMBER            │          │ Unused EBS     ███████ 8   │      ║
║  └────────────────────────────┘          │ S3 Candidates  ████   4    │      ║
║                                          └────────────────────────────┘      ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                           SCAN HEALTH                                        ║
║                                                                              ║
║  SCAN SUCCESS                            SCAN FAILURE                        ║
║  ┌────────────────────────────┐          ┌────────────────────────────┐      ║
║  │ 🟢                         │          │ 🔴                         │      ║
║  │       SUCCESS = 1          │          │       FAILURE = 0          │      ║
║  │       NUMBER               │          │       NUMBER               │      ║
║  └────────────────────────────┘          └────────────────────────────┘      ║
║                                                                              ║
║  SCAN EXECUTION HISTORY                                                      ║
║  ┌────────────────────────────────────────────────────────────────────────┐  ║
║  │ 14:00   ✓ 31 resources   17 findings                                   │  ║
║  │ 13:00   ✓ 31 resources   15 findings                                   │  ║
║  │ 12:00   ✓ 31 resources   14 findings                                   │  ║
║  │ 11:00   ✗ Scan failed                                                  │  ║
║  └────────────────────────────────────────────────────────────────────────┘  ║
║                                                                              ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                     FINOPS PIPELINE STATUS                                   ║
║                                                                              ║
║   Scheduler          Scanner Lambda        Analyzer Lambda      DynamoDB     ║
║      🟢                  🟢                    🟢                 🟢         ║
║                                                                              ║
║   LAST SCAN: 14:00 UTC       SCAN RESULT: SUCCESS       FINDINGS: 17         ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Cloudwatch Alarms

**1. EC2 High CPU**

```text
EC2
 ↓
CPUUtilization > 80%
 ↓
CloudWatch Alarm 🚨
 ↓
SNS
 ↓
Alert
```
**Notification:**

```text
🚨 EC2 HIGH CPU

Resource: ec2-prod-api
CPU: 92%
Threshold: 80%
```

❌ Lambda 
❌ EventBridge

Unneccessary, don't invoke lambda to add cost/complexity. 

**2. EC2 Status Failure**

```text
EC2
 ↓
StatusCheckFailed > 0
 ↓
CloudWatch Alarm
 ↓
SNS
 ↓
EventBridge
 ↓
Incident Handler Lambda
```

**Lambda :**

```text
1. Alarm details read
2. Instance identify
3. Current instance state check
4. Basic health information collect
5. Incident create
6. DynamoDB me store
7. Dashboard update
```

**Example Incident :**
```text
INC-1001

Resource:
ec2-prod-api

Problem:
Status check failed

Severity:
HIGH

Status:
OPEN
```

❌ Automatic start/stop.

**3. RDS High CPU**

```text
RDS
 ↓
CPU > 80%
 ↓
Alarm
 ↓
SNS
 +
EventBridge
 ↓
Incident Handler Lambda
```

**Lambda additional signals check kare :**

```text
CPUUtilization
DatabaseConnections
ReadIOPS
WriteIOPS
ReadThroughput
WriteThroughput
```

**Example :**

```text
CPU              91%
Connections      900
ReadIOPS         High
WriteIOPS        High

Diagnosis:
High database workload
```

**DynamoDB :**

```text
Incident = OPEN
```

**SNS :**
```text
🚨 RDS High CPU
```

❌ Automatically RDS resize.

**4. RDS Low Storage**

```text
RDS
 ↓
FreeStorageSpace < threshold
 ↓
Alarm
 ↓
SNS
 +
EventBridge
 ↓
Incident Handler Lambda
```
**Lambda :**

```text
1. Current FreeStorageSpace
2. DB resource identify
3. Current storage condition record
4. Incident create
5. SNS already sent by alarm
```

**Example :**

```text
RDS:
production-db

Free Storage:
7.2 GB

Threshold:
10 GB

Severity:
HIGH
```

❌ Automatically storage resize.

**5. Scanner Lambda Error**

```text
Resource Scanner Lambda
       ↓
Error
       ↓
CloudWatch Alarm
       ↓
SNS
       +
EventBridge
       ↓
Incident Handler Lambda
```

**Lambda :**

```text
1. Scanner identify
2. Last successful execution check
3. Failure details inspect
4. Incident create
5. Scan status update
6. One-time retry
```

**Retry :**

```text
Retry once
   ↓
Success?
 ├── YES → incident resolved
 └── NO  → incident remains OPEN + SNS
```

**6. Lambda Throttles**

```text
Lambda
 ↓
Throttles > 0
 ↓
Alarm
 ↓
SNS
 +
EventBridge
 ↓
Incident Handler Lambda
```

**Lambda Checks :**

```text
Invocations
Throttles
ConcurrentExecutions
Errors
```

**Example :**

```text
finops-analyzer

Invocations: 500
Throttles: 18
Concurrency spike detected
```

**DynamoDB :**

```text
Incident:
LAMBDA_THROTTLING

Status:
OPEN
```

❌ Automatically concurrency increase, especially in Free Tier project.

**7. API Gateway 5XX**

```text
API Gateway
 ↓
5XXError
 ↓
Alarm
 ↓
SNS
 +
EventBridge
 ↓
Incident Handler Lambda
```    

**Lambda Correlates :**

```text
API Gateway 5XX
       +
Dashboard API Lambda Errors
       +
DynamoDB Errors
```

**Example :**

```text
API 5XX:
14

Lambda Errors:
14

Diagnosis:
Backend Lambda failure likely
```

**Dashboard :**

```text
🔴 API INCIDENT

GET /dashboard/summary
Status: OPEN
```

❌ Automatic API deployment/restart.

**8. API High Latency**

```text
API Gateway
 ↓
Latency > threshold
 ↓
Alarm
 ↓
SNS
 +
EventBridge
 ↓
Incident Handler Lambda
```

**Lambda :**

```text
API Latency
vs
IntegrationLatency
```

**Example :**

```text
API Latency          1,240 ms
IntegrationLatency   1,180 ms
```

**Diagnosis :**

```text
Backend integration is primary latency contributor
```

Then showing in incident dashboard.

❌ Automatic scaling/remediation.

**9. DynamoDB Throttle**

```text
DynamoDB
 ↓
Read/Write Throttle
 ↓
Alarm
 ↓
SNS
 +
EventBridge
 ↓
Incident Handler Lambda
```
**Lambda inspects :**

```text
ReadThrottleEvents
WriteThrottleEvents
ConsumedReadCapacity
ConsumedWriteCapacity
```

**Example :**

```text
ReadThrottleEvents: 12
WriteThrottleEvents: 0

Likely issue:
Read workload spike
```

**Incident :**

```text
DynamoDB Throttling
Status: OPEN
Severity: HIGH
```

❌ Automatically capacity change.

**10. FinOps Scan Failure**

```text
EventBridge Scheduler
       ↓
Scanner
       ↓
Analyzer
       ↓
Failure
       ↓
ScanFailure = 1
       ↓
CloudWatch Alarm
       ↓
SNS
 +
EventBridge
       ↓
Incident Handler Lambda
```

**Lambda :**

```text
1. Last successful scan identify
2. Current scan status check
3. Failure reason record
4. Incident create
5. One-time retry
```

**Example :**

```text
Last successful scan:
14:00

Failed scan:
15:00

Resources expected:
47

Resources scanned:
0

Status:
SCAN_FAILED
```

**Retry :**
```text
Retry
 ↓
Success → RESOLVED
Failure → OPEN + SNS
```
# Lambda



