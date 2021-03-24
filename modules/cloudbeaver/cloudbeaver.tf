# Input Parameters
variable environment { }
variable primary_node_pool { }
variable create_cloudbeaver { }
variable repository { }
variable cloudbeaver_service { }
variable cloudbeaver_yaml_file { }
variable service_type { }
variable enable_ingress { }
variable expose_cloudbeaver_name { }
variable dns_zone { }

# Local variables
locals {
  cloudbeaver_template_vars = {
    secret_key_ref              = "letsencrypt-${var.environment}",
    repository                  = var.repository,
    cloudbeaver_service_prefix  = var.cloudbeaver_service
    expose_cloudbeaver_name     = var.expose_cloudbeaver_name,
    service_type                = var.service_type,
    enable_ingress              = var.enable_ingress,
    primary_node_pool           = var.primary_node_pool,
    dns_zone                    = var.dns_zone
  }

  cloudbeaver_helm_chart_values = templatefile(
    var.cloudbeaver_yaml_file,
    local.cloudbeaver_template_vars
  )

}
# Deploy resources
resource helm_release cloudbeaver {
  count  = var.create_cloudbeaver ? 1 : 0

  name      = "cloudbeaver"
  chart     = "${path.module}/cloudbeaver"

  force_update    = true
  cleanup_on_fail = true
  recreate_pods   = false
  reset_values    = false

  create_namespace = true

  values = [local.cloudbeaver_helm_chart_values]
}

data "kubernetes_service" "cloudbeaver" {
  count  = var.create_cloudbeaver ? 1 : 0

  metadata {
    name = var.expose_cloudbeaver_name
  }
  depends_on = [helm_release.cloudbeaver]
}

# Convoluted logic: If Trino is being deployed..
#  1. If its being deployed as type = LoadBalancer...
#      a. Check if its IP (GCP/Azure) or Hostname (AWS)
#      b. Output appropriate value
#  2. If it is being deployed but not type = LoadBalancer...
#      a. Nginx is being deployed
#      b. Output empty string, since Nginx will be the ingress point
#  3. If it is not being deployed, output an empty string
output cloudbeaver_ingress {
  value = var.create_cloudbeaver ? (
      data.kubernetes_service.cloudbeaver[0].spec[0].type == "LoadBalancer" ? (
          data.kubernetes_service.cloudbeaver[0].status[0].load_balancer[0].ingress[0].ip != "" ? (
              data.kubernetes_service.cloudbeaver[0].status[0].load_balancer[0].ingress[0].ip
          ) : (
              data.kubernetes_service.cloudbeaver[0].status[0].load_balancer[0].ingress[0].hostname
          )
      ) : ""
  ) : ""
}