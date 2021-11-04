locals {
  authorizer_key: "${var.authorizer_type}_${var.env}"
}

variable "subdomain_map" {
  default = {
    "production": "",
    "development": "dev-"
  }
}

variable "cognito_user_pool_endpoint_map" {
  default = {
    "admin_development": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_pCbZCYiRO",
    "admin_production": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_vXpswC2rb"
    "customer_development": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_3stpZksQE",
    "customer_production": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_g3qLCyS2G"
    "svc2svc_development": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_tgCHXqbQv",
    "svc2svc_production": "cognito-idp.ap-southeast-1.amazonaws.com/ap-southeast-1_LiNmIglhY"
  }
}


variable "cognito_jwt_token_aud_map" {
  default = {
    "admin_development": "1g1srh0jvrlrtsob12f6p2l0en",
    "admin_production": "3pom6ukr3uitpsdvma95198nm4"
    "customer_development": "6ofb0j17okkl62vkk2mjrhaejr",
    "customer_production": "54k7aiilagmsciqk84lmjko46h"
    "svc2svc_development": "n9rdkthcdijf1cua4vctikj4h",
    "svc2svc_production": "4a0i0qqd4q0rid2s52vkfdv35t"
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
    allow_headers = ["Content-Type","Accept","Authorization","Origin"]
    allow_methods = ["*"]
    allow_origins = [
        "https://quirkee.net",
        "https://admin.quirkee.net",
        "https://dev-admin.quirkee.net",
]
    allow_credentials = "true"
  }

  domain_name = "${local.subdomain}${var.name}.${local.domain_name}"
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  integrations = {

    "OPTIONS /{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "ANY /public/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
    }

    "GET /api/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
      authorization_type     = "JWT"
      authorizer_id          = aws_apigatewayv2_authorizer.admin_authorizer.id
    }

    "POST /api/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
      authorization_type     = "JWT"
      authorizer_id          = aws_apigatewayv2_authorizer.admin_authorizer.id
    }

    "PUT /api/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
      authorization_type     = "JWT"
      authorizer_id          = aws_apigatewayv2_authorizer.admin_authorizer.id
    }

    "PATCH /api/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
      authorization_type     = "JWT"
      authorizer_id          = aws_apigatewayv2_authorizer.admin_authorizer.id
    }

    "DELETE /api/{proxy+}" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "1.0"
      timeout_milliseconds   = 12000
      authorization_type     = "JWT"
      authorizer_id          = aws_apigatewayv2_authorizer.admin_authorizer.id
    }

    "$default" = {
      lambda_arn = var.lambda_arn
      authorization_type     = "JWT"
      authorizer_id          = aws_apigatewayv2_authorizer.admin_authorizer.id
    }
  }
}

resource "aws_apigatewayv2_authorizer" "admin_authorizer" {
  api_id           = module.api_gateway.apigatewayv2_api_id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "${var.env}-${var.name}-gateway-authorizer"

  jwt_configuration {
    audience = [lookup(var.cognito_jwt_token_aud_map, local.authorizer_key)]
    issuer   = "https://${lookup(var.cognito_user_pool_endpoint_map, local.authorizer_key)}"
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

