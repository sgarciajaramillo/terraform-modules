
provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
  version    = "~> 3.0"
}

#
# AMI to be used by the BYOL instance of Fortigate
# Change the fortigate_ami_string in terraform.tfvars to change it
#
data "aws_ami" "fortigate_byol" {
  most_recent = true

  filter {
    name                         = "name"
    values                       = [var.fortigate_ami_string]
  }

  filter {
    name                         = "virtualization-type"
    values                       = ["hvm"]
  }

  owners                         = ["679593333241"] # Canonical
}

#
# This is an "allow all" security group, but a place holder for a more strict SG
#
module "allow_private_subnets" {
  source = "../../modules/security_group"
  access_key              = var.access_key
  secret_key              = var.secret_key
  aws_region              = var.aws_region
  vpc_id                  = module.base-vpc.vpc_id
  name                    = "${var.fortigate_sg_name} Allow Private Subnets"
  ingress_to_port         = 0
  ingress_from_port       = 0
  ingress_protocol        = "-1"
  ingress_cidr_for_access = "0.0.0.0/0"
  egress_to_port          = 0
  egress_from_port        = 0
  egress_protocol         = "-1"
  egress_cidr_for_access  = "0.0.0.0/0"
  customer_prefix         = var.customer_prefix
  environment             = var.environment
}

#
# This is an "allow all" security group, but a place holder for a more strict SG
#
module "allow_public_subnets" {
  source = "../../modules/security_group"
  access_key              = var.access_key
  secret_key              = var.secret_key
  aws_region              = var.aws_region
  vpc_id                  = module.base-vpc.vpc_id
  name                    = "${var.fortigate_sg_name} Allow Public Subnets"
  ingress_to_port         = 0
  ingress_from_port       = 0
  ingress_protocol        = "-1"
  ingress_cidr_for_access = "0.0.0.0/0"
  egress_to_port          = 0
  egress_from_port        = 0
  egress_protocol         = "-1"
  egress_cidr_for_access  = "0.0.0.0/0"
  customer_prefix         = var.customer_prefix
  environment             = var.environment
}

#
# VPC Setups, route tables, route table associations
#

#
# Security VPC, IGW, Subnets, Route Tables, Route Table Associations, VPC Endpoint
#
module "base-vpc" {
  source                          = "../base_vpc_dual_az"
  access_key                      = var.access_key
  secret_key                      = var.secret_key
  aws_region                      = var.aws_region
  customer_prefix                 = var.customer_prefix
  environment                     = var.environment
  vpc_name                        = var.vpc_name_security
  availability_zone1              = var.availability_zone_1
  availability_zone2              = var.availability_zone_2
  vpc_cidr                        = var.vpc_cidr_security
  public1_subnet_cidr             = var.public_subnet_cidr1
  public2_subnet_cidr             = var.public_subnet_cidr2
  private1_subnet_cidr            = var.private_subnet_cidr_1
  private2_subnet_cidr            = var.private_subnet_cidr_2
  public1_description             = var.public1_description
  public2_description             = var.public2_description
  private1_description            = var.private1_description
  private2_description            = var.private2_description

}

module "vpc-transit-gateway" {
  source                          = "../../modules/tgw"
  access_key                      = var.access_key
  secret_key                      = var.secret_key
  aws_region                      = var.aws_region
  customer_prefix                 = var.customer_prefix
  environment                     = var.environment
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  description                     = "tgw for east-west inspection"
  dns_support                     = "disable"
  default_route_attachment_id     = module.vpc-transit-gateway-attachment-security.tgw_attachment_id
}

#
# Point the private route table default route to the TGW
#
resource "aws_route" "tgw1" {
  route_table_id         = module.base-vpc.private1_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}


resource "aws_route" "tgw2" {
  route_table_id         = module.base-vpc.private2_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.vpc-transit-gateway.tgw_id
}

#
# Security VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-security" {
  source                                          = "../../modules/tgw-attachment"
  access_key                                      = var.access_key
  secret_key                                      = var.secret_key
  aws_region                                      = var.aws_region
  customer_prefix                                 = var.customer_prefix
  environment                                     = var.environment
  vpc_name                                        = var.vpc_name_security
  transit_gateway_id                              = module.vpc-transit-gateway.tgw_id
  subnet_ids                                      = [ module.private1-subnet-tgw.id, module.private2-subnet-tgw.id ]
  transit_gateway_default_route_table_propogation = "false"
  vpc_id                                          = module.base-vpc.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "security" {
  transit_gateway_id = module.vpc-transit-gateway.tgw_id
  tags = {
    Name = "${var.customer_prefix}-${var.environment}-Security VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "security" {
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-security.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route_security_default" {
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west.tgw_attachment_id
}

resource "aws_ec2_transit_gateway_route" "tgw_route_security_cidr" {
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.security.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east.tgw_attachment_id
}

#
# East VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-east" {
  source                                          = "../../modules/tgw-attachment"
  access_key                                      = var.access_key
  secret_key                                      = var.secret_key
  aws_region                                      = var.aws_region
  customer_prefix                                 = var.customer_prefix
  environment                                     = var.environment
  vpc_name                                        = var.vpc_name_east
  transit_gateway_id                              = module.vpc-transit-gateway.tgw_id
  subnet_ids                                      = [ module.subnet-east.id ]
  transit_gateway_default_route_table_propogation = "false"
  vpc_id                                          = module.vpc-east.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "east" {
  transit_gateway_id = module.vpc-transit-gateway.tgw_id
    tags = {
      Name = "${var.customer_prefix}-${var.environment}-East VPC TGW Route Table"
  }
}
resource "aws_ec2_transit_gateway_route_table_association" "east" {
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.east.id
}
resource "aws_ec2_transit_gateway_route" "tgw_route_east_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.east.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-security.tgw_attachment_id
}
resource "aws_ec2_transit_gateway_route" "tgw_route_east_cidr" {
  destination_cidr_block         = var.vpc_cidr_east
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.east.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-east.tgw_attachment_id
}

#
# West VPC Transit Gateway Attachment, Route Table and Routes
#
module "vpc-transit-gateway-attachment-west" {
  source                          = "../../modules/tgw-attachment"
  access_key                      = var.access_key
  secret_key                      = var.secret_key
  aws_region                      = var.aws_region
  customer_prefix                 = var.customer_prefix
  environment                     = var.environment
  vpc_name                        = var.vpc_name_west
  transit_gateway_id              = module.vpc-transit-gateway.tgw_id
  subnet_ids                      = [ module.subnet-west.id ]
  transit_gateway_default_route_table_propogation = "false"
  vpc_id                          = module.vpc-west.vpc_id
}

resource "aws_ec2_transit_gateway_route_table" "west" {
  transit_gateway_id = module.vpc-transit-gateway.tgw_id
  tags = {
    Name = "${var.customer_prefix}-${var.environment}-West VPC TGW Route Table"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "west" {
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west.tgw_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.west.id
}

resource "aws_ec2_transit_gateway_route" "tgw_route_west" {
  destination_cidr_block         = var.vpc_cidr_west
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.west.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-west.tgw_attachment_id
}

resource "aws_ec2_transit_gateway_route" "tgw_route_west_default" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.west.id
  transit_gateway_attachment_id  = module.vpc-transit-gateway-attachment-security.tgw_attachment_id
}


resource "aws_default_route_table" "route_security" {
  default_route_table_id = module.base-vpc.vpc_main_route_table_id
  tags = {
    Name = "default table for security vpc (unused)"
  }
}

#
# Private 1 and 2 subnets that are connected to the TGW
# These route tables point to the ENI of the ACTIVE Fortigate
#
module "private1-subnet-tgw" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.base-vpc.vpc_id
  availability_zone          = var.availability_zone_1
  subnet_cidr                = var.private1_subnet_tgw_cidr
  subnet_description         = var.private1_tgw_description
}

module "private1_tgw_route_table" {
  source                     = "../../modules/route_table"
  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  vpc_id                     = module.base-vpc.vpc_id
  eni_route                  = 1
  eni_id                     = module.fortigate_1.network_private_interface_id
  route_description          = "Private 1 TGW Route Table"
}

module "private1_tgw_route_table_association" {
  source                     = "../../modules/route_table_association"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  subnet_ids                 = module.private1-subnet-tgw.id
  route_table_id             = module.private1_tgw_route_table.id
}

module "private2-subnet-tgw" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.base-vpc.vpc_id
  availability_zone          = var.availability_zone_2
  subnet_cidr                = var.private2_subnet_tgw_cidr
  subnet_description         = var.private2_tgw_description
}

module "private2_tgw_route_table" {
  source                     = "../../modules/route_table"
  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  vpc_id                     = module.base-vpc.vpc_id
  eni_route                  = 1
  eni_id                     = module.fortigate_1.network_private_interface_id
  route_description          = "Private 2 TGW Route Table"
}

module "private2_tgw_route_table_association" {
  source                     = "../../modules/route_table_association"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  subnet_ids                 = module.private2-subnet-tgw.id
  route_table_id             = module.private2_tgw_route_table.id
}

module "sync-subnet-1" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.base-vpc.vpc_id
  availability_zone          = var.availability_zone_1
  subnet_cidr                = var.sync_subnet_cidr_1
  subnet_description         = var.sync_description_1
}

module "sync-subnet-2" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.base-vpc.vpc_id
  availability_zone          = var.availability_zone_2
  subnet_cidr                = var.sync_subnet_cidr_2
  subnet_description         = var.sync_description_2
}

module "ha-subnet-1" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.base-vpc.vpc_id
  availability_zone          = var.availability_zone_1
  subnet_cidr                = var.ha_subnet_cidr_1
  subnet_description         = var.ha_description_1
  public_route               = 1
  public_route_table_id      = module.base-vpc.public_route_table_id
}

module "ha-subnet-2" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.base-vpc.vpc_id
  availability_zone          = var.availability_zone_2
  subnet_cidr                = var.ha_subnet_cidr_2
  subnet_description         = var.ha_description_2
  public_route               = 1
  public_route_table_id      = module.base-vpc.public_route_table_id
}

#
# VPC Endpoint for AWS API Calls
#
module "vpc_s3_endpoint" {
  source                     = "../../modules/vpc_endpoints"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  vpc_id                     = module.base-vpc.vpc_id
  route_table_id             = [ module.base-vpc.public_route_table_id ]
}

#
# East VPC
#
module "vpc-east" {
  source = "../../modules/vpc"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  vpc_name                   = var.vpc_name_east
  customer_prefix            = var.customer_prefix
  vpc_cidr                   = var.vpc_cidr_east
}

module "subnet-east" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.vpc-east.vpc_id
  availability_zone          = var.availability_zone_1
  subnet_cidr                = var.vpc_cidr_east
  subnet_description         = "east"
}

#
# Default route table that is created with the east VPC. We just need to add a default route
# that points to the TGW Attachment
#
resource "aws_default_route_table" "route_east" {
  default_route_table_id = module.vpc-east.vpc_main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = module.vpc-transit-gateway.tgw_id
  }
  tags = {
    Name = "default table for vpc east"
  }
}

module "rta-east" {
  source = "../../modules/route_table_association"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = "${var.customer_prefix}-east"
  subnet_ids                 = module.subnet-east.id
  route_table_id             = module.vpc-east.vpc_main_route_table_id

}

#
# West VPC
#
module "vpc-west" {
  source = "../../modules/vpc"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  vpc_name                   = var.vpc_name_west
  customer_prefix            = var.customer_prefix
  vpc_cidr                   = var.vpc_cidr_west

}

module "subnet-west" {
  source = "../../modules/subnet"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = var.customer_prefix
  vpc_id                     = module.vpc-west.vpc_id
  availability_zone          = var.availability_zone_1
  subnet_cidr                = var.vpc_cidr_west
  subnet_description         = "west"
}
#
# Default route table that is created with the west VPC. We just need to add a default route
# that points to the TGW Attachment
#
resource "aws_default_route_table" "route_west" {
  default_route_table_id = module.vpc-west.vpc_main_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = module.vpc-transit-gateway.tgw_id
  }
  tags = {
    Name = "default table for vpc west"
  }
}

module "rta-west" {
  source = "../../modules/route_table_association"

  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  environment                = var.environment
  customer_prefix            = "${var.customer_prefix}-west"
  subnet_ids                 = module.subnet-west.id
  route_table_id             = module.vpc-west.vpc_main_route_table_id
}

#
# Fortigate HA Pair and IAM Profiles
#
module "iam_profile" {
  source = "../../modules/fortigate_ha_instance_iam_role"

  access_key                  = var.access_key
  secret_key                  = var.secret_key
  aws_region                  = var.aws_region
  customer_prefix             = var.customer_prefix
  environment                 = var.environment
}

module "fortigate_1" {
  source                      = "../../modules/fortigate_ha_byol"

  access_key                  = var.access_key
  secret_key                  = var.secret_key
  aws_region                  = var.aws_region
  availability_zone           = var.availability_zone_1
  customer_prefix             = var.customer_prefix
  environment                 = var.environment
  public_subnet_id            = module.base-vpc.public1_subnet_id
  public_ip_address           = var.public1_ip_address
  private_subnet_id           = module.base-vpc.private1_subnet_id
  private_ip_address          = var.private1_ip_address
  sync_subnet_id              = module.sync-subnet-1.id
  sync_ip_address             = var.sync_subnet_ip_address_1
  ha_subnet_id                = module.ha-subnet-1.id
  ha_ip_address               = var.ha_subnet_ip_address_1
  aws_fgtbyol_ami             = data.aws_ami.fortigate_byol.id
  keypair                     = var.keypair
  fgt_instance_type           = var.fortigate_instance_type
  fortigate_instance_name     = var.fortigate_instance_name_1
  enable_public_ips           = var.enable_fortigate_public_ip
  enable_mgmt_public_ips      = var.enable_fortigate_management_public_ip
  security_group_private_id   = module.allow_private_subnets.id
  security_group_public_id    = module.allow_public_subnets.id
  acl                         = var.acl
  fgt_byol_license            = var.fgt_byol_1_license
  spoke1_cidr                 = var.vpc_cidr_east
  spoke2_cidr                 = var.vpc_cidr_west
  fgt_priority                = "255"
  fgt_ha_password             = var.fgt_ha_password
  fgt_admin_password          = var.fgt_admin_password
  sync2_ip_address            = var.sync_subnet_ip_address_2
  fortigate_hostname          = var.fortigate_hostname_1
  public_subnet_cidr          = var.public_subnet_cidr1
  private_subnet_cidr         = var.private_subnet_cidr_1
  sync_subnet_cidr            = var.sync_subnet_cidr_1
  ha_subnet_cidr              = var.ha_subnet_cidr_1
  iam_instance_profile_id     = module.iam_profile.id
}

module "fortigate_2" {
  source                      = "../../modules/fortigate_ha_byol"

  access_key                  = var.access_key
  secret_key                  = var.secret_key
  aws_region                  = var.aws_region
  availability_zone           = var.availability_zone_2
  customer_prefix             = var.customer_prefix
  environment                 = var.environment
  public_subnet_id            = module.base-vpc.public2_subnet_id
  public_ip_address           = var.public2_ip_address
  private_subnet_id           = module.base-vpc.private2_subnet_id
  private_ip_address          = var.private2_ip_address
  sync_subnet_id              = module.sync-subnet-2.id
  sync_ip_address             = var.sync_subnet_ip_address_2
  ha_subnet_id                = module.ha-subnet-2.id
  ha_ip_address               = var.ha_subnet_ip_address_2
  aws_fgtbyol_ami             = data.aws_ami.fortigate_byol.id
  keypair                     = var.keypair
  fgt_instance_type           = var.fortigate_instance_type
  fortigate_instance_name     = var.fortigate_instance_name_2
  enable_public_ips           = var.enable_fortigate_public_ip
  enable_mgmt_public_ips      = var.enable_fortigate_management_public_ip
  security_group_private_id   = module.allow_private_subnets.id
  security_group_public_id    = module.allow_public_subnets.id
  acl                         = var.acl
  fgt_byol_license            = var.fgt_byol_2_license
  spoke1_cidr                 = var.vpc_cidr_east
  spoke2_cidr                 = var.vpc_cidr_west
  fgt_priority                = "100"
  fgt_ha_password             = var.fgt_ha_password
  fgt_admin_password          = var.fgt_admin_password
  sync2_ip_address            = var.sync_subnet_ip_address_1
  fortigate_hostname          = var.fortigate_hostname_2
  public_subnet_cidr          = var.public_subnet_cidr2
  private_subnet_cidr         = var.private_subnet_cidr_2
  sync_subnet_cidr            = var.sync_subnet_cidr_2
  ha_subnet_cidr              = var.ha_subnet_cidr_2
  iam_instance_profile_id     = module.iam_profile.id
}

#
# Optional Linux Instances from here down
#
# Linux Instance that are added on to the East and West VPCs for testing EAST->West Traffic
#
# Endpoint AMI to use for Linux Instances. Just added this on the end, since traffic generating linux instances
# would not make it to a production template.
#
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200729"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

#
# EC2 Endpoint Resources
#

#
# Security Groups are VPC specific, so an "ALLOW ALL" for each VPC
#
module "ec2-east-sg" {
  source = "../../modules/security_group"
  access_key           = var.access_key
  secret_key           = var.secret_key
  aws_region           = var.aws_region
  vpc_id               = module.vpc-east.vpc_id
  name                 = var.ec2_sg_name
  ingress_to_port         = 0
  ingress_from_port       = 0
  ingress_protocol        = "-1"
  ingress_cidr_for_access = "0.0.0.0/0"
  egress_to_port          = 0
  egress_from_port        = 0
  egress_protocol         = "-1"
  egress_cidr_for_access = "0.0.0.0/0"
  customer_prefix      = var.customer_prefix
  environment          = var.environment
}


module "ec2-west-sg" {
  source = "../../modules/security_group"
  access_key           = var.access_key
  secret_key           = var.secret_key
  aws_region           = var.aws_region
  vpc_id               = module.vpc-west.vpc_id
  name                 = var.ec2_sg_name
  ingress_to_port         = 0
  ingress_from_port       = 0
  ingress_protocol        = "-1"
  ingress_cidr_for_access = "0.0.0.0/0"
  egress_to_port          = 0
  egress_from_port        = 0
  egress_protocol         = "-1"
  egress_cidr_for_access = "0.0.0.0/0"
  customer_prefix      = var.customer_prefix
  environment          = var.environment
}

#
# IAM Profile for linux instance
#
module "linux_iam_profile" {
  source = "../../modules/ec2_instance_iam_role"

  access_key                  = var.access_key
  secret_key                  = var.secret_key
  aws_region                  = var.aws_region
  customer_prefix             = var.customer_prefix
  environment                 = var.environment
}

#
# East Linux Instance for Generating East->West Traffic
#
module "aws_east_linux_instance" {
  source                     = "../../modules/endpoints"
  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  ami_id                     = data.aws_ami.ubuntu.id
  vpc_id                     = module.vpc-east.vpc_id
  subnet_id                  = module.subnet-east.id
  private_ip                 = "192.168.0.11"
  cidr_for_access            = var.cidr_for_access
  instance_type              = var.linux_instance_type
  key_pair                   = var.keypair
  instance_count             = 1
  public_ip                  = false
  security_group             = module.ec2-east-sg.id
  iam_instance_profile_id    = module.linux_iam_profile.id
  description                = "East Linux Instance"
  enable_linux_instances     = var.enable_linux_instances
}

#
# West Linux Instance for Generating West->East Traffic
#
module "aws_west_linux_instance" {
  source                     = "../../modules/endpoints"
  access_key                 = var.access_key
  secret_key                 = var.secret_key
  aws_region                 = var.aws_region
  customer_prefix            = var.customer_prefix
  environment                = var.environment
  ami_id                     = data.aws_ami.ubuntu.id
  vpc_id                     = module.vpc-west.vpc_id
  subnet_id                  = module.subnet-west.id
  private_ip                 = "192.168.1.11"
  cidr_for_access            = var.cidr_for_access
  instance_type              = var.linux_instance_type
  key_pair                   = var.keypair
  instance_count             = 1
  public_ip                  = false
  security_group             = module.ec2-west-sg.id
  iam_instance_profile_id    = module.linux_iam_profile.id
  description                = "West Linux Instance"
  enable_linux_instances     = var.enable_linux_instances
}
