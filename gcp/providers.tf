terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "3.54.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.0.0"
        }
        helm        = "~> 2.0.1"
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = "1.11.1"
        }
    }
}

provider google {
    credentials = file(var.credentials)
    project     = var.project
    region      = var.region
    zone        = var.zone
}

# Provider
provider "postgresql" {
    host            = module.db.db_ingress
    port            = module.db.db_port
    database        = module.db.db_name
    username        = module.db.primary_db_user
    password        = module.db.primary_db_password
    connect_timeout = 15
    sslmode         = "disable"
}

data "google_client_config" "default" { }

data "google_container_cluster" "my_cluster" {
  name     = module.k8s.name
  location = var.zone
}

provider "kubernetes" {
    host                   = "https://${module.k8s.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.k8s.cluster_ca_certificate
}

provider helm {
    kubernetes {
        host                   = "https://${module.k8s.endpoint}"
        token                  = data.google_client_config.default.access_token
        cluster_ca_certificate = module.k8s.cluster_ca_certificate
    }
}