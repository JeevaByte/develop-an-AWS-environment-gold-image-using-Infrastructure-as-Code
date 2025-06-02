provider "aws" {
  region = var.aws_region
}

# Remote backend for state management (uncomment and configure when ready)
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "gold-image/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

# Core networking module
module "networking" {
  source = "./modules/networking"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  tags               = var.tags
}

# Security module
module "security" {
  source = "./modules/security"

  environment = var.environment
  vpc_id      = module.networking.vpc_id
  tags        = var.tags
}

# Compute module
module "compute" {
  source = "./modules/compute"

  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  private_subnet_ids     = module.networking.private_subnet_ids
  instance_type          = var.instance_type
  key_name               = var.key_name
  security_group_ids     = [module.security.instance_security_group_id]
  ami_id                 = var.ami_id
  user_data              = file("${path.module}/scripts/user_data.sh")
  min_size               = var.asg_min_size
  max_size               = var.asg_max_size
  desired_capacity       = var.asg_desired_capacity
  tags                   = var.tags
}

# Database module
module "database" {
  source = "./modules/database"

  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  subnet_ids         = module.networking.private_subnet_ids
  security_group_ids = [module.security.database_security_group_id]
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  db_instance_class  = var.db_instance_class
  tags               = var.tags
}

# Storage module
module "storage" {
  source = "./modules/storage"

  environment = var.environment
  tags        = var.tags
}

# Output the key resources created
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids
}

output "instance_security_group_id" {
  description = "Security group ID for EC2 instances"
  value       = module.security.instance_security_group_id
}

output "database_endpoint" {
  description = "Database connection endpoint"
  value       = module.database.endpoint
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created"
  value       = module.storage.bucket_name
}