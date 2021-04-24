module "account-100368421" {
  source = "./modules/account"
  account_no = 100368421
  policy_bucket = var.policy_bucket
  region = var.region
  status_api_url = var.status_api_url
  ecs_cluster_arn = var.ecs_cluster_arn
  ecs_cluster_subnets = var.ecs_cluster_subnets
  ecs_sg_id = var.ecs_sg_id
  discovery_ns_id = var.discovery_ns_id
  vpc_id = var.vpc_id
  listener_arn = var.listener_arn
  s3_vpce_id = var.s3_vpce_id
  client_id = "phi6ainootex"
  client_secret = "IeGahfim2di4"
}