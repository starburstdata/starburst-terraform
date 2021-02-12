# GCP Infrastructure to be deployed
#
# Ensure you either have set the symbolic links to the global variable files (../common/g_*)
# or you have copied these into this folder
#
# e.g.  ln -s ../common/g_data_sources.tf g_data_sources.tf
#       ln -s ../common/g_kubernetes_secrets.tf g_kubernetes_secrets.tf
#       ln -s ../common/g_variables.tf g_variables.tf
#

module vpc {
  source      = "../modules/gcp-vpc"
  vpc_name    = local.vpc_name
  region      = var.region
}

resource "google_storage_bucket" "bucket" {
  name          = local.bucket_name
  location      = var.storage_location
  force_destroy = true

  uniform_bucket_level_access = true
}

module cloud_sql {
  source              = "../modules/gcp-cloud-sql"
  region              = var.region
  zone                = var.zone
  primary_db_instance = local.db_name
  primary_db_version  = "POSTGRES_12"
  primary_db_user     = "gcpadmin"
  vpc_id              = module.vpc.vpc_id

  create_rds          = var.create_rds

  depends_on          = [module.vpc,module.gke] 
}

module gke {
  source            = "../modules/gcp-gke"
  cluster_name      = local.cluster_name
  location          = var.zone
  primary_node_pool = var.primary_node_pool
  worker_node_pool  = var.worker_node_pool
  primary_node_vm   = "e2-standard-8"
  worker_node_vm    = "e2-standard-4"
  vpc               = module.vpc.vpc_name

  depends_on        = [module.vpc] 
}

# Save SA credentials as a secret in Kubernetes. Needed for GCS/BigQuery access
resource kubernetes_secret dns_sa_credentials {
  metadata {
    name = var.gcp_cloud_key_secret
  }
  data = {
    "key.json" = file(var.credentials)
  }
}

# Update the local kubectl config
resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${module.gke.name} --zone ${var.zone} --project ${var.project}"
    interpreter = ["bash","-c"]
  }

  depends_on        = [module.gke]
}

# Create databases needed for deployment
#resource "google_sql_database" "databases" {
#  for_each      = var.create_rds ? toset(var.databases) : []

#  name          = each.value
#  instance      = module.cloud_sql.identifier

#  depends_on    = [module.cloud_sql]
#}

# Create databases necessary to support the applications
resource "postgresql_database" "databases" {
    for_each            = var.create_rds ? toset(var.databases) : []
    
    name                = each.value
    connection_limit    = -1
    allow_connections   = true

    depends_on          = [module.cloud_sql]
}
