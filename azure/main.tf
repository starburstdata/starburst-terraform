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
  count    = var.ex_resource_group == "" ? 1 : 0 # Only create a RG if one hasn't been specified by the user

  name     = local.azure_rg
  location = var.region

  tags     = local.common_tags
}

# Create a Storage Account
module storage {
    source                    = "../modules/azure-storage"

    storage_acc_name          = local.storage_name
    resource_group            = local.resource_group
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

    resource_group    = local.resource_group
    location          = var.region
    ex_vnet_name      = var.ex_vnet_name
    ex_subnet_name    = var.ex_subnet_name
    vnet_name         = local.vpc_name
    address_space     = ["10.1.0.0/16"]
    tags              = local.common_tags

    create_vnet       = var.create_vnet
}

module k8s {
    source                = "../modules/azure-aks"

    resource_group        = local.resource_group
    location              = var.region
    cluster_name          = local.cluster_name
    dns_prefix            = "aks"
    subnet_id             = module.vnet.subnet_id[0]
    primary_node_pool     = var.primary_node_pool
    worker_node_pool      = var.worker_node_pool
    primary_node_vm       = var.primary_node_type
    worker_node_vm        = var.worker_node_type
    primary_pool_size     = var.primary_pool_size
    worker_pool_min_size  = var.worker_pool_min_size
    worker_pool_max_size  = var.worker_pool_max_size

    tags              = local.common_tags

    # Node pool flags
    use_ondemand      = var.use_ondemand
    use_spot          = var.use_spot
    node_taint_key    = var.node_taint_key
    node_taint_value  = var.node_taint_value

    create_k8s        = var.create_k8s

    depends_on        = [module.vnet]
}

# The db module has been moved to Kubernetes
# module db { }

# Update the local kubectl config
resource "null_resource" "configure_kubectl" {
  count           = var.create_k8s ? 1 : 0

  provisioner "local-exec" {
    command = "az aks get-credentials --subscription ${local.subscription_id} --resource-group ${local.resource_group} --name ${module.k8s.cluster_name} --overwrite-existing"
    interpreter = ["bash","-c"]
  }

  depends_on        = [module.k8s]
}

data "external" "worker_nodes" {
  count   = 1
  program = ["bash", "-c", "kubectl get nodes --selector='starburstpool=${var.worker_node_pool}' -o jsonpath='{.items[0].status.allocatable}'"]

  depends_on        = [module.k8s,null_resource.configure_kubectl]
}

data "external" "primary_nodes" {
  count   = 1
  program = ["bash", "-c", "kubectl get nodes --selector='starburstpool=${var.primary_node_pool}' -o jsonpath='{.items[0].status.allocatable}'"]

  depends_on        = [module.k8s,null_resource.configure_kubectl]
}
