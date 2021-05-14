variable create_k8s { }
variable create_metrics_server { }
variable metrics_server_version { }
variable primary_node_pool { }

# Deploy resources
resource helm_release metrics-server {
  count  = var.create_k8s && var.create_metrics_server ? 1 : 0

  name      = "metrics-server"
  namespace = "kube-system"
  chart     = "metrics-server"
  version   = var.metrics_server_version

  repository = "https://charts.bitnami.com/bitnami"

  force_update    = true
  cleanup_on_fail = true
  recreate_pods   = false
  reset_values    = false

    set {
      name              = "nodeSelector\\.starburstpool"
      value             = var.primary_node_pool
      type              = "string"
    }
}
