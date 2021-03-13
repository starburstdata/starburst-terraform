# Input variables
variable vpc_name { }
variable ex_vpc_id { }
variable region { }
variable create_vpc { }

# Resource creation
resource "google_compute_network" "vpc" {
  count                   = var.create_vpc ? 1 : 0

  name                    = var.vpc_name
}

resource "google_compute_firewall" "allow_ssh" {
  count                   = var.create_vpc ? 1 : 0

  name        = "allow-ssh"
  network     = google_compute_network.vpc[0].name
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh-enabled"]
}

resource "google_compute_global_address" "private_ip_address" {
  count                   = var.create_vpc ? 1 : 0

  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc[0].id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = var.create_vpc ? 1 : 0

  network                 = google_compute_network.vpc[0].id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[0].name]
}

# Output variables
output "vpc_name" {
  value       = var.create_vpc ? google_compute_network.vpc[0].name : var.ex_vpc_id
  description = "VPC Name"
}
