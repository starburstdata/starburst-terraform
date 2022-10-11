# Variables
variable resource_group { }
variable dns_rg { }
variable location { }
variable public_ip { }
variable create_nginx { }
variable starburst_service { }
variable ranger_service { }
variable mc_service { }
variable cloudbeaver_service { }
variable dns_zone { }
variable dns_zone_name { }
variable create_ranger { }
variable create_trino { }
variable create_mc { }
variable create_cloudbeaver { }

# Proxy config
# Set alternate provider
terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "= 3.25.0"
            configuration_aliases = [ azurerm.dns ]
        }
    }
}

# Get the Nginx service details
data "kubernetes_service" "nginx" {
  count               = var.create_nginx ? 1 : 0

  metadata {
    #name = "nginx-nginx-ingress-controller"
    name = "ingress-nginx-controller"
  }
}

# Get the dns zone info
data "azurerm_dns_zone" "default" {
  count               = var.create_nginx ? 1 : 0

  provider            = azurerm.dns
  name                = var.dns_zone
  resource_group_name = var.dns_rg
}

# Add Azure DNS Record sets
resource "azurerm_dns_a_record" "starburst" {
  count               = var.create_nginx && var.create_trino ? 1 : 0

  provider            = azurerm.dns
  name                = var.starburst_service
  zone_name           = data.azurerm_dns_zone.default[0].name
  resource_group_name = var.dns_rg
  ttl                 = 300
  records             = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

# Add Azure DNS Record sets
resource "azurerm_dns_a_record" "ranger" {
  count               = var.create_nginx && var.create_ranger ? 1 : 0

  provider            = azurerm.dns
  name                = var.ranger_service
  zone_name           = data.azurerm_dns_zone.default[0].name
  resource_group_name = var.dns_rg
  ttl                 = 300
  records             = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

# Add Azure DNS Record sets
resource "azurerm_dns_a_record" "mc" {
  count               = var.create_nginx && var.create_mc ? 1 : 0

  provider            = azurerm.dns
  name                = var.mc_service
  zone_name           = data.azurerm_dns_zone.default[0].name
  resource_group_name = var.dns_rg
  ttl                 = 300
  records             = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

# Add Azure DNS Record sets
resource "azurerm_dns_a_record" "cloudbeaver" {
  count               = var.create_nginx && var.create_cloudbeaver ? 1 : 0

  provider            = azurerm.dns
  name                = var.cloudbeaver_service
  zone_name           = data.azurerm_dns_zone.default[0].name
  resource_group_name = var.dns_rg
  ttl                 = 300
  records             = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}


output starburst_url {
  value = var.create_nginx && var.create_trino ? trimsuffix(azurerm_dns_a_record.starburst[0].fqdn,".") : ""
}

output ranger_url {
  value = var.create_nginx && var.create_ranger ? trimsuffix(azurerm_dns_a_record.ranger[0].fqdn,".") : ""
}

output mc_url {
  value = var.create_nginx && var.create_mc ? trimsuffix(azurerm_dns_a_record.mc[0].fqdn,".") : ""
}

output cloudbeaver_url {
  value = var.create_nginx && var.create_cloudbeaver ? trimsuffix(azurerm_dns_a_record.cloudbeaver[0].fqdn,".") : ""
}