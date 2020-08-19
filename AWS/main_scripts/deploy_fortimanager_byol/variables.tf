variable "access_key" {}
variable "secret_key" {}

variable "aws_region" {
  description = "The AWS region to use"
  default = "us-east-1"
}
variable "customer_prefix" {
  description = "Customer Prefix to apply to all resources"
}
variable "environment" {
  description = "The Tag Environment to differentiate prod/test/dev"
}
variable "availability_zone" {
  description = "Availability Zone 1 for VPC"
}
variable vpc_id {
  description = "VPC ID to deploy Fortimanager"
}
variable subnet_id {
  description = "Subnet ID to deploy Fortimanager"
}
variable ip_address {
  description = "IP Address for Public Interface of Fortimanager"
}
variable keypair {
  description = "Keypair used to login to Fortimanager"
}
variable fortimanager_instance_type {
  description = "EC2 Instance Type of Fortimanager"
}
variable fortimanager_instance_name {
  description = "Instance name of Fortimanager"
}
variable "fmgr_ami_string" {
  description = "Fortigate AMI Search String for booting Fortigate Instance"
}
variable "fmgr_byol_license" {
  description = "Fortigate license file"
}