environment = "production"
vpc_cidr = "10.0.0.0/16"
ec2_instance_type = "t2.micro"
backend_min_instances = 1
backend_max_instances = 2
backend_ecr_repository="practice-english-api"
backend_image_tag="latest"
common_tags = {
  Project     = "PracticeEnglish"
  Environment = "production"
  ManagedBy   = "Terraform"
}
scale_in = {
  cooldown = 60
  threshold = 20
  scaling_adjustment = -1
}
scale_out = {
  cooldown = 60
  threshold = 70
  scaling_adjustment = 1
}
name_prefix = "english"
frontend_ecs_cpu = "256"
frontend_ecs_memory = "512"
frontend_min_instances = 1
frontend_max_instances = 2
frontend_ecr_repository="practice-english-front"
frontend_image_tag="latest"