output "load_balancer_dns" {
  description = "DNS name of the backend load balancer"
  value       = aws_lb.backend.dns_name
}

output "autoscaling_group_name" {
  description = "Name of the backend autoscaling group"
  value       = aws_autoscaling_group.backend.name
}