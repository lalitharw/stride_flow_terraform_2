output "instance" {
  value = aws_instance.stride_flow_backend_instance.*.id
}
