# Outputs from terraform-aws-modules/vpc/aws module

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_id" {
  description = "ID of the first public subnet"
  value       = module.vpc.public_subnets[0]
}

output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnet_cidr" {
  description = "CIDR block of the first public subnet"
  value       = module.vpc.public_subnets_cidr_blocks[0]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "availability_zone" {
  description = "Availability zone of the first subnet"
  value       = module.vpc.azs[0]
}
