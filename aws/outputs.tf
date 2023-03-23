output aws-infrastructure-details {
  value = tolist([
    "eks_cluster_name     = ${module.k8s.cluster_name}",
    var.create_vpc ? "vpc_name             = ${module.vpc.name}" : "No VPC Deployed, using existing VPC: ${var.ex_vpc_id}",
    var.create_bucket ? "s3_bucket            = ${local.bucket_name}" : "No S3 Bucket Deployed"
  ])
}
