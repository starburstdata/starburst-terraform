# Module input variables. Don't set defaults.
variable environment { }
variable registry { }
variable repository { }
variable repo_version { }
variable repo_username { }
variable repo_password { }
# Insights DB details
variable primary_db_insights { }
variable primary_ip_address { }
variable primary_db_port { }
variable primary_db_user { }
variable primary_user_password { }
# Cache Redirection DB details
variable primary_db_cache { }
variable cache_db_ip_address { }
variable cache_db_port { }
variable cache_db_user { }
variable cache_db_password { }
# Ranger DB
variable primary_db_ranger { }
variable ranger_db_ip_address { }
variable ranger_db_port { }
variable ranger_db_user { }
variable ranger_db_password { }
# Cluster Node details
variable primary_node_pool { }
variable worker_node_pool { }
variable worker_autoscaling_min_size { }
variable worker_autoscaling_max_size { }
variable targetCPUUtilizationPercentage { }
variable deploymentTerminationGracePeriodSeconds { }
variable starburstWorkerShutdownGracePeriodSeconds { }
variable worker_cpu { }
variable worker_mem { }
variable coordinator_cpu { }
variable coordinator_mem { }
# Password DB default user credentials
variable admin_user { }
variable admin_pass { }
variable reg_user1 { }
variable reg_pass1 { }
variable reg_user2 { }
variable reg_pass2 { }
variable int_comm_shared_secret { }
variable ranger_service { }
variable starburst_service { }
variable hive_service_url { }
variable expose_sb_name { }
variable expose_ranger_name { }
variable dns_zone { }
variable service_type { }
variable trino_yaml_files {
    type    = list(string)
    }
variable demo_db_name { }
variable node_taint_key { }
# ADL
variable adl_oauth2_client_id {     default = ""}
variable adl_oauth2_credential {    default = ""}
variable adl_oauth2_refresh_url {   default = ""}
# Azure ADLS
variable abfs_access_key {          default = ""}
variable abfs_storage_account {     default = ""}
variable abfs_auth_type {           default = ""}
variable abfs_client_id {           default = ""}
variable abfs_endpoint {            default = ""}
variable abfs_secret {              default = ""}
variable wasb_access_key {          default = ""}
variable wasb_storage_account {     default = ""}
variable create_rds { }
variable create_trino { }
variable create_insights_db { }

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
        starburst_service_prefix    = var.starburst_service
        hive_service_url            = var.hive_service_url
        expose_sb_name              = var.expose_sb_name
        expose_ranger_name          = var.expose_ranger_name
        dns_zone                    = var.dns_zone
        primary_ip_address          = var.primary_ip_address
        primary_db_port             = var.primary_db_port
        primary_db_user             = var.primary_db_user
        primary_db_password         = var.primary_user_password
        primary_db_insights         = var.primary_db_insights
        ranger_db_ip_address        = var.ranger_db_ip_address
        ranger_db_port              = var.ranger_db_port
        ranger_db_user              = var.ranger_db_user
        ranger_db_password          = var.ranger_db_password
        primary_db_ranger           = var.primary_db_ranger
        cache_db_ip_address         = var.cache_db_ip_address
        cache_db_port               = var.cache_db_port
        cache_db_user               = var.cache_db_user
        cache_db_password           = var.cache_db_password
        primary_db_cache            = var.primary_db_cache
        demo_db_name                = var.demo_db_name
        primary_node_pool           = var.primary_node_pool
        worker_node_pool            = var.worker_node_pool
        worker_autoscaling_min_size = var.worker_autoscaling_min_size
        worker_autoscaling_max_size = var.worker_autoscaling_max_size
        targetCPUUtilizationPercentage              = var.targetCPUUtilizationPercentage
        deploymentTerminationGracePeriodSeconds     = var.deploymentTerminationGracePeriodSeconds
        starburstWorkerShutdownGracePeriodSeconds   = var.starburstWorkerShutdownGracePeriodSeconds
        worker_cpu                  = var.worker_cpu
        worker_mem                  = var.worker_mem
        coordinator_cpu             = var.coordinator_cpu
        coordinator_mem             = var.coordinator_mem
        service_type                = var.service_type
        admin_user                  = var.admin_user
        admin_pass                  = var.admin_pass
        reg_user1                   = var.reg_user1
        reg_pass1                   = var.reg_pass1
        reg_user2                   = var.reg_user2
        reg_pass2                   = var.reg_pass2
        int_comm_shared_secret      = var.int_comm_shared_secret
        node_taint_key              = var.node_taint_key
        adl_oauth2_client_id        = var.adl_oauth2_client_id
        adl_oauth2_credential       = var.adl_oauth2_credential
        adl_oauth2_refresh_url      = var.adl_oauth2_refresh_url
        abfs_access_key             = var.abfs_access_key
        abfs_storage_account        = var.abfs_storage_account
        abfs_auth_type              = var.abfs_auth_type
        abfs_client_id              = var.abfs_client_id
        abfs_endpoint               = var.abfs_endpoint
        abfs_secret                 = var.abfs_secret
        wasb_access_key             = var.wasb_access_key
        wasb_storage_account        = var.wasb_storage_account
    }

#    trino_helm_chart_values = templatefile(
#        var.trino_template_file,
#        local.trino_template_vars
#    )

    trino_helm_chart_values = [for n in var.trino_yaml_files : templatefile(
                    n,
                    local.trino_template_vars)]
    
}

resource "helm_release" "trino" {
    # This is how Terraform does conditional logic
    count               = var.create_trino ? 1 : 0

    name    = "starburst"

    repository          = var.repository
    repository_username = var.repo_username
    repository_password = var.repo_password

    chart   = "starburst-enterprise"
    version = var.repo_version

    values = local.trino_helm_chart_values

    timeout = 420

    set {
      name = "nodeSelector\\.starburstpool"
      value = var.primary_node_pool
      type = "string"
    }

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