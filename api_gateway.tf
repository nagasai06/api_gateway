# API Gateway REST API
resource "aws_api_gateway_rest_api" "MyDemoAPI" {
  name        = "MyDemoAPI"
  description = "API to access S3 bucket"
  
  # Ensure API Gateway can handle binary data
  binary_media_types = ["image/png"]
}

# API Gateway Resource for Image
resource "aws_api_gateway_resource" "MyDemoImageResource" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  parent_id   = aws_api_gateway_rest_api.MyDemoAPI.root_resource_id  # Assuming this is the root resource
  path_part   = "{filename}"
}

# API Gateway Method for GET Request
resource "aws_api_gateway_method" "MyDemoImageMethod" {
  rest_api_id   = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id   = aws_api_gateway_resource.MyDemoImageResource.id
  http_method   = "GET"
  authorization = "NONE"

  # Specify request parameters (path parameters)
  request_parameters = {
    "method.request.path.filename" = true
  }
}

# API Gateway Integration with S3
resource "aws_api_gateway_integration" "MyDemoImageIntegration" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoImageResource.id
  http_method = aws_api_gateway_method.MyDemoImageMethod.http_method

  integration_http_method = "GET"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.aws_region}:s3:path/${aws_s3_bucket.my_bucket.id}/{filename}"

  # Map the path parameter from method request to integration request
  request_parameters = {
    "integration.request.path.filename" = "method.request.path.filename"
  }

  credentials = aws_iam_role.api_gateway_role.arn

  # Convert binary data for client
  content_handling = "CONVERT_TO_BINARY"
}

# API Gateway Method Response for 200 OK
resource "aws_api_gateway_method_response" "ImageResponse200" {
  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  resource_id = aws_api_gateway_resource.MyDemoImageResource.id
  http_method = aws_api_gateway_method.MyDemoImageMethod.http_method
  status_code = "200"

  # Specify the response model for content type "image/png"
  response_models = {
    "image/png" = "Empty"
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "MyDemoDeployment" {
  depends_on = [
    aws_api_gateway_integration.MyDemoImageIntegration,
    aws_api_gateway_method_response.ImageResponse200
  ]

  rest_api_id = aws_api_gateway_rest_api.MyDemoAPI.id
  stage_name  = "prod"
}

output "api_endpoint" {
  value = "${aws_api_gateway_deployment.MyDemoDeployment.invoke_url}/prod/{filename}"
}
