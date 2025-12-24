1.	Nestjs application- found Hello world example from Internet  
Jest config has been adjusted to publish test results to AWS Codebuild reports  
Added Dockerfile  
Added buildspec.yml for defining AWS Codebuild project steps  
2.	React app –   
Added Dockerfile   
Added nginx.conf that is used in building of Docker image  
Added buildspec.yml for defining AWS Codebuild project steps  
3.	Infrastructure  
Has 2 directories: ECS and CodePipeline  
ECS contains Terraform and Terragrunt code for building 2 environments: staging and production. Each environment consists of VPC with private and public subnets, routing tables, NAT gateway and Internet gateway, security groups for accessing RDS instance, for ALB and for ECS task, ALB with appropriate target group, ECS cluster with 2 task definitions and 2 services for nestjsapp and react app, RDS instance for Postgresql in private subnets and accessible by nestjs service running in private subnet and access controlled by security group  
CodePipeline contains Terraform code for building 2 AWS Code Pipelines that are using 2 Codebuild projects , one for each app. Pipelines are configured to have stages: checkout code from CodeCommit repo, Build and push Docker image to the ECR, Deploy to staging ECS clusters, Approval step, Deploy to production ECS cluster  

