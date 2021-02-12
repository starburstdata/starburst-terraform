resource kubernetes_secret starburst_license {

  metadata {
    name = "starburst"
  }

  data = {
    "starburstdata.license" = file(var.sb_license)
  }

}
