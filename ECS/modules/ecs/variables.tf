variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "rds_instance_class" {
  description = "RDS instance class"
}

variable "rds_db_name" {
  description = "RDS database name"
}

variable "rds_username" {
  description = "RDS username"
}

variable "rds_password" {
  description = "RDS password"
}

variable "react_app_image" {
  description = "Docker image URI for React app"
}

variable "backend_service_image" {
  description = "Docker image URI for backend service"
}
