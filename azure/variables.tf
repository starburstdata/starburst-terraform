variable primary_node_type {        default="Standard_D8s_v3"}
variable worker_node_type {         default= "Standard_D4s_v3"}

variable subscription { }
variable dns_sub {                  default=""} # If left as the default empty string, then value of "subscription" is used
variable rg_name {                  default="rg"}
variable dns_rg { }
variable partner_id {               default="eafd5cfa-bcd1-4d3e-98e0-f97508a02cae"}

# AKS Node pools
# Not mutually exclusive. If both are set to true, you will have 2 worker node pools. If both are set to false,
# you won't have any worker pools
variable use_ondemand {             default=true}
variable use_spot {                 default=false}

# Azure "NoSchedule" node taint tags
variable node_taint_key {           default="kubernetes.azure.com/scalesetpriority"}
variable node_taint_value {         default="spot"}