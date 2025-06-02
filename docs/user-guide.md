# AWS Environment Gold Image - User Guide

This guide provides instructions for using the AWS Environment Gold Image Infrastructure as Code (IaC) solution.

## Getting Started

### Prerequisites

Before you begin, ensure you have the following:

1. **AWS Account**: Active AWS account with appropriate permissions
2. **Terraform**: Installed (version 1.0.0 or later)
3. **AWS CLI**: Installed and configured with appropriate credentials
4. **Git**: Installed for version control

### Initial Setup

1. Clone the repository:
   ```
   git clone https://github.com/your-org/aws-gold-image-iac.git
   cd aws-gold-image-iac
   ```

2. Configure AWS credentials:
   ```
   aws configure
   ```

3. Create a `terraform.tfvars` file in the environment directory you want to deploy:
   ```
   cd environments/dev
   cp terraform.tfvars.example terraform.tfvars
   ```

4. Edit the `terraform.tfvars` file with your specific values:
   ```
   vim terraform.tfvars
   ```

### Deployment

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review the execution plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. Confirm the deployment by typing `yes` when prompted.

## Environment Management

### Switching Environments

The repository contains configurations for three environments:

- **Development**: `environments/dev`
- **Testing**: `environments/test`
- **Production**: `environments/prod`

To switch between environments, navigate to the appropriate directory:

```
cd environments/test
```

### Environment-Specific Configuration

Each environment has its own configuration values in the `terraform.tfvars` file. Customize these values according to your requirements for each environment.

## Common Tasks

### Adding a New EC2 Instance Type

1. Update the `instance_type` variable in the environment's `terraform.tfvars` file:
   ```
   instance_type = "t3.large"
   ```

2. Apply the changes:
   ```
   terraform apply
   ```

### Scaling the Environment

1. Modify the Auto Scaling Group parameters in the environment's `terraform.tfvars` file:
   ```
   asg_min_size = 2
   asg_max_size = 6
   asg_desired_capacity = 4
   ```

2. Apply the changes:
   ```
   terraform apply
   ```

### Updating the Database Configuration

1. Modify the database parameters in the environment's `terraform.tfvars` file:
   ```
   db_instance_class = "db.t3.large"
   ```

2. Apply the changes:
   ```
   terraform apply
   ```

## Customization

### Adding Custom Tags

1. Add or modify tags in the environment's `terraform.tfvars` file:
   ```
   tags = {
     Project     = "AWS-Gold-Image"
     ManagedBy   = "Terraform"
     Environment = "dev"
     Client      = "ClientName"
     Owner       = "YourTeam"
     CostCenter  = "12345"
   }
   ```

2. Apply the changes:
   ```
   terraform apply
   ```

### Modifying Network Configuration

1. Update the CIDR blocks in the environment's `terraform.tfvars` file:
   ```
   vpc_cidr = "10.0.0.0/16"
   public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
   private_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
   ```

2. Apply the changes:
   ```
   terraform apply
   ```

## Maintenance

### Updating the AMI

1. Find the latest AMI ID:
   ```
   aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query "sort_by(Images, &CreationDate)[-1].ImageId" --output text
   ```

2. Update the `ami_id` variable in the environment's `terraform.tfvars` file:
   ```
   ami_id = "ami-0abcdef1234567890"
   ```

3. Apply the changes:
   ```
   terraform apply
   ```

### Backing Up the Environment

The environment automatically creates backups for:

- **RDS Database**: Daily automated backups with 7-day retention
- **S3 Data**: Versioning enabled for object recovery

## Troubleshooting

### Common Issues

#### Terraform State Lock

If you encounter a state lock error:

```
Error: Error acquiring the state lock
```

Check if another process is running Terraform, or remove the lock:

```
terraform force-unlock LOCK_ID
```

#### Resource Creation Failure

If resource creation fails:

1. Check the error message in the Terraform output
2. Verify your AWS credentials and permissions
3. Check the AWS service quotas and limits
4. Review the AWS CloudTrail logs for API errors

### Getting Help

For additional assistance:

1. Review the documentation in the `docs` directory
2. Check the AWS service documentation
3. Contact the project maintainers