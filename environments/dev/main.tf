provider "aws" {
  region = var.aws_region
}

# Remote backend for state management (uncomment and configure when ready)
# terraform {
#   backend "s3" {
#     bucket         = "your-terraform-state-bucket"
#     key            = "gold-image/dev/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-state-lock"
#     encrypt        = true
#   }
# }

module "gold_image" {
  source = "../../"

  environment       = "dev"
  aws_region        = var.aws_region
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  instance_type     = var.instance_type
  key_name          = var.key_name
  ami_id            = var.ami_id
  asg_min_size      = var.asg_min_size
  asg_max_size      = var.asg_max_size
  asg_desired_capacity = var.asg_desired_capacity
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = var.db_instance_class
  
  tags = merge(
    var.tags,
    {
      Environment = "dev"
    }
  )
}