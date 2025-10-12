include {
  path = find_in_parent_folders("root.hcl")
}

locals {
  common_inputs = yamldecode(file(find_in_parent_folders("common-inputs.yaml")))
}

terraform {
  source = "${get_repo_root()}/modules/palworld-reverse-proxy/vpc"
}

inputs = {
  # VPC Configuration
  name     = "palworld-vpc"
  vpc_cidr = "10.0.0.0/24"  # Minimal /24 CIDR (256 IPs total)
  
  # Single AZ for cost savings (no cross-AZ data transfer costs)
  azs            = ["${local.common_inputs.aws_region}a"]
  public_subnets = ["10.0.0.0/28"]  # /28 = 16 IPs (11 usable after AWS reserves 5)
  
  # DNS Settings (required for EC2 hostname resolution)
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # Auto-assign public IPs to instances
  map_public_ip_on_launch = true
  
  # VPC Flow Logs (disabled to save costs - enable for debugging if needed)
  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false
  
  # Tags
  tags = merge(
    local.common_inputs.common_tags,
    {
      Name        = "palworld-vpc"
      Purpose     = "Palworld reverse proxy"
      CostCenter  = "gaming"
    }
  )
  
  public_subnet_tags = {
    Type = "public"
    Tier = "web"
  }
}
