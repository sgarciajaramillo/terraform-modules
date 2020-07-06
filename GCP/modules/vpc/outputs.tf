# Public VPC Network
# output "public_network" {
#   value = "${google_compute_network.vpc[0].name}"
# }

# # Private VPC Network
# output "private_network" {
#   value = "${google_compute_network.vpc[1].name}"
# }

# # Sync VPC Network
# output "sync_network" {
#   value = "${google_compute_network.vpc[2].name}"
# }

# # Management VPC Network
# output "mgmt_network" {
#   value = "${google_compute_network.vpc[3].name}"
# }

# All VPCs
output "vpc_networks" {
  value       = google_compute_network.vpc[*].name
  description = "VPCs"
}
