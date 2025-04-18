
This document provides instructions to implement the following enhancements for your Terraform infrastructure on Azure:

1. Remote Terraform Backend using Azure Storage Account 
2. CI/CD Pipeline using GitHub Actions to build Docker image, push to DockerHub, and deploy with Terraform

---------------------------------------

 1. Remote Terraform Backend (Azure Blob Storage)

Prerequisites:
- You should have a storage account already created (e.g., `simpletimestorageacct`)
- Create a container named `tfstate` in the storage account

 Create the Blob Container

```bash
az storage container create   --name tfstate   --account-name simpletimestorageacct   --auth-mode login
```

 Add `backend.tf`

Create a file named `backend.tf` in your project root:

terraform {
  backend "azurerm" {
    resource_group_name  = "simpletimeapp-rg"
    storage_account_name = "simpletimestorageacct"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
```

Reinitialize Terraform

terraform init -reconfigure
```

---------------------------------------------------

2. CI/CD with GitHub Actions

Requirements

Store the following secrets in your GitHub repository:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

These will be used for authenticating with Azure and DockerHub.

 Create Workflow File

Create a file at `.github/workflows/deploy.yml`:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    env:
      ARM_CLIENT_ID: ${{ secrets.ARM_CLIENT_ID }}
      ARM_CLIENT_SECRET: ${{ secrets.ARM_CLIENT_SECRET }}
      ARM_SUBSCRIPTION_ID: ${{ secrets.ARM_SUBSCRIPTION_ID }}
      ARM_TENANT_ID: ${{ secrets.ARM_TENANT_ID }}
      DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
      DOCKER_PASSWORD: ${{ secrets.DOCKER_PASSWORD }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Log in to DockerHub
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/simpletimeservice:latest .

      - name: Push Docker image
        run: docker push ${{ secrets.DOCKER_USERNAME }}/simpletimeservice:latest

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: 1.5.0

      - name: Terraform Init
        run: terraform init

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        run: terraform apply -auto-approve
```

Push to GitHub

```bash
git add backend.tf .github/workflows/deploy.yml
git commit -m "Added remote backend and CI/CD pipeline"
git push origin main
```

----------------------------------------------------
You're now using a secure, production-grade setup with remote state and automated deployment!
