# Variables
variable create_nginx { }
variable presto_service { }
variable ranger_service { }
variable mc_service { }
variable cloudbeaver_service { }
variable dns_zone { }
variable dns_zone_name { }
variable create_ranger { }
variable create_trino { }
variable create_mc { }
variable create_cloudbeaver { }


# Get the Nginx service details
data "kubernetes_service" "nginx" {
  count  = var.create_nginx ? 1 : 0

  metadata {
    #name = "nginx-nginx-ingress-controller"
    name = "ingress-nginx-controller"
  }
}

# Add Google DNS Record sets
resource "google_dns_record_set" "presto" {
  count = var.create_nginx && var.create_trino ? 1 : 0

  name = "${var.presto_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

resource "google_dns_record_set" "ranger" {
  count = var.create_nginx && var.create_ranger ? 1 : 0
  
  name = "${var.ranger_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

resource "google_dns_record_set" "mc" {
  count = var.create_nginx && var.create_mc ? 1 : 0
  
  name = "${var.mc_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

resource "google_dns_record_set" "cloudbeaver" {
  count = var.create_nginx && var.create_cloudbeaver ? 1 : 0
  
  name = "${var.cloudbeaver_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}


output starburst_url {
  value = var.create_nginx && var.create_trino ? trimsuffix(google_dns_record_set.presto[0].name,".") : ""
}

output ranger_url {
  value = var.create_nginx && var.create_ranger ? trimsuffix(google_dns_record_set.ranger[0].name,".") : ""
}

output mc_url {
  value = var.create_nginx && var.create_mc ? trimsuffix(google_dns_record_set.mc[0].name,".") : ""
}

output cloudbeaver_url {
  value = var.create_nginx && var.create_cloudbeaver ? trimsuffix(google_dns_record_set.cloudbeaver[0].name,".") : ""
}