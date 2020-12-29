variable "region" {
  type = string
  description = "AWS region"
  default = "ap-southeast-2"
}

variable "policy_bucket" {
  description = "S3 policy storing bundles and data"
  type = string
}
