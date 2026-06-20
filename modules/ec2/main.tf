# resource "aws_instance" "stride_flow_backend_instance" {
#   count                  = length(var.private_subnets)
#   ami                    = data.aws_ami.ubuntu.id
#   instance_type          = "c7i-flex.large"
#   vpc_security_group_ids = [var.backend_sg_id]
#   subnet_id              = var.private_subnets[count.index]
#   user_data              = file("${path.module}/backend.sh")
#   iam_instance_profile   = var.iam_instance_profile

#   tags = {
#     Name = "stride-flow-instance-${count.index + 1}"
#   }
# }



resource "aws_instance" "stride_flow_redis_instance" {
  ami                    = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [var.redis_sg_id]
  instance_type          = "t3.small"
  subnet_id              = var.redis_private_subnet
  user_data              = file("${path.module}/redis.sh")
  tags = {
    Name = "stride-flow-redis-instance"
  }
}

resource "aws_launch_template" "stride_flow" {
  name_prefix   = "stride-flow-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "c7i-flex.large"

  vpc_security_group_ids = [
    var.backend_sg_id
  ]

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  user_data = base64encode(file("${path.module}/backend.sh"))
}
