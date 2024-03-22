variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1" # You can set a default region, or remove the default to require an explicit value when applying
}
