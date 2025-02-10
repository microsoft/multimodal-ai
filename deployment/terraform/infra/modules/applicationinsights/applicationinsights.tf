resource "azurerm_application_insights" "application_insights" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  workspace_id     = var.log_analytics_workspace_id
  application_type = "web"

  internet_ingestion_enabled    = var.app_insights_internet_ingestion_enabled
  internet_query_enabled        = var.app_insights_internet_query_enabled
  local_authentication_disabled = var.app_insights_local_authentication_disabled
}
