terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.22"
    }
  }
}

## -- Execution Role --
data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_exec_role" {
  name               = "ecs-execution-role-${var.account_no}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## -- Default Policy Object --
## todo: publish to update-policy SQS rather than creating file manually
## prevent overwrite
resource "aws_s3_bucket_object" "default-bundle" {
  bucket = var.policy_bucket
  key    = "${var.account_no}/bundles/bundle.tar.gz"
  source = "${path.module}/bundle.tar.gz"
  #etag = filemd5("${path.module}/bundle.tar.gz")
}

## Task Role
data "aws_iam_policy_document" "ecs_task_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.account_no}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

data "aws_iam_policy_document" "s3_data_bucket_policy" {
  statement {
    sid = "1"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.policy_bucket}/${var.account_no}/*"
    ]
    condition {
      test = "StringEquals"
      values = [var.vpc_id]
      variable = "aws:sourceVpce"
    }
  }
}

resource "aws_iam_policy" "s3_policy" {
  name   = "s3-policy-${var.account_no}"
  policy = data.aws_iam_policy_document.s3_data_bucket_policy.json
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}


## -- ECS Task --
data "template_file" "opa_app_task" {
  template = file("${path.module}/opa-task-def.json.tpl")
  vars = {
    //aws_ecr_repository = aws_ecr_repository.repo.repository_url
    account_no         = var.account_no
    //tag                = "latest"
    tag                = "0.24.0"
    aws_region         = var.region
    s3_bucket          = var.policy_bucket
    status_api_url     = var.status_api_url
  }
}

resource "aws_ecs_task_definition" "service" {
  family                   = "opa-task-${var.account_no}"
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.ecs_exec_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  cpu                      = 256
  memory                   = 512
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.opa_app_task.rendered

  tags = {
    Environment = "staging"
    Account = var.account_no
  }
}

## -- SG --
/*
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-sg"
  description = "allow inbound access from the ALB only"
  vpc_id = aws_vpc.aws-vpc.id

  ingress {
    protocol        = "tcp"
    from_port       = 80
    to_port         = 80
    cidr_blocks     = ["0.0.0.0/0"]
    //security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
*/

## -- ECS Service --

resource "aws_ecs_service" "staging" {
  name            = "opa-${var.account_no}"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  //platform_version = "1.4.0"
  platform_version = "LATEST"

  network_configuration {
    security_groups  = [var.ecs_sg_id]
    subnets          = var.ecs_cluster_subnets
    assign_public_ip = false
    //assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.target-group.arn
    container_name   = "opa-task-${var.account_no}"
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.service_discovery.arn
  }

  depends_on = [/*aws_lb_listener.https_forward,*/ aws_iam_role_policy_attachment.ecs_task_execution_role, aws_cloudwatch_log_group.log-group]

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}

## Discovery
resource "aws_service_discovery_service" "service_discovery" {
  name = "lb${var.account_no}"

  dns_config {
    namespace_id = var.discovery_ns_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  /*
  health_check_custom_config {
    failure_threshold = 1
  }
  */
}

## Log
resource "aws_cloudwatch_log_group" "log-group" {
  name = "opa-${var.account_no}"
  retention_in_days = 3

  tags = {
    Account = var.account_no
  }
}

## Load Balancer
resource "aws_lb_target_group" "target-group" {
  name     = "target-group-${var.account_no}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "ip"
}

resource "random_integer" "priority" {
  min = 1
  max = 50000
  keepers = {
    # Generate a new integer each time we switch to a new listener ARN
    listener_arn = var.listener_arn
  }
}

resource "aws_lb_listener_rule" "alb-listener" {

  listener_arn = var.listener_arn
  priority     = random_integer.priority.result

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target-group.arn
  }

  condition {
    http_header {
      http_header_name = "account_no"
      values = [var.account_no]
    }
  }
}
