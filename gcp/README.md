# Starburst-Terraform deployment for GCP
Deployment scripts built for GCP.

### Prerequisites
Ensure you have [gcloud cli](https://cloud.google.com/sdk/docs/install), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [helm](https://helm.sh/docs/intro/install/) installed and configured according to the cloud provider's documentation.

Ensure that the GCP project you are working in has the following APIs enabled:

*These commands can be run from your command line*
```
gcloud services enable sqladmin.googleapis.com
gcloud services enable sql-component.googleapis.com
gcloud services enable dns.googleapis.com
gcloud services enable storage-api.googleapis.com
gcloud services enable storage-component.googleapis.com
gcloud services enable storage.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable container.googleapis.com
```

## Set up
1. Create a Service Account in GCP for Terraform to work with. Ensure that the service account includes the following IAM permissions:

    - Kubernetes Engine Admin
    - DNS Administrator
    - Editor
    - Service Networking Admin
    - Storage Admin 

2. Generate a key and save it locally

3. Copy your Starburst license to the same location

4. Edit the `terraform.tfvars` file for your environment. Pay attention to the following variables, which can be set in this file or as global variables (TF_VAR_*) on your local machine:
    - `project`
    - `credentials` *(point to your local file)*
    - `sb_license` *(point to your local file)*
    - `sa_name`
    - `email`
    - `repo_username`
    - `repo_password`

5. Create a workspace in Terraform for your deployment:
```
terraform workspace new ${your-workspace-name}
```
6. Initialize the Terraform environment:
```
terraform init
```
7. Deploy your environment:
```
terraform deploy
```

## Undeploy
To delete all resources created in this deployment:
```
terraform destroy
```

___
## Input Parameters
|  Parameter | Description | Required | Default |
|---|---|---|---|
| admin_user | Admin login credentials for Ranger | yes | sbadmin |
| ch_cloud | Tag for cloud resource objects | no |  |
| ch_environment | Tag for cloud resource objects | no |  |
| ch_org | Tag for cloud resource objects | no |  |
| ch_project | Tag for cloud resource objects | no |  |
| ch_team | Tag for cloud resource objects | no |  |
| ch_user | Tag for cloud resource objects | no |  |
| create_hive | Should the Hive server resource be deployed? | no | TRUE |
| create_mc | Should Mission Control be deployed? | no | TRUE |
| create_nginx | Should the Nginx controller be deployed? | no | TRUE |
| create_ranger | Should Ranger be deployed? | no | TRUE |
| create_rds | Should the cloud_sql resource be created? | no | TRUE |
| create_trino | Should Starburst (Trino) be deployed? | no | TRUE |
| credentials | The Service Account credentials json file | yes | N/A |
| databases | Comma-separated list of databases to create when deploying the cloud_sql module | no |  |
| dns_zone | The DNS zone to deploy applications to | no |  |
| dns_zone_name | the DNS name in GCP | no |  |
| email | Your email address. Required if you need to deploy Nginx | no |  |
| project | The GCP Project | yes | N/A |
| reg_user | Non-Admin user (NOT IN USE) | no | sbuser |
| region | The GCP region | yes |  |
| registry | Starburst registry in Harbor | yes | harbor.starburstdata.net/starburstdata |
| repo_password | Login password to the Harbor repository | yes |  |
| repo_username | Login user for the Harbor repository | yes |  |
| repo_version | Starburst release to be deployed | yes | 350.1.1 |
| repository | Starburst Helm repository | yes | https://harbor.starburstdata.net/chartrepo/starburstdata |
| sa_name | The Google Service Account name | yes | N/A |
| sb_license | The Starburst license file | yes | N/A |
| zone | the GCP zone within the region | yes |  |
___
## Default Yaml Files
|  Parameter | Description | Required | Default |
|---|---|---|---|
| hive_yaml_file | Default values.yaml for `starburst-hive` Helm chart | yes | hms_values.yaml.tpl |
| trino_yaml_file | Default values.yaml for `starburst-presto` Helm chart. Note that there are two default files for this chart; one for when an external RDS is deployed and Insights metrics and event log data is being collected. The second, for when an RDS is not deployed and no event logging or insights metrics are being collected | yes | ["trino_values.yaml.tpl","trino_values.withInsightsMetrics.yaml.tpl"] |
| ranger_yaml_file | Default values.yaml for `starburst-ranger` Helm chart | yes | ranger_values.yaml.tpl |
| mc_yaml_file | Default values.yaml for `starburst-mission-control` Helm chart | yes | mission_control.yaml.tpl |
| operator_yaml_file | Default values.yaml for `starburst-presto-helm-operator` Helm chart | yes | operator_values.yaml.tpl |
___
## Known Issue with the GCP provider
*Only applies to deployments that include the `cloud_sql` resource.*

When Terraform does a teardown of the applications deployed by the [Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest) to `gke`, it doesn't wait for confirmation that the applications have been stopped completely before continuing on to undeploy the `cloud_sql` resource. This can cause an issue where the `event_logger` or `ranger` databases may still be in use by the terminating Kubernetes applications. The [Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) is unable to delete a database with an active connection and this will cause the teardown to fail with an error similar to this:
```
Error when reading or editing Database: googleapi: Error 400: Invalid request: failed to delete database "event_logger". Detail: pq: database "event_logger" is being accessed by other users
```
If this occurs, just wait a minute for the GKE engine to completely stop these applications and rerun your `terraform destroy` command. It should pick up where you left off and complete the teardown.

You will need to clean up the terraform state by running this command at the end:
```
terraform state rm google_sql_database.databases
```
