terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = ">= 2.46.1"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.0.0"
        }
        helm        = ">= 2.0.1"
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = ">= 1.11.2"
        }
    }
}        

# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Provider
provider "postgresql" {
    host            = module.db.db_ingress
    port            = module.db.db_port
    database        = module.db.db_name
    username        = module.db.primary_db_user
    password        = module.db.primary_db_password
    connect_timeout = 15
    #expected_version = "13"
    sslmode         = "disable"
}

data "azurerm_client_config" "current" { }

data "azurerm_kubernetes_cluster" "default" {
  name                = module.k8s.cluster_name
  resource_group_name = azurerm_resource_group.default.name

  depends_on          = [module.k8s]
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
}

provider helm {
    kubernetes {
        host                   = data.azurerm_kubernetes_cluster.default.kube_config.0.host
        client_certificate     = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_certificate)
        client_key             = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.client_key)
        cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.default.kube_config.0.cluster_ca_certificate)
    }
}