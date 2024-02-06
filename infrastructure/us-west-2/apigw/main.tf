resource "aws_api_gateway_rest_api" "user_api" {
  name        = "user-api"
  description = "user api"
}

resource "aws_api_gateway_resource" "user_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  parent_id   = aws_api_gateway_rest_api.user_api.root_resource_id
  path_part   = "user"
}

resource "aws_api_gateway_method" "user_api_options_method" {
    rest_api_id   = aws_api_gateway_rest_api.user_api.id
    resource_id   = aws_api_gateway_resource.user_api_resource.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_method" "user_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.user_api.id
  resource_id   = aws_api_gateway_resource.user_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "user_api_integration" {
  rest_api_id             = aws_api_gateway_rest_api.user_api.id
  resource_id             = aws_api_gateway_resource.user_api_resource.id
  http_method             = aws_api_gateway_method.user_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.lambda_execute_arn
  depends_on = [ aws_api_gateway_method.user_api_method ]
}




resource "aws_api_gateway_method_response" "user_api_method_response" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_api_resource.id
  http_method = aws_api_gateway_method.user_api_method.http_method
  status_code = "200"
  response_models= {
        "application/json" = "Empty"
    }
  response_parameters= {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [aws_api_gateway_method.user_api_options_method]
}

resource "aws_api_gateway_method_response" "user_api_options_method_response" {
    rest_api_id = aws_api_gateway_rest_api.user_api.id
    resource_id = aws_api_gateway_resource.user_api_resource.id
    http_method   = aws_api_gateway_method.user_api_options_method.http_method
    status_code   = "200"
    response_models ={
        "application/json" = "Empty"
    }
    response_parameters ={
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin" = true
    }
    depends_on = [aws_api_gateway_method.user_api_options_method]
}

resource "aws_api_gateway_integration" "user_api_options_integration" {
    rest_api_id             = aws_api_gateway_rest_api.user_api.id
    resource_id             = aws_api_gateway_resource.user_api_resource.id
    http_method   = aws_api_gateway_method.user_api_options_method.http_method
    type          = "MOCK"
    depends_on = [aws_api_gateway_method.user_api_options_method]
}

resource "aws_api_gateway_integration_response" "user_api_options_integration_response" {
    rest_api_id             = aws_api_gateway_rest_api.user_api.id
    resource_id             = aws_api_gateway_resource.user_api_resource.id
    http_method   = aws_api_gateway_method.user_api_options_method.http_method
    status_code   = aws_api_gateway_method_response.user_api_options_method_response.status_code
    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin" = "'*'"
    }
    depends_on = [aws_api_gateway_method_response.user_api_options_method_response]
}

resource "aws_api_gateway_integration_response" "user_api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  resource_id = aws_api_gateway_resource.user_api_resource.id
  http_method = aws_api_gateway_method.user_api_method.http_method
  status_code = aws_api_gateway_method_response.user_api_method_response.status_code
  response_templates = {
    "application/json" = ""
  }
  # enable cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

}

resource "aws_api_gateway_deployment" "user_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.user_api_integration,
    aws_api_gateway_integration_response.user_api_integration_response
  ]
  rest_api_id = aws_api_gateway_rest_api.user_api.id
  stage_name  = "prod"
}

resource "aws_lambda_permission" "user_api_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.user_api.execution_arn}/*/*"
}


resource "aws_api_gateway_domain_name" "app_domain" {
  regional_certificate_arn = var.cert_arn
  domain_name     = "poc.ibmb.equitasbank.com"
  certificate_crn = "arn:aws:acm:ap-south-1:804337772667:certificate/0abc90b3-cc35-4f1b-96e4-48a16598fea5"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "app_mapping" {
  api_id      = aws_api_gateway_rest_api.user_api.id
  stage_name  = "prod"
  domain_name = aws_api_gateway_domain_name.app_domain.domain_name
}
