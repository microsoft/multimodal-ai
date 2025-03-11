resource "azurerm_search_service" "search_service" {
  name                = var.search_service_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  identity {
    type = "SystemAssigned"
  }

  allowed_ips  = []
  hosting_mode = "default"

  sku                 = var.search_service_sku
  semantic_search_sku = var.semantic_search_sku
  partition_count     = var.search_service_partition_count
  replica_count       = var.search_service_replica_count
  local_authentication_enabled             = false
  customer_managed_key_enforcement_enabled = false
}