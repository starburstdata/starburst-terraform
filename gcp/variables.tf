variable project { }
variable credentials { }
variable sa_name { }

# VM machine types
variable primary_node_type {          default="e2-standard-8"}
variable worker_node_type {           default="e2-standard-4"}

# Preemtible flag for worker nodes
variable preemptible {              default=true}