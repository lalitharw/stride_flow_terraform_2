resource "aws_ecr_repository" "stride_flow_backend_ecr" {
  name                 = "stride_flow_backend_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}

resource "aws_ecr_repository" "stride_flow_caddy_ecr" {
  name                 = "stride_flow_caddy_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

}
