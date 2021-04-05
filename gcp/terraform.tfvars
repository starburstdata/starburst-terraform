# NOTE: Don't put sensitive values in this file. Sensitivae values should be set as
#       global variables prefixed with "TF_VAR_" or in sensitive.auto.tfvars (create this file
#       in this directory if it does not already exist

# GCP Cloud credentials, Service Account Name, Project and DNS zone
project         = "cogent-summer-299514"
credentials     = "~/key.json"
sb_license      = "~/signed_trial.license"
sa_name         = "partner-demo"
dns_zone        = "gcp.starburstdata.net"
dns_zone_name   = "gcp"

region          = "us-east4"
zone            = "us-east4-b"

# Service Account Secret name in K8s
gcp_cloud_key_secret = "service-account-key"

# email address for certs
#email           = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_email

# Admin username to login to Ranger. This user will have full access to all catalogs and objects
admin_user      = "sbadmin"
reg_user1       = "engineer"
reg_user2       = "analyst"

# Helm Repository details
repository      = "https://harbor.starburstdata.net/chartrepo/starburstdata"
registry        = "harbor.starburstdata.net/starburstdata"
#repo_username   = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_repo_username
#repo_password   = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_repo_password
repo_version        = "354.0.0"
starburst_version   = "354-e"

# Yaml files for Helm deployments. Terraform logic will deal with situations where more than one
# yaml file has been specified - as is the case with Trino below
hive_yaml_file          = "hms_values.yaml.tpl"
trino_yaml_file         = ["trino_values.yaml.tpl","trino_values.withInsightsMetrics.yaml.tpl"]
ranger_yaml_file        = "ranger_values.yaml.tpl"
mc_yaml_file            = "mission_control.yaml.tpl"
operator_yaml_file      = "operator_values.yaml.tpl"
postgres_yaml_file      = "postgresql.yaml.tpl"
cloudbeaver_yaml_file   = "cloudbeaver_values.yaml.tpl"

# Resource tagging variables
cloud        = "az"         # aws | gcp | az
environment  = "demo"       # prod | dev | test | demo | debug
org          = "partner"    # cs | sales | enablement | partner
team         = "partner"    # tam |  cse | sa | partner
#project     = automatically set to the Terraform workspace name
#user        = set your user identity. Can be any value you like. Defaults to "starburst"

# Infrastructure control
create_rds          = true

# K8s applications control
create_hive         = true
create_mc           = false
create_ranger       = true
create_trino        = true
create_cloudbeaver  = true

create_nginx        = true