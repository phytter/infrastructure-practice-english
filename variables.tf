variable "name_prefix" {
  description = "Prefixo para os nomes dos recursos"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (staging or production)"
  type        = string
  default     = "staging"
}

variable "backend_image_tag" {
  description = "The tag for the backend Docker image"
  type        = string
  default     = "latest"
}

variable "ecr_repository" {
  description = "Name of the ECR repository for the backend"
  type        = string
  default     = "practice-english-api"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the backend"
  type        = string
  default     = "t3.micro"
}

variable "backend_min_instances" {
  description = "Minimum number of backend instances"
  type        = number
  default     = 2
}

variable "backend_max_instances" {
  description = "Maximum number of backend instances"
  type        = number
  default     = 3
}

variable "google_client_id" {
  type = string
}

variable "google_client_secret" {
  type = string
}

variable "mongodb_url" {
  type = string
}

variable "database_name" {
  type = string
}

variable "opensubtitles_api_key" {
  type      = string
  sensitive = true
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "common_tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
}

variable "scale_out" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}

variable "scale_in" {
  type = object({
    scaling_adjustment = number
    cooldown           = number
    threshold          = number
  })
}
