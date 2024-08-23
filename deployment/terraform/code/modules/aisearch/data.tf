data "azurerm_client_config" "current" {}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_search_service" {
  resource_id = azurerm_search_service.search_service.id
}

data "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = element(split("/", var.user_assigned_identity_id), length(split("/", var.user_assigned_identity_id)) - 1)
  resource_group_name = element(split("/", var.user_assigned_identity_id), 4)
}