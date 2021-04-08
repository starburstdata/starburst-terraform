# Input variables
variable cluster_name { }
variable location { }
variable primary_node_pool { }
variable worker_node_pool { }
variable primary_node_vm { }
variable worker_node_vm { }
variable primary_pool_size { }
variable worker_pool_min_size { }
variable worker_pool_max_size { }
variable preemptible { }
variable vpc { }
variable create_k8s { }
variable tags { }

# Create resources
resource "google_container_cluster" "primary_gke" {
  count    = var.create_k8s ? 1 : 0

  name     = var.cluster_name
  location = var.location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  network                  = var.vpc
  
  resource_labels          = var.tags
  
  ip_allocation_policy {
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  count    = var.create_k8s ? 1 : 0
  
  name                = var.primary_node_pool
  location            = var.location
  cluster             = google_container_cluster.primary_gke[0].name
  initial_node_count  = var.primary_pool_size

    node_config {
        machine_type = var.primary_node_vm

        metadata = {
            disable-legacy-endpoints = "true"
        }

        labels = {
            starburstpool = var.primary_node_pool
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}

resource "google_container_node_pool" "worker_nodes" {
  count    = var.create_k8s ? 1 : 0
  
  name               = var.worker_node_pool
  location           = var.location
  cluster            = google_container_cluster.primary_gke[0].name
  initial_node_count = var.worker_pool_min_size

    autoscaling {
        min_node_count = var.worker_pool_min_size
        max_node_count = var.worker_pool_max_size
    }

    node_config {
        preemptible  = var.preemptible # true or false
        machine_type = var.worker_node_vm

        metadata = {
            disable-legacy-endpoints = "true"
        }

        labels = {
            starburstpool = var.worker_node_pool
        }

        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
    }
}


# Outputs
output name {
  description = "The name of the cluster master."
  value       = google_container_cluster.primary_gke[0].name
}

output endpoint {
  description = "The IP address of the cluster master."
  value       = google_container_cluster.primary_gke[0].endpoint
}

output client_certificate {
  description = "Public certificate used by clients to authenticate to the cluster endpoint."
  value       = base64decode(google_container_cluster.primary_gke[0].master_auth[0].client_certificate)
  sensitive   = true
}

output client_key {
  description = "Private key used by clients to authenticate to the cluster endpoint."
  value       = base64decode(google_container_cluster.primary_gke[0].master_auth[0].client_key)
  sensitive   = true
}

output cluster_ca_certificate {
  description = "The public certificate that is the root of trust for the cluster."
  value       = base64decode(google_container_cluster.primary_gke[0].master_auth[0].cluster_ca_certificate)
  sensitive   = true
}