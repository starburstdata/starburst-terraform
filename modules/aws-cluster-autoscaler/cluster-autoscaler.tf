variable region { }
variable create_k8s { }
variable create_cluster_autoscaler { }
variable cluster_autoscaler_version { }
variable cluster_autoscaler_tag { }
variable primary_node_pool { }
variable cluster_name { }
variable cluster_id { }
variable worker_iam_role_name { }

# Data Sources
locals {
    helm_template_vars = {
        region               = var.region
        cluster_name         = var.cluster_name
        cluster_autoscaler_tag = var.cluster_autoscaler_tag
    }

    helm_chart_values = templatefile(
        "${path.root}/../helm_templates/cluster_autoscaler.tpl",
        local.helm_template_vars
    )

}

# IAM policy for autoscaling
resource "aws_iam_role_policy_attachment" "workers_autoscaling" {
  policy_arn = aws_iam_policy.worker_autoscaling.arn
  role       = var.worker_iam_role_name
}

resource "aws_iam_policy" "worker_autoscaling" {
  name_prefix = "eks-worker-autoscaling-${var.cluster_id}"
  description = "EKS worker node autoscaling policy for cluster ${var.cluster_id}"
  policy      = data.aws_iam_policy_document.worker_autoscaling.json
}

data "aws_iam_policy_document" "worker_autoscaling" {
  statement {
    sid    = "eksWorkerAutoscalingAll"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeLaunchTemplateVersions",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "eksWorkerAutoscalingOwn"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/kubernetes.io/cluster/${var.cluster_id}"
      values   = ["owned"]
    }

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/k8s.io/cluster-autoscaler/enabled"
      values   = ["true"]
    }
  }
}


# Deploy Priority Values for Cluster Autoscaler
resource "kubernetes_priority_class" "autoscaler" {
  metadata {
    name = "node-autoscaler"
  }

  value             = 1000000
  global_default    = false
  description       = "Highest priority for node autoscaler pods"
}

# Deploy resources
resource helm_release cluster-autoscaler {
  count  = var.create_k8s && var.create_cluster_autoscaler ? 1 : 0

  name      = "cluster-autoscaler"
  namespace = "kube-system"
  chart     = "cluster-autoscaler"
  version   = var.cluster_autoscaler_version

  repository = "https://kubernetes.github.io/autoscaler"

  force_update    = false
  cleanup_on_fail = true
  recreate_pods   = false
  reset_values    = false

  values              = [local.helm_chart_values]

  depends_on          = [kubernetes_priority_class.autoscaler,aws_iam_role_policy_attachment.workers_autoscaling]
}