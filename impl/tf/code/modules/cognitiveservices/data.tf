data "azurerm_client_config" "current" {}

data "azurerm_monitor_diagnostic_categories" "diagnostic_categories_cognitive_service" {
  resource_id = azurerm_cognitive_account.cognitive_service.id
}

# data "azurerm_user_assigned_identity" "user_assigned_identity" {
#   name                = var.user_assigned_identity_id
#   resource_group_name = var.resource_group_name
# }