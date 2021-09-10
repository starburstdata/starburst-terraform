terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "= 2.50.0"
            configuration_aliases = [ azurerm.dns ]
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "= 2.0.2"
        }
        helm        = "= 2.0.2"
    }
}        

# Configure the Azure Provider with your current default subscription
provider "azurerm" {
  features {}
  # For usage attribution tracking
  partner_id          = var.partner_id
}

# Configure a second Azure Provider to match the subscription where your DNS zone is configured
# Note that if the user doesn't set this, the current default subscription is used
provider "azurerm" {
    features {}
    alias               = "dns"
    subscription_id     = var.dns_sub != "" ? var.dns_sub : data.azurerm_client_config.current.subscription_id
    # For usage attribution tracking
    partner_id          = var.partner_id
}

data "azurerm_client_config" "current" { }

data "azurerm_kubernetes_cluster" "default" {
  name                = module.k8s.cluster_name
  resource_group_name = local.resource_group

  depends_on          = [module.k8s]
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