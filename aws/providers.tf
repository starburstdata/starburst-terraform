terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 4.59.0"
        }
        kubernetes = {
            source  = "hashicorp/kubernetes"
            version = ">= 2.18.1"
        }
        helm        = ">= 2.9.0"
    }
}        

# Configure the AWS Provider
provider "aws" {
    region = var.region
}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.cluster[0].endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data)
    #token                  = data.aws_eks_cluster_auth.cluster.token
    exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", module.k8s.cluster_name]
        command     = "aws"
    }
}

provider helm {
    kubernetes {
        host                   = data.aws_eks_cluster.cluster[0].endpoint
        cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster[0].certificate_authority.0.data)
        #token                  = data.aws_eks_cluster_auth.cluster.token
        exec {
            api_version = "client.authentication.k8s.io/v1beta1"
            args        = ["eks", "get-token", "--cluster-name", module.k8s.cluster_name]
            command     = "aws"
        }
    }
}