locals {
  bucket_name = "${var.env}-${var.name}-app-${uuid()}"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 1.0"

  bucket        = substr(local.bucket_name, 0, 60)
  force_destroy = true
}
