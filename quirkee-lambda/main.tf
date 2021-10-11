module "lambda_function" {
  # basic
  source = "terraform-aws-modules/lambda/aws"
  runtime = "nodejs14.x"
  publish = true
  function_name = "${var.env}-${var.name}"
  handler = "index.main"
  source_path = [
    var.handler_path,
    {
      path     = var.node_project_path,
      commands = [
        "npm install",
        ":zip"
      ],
      patterns = [
        "!.*/.*\\.txt",    # Skip all txt files recursively
        "node_modules/.+", # Include all node_modules
        "!node_modules/aws-sdk/.+", # Exclude all node_modules/aws-sdk
      ],
    }
  ]

  # store lambda in S3
  store_on_s3 = true
  s3_bucket = var.s3_bucket

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${var.api_gateway_api_execution_arn}/*/*/*"
    }
  }
}