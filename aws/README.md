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

4. Edit the `terraform.tfvars` file for your environment. Pay attention to the following variables, which can be set in this file or as global variables (TF_VAR_*) on your local machine:
    - `sb_license` *(point to your local file)*
    - `email`
    - `repo_username`
    - `repo_password`
    - `s3_role`
    - `map_roles`

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
| databases | Comma-separated list of databases to create when deploying the cloud_sql module | no |  |
| dns_zone | The DNS zone to deploy applications to | no |  |
| email | Your email address. Required if you need to deploy Nginx | no |  |
| map_roles | Additional IAM role to attach to the EKS cluster, to allow others access to the resource in AWS | no |  |
| reg_user | Non-Admin user (NOT IN USE) | no | sbuser |
| region | The AWS region | yes |  |
| registry | Starburst registry in Harbor | yes | harbor.starburstdata.net/starburstdata |
| repo_password | Login password to the Harbor repository | yes |  |
| repo_username | Login user for the Harbor repository | yes |  |
| repo_version | Starburst release to be deployed | yes | 350.1.1 |
| repository | Starburst Helm repository | yes | https://harbor.starburstdata.net/chartrepo/starburstdata |
| s3_role | S3 permission role which will be attached to the EKS nodes to allow S3 access to these nodes. With the role in place, you do not need to set up S3 access via IAM keys in the Starburst-Hive yaml. | no |  |
| sb_license | The Starburst license file | yes | N/A |
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
___

## Known Issues
The Nginx deployment isn't currently working