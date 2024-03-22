resource "aws_s3_bucket" "my_bucket" {
  # Ensure the prefix will always generate a valid bucket name
  bucket_prefix = "my-unique-bucket-${random_string.bucket_suffix.result}-"
}

resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
  numeric  = true
  lower   = true
}


data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAPIGatewayAccess",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.my_bucket.arn}/*",
        Condition = {
          StringNotEquals = {
            "aws:SourceArn": "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.MyDemoAPI.id}/*/*"
          }
        }
      }
    ]
  })
}
