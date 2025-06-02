# AWS Environment Gold Image - Architecture

This document outlines the architecture of the AWS Environment Gold Image solution.

## Overview

The AWS Environment Gold Image is a standardized, templated AWS environment defined as Infrastructure as Code (IaC) using Terraform. It provides a consistent foundation for deploying applications across development, testing, and production environments.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                             AWS Cloud                                   │
│                                                                         │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                            VPC                                  │    │
│  │                                                                 │    │
│  │  ┌───────────────┐        ┌───────────────┐                     │    │
│  │  │ Public Subnet │        │ Public Subnet │   ┌─────────────┐   │    │
│  │  │               │        │               │   │             │   │    │
│  │  │  ┌─────────┐  │        │  ┌─────────┐  │   │    NAT      │   │    │
│  │  │  │   ALB   │  │        │  │   ALB   │  │   │  Gateway    │   │    │
│  │  │  └─────────┘  │        │  └─────────┘  │   │             │   │    │
│  │  │               │        │               │   └─────────────┘   │    │
│  │  └───────┬───────┘        └───────┬───────┘                     │    │
│  │          │                        │                             │    │
│  │          │                        │                             │    │
│  │  ┌───────┴───────┐        ┌───────┴───────┐                     │    │
│  │  │Private Subnet │        │Private Subnet │                     │    │
│  │  │               │        │               │                     │    │
│  │  │  ┌─────────┐  │        │  ┌─────────┐  │                     │    │
│  │  │  │   EC2   │  │        │  │   EC2   │  │                     │    │
│  │  │  │ Instance│◄─┼────────┼─►│ Instance│  │                     │    │
│  │  │  └─────────┘  │        │  └─────────┘  │                     │    │
│  │  │               │        │               │                     │    │
│  │  │  ┌─────────┐  │        │  ┌─────────┐  │                     │    │
│  │  │  │   RDS   │◄─┼────────┼─►│   RDS   │  │                     │    │
│  │  │  │ Database│  │        │  │ Replica │  │                     │    │
│  │  │  └─────────┘  │        │  └─────────┘  │                     │    │
│  │  │               │        │               │                     │    │
│  │  └───────────────┘        └───────────────┘                     │    │
│  │                                                                 │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────────────────┐      │
│  │ CloudWatch  │    │     S3      │    │        IAM Roles        │      │
│  │ Monitoring  │    │   Storage   │    │      & Permissions      │      │
│  └─────────────┘    └─────────────┘    └─────────────────────────┘      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. Networking Layer

- **VPC**: Isolated network environment with custom CIDR block
- **Subnets**: Public and private subnets across multiple Availability Zones
- **Internet Gateway**: Provides internet access for public subnets
- **NAT Gateway**: Allows private subnet resources to access the internet
- **Route Tables**: Control traffic flow between subnets and gateways
- **Network ACLs and Security Groups**: Control inbound and outbound traffic

### 2. Compute Layer

- **EC2 Instances**: Managed through Auto Scaling Groups for high availability
- **Launch Templates**: Define instance configuration including AMI, instance type, and user data
- **Load Balancers**: Application Load Balancer (ALB) to distribute traffic
- **Auto Scaling Policies**: Scale instances based on demand

### 3. Data Layer

- **RDS Database**: Managed relational database service
- **S3 Buckets**: Object storage for application data and backups
- **Database Subnet Groups**: Control database placement within VPC

### 4. Security Components

- **IAM Roles and Policies**: Least privilege access control
- **Security Groups**: Firewall rules for EC2 and RDS instances
- **KMS Keys**: Encryption for data at rest
- **SSL/TLS**: Encryption for data in transit

### 5. Monitoring and Logging

- **CloudWatch**: Metrics, logs, and alarms
- **CloudTrail**: API activity logging
- **VPC Flow Logs**: Network traffic logging

## Environment Separation

The architecture supports multiple environments (development, testing, production) with:

1. **Consistent Structure**: Same components across all environments
2. **Environment-Specific Configuration**: Different sizing and scaling parameters
3. **Isolation**: Separate VPCs for complete isolation between environments

## Scalability and High Availability

- **Multi-AZ Deployment**: Resources distributed across multiple Availability Zones
- **Auto Scaling**: Dynamic adjustment of capacity based on demand
- **Load Balancing**: Distribution of traffic across multiple instances
- **Database Replication**: RDS Multi-AZ for high availability

## Security Considerations

- **Network Segmentation**: Public/private subnet separation
- **Encryption**: Data encrypted at rest and in transit
- **Access Control**: Least privilege IAM policies
- **Security Groups**: Restrictive inbound/outbound rules
- **Patch Management**: AMI updates and instance refresh strategy

## Cost Optimization

- **Right-Sizing**: Appropriate instance types for each environment
- **Auto Scaling**: Scale resources based on demand
- **Reserved Instances**: For predictable workloads
- **Resource Tagging**: For cost allocation and tracking