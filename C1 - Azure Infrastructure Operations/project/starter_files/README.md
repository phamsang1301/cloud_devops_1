# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
### Packer (server.json)

- Install Packer plugins by cli
  ```bash
  packer plugins install github.com/hashicorp/azure

- Export variable for packers
  ```bash
		  export ARM_CLIENT_ID=""
		  export ARM_CLIENT_SECRET=""
      export ARM_SUBSCRIPTION_ID=""
- Run the following command to initiate the build process:
  ```bash
  packer build server.json

### Deploy resources with Terraform 
  - terraform init 
  - terraform plan 
  - terraform apply 
  - terraform destroy 

   Modify value in env.tfvars to customize the Terraform deployment to match requirments (All variables used in Terraform are defined in the variables.tf file. Each variable has a description and the value of them will be defined in tfvars.) 
