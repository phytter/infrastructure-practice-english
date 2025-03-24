# Main Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket       = "practice-english-terraform-state"
    key          = "terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

# Create a random suffix for unique resource naming
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  environment = terraform.workspace
  name_prefix = "english-${local.environment}"
  common_tags = {
    Project     = "PracticeEnglish"
    Environment = local.environment
    ManagedBy   = "Terraform"
  }
}

# Include other modules
module "vpc" {
  source             = "./modules/vpc"
  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

# module "frontend" {
#   source      = "./modules/frontend"
#   name_prefix = local.name_prefix
#   common_tags = local.common_tags
# }

module "backend" {
  source            = "./modules/backend"
  name_prefix       = local.name_prefix
  common_tags       = local.common_tags
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  public_subnet_ids = module.vpc.public_subnet_ids
  backend_image_tag = var.backend_image_tag
  ecr_repository    = var.ecr_repository
  aws_region        = var.aws_region
  instance_type     = var.ec2_instance_type
  min_instances     = var.backend_min_instances
  max_instances     = var.backend_max_instances
  scale_in          = var.scale_in
  scale_out         = var.scale_out
}

module "secrets" {
  source                = "./modules/secrets"
  name_prefix           = local.name_prefix
  common_tags           = local.common_tags
  google_client_id      = var.google_client_id
  google_client_secret  = var.google_client_secret
  mongodb_url           = var.mongodb_url
  database_name         = var.database_name
  opensubtitles_api_key = var.opensubtitles_api_key
  secret_key            = var.secret_key
}