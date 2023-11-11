# code for lambda resource

resource "aws_lambda_function" "api_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "api_lambda"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
  runtime          = "python3.9"
  timeout          = 900
  memory_size      = 128
  publish          = true
  tags = {
    Name = "api_lambda"
    terraform = true
  }
}