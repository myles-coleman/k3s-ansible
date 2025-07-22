terraform_binary = "/snap/bin/tofu"

locals {
  inputs = yamldecode(file("common-inputs.yaml"))
  
  common_vars = {
    aws_region = "us-west-1"
    environment = "dev"
    project_name = "myles-homelab"
  }
}

remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "myles-homelab-tfstate"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-1"
    encrypt        = true
    use_lockfile   = true
  }
}