variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "sg_backend_id" {
  description = "ID of the Security Group for the backend"
  type        = string
}

variable "sg_backend_lb_id" {
  description = "ID of the Security Group for the backend load balancer"
  type        = string
}

variable "subnet_ids" {
  description = "IDs of the subnets"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "backend_image_tag" {
  description = "Tag of the backend image"
  type        = string
}

variable "ecr_repository" {
  description = "ECR repository"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "min_instances" {
  description = "Minimum number of instances"
  type        = number
}

variable "max_instances" {
  description = "Maximum number of instances"
  type        = number
}

variable "scale_out" {
  description = "Scale out configurations"
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}

variable "scale_in" {
  description = "Scale in configurations"
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}
