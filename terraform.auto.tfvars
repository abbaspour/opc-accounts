policy_bucket = "opal-policy-dev"
# ecs_cluster_subnets = ["subnet-0b89f5115650df28e"] ## private
ecs_cluster_subnets = ["subnet-09576fe0700954a37", "subnet-0649b70bed84d5b00"] ## nat
ecs_sg_id = "sg-06831a17f8cad63c2"
discovery_ns_id = "ns-edm73qavjpzpaw4k"
status_api_url = "https://9ms2c3v81c.execute-api.ap-southeast-2.amazonaws.com/dev"
ecs_cluster_arn = "arn:aws:ecs:ap-southeast-2:377258293252:cluster/opa-ecs-cluster"
vpc_id = "vpc-06c2afe6e06938cf1"
listener_arn = "arn:aws:elasticloadbalancing:ap-southeast-2:377258293252:listener/app/OPA-smart-LB/6a910f8fd5e57486/1a123b8192ad8fdb"
s3_vpce_id = "vpce-01bd3ae5461c9c2b8"

auth0_domain = "opal-dev.au.auth0.com"
auth0_tf_client_id = "don3m86oE6WgzztzCYz1yGYTUBAWHeZJ"
auth0_tf_client_secret = "vDeZ8gxtUGLc32OJslR-qEzut40J6PtxIKFYCmDhzhz_RhUbavmlCiL40codznXX"