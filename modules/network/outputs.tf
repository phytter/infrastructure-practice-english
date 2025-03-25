output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "sg_backend_id" {
  description = "ID of the backend security group"
  value       = aws_security_group.backend.id
}

output "sg_backend_lb_id" {
  description = "ID of the backend load balancer security group"
  value       = aws_security_group.backend_lb.id
}

output "sg_frontend_ecs_id" {
  description = "ID of the frontent ecs security group"
  value       = aws_security_group.frontend_ecs.id
}

output "sg_frontend_alb_id" {
  description = "ID of the frontent load balancer security group"
  value       = aws_security_group.frontend_alb.id
}
