# Starburst-Terraform deployment for Azure
Deployment scripts built for Azure.

### Prerequisites
Ensure you have [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [helm](https://helm.sh/docs/intro/install/) installed and configured according to the cloud provider's documentation.

You should have existing user access to an Azure subscription with at least the following base IAM permissions set:
- `Owner`

OR

- `Contributor` and
- `User Access Administrator`

## Set up
1. Create a Service Principal in Azure for Terraform to work with. You will need the values returned by the create command later:
```
az login
az account set --subscription="<your_subscription_id>"
az ad sp create-for-rbac --name <your_sp_name> --role="Contributor" --scopes="/subscriptions/<your_subscription_id>"

```

2. Using the values returned in the json file, set the following global variables:
```
export ARM_CLIENT_ID=<appId-from-json>
export ARM_CLIENT_SECRET=<password-from-json>
export ARM_SUBSCRIPTION_ID=<your-subscription-id>
export ARM_TENANT_ID=<tenant-from-json>

```

3. Add the `User Access Administrator` IAM permission to the SP at the subscription level:
```
az role assignment create --assignee <service_principal_id_or_name> --role "User Access Administrator"
```
*Note: Use the SP name or id returned by the create-for-rbac command, not the displayName!*

4. Copy your Starburst license to a local directory on your client machine

5. Edit the `terraform.tfvars` file for your environment. For convenience and to ensure you don't accidentally check any sensitive values back into the GitHub repo, set any sensitive values in a separate input variables file ending in: `.auto.tfvars` (e.g. `sensitive.auto.tfvars` and add it to `.gitignore`) file or as global variables (TF_VAR_*) on your local machine:
    - `sb_license` *(point to your local file)*
    - `email`
    - `repo_username`
    - `repo_password`
    - `abfs_auth_type`
    - `abfs_client_id` *(your SP appId)*
    - `abfs_secret` *(your SP password)*

6. Create a workspace in Terraform for your deployment:
```
terraform workspace new ${your-workspace-name}
```
7. Initialize the Terraform environment:
```
terraform init
```
8. Deploy your environment:
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
| create_bucket | Should the cloud storage bucket be created? | no | true |
| create_hive | Should the Hive server resource be deployed? | no | true |
| create_k8s | Should the cloud K8s cluster be created? | no | true |
| create_mc | Should Mission Control be deployed? | no | true |
| create_nginx | Should the Nginx controller be deployed? | no | true |
| create_ranger | Should Ranger be deployed? | no | true |
| create_rds | Should the PostgreSQL instance be deployed? | no | true |
| create_trino | Should Starburst (Trino) be deployed? | no | true |
| create_vpc | Should the cloud vpc/vnet be created? | no | true |
| dns_zone | The DNS zone to deploy applications to | no |  |
| dns_zone_name | the DNS name in Azure | no |  |
| email | Your email address. Required if you need to deploy Nginx | no |  |
| presto_version | The version of Starburst that Mission Control will deploy | yes | 350-e.1 |
| primary_node_type | The VM machine type in the primary pool | no | Standard_D8s_v3 |
| primary_pool_size | The size of the base pool (runs all apps besides Trino worker nodes) | no | 1 |
| reg_user1 | Additional user login to Starburst | yes | sbuser1 |
| reg_user2 | Additional user login to Starburst | yes | sbuser2 |
| region | The Azure location | yes |  |
| registry | Starburst registry in Harbor | yes | harbor.starburstdata.net/starburstdata |
| repo_password | Login password to the Harbor repository | yes |  |
| repo_username | Login user for the Harbor repository | yes |  |
| repo_version | Starburst release to be deployed. This includes all components | yes | 350.1.1 |
| repository | Starburst Helm repository | yes | https://harbor.starburstdata.net/chartrepo/starburstdata |
| sb_license | The Starburst license file | yes | N/A |
| wait_this_long | default time to wait on resources to finalize. Currently only used to wait for Postgres K8s LoadBalancer service to complete | no | 60s |
| worker_node_type | The VM machine type in the worker pool | no | Standard_D4s_v3 |
| worker_pool_max_size | The maximum size of the worker pool (worker pool is reserved for the Trino workers) | no | 10 |
| worker_pool_min_size | The minimum size of the worker pool (worker pool is reserved for the Trino workers) | no | 1 |
___
## Default Yaml Files
|  Parameter | Description | Required | Default |
|---|---|---|---|
| hive_yaml_file | Default values.yaml for `starburst-hive` Helm chart | yes | hms_values.yaml.tpl |
| trino_yaml_file | Default values.yaml for `starburst-presto` Helm chart. Note that there are two default files for this chart; one for when an external RDS is deployed and Insights metrics and event log data is being collected. The second, for when an RDS is not deployed and no event logging or insights metrics are being collected | yes | ["trino_values.yaml.tpl","trino_values.withInsightsMetrics.yaml.tpl"] |
| ranger_yaml_file | Default values.yaml for `starburst-ranger` Helm chart | yes | ranger_values.yaml.tpl |
| mc_yaml_file | Default values.yaml for `starburst-mission-control` Helm chart | yes | mission_control.yaml.tpl |
| operator_yaml_file | Default values.yaml for `starburst-presto-helm-operator` Helm chart | yes | operator_values.yaml.tpl |
| postgres_yaml_file | Default values.yaml for Bitnami `postgresql` Helm chart | yes | postgresql.yaml.tpl |
___

## Object Storage parameters for Hive
|  Parameter | Description | Required | Default |
|---|---|---|---|
| gcp_cloud_key_secret | json file containing your Service Account's cloud credentials  | no |  |
| adl_oauth2_client_id | Azure SP ClientID | no |  |
| adl_oauth2_credential | Azure SP Password | no |  |
| adl_oauth2_refresh_url | Azure Oauth2 token refresh URL | no |  |
| s3_access_key | AWS IAM ACCESS_KEY | no |  |
| s3_endpoint | S3 endpoint | no |  |
| s3_region | AWS region to access the S3 endpoint | no |  |
| s3_secret_key | AWS IAM SECRET_KEY | no |  |
| abfs_access_key | Storage account access key | no |  |
| abfs_storage_account | Storage account name | no |  |
| abfs_auth_type | ABFS access type. Can be `accessKey` or `oauth` | no | oauth |
| abfs_client_id | Azure SP ClientID | no |  |
| abfs_endpoint | OAuth2 token refresh endpoint. You can find this in the Azure portal under: `Azure Active Directory > App Registrations > <your-app> > Endpoints` | no |  |
| abfs_secret | Azure SP Password | no |  |
| wasb_access_key | Storage account access key | no |  |
| wasb_storage_account | Storage account name | no |  |
___
