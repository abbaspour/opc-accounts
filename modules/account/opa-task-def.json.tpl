[
  {
    "name": "opa-task-${account_no}",
    "image": "openpolicyagent/opa:${tag}",
    "essential": true,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "opa-task-${account_no}",
        "awslogs-group": "opa-${account_no}"
      }
    },
    "entryPoint" : [
        "/opa", "run", "-s", "-a", ":80", "-l", "debug",
        "--set", "services.gw.url=https://api.opalpolicy.com/repository",
        "--set", "services.gw.credentials.oauth2.grant_type=client_credentials",
        "--set", "services.gw.credentials.oauth2.token_url=https://api.opalpolicy.com/runtime/token",
        "--set", "services.gw.credentials.oauth2.client_id=${client_id}",
        "--set", "services.gw.credentials.oauth2.client_secret=${client_secret}",
        "--set", "services.gw.allow_insecure_tls=true",
        "--set", "bundles.root.service=gw",
        "--set", "bundles.root.resource=/v1/bundles/bundle.tar.gz",
        "--set", "bundles.root.persist=false",
        "--set", "bundles.root.polling.min_delay_seconds=600",
        "--set", "bundles.root.polling.max_delay_seconds=1200",
        "--set", "status.console=true",
        "--set", "status.service=gw",
        "--set", "decision_logs.console=true"
    ],
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "cpu": 1,
    "environment": [
      {
        "name": "NODE_ENV",
        "value": "staging"
      },
      {
        "name": "PORT",
        "value": "80"
      }
    ],
    "ulimits": [
      {
        "name": "nofile",
        "softLimit": 65536,
        "hardLimit": 65536
      }
    ],
    "mountPoints": [],
    "memory": 512,
    "volumesFrom": []
  }
]
