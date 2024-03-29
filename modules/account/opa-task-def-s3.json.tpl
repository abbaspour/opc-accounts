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
        "--set", "services.s3.url=https://${s3_bucket}.s3-${aws_region}.amazonaws.com",
        "--set", "services.s3.credentials.s3_signing.metadata_credentials.aws_region=${aws_region}",
        "--set", "services.sqs.url=${status_api_url}",
        "--set", "bundles.root.service=s3",
        "--set", "bundles.root.resource=/${account_no}/bundles/bundle.tar.gz",
        "--set", "bundles.root.persist=false",
        "--set", "bundles.root.polling.min_delay_seconds=600",
        "--set", "bundles.root.polling.max_delay_seconds=1200",
        "--set", "status.console=true",
        "--set", "status.service=sqs",
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
