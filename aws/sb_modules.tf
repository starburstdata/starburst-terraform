module dns {
    source                  = "../modules/aws-dns"

    presto_service          = local.presto_service
    ranger_service          = local.ranger_service
    mc_service              = local.mc_service
    dns_zone                = var.dns_zone
    create_nginx            = var.create_nginx

    depends_on              = [module.nginx]   
}