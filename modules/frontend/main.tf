# ECS Cluster for the frontend application
resource "aws_ecs_cluster" "cluster" {
  name = "${var.name_prefix}-frontend-cluster"

  tags = var.common_tags
}

# ECS Task Definition for the frontend application
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.name_prefix}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name  = "${var.name_prefix}-frontend-container"
    image = "${aws_ecr_repository.nextjs_app.repository_url}:latest"
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [
      {
        name  = "GOOGLE_CLIENT_ID"
        value = var.google_client_id
      },
      {
        name  = "GOOGLE_CLIENT_SECRET"
        value = var.google_client_secret
      },
      {
        name  = "NEXTAUTH_SECRET"
        value = var.nextauth_secret
      },
      {
        name  = "NEXTAUTH_URL"
        value = var.nextauth_url
      }
    ]
  }])

  tags = var.common_tags
}

# Application Load Balancer for the frontend application
resource "aws_lb" "frontend" {
  name               = "${var.name_prefix}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.sg_frontend_alb_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = var.common_tags
}

# Target Group for the frontend application
resource "aws_lb_target_group" "frontend" {
  name        = "${var.name_prefix}-frontend-tg"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.common_tags
}

# Listener for the Load Balancer
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  tags = var.common_tags
}

# ECS Service for the frontend application
resource "aws_ecs_service" "service" {
  name            = "${var.name_prefix}-frontend-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 1

  network_configuration {
    subnets          = var.public_subnet_ids
    security_groups  = [var.sg_frontend_ecs_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "nextjs-container"
    container_port   = 3000
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight            = 1
  }

  tags = var.common_tags
}

# ECR Repository for the frontend application
resource "aws_ecr_repository" "nextjs_app" {
  name = "${var.name_prefix}-frontend"

  tags = var.common_tags
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.common_tags
}

# IAM Role Policy Attachment for ECS Task Execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudFront Distribution for the frontend application
resource "aws_cloudfront_distribution" "frontend" {
  enabled     = true
  price_class = "PriceClass_100"

  origin {
    domain_name = "${aws_lb.frontend.dns_name}"
    origin_id   = "ecs-origin"

    custom_origin_config {
      http_port              = 3000
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "ecs-origin"

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.common_tags
}
