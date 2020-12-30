variable "region" {
  type = string
  description = "AWS region"
  default = "ap-southeast-2"
}

variable "policy_bucket" {
  description = "S3 policy storing bundles and data"
  type = string
}

variable "status_api_url" {
  type = string
  description = "status api url"
}

variable "ecs_cluster_arn" {
  type = string
  description = "ecs cluster arn"
}

variable "ecs_cluster_subnets" {
  type = list(string)
  description = "ECS subnets"
}

variable "ecs_sg_id" {
  type = string
  description = "ECS security group id"
}

variable "discovery_ns_id" {
  type = string
  description = "Service discovery DNS namespace"
}