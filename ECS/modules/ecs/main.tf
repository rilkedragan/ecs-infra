provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {}
}

locals {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
}



# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.environment}-vpc"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(local.availability_zones, count.index)
  tags = {
    Name = "${var.environment}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(local.availability_zones, count.index)
  tags = {
    Name = "${var.environment}-private-${count.index + 1}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-public-rt"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.environment}-private-rt"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "${var.environment}-nat"
  }
}

resource "aws_eip" "nat" {
  vpc = true
  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.main.id
  name   = "${var.environment}-alb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"    
    security_groups   = [aws_security_group.ecs_service.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_service" {
  vpc_id = aws_vpc.main.id
  name   = "${var.environment}-ecs-service-sg"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"    
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id
  name   = "${var.environment}-rds-sg"

  ingress {
    from_port         = 5432
    to_port           = 5432
    protocol          = "tcp"
    security_groups   = [aws_security_group.ecs_service.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.environment}-ecs-cluster"
  tags = {
    Name = "${var.environment}-ecs-cluster"
  }
}

# React App ECS Service and Task Definition
resource "aws_ecs_task_definition" "react" {
  family                   = "${var.environment}-react"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "react-app"
    image     = var.react_app_image
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
    ignore_changes        = all  # Ignore all changes after creation
  }
}


resource "aws_ecs_service" "react" {
  name            = "${var.environment}-react"
  cluster        = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.react.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.public[*].id
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.react.arn
    container_name   = "react-app"
    container_port   = 80
  }
  # lifecycle {
  #   create_before_destroy = false
  #   prevent_destroy       = false
  #   ignore_changes        = all  # Ignore all changes after creation
  # }
}


resource "aws_lb_target_group" "react" {
  name        = "prod-react-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react.arn
  }
}

# ALB
resource "aws_lb" "main" {
  name               = "${var.environment}-ecs-alb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id
  enable_deletion_protection = false
}

# Backend ECS Service and Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.environment}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([{
    name      = "backend-app"
    image     = var.backend_service_image
    essential = true
	portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
  }])
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
    ignore_changes        = all  # Ignore all changes after creation
  }
}

resource "aws_ecs_service" "backend" {
  name            = "${var.environment}-backend" 
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = aws_subnet.private[*].id
    security_groups = [aws_security_group.ecs_service.id]
  }
  lifecycle {
    create_before_destroy = false
    prevent_destroy       = false
    ignore_changes        = all  # Ignore all changes after creation
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.environment}-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_execution_role_policy" {
  name   = "${var.environment}-ecs-execution-policy"
  role   = aws_iam_role.ecs_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetRepositoryPolicy", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "logs:CreateLogStream"
        Effect   = "Allow"
        Resource = "arn:aws:ecr:us-east-1:003060447871:log-group:/ecs/*"
      },
      {
        Action   = "logs:PutLogEvents"
        Effect   = "Allow"
        Resource = "arn:aws:logs:us-east-1:003060447871:log-group:/ecs/*:log-stream:*"
      }
    ]
  })
}

# RDS Instance
resource "aws_db_instance" "postgresql" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "14.15"
  identifier             = var.rds_db_name
  instance_class         = var.rds_instance_class
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
}

resource "aws_db_subnet_group" "main" {
  name       = "${var.environment}-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
  tags = {
    Name = "${var.environment}-rds-subnet-group"
  }
}