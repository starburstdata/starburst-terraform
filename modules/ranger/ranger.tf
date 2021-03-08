# Module input variables. Don't set defaults.
variable environment { }
variable registry { }
variable repository { }
variable repo_version { }
variable repo_username { }
variable repo_password { }
variable primary_ip_address { }
variable primary_db_port { }
variable primary_db_ranger { }
variable primary_db_user { }
variable primary_user_password { }
variable primary_node_pool { }
variable admin_user { }
variable admin_pass { }
variable ranger_service { }
variable presto_service { }
variable expose_ranger_name { }
variable expose_sb_name { }
variable dns_zone { }
variable ranger_db_user { default = "ranger"}
variable type { }
variable service_type { }
variable ranger_template_file { }

variable create_ranger { }
variable create_rds { }
variable create_ranger_db { }

# Data Sources
locals {
    ranger_template_vars = {
        registry                    = var.registry
        repo_username               = var.repo_username
        repo_password               = var.repo_password
        secret_key_ref              = "letsencrypt-${var.environment}"
        ranger_admin_repo           = "${var.registry}/starburst-ranger-admin"
        ranger_user_sync_repo       = "${var.registry}/ranger-usersync"
        ranger_user_sync_tag        = "2.0.24"
        ranger_service_prefix       = var.ranger_service
        presto_service_prefix       = var.presto_service
        expose_ranger_name          = var.expose_ranger_name
        expose_sb_name              = var.expose_sb_name
        dns_zone                    = var.dns_zone
        primary_ip_address          = var.primary_ip_address
        primary_db_port             = var.primary_db_port
        primary_db_user             = var.primary_db_user
        primary_db_password         = var.primary_user_password
        primary_db_ranger           = var.primary_db_ranger
        ranger_db_user              = var.ranger_db_user
        ranger_db_password          = random_string.ranger_db_password.result
        primary_node_pool           = var.primary_node_pool
        admin_user                  = var.admin_user
        admin_pass                  = var.admin_pass
        ranger_svc_acc_pwd1         = random_password.service_acc_password1.result
        ranger_svc_acc_pwd2         = random_password.service_acc_password2.result
        ranger_svc_acc_pwd3         = random_password.service_acc_password3.result
        ranger_svc_acc_pwd4         = random_password.service_acc_password4.result
        ranger_svc_acc_pwd5         = random_password.service_acc_password5.result
        type                        = var.type
        service_type                = var.service_type
    }

    ranger_helm_chart_values = templatefile(
        var.ranger_template_file,
        local.ranger_template_vars
    )

}

# Create the Ranger DB
terraform {
    required_providers {
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = ">= 1.11.2"
        }
    }
}

resource postgresql_database ranger {
    count               = var.create_ranger && var.create_rds && var.create_ranger_db ? 1 : 0

    name                = var.primary_db_ranger
    connection_limit    = -1
    allow_connections   = true
}



resource "helm_release" "ranger" {
    # This is how Terraform does conditional logic
    count               = var.create_ranger ? 1 : 0

    name    = "starburst-ranger"

    repository          = var.repository
    repository_username = var.repo_username
    repository_password = var.repo_password

    chart   = "starburst-ranger"
    version = var.repo_version

    values = [local.ranger_helm_chart_values]

    set {
      name = "nodeSelector\\.agentpool"
      value = var.primary_node_pool
      type = "string"
    }

    depends_on          = [postgresql_database.ranger]
}

data "kubernetes_service" "ranger" {
  count  = var.create_ranger ? 1 : 0

  metadata {
    name = var.expose_ranger_name
  }
  depends_on = [helm_release.ranger]
}


# Random password for the db user
resource "random_string" "ranger_db_password" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

# Random passwords for the service accounts.
# Don't need to expose to the end user
resource "random_password" "service_acc_password1" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password2" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password3" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password4" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password5" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

output ranger_db_user {
  value = var.create_ranger ? var.ranger_db_user : null
}

output ranger_db_password {
  value = var.create_ranger ? random_string.ranger_db_password.result : null
}

output ranger_svc_acc_admin {
  value = var.create_ranger ? "admin" : null
}

output ranger_svc_acc_pass {
  value = var.create_ranger ? random_password.service_acc_password1.result : null
}

# Convoluted logic: If Ranger is being deployed..
#  1. If its being deployed as type = LoadBalancer...
#      a. Check if its IP (GCP/Azure) or Hostname (AWS)
#      b. Output appropriate value
#  2. If it is being deployed but not type = LoadBalancer...
#      a. Nginx is being deployed
#      b. Output empty string, since Nginx will be the ingress point
#  3. If it is not being deployed, output an empty string
output ranger_ingress {
  value = var.create_ranger ? (
      data.kubernetes_service.ranger[0].spec[0].type == "LoadBalancer" ? (
          data.kubernetes_service.ranger[0].status[0].load_balancer[0].ingress[0].ip != "" ? (
              data.kubernetes_service.ranger[0].status[0].load_balancer[0].ingress[0].ip
          ) : (
              data.kubernetes_service.ranger[0].status[0].load_balancer[0].ingress[0].hostname
          )
      ) : ""
  ) : ""
}