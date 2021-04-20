output gcp-infrastructure-details {
  value = tolist([
    var.create_k8s ?    "gke_cluster_name  = ${module.k8s.name}" : "No GKE Cluster deployed",
    var.create_vpc ?    "vpc_name          = ${module.vpc.vpc_name}" : "No new VPC deployed. Using existing VPC: ${var.ex_vpc_id}",
    var.create_bucket ? "gcs_bucket        = ${google_storage_bucket.bucket[0].name}" : "No new GCS bucket deployed"
  ])
}

output kubectl-profile {
  value = tolist([
    "gcloud container clusters get-credentials ${module.k8s.name} --zone ${var.zone}"
  ])
}