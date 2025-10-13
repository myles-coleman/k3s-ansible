variable "ec2_module_version" {
  description = "Version of the terraform-aws-modules/ec2-instance/aws module"
  type        = string
  default     = "6.1.1"  # Latest version, compatible with AWS provider v6.x
}

variable "name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "game-reverse-proxy"
}

variable "ami" {
  description = "AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with"
  type        = list(string)
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be created"
  type        = string
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address"
  type        = bool
  default     = true
}

variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = true
}

variable "user_data_base64" {
  description = "Base64-encoded user data script"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to replace the instance when user data changes"
  type        = bool
  default     = false
}

variable "root_block_device" {
  description = "Configuration for the root block device"
  type        = any  # Object type for module v6.x
  default     = {}
}

variable "metadata_options" {
  description = "Customize the metadata options for the instance"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
