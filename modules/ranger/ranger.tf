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
variable ranger_db_user { }
variable ex_ranger_db_password { }
variable ex_ranger_admin_pwd { }
variable ex_ranger_keyadmin_pwd { }
variable ex_ranger_service_pwd { }
variable ex_ranger_tagsync_pwd { }
variable ex_ranger_usersync_pwd { }
variable primary_node_pool { }
variable admin_user { }
variable admin_pass { }
variable ranger_service { }
variable starburst_service { }
variable expose_ranger_name { }
variable expose_sb_name { }
variable dns_zone { }
variable type { }
variable service_type { }
variable ranger_yaml_files {
    type    = list(string)
    }

variable create_ranger { }
variable create_rds { }
variable create_ranger_db { }

variable ranger_cpu { }
variable ranger_mem { }

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
        starburst_service_prefix    = var.starburst_service
        expose_ranger_name          = var.expose_ranger_name
        expose_sb_name              = var.expose_sb_name
        dns_zone                    = var.dns_zone
        primary_ip_address          = var.primary_ip_address
        primary_db_port             = var.primary_db_port
        primary_db_user             = var.primary_db_user
        primary_db_password         = var.primary_user_password
        primary_db_ranger           = var.primary_db_ranger
        ranger_db_user              = var.ranger_db_user
        ranger_db_password          = var.ex_ranger_db_password != "" ? var.ex_ranger_db_password : random_string.ranger_db_password.result
        primary_node_pool           = var.primary_node_pool
        admin_user                  = var.admin_user
        admin_pass                  = var.admin_pass
        ranger_svc_acc_pwd1         = var.ex_ranger_admin_pwd != "" ? var.ex_ranger_admin_pwd : random_password.service_acc_password1.result
        ranger_svc_acc_pwd2         = var.ex_ranger_keyadmin_pwd != "" ? var.ex_ranger_keyadmin_pwd : random_password.service_acc_password2.result
        ranger_svc_acc_pwd3         = var.ex_ranger_service_pwd != "" ? var.ex_ranger_service_pwd : random_password.service_acc_password3.result
        ranger_svc_acc_pwd4         = var.ex_ranger_tagsync_pwd != "" ? var.ex_ranger_tagsync_pwd : random_password.service_acc_password4.result
        ranger_svc_acc_pwd5         = var.ex_ranger_usersync_pwd != "" ? var.ex_ranger_usersync_pwd : random_password.service_acc_password5.result
        type                        = var.type
        service_type                = var.service_type
        ranger_cpu                  = var.ranger_cpu
        ranger_mem                  = var.ranger_mem
    }

    ranger_helm_chart_values = [for n in var.ranger_yaml_files : templatefile(
                    n,
                    local.ranger_template_vars)]

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

    values = local.ranger_helm_chart_values

    set {
      name = "nodeSelector.starburstpool"
      value = var.primary_node_pool
      type = "string"
    }

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
  numeric = true
  special = false
}

# Random passwords for the service accounts.
# Don't need to expose to the end user
resource "random_password" "service_acc_password1" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  numeric = true
  special = false
}

resource "random_password" "service_acc_password2" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  numeric = true
  special = false
}

resource "random_password" "service_acc_password3" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  numeric = true
  special = false
}

resource "random_password" "service_acc_password4" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  numeric = true
  special = false
}

resource "random_password" "service_acc_password5" {
  # Generate a random password for the Ranger user in the Postgres DB
  length = 32
  upper  = true
  lower  = true
  numeric = true
  special = false
}

output ranger_db_user {
  value = var.create_ranger ? var.ranger_db_user : null
}

output ranger_db_password {
  value = var.create_ranger && var.ex_ranger_db_password == "" ? random_string.ranger_db_password.result : var.ex_ranger_db_password
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