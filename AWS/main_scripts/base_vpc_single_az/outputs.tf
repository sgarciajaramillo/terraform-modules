output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The VPC Id of the newly created VPC."
}

output "public_subnet_id" {
  value = module.public-subnet.id
  description = "The Subnet Id of the newly created Public Subnet"
}

output "private_subnet_id" {
  value = module.private-subnet.id
    description = "The Subnet Id of the newly created Private Subnet"
}
