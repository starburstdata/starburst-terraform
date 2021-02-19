variable sb_license { }
variable dns_zone { }
variable dns_zone_name {          default = ""}
variable email { }

variable prefix {                 default = "sb"}
variable region { }
variable zone {                   default = ""}
variable vpc_name {               default = "vpc"}
variable k8s_name {               default = "k8s"}
variable bucket_name {            default = "storage"}
variable storage_location {       default = "US"}
variable primary_node_pool {      default = "demobase"}
variable worker_node_pool {       default = "demopresto"}
variable primary_db_instance {    default = "postgres"}
variable hive_service {           default = "hive"}
variable presto_service {         default = "presto"}
variable ranger_service {         default = "ranger"}
variable mc_service {             default = "missioncontrol"}
variable expose_postgres_name {   default = "postgresql"}
variable expose_sb_name {         default = "starburst"}
variable expose_ranger_name {     default = "ranger"}
variable expose_mc_name {         default = "missioncontrol"}
variable hive_yaml_file { }
variable trino_yaml_file { }
variable ranger_yaml_file { }
variable mc_yaml_file { }
variable operator_yaml_file { }
variable postgres_yaml_file { }

# Additional tags for resources
variable ch_cloud { }
variable ch_org { }
variable ch_team { }
variable ch_project { }
variable ch_user {                default = "starburst"}

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

# Starburst-Trino versions
variable presto_version { }

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
variable admin_user { }

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

# debug flag
variable debug_this {             default = false}