terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.1"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }
  }
}


# Define provider for Azure
provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}
