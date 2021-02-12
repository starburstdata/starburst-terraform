# Input Parameters
variable environment { }
variable email { }
variable primary_node_pool { }
variable create_nginx { }

# Local variables
locals {
  namespace       = "certs-manager"

  certs_template_vars = {
    env             = var.environment,
    name            = "letsencrypt-${var.environment}",
    email           = var.email,
    namespace       = local.namespace,
    primary_node_pool = var.primary_node_pool
  }

  certs_helm_chart_values = templatefile(
    "${path.module}/certs/certs_values.yaml.tpl",
    local.certs_template_vars
  )

}

# Deploy resources
resource helm_release issuer {
  count  = var.create_nginx ? 1 : 0
  depends_on = [ helm_release.cert-manager ]

  name      = "certs"
  namespace = local.namespace
  chart     = "${path.module}/certs"

  force_update    = true
  cleanup_on_fail = true
  recreate_pods   = false
  reset_values    = false

  create_namespace = true

  values = [local.certs_helm_chart_values]
}

resource helm_release cert-manager {
  count  = var.create_nginx ? 1 : 0

  name       = "cert-manager"
  namespace  = local.namespace
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"

  force_update     = false
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name              = "nodeSelector\\.agentpool"
    value             = var.primary_node_pool
  }

}

resource helm_release ingress {
  count  = var.create_nginx ? 1 : 0

  name = "nginx"

  repository = "https://charts.helm.sh/stable"

  chart = "nginx-ingress"

  version      = ""
  force_update = true

  cleanup_on_fail = true

  set {
    name  = "rbac.create"
    value = true
  }

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "controller.publishService.enabled"
    value = true
  }

}
