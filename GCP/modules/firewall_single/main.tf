# Firewall Rules

resource "google_compute_firewall" "fw_ingress" {
  count   = length(var.vpcs)
  name    = "${var.fw_ingress[count.index]}-${var.random_string}"
  network = var.vpcs[count.index]
  allow {
    protocol = var.allow_all
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "fw_egress" {
  count   = length(var.vpcs)
  name    = "${var.fw_egress[count.index]}-${var.random_string}"
  network = var.vpcs[count.index]
  allow {
    protocol = var.allow_all
  }
  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}
