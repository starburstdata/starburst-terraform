# AWS Infrastructure to be deployed
#
# Ensure you either have set the symbolic links to the global variable files (../common/g_*)
# or you have copied these into this folder
#
# e.g.  ln -s ../common/g_data_sources.tf g_data_sources.tf
#       ln -s ../common/g_kubernetes_secrets.tf g_kubernetes_secrets.tf
#       ln -s ../common/g_variables.tf g_variables.tf
#

module vpc {
    source  = "terraform-aws-modules/vpc/aws"
    version = "2.66.0"

    name                 = local.vpc_name
    cidr                 = "172.31.0.0/16"
    azs                  = data.aws_availability_zones.available.names
    public_subnets       = ["172.31.74.0/24","172.31.75.0/24","172.31.76.0/24"]
    enable_dns_hostnames = true

    public_subnet_tags = {
        "kubernetes.io/cluster/${local.cluster_name}" = "shared"
        "kubernetes.io/role/elb"                      = "1"
    }

    # Public access to RDS
    create_database_subnet_group           = true
    create_database_subnet_route_table     = true
    create_database_internet_gateway_route = true

    tags              = local.common_tags
    create_vpc        = var.create_vpc
}

module k8s {
  source  = "terraform-aws-modules/eks/aws"
  version = "13.2.1"

  cluster_name    = local.cluster_name
  cluster_version = var.k8s_version
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id

  worker_groups = [
    {
      name                          = var.primary_node_pool
      instance_type                 = var.primary_node_type
      asg_max_size                  = var.primary_pool_size
      kubelet_extra_args            = "--node-labels=agentpool=${var.primary_node_pool}"
      suspended_processes           = ["AZRebalance"]
    },
    {
      name                          = var.worker_node_pool
      instance_type                 = var.worker_node_type
      asg_min_size                  = var.worker_pool_min_size
      asg_max_size                  = var.worker_pool_max_size
      kubelet_extra_args            = "--node-labels=agentpool=${var.worker_node_pool}"
      suspended_processes           = ["AZRebalance"]
    }
  ]

  # Attach S3 policy to allow worker nodes to interact with Glue/S3
  workers_additional_policies = var.s3_role

  write_kubeconfig   = true
  config_output_path = "./"

  map_roles         = var.map_roles

  tags              = local.common_tags
  create_eks        = var.create_k8s

  depends_on        = [module.vpc]
}

module s3_bucket {
  source            = "terraform-aws-modules/s3-bucket/aws"

  bucket            = local.bucket_name
  acl               = "private"
  force_destroy     = true

  tags              = local.common_tags
  create_bucket     = var.create_bucket
}

data "aws_availability_zones" "available" { }

data "aws_eks_cluster" "cluster" {
  name = module.k8s.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.k8s.cluster_id
}

data "aws_security_group" "default" {
  vpc_id = module.vpc.vpc_id
  name   = "default"
}
