locals {
  trino_endpoint    = var.create_nginx ? "https://${module.dns.starburst_url}" : var.create_trino ? "http://${data.kubernetes_service.starburst.status.0.load_balancer.0.ingress.0.hostname}:8080/ui" : null
  insights_endpoint = var.create_nginx ? "https://${module.dns.starburst_url}/ui/insights" : var.create_trino ? "http://${data.kubernetes_service.starburst.status.0.load_balancer.0.ingress.0.hostname}:8080/ui/insights" : null
  ranger_endpoint   = var.create_nginx ? "https://${module.dns.ranger_url}" : var.create_ranger ? "http://${data.kubernetes_service.ranger.status.0.load_balancer.0.ingress.0.hostname}:6080" : null
  mc_endpoint       = var.create_nginx ? "https://${module.dns.mc_url}" : var.create_mc ? "http://${data.kubernetes_service.mc.status.0.load_balancer.0.ingress.0.hostname}:5042" : null
}

output aws-infrastructure-details {
  value = list(
    "eks_cluster_name     = ${module.eks.cluster_id}",
    "vpc_name             = ${module.vpc.name}",
    var.create_rds ? "rds_name             = ${module.db.identifier}" : "",
    "s3_bucket            = ${local.bucket_name}"
  )
}

output user-credentials {
  value = list(
    "admin_user           = ${var.admin_user}",
    "admin_pass           = ${random_string.admin_pass.result}",
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
    var.create_ranger ? "ranger               = ${local.ranger_endpoint}" : "Starburst-Ranger not deployed",
    var.create_mc ?     "Mission Control      = ${local.mc_endpoint}" : "Starburst-MissionControl not deployed"
  )
}