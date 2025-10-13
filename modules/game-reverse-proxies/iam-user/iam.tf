# IAM User for Game EC2 automation
resource "aws_iam_user" "game_automation" {
  name = var.user_name
  path = "/automation/"

  tags = var.tags
}

# Access key for programmatic access
resource "aws_iam_access_key" "game_automation" {
  user = aws_iam_user.game_automation.name
}

# IAM Policy for EC2 control
resource "aws_iam_user_policy" "game_ec2_control" {
  name = "GameEC2Control"
  user = aws_iam_user.game_automation.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DescribeAllInstances"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus"
        ]
        Resource = "*"
      },
      {
        Sid    = "ControlGameInstance"
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances"
        ]
        Resource = var.ec2_instance_arn
        Condition = {
          StringEquals = {
            "ec2:ResourceTag/Name" = var.ec2_instance_name
          }
        }
      }
    ]
  })
}

# Save credentials to local file (for easy setup)
resource "local_sensitive_file" "aws_credentials" {
  content = templatefile("${path.module}/credentials.tpl", {
    profile_name        = var.profile_name
    access_key_id       = aws_iam_access_key.game_automation.id
    secret_access_key   = aws_iam_access_key.game_automation.secret
    region              = var.region
  })
  filename        = pathexpand("~/.aws/credentials")
  file_permission = "0600"
}
