# Variables
variable create_nginx { }
variable starburst_service { }
variable ranger_service { }
variable cloudbeaver_service { }
variable mc_service { }
variable dns_zone { }
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
resource "aws_route53_record" "starburst" {
  count  = var.create_nginx && var.create_trino ? 1 : 0

  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "${var.starburst_service}.${var.dns_zone}"
  type    = "A"
  alias {
    name    = data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname
    zone_id = data.aws_elb.nginx[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "ranger" {
  count  = var.create_nginx && var.create_ranger ? 1 : 0

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
  count  = var.create_nginx && var.create_mc ? 1 : 0

  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "${var.mc_service}.${var.dns_zone}"
  type    = "A"
  alias {
    name    = data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname
    zone_id = data.aws_elb.nginx[0].zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cloudbeaver" {
  count  = var.create_nginx && var.create_cloudbeaver ? 1 : 0

  zone_id = data.aws_route53_zone.primary[0].zone_id
  name    = "${var.cloudbeaver_service}.${var.dns_zone}"
  type    = "A"
  alias {
    name    = data.kubernetes_service.nginx[0].status[0].load_balancer[0].ingress[0].hostname
    zone_id = data.aws_elb.nginx[0].zone_id
    evaluate_target_health = true
  }
}


output starburst_url {
  value = var.create_nginx && var.create_trino ? trimsuffix(aws_route53_record.starburst[0].name,".") : ""
}

output ranger_url {
  value = var.create_nginx && var.create_ranger ? trimsuffix(aws_route53_record.ranger[0].name,".") : ""
}

output mc_url {
  value = var.create_nginx && var.create_mc ? trimsuffix(aws_route53_record.mc[0].name,".") : ""
}

output cloudbeaver_url {
  value = var.create_nginx && var.create_cloudbeaver ? trimsuffix(aws_route53_record.cloudbeaver[0].name,".") : ""
}