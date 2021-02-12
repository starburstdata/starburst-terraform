# Input variables
variable vpc_name { }
variable region { }

# Resource creation
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
}

resource "google_compute_firewall" "allow_ssh" {
  name        = "allow-ssh"
  network     = google_compute_network.vpc.name
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh-enabled"]
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  ip_version    = "IPV4"
  prefix_length = 20
  network       = google_compute_network.vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Output variables
output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "VPC Name"
}

output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "VPC ID"
}
