# Variables
variable create_nginx { }
variable presto_service { }
variable ranger_service { }
variable mc_service { }
variable dns_zone { }
variable dns_zone_name { }

# Get the Nginx service details
data "kubernetes_service" "nginx" {
  count  = var.create_nginx ? 1 : 0

  metadata {
    name = "nginx-nginx-ingress-controller"
  }
}

# Add Google DNS Record sets
resource "google_dns_record_set" "presto" {
  count = var.create_nginx ? 1 : 0

  name = "${var.presto_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

resource "google_dns_record_set" "ranger" {
  count = var.create_nginx ? 1 : 0
  
  name = "${var.ranger_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}

resource "google_dns_record_set" "mc" {
  count = var.create_nginx ? 1 : 0
  
  name = "${var.mc_service}.${var.dns_zone}."
  type = "A"
  ttl  = 3600

  managed_zone = var.dns_zone_name

  rrdatas = [data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].ip]
}


output starburst_url {
  value = var.create_nginx ? trimsuffix(google_dns_record_set.presto[0].name,".") : null
}

output ranger_url {
  value = var.create_nginx ? trimsuffix(google_dns_record_set.ranger[0].name,".") : null
}

output mc_url {
  value = var.create_nginx ? trimsuffix(google_dns_record_set.mc[0].name,".") : null
}