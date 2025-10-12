module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = var.sg_module_version

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  # Ingress rules
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks

  # Egress rules
  egress_with_cidr_blocks = var.egress_with_cidr_blocks

  tags = var.tags
}