terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = "~> 2.0.0"
        }
        helm        = "~> 2.0.1"
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = "1.11.1"
        }
    }
}        

# Configure the AWS Provider
provider "aws" {
    region = var.region
}

# Provider
provider "postgresql" {
    host            = module.db.db_ingress
    port            = module.db.db_port
    database        = module.db.db_name
    username        = module.db.primary_db_user
    password        = module.db.primary_db_password
    connect_timeout = 15
    sslmode         = "disable"
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    #token                  = data.aws_eks_cluster_auth.cluster.token
    exec {
        api_version = "client.authentication.k8s.io/v1alpha1"
        args        = ["eks", "get-token", "--cluster-name", module.k8s.cluster_id]
        command     = "aws"
    }
}

provider helm {
    kubernetes {
        host                   = data.aws_eks_cluster.cluster.endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
        #token                  = data.aws_eks_cluster_auth.cluster.token
        exec {
            api_version = "client.authentication.k8s.io/v1alpha1"
            args        = ["eks", "get-token", "--cluster-name", module.k8s.cluster_id]
            command     = "aws"
        }
    }
}