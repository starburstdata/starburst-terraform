# AWS Infrastructure to be deployed
#
# Ensure you either have set the symbolic links to the global variable files (../common/g_*)
# or you have copied these into this folder
#
# e.g.  ln -s ../common/g_data_sources.tf g_data_sources.tf
#       ln -s ../common/g_kubernetes_secrets.tf g_kubernetes_secrets.tf
#       ln -s ../common/g_variables.tf g_variables.tf
#

# Create an RG for this deployment
resource "azurerm_resource_group" "default" {
  name     = local.azure_rg
  location = var.region

  tags     = local.common_tags
}

# Create a Storage Account
module storage {
    source                    = "../modules/azure-storage"

    storage_acc_name          = local.storage_name
    resource_group            = azurerm_resource_group.default.name
    location                  = var.region
    account_tier              = "Standard"
    account_replication_type  = "LRS"

    storage_type              = "ADLS"
    client_object_id          = data.azurerm_client_config.current.object_id

    tags                      = local.common_tags

    create_bucket             = var.create_bucket
}

# Create a VNet in the new RG
module vnet {
    source            = "../modules/azure-vnet"

    resource_group    = azurerm_resource_group.default.name
    location          = var.region
    vnet_name         = local.vpc_name
    address_space     = ["10.1.0.0/16"]
    tags              = local.common_tags

    create_vpc        = var.create_vpc
}

module k8s {
    source            = "../modules/azure-aks"

    resource_group    = azurerm_resource_group.default.name
    location          = var.region
    cluster_name      = local.cluster_name
    dns_prefix        = "aks"
    subnet_id         = module.vnet.subnet_id[0]
    primary_node_pool = var.primary_node_pool
    worker_node_pool  = var.worker_node_pool
    primary_node_vm   = "Standard_D8s_v3"
    worker_node_vm    = "Standard_D4s_v3"

    tags              = local.common_tags

    create_k8s        = var.create_k8s

    depends_on        = [module.vnet]
}

# The db module has been moved to Kubernetes
# module db { }

# Update the local kubectl config
resource "null_resource" "configure_kubectl" {
  count           = var.create_k8s ? 1 : 0

  provisioner "local-exec" {
    command = "az aks get-credentials --resource-group ${azurerm_resource_group.default.name} --name ${module.k8s.cluster_name} --overwrite-existing"
    interpreter = ["bash","-c"]
  }

  depends_on        = [module.k8s]
}
