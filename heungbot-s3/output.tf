output "bucket_id" {
  value = data.aws_s3_bucket.bucket.id
}

output "bucket_arn" {
  value = data.aws_s3_bucket.bucket.arn
}

output "bucket_regional_domain_name" {
  value = data.aws_s3_bucket.bucket.bucket_regional_domain_name
}