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
    postgres_yaml_file  = var.postgres_yaml_file

    hms_version         = var.hms_version != null ? var.hms_version : var.repo_version
    sb_version          = var.sb_version != null  ? var.sb_version : var.repo_version
    ranger_version      = var.ranger_version != null  ? var.ranger_version : var.repo_version
    mc_version          = var.mc_version != null  ? var.mc_version : var.repo_version
    operator_version    = var.operator_version != null  ? var.operator_version : var.repo_version
    
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
