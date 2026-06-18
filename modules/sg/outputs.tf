output "rds_sg_id" {
  value = aws_security_group.stride_flow_rds_mysql_sg.id
}

output "redis-sg-id" {
  value = aws_security_group.stride_flow_redis_sg.id
}

output "backend-sg-id" {
  value = aws_security_group.stride_flow_backend_sg.id
}

output "alb-sg-id"{
  value = aws_security_group.stride_flow_alb_sg.id
}
