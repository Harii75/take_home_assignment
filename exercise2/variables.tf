variable "aws_region" {
  description = "AWS region where the backup bucket will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short project/application name used in resource naming"
  type        = string
  default     = "myapp"
}

variable "backup_uploader_role_arn" {
  description = "ARN of the cross-account IAM role allowed to upload backups"
  type        = string
  default     = "arn:aws:iam::123456789012:role/backup_uploader"
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "Terraform"
    Purpose   = "Backups"
    Retention = "180days"
  }
}
