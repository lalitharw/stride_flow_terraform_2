resource "aws_autoscaling_group" "bar" {
  name                      = "stride-flow-asg"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = var.instance_launch_id
  vpc_zone_identifier       = var.private_subnets
  target_group_arns         = [var.target_group_arn]
  tag {
    key                 = "Name"
    value               = "stride-flow"
    propagate_at_launch = true
  }
}
