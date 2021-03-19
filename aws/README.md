# Starburst-Terraform deployment for AWS
Deployment scripts built for AWS.

### Prerequisites
Ensure you have [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [helm](https://helm.sh/docs/intro/install/) installed and configured according to the cloud provider's documentation.

## Set up
1. Ensure that your `aws cli` has been preconfigured with a user that has the following permissions:
    - `AdministratorAccess`
    - `IAMFullAccess`
    - `AmazonEC2FullAccess`
    - `AutoScalingFullAccess`
    - `AmazonS3FullAccess`
    - `AmazonEKSClusterPolicy`
    - `AmazonEKSServicePolicy`

2. Copy your Starburst license to a local directory

3. Edit the `terraform.tfvars` file for your environment. For convenience and to ensure you don't accidentally check any sensitive values back into the GitHub repo, set any sensitive values in a separate input variables file ending in: `.auto.tfvars` (e.g. `sensitive.auto.tfvars` and add it to `.gitignore`) file or as global variables (TF_VAR_*) on your local machine:
    - `sb_license` *(point to your local file)*
    - `email`
    - `repo_username`
    - `repo_password`
    - `s3_role`
    - `map_roles`

4. Create a workspace in Terraform for your deployment:
```
terraform workspace new ${your-workspace-name}
```
5. Initialize the Terraform environment:
```
terraform init
```
6. Deploy your environment:
```
terraform apply
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
| email | Your email address. Required if you need to deploy Nginx | no |  |
| map_roles | Additional IAM role to attach to the EKS cluster, to allow others access to the resource in AWS | no |  |
| primary_node_type | The EC2 machine type in the primary pool | no | m5.2xlarge |
| primary_pool_size | The size of the base pool (runs all apps besides Trino worker nodes) | no | 1 |
| reg_user1 | Additional user login to Starburst | yes | sbuser1 |
| reg_user2 | Additional user login to Starburst | yes | sbuser2 |
| region | The AWS region | yes |  |
| registry | Starburst registry in Harbor | yes | harbor.starburstdata.net/starburstdata |
| repo_password | Login password to the Harbor repository | yes |  |
| repo_username | Login user for the Harbor repository | yes |  |
| repo_version | Starburst release to be deployed | yes | 350.1.1 |
| repository | Starburst Helm repository | yes | https://harbor.starburstdata.net/chartrepo/starburstdata |
| s3_role | S3 permission role which will be attached to the EKS nodes to allow S3 access to these nodes. With the role in place, you do not need to set up S3 access via IAM keys in the Starburst-Hive yaml. | no |  |
| sb_license | The Starburst license file | yes | N/A |
| wait_this_long | default time to wait on resources to finalize. Currently only used to wait for Postgres K8s LoadBalancer service to complete | no | 60s |
| worker_node_type | The Ec2 machine type in the worker pool | no | m5.xlarge |
| worker_pool_max_size | The maximum size of the worker pool (worker pool is reserved for the Trino workers) | no | 10 |
| worker_pool_min_size | The minimum size of the worker pool (worker pool is reserved for the Trino workers) | no | 1 |
| zone | the AWS zone within the region | yes |  |
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

## External RDS overrides
*If you have existing databases for these components, you can point to them with these override input parameters. Can be overridden on an individual basis.*
|  Parameter | Description | Required | Default |
|---|---|---|---|
| ex_hive_instance | Existing RDS instance to point your Hive Server to | no |  |
| ex_hive_port | Hive Database instance port | no |  |
| ex_hive_db | Hive database name (usually `hive` or `hms`) | no |  |
| ex_hive_db_user | User that can connect to the Hive Database | no |  |
| ex_hive_db_password | Password for the `ex_hive_db_user` | no |  |
| ex_mc_instance | Existing RDS instance to point Mission Control to | no |  |
| ex_mc_port | Mission Control Database instance port | no |  |
| ex_mc_db | Mission Control database name (usually `mcdemo`) | no |  |
| ex_mc_db_user | User that can connect to the Mission Control Database | no |  |
| ex_mc_db_password | Password for the `ex_mc_db_user` | no |  |
| ex_ranger_instance | Existing RDS instance to point Ranger to | no |  |
| ex_ranger_port | Ranger Database instance port | no |  |
| ex_ranger_db | Ranger database name (usually `ranger`) | no |  |
| ex_ranger_root_user | Database admin user that can connect to the Ranger Database. This should be the `postgres` user or a suitable sysadmin user with the same privileges | no |  |
| ex_ranger_root_password | Password for the `ex_ranger_root_user` | no |  |
| ex_ranger_db_user | The database user that the Ranger application will use (default is `ranger`) | no |  |
| ex_ranger_db_password | Password for `ex_ranger_db_user` | no |  |
| ex_ranger_admin_password | Password to the admin user that Starburst creates for Ranger. By default this is the same admin user used to login to Starburst (`sbadmin`)  | no |  |
| ex_ranger_svc_password | Password for the admin service account that Ranger creates internally (Ranger refers to this as the `admin` user) | no |  |
| ex_insights_instance | Existing RDS instance to point Starburst Insights to | no |  |
| ex_insights_port | Insights Database instance port | no |  |
| ex_insights_db | Insights database name (usually `event_logger`) | no |  |
| ex_insights_db_user | User that can connect to the Starburst Insights Database | no |  |
| ex_insights_db_password | Password for the `ex_insights_db_user` | no |  |