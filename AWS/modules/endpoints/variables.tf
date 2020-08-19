variable "access_key" {}
variable "secret_key" {}

variable "aws_region" {
  description = "Provide the region to use"
}
variable "customer_prefix" {
  description = "Customer Prefix to apply to all resources"
}
variable "environment" {
  description = "The Tag Environment in the S3 tag"
}
variable "ami_id" {
  description = "AMI ID for the new instance"
}
variable "vpc_id" {
  description = "Provide the VPC ID for the instance"
}
variable "subnet_id" {
  description = "Provide the ID for the subnet"
}
variable "private_ip" {
  description = "Private IP associated with Instance"
}
variable "key_pair" {
  description = "Key Pair associated with Instance"
}
variable "cidr_for_access" {
  description = "CIDR to use for security group access"
}
variable "instance_type" {
  description = "Instance type for endpoint"
}
variable "instance_count" {
  description = "Instance count"
}
variable "public_ip" {
  description = "Boolean - Associate Public IP address"
  type = bool
  default = false
}
variable "security_group" {
  description = "Security Group for the instance"
}
variable "iam_instance_profile_id" {
  description = "Linux IAM Instance Profile ID"
}
variable "description" {
  description = "EC2 Instance Description"
}
variable "enable_linux_instances" {
  description = "Boolean to enable creation of Linux Endpoints"
}