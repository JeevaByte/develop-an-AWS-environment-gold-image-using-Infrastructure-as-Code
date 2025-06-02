variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
}

variable "bucket_name" {
  description = "Base name for the S3 bucket"
  type        = string
  default     = "app-data"
}

variable "bucket_size_threshold" {
  description = "Threshold for bucket size alarm in bytes"
  type        = number
  default     = 5368709120  # 5GB in bytes
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}