resource "aws_cloudwatch_event_rule" "StopInstances" {
  name                = "${var.function_name}-stop-instances"
  description         = "Turns off running AWS instances"
  schedule_expression = var.stop_cron
}

resource "aws_cloudwatch_event_rule" "StartInstances" {
  name                = "${var.function_name}-start-instances"
  description         = "Turns on AWS instances"
  schedule_expression = var.start_cron
}

resource "aws_cloudwatch_event_target" "StopInstances" {
  target_id = "StopInstances"
  rule      = aws_cloudwatch_event_rule.StopInstances.name
  arn       = aws_lambda_function.scheduler_lambda.arn
  input     = jsonencode({ action = "stop" })
}

resource "aws_cloudwatch_event_target" "StartInstances" {
  target_id = "StartInstances"
  rule      = aws_cloudwatch_event_rule.StartInstances.name
  arn       = aws_lambda_function.scheduler_lambda.arn
  input     = jsonencode({ action = "start" })
}

resource "aws_lambda_permission" "StopInstances" {
  statement_id  = "StopInstances"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.StopInstances.arn
}

resource "aws_lambda_permission" "StartInstances" {
  statement_id  = "StartInstances"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.scheduler_lambda.arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.StartInstances.arn
}
