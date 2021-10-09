output "app_bucket_arn" {
  value = module.s3_bucket.this_s3_bucket_arn
}

output "app_bucket_id" {
  value = module.s3_bucket.this_s3_bucket_id
}