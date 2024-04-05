# API Gateway REST API
resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = var.api_gateway_details.name
  description = var.api_gateway_details.description
}

# API Gateway Resource for 
resource "aws_api_gateway_resource" "MyDemoResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id  
  path_part   = var.path_part
}

# API Gateway Method for GET Request Mwthod
resource "aws_api_gateway_method" "MyDemoMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoResource.id
  http_method   = var.method_details.http_method
  authorization = var.method_details.authorization
  authorizer_id      = var.method_details.authorization == "CUSTOM" ? aws_api_gateway_authorizer.demo[0].id : null
  request_parameters = {
    "method.request.${var.authorizer_config != null ? var.authorizer_config.identity_source : "header.Default"}" = var.method_details.authorization == "CUSTOM" && var.authorizer_config != null ? true : false
    "method.request.path.${var.path_part_withoutbraces}" = true
  }
}

resource "aws_api_gateway_authorizer" "demo" {
  count = var.method_details.authorization == "CUSTOM" ? 1 : 0

  name                   = var.authorizer_config.name
  rest_api_id            = aws_api_gateway_rest_api.MyDemoAPI.id
  type                   = var.authorizer_config.type
  authorizer_uri         = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.authorizer_config.lambda_function_arn}/invocations"
  authorizer_credentials = var.authorizer_config.authorizer_credentials
  identity_source        = "method.request.${var.authorizer_config.identity_source}"
}



resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id          = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id          = aws_api_gateway_resource.MyDemoResource.id
  http_method          = aws_api_gateway_method.MyDemoMethod.http_method
  type                 = var.integration_config.type
  integration_http_method = var.integration_config.integration_http_method
  uri                  = var.integration_config.uri
  credentials          = var.integration_config.credentials
  timeout_milliseconds = var.integration_config.timeout_milliseconds

  request_parameters = {
    "integration.request.path.${var.path_part_withoutbraces}" = "method.request.path.${var.path_part_withoutbraces}"
  }

}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoResource.id
  http_method = aws_api_gateway_method.MyDemoMethod.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.MyDemoResource.id,
      aws_api_gateway_method.MyDemoMethod.id,
      aws_api_gateway_integration.MyDemoIntegration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name    = var.stage_config.stage_name
}


