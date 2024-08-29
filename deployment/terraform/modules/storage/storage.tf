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
  account_replication_type        = "ZRS"
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
  https_traffic_only_enabled        = true
  infrastructure_encryption_enabled = true
  is_hns_enabled                    = var.storage_account_hns_enabled
  large_file_share_enabled          = false
  min_tls_version                   = "TLS1_2"
  network_rules {
    # bypass                     = ["Metrics","Logging","AzureServices"]
    default_action             = "Allow"
    # ip_rules                   = []
    # virtual_network_subnet_ids = []
    # private_link_access {
    #   endpoint_tenant_id   = data.azurerm_client_config.current.tenant_id
    #   endpoint_resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Security/datascanners/StorageDataScanner"
    # }
  }
  nfsv3_enabled                 = false
  public_network_access_enabled = true
  queue_encryption_key_type     = "Account"
  table_encryption_key_type     = "Account"
  # routing {
  #   choice                      = "MicrosoftRouting"
  #   publish_internet_endpoints  = false
  #   publish_microsoft_endpoints = false
  # }
  sftp_enabled              = false
  shared_access_key_enabled = var.storage_account_shared_access_key_enabled
}

resource "azurerm_storage_container" "storage_container" {
  for_each = toset(var.storage_account_container_names)

  name                 = each.key
  storage_account_name = azurerm_storage_account.storage.name

  container_access_type = "private"
  metadata              = {}

  depends_on = [
    azurerm_role_assignment.current_role_assignment_storage_blob_data_owner
  ]
}

# resource "azurerm_storage_share" "storage_share" {
#   for_each = toset(var.storage_account_share_names)

#   name                 = each.key
#   storage_account_name = azurerm_storage_account.storage.name

#   access_tier      = "TransactionOptimized"
#   enabled_protocol = "SMB"
#   quota            = 102400
# }


# resource "azapi_resource" "storage_share" {
#   for_each = toset(var.storage_account_share_names)

#   type      = "Microsoft.Storage/storageAccounts/fileServices/shares@2021-02-01"
#   name      = each.key
#   parent_id = "${azurerm_storage_account.storage.id}/fileServices/default"
#   body = jsonencode({
#     properties = {
#       accessTier       = "TransactionOptimized"
#       enabledProtocols  = "SMB"
#       shareQuota             = 102400
#     }
#   })
#   depends_on = [
#     azurerm_storage_account.storage,
#     azurerm_role_assignment.current_role_assignment_storage_blob_data_owner
#  ]
# }