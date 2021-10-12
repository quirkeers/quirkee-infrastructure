variable "subdomain_map" {
  default = {
    "production": "prod",
    "development": "dev"
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

  domain_name = "${local.subdomain}-${var.name}.${local.domain_name}"
  domain_name_certificate_arn = module.acm.acm_certificate_arn

  integrations = {
    "ANY /" = {
      lambda_arn             = var.lambda_arn
      payload_format_version = "2.0"
      timeout_milliseconds   = 12000
    }

"$default" = { lambda_arn = var.lambda_arn }
  }
}

data "aws_route53_zone" "this" {
  name = local.domain_name
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.this.zone_id
  name    = "${local.subdomain}-${var.name}"
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
  subject_alternative_names = ["${local.subdomain}-${var.name}.${local.domain_name}"]
}
