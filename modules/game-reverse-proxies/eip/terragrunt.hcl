include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

terraform {
  source = "${get_repo_root()}/modules/game-reverse-proxies/eip"
}

# Dependency on EC2 instance
dependency "ec2" {
  config_path = "${get_repo_root()}/modules/game-reverse-proxies/ec2"
  
  # Mock outputs for plan/validate without deploying EC2 first
  mock_outputs = {
    id                  = "i-mock-12345678"
    instance_id         = "i-mock-12345678"
    instance_public_ip  = "203.0.113.1"
    instance_private_ip = "10.0.0.10"
    arn                 = "arn:aws:ec2:us-west-1:123456789012:instance/i-mock-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "init"]
}

inputs = {
  instance_id = dependency.ec2.outputs.id
  
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name = "game-reverse-proxies-eip"
    }
  )
}
