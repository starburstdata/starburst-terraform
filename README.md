# starburst-terraform

A complete set of Terraform scripts to deploy Starburst to AWS, GCP and Azure managed Kubernetes services. It brings the cloud provider APIs together with Helm to create a single deployment experience for your Infrastructure and Starburst applications running on Kubernetes.

### Disclaimer
This is not part of the core Starburst product and is not covered by Starburst Enterprise support agreements. It is a community developed set of scripts to make your life easier when deploying to these cloud environments. 

### Why?
Getting an environment up and running can be challenging. Successfully repeating it and getting a consistent end result is not guaranteed either. Terraform makes this easier by providing scripting to consistently orchestrate your environment

<img src="./overview.svg?sanitize=true">

## Prerequisites

The following components should be installed and pre-configured in your local environment:

- [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) **NOTE: Currently not compatible with Terraform v0.15**
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [gcloud cli](https://cloud.google.com/sdk/docs/install)
- [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/) 

___
## Instructions
Clone a copy of this repository to your local system and follow the instructions provided within each cloud module (aws, gcp or azure) to execute against a specific cloud environment.

**Note:** This is the master directory for the whole repository, containing the common modules and global variables shared across the cloud-specific scripts. The cloud specific scripts can be found in the sub-folders:
- aws
- gcp
- azure

Terraform should be run from within these individual folders.

___
## Environment and Deployment Details

Each cloud deployment option will create the following infrastructure resources which are required to support the deployment:

- A storage account (S3, ADLS or GCS)
- A network VPC or VNet (On AWS & GCP you can turn this off and BYO VPC to the deployment)
- A managed Kubernetes cluster (EKS, GKE or AKS)

In addition, the user has the option to deploy these specific applications to the Kubernetes cluster:

- A Postgres database instance
- Hive metastore
- Starburst (i.e. the Trino application)
- Ranger
- Mission Control
- [CloudBeaver](https://cloudbeaver.io/)
- [Nginx](https://github.com/kubernetes/ingress-nginx) (if you need an https ingress for your applications)

Lastly, the user has the option to point any of these components to an existing external database:

- Hive
- Ranger
- Starburst Insights
- Mission Control

**Note:** Instructions on how to point to an existing database to support these components can be found in the cloud-specific directories.

### Helm Charts
Default Helm Charts required for the ootb deployments are located in `./helm_templates`. They can be customized to suit your needs, but be aware of the existing variables used in these files.
### Shared Terraform files
Located in `./common`, these are configuration files shared by all three cloud provider deployments. The aws, gcp and azure folders should contain symlinks to these files.
### Modules
The `./modules` directory contains the individual Terraform resource deployment modules used across the environment. Some of these are common to all three clouds, others are cloud-specific. The module name will be prefixed with the cloud provider if it is a cloud-specific deployment (e.g. aws-dns)