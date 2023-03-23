# EC2 Node types
variable primary_node_type {            default="m5.2xlarge"}
variable worker_node_type {             default="m5.2xlarge"}
variable worker_node_types {            default=["m5.xlarge","m5a.xlarge","m5n.xlarge","m5.2xlarge","m5a.2xlarge","m5n.2xlarge"]}
variable capacity_type {                default="SPOT"} #SPOT or ON_DEMAND

# K8s resource offsets
variable cpu_offset {                 default=600 }
variable mem_offset {                 default=600000 }

# AWS "NoSchedule" node taint tags
variable node_taint_key {               default="kubernetes.io/nodetype"}
variable node_taint_value {             default="spot"}

# EKS autoscaling vars
variable create_metrics_server  {       default=true}
variable create_cluster_autoscaler {    default=true}
variable metrics_server_version {       default=""}
variable cluster_autoscaler_version {   default=""}
variable cluster_autoscaler_tag {       default=""}

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
