resource "random_id" "deployment" {
  # Generate a unique ID to be used in this deployment
  byte_length = 4
}

locals {
    env                 = terraform.workspace
    deployment_id       = var.deployment_id == "" ? random_id.deployment.hex : var.deployment_id

    vpc_name            = "${var.prefix}-${local.env}-${var.vpc_name}-${local.deployment_id}"
    cluster_name        = "${var.prefix}-${local.env}-${var.k8s_name}-${local.deployment_id}"
    db_name             = "${var.prefix}-${local.env}-${var.primary_db_instance}-${local.deployment_id}"
    bucket_name         = "${var.prefix}-${local.env}-${var.bucket_name}-${local.deployment_id}"
    hive_service        = "${var.prefix}-${local.env}-${var.hive_service}"
    starburst_service   = "${var.prefix}-${local.env}-${var.starburst_service}-${local.deployment_id}"
    ranger_service      = "${var.prefix}-${local.env}-${var.ranger_service}-${local.deployment_id}"
    mc_service          = "${var.prefix}-${local.env}-${var.mc_service}-${local.deployment_id}"
    cloudbeaver_service = "${var.prefix}-${local.env}-${var.cloudbeaver_service}-${local.deployment_id}"

    hive_yaml_files     = compact(["${path.root}/../helm_templates/${var.hive_yaml_file}",
                            var.custom_hive_yaml_file])
    ranger_yaml_files   = compact(["${path.root}/../helm_templates/${var.ranger_yaml_file}",
                            var.custom_ranger_yaml_file])
    mc_yaml_file        = var.mc_yaml_file
    operator_yaml_file  = var.operator_yaml_file
    postgres_yaml_file  = var.postgres_yaml_file
    cloudbeaver_yaml_file  = var.cloudbeaver_yaml_file

    trino_yaml_files    = compact(["${path.root}/../helm_templates/trino_values.01.base.tpl",
                            "${path.root}/../helm_templates/trino_values.02.auth.tpl",
                            var.create_ranger ? "" : "${path.root}/../helm_templates/trino_values.03.ranger.tpl",
                            var.create_rds == false && var.ex_insights_instance == "" ? "" : "${path.root}/../helm_templates/trino_values.04.insights.tpl",
                            "${path.root}/../helm_templates/trino_values.05.catalogs.tpl",
                            var.custom_trino_yaml_file])

    hms_version         = var.hms_version       != null ? var.hms_version : var.repo_version
    sb_version          = var.sb_version        != null ? var.sb_version : var.repo_version
    ranger_version      = var.ranger_version    != null ? var.ranger_version : var.repo_version
    mc_version          = var.mc_version        != null ? var.mc_version : var.repo_version
    operator_version    = var.operator_version  != null ? var.operator_version : var.repo_version
    
    common_tags = var.tags

    # Password overrides
    admin_pass          = var.admin_pass != "" ? var.admin_pass : random_string.admin_pass.result
    reg_pass1           = var.reg_pass1 != "" ? var.reg_pass1 : random_string.admin_pass.result
    reg_pass2           = var.reg_pass2 != "" ? var.reg_pass2 : random_string.admin_pass.result

    primary_node_tags = {
        agentpool       = var.primary_node_pool
    }

    worker_node_tags  = {
        agentpool       = var.worker_node_pool
    }
}

# Generate some visible random passwords the user can use to connect to starburst & Ranger
# NOTE: the "admin_user" is used for both Ranger & Trino logins and will have full access to all
resource "random_string" "admin_pass" {

  # Generate a password to be used in this deployment.
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_string" "user_pass1" {

  # Generate a password to be used in this deployment.
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}

resource "random_string" "user_pass2" {

  # Generate a password to be used in this deployment.
  length = 32
  upper  = true
  lower  = true
  number = true
  special = false
}
