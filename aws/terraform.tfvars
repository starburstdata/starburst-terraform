# SB License and DNS zone
sb_license      = "~/signed_trial.license"
dns_zone        = "aws.starburstdata.net"
region          = "us-east-1"
s3_role         = ["arn:aws:iam::188806360106:policy/EKS-S3-Glue"]

map_roles       = [{rolearn    = "arn:aws:iam::188806360106:role/solution_architect",
                    username   = "solution_architect",
                    groups     = ["system:masters"]
                    }]

# email address for certs
#email           = set by environment variable: $TF_VAR_email

# List of usernames to login to Trino & Ranger.
# NOTE: The first user in the list is assumed to be the admin user.
# The admin user has acess to both Trino and Ranger. The regular users only have access to Trino
# Use the admin user to set catalog and object permissions to the regular user in Ranger
admin_user      = "sbadmin"

# Databases required
databases       = ["hive","ranger","mcdemo","demo","event_logger"]

# Helm Repository details
repository      = "https://harbor.starburstdata.net/chartrepo/starburstdata"
registry        = "harbor.starburstdata.net/starburstdata"
#repo_username   = set by environment variable: $TF_VAR_repo_username
#repo_password   = set by environment variable: $TF_VAR_repo_password
repo_version    = "350.1.1" # For Trino, Ranger & Hive
presto_version  = "350-e.1" # For Mission Control & Presto Operator

# Yaml files for Helm deployments. Terraform logic will deal with situations where more than one
# yaml file has been specified - as is the case with Trino below
hive_yaml_file      = "hms_values.yaml.tpl"
trino_yaml_file     = ["trino_values.yaml.tpl","trino_values.withInsightsMetrics.yaml.tpl"]
ranger_yaml_file    = "ranger_values.yaml.tpl"
mc_yaml_file        = "mission_control.yaml.tpl"
operator_yaml_file  = "operator_values.yaml.tpl"

# Resource tagging variables
ch_cloud        = "aws"
ch_org          = "bizdev"
ch_team         = "psa"
ch_project      = "lab"

# Block creating these resources
create_rds      = false
create_hive     = true
create_mc       = false
create_ranger   = true
create_trino    = true
create_nginx    = false