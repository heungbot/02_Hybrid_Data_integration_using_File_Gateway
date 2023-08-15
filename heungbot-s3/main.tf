data "aws_s3_bucket" "bucket" {
  bucket = var.BUCKET_NAME
}


# s3 bucket version 관리 on
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = data.aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# lifecycle 구성
resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  depends_on = [aws_s3_bucket_versioning.versioning]

  bucket = data.aws_s3_bucket.bucket.id

  rule {
    id = var.STORAGE_GATEWAY_DATA_RULE_NAME

    filter {
      prefix = var.STORAGE_GATEWAY_BUCKET_PREFIX # example : log/
    }

    noncurrent_version_transition { # 180일 이상된 구 버전 storage class IA로 변경
      noncurrent_days = 365
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition { # 365일 이상된 구 버전 storage class Glacier로 변경
      noncurrent_days = 730
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}