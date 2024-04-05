variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "api_gateway_details" {
  description = "Details of the API Gateway REST API"
  type = object({
    name        = string
    description = string
  })
  default = {
    name        = "MyModuleAPI"
    description = "API gateway to route all the traffic to a destined endpoint"
  }
}


variable "path_part" {
  description = "Path part for the API Gateway resource, including path parameters"
  type        = string
  default     = "{objectKey}"
}

variable "path_part_withoutbraces" {
  description = "Path part for the API Gateway resource, including path parameters"
  type        = string
  default     = "objectKey"
}

variable "method_details" {
  description = "Details of the API gateway method"
  type = object({
    http_method = string
    authorization = string 
  })
  default = {
    http_method = "GET"
    authorization = "NONE"
  }
}

variable "authorizer_config" {
  description = "Configuration for the API Gateway authorizer. Leave empty for no authorizer."
  type = object({
    name                 = string
    type                 = string
    lambda_function_arn  = string
    authorizer_credentials = string
    identity_source      = string
  })
  default = null
}

variable "integration_config" {
  description = "Configuration for the API Gateway Integration."
  type = object({
    http_method             = string
    type                    = string
    integration_http_method = string
    uri                     = string
    credentials             = string
    timeout_milliseconds    = number
    #request_parameters      = map(string)
  })
}

variable "stage_config" {
  description = "Configuration for the API Gateway stage."
  type = object({
    stage_name = string
  })
  default = {
    stage_name = "dev"
  }
}





