resource "azurerm_monitor_private_link_scoped_service" "ampls_scoped_service" {
  name                = var.ampls_scoped_service_name
  resource_group_name = var.resource_group_name

  scope_name         = var.ampls_scope_name
  linked_resource_id = var.azure_monitor_resource_id
}