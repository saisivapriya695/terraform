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
