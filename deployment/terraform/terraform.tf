terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.1"
    }
    azuread = {
      source = "hashicorp/azuread"
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
