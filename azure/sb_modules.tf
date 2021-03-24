# Azure-specific dns setup
module dns {
    source                  = "../modules/azure-dns"

    resource_group          = azurerm_resource_group.default.name
    dns_rg                  = var.dns_rg
    location                = var.region
    public_ip               = local.public_ip
    presto_service          = local.presto_service
    ranger_service          = local.ranger_service
    mc_service              = local.mc_service
    cloudbeaver_service     = local.cloudbeaver_service
    dns_zone_name           = var.dns_zone_name
    dns_zone                = var.dns_zone
    create_nginx            = var.create_nginx
    create_trino            = var.create_trino
    create_ranger           = var.create_ranger
    create_mc               = var.create_mc
    create_cloudbeaver      = var.create_cloudbeaver

    depends_on              = [module.nginx]   
}