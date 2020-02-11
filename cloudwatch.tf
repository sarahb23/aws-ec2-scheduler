resource "aws_cloudwatch_event_rule" "StopInstances" {
    name                = "lambda-stop-instances"
    description         = "Turns off running AWS instances at 6pm Eastern Time"
    schedule_expression = "cron(0 23 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_rule" "StartInstances" {
    name                = "lambda-start-instances"
    description         = "Turns on AWS instances at 6am Eastern Time"
    schedule_expression = "cron(0 11 ? * MON-FRI *)"
}

resource "aws_cloudwatch_event_target" "StopInstances" {
    target_id = "StopInstances"
    rule      = aws_cloudwatch_event_rule.StopInstances.name
    arn       = aws_lambda_function.stop_running_instances.arn
}

resource "aws_cloudwatch_event_target" "StartInstances" {
    target_id = "StartInstances"
    rule      = aws_cloudwatch_event_rule.StartInstances.name
    arn       = aws_lambda_function.start_stopped_instances.arn
}

resource "aws_lambda_permission" "StopInstances" {
    statement_id  = "AllowCloudwatchExecution"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.stop_running_instances.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.StopInstances.arn
}

resource "aws_lambda_permission" "StartInstances" {
    statement_id  = "AllowCloudwatchExecution"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.start_stopped_instances.function_name
    principal     = "events.amazonaws.com"
    source_arn    = aws_cloudwatch_event_rule.StartInstances.arn
}