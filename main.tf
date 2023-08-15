module "heungbot-vpc" {
  source       = "./heungbot-vpc"
  APP_NAME     = var.APP_NAME
  AWS_REGION   = var.AWS_REGION
  AZ           = var.AZ
  VPC_CIDR     = var.VPC_CIDR
  PRIVATE_CIDR = var.PRIVATE_CIDR
}

module "heungbot-s3" {
  source                         = "./heungbot-s3"
  BUCKET_NAME                    = var.BUCKET_NAME
  STORAGE_GATEWAY_DATA_RULE_NAME = var.STORAGE_GATEWAY_DATA_RULE_NAME
  STORAGE_GATEWAY_BUCKET_PREFIX  = var.STORAGE_GATEWAY_BUCKET_PREFIX
}

module "heungbot-storage-gw" {
  source                         = "./heungbot-storage-gw"
  APP_NAME                       = var.APP_NAME
  AWS_REGION                     = var.AWS_REGION
  GATEWAY_IP_ADDRESS             = var.GATEWAY_IP_ADDRESS
  STORAGE_GATEWAY_NAME           = var.STORAGE_GATEWAY_NAME
  STORAGE_GATEWAY_BUCKET_PREFIX  = var.STORAGE_GATEWAY_BUCKET_PREFIX
  FILE_SHARE_NAME                = var.FILE_SHARE_NAME
  CLIENT_LIST                    = var.CLIENT_LIST
  DISK_ID                        = var.DISK_ID
  BUCKET_ARN                     = module.heungbot-s3.bucket_arn
  STORAGE_GATEWAY_INTERFACE_ENDPOINT_ARN     = module.heungbot-vpc.sgw-interface_endpoint_arn
  S3_INTERFACE_ENDPOINT_DNS_NAME = module.heungbot-vpc.s3-interface_endpoint_dns_name
}