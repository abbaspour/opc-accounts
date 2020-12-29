variable "account_no" {
  description = "account number"
  type = number
}

variable "policy_bucket" {
  description = "S3 policy storing bundles and data"
  type = string
}

variable "status_api_url" {
  type = string
  default = "status api url"
}

variable "region" {
  type = string
  description = "AWS region"
}

variable "ecs_cluster_arn" {
  type = string
  description = "ecs cluster ARN"
}