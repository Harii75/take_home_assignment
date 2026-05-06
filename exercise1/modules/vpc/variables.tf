variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "Map of public subnets keyed by AZ suffix (e.g. 'a', 'b')"
  type = map(object({
    cidr_block = string
  }))
  default = {
    "a" = { cidr_block = "10.0.1.0/24" }
    "b" = { cidr_block = "10.0.2.0/24" }
  }
}

variable "private_subnets" {
  description = "Map of private subnets keyed by AZ suffix (e.g. 'a', 'b')"
  type = map(object({
    cidr_block = string
  }))
  default = {
    "a" = { cidr_block = "10.0.3.0/24" }
    "b" = { cidr_block = "10.0.4.0/24" }
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
