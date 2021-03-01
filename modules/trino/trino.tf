# Module input variables. Don't set defaults.
variable environment { }
variable registry { }
variable repository { }
variable repo_version { }
variable repo_username { }
variable repo_password { }
variable primary_ip_address { }
variable primary_db_port { }
variable primary_db_event_logger { }
variable primary_db_ranger { }
variable primary_db_user { }
variable primary_user_password { }
variable primary_node_pool { }
variable worker_node_pool { }
variable admin_user { }
variable admin_pass { }
variable reg_user1 { }
variable reg_pass1 { }
variable reg_user2 { }
variable reg_pass2 { }
variable ranger_service { }
variable presto_service { }
variable expose_sb_name { }
variable expose_ranger_name { }
variable dns_zone { }
variable service_type { }
variable trino_template_file { }
variable demo_db_name { }

variable create_rds { }
variable create_trino { }

# Data Sources
locals {

    trino_template_vars = {
        registry                    = var.registry
        repo_username               = var.repo_username
        repo_password               = var.repo_password
        secret_key_ref              = "letsencrypt-${var.environment}"
        ranger_admin_repo           = "${var.registry}/starburst-ranger-admin"
        ranger_user_sync_repo       = "${var.registry}/ranger-usersync"
        ranger_user_sync_tag        = "2.0.24"
        ranger_service_prefix       = var.ranger_service
        presto_service_prefix       = var.presto_service
        expose_sb_name              = var.expose_sb_name
        expose_ranger_name          = var.expose_ranger_name
        dns_zone                    = var.dns_zone
        primary_ip_address          = var.primary_ip_address
        primary_db_port             = var.primary_db_port
        primary_db_user             = var.primary_db_user
        primary_db_password         = var.primary_user_password
        primary_db_event_logger     = var.primary_db_event_logger
        primary_db_ranger           = var.primary_db_ranger
        demo_db_name                = var.demo_db_name
        primary_node_pool           = var.primary_node_pool
        worker_node_pool            = var.worker_node_pool
        service_type                = var.service_type
        admin_user                  = var.admin_user
        admin_pass                  = var.admin_pass
        reg_user1                   = var.reg_user1
        reg_pass1                   = var.reg_pass1
        reg_user2                   = var.reg_user2
        reg_pass2                   = var.reg_pass2
    }

    trino_helm_chart_values = templatefile(
        var.trino_template_file,
        local.trino_template_vars
    )

}

# Create the event_logger DB
terraform {
    required_providers {
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = ">= 1.11.2"
        }
    }
}

resource postgresql_database event_logger {
    count               = var.create_trino && var.create_rds ? 1 : 0

    name                = var.primary_db_event_logger
    connection_limit    = -1
    allow_connections   = true
}


resource "helm_release" "trino" {
    # This is how Terraform does conditional logic
    count               = var.create_trino ? 1 : 0

    name    = "presto"

    repository          = var.repository
    repository_username = var.repo_username
    repository_password = var.repo_password

    chart   = "starburst-presto"
    version = var.repo_version

    values = [local.trino_helm_chart_values]

    set {
      name = "nodeSelector\\.agentpool"
      value = var.primary_node_pool
      type = "string"
    }

    depends_on          = [postgresql_database.event_logger]
}


data "kubernetes_service" "starburst" {
  count  = var.create_trino ? 1 : 0

  metadata {
    name = var.expose_sb_name
  }
  depends_on = [helm_release.trino]
}

# Convoluted logic: If Trino is being deployed..
#  1. If its being deployed as type = LoadBalancer...
#      a. Check if its IP (GCP/Azure) or Hostname (AWS)
#      b. Output appropriate value
#  2. If it is being deployed but not type = LoadBalancer...
#      a. Nginx is being deployed
#      b. Output empty string, since Nginx will be the ingress point
#  3. If it is not being deployed, output an empty string
output starburst_ingress {
  value = var.create_trino ? (
      data.kubernetes_service.starburst[0].spec[0].type == "LoadBalancer" ? (
          data.kubernetes_service.starburst[0].status[0].load_balancer[0].ingress[0].ip != "" ? (
              data.kubernetes_service.starburst[0].status[0].load_balancer[0].ingress[0].ip
          ) : (
              data.kubernetes_service.starburst[0].status[0].load_balancer[0].ingress[0].hostname
          )
      ) : ""
  ) : ""
}