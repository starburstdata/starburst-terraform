terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "4.38.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.13.1"
        }
        helm        = ">= 2.7.0"
    }
}

provider google {
    credentials = file(var.credentials)
    project     = var.project
    region      = var.region
    zone        = var.zone
}

data "google_client_config" "default" { }

data "google_container_cluster" "my_cluster" {
  name     = module.k8s.name
  location = var.zone
  project  = var.project

  depends_on = [module.k8s]
}

provider "kubernetes" {
    host                   = "https://${module.k8s.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
}

provider helm {
    kubernetes {
        host                   = "https://${module.k8s.endpoint}"
        token                  = data.google_client_config.default.access_token
        cluster_ca_certificate = base64decode(data.google_container_cluster.my_cluster.master_auth[0].cluster_ca_certificate)
    }
}