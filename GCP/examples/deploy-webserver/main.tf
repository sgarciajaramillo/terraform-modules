provider "google" {
  version     = "3.5.0"
  credentials = file(var.credentials_file_path)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

module "random" {
  source = "../../modules/random-generator"
}

module "vpc" {
  source = "../../modules/vpc"
  # Pass Variables
  vpcs = var.vpcs
  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "subnet" {
  source = "../../modules/subnet"

  # Pass Variables
  region       = var.region
  subnets      = var.subnets
  subnet_cidrs = var.subnet_cidrs
  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "firewall" {
  source = "../../modules/firewall"

  # Values fetched from the Modules
  random_string = module.random.random_string
  vpcs          = module.vpc.vpc_networks
}

module "static-ip" {
  source = "../../modules/static-ip"

  # Values fetched from the Modules
  random_string = module.random.random_string
}

module "instances" {
  source = "../../modules/nginx_instance"

  # Pass Variables
  zone    = var.zone
  machine = var.machine
  image   = var.image
  # Values fetched from the Modules
  random_string      = module.random.random_string
  public_vpc_network = module.vpc.vpc_networks[0]
  public_subnet      = module.subnet.subnets[0]
  static_ip          = module.static-ip.static_ip
}
