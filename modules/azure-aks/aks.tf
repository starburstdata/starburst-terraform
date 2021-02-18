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
variable tags { }
variable create_k8s { }

# Create Resources
resource "azurerm_kubernetes_cluster" "default" {
    count               = var.create_k8s ? 1 : 0

    name                = var.cluster_name
    location            = var.location
    resource_group_name = var.resource_group
    dns_prefix          = var.dns_prefix

    default_node_pool {
        name            = var.primary_node_pool
        node_count      = 1
        vm_size         = var.primary_node_vm
        vnet_subnet_id  = var.subnet_id
    }

    identity {
        type = "SystemAssigned"
    }

    tags = var.tags
}

# Create Worker node pool
resource "azurerm_kubernetes_cluster_node_pool" "worker" {
    count                 = var.create_k8s ? 1 : 0

    name                  = var.worker_node_pool
    kubernetes_cluster_id = azurerm_kubernetes_cluster.default[0].id
    vm_size               = var.worker_node_vm
    enable_auto_scaling   = true

    vnet_subnet_id        = var.subnet_id

    node_count            = 1
    max_count             = 10
    min_count             = 1
    priority              = "Spot"
    eviction_policy       = "Delete"

    spot_max_price        = -1 # note: this is the "maximum" price

    node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
    }

    tags = var.tags
}


output "cluster_id" {
    value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].id : null
}

output "cluster_name" {
    value = var.create_k8s ? azurerm_kubernetes_cluster.default[0].name : null
}