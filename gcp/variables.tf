variable project { }
#variable credentials { }
#variable sa_name { }

# VM machine types
variable primary_node_type {          default="e2-standard-8"}
variable worker_node_type {           default="e2-standard-8"}

# K8s resource offsets
variable cpu_offset {                 default=600 } # e2-standard-4 = 220
variable mem_offset {                 default=600000 } # e2-standard-4 = 300k

# Preemtible flag for worker nodes
variable use_preemptible {            default=true}

# GCP "NoSchedule" node taint tags
variable node_taint_key {           default="kubernetes.io/nodetype"}
variable node_taint_value {         default="worker"}