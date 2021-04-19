output azure-infrastructure-details {
  value = tolist([
    var.create_k8s ?    "aks_cluster_name     = ${module.k8s.cluster_name}" : "",
    var.create_vpc ?    "vnet_name            = ${module.vnet.vnet_name}" : "",
    #var.create_rds ?    "rds                  = ${module.cloud_sql.identifier}" : "",
    var.create_bucket ? "storage_account      = ${module.storage.storage_account_name}" : ""
  ])
}

output debug-infrastructure {
    value = var.debug_this ? tolist([
        var.create_vpc ?    "subnet_id          = ${module.vnet.subnet_id[0]}" : "",
        var.create_vpc ?    "vnet_id            = ${module.vnet.vnet_id}" : "",
        var.create_k8s ?    "cluster_id         = ${module.k8s.cluster_id}" : "",
        var.create_bucket ? "storage_account    = ${module.storage.storage_account_id}" : ""
    ]) : null
}
