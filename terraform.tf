variable "env" {}
variable "name" {}

module "quirkee_api_gateway" {
  source = "./quirkee-api-gateway"

  env = var.env
  name = var.name
  lambda_arn = module.quirkee_lambda.lambda_arn
}

module "quirkee_lambda" {
  source = "./quirkee-lambda"

  env = var.env
  name = var.name

  api_gateway_api_execution_arn = module.quirkee_api_gateway.api_gateway_api_execution_arn

  handler_path = "./lib/index.js"
  node_project_path = "./"
  s3_bucket = module.quirkee_lambda_s3_bucket.app_bucket_id
}

module "quirkee_lambda_s3_bucket" {
  source = "./quirkee-s3-bucket"

  env = var.env
  name = var.name
}
