# Outputs from IAM user module

output "user_name" {
  description = "Name of the IAM user"
  value       = aws_iam_user.palworld_automation.name
}

output "user_arn" {
  description = "ARN of the IAM user"
  value       = aws_iam_user.palworld_automation.arn
}

output "access_key_id" {
  description = "Access key ID for the IAM user"
  value       = aws_iam_access_key.palworld_automation.id
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key for the IAM user"
  value       = aws_iam_access_key.palworld_automation.secret
  sensitive   = true
}

output "credentials_file_path" {
  description = "Path to the generated credentials file"
  value       = local_sensitive_file.aws_credentials.filename
}

output "profile_name" {
  description = "AWS CLI profile name to use"
  value       = var.profile_name
}
