resource "aws_lb" "stride_flow_lb" {
  name               = "stride-flow-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb-sg-id]
  subnets            = var.public_subnets_id

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}


# target group
resource "aws_lb_target_group" "stride_flow_target_group" {
  name     = "stride-flow-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }
}

# target group attachment
resource "aws_lb_target_group_attachment" "test" {
  count            = length(var.instance)
  target_group_arn = aws_lb_target_group.stride_flow_target_group.arn
  target_id        = var.instance[count.index]
  port             = 80


}

# listener
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.stride_flow_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.stride_flow_target_group.arn
        weight = 100
      }

    }
  }
}
