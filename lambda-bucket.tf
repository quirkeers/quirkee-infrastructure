locals {
  bucket_name = "${var.name}-lambda-bucket"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 1.0"

  bucket        = local.bucket_name
  force_destroy = true
}
