# NOTE: Don't put sensitive values in this file. Sensitivae values should be set as
#       global variables prefixed with "TF_VAR_" or in sensitive.auto.tfvars (create this file
#       in this directory if it does not already exist

# SB License and DNS zone
sb_license      = "~/signed_trial.license"
dns_zone        = "az.starburstdata.net"
dns_rg          = "fieldeng" # The RG where the dns zone definition resides
region          = "East US"

# email address for certs
#email           = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_email

# List of usernames to login to Trino & Ranger.
# NOTE: The first user in the list is assumed to be the admin user.
# The admin user has acess to both Trino and Ranger. The regular users only have access to Trino
# Use the admin user to set catalog and object permissions to the regular user in Ranger
admin_user      = "sbadmin"

# Helm Repository details
repository      = "https://harbor.starburstdata.net/chartrepo/starburstdata"
registry        = "harbor.starburstdata.net/starburstdata"
#repo_username   = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_repo_username
#repo_password   = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_repo_password
repo_version        = "354.0.0"
starburst_version   = "354-e"

# Yaml files for Helm deployments. Terraform logic will deal with situations where more than one
# yaml file has been specified - as is the case with Trino below
hive_yaml_file      = "hms_values.yaml.tpl"
trino_yaml_file     = ["trino_values.yaml.tpl","trino_values.withInsightsMetrics.yaml.tpl"]
ranger_yaml_file    = "ranger_values.yaml.tpl"
mc_yaml_file        = "mission_control.yaml.tpl"
operator_yaml_file  = "operator_values.yaml.tpl"
postgres_yaml_file  = "postgresql.yaml.tpl"
cloudbeaver_yaml_file   = "cloudbeaver_values.yaml.tpl"

# Resource tagging variables
ch_cloud        = "azure"
#ch_environment = automatically set to the Terraform workspace name
ch_org          = "bizdev"
ch_team         = "psa"
ch_project      = "lab"
#ch_user        = set your user identity. Can be any value you like. Defaults to "starburst"

# Infrastructure control
create_rds      = true

# K8s applications control
create_hive         = true
create_mc           = false
create_ranger       = true
create_trino        = true
create_cloudbeaver  = true

create_nginx        = true

# Debug flag
debug_this      = false