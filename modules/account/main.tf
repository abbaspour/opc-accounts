terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.22"
    }
  }
}

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