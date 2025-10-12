# Outputs from terraform-aws-modules/ec2-instance module

output "id" {
  description = "ID of the EC2 instance"
  value       = module.ec2_instance.id
}

output "instance_id" {
  description = "ID of the EC2 instance (alias)"
  value       = module.ec2_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.ec2_instance.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = module.ec2_instance.private_ip
}

output "arn" {
  description = "ARN of the EC2 instance"
  value       = module.ec2_instance.arn
}

output "key_pair_name" {
  description = "Name of the SSH key pair"
  value       = aws_key_pair.this.key_name
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_sensitive_file.private_key.filename
}
