# AWS Environment Gold Image - Architecture Diagram

## High-Level Architecture

```
+-----------------------------------------------------------------------+
|                             AWS Cloud                                  |
|                                                                        |
|  +-------------------------------------------------------------------+ |
|  |                            VPC                                    | |
|  |                                                                   | |
|  |  +------------------+        +------------------+                 | |
|  |  |  Availability    |        |  Availability    |                 | |
|  |  |     Zone 1       |        |     Zone 2       |                 | |
|  |  |                  |        |                  |                 | |
|  |  | +-------------+  |        | +-------------+  |                 | |
|  |  | |Public Subnet|  |        | |Public Subnet|  |                 | |
|  |  | |             |  |        | |             |  |                 | |
|  |  | |    ALB      |  |        | | NAT Gateway |  |                 | |
|  |  | +------+------+  |        | +------+------+  |                 | |
|  |  |        |         |        |        |         |                 | |
|  |  | +------+------+  |        | +------+------+  |                 | |
|  |  | |Private Subnet| |        | |Private Subnet| |                 | |
|  |  | |             | |        | |             | |                 | |
|  |  | | EC2 Instance| |<--------->| EC2 Instance| |                 | |
|  |  | +------+------+ |        | +------+------+ |                 | |
|  |  |        |        |        |        |        |                 | |
|  |  | +------+------+ |        | +------+------+ |                 | |
|  |  | |  Database   | |<--------->|  Database   | |                 | |
|  |  | |    (RDS)    | |        | |   Replica   | |                 | |
|  |  | +-------------+ |        | +-------------+ |                 | |
|  |  |                  |        |                  |                 | |
|  |  +------------------+        +------------------+                 | |
|  |                                                                   | |
|  +-------------------------------------------------------------------+ |
|                                                                        |
|  +-------------+    +-------------+    +-------------+    +----------+ |
|  |     S3      |    | CloudWatch  |    |    IAM      |    |   KMS    | |
|  |   Storage   |    |  Monitoring |    |   Roles     |    |          | |
|  +-------------+    +-------------+    +-------------+    +----------+ |
|                                                                        |
+------------------------------------------------------------------------+
```

## Architecture Components

### Networking Layer
- **VPC**: Isolated network environment
- **Subnets**: Public and private subnets across multiple AZs
- **Internet Gateway**: (Not shown) Provides internet access
- **NAT Gateway**: Allows private resources to access internet
- **Route Tables**: (Not shown) Control traffic flow

### Compute Layer
- **EC2 Instances**: Application servers in private subnets
- **Auto Scaling Groups**: (Not shown) Manage EC2 instances
- **Application Load Balancer (ALB)**: Distributes traffic

### Data Layer
- **RDS Database**: Primary database in first AZ
- **RDS Replica**: Read replica in second AZ for redundancy
- **S3 Storage**: Object storage for application data

### Security Components
- **Security Groups**: (Not shown) Firewall rules
- **IAM Roles**: Access control for AWS resources
- **KMS**: Key management for encryption

### Monitoring
- **CloudWatch**: Metrics, logs, and alarms

## Multi-Environment Support

This architecture can be deployed as separate environments:

1. **Development Environment**
   - Smaller instance sizes
   - Single AZ deployment possible
   - Reduced redundancy

2. **Testing Environment**
   - Similar to production but with test data
   - May use smaller instance sizes

3. **Production Environment**
   - Full multi-AZ deployment
   - Maximum redundancy and scaling
   - Production-grade security controls

## Deployment Process

The architecture is deployed using Terraform modules:

1. **Core Infrastructure**: VPC, subnets, gateways
2. **Security Layer**: IAM roles, security groups
3. **Compute Resources**: EC2 instances, load balancers
4. **Data Layer**: RDS databases, S3 buckets
5. **Monitoring**: CloudWatch dashboards and alarms

Each environment (dev, test, prod) uses the same modules with different configuration parameters.