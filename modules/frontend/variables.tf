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

variable "sg_frontend_ecs_id" {
  description = "ID of the frontent ecs security group"
  type        = string
}

variable "sg_frontend_alb_id" {
  description = "ID of the frontent load balancer security group"
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs of the public subnets"
  type        = list(string)
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "google_client_id" {
  description = "Google client ID"
  type        = string
}

variable "google_client_secret" {
  description = "Google client secret"
  type        = string
}

variable "nextauth_secret" {
  description = "Next auth secret"
  type        = string
}

variable "nextauth_url" {
  description = "Next auth url"
  type        = string
}

variable "ecs_cpu" {
  description = "Cpu capacity for frontend ecs"
  type        = string
}

variable "ecs_memory" {
  description = "Memory capacity for frontend ecs"
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

variable "ecr_repository" {
  description = "Name of the ECR repository for the frontend"
  type        = string
}

variable "image_tag" {
  description = "The tag for the frontend Docker image"
  type        = string
}
