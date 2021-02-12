resource "random_id" "deployment" {
  # Generate a unique ID to be used in this deployment
  byte_length = 4
}

locals {
    env                 = terraform.workspace

    vpc_name            = "${var.prefix}-${local.env}-${var.vpc_name}-${random_id.deployment.hex}"
    cluster_name        = "${var.prefix}-${local.env}-${var.k8s_name}-${random_id.deployment.hex}"
    db_name             = "${var.prefix}-${local.env}-${var.primary_db_instance}-${random_id.deployment.hex}"
    bucket_name         = "${var.prefix}-${local.env}-${var.bucket_name}-${random_id.deployment.hex}"
    hive_service        = "${var.prefix}-${local.env}-${var.hive_service}"
    presto_service      = "${var.prefix}-${local.env}-${var.presto_service}-${random_id.deployment.hex}"
    ranger_service      = "${var.prefix}-${local.env}-${var.ranger_service}-${random_id.deployment.hex}"
    mc_service          = "${var.prefix}-${local.env}-${var.mc_service}-${random_id.deployment.hex}"

    hive_yaml_file      = var.hive_yaml_file
    trino_yaml_file     = var.create_rds ? var.trino_yaml_file[1] : var.trino_yaml_file[0]
    ranger_yaml_file    = var.ranger_yaml_file
    mc_yaml_file        = var.mc_yaml_file
    operator_yaml_file  = var.operator_yaml_file

    hms_version         = var.hms_version != null ? var.hms_version : var.repo_version
    sb_version          = var.sb_version != null  ? var.sb_version : var.repo_version
    ranger_version      = var.ranger_version != null  ? var.ranger_version : var.repo_version
    mc_version          = var.mc_version != null  ? var.mc_version : var.repo_version
    operator_version    = var.operator_version != null  ? var.operator_version : var.repo_version

    # Object storage credentials
    # GCS
    gcp_cloud_key_secret    = var.gcp_cloud_key_secret
    # ADL
    adl_oauth2_client_id    = var.adl_oauth2_client_id
    adl_oauth2_credential   = var.adl_oauth2_credential
    adl_oauth2_refresh_url  = var.adl_oauth2_refresh_url
    # AWS S3
    s3_access_key           = var.s3_access_key
    s3_endpoint             = var.s3_endpoint
    s3_region               = var.s3_region
    s3_secret_key           = var.s3_secret_key
    # Azure ADLS
    abfs_access_key         = var.abfs_access_key
    abfs_storage_account    = var.abfs_storage_account
    abfs_auth_type          = var.abfs_auth_type
    abfs_client_id          = var.abfs_client_id
    abfs_endpoint           = var.abfs_endpoint
    abfs_secret             = var.abfs_secret
    wasb_access_key         = var.wasb_access_key
    wasb_storage_account    = var.wasb_storage_account

    
    common_tags = {
        ch_cloud        = var.ch_cloud
        ch_environment  = local.env
        ch_org          = var.ch_org
        ch_team         = var.ch_team
        ch_project      = var.ch_project
        ch_user         = var.ch_user
    }

    primary_node_tags = {
        agentpool       = var.primary_node_pool
    }

    worker_node_tags  = {
        agentpool       = var.worker_node_pool
    }
}

# Generate some visible random passwords the user can use to connect to Presto & Ranger
# NOTE: the "admin_user" is used for both Ranger & Trino logins and will have full access to all
resource "random_string" "admin_pass" {

  # Generate a password to be used in this deployment.
  length = 16
  upper  = true
  lower  = true
  number = true
  special = false
}

data "kubernetes_service" "starburst" {
  metadata {
    name = var.expose_sb_name
  }
  depends_on = [module.trino]
}

data "kubernetes_service" "ranger" {
  metadata {
    name = var.expose_ranger_name
  }
  depends_on = [module.ranger]
}

data "kubernetes_service" "mc" {
  metadata {
    name = var.expose_mc_name
  }
  depends_on = [module.mc]
}
