# output "frontend_s3_bucket" {
#   description = "S3 bucket name for frontend static assets"
#   value       = module.frontend.s3_bucket_name
# }

# output "cloudfront_distribution_id" {
#   description = "CloudFront distribution ID for frontend"
#   value       = module.frontend.cloudfront_distribution_id
# }

output "backend_lb_dns" {
  description = "DNS name of the backend load balancer"
  value       = module.backend.load_balancer_dns
}

output "backend_autoscaling_group_name" {
  description = "Name of the backend autoscaling group"
  value       = module.backend.autoscaling_group_name
}