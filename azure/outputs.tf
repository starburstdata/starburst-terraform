locals {
  trino_endpoint    = var.create_nginx ? "https://${module.dns.starburst_url}" : "http://${data.kubernetes_service.starburst.status.0.load_balancer.0.ingress.0.hostname}:8080/ui"
  insights_endpoint = var.create_nginx ? "https://${module.dns.starburst_url}/ui/insights" : "http://${data.kubernetes_service.starburst.status.0.load_balancer.0.ingress.0.hostname}:8080/ui/insights"
  ranger_endpoint   = var.create_nginx ? "https://${module.dns.ranger_url}" : "http://${data.kubernetes_service.ranger.status.0.load_balancer.0.ingress.0.hostname}:6080"
}


output aws-infrastructure-details {
  value = list(
    "eks_cluster_name     = ${module.eks.cluster_id}",
    "vpc_name             = ${module.vpc.name}",
    "rds_name             = ${module.db.identifier}",
    "s3_bucket            = ${local.bucket_name}"
  )
}

output user-credentials {
  value = list(
    "admin_user           = ${var.admin_user}",
    "admin_pass           = ${random_string.admin_pass.result}",
    "regular_user         = ${var.reg_user}",
    "regular_pass         = ${random_string.reg_pass.result}"
  )
}

output postgres-details {
  value = var.create_rds ? list(
    "db_engine:version    = ${module.db.engine}:${module.db.engine_version}",
    "db_address:port      = ${module.db.address}:${module.db.port}",
    "primary_db_user      = ${module.db.username}",
    "primary_db_password  = ${module.db.password}",
    "ranger_db_user       = ${module.ranger.ranger_db_user}",
    "ranger_db_password   = ${module.ranger.ranger_db_password}"
  ) : ["No external RDS was specified in this deployment"]
}

output starburst-endpoints {
  value = list(
    var.create_trino ?  "starburst-trino      = ${local.trino_endpoint}" : "Starburst-trino not deployed",
    var.create_trino ?  "starburst-insights   = ${local.insights_endpoint}" : "Starburst-insights not deployed",
    var.create_ranger ? "ranger               = ${local.ranger_endpoint}" : "Starburst-Ranger not deployed"
  )
}