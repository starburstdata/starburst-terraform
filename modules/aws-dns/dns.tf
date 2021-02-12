# Variables
variable create_nginx { }
variable presto_service { }
variable ranger_service { }
variable mc_service { }
variable dns_zone { }

# Get the Nginx service details
data "kubernetes_service" "nginx" {
  count  = var.create_nginx ? 1 : 0

  metadata {
    name = "nginx-nginx-ingress-controller"
  }
}

# Get the dns info of the existing zone
data "aws_route53_zone" "primary" {
  count  = var.create_nginx ? 1 : 0

  name         = "${var.dns_zone}."
}

# Get the elb details. Name is derived from the hostname entry for the Nginx ELB
data aws_elb nginx {
  count  = var.create_nginx ? 1 : 0

  name          = split("-", data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname)[0]
}

# Add AWS DNS Record sets
resource "aws_route53_record" "presto" {
  count  = var.create_nginx ? 1 : 0

  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "${var.presto_service}.${var.dns_zone}"
  type    = "A"
  alias {
    name    = data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname
    zone_id = data.aws_elb.nginx[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ranger" {
  count  = var.create_nginx ? 1 : 0

  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "${var.ranger_service}.${var.dns_zone}"
  type    = "A"
  alias {
    name    = data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname
    zone_id = data.aws_elb.nginx[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "mc" {
  count  = var.create_nginx ? 1 : 0

  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "${var.mc_service}.${var.dns_zone}"
  type    = "A"
  alias {
    name    = data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname
    zone_id = data.aws_elb.nginx[0].zone_id
    evaluate_target_health = true
  }
}


output starburst_url {
  value = var.create_nginx ? trimsuffix(aws_route53_record.presto[0].name,".") : null
}

output ranger_url {
  value = var.create_nginx ? trimsuffix(aws_route53_record.ranger[0].name,".") : null
}

output mc_url {
  value = var.create_nginx ? trimsuffix(aws_route53_record.mc[0].name,".") : null
}