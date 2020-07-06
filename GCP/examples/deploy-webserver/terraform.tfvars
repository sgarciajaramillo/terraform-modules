credentials_file_path   = "<CREDENTIALS>"
project                 = "<GCP_PROJECT>"
region                  = "us-central1"
zone                    = "us-central1-c"
machine                 = "n1-standard-4"
image                   = "projects/ubuntu-os-cloud/global/images/ubuntu-1604-xenial-v20200702"
# VPCs
vpcs                    = ["public-vpc"]
# subnet module
subnets                 = ["public-subnet"]
subnet_cidrs            = ["172.20.0.0/24"]
# Firewall module
fw_ingress              = ["public-fw-ingress"]
fw_egress               = ["public-fw-egress"]
