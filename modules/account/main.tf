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
resource "aws_s3_bucket_object" "default-bundle" {
  bucket = var.policy_bucket
  key    = "${var.account_no}/bundle.txt"
  source = "${path.module}/bundle.txt"
  etag = filemd5("${path.module}/bundle.txt")
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
    sid = ""
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.policy_bucket}/${var.account_no}/*"
    ]
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
    tag                = "latest"
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
  }
}

## -- ECS Service --
/*
resource "aws_ecs_service" "staging" {
  name            = "opa"
  cluster         = var.ecs_cluster_arn
  task_definition = aws_ecs_task_definition.service.arn
  desired_count   = 0
  launch_type     = "FARGATE"
  //platform_version = "1.4.0"
  platform_version = "LATEST"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = data.aws_subnet_ids.default.ids
    assign_public_ip = false
    //assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.staging.arn
    container_name   = "opa-task"
    container_port   = 80
  }

  service_registries {
    registry_arn = aws_service_discovery_service.sd-account-100394707.arn
  }

  depends_on = [aws_lb_listener.https_forward, aws_iam_role_policy_attachment.ecs_task_execution_role]

  tags = {
    Environment = var.app_environment
    Application = var.app_name
  }

  lifecycle {
    ignore_changes = [
      desired_count
    ]
  }
}
*/