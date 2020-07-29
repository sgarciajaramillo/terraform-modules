# Firewall Rules

# Public
resource "google_compute_firewall" "public_ingress" {
  name    = "public-ingress-${var.random_string}"
  network = var.public_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "public_egress" {
  name    = "public-egress-${var.random_string}"
  network = var.public_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}

# Private
resource "google_compute_firewall" "private_ingress" {
  name    = "private-ingress-${var.random_string}"
  network = var.private_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "private_egress" {
  name    = "private-egress-${var.random_string}"
  network = var.private_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}

# Sync
resource "google_compute_firewall" "sync_ingress" {
  name    = "sync-ingress-${var.random_string}"
  network = var.sync_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "sync_egress" {
  name    = "sync-egress-${var.random_string}"
  network = var.sync_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}

# Management
resource "google_compute_firewall" "mgmt_ingress" {
  name    = "mgmt-ingress-${var.random_string}"
  network = var.mgmt_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction     = "INGRESS"
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "mgmt_egress" {
  name    = "mgmt-egress-${var.random_string}"
  network = var.mgmt_vpc_network
  allow {
    protocol = var.allow_all
  }
  direction          = "EGRESS"
  destination_ranges = var.destination_ranges
}
