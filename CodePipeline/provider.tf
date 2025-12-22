provider "aws" {
  region = "us-east-1"
}
terraform {
  backend "s3" {
    bucket         = "state-bucket-pipelines"   
    key            = "pipelines/terraform.tfstate" 
    region         = "us-east-1"                 
  }
}

