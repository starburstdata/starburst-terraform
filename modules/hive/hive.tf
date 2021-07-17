# Module input variables. Don't set defaults.
variable registry { }
variable repository { }
variable repo_version { }
variable repo_username { }
variable repo_password { }
variable hive_service { }
variable hive_service_type { }
variable primary_ip_address { }
variable primary_db_port { }
variable primary_db_user { }
variable primary_user_password { }
variable primary_db_hive { }
variable primary_node_pool { }
variable create_hive { }
variable create_rds { }
variable create_hive_db { }
variable type { }
variable hive_yaml_files {
    type    = list(string)
    }
# External Hive Server
variable ex_hive_server_url {       default = ""}
# Object storage credentials
# GCS
variable gcp_cloud_key_secret { }
# ADL
variable adl_oauth2_client_id {     default = ""}
variable adl_oauth2_credential {    default = ""}
variable adl_oauth2_refresh_url {   default = ""}
# AWS S3
variable s3_access_key {            default = ""}
variable s3_endpoint {              default = ""}
variable s3_region {                default = ""}
variable s3_secret_key {            default = ""}
# Azure ADLS
variable abfs_access_key {          default = ""}
variable abfs_storage_account {     default = ""}
variable abfs_auth_type {           default = ""}
variable abfs_client_id {           default = ""}
variable abfs_endpoint {            default = ""}
variable abfs_secret {              default = ""}
variable wasb_access_key {          default = ""}
variable wasb_storage_account {     default = ""}

# Data Sources
locals {
  hive_template_vars = {    
        registry                    = var.registry
        repo_username               = var.repo_username
        repo_password               = var.repo_password
        repository                  = "${var.registry}/hive"
        hive_service                = var.hive_service
        hive_service_type           = var.hive_service_type
        primary_ip_address          = var.primary_ip_address
        primary_db_port             = var.primary_db_port
        primary_db_user             = var.primary_db_user
        primary_db_password         = var.primary_user_password
        primary_db_hive             = var.primary_db_hive
        primary_node_pool           = var.primary_node_pool
        type                        = var.type
        gcp_cloud_key_secret        = var.gcp_cloud_key_secret
        adl_oauth2_client_id        = var.adl_oauth2_client_id
        adl_oauth2_credential       = var.adl_oauth2_credential
        adl_oauth2_refresh_url      = var.adl_oauth2_refresh_url
        s3_access_key               = var.s3_access_key
        s3_endpoint                 = var.s3_endpoint
        s3_region                   = var.s3_region
        s3_secret_key               = var.s3_secret_key
        abfs_access_key             = var.abfs_access_key
        abfs_storage_account        = var.abfs_storage_account
        abfs_auth_type              = var.abfs_auth_type
        abfs_client_id              = var.abfs_client_id
        abfs_endpoint               = var.abfs_endpoint
        abfs_secret                 = var.abfs_secret
        wasb_access_key             = var.wasb_access_key
        wasb_storage_account        = var.wasb_storage_account
    }

    hive_helm_chart_values = [for n in var.hive_yaml_files : templatefile(
                    n,
                    local.hive_template_vars)]

}

terraform {
    required_providers {
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = ">= 1.11.2"
        }
    }
}

resource postgresql_database hive {
    count               = var.create_hive && var.create_rds && var.create_hive_db ? 1 : 0

    name                = var.primary_db_hive
    connection_limit    = -1
    allow_connections   = true
}


# Helm Deployment
resource "helm_release" "hive" {
    # This is how Terraform does conditional logic
    count               = var.create_hive ? 1 : 0

    name                = "hive"

    repository          = var.repository
    repository_username = var.repo_username
    repository_password = var.repo_password

    chart               = "starburst-hive"
    version             = var.repo_version

    values              = local.hive_helm_chart_values

    set {
      name              = "nodeSelector.starburstpool"
      value             = var.primary_node_pool
      type              = "string"
    }

    depends_on          = [postgresql_database.hive]
}

output hive_url {
    value = var.ex_hive_server_url != "" ? var.ex_hive_server_url : "thrift://${var.hive_service}:9083"
}