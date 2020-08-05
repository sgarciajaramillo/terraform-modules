provider "aws" {
  access_key    = var.access_key
  secret_key    = var.secret_key
  region        = var.aws_region
}

data "template_file" "web_userdata" {
  template = file("./web-userdata.tpl")
}

resource "aws_instance" "ec2" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  user_data                   = data.template_file.web_userdata.rendered
  iam_instance_profile        = var.iam_instance_profile_id
  private_ip                  = var.private_ip
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.public_ip
  key_name                    = var.key_pair
  vpc_security_group_ids      = [var.security_group]
  tags = {
	Name = "${var.customer_prefix}-${var.environment}-EC2-${var.description}"
    Environment = var.environment
  }
}
