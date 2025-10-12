include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

terraform {
  source = "${get_repo_root()}/modules/palworld-reverse-proxy/ec2"
}

dependency "vpc" {
  config_path = "${get_repo_root()}/modules/palworld-reverse-proxy/vpc"
  
  # Mock outputs for plan/validate without deploying VPC first
  mock_outputs = {
    vpc_id            = "vpc-mock-12345678"
    public_subnet_id  = "subnet-mock-12345678"
    vpc_cidr          = "10.0.0.0/24"
    availability_zone = "us-west-1a"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

dependency "security_group" {
  config_path = "${get_repo_root()}/modules/palworld-reverse-proxy/security-group"
  
  # Mock outputs for plan/validate without deploying security group first
  mock_outputs = {
    security_group_id   = "sg-mock-12345678"
    security_group_arn  = "arn:aws:ec2:us-west-1:123456789012:security-group/sg-mock-12345678"
    security_group_name = "palworld-reverse-proxy-sg-mock"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

inputs = {
  name = "palworld-reverse-proxy"
  
  ami                         = "ami-0b967c22fe917319b"
  instance_type               = "t3.micro"
  key_name                    = "reverse-proxy"
  
  # Network configuration
  subnet_id                   = dependency.vpc.outputs.public_subnet_id
  vpc_security_group_ids      = [dependency.security_group.outputs.security_group_id]
  associate_public_ip_address = true
  
  # Monitoring
  monitoring                  = true
  
  # User data script
  user_data_base64            = base64encode(templatefile("${get_terragrunt_dir()}/user-data.sh", {
    tailscale_auth_key = get_env("TAILSCALE_AUTH_KEY")
    palworld_server_ip = get_env("PALWORLD_SERVER_IP")
  }))
  
  user_data_replace_on_change = false
  
  # Root volume (object format for module v6.x)
  root_block_device = {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
    encrypted             = true
  }
  
  # IMDSv2
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }
  
  # EIP will be created separately
  create_eip = false
  
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name = "palworld-reverse-proxy"
    }
  )
}