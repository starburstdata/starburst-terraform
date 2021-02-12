locals {
  trino_endpoint    = var.create_nginx ? "https://${module.dns.starburst_url}" : var.create_trino ? "http://${data.kubernetes_service.starburst.status.0.load_balancer.0.ingress.0.ip}:8080/ui" : null
  insights_endpoint = var.create_nginx ? "https://${module.dns.starburst_url}/ui/insights" : var.create_trino ? "http://${data.kubernetes_service.starburst.status.0.load_balancer.0.ingress.0.ip}:8080/ui/insights" : null
  ranger_endpoint   = var.create_nginx ? "https://${module.dns.ranger_url}" : var.create_ranger ? "http://${data.kubernetes_service.ranger.status.0.load_balancer.0.ingress.0.ip}:6080" : null
  mc_endpoint       = var.create_nginx ? "https://${module.dns.mc_url}" : var.create_mc ? "http://${data.kubernetes_service.mc.status.0.load_balancer.0.ingress.0.ip}:5042" : null
}

output gcp-infrastructure-details {
  value = list(
    "gke_cluster_name     = ${module.gke.name}",
    "vpc_name             = ${module.vpc.vpc_name}",
    var.create_rds ? "cloud_sql_name       = ${module.cloud_sql.identifier}" : "",
    "gcs_bucket           = ${google_storage_bucket.bucket.name}"
  )
}

output user-credentials {
  value = list(
    "admin_user           = ${var.admin_user}",
    "admin_pass           = ${random_string.admin_pass.result}"
  )
}

output postgres-details {
  value = var.create_rds ? list(
    "db_version           = ${module.cloud_sql.database_version}",
    "db_public_address    = ${module.cloud_sql.public_ip_address}:5432",
    "db_private_address   = ${module.cloud_sql.private_ip_address}:5432",
    "primary_db_user      = ${module.cloud_sql.primary_db_user}",
    "primary_db_password  = ${module.cloud_sql.primary_db_password}",
    "ranger_db_user       = ${module.ranger.ranger_db_user}",
    "ranger_db_password   = ${module.ranger.ranger_db_password}"
  ) : ["No external RDS was specified in this deployment"]
}

output starburst-endpoints {
  value = list(
    var.create_trino ?  "starburst-trino      = ${local.trino_endpoint}" : "Starburst-trino not deployed",
    var.create_trino ?  "starburst-insights   = ${local.insights_endpoint}" : "Starburst-insights not deployed",
    var.create_ranger ? "ranger               = ${local.ranger_endpoint}" : "Starburst-Ranger not deployed",
    var.create_mc ?     "Mission Control      = ${local.mc_endpoint}" : "Starburst-MissionControl not deployed"
  )
}