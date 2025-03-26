resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public subnets - for load balancers and NAT gateways
resource "aws_subnet" "public" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-subnet-${count.index + 1}"
  })
}

# Private subnets - for backend instances
resource "aws_subnet" "private" {
  count                   = length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + length(data.aws_availability_zones.available.names))
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-subnet-${count.index + 1}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = 1
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-eip"
  })
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = 1
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-nat-gw"
  })
  
  depends_on = [aws_internet_gateway.main]
}

# Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

# Route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-rt"
  })
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security group for the load balancer
resource "aws_security_group" "backend_lb" {
  name        = "${var.name_prefix}-backend-lb-sg"
  description = "Security group for backend load balancer"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backend-lb-sg"
  })
}

# Ingress rules for the load balancer
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

# Egress rule for the load balancer
resource "aws_vpc_security_group_egress_rule" "lb_egress" {
  security_group_id = aws_security_group.backend_lb.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1" # All protocols
  cidr_ipv4         = "0.0.0.0/0"
}

# Security group for backend instances
resource "aws_security_group" "backend" {
  name        = "${var.name_prefix}-backend-sg"
  description = "Security group for backend FastAPI instances"
  vpc_id      = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-backend-sg"
  })
}

# Ingress rule for backend instances - fixed to port 8000
resource "aws_vpc_security_group_ingress_rule" "backend_app_ingress" {
  security_group_id            = aws_security_group.backend.id
  description                  = "Allow traffic from the load balancer to the application port"
  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.backend_lb.id
}

# Egress rule for backend instances
resource "aws_vpc_security_group_egress_rule" "backend_egress" {
  security_group_id = aws_security_group.backend.id
  description       = "Allow all outbound traffic"
  ip_protocol       = "-1" # All protocols
  cidr_ipv4         = "0.0.0.0/0"
}

# Security group for the load balancer alb frontend
resource "aws_security_group" "frontend_alb" {
  name        = "${var.name_prefix}-frontend-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  tags = var.common_tags
}

# Ingress rules for the load balancer
resource "aws_security_group_rule" "frontend_alb_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_alb.id
}

resource "aws_vpc_security_group_ingress_rule" "frontend_alb__https_ingress" {
  security_group_id = aws_security_group.frontend_alb.id
  description       = "Allow HTTPS traffic from anywhere"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# Egress rules for the load balancer
resource "aws_security_group_rule" "frontend_alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_alb.id
}

# Security group for ecs frontend 
resource "aws_security_group" "frontend_ecs" {
  name        = "${var.name_prefix}-frontend-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  tags = var.common_tags
}

resource "aws_security_group_rule" "frontend_ecs_ingress" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  security_group_id = aws_security_group.frontend_ecs.id
  source_security_group_id = aws_security_group.frontend_alb.id
}

resource "aws_security_group_rule" "frontend_ecs_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.frontend_ecs.id
}

resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = var.common_tags
}

resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "app.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.frontend_lb_dns]
}

resource "aws_route53_record" "backend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.backend_lb_dns]
}
