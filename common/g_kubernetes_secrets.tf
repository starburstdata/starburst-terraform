resource kubernetes_secret starburst_license {
  count   = var.create_k8s ? 1 : 0
  
  metadata {
    name = "starburst"
  }

  data = {
    "starburstdata.license" = file(var.sb_license)
  }

}
