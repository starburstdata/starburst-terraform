terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "3.59.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
        helm        = ">= 2.0.1"
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = ">= 1.11.1"
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
  project  = var.project
}

provider "kubernetes" {
  #host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  #config_path = "~/.kube/config"
  #client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  #client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  #cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
  host                   = module.k8s.endpoint
  client_certificate     = base64decode(module.k8s.client_cert)
  client_key             = base64decode(module.k8s.client_key)
  cluster_ca_certificate = base64decode(module.k8s.ca_cert)

}

provider helm {
    kubernetes {
        #host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
        #config_path = "~/.kube/config"
        #client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
        #client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
        #cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
        host                   = module.k8s.endpoint
        client_certificate     = base64decode(module.k8s.client_cert)
        client_key             = base64decode(module.k8s.client_key)
        cluster_ca_certificate = base64decode(module.k8s.ca_cert)
    }
}