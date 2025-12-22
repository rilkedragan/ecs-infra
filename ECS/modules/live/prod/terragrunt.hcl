terraform {
  source = "../../ecs"
  }
  remote_state {
    backend = "s3"
    config = {
      bucket = "state-bucket-prod"
      region = "us-east-1"
      key    = "prod/terraform.tfstate"
    }
}

inputs = {
  environment           = "prod"
  vpc_cidr	            = "10.1.0.0/16"
  public_subnet_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs  = ["10.1.3.0/24", "10.1.4.0/24"]
  rds_instance_class    = "db.t3.micro"
  rds_db_name		        = "mydbprod"
  rds_username          = "minda"
  rds_password	        = "SuperSecurePassword"
  react_app_image       = "003060447871.dkr.ecr.us-east-1.amazonaws.com/reactapp:latest"
  backend_service_image = "003060447871.dkr.ecr.us-east-1.amazonaws.com/nestjsapp:latest"
}