data "archive_file" "start" {
    type = "zip"
    source_file = "${path.module}/lambda-code/start_stopped_instances.py"
    output_path = "${path.module}/lambda-code/start_stopped_instances.zip"
}

data "archive_file" "stop" {
    type = "zip"
    source_file = "${path.module}/lambda-code/stop_running_instances.py"
    output_path = "${path.module}/lambda-code/stop_running_instances.zip"
}

resource "aws_lambda_function" "start_stopped_instances" {
    filename      = data.archive_file.start.output_path
    function_name = "Start-Stopped-Instances"
    role          = aws_iam_role.start_stop_lambda_role.arn
    handler       = "start_stopped_instances.start_instances"
    runtime       = "python3.7"
}

resource "aws_lambda_function" "stop_running_instances" {
    filename      = data.archive_file.stop.output_path
    function_name = "Stop-Running-Instances"
    role          = aws_iam_role.start_stop_lambda_role.arn
    handler       = "stop_running_instances.stop_instances"
    runtime       = "python3.7"
}

resource "aws_cloudwatch_log_group" "Start-Stopped-Instances" {
    name = "/aws/lambda/${aws_lambda_function.start_stopped_instances.function_name}"
}

resource "aws_cloudwatch_log_group" "Stop-Running-Instances" {
    name = "/aws/lambda/${aws_lambda_function.stop_running_instances.function_name}"
}