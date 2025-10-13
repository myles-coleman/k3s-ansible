variable "instance_id" {
  description = "ID of the EC2 instance to associate with the EIP"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the EIP"
  type        = map(string)
  default     = {}
}
