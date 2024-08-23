terraform {
  required_version = ">=0.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.113.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.12.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.19.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.4"
    }
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
  # Configuration options
}

provider "restapi" {
  uri                   = "https://${local.ai_search_name}.search.windows.net"
  create_returns_object = true
  write_returns_object  = true
  debug                 = true

  headers = {
    "api-key"      = module.ai_search.search_service_key # Use the variable
    "Content-Type" = "application/json"
  }

  create_method  = "POST" #POST
  update_method  = "PUT"  #PUT
  destroy_method = "DELETE"
}

provider "http" {
  # Configuration options
}