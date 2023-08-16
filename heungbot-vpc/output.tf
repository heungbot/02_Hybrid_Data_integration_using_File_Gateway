output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "private subnet's id list"
  value       = aws_subnet.private.*.id
}

output "sgw-interface_endpoint_id" {
  value = aws_vpc_endpoint.storage-gateway.id
}

output "sgw-interface_endpoint_arn" {
  value = aws_vpc_endpoint.storage-gateway.arn
}


# terraform이 아직 지원하지 않음
# output "s3-interface_endpoint_id" {
#   value = aws_vpc_endpoint.s3.id
# }

# output "s3-interface_endpoint_arn" {
#   value = aws_vpc_endpoint.s3.arn
# }

# output "s3-interface_endpoint_dns_name" {
#   value = aws_vpc_endpoint.s3.dns_entry[0].dns_name
# }