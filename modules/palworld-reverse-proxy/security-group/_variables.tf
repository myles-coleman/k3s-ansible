variable "sg_module_version" {
  description = "Version of the terraform-aws-modules/security-group/aws module"
  type        = string
  default     = "5.1.0"
}

variable "name" {
  description = "Name of security group"
  type        = string
}

variable "description" {
  description = "Description of security group"
  type        = string
  default     = "Security group"
}

variable "vpc_id" {
  description = "ID of the VPC where to create security group"
  type        = string
}

variable "ingress_with_cidr_blocks" {
  description = "List of ingress rules to create with CIDR blocks"
  type        = list(map(string))
  default     = []
}

variable "egress_with_cidr_blocks" {
  description = "List of egress rules to create with CIDR blocks"
  type        = list(map(string))
  default     = []
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
