terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 3.48"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.3.2"
        }
        helm        = ">= 2.2.0"
        postgresql = {
            source = "cyrilgdn/postgresql"
            version = ">= 1.13.0"
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
    host                   = data.aws_eks_cluster.cluster[0].endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data)
    #token                  = data.aws_eks_cluster_auth.cluster.token
    exec {
        api_version = "client.authentication.k8s.io/v1alpha1"
        args        = ["eks", "get-token", "--cluster-name", module.k8s.cluster_id]
        command     = "aws"
    }
}

provider helm {
    kubernetes {
        host                   = data.aws_eks_cluster.cluster[0].endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data)
        #token                  = data.aws_eks_cluster_auth.cluster.token
        exec {
            api_version = "client.authentication.k8s.io/v1alpha1"
            args        = ["eks", "get-token", "--cluster-name", module.k8s.cluster_id]
            command     = "aws"
        }
    }
}