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