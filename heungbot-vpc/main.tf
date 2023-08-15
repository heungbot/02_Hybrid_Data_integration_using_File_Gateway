# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.VPC_CIDR
  enable_dns_hostnames = true # vpc endpoint interface 사용하기 위해선 dns hostname & vpc interface endpoint private dns을 enable 상태로 해야함.
  enable_dns_support   = true
  tags = {
    Name = "${var.APP_NAME}-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.PRIVATE_CIDR)
  cidr_block        = element(var.PRIVATE_CIDR, count.index)
  availability_zone = element(var.AZ, count.index)

  tags = {
    Name = "${var.APP_NAME}-private-subnet-${count.index + 1}"
  }
}

# private routing table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.APP_NAME}-routing-table-private"
  }
}

# resource "aws_route" "private" {
#   count             = length(var.PRIVATE_CIDR)
#   route_table_id         = aws_route_table.private.id
# }

resource "aws_route_table_association" "private" {
  count          = length(var.PRIVATE_CIDR)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

### VPC Endpoint

# storage gateway interface endpoint 
resource "aws_vpc_endpoint" "storage-gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.AWS_REGION}.storagegateway"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.storage-gateway-interface-endpoint-sg.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.APP_NAME}-storage-gateway-interface-endpoint"
  }
}

# storage gateway interface security group
resource "aws_security_group" "storage-gateway-interface-endpoint-sg" {
  name   = "storage-gateway-interface-endpoint-sg"
  vpc_id = aws_vpc.main.id

  dynamic "ingress" {
    for_each = {
      443  = ["${var.VPC_CIDR}"],
      1031 = ["${var.VPC_CIDR}"],
      2222 = ["${var.VPC_CIDR}"]
    }
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = ingress.value
      protocol    = "tcp"
    }
  }

  ingress {
    from_port   = 1026
    protocol    = "tcp"
    to_port     = 1028
    cidr_blocks = ["${var.VPC_CIDR}"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP_NAME}-storage-gateway-interface-endpoint-sg"
  }
}

# s3 interface endpoint 
# # 이는 AWS에서 3월에 새로 공개한 기능임.
# # terraform에선 아직 지원하지 않고, console에서만 생성 가능.
# resource "aws_vpc_endpoint" "s3" { 
#   vpc_id            = aws_vpc.main.id
#   service_name      = "com.amazonaws.${var.AWS_REGION}.s3"
#   vpc_endpoint_type = "Interface"

#   security_group_ids = [
#     aws_security_group.s3-interface-endpoint-sg.id
#   ]

#   private_dns_enabled = true # Error 발생. To set PrivateDnsOnlyForInboundResolverEndpoint to true, the VPC vpc-0f2ee4340f6baa628 must have a Gateway endpoint for the service.
#   # -> new feature that is not yey exists in terraform.
#   dns_options {
#     dns_record_ip_type = "ipv4"

# }

#   tags = {
#     Name = "${var.APP_NAME}-s3-interface-endpoint"
#   }
# }


# storage gateway interface security group
resource "aws_security_group" "s3-interface-endpoint-sg" {
  name   = "s3-interface-endpoint-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["${var.VPC_CIDR}"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.APP_NAME}-s3-interface-endpoint-sg"
  }
}
