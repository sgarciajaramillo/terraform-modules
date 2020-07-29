# Subnet(s)
resource "google_compute_subnetwork" "subnet" {
  count         = length(var.subnets)
  name          = "terraform-${var.subnets[count.index]}-${var.random_string}"
  region        = var.region
  network       = var.vpcs[count.index]
  ip_cidr_range = var.subnet_cidrs[count.index]
}
