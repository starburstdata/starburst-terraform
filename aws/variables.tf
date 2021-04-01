# EC2 Node types
variable primary_node_type {            default="m5.2xlarge"}
variable worker_node_type {             default="m5.xlarge"}
variable capacity_type {                default="SPOT"} #SPOT or ON_DEMAND

# AWS "NoSchedule" node taint tags
variable node_taint_key {           default="kubernetes.io/nodetype"}
variable node_taint_value {         default="spot"}

# AWS roles to attach to EKS & node pools
variable s3_role { }
variable map_roles {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  default = [
    {
      rolearn  = "arn:aws:iam::66666666666:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
}
