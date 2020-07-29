provider "aws" {
  region     = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_eip" "EIP" {
  count                 = var.enable_public_ips
  vpc                   = true
  network_interface     = aws_network_interface.public_eni.id
  tags = {
    Name            = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}"
    Environment     = var.environment
  }
}

resource "aws_eip" "HA_EIP" {
  count                 = var.enable_mgmt_public_ips
  vpc                   = true
  network_interface     = aws_network_interface.ha_eni.id
  tags = {
    Name            = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}"
    Environment     = var.environment
  }
}

data "aws_subnet" "public_id" {
  id = var.public_subnet_id
}

data "aws_subnet" "private_id" {
  id = var.private_subnet_id
}

data "aws_subnet" "private2_id" {
  id = var.private2_subnet_id
}

data "aws_subnet" "mgmt_id" {
  id = var.ha_subnet_id
}

data "template_file" "fgt_userdata" {
  template = file("./fgt-userdata.tpl")

  vars = {
    fgt_id               = var.fortigate_hostname
    Port1IP              = aws_network_interface.public_eni.private_ip
    Port2IP              = aws_network_interface.private_eni.private_ip
    Port3IP              = aws_network_interface.sync_eni.private_ip
    Port4IP              = aws_network_interface.ha_eni.private_ip
    PrivateSubnet        = data.aws_subnet.private_id.cidr_block
    Private2Subnet       = data.aws_subnet.private2_id.cidr_block
    spoke1_cidr          = var.spoke1_cidr
    spoke2_cidr          = var.spoke2_cidr
    mgmt_cidr            = data.aws_subnet.mgmt_id.cidr_block
    mgmt_gw              = cidrhost(data.aws_subnet.mgmt_id.cidr_block, 1)
    tgw_gw               = cidrhost(var.from_cidr, 1)
    fgt_priority         = var.fgt_priority
    fgt_ha_password      = var.fgt_ha_password
    fgt_byol_license     = file("${path.module}/${var.fgt_byol_license}")
    fgt-remote-heartbeat = var.sync2_ip_address
    PublicSubnetRouterIP = cidrhost(data.aws_subnet.public_id.cidr_block, 1)
    public_subnet_mask   = cidrnetmask(var.public_subnet_cidr)
    private_subnet_mask  = cidrnetmask(var.private_subnet_cidr)
    sync_subnet_mask     = cidrnetmask(var.sync_subnet_cidr)
    hamgmt_subnet_mask   = cidrnetmask(var.ha_subnet_cidr)
    PrivateSubnetRouterIP = cidrhost(data.aws_subnet.private_id.cidr_block, 1)
    fgt_admin_password    = var.fgt_admin_password
  }
}

resource "aws_network_interface" "public_eni" {
  subnet_id                   = var.public_subnet_id
  private_ips                 = [ var.public_ip_address ]
  security_groups             = [ var.security_group_public_id ]
  source_dest_check           = false

  tags = {
    Name = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}-ENI_Public"
  }
}

resource "aws_network_interface" "private_eni" {
  subnet_id                   = var.private_subnet_id
  private_ips                 = [
    var.private_ip_address]
  security_groups             = [ var.security_group_private_id ]
  source_dest_check           = false

  tags = {
    Name = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}-ENI_Private"
  }
}

resource "aws_network_interface" "sync_eni" {
  subnet_id                   = var.sync_subnet_id
  private_ips                 = [
    var.sync_ip_address]
  security_groups             = [ var.security_group_public_id ]
  source_dest_check           = false

  tags = {
    Name = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}-ENI_Public"
  }
}

resource "aws_network_interface" "ha_eni" {
  subnet_id                   = var.ha_subnet_id
  private_ips                 = [
    var.ha_ip_address]
  security_groups             = [ var.security_group_private_id ]
  source_dest_check           = false

  tags = {
    Name = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}-ENI_Private"
  }
}

resource "aws_instance" "fortigate" {

  ami                         = var.aws_fgtbyol_ami
  instance_type               = var.fgt_instance_type
  availability_zone           = var.availability_zone
  key_name                    = var.keypair
  user_data                   = data.template_file.fgt_userdata.rendered
  iam_instance_profile        = var.iam_instance_profile_id
  network_interface {
    device_index = 0
    network_interface_id   = aws_network_interface.public_eni.id
  }
  network_interface {
    device_index = 1
    network_interface_id   = aws_network_interface.private_eni.id
  }
    network_interface {
    device_index = 2
    network_interface_id   = aws_network_interface.sync_eni.id
  }
  network_interface {
    device_index = 3
    network_interface_id   = aws_network_interface.ha_eni.id
  }
  tags = {
    Name            = "${var.customer_prefix}-${var.environment}-${var.fortigate_instance_name}"
    Environment     = var.environment
  }
}

