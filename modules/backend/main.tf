# Security group para o load balancer
resource "aws_security_group" "backend_lb" {
  name        = "${var.name_prefix}-backend-lb-sg"
  description = "Security group for backend load balancer"
  vpc_id      = var.vpc_id
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backend-lb-sg"
  })
}

# Regras de ingress para o load balancer
resource "aws_vpc_security_group_ingress_rule" "lb_http_ingress" {
  security_group_id = aws_security_group.backend_lb.id
  description       = "Allow HTTP traffic from anywhere"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "lb_https_ingress" {
  security_group_id = aws_security_group.backend_lb.id
  description       = "Allow HTTPS traffic from anywhere"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Regra de egress para o load balancer
resource "aws_vpc_security_group_egress_rule" "lb_egress" {
  security_group_id = aws_security_group.backend_lb.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1" # Todos os protocolos
  cidr_ipv4         = "0.0.0.0/0"
}

# Security group para instâncias backend
resource "aws_security_group" "backend" {
  name        = "${var.name_prefix}-backend-sg"
  description = "Security group for backend FastAPI instances"
  vpc_id      = var.vpc_id
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backend-sg"
  })
}

# Regra de ingress para instâncias backend - corrigido para porta 8000
resource "aws_vpc_security_group_ingress_rule" "backend_app_ingress" {
  security_group_id            = aws_security_group.backend.id
  description                  = "Allow traffic from the load balancer to the application port"
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.backend_lb.id
}

# Regra de egress para instâncias backend
resource "aws_vpc_security_group_egress_rule" "backend_egress" {
  security_group_id = aws_security_group.backend.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1" # Todos os protocolos
  cidr_ipv4         = "0.0.0.0/0"
}

# IAM role for EC2 instances
resource "aws_iam_role" "backend" {
  name = "${var.name_prefix}-backend-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  
  tags = var.common_tags
}

# IAM policy for backend instances to access Secrets Manager and ECR
resource "aws_iam_policy" "backend_secrets" {
  name        = "${var.name_prefix}-backend-secrets-policy"
  description = "Allow backend instances to access secrets and ECR"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:ListSecrets",
          "sts:GetCallerIdentity",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


# Attach policy to role
resource "aws_iam_role_policy_attachment" "backend_secrets" {
  role       = aws_iam_role.backend.name
  policy_arn = aws_iam_policy.backend_secrets.arn
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ssm_policy_attachment" {
  role       = aws_iam_role.backend.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile
resource "aws_iam_instance_profile" "backend" {
  name = "${var.name_prefix}-backend-profile"
  role = aws_iam_role.backend.name
}

# Launch template for backend instances
resource "aws_launch_template" "backend" {
  name = "${var.name_prefix}-backend-template"
  
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  
  iam_instance_profile {
    name = aws_iam_instance_profile.backend.name
  }
  
  vpc_security_group_ids = [aws_security_group.backend.id]
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    ecr_repository  = var.ecr_repository
    image_tag       = var.backend_image_tag
    aws_region      = var.aws_region
    secrets_name    = "${var.name_prefix}-secrets-api"
  }))
  
  tag_specifications {
    resource_type = "instance"
    
    tags = merge(var.common_tags, {
      Name = "${var.name_prefix}-backend"
    })
  }
}

# Auto Scaling Group for backend instances
resource "aws_autoscaling_group" "backend" {
  name                = "${var.name_prefix}-backend-asg"
  min_size            = var.min_instances
  max_size            = var.max_instances
  desired_capacity    = var.min_instances
  vpc_zone_identifier = var.subnet_ids
  target_group_arns = [aws_lb_target_group.backend.arn]
  
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  
  
  health_check_type         = "ELB"
  health_check_grace_period = 300
  
  dynamic "tag" {
    for_each = merge(var.common_tags, {
      Name = "${var.name_prefix}-backend"
    })
    
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Application Load Balancer for backend
resource "aws_lb" "backend" {
  name               = "${var.name_prefix}-backend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.backend_lb.id]
  subnets            = var.public_subnet_ids
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backend-lb"
  })
}

# Target group for backend instances
resource "aws_lb_target_group" "backend" {
  name     = "${var.name_prefix}-backend-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    path                = "/api/v1/health/check"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }
  
  tags = var.common_tags
}

# Listener for the load balancer
resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "${var.name_prefix}-scale-out"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_in.scaling_adjustment
  cooldown               = var.scale_in.cooldown
}


resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_out_policy.arn]
  alarm_name          = "${var.name_prefix}-scale-out-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = var.scale_in.threshold
  statistic           = "Average"
  evaluation_periods  = "3"
  period              = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.backend.name
  }
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "${var.name_prefix}-scale-in"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.scale_out.scaling_adjustment
  cooldown               = var.scale_out.cooldown
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
  alarm_description   = "Monitors CPU utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_in_policy.arn]
  alarm_name          = "${var.name_prefix}-scale-in-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  threshold           = var.scale_out.threshold
  statistic           = "Average"
  evaluation_periods  = "3"
  period              = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.backend.name
  }
}

# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}