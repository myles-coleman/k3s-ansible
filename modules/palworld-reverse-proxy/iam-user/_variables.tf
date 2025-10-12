variable "user_name" {
  description = "Name of the IAM user for automation"
  type        = string
  default     = "palworld-automation"
}

variable "profile_name" {
  description = "AWS CLI profile name for the credentials file"
  type        = string
  default     = "palworld-automation"
}

variable "ec2_instance_name" {
  description = "Name tag of the EC2 instance to control"
  type        = string
  default     = "palworld-reverse-proxy"
}

variable "ec2_instance_arn" {
  description = "ARN of the EC2 instance (from EC2 module output)"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-1"
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}
