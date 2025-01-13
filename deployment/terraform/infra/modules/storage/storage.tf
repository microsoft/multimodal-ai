resource "azurerm_storage_account" "storage" {
  name                = replace(var.storage_account_name, "-", "")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }

  access_tier                     = "Hot"
  account_kind                    = "StorageV2"
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false

  blob_properties {
    change_feed_enabled = false
    container_delete_retention_policy {
      days = 7
    }
    delete_retention_policy {
      days = 7
    }
    default_service_version  = "2020-06-12"
    last_access_time_enabled = false
    versioning_enabled       = false
  }

  cross_tenant_replication_enabled  = false
  default_to_oauth_authentication   = true
  local_user_enabled                = false
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  is_hns_enabled                    = var.storage_account_hns_enabled
  large_file_share_enabled          = false
  min_tls_version                   = "TLS1_2"
  network_rules {
    bypass                     = var.network_bypass
    default_action             = var.default_action
    ip_rules                   = []
    virtual_network_subnet_ids = []
    dynamic "private_link_access" {
      for_each = var.network_private_link_access
      content {
        endpoint_resource_id = private_link_access.value
        endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
      }
    }
  }
  nfsv3_enabled                 = false
  public_network_access_enabled = var.public_network_access_enabled
  queue_encryption_key_type     = "Account"
  table_encryption_key_type     = "Account"
  routing {
    choice                      = "MicrosoftRouting"
    publish_internet_endpoints  = false
    publish_microsoft_endpoints = false
  }
  sftp_enabled              = false
  shared_access_key_enabled = var.storage_account_shared_access_key_enabled
}

resource "azurerm_storage_container" "storage_container" {
  for_each = toset(var.storage_account_container_names)

  name               = each.key
  storage_account_id = azurerm_storage_account.storage.id

  container_access_type = "private"
  metadata              = {}

  depends_on = [
    azurerm_role_assignment.current_role_assignment_storage_blob_data_owner
  ]
}
