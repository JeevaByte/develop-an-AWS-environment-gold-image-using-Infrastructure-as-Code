# Security group for EC2 instances
resource "aws_security_group" "instance" {
  name        = "${var.environment}-instance-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  # Allow SSH access from anywhere (for demo purposes only - restrict in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # Allow HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-instance-sg"
    }
  )
}

# Security group for RDS database
resource "aws_security_group" "database" {
  name        = "${var.environment}-database-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # Allow MySQL/Aurora access from the instance security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.instance.id]
    description     = "MySQL/Aurora access from instances"
  }

  # Allow PostgreSQL access from the instance security group
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.instance.id]
    description     = "PostgreSQL access from instances"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-database-sg"
    }
  )
}

# IAM role for EC2 instances
resource "aws_iam_role" "instance_role" {
  name = "${var.environment}-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.environment}-instance-profile"
  role = aws_iam_role.instance_role.name
}

# Attach AWS managed policy for SSM
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Custom policy for S3 access
resource "aws_iam_policy" "s3_access" {
  name        = "${var.environment}-s3-access-policy"
  description = "Policy for S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.environment}-*/*",
          "arn:aws:s3:::${var.environment}-*"
        ]
      }
    ]
  })
}

# Attach S3 policy to instance role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}