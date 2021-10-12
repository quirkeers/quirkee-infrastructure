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

//  layers = [
//    module.lambda_layer_s3.lambda_layer_arn,
//  ]

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${var.api_gateway_api_execution_arn}/*/*/*"
    }
  }
}

//module "lambda_layer_s3" {
//  source = "terraform-aws-modules/lambda/aws"
//
//  create_layer = true
//
//  layer_name          = "${var.env}-${var.name}-layer"
//  description         = "${var.env}-${var.name}'s common layer"
//  compatible_runtimes = ["nodejs14.x"]
//
//  source_path = var.node_project_path
//
//  store_on_s3 = true
//  s3_bucket   = var.s3_bucket
//}
