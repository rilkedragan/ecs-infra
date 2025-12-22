
module "nestjs_pipeline" {
  source                   = "./modules/codepipeline"
  pipeline_name            = "nestjs-pipeline"
  appname                  = "nestjs"
  repository_name          = "nestjsapp"
  branch_name              = var.branch_name
  ecs_stagecluster_name    = var.ecs_stagecluster_name
  ecs_stageservice_name    = "stage-backend"
  ecs_prodcluster_name     = var.ecs_prodcluster_name
  ecs_prodservice_name     = "prod-backend"
  codecommit_url           = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/nestjsapp"
  
}

module "react_pipeline" {
  source                   = "./modules/codepipeline"
  pipeline_name            = "react-pipeline"
  appname                  = "react"
  repository_name          = "reactapp"
  branch_name              = var.branch_name
  ecs_stagecluster_name    = var.ecs_stagecluster_name
  ecs_stageservice_name    = "stage-react"
  ecs_prodcluster_name     = var.ecs_prodcluster_name
  ecs_prodservice_name     = "prod-react"
  codecommit_url           = "https://git-codecommit.us-east-1.amazonaws.com/v1/repos/reactapp"
  
}