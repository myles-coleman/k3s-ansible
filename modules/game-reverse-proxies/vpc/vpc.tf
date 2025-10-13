# Minimal cost-optimized VPC for game reverse proxy
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = var.vpc_module_version

  name = var.name
  cidr = var.vpc_cidr
  
  # Single AZ for cost savings (no cross-AZ data transfer)
  azs            = var.azs
  public_subnets = var.public_subnets
  
  # No private subnets needed (saves NAT Gateway costs)
  private_subnets = []
  
  # DNS settings
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  # Auto-assign public IPs
  map_public_ip_on_launch = var.map_public_ip_on_launch
  
  # Cost optimization: No NAT Gateway (saves $32/month!)
  enable_nat_gateway = false
  enable_vpn_gateway = false
  
  # VPC Flow Logs (optional, disabled by default to save costs)
  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  
  # Tags
  tags               = var.tags
  public_subnet_tags = var.public_subnet_tags
}