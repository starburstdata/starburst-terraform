variable primary_node_type {        default="Standard_D8s_v3"}
variable worker_node_type {         default= "Standard_D4s_v3"}

variable ex_resource_group {        default=""} # Use an existing resource group. If this is set, the app will assume you wish to use an existing RG
variable ex_vnet_name {             default=""} # The name of an existing VNet to use
variable ex_subnet_name {           default=""} # The name of an existing subnet within the VNet to use
variable create_vnet {              default=true}
variable dns_sub {                  default=""} # If left as the default empty string, then value of "subscription" is used
variable rg_name {                  default="rg"} # RG tag - used as part of the autogenerated RG name
variable dns_rg { }
variable partner_id {               default="eafd5cfa-bcd1-4d3e-98e0-f97508a02cae"}

# Azure "NoSchedule" node taint tags
variable node_taint_key {           default="kubernetes.azure.com/scalesetpriority"}
variable node_taint_value {         default="spot"}