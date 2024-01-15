data "archive_file" "lambda_code" {
  type        = "zip"
  output_path = "${path.module}/lambda-code/scheduler_lambda.zip"

  source_dir = "${path.module}/lambda-code/"
}

resource "aws_lambda_function" "scheduler_lambda" {
  filename      = data.archive_file.lambda_code.output_path
  function_name = var.function_name
  role          = aws_iam_role.scheduler_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.10"

  source_code_hash = data.archive_file.lambda_code.output_base64sha256

  environment {
    variables = {
      TAG_KEY   = var.tag_key
      TAG_VALUE = var.tag_value
    }
  }
}

resource "aws_cloudwatch_log_group" "scheduler_lambda" {
  name = "/aws/lambda/${aws_lambda_function.scheduler_lambda.function_name}"
}
