
variable "branch_name" {
  description = "Branch name in the repository"
  type        = string
  default = "master"
}


variable "ecs_stagecluster_name" {
  description = "ECS cluster name"
  type        = string
  default = "stage-ecs-cluster"
}


variable "ecs_prodcluster_name" {
  description = "ECS cluster name"
  type        = string
  default = "prod-ecs-cluster"
}


