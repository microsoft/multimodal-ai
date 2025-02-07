resource "azurerm_monitor_private_link_scope" "ampls" {
  name                = var.ampls_name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ingestion_access_mode = var.ampls_ingestion_access_mode
  query_access_mode     = var.ampls_query_access_mode
}
