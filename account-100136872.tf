module "account-100136872" {
  source = "./modules/account"
  account_no = 100136872
  policy_bucket = var.policy_bucket
  region = var.region
  status_api_url = var.status_api_url
  ecs_cluster_arn = var.ecs_cluster_arn
  ecs_cluster_subnets = var.ecs_cluster_subnets
  ecs_sg_id = var.ecs_sg_id
  discovery_ns_id = var.discovery_ns_id
}