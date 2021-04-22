output azure-infrastructure-details {
  value = tolist([
    var.create_k8s ?              "aks_cluster_name     = ${module.k8s.cluster_name}" : "",
    var.ex_resource_group == "" ? "resource_group       = ${local.resource_group}" : "Using existing RG for deployment: ${local.resource_group}",
    var.create_vnet ?             "vnet_name            = ${module.vnet.vnet_name}" : "Using existing VNet for deployment: ${var.ex_vnet_name}",
    var.create_bucket ?           "storage_account      = ${module.storage.storage_account_name}" : "No storage acount will be deployed"
  ])
}

output debug-infrastructure {
    value = var.debug_this ? tolist([
        var.create_vnet ?   "subnet_id          = ${module.vnet.subnet_id[0]}" : "",
        var.create_vnet ?   "vnet_id            = ${module.vnet.vnet_id}" : "",
        var.create_k8s ?    "cluster_id         = ${module.k8s.cluster_id}" : "",
        var.create_bucket ? "storage_account    = ${module.storage.storage_account_id}" : ""
    ]) : null
}

output kubectl-profile {
  value = tolist([
    "az aks get-credentials --subscription ${local.subscription_id} --resource-group ${local.azure_rg} --name ${module.k8s.cluster_name} --overwrite-existing"
  ])
}