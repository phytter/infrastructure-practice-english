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

variable "backend_ecr_repository" {
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
  description = "Google Client ID for authentication"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google Client Secret for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "mongodb_url" {
  description = "URL for the MongoDB database"
  type        = string
  default     = ""
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = ""
}

variable "opensubtitles_api_key" {
  description = "API key for OpenSubtitles"
  type        = string
  sensitive   = true
  default     = ""
}

variable "secret_key" {
  description = "Secret key for the application"
  type        = string
  sensitive   = true
  default     = ""
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

variable "nextauth_secret" {
  description = "Next auth secret"
  type        = string
  default     = "asd45115431ds@*112s"
}

variable "nextauth_url" {
  description = "Next auth url"
  type        = string
  default     = ""
}

variable "frontend_ecs_cpu" {
  description = "Cpu capacity for frontend ecs"
  type        = string
  default     = "256"
}

variable "frontend_ecs_memory" {
  description = "Memory capacity for frontend ecs"
  type        = string
  default     = "512"
}

variable "frontend_min_instances" {
  description = "Minimum number of frontend instances"
  type        = number
  default     = 1
}

variable "frontend_max_instances" {
  description = "Maximum number of frontend instances"
  type        = number
  default     = 2
}

variable "frontend_image_tag" {
  description = "The tag for the frontend Docker image"
  type        = string
  default     = "latest"
}

variable "frontend_ecr_repository" {
  description = "Name of the ECR repository for the frontend"
  type        = string
  default     = "practice-english-front"
}
