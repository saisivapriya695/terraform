#  instructions for automating creation of resources in azure portal for simple time service application

Pre-requisites
Before starting the task, ensure you have the following tools and accounts:

**Azure Account**:

An active Azure subscription is required to deploy the resources.

Ensure you have the appropriate permissions to create resources like function apps, resource groups, storage accounts, and service plans.

**Terraform**:

Ensure you have Terraform installed. You can download it from browser

Terraform v1.11.4 or later is recommended.

**Docker**:

Ensure Docker is installed and working on your machine. 

**Azure CLI**:

Install the Azure CLI to interact with Azure resources directly from your terminal. .

**Git**:

Install Git to manage your source code.

**Docker Image**:

Make sure the Docker image you want to deploy is available in Docker Hub or your container registry. In this example, we're using saisivapriya695/simpletimeservice:latest.

Step-by-Step Process
**Step 1**: Set up Terraform Files
Create the necessary Terraform configuration files to define your infrastructure:
in vs code create a folder for all the terraform files to reside in [here it is terraform] and create each of the file and add the below codes to respective files.

**main.tf**:[you can also clone it from the git hud repo i shared]

Define your resource group, storage account, service plan, and the function app.

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "plan" {
  name                = var.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "function" {
  name                       = var.function_app_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.plan.id
  storage_account_name       = azurerm_storage_account.storage.name
  storage_account_access_key = azurerm_storage_account.storage.primary_access_key

  site_config {
    #linux_fx_version = "DOCKER|${var.container_image}"
  }

  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL          = "https://index.docker.io"
  }
}

**terraform.tfvars**:

If you are using variables for your Terraform configuration, define them here as 
resource_group_name   = "simpletimeapp-rg"
storage_account_name  = "simpletimestorageacct"
function_app_name     = "simpletimeapp-fn"
service_plan_name     = "simpletimeapp-plan"
container_image       = "saisivapriya695/simpletimeservice:latest"

**variables.tf**:

variable "location" {
  description = "The Azure location where resources will be deployed"
  type        = string
  default     = "West Europe"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type        = string
}

variable "function_app_name" {
  description = "Name of the Function App"
  type        = string
}

variable "service_plan_name" {
  description = "Name of the Service Plan"
  type        = string
}

variable "container_image" {
  description = "Docker image to run in the function app"
  type        = string
}

**.gitignore**:

to secure secrets and api keys without sharing then through git repo use this

# Terraform state and crash files
*.tfstate
*.tfstate.*
.terraform/
crash.log

# Sensitive variable files
*.tfvars
*.tfvars.json

# Local override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Editor/OS specific files
.vscode/
.idea/
.DS_Store




**Step 2**: Initialize Terraform
Before applying the Terraform configuration, run the following command to initialize Terraform:

terraform init
This will download the required provider plugins and prepare the configuration for execution.

**Step 3**: Review the Plan
Once initialized, run terraform plan to see the changes that will be made in your Azure environment:

terraform plan
Review the plan carefully to ensure all resources are defined correctly.

**Step 4:** Apply the Terraform Configuration
Once you're satisfied with the plan, run the following command to apply the configuration and create the resources:

terraform apply
Terraform will ask for confirmation before applying the changes. Type yes to proceed.

**Step 5**: Verify the Deployment
After the apply command completes successfully, your Docker container will be deployed to the Azure Function App, and you can verify the following:

Resource Group: A new resource group simpletimeapp-rg should be created.

Storage Account: A new storage account simpletimestorageacct should be available.

Function App: Your function app should be up and running, pulling the container from Docker Hub.

You can verify the deployment in the Azure Portal under the "Function App" section.
