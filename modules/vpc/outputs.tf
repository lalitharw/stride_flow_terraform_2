output "vpc_id" {
  value = aws_vpc.stride_flow_vpc.id
}


output "private_subnets_id" {
  value = aws_subnet.stride_flow_private_subnet.*.id
}

output "public_subnets_id" {
  value = aws_subnet.stride_flow_public_subnet.*.id
}

output "redis_private_subnet" {
  value = aws_subnet.stride_flow_redis_subnet.id
}
