variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "domain_name" {
  description = "The domain name to create records for"
  type        = string
}

variable "frontend_lb_dns" {
  description = "DNS name of the frontend load balancer"
  type        = string
}

variable "backend_lb_dns" {
  description = "DNS name of the backend load balancer"
  type        = string
}
