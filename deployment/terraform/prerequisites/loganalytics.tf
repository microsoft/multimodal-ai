module "loganalytics" {
  source = "./modules/loganalytics"

  location                     = var.location
  tags                         = var.tags
  resource_group_name          = azurerm_resource_group.resource_group.name
  log_analytics_workspace_name = "${local.abbrs.operationalInsightsWorkspaces}${local.prefix}-law001"
}
