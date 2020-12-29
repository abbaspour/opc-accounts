module "opal_account-1234" {
  source = "./modules/account"
  account_no = 1234
  policy_bucket = var.policy_bucket
  region = var.region
  status_api_url = "https://9ms2c3v81c.execute-api.ap-southeast-2.amazonaws.com/dev"
  ecs_cluster_arn = "arn:aws:ecs:ap-southeast-2:377258293252:cluster/opa-ecs-cluster"
  ecs_cluster_subnets = var.ecs_cluster_subnets
  ecs_sg_id = var.ecs_sg_id
  discovery_ns_id = var.discovery_ns_id
}

