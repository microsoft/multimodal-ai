module "amplsscopedservice" {
  source = "./modules/amplsscopedservice"

  location                  = var.location
  ampls_scoped_service_name = "${local.prefix}-ampls-law"
  ampls_scope_name          = module.ampls.azurerm_monitor_private_link_scope_name
  resource_group_name       = azurerm_resource_group.resource_group.name
  azure_monitor_resource_id = module.loganalytics.log_analytics_workspace_id

}