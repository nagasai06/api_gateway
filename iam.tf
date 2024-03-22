resource "aws_iam_role" "api_gateway_role" {
  name = "api_gateway_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
      },
    ]
  })
}

resource "aws_iam_role_policy" "api_gateway_s3_policy" {
  name = "api_gateway_s3_policy"
  role = aws_iam_role.api_gateway_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = ["s3:GetObject"],
        Effect = "Allow",
        Resource = "${aws_s3_bucket.my_bucket.arn}/*",
      },
    ]
  })
}
