# Main Terraform configuration

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
module "network" {
  source             = "./modules/network"
  name_prefix        = local.name_prefix
  common_tags        = local.common_tags
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  domain_name        = var.domain_name
  frontend_lb_dns    = module.frontend.load_balancer_dns
  backend_lb_dns     = module.backend.load_balancer_dns
}

module "frontend" {
  source               = "./modules/frontend"
  name_prefix          = local.name_prefix
  common_tags          = local.common_tags
  public_subnet_ids    = module.network.public_subnet_ids
  aws_region           = var.aws_region
  vpc_id               = module.network.vpc_id
  google_client_id     = var.google_client_id
  google_client_secret = var.google_client_secret
  nextauth_secret      = var.nextauth_secret
  nextauth_url         = var.nextauth_url
  sg_frontend_ecs_id   = module.network.sg_frontend_ecs_id
  sg_frontend_alb_id   = module.network.sg_frontend_alb_id
  min_instances        = var.frontend_min_instances
  max_instances        = var.frontend_max_instances
  ecs_cpu              = var.frontend_ecs_cpu
  ecs_memory           = var.frontend_ecs_memory
  image_tag            = var.frontend_image_tag
  ecr_repository       = var.frontend_ecr_repository
}

module "backend" {
  source            = "./modules/backend"
  name_prefix       = local.name_prefix
  common_tags       = local.common_tags
  vpc_id            = module.network.vpc_id
  sg_backend_lb_id  = module.network.sg_backend_lb_id
  sg_backend_id     = module.network.sg_backend_id
  subnet_ids        = module.network.private_subnet_ids
  public_subnet_ids = module.network.public_subnet_ids
  backend_image_tag = var.backend_image_tag
  ecr_repository    = var.backend_ecr_repository
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