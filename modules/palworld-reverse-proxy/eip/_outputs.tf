output "public_ip" {
  description = "The Elastic IP address"
  value       = aws_eip.this.public_ip
}

output "allocation_id" {
  description = "The allocation ID of the Elastic IP"
  value       = aws_eip.this.id
}
