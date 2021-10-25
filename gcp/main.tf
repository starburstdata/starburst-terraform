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
  ex_vpc_id   = var.ex_vpc_id
  region      = var.region

  create_vpc  = var.create_vpc
}

resource "google_storage_bucket" "bucket" {
  count         = var.create_bucket ? 1 : 0

  name          = local.bucket_name
  location      = var.storage_location
  force_destroy = true

  uniform_bucket_level_access = true
}

module k8s {
  source                = "../modules/gcp-gke"
  cluster_name          = local.cluster_name
  location              = var.zone
  primary_node_pool     = var.primary_node_pool
  worker_node_pool      = var.worker_node_pool
  primary_node_vm       = var.primary_node_type
  worker_node_vm        = var.worker_node_type
  primary_pool_size     = var.primary_pool_size
  worker_pool_min_size  = var.worker_pool_min_size
  worker_pool_max_size  = var.worker_pool_max_size
  use_ondemand          = var.use_ondemand
  use_preemptible       = var.use_preemptible
  vpc                   = module.vpc.vpc_name
  node_taint_key        = var.node_taint_key
  node_taint_value      = var.node_taint_value

  create_k8s            = var.create_k8s

  tags                  = local.common_tags

  depends_on            = [module.vpc] 
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
    command = "gcloud container clusters get-credentials ${module.k8s.name} --zone ${var.zone} --project ${var.project}"
    interpreter = ["bash","-c"]
  }

  depends_on        = [module.k8s]
}

data "external" "worker_nodes" {
  count   = 1
  program = ["bash", "-c", "kubectl get nodes --selector='starburstpool=${var.worker_node_pool}' -o jsonpath='{.items[0].status.allocatable}'"]

  depends_on        = [module.k8s,null_resource.configure_kubectl]
}

data "external" "primary_nodes" {
  count   = 1
  program = ["bash", "-c", "kubectl get nodes --selector='starburstpool=${var.primary_node_pool}' -o jsonpath='{.items[0].status.allocatable}'"]

  depends_on        = [module.k8s,null_resource.configure_kubectl]
}
