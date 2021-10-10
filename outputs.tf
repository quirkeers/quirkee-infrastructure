output "api_gateway_api_execution_arn" {
  value = module.quirkee_api_gateway.api_gateway_api_execution_arn
}

output "lambda_arn" {
  value = module.quirkee_lambda.lambda_arn
}

output "app_bucket_arn" {
  value = module.quirkee_lambda_s3_bucket.app_bucket_arn
}

output "app_bucket_id" {
  value = module.quirkee_lambda_s3_bucket.app_bucket_id
}
