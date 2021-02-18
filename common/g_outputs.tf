locals {
  trino_endpoint    = var.create_nginx ? "https://${module.dns.starburst_url}" : var.create_trino ? "http://${module.trino.starburst_ingress}:8080/ui" : null
  insights_endpoint = var.create_nginx ? "https://${module.dns.starburst_url}/ui/insights" : var.create_trino ? "http://${module.trino.starburst_ingress}:8080/ui/insights" : null
  ranger_endpoint   = var.create_nginx ? "https://${module.dns.ranger_url}" : var.create_ranger ? "http://${module.ranger.ranger_ingress}:6080" : null
  mc_endpoint       = var.create_nginx ? "https://${module.dns.mc_url}" : var.create_mc ? "http://${module.mc.mc_ingress}:5042" : null
}

output user-credentials {
  value = list(
    "admin_user           = ${var.admin_user}",
    "admin_pass           = ${random_string.admin_pass.result}"
  )
}

output postgres-details {
  value = var.create_rds ? list(
    "db_engine:version    = ${module.db.db_engine}:${module.db.db_version}",
    "db_local_address     = ${module.db.db_address}",
    "db_ingress           = ${module.db.db_ingress}",
    "db_port              = ${module.db.db_port}",
    "primary_db_user      = ${module.db.primary_db_user}",
    "primary_db_password  = ${module.db.primary_db_password}"
    #"ranger_db_user       = ${module.ranger.ranger_db_user}",
    #"ranger_db_password   = ${module.ranger.ranger_db_password}"
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