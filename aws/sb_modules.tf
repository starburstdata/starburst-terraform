module dns {
    source                  = "../modules/aws-dns"

    starburst_service       = local.starburst_service
    ranger_service          = local.ranger_service
    mc_service              = local.mc_service
    cloudbeaver_service     = local.cloudbeaver_service
    dns_zone                = var.dns_zone
    create_nginx            = var.create_nginx
    create_trino            = var.create_trino
    create_ranger           = var.create_ranger
    create_mc               = var.create_mc
    create_cloudbeaver      = var.create_cloudbeaver

    depends_on              = [module.nginx]   
}

module metrics-server {
    source                  = "../modules/aws-metrics-server"

    create_k8s              = var.create_k8s
    create_metrics_server   = var.create_metrics_server
    metrics_server_version  = var.metrics_server_version
    primary_node_pool       = var.primary_node_pool

    depends_on              = [module.k8s]
}

# module cluster-autoscaler {
#     source                      = "../modules/aws-cluster-autoscaler"

#     cluster_name                = local.cluster_name
#     cluster_id                  = module.k8s.cluster_id
#     worker_iam_role_name        = module.k8s.worker_iam_role_name
#     region                      = var.region    
#     create_k8s                  = var.create_k8s
#     create_cluster_autoscaler   = var.create_cluster_autoscaler
#     cluster_autoscaler_version  = var.cluster_autoscaler_version
#     cluster_autoscaler_tag      = var.cluster_autoscaler_tag
#     primary_node_pool           = var.primary_node_pool

#     depends_on                  = [module.k8s,module.metrics-server]
# }