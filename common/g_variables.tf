variable sb_license { }
variable ldap_cert {              default = ""}
variable dns_zone { }
variable dns_zone_name {          default = ""}
variable email { }
variable deployment_id {          default = ""} # Override the randomly generated deployment ID with a fixed value
variable prefix {                 default = "sb"}
variable region { }
variable zone {                   default = ""}
variable vpc_name {               default = "vpc"}
variable k8s_name {               default = "k8s"}
variable k8s_version {            default = "1.19"}
variable bucket_name {            default = "storage"}
variable storage_location {       default = "US"}
variable primary_node_pool {      default = "base"}
variable worker_node_pool {       default = "worker"}
variable primary_pool_size {      default = 1} 
variable worker_pool_min_size {   default = 1}  # Autoscaling parameters for the Kubernetes cluster nodes
variable worker_pool_max_size {   default = 10} # Autoscaling parameters for the Kubernetes cluster nodes
variable worker_autoscaling_min_size {   default = 1}   # Autoscaling parameters for the Starburst Worker nodes
variable worker_autoscaling_max_size {   default = 10}  # Autoscaling parameters for the Starburst Worker nodes
variable primary_db_instance {    default = "postgres"}
variable hive_service {           default = "hive"}
variable hive_service_type {      default = "clusterIp"}
variable starburst_service {      default = "starburst"}
variable ranger_service {         default = "ranger"}
variable mc_service {             default = "missioncontrol"}
variable cloudbeaver_service {    default = "cloudbeaver"}
variable expose_postgres_name {   default = "postgres"}
variable expose_sb_name {         default = "starburst"}
variable expose_ranger_name {     default = "ranger"}
variable expose_mc_name {         default = "starburst-mission-control"}
variable expose_cloudbeaver_name {default = "cloudbeaver"}
variable wait_this_long {         default = "60s"} # default wait time to use when waiting on resources 
variable hive_yaml_file {           default = "hms_values.yaml.tpl"}
variable ranger_yaml_file {         default = "ranger_values.yaml.tpl"}
variable mc_yaml_file {             default = "mission_control.yaml.tpl"}
variable operator_yaml_file {       default = "operator_values.yaml.tpl"}
variable postgres_yaml_file {       default = "postgresql.yaml.tpl"}
variable cloudbeaver_yaml_file {    default = "cloudbeaver_values.yaml.tpl"}
variable custom_trino_yaml_file {   default = ""}
variable custom_ranger_yaml_file {  default = ""}
variable custom_hive_yaml_file {    default = ""}

# Starburst Worker Autoscaling and Graceful shutdown
variable targetCPUUtilizationPercentage {               default = 80}
variable deploymentTerminationGracePeriodSeconds {      default = 300}
variable starburstWorkerShutdownGracePeriodSeconds {    default = 120}

# External Hive RDS
variable ex_hive_instance {       default = ""} # If this value is set, a database for Hive WILL NOT be created
variable ex_hive_port {           default = ""}
variable ex_hive_db {             default = ""}
variable ex_hive_db_user {        default = ""}
variable ex_hive_db_password {    default = ""}

# External Ranger RDS
variable ex_ranger_instance {           default = ""} # If this value is set, a database for Ranger WILL NOT be created
variable ex_ranger_port {               default = ""}
variable ex_ranger_db {                 default = ""}
variable ex_ranger_root_user {          default = ""}
variable ex_ranger_root_password {      default = ""}
variable ex_ranger_db_user {            default = ""}
variable ex_ranger_db_password {        default = ""}
# Ranger internal users:
variable ex_ranger_admin_pwd {          default = ""}
variable ex_ranger_keyadmin_pwd {       default = ""}
variable ex_ranger_service_pwd {        default = ""}
variable ex_ranger_tagsync_pwd {        default = ""}
variable ex_ranger_usersync_pwd {       default = ""}

# External Mission Control RDS
variable ex_mc_instance {         default = ""} # If this value is set, a database for MC WILL NOT be created
variable ex_mc_port {             default = ""}
variable ex_mc_db {               default = ""}
variable ex_mc_db_user {          default = ""}
variable ex_mc_db_password {      default = ""}

# External Insights RDS
variable ex_insights_instance {    default = ""} # If this value is set, a database for Insights WILL NOT be created
variable ex_insights_port {        default = ""}
variable ex_insights_db {          default = ""}
variable ex_insights_db_user {     default = ""}
variable ex_insights_db_password { default = ""}

# External Cache Redirection RDS
variable ex_cache_instance {    default = ""} # If this value is set, a database for Cache Redirection WILL NOT be created
variable ex_cache_port {        default = ""}
variable ex_cache_db {          default = ""}
variable ex_cache_db_user {     default = ""}
variable ex_cache_db_password { default = ""}


# External HMS
variable ex_hive_server_url {      default = ""}

# External VPC/VNET
variable ex_vpc_id {               default=""}

# AKS Node pools
# Not mutually exclusive. If both are set to true, you will have 2 worker node pools. If both are set to false,
# you won't have any worker pools
variable use_ondemand {             default=true}
variable use_spot {                 default=false}

# Additional tags for resources
variable tags {                    default={manager = "starburst-terraform"}}

# Harbor details
variable repository { }
variable registry { }
variable repo_username { }
variable repo_password { }
# Chart versions
variable repo_version { }
## Override these in your tfvars file, otherwise repo_version is assumed
variable hms_version {            default = null}
variable sb_version {             default = null}
variable ranger_version {         default = null}
variable mc_version {             default = null}
variable operator_version {       default = null}

# Object storage credentials
# GCS
variable gcp_cloud_key_secret {     default = ""}
# ADL
variable adl_oauth2_client_id {     default = ""}
variable adl_oauth2_credential {    default = ""}
variable adl_oauth2_refresh_url {   default = ""}
# AWS S3
variable s3_access_key {            default = ""}
variable s3_endpoint {              default = ""}
variable s3_region {                default = ""}
variable s3_secret_key {            default = ""}
# Azure ADLS
variable abfs_access_key {          default = ""}
variable abfs_storage_account {     default = ""}
variable abfs_auth_type {           default = "oauth"} # "accessKey" or "oauth"
variable abfs_client_id {           default = ""}
variable abfs_endpoint {            default = ""}
variable abfs_secret {              default = ""}
variable wasb_access_key {          default = ""}
variable wasb_storage_account {     default = ""}

# Ranger/Starburst login users
variable admin_user {               default = "sbadmin"}
variable admin_pass {               default = ""}
variable reg_user1 {                default = "sbuser1"}
variable reg_pass1 {                default = ""}
variable reg_user2 {                default = "sbuser2"}
variable reg_pass2 {                default = ""}

# Control the creation of Cloud Infrastructure Objects
variable create_bucket {          default = true}
variable create_vpc {             default = true}
variable create_k8s {             default = true}

# Control the deployment of Kubernetes applications
variable create_rds {             default = true}
variable create_hive {            default = true}
variable create_mc {              default = true}
variable create_ranger {          default = true}
variable create_trino {           default = true}
variable create_demo {            default = true}
variable create_nginx {           default = true}
variable create_cloudbeaver {     default = true}

# debug flag
variable debug_this {             default = false}