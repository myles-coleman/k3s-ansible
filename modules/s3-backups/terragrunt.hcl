# Include the root terragrunt.hcl configuration
include "root" {
  path = find_in_parent_folders()
}

# Override the remote state key for this module
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "myles-homelab-tfstate"
    key            = "k3s-ansible/s3-backups/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
    use_lockfile   = true
  }
}

# Load common inputs and add module-specific ones
locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

# Module-specific inputs
inputs = merge(
  local.common_inputs,
  {
    # S3 backup specific variables
    bucket_name = "myles-homelab-backups"
    backup_retention_days = 90
  }
)
