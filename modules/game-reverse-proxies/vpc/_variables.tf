# Minimal VPC variables for game reverse proxy

variable "vpc_module_version" {
  description = "Version of the terraform-aws-modules/vpc/aws module"
  type        = string
  default     = "5.1.2"
}

variable "name" {
  description = "Name for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.0.0.0/24 for minimal setup)"
  type        = string
}

variable "azs" {
  description = "List of availability zones (use single AZ for cost savings)"
  type        = list(string)
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks (e.g., ['10.0.0.0/28'] for 11 usable IPs)"
  type        = list(string)
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "map_public_ip_on_launch" {
  description = "Auto-assign public IP on instance launch"
  type        = bool
  default     = true
}

variable "enable_flow_log" {
  description = "Enable VPC Flow Logs (costs extra, disabled by default)"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_iam_role" {
  description = "Create IAM role for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "create_flow_log_cloudwatch_log_group" {
  description = "Create CloudWatch log group for VPC Flow Logs"
  type        = bool
  default     = false
}

variable "public_subnet_tags" {
  description = "Additional tags for public subnets"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}
