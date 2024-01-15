resource "aws_iam_role" "scheduler_lambda_role" {
  name = "${var.function_name}-role"

  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "scheduler_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:StartInstance",
      "ec2:StopInstance"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/${var.tag_key}"
      values   = ["${var.tag_value}"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:UpdateAutoScalingGroup",
      "autoscaling:DescribeAutoScalingGroups"
    ]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/${var.tag_key}"
      values   = ["${var.tag_value}"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["${aws_cloudwatch_log_group.scheduler_lambda.arn}*"]
  }
}

resource "aws_iam_role_policy" "scheduler_lambda_policy" {
  name   = "${var.function_name}-policy"
  role   = aws_iam_role.scheduler_lambda_role.name
  policy = data.aws_iam_policy_document.scheduler_policy.json
}
