output gcp-infrastructure-details {
  value = list(
    "gke_cluster_name     = ${module.k8s.name}",
    "vpc_name             = ${module.vpc.vpc_name}",
    "gcs_bucket           = ${google_storage_bucket.bucket.name}"
  )
}
