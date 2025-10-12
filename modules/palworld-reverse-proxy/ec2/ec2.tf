module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.1.1"  # Latest version, compatible with AWS provider v6.x

  name = var.name

  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.key_name
  monitoring                  = var.monitoring
  vpc_security_group_ids      = var.vpc_security_group_ids
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address
  
  # Don't create a security group - use the one passed in
  create_security_group       = false

  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  root_block_device           = var.root_block_device
  metadata_options            = var.metadata_options

  tags = var.tags
}