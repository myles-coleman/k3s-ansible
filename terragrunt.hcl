# Root terragrunt.hcl

# Configure Terragrunt to automatically use OpenTofu
terraform_binary = "/snap/bin/tofu"

locals {
  inputs = yamldecode(file("common-inputs.yaml"))
  
  # Common variables for all modules
  common_vars = {
    aws_region = "us-west-1"
    environment = "dev"
    project_name = "myles-homelab"
  }
}