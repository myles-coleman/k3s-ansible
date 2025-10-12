include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

terraform {
  source = "${get_repo_root()}/modules/palworld-reverse-proxy/iam-user"
}

# Dependency on EC2 instance (to get ARN)
dependency "ec2" {
  config_path = "${get_repo_root()}/modules/palworld-reverse-proxy/ec2"
  
  mock_outputs = {
    arn = "arn:aws:ec2:us-west-1:123456789012:instance/i-mock-12345678"
  }
  mock_outputs_allowed_terraform_commands = ["init", "validate", "plan"]
}

inputs = {
  user_name          = "palworld-automation"
  profile_name       = "palworld-automation"
  ec2_instance_name  = "palworld-reverse-proxy"
  ec2_instance_arn   = dependency.ec2.outputs.arn
  region             = "us-west-1"
  
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name    = "palworld-automation-user"
      Purpose = "Automated EC2 instance control for Palworld"
    }
  )
}
