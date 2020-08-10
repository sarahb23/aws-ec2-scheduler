resource "aws_iam_role" "start_stop_lambda_role" {
  name = "Lambda-Start-Stop-Instances"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

data "template_file" "iam_policy" {
  template = file("${path.module}/policies/lambda_start_stop_instances.json")

  vars = {
    tag_key   = keys(var.instance_tag)[0]
    tag_value = values(var.instance_tag)[0]
  }
}

resource "aws_iam_role_policy" "start_stop_lambda_policy" {
  name   = "Lambda-Start-Stop-Instances"
  role   = aws_iam_role.start_stop_lambda_role.name
  policy = data.template_file.iam_policy.rendered
}

resource "aws_iam_policy" "lambda_logging" {
  name = "Lambda-Start-Stop-Instances-Logging"
  path = "/"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logging_attach" {
  role       = aws_iam_role.start_stop_lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}