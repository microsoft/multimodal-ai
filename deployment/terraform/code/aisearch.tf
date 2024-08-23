module "ai_search" {
  source = "./modules/aisearch"

  location            = local.location
  resource_group_name = azurerm_resource_group.mmai.name
  tags                = var.tags

  search_service_name            = local.ai_search_name
  search_service_sku             = local.ai_search_sku
  search_service_partition_count = 1
  search_service_replica_count   = 1
  customer_managed_key           = null
  log_analytics_workspace_id     = module.azure_log_analytics.log_analytics_id
  user_assigned_identity_id      = module.user_assigned_identity.user_assigned_identity_id
  subnet_id                      = null
}