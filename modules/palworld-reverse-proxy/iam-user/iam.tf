# IAM User for Palworld EC2 automation
resource "aws_iam_user" "palworld_automation" {
  name = var.user_name
  path = "/automation/"

  tags = var.tags
}

# Access key for programmatic access
resource "aws_iam_access_key" "palworld_automation" {
  user = aws_iam_user.palworld_automation.name
}

# IAM Policy for EC2 control
resource "aws_iam_user_policy" "palworld_ec2_control" {
  name = "PalworldEC2Control"
  user = aws_iam_user.palworld_automation.name

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
        Sid    = "ControlPalworldInstance"
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
    access_key_id       = aws_iam_access_key.palworld_automation.id
    secret_access_key   = aws_iam_access_key.palworld_automation.secret
    region              = var.region
  })
  filename        = pathexpand("~/.aws/credentials-palworld")
  file_permission = "0600"
}
