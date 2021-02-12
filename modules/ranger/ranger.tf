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
variable dns_zone { }
variable ranger_db_user { default = "ranger"}
variable type { }
variable service_type { }
variable ranger_template_file { }

variable create_ranger { }

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
}

# Random password for the db user
resource "random_string" "ranger_db_password" {
  #count               = var.create_ranger ? 1 : 0

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
  #count               = var.create_ranger ? 1 : 0

  # Generate a random password for the Ranger user in the Postgres DB
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password2" {
  #count               = var.create_ranger ? 1 : 0

  # Generate a random password for the Ranger user in the Postgres DB
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password3" {
  #count               = var.create_ranger ? 1 : 0

  # Generate a random password for the Ranger user in the Postgres DB
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password4" {
  #count               = var.create_ranger ? 1 : 0

  # Generate a random password for the Ranger user in the Postgres DB
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_password" "service_acc_password5" {
  #count               = var.create_ranger ? 1 : 0

  # Generate a random password for the Ranger user in the Postgres DB
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

output ranger_db_user {
  value = var.ranger_db_user
}

output ranger_db_password {
  value = random_string.ranger_db_password.result
}

output ranger_svc_acc_admin {
  value = "admin"
}

output ranger_svc_acc_pass {
  value = random_password.service_acc_password1.result
}