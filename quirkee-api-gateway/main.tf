module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name = "${var.env}-${var.name}-gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  create_api_domain_name = true

  integrations = {
    "ANY /" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

    "$default" = {
      lambda_arn = var.lambda_arn
    }
  }
}
