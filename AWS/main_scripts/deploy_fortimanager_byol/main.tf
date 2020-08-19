
provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}


data "aws_ami" "fortimanager_byol" {
  most_recent = true

  filter {
    name                         = "name"
    values                       = [var.fmgr_ami_string]
  }

  filter {
    name                         = "virtualization-type"
    values                       = ["hvm"]
  }

  owners                         = ["679593333241"] # Canonical
}

resource aws_security_group "fortimanager_sg" {
  name = "allow_public_subnets"
  description = "Allow all traffic from public Subnets"
  vpc_id = var.vpc_id
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_public_subnets"
  }
}

module "fortimanager" {
  source                      = "../../modules/fortimanager_byol"

  access_key                  = var.access_key
  secret_key                  = var.secret_key
  aws_region                  = var.aws_region
  availability_zone           = var.availability_zone
  customer_prefix             = var.customer_prefix
  environment                 = var.environment
  subnet_id                   = var.subnet_id
  ip_address                  = var.ip_address
  aws_fmgrbyol_ami            = data.aws_ami.fortimanager_byol.id
  keypair                     = var.keypair
  fmgr_instance_type          = var.fortimanager_instance_type
  fortimanager_instance_name  = var.fortimanager_instance_name
  security_group_public_id    = aws_security_group.fortimanager_sg.id
  fmgr_byol_license           = var.fmgr_byol_license
}

