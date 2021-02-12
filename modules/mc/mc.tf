# Module input variables. Don't set defaults.
variable environment { }
variable registry { }
variable repository { }
variable repo_version { }
variable presto_version { }
variable repo_username { }
variable repo_password { }
variable primary_ip_address { }
variable primary_db_port { }
variable primary_db_mc { }
variable primary_db_user { }
variable primary_user_password { }
variable primary_node_pool { }
variable create_mc { }
variable mc_template_file { }
variable operator_template_file { }
variable type { }
variable service_type { }
variable expose_mc_name { }
variable mc_service { }
variable dns_zone { }

# Data Sources
locals {
    mc_template_vars = {    
        registry                    = var.registry
        repo_username               = var.repo_username
        repo_password               = var.repo_password
        secret_key_ref              = "letsencrypt-${var.environment}"
        repository                  = "${var.registry}/missioncontrol"
        mc_service_prefix           = var.mc_service
        primary_ip_address          = var.primary_ip_address
        primary_db_port             = var.primary_db_port
        primary_db_mc               = var.primary_db_mc
        primary_db_user             = var.primary_db_user
        primary_db_password         = var.primary_user_password
        primary_node_pool           = var.primary_node_pool
        type                        = var.type
        service_type                = var.service_type
        expose_mc_name              = var.expose_mc_name
        dns_zone                    = var.dns_zone
        charts_version              = var.repo_version
        presto_version              = var.presto_version
    }

    # Keep these charts in a directory under the root folder
    mc_chart_values = templatefile(
        var.mc_template_file,
        local.mc_template_vars
    )

    presto_operator_vars = {
        registry                    = var.registry
        repo_username               = var.repo_username
        repo_password               = var.repo_password
        repository                  = "${var.registry}/presto-helm-operator"
    }

    presto_operator_values = templatefile(
        var.operator_template_file,
        local.presto_operator_vars
    )
}

# Need to Deploy Presto Operator as well if deploying MC
resource "helm_release" "presto-operator" {
    # This is how Terraform does conditional logic
    count               = var.create_mc ? 1 : 0

    name                = "starburst-presto-helm-operator"

    repository          = var.repository
    repository_username = var.repo_username
    repository_password = var.repo_password

    chart               = "starburst-presto-helm-operator"
    version             = var.repo_version

    values              = [local.presto_operator_values]

    set {
      name              = "nodeSelector\\.agentpool"
      value             = var.primary_node_pool
      type              = "string"
    }
}


# Helm Deployment
resource "helm_release" "starburst-mission-control" {
    # This is how Terraform does conditional logic
    count               = var.create_mc ? 1 : 0

    name                = "starburst-mission-control"

    repository          = var.repository
    repository_username = var.repo_username
    repository_password = var.repo_password

    chart               = "starburst-mission-control"
    version             = var.repo_version

    values              = [local.mc_chart_values]

    set {
      name              = "nodeSelector\\.agentpool"
      value             = var.primary_node_pool
      type              = "string"
    }

}