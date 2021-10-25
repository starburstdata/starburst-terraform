resource "random_id" "deployment" {
  # Generate a unique ID to be used in this deployment
  byte_length = 4
}

locals {
    env                 = terraform.workspace
    deployment_id       = var.deployment_id == "" ? random_id.deployment.hex : var.deployment_id

    vpc_name            = lower("${var.prefix}-${local.env}-${var.vpc_name}-${local.deployment_id}")
    cluster_name        = lower("${var.prefix}-${local.env}-${var.k8s_name}-${local.deployment_id}")
    db_name             = lower("${var.prefix}-${local.env}-${var.primary_db_instance}-${local.deployment_id}")
    bucket_name         = lower("${var.prefix}-${local.env}-${var.bucket_name}-${local.deployment_id}")
    hive_service        = lower("${var.prefix}-${local.env}-${var.hive_service}")
    starburst_service   = lower("${var.prefix}-${local.env}-${var.starburst_service}-${local.deployment_id}")
    ranger_service      = lower("${var.prefix}-${local.env}-${var.ranger_service}-${local.deployment_id}")
    mc_service          = lower("${var.prefix}-${local.env}-${var.mc_service}-${local.deployment_id}")
    cloudbeaver_service = lower("${var.prefix}-${local.env}-${var.cloudbeaver_service}-${local.deployment_id}")

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
                            var.create_ranger ? "${path.root}/../helm_templates/trino_values.03.ranger.tpl" : "",
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
    reg_pass1           = var.reg_pass1 != "" ? var.reg_pass1 : random_string.user_pass1.result
    reg_pass2           = var.reg_pass2 != "" ? var.reg_pass2 : random_string.user_pass2.result

    primary_node_tags = {
        agentpool       = var.primary_node_pool
    }

    worker_node_tags  = {
        agentpool       = var.worker_node_pool
    }

    # Coordinator starts with 87.5% of the node. Subtract 1/8 each for: Ranger, Nginx, Hive, Postgres
    coordinator_factor      = 0.875 - (var.create_ranger ? 0.125 : 0) - (var.create_rds ? 0.125 : 0) - (var.create_hive ? 0.125 : 0) - (var.create_nginx ? 0.125 : 0)

    # Get maximum available node cpu & mem for Worker pods 
    worker_cpu              = var.worker_cpu != "" ? var.worker_cpu : "${(trimsuffix(data.external.worker_nodes[0].result.cpu,substr(data.external.worker_nodes[0].result.cpu,-1,-1)) - var.cpu_offset)}${substr(data.external.worker_nodes[0].result.cpu,-1,-1)}"
    worker_mem              = var.worker_mem != "" ? var.worker_mem : "${(trimsuffix(data.external.worker_nodes[0].result.memory,substr(data.external.worker_nodes[0].result.memory,-2,-1)) - var.mem_offset)}${substr(data.external.worker_nodes[0].result.memory,-2,-1)}"

    # Coordinator gets at least 1/2 of available mem & cpu on base node
    coordinator_cpu         = var.coordinator_cpu != "" ? var.coordinator_cpu : "${((trimsuffix(data.external.primary_nodes[0].result.cpu,substr(data.external.primary_nodes[0].result.cpu,-1,-1)) - var.cpu_offset) * local.coordinator_factor)}m"
    coordinator_mem         = var.coordinator_mem != "" ? var.coordinator_mem : "${floor(((trimsuffix(data.external.primary_nodes[0].result.memory,substr(data.external.primary_nodes[0].result.memory,-2,-1)) - var.mem_offset) * 0.5)/1000000)}Gi"

    # Ranger gets 1/4 of available cpu & mem on base node
    ranger_cpu              = var.ranger_cpu != "" ? var.ranger_cpu : "${((trimsuffix(data.external.primary_nodes[0].result.cpu,substr(data.external.primary_nodes[0].result.cpu,-1,-1)) - var.cpu_offset) * 0.125)}m"
    ranger_mem              = var.ranger_mem != "" ? var.ranger_mem : "${floor(((trimsuffix(data.external.primary_nodes[0].result.memory,substr(data.external.primary_nodes[0].result.memory,-2,-1)) - var.mem_offset) * 0.125)/1000000)}Gi"

    # Hive & Postgres get remaining mem & cpu on base node
    postgres_cpu            = var.postgres_cpu != "" ? var.postgres_cpu : "${((trimsuffix(data.external.primary_nodes[0].result.cpu,substr(data.external.primary_nodes[0].result.cpu,-1,-1)) - var.cpu_offset) * 0.125)}m"
    postgres_mem            = var.postgres_mem != "" ? var.postgres_mem : "${floor(((trimsuffix(data.external.primary_nodes[0].result.memory,substr(data.external.primary_nodes[0].result.memory,-2,-1)) - var.mem_offset) * 0.125)/1000000)}Gi"
    hive_cpu                = var.hive_cpu != "" ? var.hive_cpu : "${((trimsuffix(data.external.primary_nodes[0].result.cpu,substr(data.external.primary_nodes[0].result.cpu,-1,-1)) - var.cpu_offset) * 0.125)}m"
    hive_mem                = var.hive_mem != "" ? var.hive_mem : "${floor(((trimsuffix(data.external.primary_nodes[0].result.memory,substr(data.external.primary_nodes[0].result.memory,-2,-1)) - var.mem_offset) * 0.125)/1000000)}Gi"
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
