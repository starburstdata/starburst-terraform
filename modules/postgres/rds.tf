# Variables
variable create_rds { }
variable primary_db_user { }
variable postgres_template_file { }
variable primary_node_pool { }
variable expose_postgres_name { }
variable wait_this_long { }

# Data Sources
locals {

    postgres_template_vars = {
        expose_postgres_name = var.expose_postgres_name
        primary_db_user      = var.primary_db_user
        primary_db_password  = random_string.primary_db_user.result
    }

    postgres_helm_chart_values = templatefile(
        var.postgres_template_file,
        local.postgres_template_vars
    )

}

# Create Resources
resource "helm_release" "postgresql" {
    count           = var.create_rds ? 1 : 0

    name            = var.expose_postgres_name

    repository      = "https://charts.bitnami.com/bitnami"

    chart           = "postgresql"
    values          = [local.postgres_helm_chart_values]

    set {
        name        = "nodeSelector\\.agentpool"
        value       = var.primary_node_pool
        type        = "string"
    }
}

# Add small delay to wait for Cloud provider to complete DB LoadBalancer startup
resource "time_sleep" "wait_for_postgres" {
  count           = var.create_rds ? 1 : 0

  depends_on = [helm_release.postgresql]

  create_duration = var.wait_this_long #"60s"
}


data "kubernetes_service" "postgres" {
  count           = var.create_rds ? 1 : 0

  metadata {
    name = var.expose_postgres_name
  }
  #depends_on = [helm_release.postgresql]
  depends_on = [time_sleep.wait_for_postgres]
}

# Always generate this pwd, even if the postgres instance is not being deployed
resource "random_string" "primary_db_user" {
    # Generate a random password for the primary PostgreSQL DB user
    length = 16
    upper  = true
    lower  = true
    number = true
    special = false
}

# Outputs
output "primary_db_user" {
    value       = var.primary_db_user
}

output "primary_db_password" {
    value       = random_string.primary_db_user.result
}

# Output "" when not creating an rds. Output IP for Azure/GCP. Output hostname for AWS
output "db_ingress" {
    value       = !var.create_rds ? "" : data.kubernetes_service.postgres[0].status[0].load_balancer[0].ingress[0].ip != "" ? data.kubernetes_service.postgres[0].status[0].load_balancer[0].ingress[0].ip : data.kubernetes_service.postgres[0].status[0].load_balancer[0].ingress[0].hostname
}

output "db_address" {
    value       = var.expose_postgres_name
}

output "db_name" {
    value       = "postgres"
}

output "db_port" {
    value       = "5432"
}

output db_engine {
    value       = "postgresql"
}

output db_version {
    value       = "13"
}