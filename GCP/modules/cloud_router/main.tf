# Cloud Router
# https://www.terraform.io/docs/providers/google/r/compute_router.html

resource "google_compute_router" "cloud_router" {
  name    = "${var.name}-cloud-router-${var.random_string}"
  region  = var.region
  network = var.vpc_network
}
