# Variables
variable resource_group { }
variable location { }
variable cluster_name { }
variable dns_prefix { }
variable subnet_id { }
variable primary_node_pool { }
variable worker_node_pool { }
variable primary_node_vm { }
variable worker_node_vm { }
variable primary_pool_size { }
variable worker_pool_min_size { }
variable worker_pool_max_size { }
variable tags { }
variable create_k8s { }
variable use_ondemand { }
variable use_spot { }
variable node_taint_key { }
variable node_taint_value { }

# Create Resources
resource "azurerm_kubernetes_cluster" "default" {
    count               = var.create_k8s ? 1 : 0

    name                = var.cluster_name
    location            = var.location
    resource_group_name = var.resource_group
    dns_prefix          = var.dns_prefix

    default_node_pool {
        name                = var.primary_node_pool
        node_count          = var.primary_pool_size
        vm_size             = var.primary_node_vm
        vnet_subnet_id      = var.subnet_id
        node_labels = {
            "starburstpool" = var.primary_node_pool
        }
    }

    identity {
        type = "SystemAssigned"
    }

    tags = var.tags
}

# Create Worker node pool
resource "azurerm_kubernetes_cluster_node_pool" "workerOnDemand" {
    count                 = var.create_k8s && var.use_ondemand ? 1 : 0

    name                  = var.worker_node_pool
    kubernetes_cluster_id = azurerm_kubernetes_cluster.default[0].id
    vm_size               = var.worker_node_vm
    enable_auto_scaling   = true

    vnet_subnet_id        = var.subnet_id

    node_labels = {
        "starburstpool"      = var.worker_node_pool
    }

    node_count            = var.worker_pool_min_size
    max_count             = var.worker_pool_max_size
    min_count             = var.worker_pool_min_size
    tags = var.tags
}

# Create Spot Worker node pool
resource "azurerm_kubernetes_cluster_node_pool" "workerSpot" {
    count                 = var.create_k8s && var.use_spot ? 1 : 0

    name                  = "${var.worker_node_pool}spot"
    kubernetes_cluster_id = azurerm_kubernetes_cluster.default[0].id
    vm_size               = var.worker_node_vm
    enable_auto_scaling   = true

    vnet_subnet_id        = var.subnet_id

    priority              = "Spot"
    eviction_policy       = "Delete"
    spot_max_price        = -1 # i.e. the current on-demand price
    node_labels = {
        "starburstpool"             = var.worker_node_pool,
        (var.node_taint_key) = var.node_taint_value
    }
    node_taints = [
        "${var.node_taint_key}=${var.node_taint_value}:NoSchedule"
    ]

    node_count            = var.worker_pool_min_size
    max_count             = var.worker_pool_max_size
    min_count             = var.worker_pool_min_size
    tags = var.tags
}


output "cluster_id" {
    value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].id : null
}

output "cluster_name" {
    value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].name : null
}

output "client_cert" {
  value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].kube_config.0.client_certificate : null
}

output "client_key" {
  value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].kube_config.0.client_key : null
}

output "ca_cert" {
  value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].kube_config.0.cluster_ca_certificate : null
}

output "endpoint" {
  value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].kube_config.0.host : null
}
