resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  allow_resource_only_permissions         = false
  cmk_for_query_forced                    = false
  immediate_data_purge_on_30_days_enabled = false
  internet_ingestion_enabled              = var.log_analytics_internet_ingestion_enabled
  internet_query_enabled                  = var.log_analytics_internet_query_enabled
  local_authentication_disabled           = var.log_analytics_local_authentication_disabled
  retention_in_days                       = var.log_analytics_retention_in_days
  sku                                     = "PerGB2018"
}
