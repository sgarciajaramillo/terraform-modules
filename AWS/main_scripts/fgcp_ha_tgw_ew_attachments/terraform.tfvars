access_key                  = ""
secret_key                  = ""

aws_region                  = "us-west-2"
customer_prefix             = "mdw"
environment                 = "dev"
availability_zone_1         = "us-west-2a"
availability_zone_2         = "us-west-2c"
vpc_cidr_security           = "10.0.0.0/16"
vpc_cidr_east               = "192.168.0.0/24"
vpc_cidr_west               = "192.168.1.0/24"

vpc_name_security           = "security"
vpc_name_east               = "east"
vpc_name_west               = "west"


public_subnet_cidr1         = "10.0.1.0/24"
public1_ip_address          = "10.0.1.10"
public1_description         = "public1-subnet-az1"

public_subnet_cidr2         = "10.0.10.0/24"
public2_ip_address          = "10.0.10.10"
public2_description         = "public2-subnet-az2"

private1_subnet_tgw_cidr     = "10.0.6.0/24"
private1_tgw_description     = "private-tgw-subnet-az1"

private2_subnet_tgw_cidr     = "10.0.60.0/24"
private2_tgw_description     = "private-tgw-subnet-az2"

private_subnet_cidr_1       = "10.0.2.0/24"
private1_ip_address         = "10.0.2.10"
private1_description        = "private1-subnet-az1"

private_subnet_cidr_2       = "10.0.20.0/24"
private2_ip_address         = "10.0.20.10"
private2_description        = "private2-subnet-az2"

sync_subnet_cidr_1          = "10.0.4.0/24"
sync_subnet_ip_address_1    = "10.0.4.10"
sync_description_1          = "sync-subnet-az1"

sync_subnet_cidr_2          = "10.0.40.0/24"
sync_subnet_ip_address_2    = "10.0.40.10"
sync_description_2          = "sync-subnet-az2"

ha_subnet_cidr_1            = "10.0.5.0/24"
ha_subnet_ip_address_1      = "10.0.5.10"
ha_description_1            = "hamgmt-subnet-az1"

ha_subnet_cidr_2            = "10.0.50.0/24"
ha_subnet_ip_address_2      = "10.0.50.10"
ha_description_2            = "hamgmt-subnet-az2"

keypair                     = "mdw-key-oregon"
cidr_for_access             = "0.0.0.0/0"
fortigate_instance_type     = "c5n.xlarge"
fortigate_instance_name_1   = "Fortigate One HA Pair"
fortigate_instance_name_2   = "Fortigate Two HA Pair"
public_ip                   = 1
disable_public_ip           = 0
mgmt_public_ip              = 1
disable_mgmt_public_ip      = 0
s3_license_bucket           = "mdw-license-bucket"
acl                         = "private"
fortigate_ami_string        = "FortiGate-VM64-AWS build1637 (6.4.1) GA*"
fgt_byol_1_license          = "./fgt1-license.lic"
fgt_byol_2_license          = "./fgt2-license.lic"
fgt_ha_password             = "pocpassword727"
fgt_admin_password          = "Texas4me!"
fortigate_hostname_1        = "fgt-active"
fortigate_hostname_2        = "fgt-passive"

#
# Endpoints info
#
sg_name                        = "ec2"
linux_instance_type            = "t2.micro"


