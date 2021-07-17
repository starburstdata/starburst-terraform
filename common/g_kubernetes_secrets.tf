resource kubernetes_secret starburst_license {
  count   = var.create_k8s ? 1 : 0
  
  metadata {
    name = "starburst"
  }

  data = {
    "starburstdata.license" = file(var.sb_license)
  }

}

resource kubernetes_secret ldap_cert {
  count   = var.ldap_cert == "" ? 0 : 1

  metadata {
    name = "ldaps-ca-jks"
  }

  data = {
    (var.ldap_cert) = file(var.ldap_cert)
  }

}