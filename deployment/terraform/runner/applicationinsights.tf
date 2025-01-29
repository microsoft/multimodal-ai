module "application_insights" {
  source = "../infra/modules/applicationinsights"

  location                   = var.location
  tags                       = var.tags
  resource_group_name        = azurerm_resource_group.resource_group_container_app.name
  application_insights_name  = "${local.prefix}-appi001"
  log_analytics_workspace_id = var.log_analytics_workspace_id
}
