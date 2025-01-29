provider "azurerm" {
  disable_correlation_request_id  = false
  environment                     = "public"
  resource_provider_registrations = "none"
  resource_providers_to_register  = local.resource_providers_to_register
  storage_use_azuread             = true

  features {
    key_vault {
      recover_soft_deleted_key_vaults   = true
      recover_soft_deleted_certificates = true
      recover_soft_deleted_keys         = true
      recover_soft_deleted_secrets      = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
  default_location               = var.location
  default_tags                   = var.tags
  disable_correlation_request_id = false
  environment                    = "public"
  skip_provider_registration     = false
}
