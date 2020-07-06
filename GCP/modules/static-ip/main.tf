# Create Static Cluster IP
resource "google_compute_address" "static" {
  name = "terraform-cluster-ip-${var.random_string}"
}
