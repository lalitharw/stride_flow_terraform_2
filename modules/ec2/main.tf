resource "aws_instance" "example" {
  count                  = length(var.private_subnets)
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "c7i-flex.large"
  vpc_security_group_ids = [var.backend_sg_id]
  subnet_id              = var.private_subnets[count.index]
#   user_data = 

  tags = {
    Name = "stride-flow-instance-${count.index + 1}"
  }
}
