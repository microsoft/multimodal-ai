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
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
  subscription_id     = var.subscription_id
  storage_use_azuread = true

}
