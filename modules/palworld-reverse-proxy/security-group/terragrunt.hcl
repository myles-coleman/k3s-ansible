include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

terraform {
  source = "${get_repo_root()}/modules/palworld-reverse-proxy/security-group"
}

dependency "vpc" {
  config_path = "${get_repo_root()}/modules/palworld-reverse-proxy/vpc"
  
  # Mock outputs for plan/validate without deploying VPC first
  mock_outputs = {
    vpc_id = "vpc-mock-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

inputs = {
  name        = "palworld-reverse-proxy-sg"
  description = "Security group for Palworld reverse proxy"
  vpc_id      = dependency.vpc.outputs.vpc_id
  
  # Ingress rules
  ingress_with_cidr_blocks = [
    {
      from_port   = 8211
      to_port     = 8211
      protocol    = "udp"
      description = "Palworld game port"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH access"
      cidr_blocks = get_env("ADMIN_CIDR_BLOCKS", "0.0.0.0/0")
    }
  ]
  
  # Egress rules - allow all outbound
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name = "palworld-reverse-proxy-sg"
    }
  )
}
