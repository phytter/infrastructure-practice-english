output "frontend_url" {
  description = "Domain name of the frontend"
  value       = module.frontend.app_url
}

output "frontend_lb_dns" {
  description = "DNS name of the frontend load balancer"
  value       = module.frontend.load_balancer_dns
}

output "backend_lb_dns" {
  description = "DNS name of the backend load balancer"
  value       = module.backend.load_balancer_dns
}

output "backend_autoscaling_group_name" {
  description = "Name of the backend autoscaling group"
  value       = module.backend.autoscaling_group_name
}