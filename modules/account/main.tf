terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.22"
    }
  }
}

## Execution Role
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

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${var.account_no}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role.json
}

## Default Policy Object
resource "aws_s3_bucket_object" "default-bundle" {
  bucket = var.policy_bucket
  key    = "${var.account_no}/bundle.txt"
  source = "${path.module}/bundle.txt"
  etag = filemd5("${path.module}/bundle.txt")
}