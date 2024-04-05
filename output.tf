output "stage_invoke_url" {
  description = "The invoke URL for the API Gateway stage"
  value       = "https://${aws_api_gateway_rest_api.MyDemoAPI.id}.execute-api.${var.aws_region}.amazonaws.com/${var.stage_config.stage_name}"
}