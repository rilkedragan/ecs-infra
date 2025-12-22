terraform {
  source = "../../ecs"
  }
  remote_state {
    backend = "s3"
    config = {
      bucket = "state-bucket-stage"
      region = "us-east-1"
      key    = "stage/terraform.tfstate"
    }
}

inputs = {
  environment           = "stage"
  vpc_cidr	            = "10.2.0.0/16"
  public_subnet_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
  private_subnet_cidrs  = ["10.2.3.0/24", "10.2.4.0/24"]
  rds_instance_class    = "db.t3.micro"
  rds_db_name		        = "mydbstage"
  rds_username          = "minda"
  rds_password	        = "SuperSecurePassword"
  react_app_image       = "003060447871.dkr.ecr.us-east-1.amazonaws.com/reactapp:latest"
  backend_service_image = "003060447871.dkr.ecr.us-east-1.amazonaws.com/nestjsapp:latest"
}