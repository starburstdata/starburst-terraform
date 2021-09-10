locals {
  trino_endpoint    = var.create_nginx ? "https://${module.dns.starburst_url}" : var.create_trino ? "http://${module.trino.starburst_ingress}:8080/ui" : null
  insights_endpoint = var.create_nginx ? "https://${module.dns.starburst_url}/ui/insights" : var.create_trino ? "http://${module.trino.starburst_ingress}:8080/ui/insights" : null
  ranger_endpoint   = var.create_nginx ? "https://${module.dns.ranger_url}" : var.create_ranger ? "http://${module.ranger.ranger_ingress}:6080" : null
}

output user-credentials {
  value = tolist([
    "user / pwd",
    "${var.admin_user} / ${local.admin_pass}",
    "${var.reg_user1} / ${local.reg_pass1}",
    "${var.reg_user2} / ${local.reg_pass2}"
  ])
}

output postgres-details {
  value = var.create_rds ? tolist([
    "db_engine:version    = ${module.db.db_engine}:${module.db.db_version}",
    "db_local_address     = ${module.db.db_address}",
    "db_port              = ${module.db.db_port}",
    "primary_db_user      = ${module.db.primary_db_user}",
    "primary_db_password  = ${module.db.primary_db_password}"
  ]) : ["No RDS was built for this deployment"]
}

output starburst-endpoints {
  value = tolist([
    var.create_trino ?        "starburst-trino      = ${local.trino_endpoint}" : "Starburst-trino not deployed",
    var.create_trino ?        "starburst-insights   = ${local.insights_endpoint}" : "Starburst-insights not deployed",
    var.create_ranger ?       "ranger               = ${local.ranger_endpoint}" : "Starburst-Ranger not deployed",
  ])
}

output worker-node-details {
  value = tolist([
    "Allocatable CPU=${data.external.worker_nodes.result.cpu}",
    "Allocatable MEM=${data.external.worker_nodes.result.memory}",
    "Usable CPU=${local.worker_cpu}",
    "Usable MEM=${local.worker_mem}"
  ])
}

output primary-node-details {
  value = tolist([
    "CPU=${data.external.primary_nodes.result.cpu}",
    "MEM=${data.external.primary_nodes.result.memory}"
  ])
}