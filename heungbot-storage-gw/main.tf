# storage gateway 
resource "aws_storagegateway_gateway" "main" {
  gateway_ip_address   = var.GATEWAY_IP_ADDRESS
  gateway_name         = var.STORAGE_GATEWAY_NAME
  gateway_timezone     = "GMT+09:00" # 한국 시간
  gateway_type         = "FILE_S3"
  gateway_vpc_endpoint = var.STORAGE_GATEWAY_INTERFACE_ENDPOINT_ARN

  tags = {
    Name = "${var.APP_NAME}-${var.STORAGE_GATEWAY_NAME}"
  }
}

# file sharing
resource "aws_storagegateway_nfs_file_share" "nfs" {
  client_list = var.CLIENT_LIST # default = 0.0.0.0/0
  gateway_arn = aws_storagegateway_gateway.main.arn

  location_arn          = "${var.BUCKET_ARN}/${var.STORAGE_GATEWAY_BUCKET_PREFIX}" # prefix = storage-gateway/
  file_share_name       = var.FILE_SHARE_NAME
  vpc_endpoint_dns_name = var.S3_INTERFACE_ENDPOINT_DNS_NAME
  bucket_region         = var.AWS_REGION
  default_storage_class = "S3_STANDARD"

  nfs_file_share_defaults {

    directory_mode = "0777"

    file_mode = "0666"

    group_id = 65534

    owner_id = 65534
  }

  role_arn = aws_iam_role.file-share-role.arn

  tags = {
    Name = "${var.APP_NAME}-${var.FILE_SHARE_NAME}"
  }
}

# file share role
resource "aws_iam_role" "file-share-role" {
  name = "file_share_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "storagegateway.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "${var.APP_NAME}-file-share-role"
  }
}

resource "aws_iam_policy" "file-share-policy" {
  name = "file-share-role-policy"
  path = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetAccelerateConfiguration",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads"
        ]
        Effect   = "Allow"
        Resource = "${var.BUCKET_ARN}"
      },
      {
        Action = [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObjectVersion",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Effect   = "Allow"
        Resource = "${var.BUCKET_ARN}/${var.STORAGE_GATEWAY_BUCKET_PREFIX}*" # bucket_name/storage-gateway/*
      }
    ]
  })
}

# policy attach to role
resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.file-share-role.name
  policy_arn = aws_iam_policy.file-share-policy.arn
}

# cache volume config
resource "aws_storagegateway_cache" "cache-volume" {
  disk_id = var.DISK_ID
  # disk_id     = data.aws_storagegateway_local_disk.example.id # exmaple : pci-0000:03:000-scsi-0:0:0:0. => terraform docs에 나온 형식.
  gateway_arn = aws_storagegateway_gateway.main.arn
}

