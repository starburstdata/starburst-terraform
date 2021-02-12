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
#email           = set here or in environment variable: $TF_VAR_email

# Admin username to login to Ranger. This user will have full access to all catalogs and objects
admin_user      = "sbadmin"

# Databases required
databases       = ["hive","ranger","mcdemo","demo","event_logger"]

# Helm Repository details
repository      = "https://harbor.starburstdata.net/chartrepo/starburstdata"
registry        = "harbor.starburstdata.net/starburstdata"
#repo_username   = set here or in environment variable: $TF_VAR_repo_username
#repo_password   = set here or in environment variable: $TF_VAR_repo_password
repo_version    = "350.1.1"
presto_version  = "350-e.1"

# Yaml files for Helm deployments. Terraform logic will deal with situations where more than one
# yaml file has been specified - as is the case with Trino below
hive_yaml_file      = "hms_values.yaml.tpl"
trino_yaml_file     = ["trino_values.yaml.tpl","trino_values.withInsightsMetrics.yaml.tpl"]
ranger_yaml_file    = "ranger_values.yaml.tpl"
mc_yaml_file        = "mission_control.yaml.tpl"
operator_yaml_file  = "operator_values.yaml.tpl"

# Resource tagging variables
ch_cloud        = "gcp"
ch_org          = "bizdev"
ch_team         = "psa"
ch_project      = "lab"

# Block creating these resources by setting them to false. Default is true if undefined here
create_rds      = true
create_hive     = true
create_mc       = true
create_ranger   = true
create_trino    = true
create_nginx    = false