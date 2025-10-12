resource "aws_eip" "this" {
  domain   = "vpc"
  instance = var.instance_id

  tags = var.tags
}
