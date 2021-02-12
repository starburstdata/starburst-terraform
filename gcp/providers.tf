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
    host            = var.create_rds ? module.cloud_sql.public_ip_address : null
    port            = var.create_rds ? module.cloud_sql.database_port : null
    database        = var.create_rds ? module.cloud_sql.primary_database : null
    username        = var.create_rds ? module.cloud_sql.primary_db_user : null
    password        = var.create_rds ? module.cloud_sql.primary_db_password : null
    connect_timeout = var.create_rds ? 15 : null
}

data "google_client_config" "default" { }

data "google_container_cluster" "my_cluster" {
  name     = module.gke.name
  location = var.zone
}

provider "kubernetes" {
    host                   = "https://${module.gke.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = module.gke.cluster_ca_certificate
}

provider helm {
    kubernetes {
        host                   = "https://${module.gke.endpoint}"
        token                  = data.google_client_config.default.access_token
        cluster_ca_certificate = module.gke.cluster_ca_certificate
    }
}