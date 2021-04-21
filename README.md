# starburst-terraform

A complete set of Terraform scripts to deploy Starburst to AWS, GCP and Azure managed Kubernetes services. It brings the cloud provider APIs together with Helm to create a single deployment experience for your Infrastructure and Starburst applications running on Kubernetes.

### Disclaimer
This is not part of the core Starburst product and is not covered by Starburst Enterprise support agreements. It is a community developed set of scripts to make your life easier when deploying to these cloud environments. 

### Why?
Getting an environment up and running can be challenging. Successfully repeating it and getting a consistent end result is not guaranteed either. Terraform makes this easier by providing scripting to consistently orchestrate your environment

<img src="./overview.svg?sanitize=true">

## Prerequisites

The following components should be installed and pre-configured in your local environment:

- [terraform v0.15](https://learn.hashicorp.com/tutorials/terraform/install-cli) 
- [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [gcloud cli](https://cloud.google.com/sdk/docs/install)
- [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm](https://helm.sh/docs/intro/install/)

**NOTE: Updated to be compatible with Terraform v0.15**

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
___
## Quick Setup
After checking out the module from Github to your local client and renaming the `terraform.tfvars.example` to `terraform.tfvars`, follow these helpful guidelines when setting up your environment to match its intended purpose:
___
### The Stateless "Basic" Deployment Option
*Installs a new, clean environment with default advanced settings*
- Review and set the basic parameters in `terraform.tfvars` to match your environment
- Leave all advanced paramaters set to default. *hint: advanced parameters are not included in the `.example` file*
- A basic instalation will install the following infrastructure:
    - A cloud storage account
    - A new VPC
    - A Kubernetes cluster with two node pools: `main` and `workers`. The `workers` node pool will by default use "Spot" or "Preemptible" machines. The default machine types for `main` & `workers` respectively are:
        - AWS: `m5.2xlarge` & `m5.xlarge`
        - Azure: `Standard_D8s_v3` & `Standard_D4s_v3`
        - GCP: `e2-standard-8` & `e2-standard-4`
- The Kubernetes cluster will include these applications by default:
    - A Postgres database instance which will be used by any applications that require it.
    - A Starburst cluster with the Coordinator deployed to the `main` node pool and one worker deployed to the `workers` pool. Autoscaling is included by default and both the node pool and the workers have their min & max autoscaling values set to 1 & 10.
    - A Ranger instance
    - A CloudBeaver instance. This is a web-based DBeaver application that can be used in place of a local DBeaver client.
    - An Nginx Load Balancer. This takes care of ingress over TLS for the deployed applications. DNS 'A' records are automatically added to your DNS zone.
- The deployment will print out a summary output of what was deployed, including the URL links needed to access the applications and credentials needed to authenticate to them. A password file is the default authentication method for a Basic installation
- When this environment is destroyed by Terraform (`terraform destroy`), ALL metadata will be destroyed along with it unless you manually export it beforehand.
___
### The Stateful "re"-Deployment Option
*When you require an easy way to bring up and tear down a Starburst environment, while maintaining a stateful configuration when the system is down. This option ensures that application metadata is saved externally and is not impacted by destroying your Kubernetes cluster. You will require one or more externally database instances which are accessible to the cluster for this to work.*
- Ensure that the following flags are set. You can safely add them to your `terraform.tfvars` file:
    - `create_rds = false` (you won't need the Postgres instance deployed to K8s)
    - `create_storage = false` (don't let Terraform create a storage account. Use an existing one)
    - `create_vpc = false` (For GCP/AWS only - suggest you use an existing Network)
    - `ex_vpc_id = <your-vpc>` (The name/ID of your existing VPC)
    - `deployment_id = <your-deployment-identifier>` (set it to a fixed value, so that your application URLs will be static)
- In addition, you will need to set all the `ex_*` database parameters detailed in each cloud module for the components that need to be persisted (e.g. Hive, Ranger, Insights). You should add these to your `sensitive.auto.tfvars` file (create it if it does not already exist).
- Add the following parameters to `sensitive.auto.tfvars` to ensure your user login credentials remain consistent:
    - `admin_pass = ?`
    - `reg_pass1 = ?`
    - `reg_pass2 = ?`
- If required, create separate yaml files for Hive, Ranger & Starburst to customize your environment. Note that these **do not replace the default yaml files**, they just modify the existing defaults. This way, you can just target only the parameters that you need to modify - e.g. like adding your own custom catalogs to Starburst. Refer to these files in `terraform.tfvars` via these parameters:
    - `custom_trino_yaml_file = <your-custom-file>` (include the path if you don't save it to the same folder you execute Terraform from)
    - `custom_ranger_yaml_file = <your-custom-file>` (include the path if you don't save it to the same folder you execute Terraform from)
    - `custom_hive_yaml_file = <your-custom-file>` (include the path if you don't save it to the same folder you execute Terraform from)
___
### Additional Notes
Broadly speaking, these are the main deployment approaches, so pick the one that suits your needs. Remember to review all the additional settings that can be tweaked to customize your environment even further.

There are many options that can be customized: from specifying the name and number of your K8s node pools, machine sizes & types, autoscaling min and max sizes, spot or on-demand, and individual component applications that should be deployed. This ensures that you can fine-tune your settings to suit the environment that you would like to deploy

Avoid updating the standard files and yamls, since this will make it more difficult to update your `starburst-terraform` codebase at a later date. If in doubt, any files that you create, or that are listed in `.gitignore` can be safely modified.