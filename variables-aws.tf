variable "region" {
  type = string
  description = "AWS region"
  default = "ap-southeast-2"
}

variable "policy_bucket" {
  description = "S3 policy storing bundles and data"
  type = string
}

variable "ecs_cluster_subnets" {
  type = list(string)
  description = "ECS subnets"
}

variable "ecs_sg_id" {
  type = string
  description = "ECS security group id"
}