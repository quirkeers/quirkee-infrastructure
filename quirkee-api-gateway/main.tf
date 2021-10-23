variable "subdomain_map" {
  default = {
    "production": "",
    "development": "dev-"
  }
}

variable "cognito_admin_user_pool_endpoint_map" {
  default = {
    "development": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_pCbZCYiRO",
    "production": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_vXpswC2rb"
  }
}

locals  {
  domain_name = "quirkee.net"
  subdomain = lookup(var.subdomain_map, var.env)
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name = "${var.env}-${var.name}-gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }

  domain_name = "${local.subdomain}${var.name}.${local.domain_name}"
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  integrations = {

    "ANY /" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "ANY /api/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "$default" = { lambda_arn = var.lambda_arn }
  }
}

resource "aws_apigatewayv2_authorizer" "some_authorizer" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.env}-${var.name}-gateway-authorizer"

  jwt_configuration {
    audience = ["quirkee-admin"]
    issuer   = "https://${lookup(var.cognito_admin_user_pool_endpoint_map, var.env)}"
  }
}

data "aws_route53_zone" "this" {
  name = local.domain_name
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${local.subdomain}${var.name}"
  type    = "A"

  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 3.0"

  domain_name               = local.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["${local.subdomain}${var.name}.${local.domain_name}"]
}
