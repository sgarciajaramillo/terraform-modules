credentials_file_path   = "<CREDENTIALS>"
project                 = "<GCP_PROJECT>"
region                  = "us-central1"
zone                    = "us-central1-c"
machine                 = "n1-standard-4"
image                   = "<IMAGE>"
license_file            = "<LICENSE_FILE>"
# VPCs
vpcs                    = ["public-vpc", "private-vpc"]
# subnet module
subnets                 = ["public-subnet", "private-subnet"]
subnet_cidrs            = ["172.18.0.0/24", "172.18.1.0/24"]
# Firewall module
fw_ingress              = ["public-fw-ingress", "private-fw-ingress"]
fw_egress               = ["public-fw-egress", "private-fw-egress"]
