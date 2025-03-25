output "app_url" {
  value = aws_cloudfront_distribution.frontend.domain_name
}

output "load_balancer_dns" {
  value = aws_lb.frontend.dns_name
}
