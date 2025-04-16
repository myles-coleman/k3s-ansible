terraform {
  backend "s3" {
    bucket  = "myles-homelab-tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}
# terraform init -backend-config="key=k3s-ansible/argocd-configure/terraform.tfstate"