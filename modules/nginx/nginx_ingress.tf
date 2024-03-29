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

  set {
    name              = "nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

  values = [local.certs_helm_chart_values]
}

resource helm_release cert-manager {
  count  = var.create_nginx ? 1 : 0

  depends_on = [time_sleep.wait_for_nginx]

  name       = "cert-manager"
  namespace  = local.namespace
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  version    = "v1.9.1"

  force_update     = false
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name              = "nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

  set {
    name              = "webhook.nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

  set {
    name              = "cainjector.nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

}

resource helm_release ingress {
  count  = var.create_nginx ? 1 : 0

  name = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"

  chart = "ingress-nginx"

  version      = "4.2.5"
  force_update = true

  cleanup_on_fail = true

  set {
    name              = "fullnameOverride"
    value             = "ingress-nginx"
  }

  set {
    name              = "controller.nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

  set {
    name              = "defaultBackend.nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

  set {
    name              = "controller.admissionWebhooks.patch.nodeSelector.starburstpool"
    value             = var.primary_node_pool
  }

}

resource "time_sleep" "wait_for_nginx" {
  depends_on = [helm_release.ingress]

  create_duration = "30s"
}
