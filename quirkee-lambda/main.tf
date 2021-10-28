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

  attach_policy_jsons = var.attach_policy_jsons
  policy_jsons        = var.policy_jsons
  number_of_policy_jsons = var.number_of_policy_jsons

  # max
  memory_size = 2048
  timeout = 60

  environment_variables = {
    APP_ENV = var.env
  }

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${var.api_gateway_api_execution_arn}/*/*/*"
    }
  }
}
