data "template_file" "start" {
  template = file("${path.module}/lambda-code/start_stopped_instances.py")
  vars = {
    tag_key   = keys(var.instance_tag)[0]
    tag_value = values(var.instance_tag)[0]
  }
}

data "template_file" "stop" {
  template = file("${path.module}/lambda-code/stop_running_instances.py")
  vars = {
    tag_key   = keys(var.instance_tag)[0]
    tag_value = values(var.instance_tag)[0]
  }
}

data "archive_file" "start" {
  type        = "zip"
  output_path = "${path.module}/lambda-code/start_stopped_instances.zip"

  source {
    content  = data.template_file.start.rendered
    filename = "start_stopped_instances.py"
  }
}

data "archive_file" "stop" {
  type        = "zip"
  output_path = "${path.module}/lambda-code/stop_running_instances.zip"

  source {
    content  = data.template_file.stop.rendered
    filename = "stop_running_instances.py"
  }
}

resource "aws_lambda_function" "start_stopped_instances" {
  filename      = data.archive_file.start.output_path
  function_name = "Start-Stopped-Instances"
  role          = aws_iam_role.start_stop_lambda_role.arn
  handler       = "start_stopped_instances.start_instances"
  runtime       = "python3.7"
  timeout       = 30
}

resource "aws_lambda_function" "stop_running_instances" {
  filename      = data.archive_file.stop.output_path
  function_name = "Stop-Running-Instances"
  role          = aws_iam_role.start_stop_lambda_role.arn
  handler       = "stop_running_instances.stop_instances"
  runtime       = "python3.7"
  timeout       = 30
}

resource "aws_cloudwatch_log_group" "Start-Stopped-Instances" {
  name = "/aws/lambda/${aws_lambda_function.start_stopped_instances.function_name}"
}

resource "aws_cloudwatch_log_group" "Stop-Running-Instances" {
  name = "/aws/lambda/${aws_lambda_function.stop_running_instances.function_name}"
}