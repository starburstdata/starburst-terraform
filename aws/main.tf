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
    version = "3.19.0"

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
  version = "19.10.1"

  cluster_name    = local.cluster_name
  cluster_version = var.k8s_version
  subnet_ids      = var.create_vpc ? module.vpc.public_subnets : data.aws_subnets.subnet[0].ids
  vpc_id          = var.create_vpc ? module.vpc.vpc_id : var.ex_vpc_id

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_group_defaults = {
    #instance_type                          = var.primary_node_type
    update_launch_template_default_version = true
    iam_role_additional_policies = {
      AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      additional = var.s3_role
    }
  }

  eks_managed_node_groups = {
    (var.primary_node_pool) = {
      desired_size    = var.primary_pool_size
      max_size        = var.primary_pool_size
      min_size        = var.primary_pool_size

      instance_types = [var.primary_node_type]
      labels = {
        starburstpool = var.primary_node_pool
      }
    },
    (var.worker_node_pool) = {
      desired_size    = var.worker_pool_min_size
      max_size        = var.worker_pool_max_size
      min_size        = var.worker_pool_min_size

      instance_types = var.capacity_type == "SPOT" ? var.worker_node_types : [var.worker_node_type]
      capacity_type  = var.capacity_type
      labels = {
        starburstpool = var.worker_node_pool
      }
      tags = {
        "k8s.io/cluster-autoscaler/enabled" = true
        "k8s.io/cluster-autoscaler/${local.cluster_name}" = true
      }
    }
  }

  tags              = local.common_tags
  create            = var.create_k8s

  depends_on        = [module.vpc,data.aws_subnets.subnet]
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
  count = var.create_k8s ? 1 : 0
  name = module.k8s.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_k8s ? 1 : 0
  name = module.k8s.cluster_name
}

data aws_subnets subnet {
  count = var.ex_vpc_id != "" ? 1 : 0
  filter {
    name   = "vpc-id"
    values = [var.ex_vpc_id]
  }
  #vpc_id = var.ex_vpc_id
}

# data "aws_security_group" "default" {
#   #vpc_id = module.vpc.vpc_id
#   vcp_id = var.ex_vpc_id != "" ? data.aws_vpc.new_vpc.id : data.aws_vpc.default_vpc
#   name   = "default"
# }


# Update the local kubectl config
resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --name ${local.cluster_name} --region ${var.region}"
    interpreter = ["bash","-c"]
  }

  depends_on        = [module.k8s]
}

data "external" "worker_nodes" {
  count   = 1 #var.worker_cpu == "" || var.worker_mem == "" ? 1 : 0
  program = ["bash", "-c", "kubectl get nodes --selector='starburstpool=${var.worker_node_pool}' -o jsonpath='{.items[0].status.allocatable}'"]

  depends_on        = [module.k8s,null_resource.configure_kubectl]
}

data "external" "primary_nodes" {
  count   = 1 #var.coordinator_cpu == "" || var.coordinator_mem == "" ? 1 : 0
  program = ["bash", "-c", "kubectl get nodes --selector='starburstpool=${var.primary_node_pool}' -o jsonpath='{.items[0].status.allocatable}'"]

  depends_on        = [module.k8s,null_resource.configure_kubectl]
}
