output "bucket_name" {
  description = "Name of the backup S3 bucket"
  value       = aws_s3_bucket.backup.bucket
}

output "bucket_arn" {
  description = "ARN of the backup S3 bucket"
  value       = aws_s3_bucket.backup.arn
}

output "access_logs_bucket" {
  description = "Name of the S3 access log bucket"
  value       = aws_s3_bucket.access_logs.bucket
}
