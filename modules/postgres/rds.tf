# Variables
variable create_rds { }
variable primary_db_user { }
variable postgres_template_file { }
variable primary_node_pool { }
variable expose_postgres_name { }
variable wait_this_long { }
# Create these databases
variable primary_db_hive { }
variable primary_db_ranger { }
variable primary_db_insights { }
variable primary_db_cache { }


# Data Sources
locals {

    postgres_template_vars = {
        expose_postgres_name = var.expose_postgres_name
        primary_db_user      = var.primary_db_user
        primary_db_password  = random_string.primary_db_user.result
        primary_db_hive      = var.primary_db_hive
        primary_db_ranger    = var.primary_db_ranger
        primary_db_insights  = var.primary_db_insights
        primary_db_cache     = var.primary_db_cache
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
        name        = "primary.nodeSelector.starburstpool"
        value       = var.primary_node_pool
    }

    set {
        name        = "readReplicas.nodeSelector.starburstpool"
        value       = var.primary_node_pool
    }
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