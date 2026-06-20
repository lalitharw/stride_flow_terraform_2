# output "instance" {
#   value = aws_instance.stride_flow_backend_instance.*.id
# }


output "instance_launch_id" {
  value = aws_launch_template.stride_flow.name
}
