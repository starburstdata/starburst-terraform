# NOTE: Don't put sensitive values in this file. Sensitivae values should be set as
#       global variables prefixed with "TF_VAR_" or in sensitive.auto.tfvars (create this file
#       in this directory if it does not already exist

# SB License and DNS zone
sb_license      = "~/Downloads/signed_trial.license"
dns_zone        = "az.starburstdata.net"
dns_rg          = "fieldeng" # The RG where the dns zone definition resides
#dns_sub        = The subscription where the dns zone resides. set in sensitive.auto.tfvars or in environment variable: $TF_VAR_dns_sub
region          = "East US"
#subscription   = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_subscription

# email address for certs
#email           = set in sensitive.auto.tfvars or in environment variable: $TF_VAR_email

# List of usernames to login to Trino & Ranger.
# NOTE: The first user in the list is assumed to be the admin user.
# The admin user has acess to both Trino and Ranger. The regular users only have access to Trino
# Use the admin user to set catalog and object permissions to the regular user in Ranger
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

# Optional tagging for cloud resources. Defined as a map of keys and values
# Replace with your own keys and values, or delete this if not needed
tags         = {cloud        = "az",
                environment  = "demo",
                org          = "partner",
                team         = "partner",
                project      = "training",
                user         = "starburst"
                }

# Infrastructure control
create_rds      = true
use_spot        = true  # If set, a dedicated SPOT node pool will be created.
use_ondemand    = false # If set, a dedicated ON_DEMAND node pool will be created

# K8s applications control
create_hive         = true
create_mc           = false
create_ranger       = true
create_trino        = true
create_cloudbeaver  = true

create_nginx        = true
