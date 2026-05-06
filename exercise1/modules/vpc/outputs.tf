output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "load_balancer_sg_id" {
  description = "Security group ID for the load balancer"
  value       = aws_security_group.load_balancer_sg.id
}

output "app_server_sg_id" {
  description = "Security group ID for app servers"
  value       = aws_security_group.app_server_sg.id
}

output "s3_endpoint_id" {
  description = "ID of the S3 VPC gateway endpoint"
  value       = aws_vpc_endpoint.s3.id
}
