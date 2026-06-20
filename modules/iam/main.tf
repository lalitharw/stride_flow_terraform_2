resource "aws_iam_role" "stride_flow_ec2_role" {
  name = "stride-flow-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "production"
  }
}


resource "aws_iam_policy" "ecr_read_only_policy" {
  name = "ecr-read-only-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchCheckLayerAvailability"
        ]
        Resource = [
          "arn:aws:ecr:us-east-1:962765735019:repository/stride_flow_backend_ecr",
          "arn:aws:ecr:us-east-1:962765735019:repository/stride_flow_caddy_ecr"
        ]
      }
    ]
  })
}


resource "aws_iam_instance_profile" "stride_flow_ecr_profile" {
  name = "stride-flow-profile"
  role = aws_iam_role.stride_flow_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "ecr_attach" {
  role       = aws_iam_role.stride_flow_ec2_role.name
  policy_arn = aws_iam_policy.ecr_read_only_policy.arn
}
