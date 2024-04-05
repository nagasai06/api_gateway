module "api_gateway" {
  source = "D:\\INfra Engineering2\\API Gateway modules" # Update this to the path where your module is stored

  api_gateway_details = {
    name        = "ModuleTestWithoutAuth"
    description = "Example API Gateway REST API"
  }

  path_part = "{objectKey}"

  method_details = {
    http_method   = "GET"
    authorization = "NONE"  # or "CUSTOM" if using a custom authorizer
  }

  # Include `authorizer_config` if you're using a custom authorizer

  integration_config = {
    type                     = "AWS"
    http_method = "GET"
    integration_http_method  = "GET"
    uri                      = "arn:aws:apigateway:us-east-1:s3:path/accesstestone/{objectKey}"
    credentials              = "arn:aws:iam::082185593297:role/apgw_role"
    timeout_milliseconds     = 29000
  }

  stage_config = {
    stage_name = "test"
  }
}



output "api_gateway_stage_invoke_url" {
  value = module.api_gateway.stage_invoke_url
}
