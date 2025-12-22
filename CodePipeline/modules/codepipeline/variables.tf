variable "pipeline_name" {
  description = "Name of the CodePipeline"
  type        = string
}
variable "appname" {
  description = "Name of the app"
}

variable "codecommit_url" {
  description = "Repo URL"  
}


variable "repository_name" {
  description = "Name of the CodeCommit repository"
  type        = string
}

variable "branch_name" {
  description = "Branch name in the repository"
  type        = string
}


variable "ecs_stagecluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_stageservice_name" {
  description = "ECS service name"
  type        = string
}


variable "ecs_prodcluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_prodservice_name" {
  description = "ECS service name"
  type        = string
}
