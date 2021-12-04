## AWS
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

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "listener_arn" {
  type = string
  description = "ALB listener arn"
}

## Auth0
variable "auth0_domain" {
  type = string
  description = "auth0 domain"
}

variable "auth0_canonical_domain" {
  type = string
  description = "auth0 canonical domain"
}

variable "auth0_tf_client_id" {
  type = string
  description = "Auth0 TF provider client_id"
}

variable "auth0_tf_client_secret" {
  type = string
  description = "Auth0 TF provider client_secret"
  sensitive = true
}
