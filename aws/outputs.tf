output aws-infrastructure-details {
  value = list(
    "eks_cluster_name     = ${module.k8s.cluster_id}",
    "vpc_name             = ${module.vpc.name}",
    "s3_bucket            = ${local.bucket_name}"
  )
}
