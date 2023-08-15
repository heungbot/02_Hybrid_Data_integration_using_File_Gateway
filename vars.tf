# 공통 변수
variable "AWS_REGION" {
  default = "ap-northeast-2"
}

variable "APP_NAME" {
  default = "heungbot-sgw"
}


# vpc module
variable "AZ" {
  default = ["ap-northeast-2a"]
}


variable "VPC_CIDR" {
  default = "20.0.0.0/16"
}

variable "PRIVATE_CIDR" {
  default = ["20.0.128.0/20"] # 64 ~ 127
}



# s3 bucket module
variable "BUCKET_NAME" {
  default = "heungbot-db-snapshot-demo"
}

variable "STORAGE_GATEWAY_DATA_RULE_NAME" {
  default = "heungbot-sgw-data-rule"
}

variable "STORAGE_GATEWAY_BUCKET_PREFIX" {
  default = "storage-gateway/"
}



# storage gateway module
variable "GATEWAY_IP_ADDRESS" {
  default = "1.2.3.4"
}

variable "STORAGE_GATEWAY_NAME" {
  default = "heungbot-storage-gateway"
}

variable "FILE_SHARE_NAME" {
  default = "heungbot-file-share"
}

variable "CLIENT_LIST" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "DISK_ID" {
  default = "test"
}
